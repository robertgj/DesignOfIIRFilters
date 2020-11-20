function [xk,slb_iter,opt_iter,func_iter,feasible] = ...
           iir_frm_slb(pfx,x0k,xu,xl,U,V,M,Q,na,nc,Mmodel,Dmodel, ...
                       w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt, ...
                       maxiter,tol,ctol,verbose)
% [xk,slb_iter,opt_iter,func_iter,feasible] = ...
%   iir_frm_slb(pfx,x0k,xu,xl,U,V,M,Q,na,nc,Mmodel,Dmodel, ...
%               w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt, ...
%               maxiter,tol,ctol,verbose)
%
% PCLS optimisation of an FRM filter with constraints on the amplitude and
% group delay responses. The FRM filter has a model filter comprised of an
% IIR filter in parallel with a delay and linear phase (ie:symmetric) FIR
% masking filters. See:
%
% "Constrained Least Square Design of FIR Filters without Specified 
% Transition Bands", I. W. Selesnick, M. Lang and C. S. Burrus, IEEE
% Trans. Signal Processing, Vol.44, No.8, August 1996, pp.1879--1892
%
% Inputs:
%   pfx - pointer to function that calls the inner optimisation loop:   
%         [xk,socp_iter,func_iter,feasible]= ...
%         pfx(vS,x0,ru,rl,Vr,Qr,na,nc,M,Dmodel, ...
%             w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt,maxiter,tol,verbose);
%   x0k - initial coefficient vector in the form:
%          [ K,zR(1:U),pR(1:V); ...
%            abs(z(1:Mon2)); angle(z(1:Mon2)); ...
%            abs(p(1:Qon2)); angle(p(1:Qon2)) ];
%        where zR represents the real zeros, pR represents real poles,
%        z represents conjugate zero pairs and p represent conjugate pole pairs.
%   xu,xl - upper and lower bounds on the coefficients of the IIR filter
%   U - number of real zeros
%   V - number of real poles
%   M - number of conjugate zero pairs
%   Q - number of conjugate pole pairs
%   na - length of the FIR masking filter
%   nc - length of the FIR complementary masking filter
%   Mmodel - decimation factor of the IIR branch of the model filter
%   Dmodel - delay of the pure delay branch of the model filter
%   w - angular frequencies of amplitude and pass-band delay response
%        in [0,pi]. 
%   Asqd - desired squared amplitude response
%   Asqdu,Asqdl - upper/lower mask for the desired squared amplitude response
%   Wa - squared amplitude response weight at each frequency
%   Td - desired passband group delay response
%   Tdu,Tdl - upper/lower mask for the desired group delay response
%   Wt - group delay response weight at each frequency
%   maxiter - maximum number of SQP iterations
%   tol - tolerance on relative size of the coefficient update
%   ctol - tolerance on response constraints
%   verbose - 
%
% Outputs:
%   x - filter design 
%   slb_iter - number of PCLS iterations
%   opt_iter - number of optimisation loop iterations
%   func_iter - number of function calls
%   feasible - x satisfies the constraints 
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

% Copyright (C) 2017,2018 Robert G. Jenssen
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
  if (nargin ~= 25) || (nargout ~= 5)
    print_usage("[xk,slb_iter,opt_iter,func_iter,feasible] = ...\n\
         iir_frm_slb(pfx,x0k,xu,xl,U,V,M,Q,na,nc,Mmodel,Dmodel, ...\n\
                     w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt, ...\n\
                     maxiter,tol,verbose)");
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
  vR=iir_frm_slb_set_empty_constraints();
  [Asqk,Tk]=iir_frm(w,x0k,U,V,M,Q,na,nc,Mmodel,Dmodel);
  vS=iir_frm_slb_update_constraints(Asqk,Asqdu,Asqdl,Wa,Tk,Tdu,Tdl,Wt,ctol);

  % Initialise SLB loop parameters
  info=0;slb_iter=0;opt_iter=0;func_iter=0;feasible=false;xk=x0k(:);

  % PCLS loop
  while 1
    
    % Check loop iterations
    slb_iter = slb_iter+1;
    if slb_iter>maxiter
      warning("PCLS loop iteration limit exceeded!");
      break;
    endif
    printf("\nStarting SLB loop iteration %d\n", slb_iter);

    %
    % Step 2 : Solve the minimisation problem with the active constraints  
    % Step 3 : Test for optimality with Karush-Kuhn-Tucker conditions
    %
    try
      [nextxk,tmp_opt_iter,tmp_func_iter,feasible] = ...
      feval(pfx,vS,xk,xu,xl,U,V,M,Q,na,nc,Mmodel,Dmodel, ...
            w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt,maxiter,tol,verbose);
      opt_iter = opt_iter + tmp_opt_iter;
      func_iter = func_iter + tmp_func_iter;
    catch
      feasible=0;
      err=lasterror();
      for e=1:length(err.stack)
        printf("Called from %s at line %d\n", ...
               err.stack(e).name, err.stack(e).line);
      endfor
      error("feval(pfx,...) failure : %s",err.message);
    end_try_catch
    if feasible
      if xk==nextxk
        printf("xk=[ ");printf("%f ",xk);printf("]';\n");
        warning("No change to solution after %d PCLS iterations\n",slb_iter);
        for [v,m]=vR
          printf("vR.%s=[ ",m);printf("%d ",v);printf("]\n");
        endfor
        for [v,m]=vS
          printf("vS.%s=[ ",m);printf("%d ",v);printf("]\n");
        endfor
        if iir_frm_slb_constraints_are_empty(vR)
          break;
        endif
      endif
      xk=nextxk;
      printf("Feasible solution after %d optimisation iterations\n", ...
             tmp_opt_iter);
      printf("xk=[ ");printf("%f ",xk);printf("]';\n");
    else
      warning("Optimisation solution not feasible!");
      break;
    endif

    %
    % Step 4: Check for violations over vR
    % 
    [Asqk,Tk]=iir_frm(w,xk,U,V,M,Q,na,nc,Mmodel,Dmodel);
    [vR,vS,exchanged] = iir_frm_slb_exchange_constraints ...
                          (vS,vR,Asqk,Asqdu,Asqdl,Tk,Tdu,Tdl,ctol);
    if exchanged
      printf("Step 4: R constraints violated after ");
      printf("%d PCLS iterations\nGoing to Step 2!\n",slb_iter);
      continue;
    else
      printf("Step 4: no R constraints violated after ")
      printf("%d PCLS iterations\nGoing to Step 5!\n",slb_iter);
    endif

    %
    % Step 5: Multiple exchange of the constraint sets
    %
    vR=vS;
    vS=iir_frm_slb_update_constraints(Asqk,Asqdu,Asqdl,Wa,Tk,Tdu,Tdl,Wt,ctol);
    printf("Step 5: vS frequency constraints updated to:\n");
    for [v,m]=vS
      printf("vS.%s=[ ",m);printf("%d ",v);printf("]\n");
    endfor

    %
    % Step 6: Check for convergence
    %
    if iir_frm_slb_constraints_are_empty(vS)
      printf("Step 6: Solution satisfying constraints found ");
      printf("after %d PCLS iterations\nDone!\n",slb_iter);
      break;
    else
      printf("Step 6: Solution does not satisfy S constraints ");
      printf("after %d PCLS iterations\nGoing to Step 2!\n",slb_iter);
      continue;
    endif

  % End of PCLS constraint loop
  endwhile

endfunction
