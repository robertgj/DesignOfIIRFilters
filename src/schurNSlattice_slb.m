function [s10,s11,s20,s00,s02,s22,slb_iter,opt_iter,func_iter,feasible] = ...
  schurNSlattice_slb(pfx,s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                        sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
                        wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                        maxiter,ftol,ctol,verbose)
% [s10,s11,s20,s00,s02,s22,slb_iter,opt_iter,func_iter,feasible] = ...
%   schurNSlattice_slb(pfx,s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
%                      sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
%                      wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                      maxiter,ftol,ctol,verbose)
%
% PCLS optimisation of a normalised-scaled lattice filter with constraints on
% the amplitude and group delay responses. See:
%
% "Constrained Least Square Design of FIR Filters without Specified 
% Transition Bands", I. W. Selesnick, M. Lang and C. S. Burrus, IEEE
% Trans. Signal Processing, Vol.44, No.8, August 1996, pp.1879--1892
%
% The sxx_u and sxx_l are vectors with the per-section limits on the
% coefficients arranged in the order [s10(1),s11(1),...,s00,(Ns),s22(Ns)]
% and sxx_active is a vector of indexes into those vectors.
%
% Inputs:
%   pfx - pointer to function that calls the inner optimisation loop:   
%         [s10,s11,s20,s00,s02,s22,socp_iter,func_iter,feasible]= ...
%           pfx(vS,s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
%               sxx_u,sxx_l,sxx_active,dmax, ...
%               wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%               maxiter,ftol,ctol,verbose);
%   s10_0,s11_0,s20_0,s00_0,s02_0,s22_0 - initial lattice coefficients
%   sxx_u,sxx_l - upper and lower bounds on lattice coefficients
%   sxx_active - indexes of elements of s10,etc being optimised
%   sxx_symmetric - enforce s02=-s20 and s22=s00
%   dmax - maximum of norm of the coefficient step (SQP only)
%   wa - angular frequencies of amplitude response in [0,pi]. 
%   Asqd - desired squared amplitude response
%   Asqdu,Asqdl - upper/lower mask for the desired squared amplitude response
%   Wa - squared amplitude response weight at each frequency
%   wt - angular frequencies of group delay response in [0,pi]. 
%   Td - desired passband group delay response
%   Tdu,Tdl - upper/lower mask for the desired group delay response
%   Wt - group delay response weight at each frequency
%   maxiter - maximum number of SQP iterations
%   ftol - tolerance on coefficient update
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   s10,s11,s20,s00,s02,s22 - filter design 
%   slb_iter - number of PCLS iterations
%   opt_iter - number of optimisation loop iterations
%   func_iter - number of function calls
%   feasible - the design s10,etc satisfies the constraints 
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

% Copyright (C) 2017-2024 Robert G. Jenssen
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
if (nargin ~= 26) || (nargout ~=10)
  print_usage...
    ("[s10,s11,s20,s00,s02,s22,slb_iter,opt_iter,func_iter,feasible] = ...\n\
schurNSlattice_slb(pfx,s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...\n\
                   sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...\n\
                   wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...\n\
                   maxiter,ftol,ctol,verbose)");
endif
if ~is_function_handle(pfx)
  error("Expected pfx to be a function handle!");
endif

%
% SLB constraints
%

%
% Step 1: Initialise constraint sets of the amplitude and group
% delay responses over frequency. vS.al etc are angular frequencies.
%
% Initialise the SLB loop parameters (these are also output values)
slb_iter=0;opt_iter=0;func_iter=0;feasible=false;
s10=s10_0(:)';s11=s11_0(:)';
s20=s20_0(:)';s00=s00_0(:)';
s02=s02_0(:)';s22=s22_0(:)';
sxx_0=reshape([s10;s11;s20;s00;s02;s22],1,6*length(s10));
% Check if the initial filter meets the constraints
vR=schurNSlattice_slb_set_empty_constraints();
Asqk=schurNSlatticeAsq(wa,s10,s11,s20,s00,s02,s22);
Tk=schurNSlatticeT(wt,s10,s11,s20,s00,s02,s22);
vS=schurNSlattice_slb_update_constraints ...
     (Asqk,Asqdu,Asqdl,Wa,Tk,Tdu,Tdl,Wt,ctol);
if schurNSlattice_slb_constraints_are_empty(vS) ...
   && all((sxx_u+ctol)>=sxx_0) && all(sxx_0>=(sxx_l-ctol))
  printf("Initial solution satisfies constraints!\n");
  feasible=true;
  return;
endif

% PCLS loop
while 1
  
  % Check loop iterations
  slb_iter = slb_iter+1;
  if slb_iter>maxiter
    feasible=false;
    warning("PCLS loop iteration limit exceeded!");
    break;
  endif

  %
  % Step 2 : Solve the minimisation problem with the active constraints  
  % Step 3 : Test for optimality with Karush-Kuhn-Tucker conditions(SQP only)
  %
  try
    feasible=false;
    [s10,s11,s20,s00,s02,s22,tmp_opt_iter,tmp_func_iter,feasible] = ...
      feval(pfx,vS,s10,s11,s20,s00,s02,s22, ...
            sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
            wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
            maxiter,ftol,ctol,verbose);
    opt_iter = opt_iter + tmp_opt_iter;
    func_iter = func_iter + tmp_func_iter;
  catch
    feasible=false;
    err=lasterror();
    warning("feval(pfx,...) failure : %s",err.message);
    for e=1:length(err.stack)
      printf("Called from %s at line %d\n", ...
             err.stack(e).name, err.stack(e).line);
    endfor
  end_try_catch
  
  if feasible
    printf("Feasible solution after %d optimisation iterations\n",tmp_opt_iter);
  else
    warning("Optimisation solution not feasible!");
    break;
  endif

  %
  % Step 4: Check for violations over vR
  % 
  Asqk=schurNSlatticeAsq(wa,s10,s11,s20,s00,s02,s22);
  Tk=schurNSlatticeT(wt,s10,s11,s20,s00,s02,s22);
  [vR,vS,exchanged] = schurNSlattice_slb_exchange_constraints ...
                        (vS,vR,Asqk,Asqdu,Asqdl,Tk,Tdu,Tdl,ctol);
  if exchanged
    printf("Step 4: R constraints violated after ");
    printf("%d PCLS iterations.\n",slb_iter)
    printf("R constraints:\n");
    schurNSlattice_slb_show_constraints(vR,wa,Asqk,wt,Tk);
    printf("S constraints:\n");
    schurNSlattice_slb_show_constraints(vS,wa,Asqk,wt,Tk);
    printf("Going to Step 2!\n");
    continue;
  else
    printf("Step 4: no R constraints violated after ")
    printf("%d PCLS iterations.\n",slb_iter)
    printf("S constraints:\n");
    schurNSlattice_slb_show_constraints(vS,wa,Asqk,wt,Tk);
    printf("Going to Step 5!\n");
  endif
  
  %
  % Step 5: Multiple exchange of the constraint sets
  %
  vR=vS;
  vS=schurNSlattice_slb_update_constraints ...
       (Asqk,Asqdu,Asqdl,Wa,Tk,Tdu,Tdl,Wt,ctol);
  printf("Step 5: vS frequency constraints updated to:\n");
  for [v,m]=vS
    printf("vS.%s=[ ",m);printf("%d ",v);printf("]\n");
  endfor  
  printf("S constraints:\n");
  schurNSlattice_slb_show_constraints(vS,wa,Asqk,wt,Tk);

  %
  % Step 6: Check for convergence
  %
  if schurNSlattice_slb_constraints_are_empty(vS)
    printf("Step 6: Solution satisfying constraints found ");
    printf("after %d PCLS iterations\nDone!\n",slb_iter);
    break;
  else
    printf("Step 6: Solution does not satisfy S constraints ");
    printf("after %d PCLS iterations\n",slb_iter)
    printf("S constraints:\n");
    schurNSlattice_slb_show_constraints(vS,wa,Asqk,wt,Tk);
    printf("Going to Step 2!\n");
    continue;
  endif

% End of PCLS constraint loop
endwhile

endfunction
