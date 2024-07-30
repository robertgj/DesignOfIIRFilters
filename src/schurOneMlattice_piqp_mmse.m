function [k,c,piqp_iter,func_iter,feasible]= ...
schurOneMlattice_piqp_mmse(vS,k0,epsilon0,p0,c0, ...
                           kc_u,kc_l,kc_active,dmax, ...
                           wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                           wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
                           maxiter,ftol,ctol,verbose)
% [k,c,piqp_iter,func_iter,feasible] =
% schurOneMlattice_piqp_mmse(vS,k0,epsilon0,p0,c0, ...
%                            kc_u,kc_l,kc_active,dmax, ...
%                            wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                            wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
%                            maxiter,ftol,ctol,verbose)
%
% PIQP MMSE optimisation of a one-multiplier Schur lattice filter with
% constraints on the amplitude, phase and low pass group delay responses. 
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu}
%   k0 - initial allpass filter multipliers
%   epsilon0,p0 - state scaling coefficients. These have no effect on the
%                 response but can improve numerical accuracy.
%   c0 - initial numerator tap coefficients
%   kc_u,kc_l - upper and lower bounds on the allpass filter coefficients
%   kc_active - indexes of elements of coefficients being optimised
%   dmax - maximum coefficient step
%   wa - angular frequencies of the squared-magnitude response
%   Asqd - desired squared amplitude response
%   Asqdu,Asqdl - upper/lower mask for the desired squared amplitude response
%   Wa - squared amplitude response weight at each frequency
%   wt - angular frequencies of the delay response
%   Td - desired group delay response
%   Tdu,Tdl - upper/lower mask for the desired group delay response
%   Wt - group delay response weight at each frequency
%   wp - angular frequencies of the phase response
%   Pd - desired passband phase response
%   Pdu,Pdl - upper/lower mask for the desired phase response
%   Wp - phase response weight at each frequency
%   wd - angular frequencies of the dAsqdw response
%   Dd - desired passband dAsqdw response
%   Ddu,Ddl - upper/lower mask for the desired dAsqdw response
%   Wd - dAsqdw response weight at each frequency
%   maxiter - maximum number of PIQP iterations
%   ftol - tolerance on coefficient update
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   k,c - filter design
%   piqp_iter - number of PIQP iterations
%   func_iter - number of function calls
%   feasible - design satisfies the constraints 

% Copyright (C) 2024 Robert G. Jenssen
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

if (nargin ~= 33) || (nargout ~= 5)
  print_usage("[k,c,piqp_iter,func_iter,feasible]= ...\n\
    schurOneMlattice_piqp_mmse(vS,k0,epsilon0,p0,c0, ...\n\
                               kc_u,kc_l,kc_active,dmax, ...\n\
                               wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...\n\
                               wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd. ...\n\
                               maxiter,ftol,ctol,verbose)");
endif

%
% Sanity checks on frequency response vectors
%
wa=wa(:);wt=wt(:);wp=wp(:);wd=wd(:);
Nwa=length(wa);
Nwt=length(wt);
Nwp=length(wp);
Nwd=length(wd);
if isempty(wa) && isempty(wt) && isempty(wp) && isempty(wd)
  error("wa, wt, wp and wd empty");
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
if ~isempty(Dd) && Nwd ~= length(Dd)
  error("Expected length(wd)(%d) == length(Dd)(%d)",Nwd,length(Dd));
endif
if ~isempty(Ddu) && Nwd ~= length(Ddu)
  error("Expected length(wd)(%d) == length(Ddu)(%d)",Nwd,length(Ddu));
endif
if ~isempty(Ddl) && Nwd ~= length(Ddl)
  error("Expected length(wd)(%d) == length(Ddl)(%d)",Nwd,length(Ddl));
endif
if ~isempty(Wd) && Nwd ~= length(Wd)
  error("Expected length(wd)(%d) == length(Wd)(%d)",Nwd,length(Wd));
endif
if isempty(vS)
  vS=schurOneMlattice_slb_set_empty_constraints();
elseif (numfields(vS) ~= 8) || ...
       (all(isfield(vS,{"al","au","tl","tu","pl","pu","dl","du"}))==false)
  error("numfields(vS)=%d, expected 8 (al,au,tl,tu,pl,pu,dl and du)", ...
        numfields(vS));
endif

%
% Sanity checks on coefficient vectors
%
k0=k0(:);c0=c0(:);kc0=[k0;c0];kc_u=kc_u(:);kc_l=kc_l(:);
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
Nkc_active=length(kc_active);
if isempty(kc_active)
  k=k0;
  c=c0;
  sqp_iter=0;
  func_iter=0;
  feasible=true;
  return;
endif

%
% Initialise loop
%
piqp_iter=0;func_iter=0;loop_iter=0;feasible=false;
% Coefficient vector being optimised
k=k0(:);c=c0(:);kc=[k;c];xkc=kc(kc_active);
% Initial squared response error
[Esq,gradEsq,~,hessEsq] = ...
  schurOneMlatticeEsq(k,epsilon0,p0,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
func_iter=func_iter+1;
if verbose
  printf("Initial Esq=%g\n",Esq);
  printf("Initial gradEsq=[");printf("%g ",gradEsq);printf("]\n");
endif
% PIQP
P0=zeros(size(hessEsq(kc_active,kc_active)));
c0=zeros(size(gradEsq(kc_active)));
rowsG=length(vS.au)+length(vS.al) + ...
      length(vS.tu)+length(vS.tl) + ...
      length(vS.pu)+length(vS.pl) + ...
      length(vS.du)+length(vS.dl);
G0=zeros(rowsG,length(xkc));
h0=zeros(rowsG,1);
A0=[];
b0=[];
xkc_lb=kc_l(kc_active);
xkc_ub=kc_u(kc_active);
solver=piqp('dense');
solver.update_settings('max_iter', maxiter);
solver.update_settings('verbose', false, 'compute_timings', verbose);
solver.setup(P0, c0, A0, b0, G0, h0, xkc_lb, xkc_ub);

%
% PIQP loop
%
while 1

  loop_iter=loop_iter+1;
  if loop_iter > maxiter
    error("maxiter exceeded");
  endif

  %
  % Set up the PIQP problem. The decision variable is delta=x-xk
  %
  
  % Minimise (x-xk)'*hessEk*(x-xk)/2 + gradEk*(x-xk)
  Pk=hessEsq(kc_active,kc_active);
  ck=gradEsq(kc_active);
  
  % Subject to:
  Gk=[]; hk=[];
  % Pass-band amplitude upper bound, gradA*(x-xk) <= ctol+Adu-A
  if ~isempty(vS.au)
    [Asq_au,gradAsq_au]=schurOneMlatticeAsq(wa(vS.au),k,epsilon0,p0,c);
    func_iter = func_iter+1;
    Gk=[Gk; gradAsq_au(:,kc_active)];
    hk=[hk; ctol+Asqdu(vS.au)-Asq_au];
  endif
  % Pass-band amplitude lower bound, ctol+A-Adl >= -gradA*(x-xk)
  if ~isempty(vS.al)
    [Asq_al,gradAsq_al]=schurOneMlatticeAsq(wa(vS.al),k,epsilon0,p0,c);
    func_iter = func_iter+1;
    Gk=[Gk; -gradAsq_al(:,kc_active)];
    hk=[hk; ctol+Asq_al-Asqdl(vS.al)];
  endif
  % Group delay upper bound, gradT*(x-xk) <= ctol+Tdu-T
  if ~isempty(vS.tu)
    [T_tu,gradT_tu]=schurOneMlatticeT(wt(vS.tu),k,epsilon0,p0,c);
    func_iter = func_iter+1;
    Gk=[Gk; gradT_tu(:,kc_active)];
    hk=[hk; ctol+Tdu(vS.tu)-T_tu];
  endif
  % Group delay lower bound, ctol+T-Tdl >= -gradT*(x-xk)
  if ~isempty(vS.tl)
    [T_tl,gradT_tl]=schurOneMlatticeT(wt(vS.tl),k,epsilon0,p0,c);
    func_iter = func_iter+1;
    Gk=[Gk; -gradT_tl(:,kc_active)];
    hk=[hk; ctol+T_tl-Tdl(vS.tl)];
  endif
  % Set phase linear constraints (avoiding phase unwrapping differences)
  if ~isempty(vS.pu) || ~isempty(vS.pl)
    [P,gradP]=schurOneMlatticeP(wp,k,epsilon0,p0,c);
    func_iter = func_iter+1;
  endif
  % Phase upper bound, gradP*(x-xk) <= ctol+Pdu-P
  if ~isempty(vS.pu)
    Gk=[Gk; gradP(vS.pu,kc_active)];
    hk=[hk; ctol+Pdu(vS.pu)-P(vS.pu)];
  endif
  % Phase lower bound, ctol+P-Pdl >= -gradP*(x-xk)
  if ~isempty(vS.pl)
    Gk=[Gk; -gradP(vS.pl,kc_active)];
    hk=[hk; ctol+P(vS.pl)-Pdl(vS.pl)];
  endif
  % dAsqdw upper bound, graddAsqdw*(x-xk) <= ctol+dAsqdwdu-dAsqdw
  if ~isempty(vS.du)
    [dAsqdw_du,graddAsqdw_du]=schurOneMlatticedAsqdw(wd(vS.du),k,epsilon0,p0,c);
    func_iter = func_iter+1;
    Gk=[Gk; graddAsqdw_du(:,kc_active)];
    hk=[hk; ctol+dAsqdwdu(vS.du)-dAsqdw_du];
  endif
  % dAsqdw lower bound, ctol+dAsqdw-dAsqdwdl >= -graddAsqdw*(x-xk)
  if ~isempty(vS.dl)
    [dAsqdw_dl,graddAsqdw_dl]=schurOneMlatticedAsqdw(wd(vS.dl),k,epsilon0,p0,c);
    func_iter = func_iter+1;
    Gk=[Gk; -graddAsqdw_dl(:,kc_active)];
    hk=[hk; ctol+dAsqdw_dl-dAsqdwdl(vS.dl)];
  endif

  % Decision variable global constraints
  delta_lb=max(kc_l(kc_active)-xkc,-dmax);
  delta_ub=min(kc_u(kc_active)-xkc, dmax);

  % Update solver
  solver.update('P',Pk,'c',ck,'G',Gk,'h',hk,'x_lb',delta_lb,'x_ub',delta_ub);

  %
  % Call PIQP
  %
  try
    result=solver.solve();
    piqp_iter=piqp_iter+1;
  catch
    xk=[];
    Ek=inf;
    feasible=false;
    err=lasterror();
    for e=1:length(err.stack)
      fprintf(stderr,"Called %s at line %d\n", ...
              err.stack(e).name,err.stack(e).line);
    endfor
    error("%s\n", err.message);
    return;
  end_try_catch
  switch (result.info.status_val)
    case 1
      if verbose
        printf("Solver solved problem up to given tolerance.\n");
      endif
    case -1
      result.info
      result.x
      error("Iteration limit was reached!");
    case -2
      error("The problem is primal infeasible!");
    case -3
      error("The problem is dual infeasible!");
    case -8
      error("Numerical error occurred during solving!");
    case -9
      error("The problem is unsolved (solve was never called)!");
    case -10
      error("Invalid settings were provided to the solver!");
    otherwise
      error("Unknown PIQP error code!");
  endswitch

  %
  % Extract delta
  %
  delta=result.x;
  xkc=xkc+delta;
  kc=kc0;
  kc(kc_active)=xkc;
  k=kc(1:Nk);
  c=kc((Nk+1):end);
  
  [Esq,gradEsq,~,hessEsq] = ...
    schurOneMlatticeEsq(k,epsilon0,p0,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  func_iter=func_iter+1;
  if verbose
    printf("PIQP status=%s, run_time=%g, primal_obj=%g\n",
           result.info.status, result.info.run_time, result.info.primal_obj);
    printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
    printf("norm(delta)=%g\n",norm(delta));
    printf("k=[ ");printf("%g ",k');printf(" ]';\n"); 
    printf("c=[ ");printf("%g ",c');printf(" ]';\n"); 
    printf("Esq=%g\n",Esq);
    printf("gradEsq=[ ");printf("%g ",gradEsq');printf(" ]';\n");
    printf("norm(delta)/norm(xkc)=%g\n",norm(delta)/norm(xkc));
    printf("func_iter=%d, piqp_iter=%d\n",func_iter,piqp_iter);
  endif
  if norm(delta)/norm(xkc) < ftol
    printf("norm(delta)/norm(xkc) < ftol\n");
    feasible=true;
    break;
  endif

endwhile
  
endfunction
