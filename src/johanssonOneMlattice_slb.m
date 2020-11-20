function [fM,k0,k1,slb_iter,opt_iter,func_iter,feasible] = ...
         johanssonOneMlattice_slb(pfx,fM_0,k0_0,epsilon0,k1_0,epsilon1, ...
                                  fMk_u,fMk_l,fMk_active,dmax, ...
                                  wa,Ad,Adu,Adl,Wa, ...
                                  maxiter,tol,ctol,verbose)
% [fM,k0,k1,slb_iter,opt_iter,func_iter,feasible] = ...
%   johanssonOneMlattice_slb(pfx,fM_0,k0_0,epsilon0,k1_0,epsilon1, ...
%                            fMk_u,fMk_l,fMk_active,dmax, ...
%                            wa,Ad,Adu,Adl,Wa, ...
%                            maxiter,tol,ctol,verbose)
%
% PCLS optimisation of a Johansson and Saramaki cascade allpass band-stop
% filter with the all-pass filters implemented as one-multiplier lattice
% filters and with constraints on the amplitude response. See:
%
% "Constrained Least Square Design of FIR Filters without Specified 
% Transition Bands", I. W. Selesnick, M. Lang and C. S. Burrus, IEEE
% Trans. Signal Processing, Vol.44, No.8, August 1996, pp.1879--1892
%
% Inputs:
%   pfx - pointer to function that calls the inner optimisation loop:   
%         [fM,k0,k1,socp_iter,func_iter,feasible]= ...
%           pfx(vS,fM_0,k0_0,epsilon0,k1_0,epsilon1, ...
%               fMk_u,fMk_l,fMk_active,dmax, ...
%               wa,Ad,Adu,Adl,Wa, ...
%               maxiter,tol,verbose);
%   fM_0 - distinct initial coefficients of the FIR filter: [f0_0,...,fM_0]
%   k0_0,k1_0 - initial vector of allpass multipliers
%   epsilon0,epsilon1- state scaling coefficients. These have no effect on the
%                      response but can improve numerical accuracy.
%   fMk_u,fMk_l - upper and lower bounds on the coefficients
%   fMk_active - indexes of the coefficents being optimised
%   dmax - maximum of norm of the coefficient step (SQP only)
%   wa - angular frequencies of amplitude response
%   Ad - desired amplitude response
%   Adu,Adl - upper/lower mask for the desired amplitude response
%   Wa - amplitude response weight at each frequency
%   maxiter - maximum number of SQP iterations
%   tol - tolerance on coefficient update
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   fM,k0,k1 - filter design 
%   slb_iter - number of PCLS iterations
%   opt_iter - number of optimisation loop iterations
%   func_iter - number of function calls
%   feasible - fMkc satisfies the constraints 
%
% The constraints exchange algorithm is:
% 
%  1. Initialise the constraint sets R and S to the empty set
%  2. Solve for the Lagrange multipliers at the constraints in S
%  3. Check the KKT conditions. If they fail then remove the 
%     constraint with the most negative Lagrange multiplier from
%     S and go back to step 2.
%  4. Exchange constraints: calculate the new response and check 
%     for violation of the constraints in R. If any constraints 
%     are violated then move them from R to S and go back to step 2.
%  5. Update constraints: overwrite the previous constraint set R 
%     with S. Set the constraint set S to contain the peak or 
%     trough frequencies that fail the constraints.
%  6. If the solution has not converged then go back to step 2.
%
% See Figure 4 of "A Modified Algorithm for Constrained Least 
% Square Design of Multiband FIR Filters without Specified 
% Transition Bands", I. W. Selesnick, M. Lang and C. S. Burrus, IEEE
% Transactions on Signal Processing, 46(2):497-501, February 1998.

% Copyright (C) 2019 Robert G. Jenssen
%
% Permission is hereby granted, free of charge, to any person
% obtaining a copy of this software and associated documentation
% files (the "Software"), to deal in the Software without restriction,
% including without limitation the rights to use, copy, modify, merge,
% publish, distribute, sublicense, and/or sell copies of the Software,
% and to permit persons to whom the Software is furnished to do so,
% subject to the following conditions: The above copyright notice and
% this permission notice shall be included in all copies or substantial
% portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  %
  % Sanity checks
  %
  if (nargin ~= 19) || (nargout ~=7)
    print_usage("[fM,k0,k1,slb_iter,opt_iter,func_iter,feasible] = ...\n\
    johanssonOneMlattice_slb(pfx,fM_0,k0_0,epsilon0,k1_0,epsilon1, ...\n\
                             fMk_u,fMk_l,fMk_active,dmax,wa,Ad,Adu,Adl,Wa, ...\n\
                             maxiter,tol,ctol,verbose)");
  endif
  if ~is_function_handle(pfx)
    error("Expected pfx to be a function handle!");
  endif

  %
  % SLB constraints
  %

  %
  % Step 1: Initialise constraint sets of the amplitude response
  % over frequency. vS.al etc are angular frequencies.
  %
  % Initialise the SLB loop parameters (these are also output values)
  slb_iter=0;opt_iter=0;func_iter=0;feasible=false;
  fM=fM_0(:);k0=k0_0(:);k1=k1_0(:);fMk=[fM;k0;k1];
  % Check if the initial filter meets the constraints
  vR=johanssonOneMlattice_slb_set_empty_constraints();
  Azpk=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1,epsilon1);
  vS=johanssonOneMlattice_slb_update_constraints(Azpk,Adu,Adl,Wa,ctol);
  if johanssonOneMlattice_slb_constraints_are_empty(vS) && ...
     all(fMk_u>=fMk) && all(fMk_l<=fMk)
    printf("Initial solution satisfies constraints!\n");
    feasible=true;
    return;
  endif
  % Nothing to do but k and c do not satisfy the constraints
  if isempty(fMk_active)
    feasible=false;
    return;
  endif
  
  % PCLS loop
  while 1
    
    % Check loop iterations
    slb_iter = slb_iter+1;
    if slb_iter>maxiter
      warning("PCLS loop iteration limit exceeded!");
      break;
    endif

    %
    % Step 2 : Solve the minimisation problem with the active constraints  
    % Step 3 : Test for optimality with Karush-Kuhn-Tucker conditions(SQP only)
    %
    try
      [nextfM,nextk0,nextk1,tmp_opt_iter,tmp_func_iter,feasible] = ...
      feval(pfx,vS,fM,k0,epsilon0,k1,epsilon1,fMk_u,fMk_l,fMk_active,dmax, ...
            wa,Ad,Adu,Adl,Wa,maxiter,tol,verbose);
      opt_iter=opt_iter+tmp_opt_iter;
      func_iter=func_iter+tmp_func_iter;
    catch
      feasible=0;
      err=lasterror();
      warning("feval(pfx,...) failure : %s",err.message);
      for e=1:length(err.stack)
        printf("Called from %s at line %d\n", ...
               err.stack(e).name, err.stack(e).line);
      endfor
    end_try_catch
    if feasible
      if fM==nextfM && k0==nextk0 && k1==nextk1
        printf("fM=[ ");printf("%f ",fM');printf("]';\n");
        printf("k0=[ ");printf("%f ",k0');printf("]';\n");
        printf("k1=[ ");printf("%f ",k1');printf("]';\n");
        warning("No change to solution after %d PCLS iterations\n",slb_iter);
        for [v,m]=vR
          printf("vR.%s=[ ",m);printf("%d ",v);printf("]\n");
        endfor
        for [v,m]=vS
          printf("vS.%s=[ ",m);printf("%d ",v);printf("]\n");
        endfor
        if johanssonOneMlattice_slb_constraints_are_empty(vR)
          break;
        endif
      endif
      fM=nextfM;
      k0=nextk0; 
      k1=nextk1; 
      printf("Feasible solution after %d optimisation iterations\n", ...
             tmp_opt_iter);
    else
      warning("Optimisation solution not feasible!");
      break;
    endif

    %
    % Step 4: Check for violations over vR
    % 
    Azpk=johanssonOneMlatticeAzp(wa,fM,k0,epsilon0,k1,epsilon1);
    [vR,vS,exchanged] = johanssonOneMlattice_slb_exchange_constraints ...
                          (vS,vR,Azpk,Adu,Adl,ctol);
    if exchanged
      printf("Step 4: R constraints violated after ");
      printf("%d PCLS iterations.\n",slb_iter)
      printf("R constraints:\n");
      johanssonOneMlattice_slb_show_constraints(vR,wa,Azpk);
      printf("S constraints:\n");
      johanssonOneMlattice_slb_show_constraints(vS,wa,Azpk);
      printf("Going to Step 2!\n");
      continue;
    else
      printf("Step 4: no R constraints violated after ")
      printf("%d PCLS iterations.\n",slb_iter)
      printf("S constraints:\n");
      johanssonOneMlattice_slb_show_constraints(vS,wa,Azpk);
      printf("Going to Step 5!\n");
    endif
    
    %
    % Step 5: Multiple exchange of the constraint sets
    %
    vR=vS;
    vS=johanssonOneMlattice_slb_update_constraints(Azpk,Adu,Adl,Wa,ctol);
    printf("Step 5: vS frequency constraints updated to:\n");
    for [v,m]=vS
      printf("vS.%s=[ ",m);printf("%d ",v);printf("]\n");
    endfor  
    printf("fM=[ ");printf("%f ",fM');printf("]';\n");
    printf("k0=[ ");printf("%f ",k0');printf("]';\n");
    printf("k1=[ ");printf("%f ",k1');printf("]';\n");
    printf("S constraints:\n");
    johanssonOneMlattice_slb_show_constraints(vS,wa,Azpk);

    %
    % Step 6: Check for convergence
    %
    if johanssonOneMlattice_slb_constraints_are_empty(vS)
      printf("Step 6: Solution satisfying constraints found ");
      printf("after %d PCLS iterations\nDone!\n",slb_iter);
      break;
    else
      printf("Step 6: Solution does not satisfy S constraints ");
      printf("after %d PCLS iterations\n",slb_iter)
      printf("S constraints:\n");
      johanssonOneMlattice_slb_show_constraints(vS,wa,Azpk);
      printf("Going to Step 2!\n");
      continue;
    endif

  % End of PCLS constraint loop
  endwhile

endfunction
