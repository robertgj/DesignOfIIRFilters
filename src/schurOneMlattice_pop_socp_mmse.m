function [k,c,pop_iter,func_iter,feasible]= ...
  schurOneMlattice_pop_socp_mmse(vS,k0,epsilon0,p0,c0, ...
                                 kc_u,kc_l,kc_active,kc_fixed, ...
                                 wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                                 wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose)
% [k,c,pop_iter,func_iter,feasible] =
%   schurOneMlattice_pop_socp_mmse(vS,k0,epsilon0,p0,c0, ...
%                                  kc_u,kc_l,kc_active,kc_fixed, ...
%                                  wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                                  wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose)
%
% sparsePOP optimisation of a one-multiplier Schur lattice filter with
% constraints on the amplitude, phase and group delay responses.
%
% The objective function minimised is:
%   (0.5*delta'*hessEsq*delta)+(gradEsq*delta)+Esq
% where hessEsq is approximated by its diagonal elements.
%
% Coefficient truncation is achieved by setting equality constraints on delta:
%  (delta-(xl-x))*(delta-(xu-x))=0
% where x is the current coefficient vector and xl and xu are the lower and
% upper coefficient truncation bounds on x. I found that sparsePOP only
% solves for the first equality constraint.
%
% The response inequalities are of the form:
%   (Asqdu-Asq) - gradAsq*delta >= 0
%   (Asq-Asqdl) + gradAsq*delta >= 0
% where Asq is the current squared magnitude response, Asqdl and Asqdu are
% the desired lower and upper bounds on Asq and gradAsq is the gradient of
% the squared magnitude response with the current coefficients. I found that
% adding these inequalities drastically increased the size of the SeDuMi
% problem so that SeDuMi failed with numerical or out-of-memory errors.
%
% It may be necessary to adjust param.eqTolerance and param.SDPsolverEpsilon
%
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu}
%   k0 - initial allpass filter multipliers
%   epsilon0,p0 - state scaling coefficients. These have no effect on the
%                 response but can improve numerical accuracy.
%   c0 - initial numerator tap coefficients
%   kc_u,kc_l - upper and lower bounds on the allpass filter coefficients
%   kc_active - indexes of elements of coefficients being optimised
%   kc_fixed - indexes of kc_active that are to be truncated by SparsePOP. 
%   wa - angular frequencies of the squared-magnitude response
%   Asqd - desired squared amplitude response
%   Asqdu,Asqdl - upper/lower mask for the desired squared amplitude response
%   Wa - squared amplitude response weight at each frequency
%   wt - angular frequencies of the delay response
%   Td - desired group delay response
%   Tdu,Tdl - upper/lower mask for the desired group delay response
%   Wt - group delay response weight at each frequency
%   wp - angular frequencies of the delay response
%   Pd - desired passband group delay response
%   Pdu,Pdl - upper/lower mask for the desired phase response
%   Wp - phase response weight at each frequency
%   maxiter - not used
%   tol - tolerance
%   verbose - 
%
% Outputs:
%   k,c - filter design
%   pop_iter - number of SOCP iterations
%   func_iter - number of function calls
%   feasible - design satisfies the constraints 

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

  if (nargin ~= 27) || (nargout ~= 5)
    print_usage("[k,c,pop_iter,func_iter,feasible]= ...\n\
  schurOneMlattice_pop_socp_mmse(vS,k0,epsilon0,p0,c0, ...\n\
                                 kc_u,kc_l,kc_active,kc_fixed, ...\n\
                                 wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...\n\
                                 wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose)");
  endif

  %
  % Sanity checks on frequency response vectors
  %
  wa=wa(:);wt=wt(:);wp=wp(:);
  Nwa=length(wa);
  Nwt=length(wt);
  Nwp=length(wp);
  if isempty(wa) && isempty(wt)
    error("wa and wt empty");
  endif
  if Nwa ~= length(Asqd)
    error("Expected length(wa)(%d) == length(Asqd)(%d)",Nwa,length(Asqd));
  endif  
  if ~isempty(Asqdu) && Nwa ~= length(Asqdu)
    error("Expected length(wa)(%d) == length(Asqdu)(%d)",Nwa,length(Asqdu));
  endif
  if ~isempty(Asqdl) && Nwa ~= length(Asqdl)
    error("Expected lenth(wa)(%d) == length(Asqdl)(%d)",Nwa,length(Asqdl));
  endif
  if Nwa ~= length(Wa)
    error("Expected length(wa)(%d) == length(Wa)(%d)",Nwa,length(Wa));
  endif
  if ~isempty(Td) && Nwt ~= length(Td)
    error("Expected length(wt)(%d) == length(Td)(%d)",Nwt,length(Td));
  endif
  if ~isempty(Tdu) && Nwt ~= length(Tdu)
    error("Expected length(wt)(%d) == length(Tdu)(%d)",Nwt,length(Tdu));
  endif
  if ~isempty(Tdl) && Nwt ~= length(Tdl)
    error("Expected length(wt)(%d) == length(Tdl)(%d)",Nwt,length(Tdl));
  endif
  if ~isempty(Wt) && Nwt ~= length(Wt)
    error("Expected length(wt)(%d) == length(Wt)(%d)",Nwt,length(Wt));
  endif
  if ~isempty(Pd) && Nwp ~= length(Pd)
    error("Expected length(wp)(%d) == length(Pd)(%d)",Nwp,length(Pd));
  endif
  if ~isempty(Pdu) && Nwp ~= length(Pdu)
    error("Expected length(wp)(%d) == length(Pdu)(%d)",Nwp,length(Pdu));
  endif
  if ~isempty(Pdl) && Nwp ~= length(Pdl)
    error("Expected length(wp)(%d) == length(Pdl)(%d)",Nwp,length(Pdl));
  endif
  if ~isempty(Wp) && Nwp ~= length(Wp)
    error("Expected length(wp)(%d) == length(Wp)(%d)",Nwp,length(Wp));
  endif
  if isempty(vS)
    vS=schurOneMlattice_slb_set_empty_constraints();
  elseif (numfields(vS) ~= 6) || ...
         (all(isfield(vS,{"al","au","tl","tu","pl","pu"}))==false)
    error("numfields(vS)=%d, expected 6 (al,au,tl,tu,pl and pu)",numfields(vS));
  endif
  Nresp=length(vS.al)+length(vS.au)+ ...
        length(vS.tl)+length(vS.tu)+ ...
        length(vS.pl)+length(vS.pu);

  %
  % Sanity checks on coefficient vectors
  %
  k0=k0(:);c0=c0(:);kc_u=kc_u(:);kc_l=kc_l(:);
  Nk=length(k0);
  Nc=length(c0);
  Nkc=Nk+Nc;
  if (Nkc==0)
    error("No active coefficients");
  endif
  if (Nk+1) ~= Nc
    error("Expected Nk(%d)+1 == Nc(%d)",Nk,Nc);
  endif
  if length(kc_u) ~= Nkc
    error("Expected length(kc_u)(%d) == Nkc(%d)",length(kc_u),Nkc);
  endif
  if length(kc_l) ~= Nkc
    error("Expected length(kc_l)(%d) == Nkc(%d)",length(kc_l),Nkc);
  endif
  if isempty(kc_active)
    warning("kc_active is empty!");
    k=k0;
    c=c0;
    pop_iter=0;
    func_iter=0;
    feasible=true;
    return;
  endif
  Nkc_active=length(kc_active);
  Nkc_fixed=length(kc_fixed);
  if any(kc_fixed<1) || any(kc_fixed>Nkc_active) || any(rem(kc_active,1))
    error("kc_fixed(%d)>%d is out of bounds!",kc_fixed,length(kc_active));
  endif

  %
  % Initialise
  %
  pop_iter=0;func_iter=0;feasible=false;
  % Coefficient vector being optimised
  k=k0(:);c=c0(:);kc=[k;c];xkc=kc(kc_active);
  % Initial squared response error
  [Esq0,gradEsq0,diagHessEsq0]= ...
    schurOneMlatticeEsq(k,epsilon0,p0,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  func_iter=func_iter+1;
  if verbose
    printf("Initial Esq=%g\n",Esq0);
    printf("Initial gradEsq=[");printf("%g ",gradEsq0);printf("]\n");
  endif

  %
  % Set up the sparsePOP problem.
  %

  % SparsePOP parameters
  param.relaxOrder=1;
  param.SDPsolver='sedumi';
  param.eqTolerance=1e-6;
  param.SDPsolverEpsilon=1e-6;
  param.mex=0;
  param.symbolicMath=0;
  
  %
  % Objective function (must be positive!)
  %
  % Minimise the estimated error (ignoring the constant term):
  %  0.5*deltaxl'*diag(diagHessEsql*deltaxl)+gradEsql*deltaxl
  % with l=1..Nkc_active
  objPoly.typeCone = 1;
  objPoly.dimVar   = Nkc_active;
  objPoly.degree   = 2;
  objPoly.noTerms  = Nkc_active+Nkc_active;
  % Order of supports: delta_l^2, delta_l
  objPoly.supports = [2*speye(Nkc_active); speye(Nkc_active)];
  % objPoly coefficients
  gradEsq_active=gradEsq0(kc_active);
  diagHessEsq_active=diagHessEsq0(kc_active);
  objPoly.coef=[0.5*diagHessEsq_active(:); gradEsq_active(:)];
  
  %
  % Constraints
  %
  
  % Allocate cell array for constraints
  ineqPolySys=cell(Nresp+Nkc_fixed,1);

  % Initialise linear response constraints
  for l=1:Nresp,
    ineqPolySys{l}.typeCone = 1;
    ineqPolySys{l}.dimVar   = Nkc_active;
    ineqPolySys{l}.degree   = 1;
    ineqPolySys{l}.noTerms  = Nkc_active+1;
    ineqPolySys{l}.coef     = zeros(1+Nkc_active,1);
    ineqPolySys{l}.supports = [sparse(1,Nkc_active);speye(Nkc_active)];
  endfor

  % Squared amplitude linear constraints
  l_ineq=0;
  if ~isempty(vS.au)
    [Asq_au,gradAsq_au]=schurOneMlatticeAsq(wa(vS.au),k,epsilon0,p0,c);
    func_iter = func_iter+1;
    for l=1:length(vS.au)
      l_ineq=l_ineq+1; 
      % Asqdu - (Asq+(gradAsq*delta)) >= 0
      ineqPolySys{l_ineq}.coef=[Asqdu(l)-Asq_au(l);-gradAsq_au(l,kc_active)'];
    endfor
  endif
  if ~isempty(vS.al)
    [Asq_al,gradAsq_al]=schurOneMlatticeAsq(wa(vS.al),k,epsilon0,p0,c);
    func_iter = func_iter+1;
    for l=1:length(vS.al)
      l_ineq=l_ineq+1;
      % (Asq+(gradAsq*delta)) - Asqdl >= 0
      ineqPolySys{l_ineq}.coef=[Asq_al(l)-Asqdl(l);gradAsq_al(l,kc_active)'];
    endfor
  endif

  % Group delay linear constraints
  if ~isempty(vS.tu)
    [T_tu,gradT_tu]=schurOneMlatticeT(wt(vS.tu),k,epsilon0,p0,c);
    func_iter = func_iter+1;
    for l=1:length(vS.tu)
      l_ineq=l_ineq+1;
      % Tdu - (T+(gradT*delta)) >= 0
      ineqPolySys{l_ineq}.coef=[Tdu(l)-T_tu(l);-gradT_tu(l,kc_active)'];
    endfor
  endif
  if ~isempty(vS.tl)
    [T_tl,gradT_tl]=schurOneMlatticeT(wt(vS.tl),k,epsilon0,p0,c);
    func_iter = func_iter+1;
    for l=1:length(vS.tl)
      l_ineq=l_ineq+1;
      % (T+(gradT*delta)) - Tdl >= 0
      ineqPolySys{l_ineq}.coef=[T_tl(l)-Tdl(l);gradT_tl(l,kc_active)'];
    endfor
  endif

  % Phase linear constraints
  if ~isempty(vS.pu)
    [P_pu,gradP_pu]=schurOneMlatticeP(wp(vS.pu),k,epsilon0,p0,c);
    func_iter = func_iter+1;
    for l=1:length(vS.pu)
      l_ineq=l_ineq+1;
      % Pdu - (P+(gradP*delta)) >= 0
      ineqPolySys{l_ineq}.coef=[Pdu(l)-P_pu(l);-gradP_pu(l,kc_active)'];
    endfor
  endif
  if ~isempty(vS.pl)
    [P_pl,gradP_pl]=schurOneMlatticeP(wp(vS.pl),k,epsilon0,p0,c);
    func_iter = func_iter+1;
    for l=1:length(vS.pl)
      l_ineq=l_ineq+1;
      % (P+(gradP*delta)) - Pdl >= 0
      ineqPolySys{l_ineq}.coef=[P_pl(l)-Pdl(l);gradP_pl(l,kc_active)'];
    endfor
  endif

  % Initialise truncation equality constraints
  for l=1:Nkc_fixed
    ineqPolySys{Nresp+l}.typeCone = -1;
    ineqPolySys{Nresp+l}.dimVar   = Nkc_active;
    ineqPolySys{Nresp+l}.degree   = 2;
    ineqPolySys{Nresp+l}.noTerms  = 3;
    ineqPolySys{Nresp+l}.supports = sparse(3,Nkc_active);
    ineqPolySys{Nresp+l}.supports(1,kc_fixed(l))=2;
    ineqPolySys{Nresp+l}.supports(2,kc_fixed(l))=1;
    mx=kc_fixed(l);
    ma=kc_active(mx);
    ineqPolySys{Nresp+l}.coef = [1; ...
                                 (2*xkc(mx))-kc_u(ma)-kc_l(ma); ...
                                 (xkc(mx)-kc_u(ma))*(xkc(mx)-kc_l(ma))];
  endfor

  %
  % Upper and lower bounds on the coefficient difference vector, deltakc:
  %  kc_u-(kc+deltakc) >= 0
  ubd=(kc_u(kc_active)-xkc)';
  %  (kc+deltakc)-kc_l >= 0
  lbd=(kc_l(kc_active)-xkc)';
  
  %
  % Call sparsePOP
  %
  try
    [param,SDPobjValue,POP,cpuTime,SDPsolverInfo,SDPinfo] = ...
    sparsePOP(objPoly,ineqPolySys,lbd,ubd,param);
    if verbose
      printf("SeDuMi SDPsolverInfo.iter=%d,SDPsolverInfo.feasratio=%6.4g\n",
             SDPsolverInfo.iter,SDPsolverInfo.feasratio);
    endif
    if SDPsolverInfo.pinf
      error("SeDuMi primary problem infeasible");
    endif
    if SDPsolverInfo.dinf
      error("SeDuMi dual problem infeasible");
    endif 
    if SDPsolverInfo.numerr == 1
      error("SeDuMi premature termination"); 
    elseif SDPsolverInfo.numerr == 2 
      error("SeDuMi numerical failure");
    elseif SDPsolverInfo.numerr
      error("SeDuMi SDPsolverInfo.numerr=%d",SDPsolverInfo.numerr);
    endif
    feasible=true;
  catch
    xkc=[];
    feasible=false;
    err=lasterror();
    for e=1:length(err.stack)
      fprintf(stderr,"Called %s at line %d\n", ...
              err.stack(e).name,err.stack(e).line);
    endfor
    error("%s\n", err.message);
  end_try_catch
  
  % Extract results
  delta=POP.xVect;
  delta=delta(:);
  
  % Update kc
  xkc=xkc+delta;
  kc(kc_active)=xkc;
  k=kc(1:Nk);
  c=kc((Nk+1):end);
  pop_iter=SDPsolverInfo.iter;
  if verbose
    printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
    printf("norm(delta)=%g\n",norm(delta));
    printf("k=[ ");printf("%g ",k');printf(" ]';\n"); 
    printf("c=[ ");printf("%g ",c');printf(" ]';\n");    
    printf("xkc(%d)= ",kc_fixed);printf("%g ",xkc(kc_fixed));printf("\n");
    printf("norm(delta)/norm(xkc)=%g\n",norm(delta)/norm(xkc));
    [Esq,gradEsq]= ...
      schurOneMlatticeEsq(k,epsilon0,p0,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    func_iter=func_iter+1;
    printf("Esq=%g\n",Esq);
    printf("gradEsq=[");printf("%g ",gradEsq);printf("]\n");
    printf("func_iter=%d, pop_iter=%d\n",func_iter,pop_iter);
  endif

endfunction
