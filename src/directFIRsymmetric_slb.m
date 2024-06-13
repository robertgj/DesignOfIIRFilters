function [hM,slb_iter,socp_iter,func_iter,feasible] = ...
           directFIRsymmetric_slb(pfx,hM0,hM_active,na,wa,Ad,Adu,Adl,Wa, ...
                                  maxiter,ftol,ctol,verbose)
% [hM,slb_iter,socp_iter,func_iter,feasible] = ...
%   directFIRsymmetric_slb(pfx,hM0,hM_active,na,wa,Ad,Adu,Adl,Wa, ...
%                          maxiter,ftol,ctol,verbose)
% PCLS optimisation of a direct-form symmetric even-order FIR filter with
% constraints on the amplitude response. See:
% "Constrained Least Square Design of FIR Filters without Specified 
% Transition Bands", I. W. Selesnick, M. Lang and C. S. Burrus, IEEE
% Trans. Signal Processing, Vol.44, No.8, August 1996, pp.1879--1892
%
% Inputs:
%   pfx - pointer to function that calls:
%           [hM,socp_iter,func_iter,feasible]=pfx(vS,hM,hM_active,na, ..
%                                                 wa,Ad,Adu,Adl,Wa, ...
%                                                 maxiter,ftol,ctol,verbose);
%   vS - structure of peak constraint frequencies {al,au}
%   hM0 - initial distinct symmetric FIR polynomial coefficients [h0,...,hM]
%   hM_active - indexes of elements of coefficients being optimised
%   na - indexes of band edges in wa
%   wa - angular frequencies of the amplitude response
%   Ad - desired amplitude response
%   Adu,Adl - upper/lower mask for the desired amplitude response
%   Wa - amplitude response weight at each frequency
%   maxiter - maximum number of SLB iterations
%   ftol - tolerance on coefficient update
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   hM - filter design 
%   slb_iter - number of PCLS iterations
%   socp_iter - number of SOCP iterations
%   func_iter - number of function iterations
%   feasible - kc satisfies the constraints 
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
if (nargin ~= 13) || (nargout ~= 5)
  print_usage("[hM,slb_iter,socp_iter,func_iter,feasible] = ...\n\
    directFIRsymmetric_slb(pfx,hM0,hM_active,na,wa,Ad,Adu,Adl,Wa, ...\n\
                           maxiter,ftol,ctol,verbose)");
endif
if ~is_function_handle(pfx)
  feasible=false;
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
slb_iter=0;socp_iter=0;func_iter=0;feasible=false;hM=hM0(:);
% Check if the initial filter meets the constraints
vR=directFIRsymmetric_slb_set_empty_constraints();
Ak=directFIRsymmetricA(wa,hM);
vS=directFIRsymmetric_slb_update_constraints(Ak,Adu,Adl,ctol);
if directFIRsymmetric_slb_constraints_are_empty(vS)
  printf("Initial solution satisfies constraints!\n");
  feasible=true;
  return;
endif
% Nothing to do but hM0 does not satisfy the constraints
if isempty(hM_active) 
  warning("No active coefficients! Initial solution fails constraints!");
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
    [hM,siter,fiter,feasible]= ...
      feval(pfx,vS,hM,hM_active,na,wa,Ad,Adu,Adl,Wa,maxiter,ftol,ctol,verbose);
    socp_iter=socp_iter+siter;
    func_iter=func_iter+fiter;
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
    printf("Feasible solution after %d optimisation iterations\n",siter);
  else
    warning("Optimisation solution not feasible!");
    break;
  endif

  %
  % Step 4: Check for violations over vR
  % 
  Ak=directFIRsymmetricA(wa,hM);
  [vR,vS,exchanged] = ...
    directFIRsymmetric_slb_exchange_constraints(vS,vR,Ak,Adu,Adl,ctol);
  if exchanged
    printf("Step 4: R constraints violated after ");
    printf("%d PCLS iterations.\n",slb_iter)
    printf("R constraints:\n");
    directFIRsymmetric_slb_show_constraints(vR,wa,Ak);
    printf("S constraints:\n");
    directFIRsymmetric_slb_show_constraints(vS,wa,Ak);
    printf("Going to Step 2!\n");
    continue;
  else
    printf("Step 4: no R constraints violated after ")
    printf("%d PCLS iterations.\n",slb_iter)
    printf("S constraints:\n");
    directFIRsymmetric_slb_show_constraints(vS,wa,Ak);
    printf("Going to Step 5!\n");
  endif
  
  %
  % Step 5: Multiple exchange of the constraint sets
  %
  vR=vS;
  vS=directFIRsymmetric_slb_update_constraints(Ak,Adu,Adl,ctol);
  printf("Step 5: vS frequency constraints updated to:\n");
  for [v,m]=vS
    printf("vS.%s=[ ",m);printf("%d ",v);printf("]\n");
  endfor  
  printf("hM=[ ");printf("%g ",hM');printf("]'\n");
  printf("S constraints:\n");
  directFIRsymmetric_slb_show_constraints(vS,wa,Ak);

  %
  % Step 6: Check for convergence
  %
  if directFIRsymmetric_slb_constraints_are_empty(vS)
    printf("Step 6: Solution satisfying constraints found ");
    printf("after %d PCLS iterations\nDone!\n",slb_iter);
    break;
  else
    printf("Step 6: Solution does not satisfy S constraints ");
    printf("after %d PCLS iterations\n",slb_iter)
    printf("S constraints:\n");
    directFIRsymmetric_slb_show_constraints(vS,wa,Ak);
    printf("Going to Step 2!\n");
    continue;
  endif

% End of PCLS constraint loop
endwhile

endfunction
