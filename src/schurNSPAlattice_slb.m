function [A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
          slb_iter,opt_iter,func_iter,feasible] = ...
  schurNSPAlattice_slb(pfx, ...
                       A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
                       A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
                       difference, ...
                       sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
                       wa,Asqd,Asqdu,Asqdl,Wa, ...
                       wt,Td,Tdu,Tdl,Wt, ...
                       wp,Pd,Pdu,Pdl,Wp, ...
                       maxiter,ftol,ctol,verbose)
% [A1s20,A1s00,A1s02,A1s22,A1s20,A2s00,A2s02,A2s22, ...
%  slb_iter,opt_iter,func_iter,feasible] = ...
%   schurNSPAlattice_slb(pfx, ...
%                        A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
%                        A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
%                        difference, ...
%                        sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
%                        wa,Asqd,Asqdu,Asqdl,Wa, ...
%                        wt,Td,Tdu,Tdl,Wt, ...
%                        wp,Pd,Pdu,Pdl,Wp, ...
%                        maxiter,ftol,ctol,verbose)
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
%         [A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
%          socp_iter,func_iter,feasible]= ...
%            pfx(vS, ...
%                A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
%                A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
%                difference, ...
%                sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
%                wa,Asqd,Asqdu,Asqdl,Wa, ...
%                wt,Td,Tdu,Tdl,Wt, ...
%                wp,Pd,Pdu,Pdl,Wp, ...
%                maxiter,ftol,ctol,verbose);
%   A1s20_0,A1s00_0,A1s02_0,A1s22_0 - initial A1 lattice coefficients
%   A2s20_0,A2s00_0,A2s02_0,A2s22_0 - initial A2 lattice coefficients
%   difference - filter uses the difference of the all-pass outputs
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
%   wp - angular frequencies of phase response in [0,pi]. 
%   Pd - desired passband phase response
%   Pdu,Pdl - upper/lower mask for the desired phase response
%   Wp - phase response weight at each frequency
%   maxiter - maximum number of SQP iterations
%   ftol - tolerance on coefficient update
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22 - filter design 
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

% Copyright (C) 2023-2025 Robert G. Jenssen
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
if (nargin ~= 34) || (nargout ~=12)
  print_usage(["[A1s20,A1s00,A1s02,A1s22,A1s20,A2s00,A2s02,A2s22, ...\n", ...
 "lb_iter,opt_iter,func_iter,feasible] = ...\n", ...
 " schurNSPAlattice_slb(pfx, ...\n", ...
 "                      A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...\n", ...
 "                      A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...\n", ...
 "                      difference, ...\n", ...
 "                      sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax,...\n", ...
 "                      wa,Asqd,Asqdu,Asqdl,Wa, ...\n", ...
 "                      wt,Td,Tdu,Tdl,Wt, ...\n", ...
 "                      wp,Pd,Pdu,Pdl,Wp, ...\n", ...
 "                      maxiter,ftol,ctol,verbose)"])
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
A1s20=A1s20_0(:);A1s00=A1s00_0(:);A1s02=A1s02_0(:);A1s22=A1s22_0(:);
A2s20=A2s20_0(:);A2s00=A2s00_0(:);A2s02=A2s02_0(:);A2s22=A2s22_0(:);
sxx_0=[A1s20;A1s00;A1s02;A1s22;A2s20;A2s00;A2s02;A2s22];
if length(sxx_0) ~= (4*(length(A1s20)+length(A2s20)))
  error("Incorrect length sxx_0");
endif
sxx_u=sxx_u(:);sxx_l=sxx_l(:);
% Check if the initial filter meets the constraints
vR=schurNSPAlattice_slb_set_empty_constraints();
Asqk=schurNSPAlatticeAsq ...
  (wa,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference);
Tk=schurNSPAlatticeT ...
  (wt,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference);
Pk=schurNSPAlatticeP ...
  (wp,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference);
vS=schurNSPAlattice_slb_update_constraints ...
     (Asqk,Asqdu,Asqdl,Wa,Tk,Tdu,Tdl,Wt,Pk,Pdu,Pdl,Wp,ctol);
schurNSPAlattice_slb_show_constraints(vS,wa,Asqk,wt,Tk,wp,Pk);
if schurNSPAlattice_slb_constraints_are_empty(vS) ...
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
    [A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
     tmp_opt_iter,tmp_func_iter,feasible] = ...
       feval(pfx,vS,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
             difference,sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
             wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
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
  Asqk=schurNSPAlatticeAsq ... 
         (wa,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference);
  Tk=schurNSPAlatticeT ...
       (wt,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference);
  Pk=schurNSPAlatticeP ...
       (wp,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference);
  [vR,vS,exchanged] = schurNSPAlattice_slb_exchange_constraints ...
                        (vS,vR,Asqk,Asqdu,Asqdl,Tk,Tdu,Tdl,Pk,Pdu,Pdl,ctol);
  if exchanged
    printf("Step 4: R constraints violated after ");
    printf("%d PCLS iterations.\n",slb_iter)
    printf("R constraints:\n");
    schurNSPAlattice_slb_show_constraints(vR,wa,Asqk,wt,Tk,wp,Pk);
    printf("S constraints:\n");
    schurNSPAlattice_slb_show_constraints(vS,wa,Asqk,wt,Tk,wp,Pk);
    printf("Going to Step 2!\n");
    continue;
  else
    printf("Step 4: no R constraints violated after ")
    printf("%d PCLS iterations.\n",slb_iter)
    printf("S constraints:\n");
    schurNSPAlattice_slb_show_constraints(vS,wa,Asqk,wt,Tk,wp,Pk);
    printf("Going to Step 5!\n");
  endif
  
  %
  % Step 5: Multiple exchange of the constraint sets
  %
  vR=vS;
  vS=schurNSPAlattice_slb_update_constraints ...
       (Asqk,Asqdu,Asqdl,Wa,Tk,Tdu,Tdl,Wt,Pk,Pdu,Pdl,Wp,ctol);
  printf("Step 5: vS frequency constraints updated to:\n");
  for [v,m]=vS
    printf("vS.%s=[ ",m);printf("%d ",v);printf("]\n");
  endfor  
  printf("S constraints:\n");
  schurNSPAlattice_slb_show_constraints(vS,wa,Asqk,wt,Tk,wp,Pk);

  %
  % Step 6: Check for convergence
  %
  if schurNSPAlattice_slb_constraints_are_empty(vS)
    printf("Step 6: Solution satisfying constraints found ");
    printf("after %d PCLS iterations\nDone!\n",slb_iter);
    break;
  else
    printf("Step 6: Solution does not satisfy S constraints ");
    printf("after %d PCLS iterations\n",slb_iter)
    printf("S constraints:\n");
    schurNSPAlattice_slb_show_constraints(vS,wa,Asqk,wt,Tk,wp,Pk);
    printf("Going to Step 2!\n");
    continue;
  endif

% End of PCLS constraint loop
endwhile

endfunction
