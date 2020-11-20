function [x,E,slb_iter,opt_iter,func_iter,feasible] = iir_slb(pfx, ...
  x0,xu,xl,dmax,U,V,M,Q,R,wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
  wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,maxiter,tol,ctol,verbose)
% [x,E,slb_iter,opt_iter,func_iter,feasible] = ...
%   iir_slb(pfx,x0,xu,xl,dmax,U,V,M,Q,R,wa,Ad,Adu,Adl,Wa, ...
%           ws,Sd,Sdu,Sdl,Ws,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
%           maxiter,tol,ctol,verbose)
%
% PCLS optimisation with constraints on the amplitude, phase and
% group delay responses. See:
%
% "Constrained Least Square Design of FIR Filters without Specified 
% Transition Bands", I. W. Selesnick, M. Lang and C. S. Burrus, IEEE
% Trans. Signal Processing, Vol.44, No.8, August 1996, pp.1879--1892
%
%
% Inputs:
%   pfx - pointer to function that calls the inner optimisation loop:   
%         [nextx,E,opt_iter,func_iter,feasible] = pfx(vS,x,xu,xl,dmax, ...
%         U,V,M,Q,R,wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,...
%         wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose);
%   x0 - initial coefficient vector in the form:
%         [ k;                          ...
%           zR(1:U);     pR(1:V);       ...
%           abs(z(1:Mon2)); angle(z(1:Mon2)); ...
%           abs(p(1:Qon2)); angle(p(1:Qon2)) ];
%         where k is the gain coefficient, zR and pR represent real
%         zeros  and poles and z and p represent conjugate zero and
%         pole pairs.
%   xu,xl - upper and lower bounds on coefficients
%   dmax - maximum coefficient step-size
%   U - number of real zeros
%   V - number of real poles
%   M - number of conjugate zero pairs
%   Q - number of conjugate pole pairs
%   R - decimation factor, pole pairs are for z^R
%   wa - angular frequencies of desired amplitude response in [0,pi].
%        Assumed to be equally spaced
%   Ad - desired amplitude response
%   Adu,Adl - upper/lower mask for the desired amplitude response
%   Wa - amplitude weight at each frequency
%   ws - angular frequencies of desired stop-band amplitude response 
%        in [0,pi]. Assumed to be equally spaced
%   Sd - desired stop-band amplitude response
%   Sdu,Sdl - upper/lower mask for the desired stop-band amplitude response
%   Ws - stop-band amplitude weight at each frequency
%   wt - angular frequencies of the desired group delay response
%   Td - desired group delay response vector
%   Tdu,Tdl - upper/lower mask for the desired group delay response
%   Wt - group delay weight at each frequency
%   wp - angular frequencies of the desired phase response
%   Pd - desired phase response vector
%   Pdu,Pdl - upper/lower mask for the desired phase response
%   Wp - phase response weight at each frequency
%   maxiter - maximum number of optimisation loop iterations
%   tol - tolerance on coefficient update
%   ctol - tolerance on constraints
%   verbose - 
%
% Note that Ad, Adu, Adl and Wa are the amplitudes or weights at
% the corresponding angular frequencies in wa. Similarly for
% Td, Tdu, Tdl, Wt and wt.
%   
% Outputs:
%   x - filter design 
%   E - error value at x
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

if (nargin ~= 34) || (nargout ~= 6)
  print_usage("[x,E,slb_iter,opt_iter,func_iter,feasible] = ...\n\
         iir_slb(pfx,x0,xu,xl,dmax,U,V,M,Q,R,wa,Ad,Adu,Adl,Wa, ...\n\
         ws,Sd,Sdu,Sdl,Ws,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...\n\
         maxiter,tol,ctol,verbose)");
endif

%
% Sanity checks
%
if ~is_function_handle(pfx)
  error("Expected pfx to be a function handle!");
endif
if (length(x0) ~= length(xu)) 
  error("length(x0)(%d) ~= length(xu)(%d)",length(x0),length(xu));
endif
if (length(x0) ~= length(xl)) 
  error("length(x0)(%d) ~= length(xl)(%d)",length(x0),length(xl));

endif

%
% SLB constraints
%

%
% Step 1: Initialise constraint sets of the amplitude and group
% delay responses over frequency. vS.xl and vS.xu are indexes 
% into the coefficient vector. vS.al etc are angular frequencies.
%
vR=iir_slb_set_empty_constraints();
vS=iir_slb_update_constraints(x0,U,V,M,Q,R,wa,Adu,Adl,Wa, ...
                              ws,Sdu,Sdl,Ws,wt,Tdu,Tdl,Wt, ...
                              wp,Pdu,Pdl,Wp,ctol);

% Initialise SLB loop parameters
info=0;slb_iter=0;opt_iter=0;func_iter=0;
feasible=false;E=bestE=inf;bestx=x0(:);x=x0(:);

% PCLS loop
while 1
  
  % Check loop iterations
  slb_iter = slb_iter+1;
  if slb_iter>maxiter
    x=bestx;
    E=bestE;
    warning("PCLS loop iteration limit exceeded!");
    break;
  endif

  %
  % Step 2 : Solve the minimisation problem with the active constraints  
  % Step 3 : Test for optimality with Karush-Kuhn-Tucker conditions
  %
  try
    [nextx,E,tmp_opt_iter,tmp_func_iter,feasible] = ...
    feval(pfx,vS,x,xu,xl,dmax,U,V,M,Q,R,wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
          wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose);
    opt_iter = opt_iter + tmp_opt_iter;
    func_iter = func_iter + tmp_func_iter;
  catch
    feasible=0;
    err=lasterror();
    fprintf(stderr,"Error: %s\n",err.message);
    for e=1:length(err.stack)
      fprintf(stderr,"Called from %s at line %d\n", ...
              err.stack(e).name, err.stack(e).line);
    endfor
    error("feval(pfx,...) failure!");
  end_try_catch
  if feasible
    if x==nextx
      printf("E=%f\n",E);
      printf("x=[ ");printf("%f ",x);printf("]';\n");
      warning("No change to solution after %d PCLS iterations\n",slb_iter);
      for [v,m]=vR
        printf("vR.%s=[ ",m);printf("%d ",v);printf("]\n");
      endfor
      for [v,m]=vS
        printf("vS.%s=[ ",m);printf("%d ",v);printf("]\n");
      endfor
      if iir_slb_constraints_are_empty(vR)
        break;
      endif
    endif
    x=nextx;
    printf("Feasible solution after %d optimisation iterations\n",tmp_opt_iter);
    printf("E=%f\n",E);
    printf("x=[ ");printf("%f ",x);printf("]';\n");
  else
    warning("Optimisation solution not feasible!");
    break;
  endif

  % Track best result
  if E<bestE
    bestx=x;
    bestE=E;
  endif

  %
  % Step 4: Check for violations over vR
  % 
  [vR,vS,exchanged] = ...
    iir_slb_exchange_constraints(vS,vR,x,U,V,M,Q,R,wa,Adu,Adl, ...
                                 ws,Sdu,Sdl,wt,Tdu,Tdl,wp,Pdu,Pdl,ctol);
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
  vS=iir_slb_update_constraints(x,U,V,M,Q,R, ...
                                wa,Adu,Adl,Wa,ws,Sdu,Sdl,Ws, ...
                                wt,Tdu,Tdl,Wt,wp,Pdu,Pdl,Wp,ctol);
  printf("Step 5: S frequency constraints updated to:\n");
  for [v,m]=vS
    printf("vS.%s=[ ",m);printf("%d ",v);printf("]\n");
  endfor

  %
  % Step 6: Check for convergence
  %
  if iir_slb_constraints_are_empty(vS)
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
