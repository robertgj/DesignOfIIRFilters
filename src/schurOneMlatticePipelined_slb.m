function [k,c,kk,ck,slb_iter,opt_iter,func_iter,feasible] = ...
         schurOneMlatticePipelined_slb(pfx,k0,epsilon0,c0,kk0,ck0, ...
                              kc_u,kc_l,kc_active,dmax, ...
                              wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                              wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
                              maxiter,ftol,ctol,verbose)
% [k,c,kk,ck,slb_iter,opt_iter,func_iter,feasible] = ...
%   schurOneMlatticePipelined_slb(pfx,k0,epsilon0,c0,kk0,ck0, ...
%                        kc_u,kc_l,kc_active,dmax, ...
%                        wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                        wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
%                        maxiter,ftol,ctol,verbose)
%
% PCLS optimisation of a pipelined one-multiplier lattice filter with
% constraints on the amplitude and group delay responses. See:
%
% "Constrained Least Square Design of FIR Filters without Specified 
% Transition Bands", I. W. Selesnick, M. Lang and C. S. Burrus, IEEE
% Trans. Signal Processing, Vol.44, No.8, August 1996, pp.1879--1892
%
% Inputs:
%   pfx - pointer to function that calls the inner optimisation loop:   
%         [k,c,socp_iter,func_iter,feasible]= ...
%           pfx(vS,k0,epsilon0,c0,kk0,ck0,kc_u,kc_l,kc_active,dmax, ...
%               wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%               wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose);
%   k0 - initial vector of allpass multipliers
%   epsilon0 - state scaling coefficients. These have no effect on the
%                 response but can improve numerical accuracy.
%   c0 - initial vector of numerator tap coefficients
%   kk0 - nominally k0(1:(Nk-1)).*k0(2:Nk)
%   ck0 - nominally c0(2:Nk).*k0(2:Nk) (where c(1)=c_{0}, ... , c(Nk+1)=c_{Nk})
%   kc_u,kc_l - upper and lower bounds on the coefficients
%   kc_active - indexes of the coefficients being optimised
%   dmax - maximum of norm of the coefficient step (SQP only)
%   wa - angular frequencies of amplitude response
%   Asqd - desired squared amplitude response
%   Asqdu,Asqdl - upper/lower mask for the desired squared amplitude response
%   Wa - squared amplitude response weight at each frequency
%   wt - angular frequencies of group delay response
%   Td - desired group delay response
%   Tdu,Tdl - upper/lower mask for the desired group delay response
%   Wt - group delay response weight at each frequency
%   wp - angular frequencies of phase response 
%   Pd - desired phase response
%   Pdu,Pdl - upper/lower mask for the desired phase response
%   Wp - phase response weight at each frequency
%   wd - angular frequencies of the dAsqdw response
%   Dd - desired passband dAsqdw response
%   Ddu,Ddl - upper/lower mask for the desired dAsqdw response
%   Wd - dAsqdw response weight at each frequency

%   maxiter - maximum number of SQP iterations
%   ftol - tolerance on coefficient update
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   k,c,kk,ck - filter design 
%   slb_iter  - number of PCLS iterations
%   opt_iter  - number of optimisation loop iterations
%   func_iter - number of function calls
%   feasible  - kc satisfies the constraints 
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

% Copyright (C) 2024-2025 Robert G. Jenssen
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
if (nargin ~= 34) || (nargout ~= 8)
  print_usage(["[k,c,kk,ck,slb_iter,opt_iter,func_iter,feasible] = ...\n", ...
 "     schurOneMlatticePipelined_slb(pfx,k0,epsilon0,c0,kk0,ck0, ...\n", ...
 "                          kc_u,kc_l,kc_active,dmax, ...\n", ...
 "                          wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...\n", ...
 "                          wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...\n", ...
 "                          maxiter,ftol,ctol,verbose)"]);
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
k=k0(:);c=c0(:);kk=kk0(:);ck=ck0(:);kc=[k;c;kk;ck];

% Check if the initial filter meets the constraints
vR=schurOneMlatticePipelined_slb_set_empty_constraints();
Asqk=schurOneMlatticePipelinedAsq(wa,k,epsilon0,c,kk,ck);
Tk=schurOneMlatticePipelinedT(wt,k,epsilon0,c,kk,ck);
Pk=schurOneMlatticePipelinedP(wp,k,epsilon0,c,kk,ck);
dAsqdwk=schurOneMlatticePipelineddAsqdw(wd,k,epsilon0,c,kk,ck);
vS=schurOneMlatticePipelined_slb_update_constraints ...
     (Asqk,Asqdu,Asqdl,Wa,Tk,Tdu,Tdl,Wt,Pk,Pdu,Pdl,Wp,dAsqdwk,Ddu,Ddl,Wd,ctol);

if schurOneMlatticePipelined_slb_constraints_are_empty(vS) ...
   && ...
   all(kc_u>=kc)&&all(kc_l<=kc)
  printf("Initial solution satisfies constraints!\n");
  feasible=true;
  return;
endif
% Nothing to do but k and c do not satisfy the constraints
if isempty(kc_active)
  feasible=false;
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
    [k,c,kk,ck,tmp_opt_iter,tmp_func_iter,feasible] = ...
      feval(pfx,vS,k,epsilon0,c,kk,ck,kc_u,kc_l,kc_active,dmax, ...
            wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
            wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
            maxiter,ftol,ctol,verbose);
    opt_iter=opt_iter+tmp_opt_iter;
    func_iter=func_iter+tmp_func_iter;
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
    printf("k=[ ");printf("%f ",k);printf("]';\n");
    printf("c=[ ");printf("%f ",c);printf("]';\n");      
    printf("kk=[ ");printf("%f ",kk);printf("]';\n");
    printf("ck=[ ");printf("%f ",ck);printf("]';\n");      
  else
    warning("Optimisation solution not feasible!");
    break;
  endif

  %
  % Step 4: Check for violations over vR
  % 
  Asqk=schurOneMlatticePipelinedAsq(wa,k,epsilon0,c,kk,ck);
  Tk=schurOneMlatticePipelinedT(wt,k,epsilon0,c,kk,ck);
  Pk=schurOneMlatticePipelinedP(wp,k,epsilon0,c,kk,ck);
  dAsqdwk=schurOneMlatticePipelineddAsqdw(wd,k,epsilon0,c,kk,ck);
  [vR,vS,exchanged] = ...
    schurOneMlatticePipelined_slb_exchange_constraints ...
      (vS,vR,Asqk,Asqdu,Asqdl,Tk,Tdu,Tdl,Pk,Pdu,Pdl,dAsqdwk,Ddu,Ddl,ctol);
  if exchanged
    printf("Step 4: R constraints violated after ");
    printf("%d PCLS iterations.\n",slb_iter)
    printf("R constraints:\n");
    schurOneMlatticePipelined_slb_show_constraints ...
      (vR,wa,Asqk,wt,Tk,wp,Pk,wd,dAsqdwk);
    printf("S constraints:\n");
    schurOneMlatticePipelined_slb_show_constraints ...
      (vS,wa,Asqk,wt,Tk,wp,Pk,wd,dAsqdwk);
    printf("Going to Step 2!\n");
    continue;
  else
    printf("Step 4: no R constraints violated after ")
    printf("%d PCLS iterations.\n",slb_iter)
    printf("S constraints:\n");
    schurOneMlatticePipelined_slb_show_constraints ...
      (vS,wa,Asqk,wt,Tk,wp,Pk,wd,dAsqdwk);
    printf("Going to Step 5!\n");
  endif
  
  %
  % Step 5: Multiple exchange of the constraint sets
  %
  vR=vS;
  vS=schurOneMlatticePipelined_slb_update_constraints ...
       (Asqk,Asqdu,Asqdl,Wa,Tk,Tdu,Tdl,Wt,Pk,Pdu,Pdl,Wp,dAsqdwk,Ddu,Ddl,Wd,ctol);
  printf("Step 5: vS frequency constraints updated to:\n");
  for [v,m]=vS
    printf("vS.%s=[ ",m);printf("%d ",v);printf("]\n");
  endfor  
  printf("k=[ ");printf("%g ",k');printf("]'\n");
  printf("c=[ ");printf("%g ",c');printf("]'\n");
  printf("kk=[ ");printf("%g ",kk');printf("]'\n");
  printf("ck=[ ");printf("%g ",ck');printf("]'\n");
  printf("S constraints:\n");
  schurOneMlatticePipelined_slb_show_constraints ...
    (vS,wa,Asqk,wt,Tk,wp,Pk,wd,dAsqdwk);

  %
  % Step 6: Check for convergence
  %
  if schurOneMlatticePipelined_slb_constraints_are_empty(vS)
    printf("Step 6: Solution satisfying constraints found ");
    printf("after %d PCLS iterations\nDone!\n",slb_iter);
    break;
  else
    printf("Step 6: Solution does not satisfy S constraints ");
    printf("after %d PCLS iterations\n",slb_iter)
    printf("S constraints:\n");
    schurOneMlatticePipelined_slb_show_constraints ...
      (vS,wa,Asqk,wt,Tk,wp,Pk,wd,dAsqdwk);
    printf("Going to Step 2!\n");
    continue;
  endif

% End of PCLS constraint loop
endwhile

endfunction
