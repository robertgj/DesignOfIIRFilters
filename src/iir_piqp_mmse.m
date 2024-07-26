function [xk,Ek,piqp_iter,func_iter,feasible]= ...
iir_piqp_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...
              wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
              wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
              maxiter,ftol,ctol,verbose)
% [xk,E,piqp_iter,func_iter,feasible] =
%   iir_piqp_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...
%                 wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
%                 wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
%                 maxiter,ftol,ctol,verbose)
%
% PIQP MMSE optimisation using a linear approximation to the error with
% linear constraints on the amplitude, phase and group delay responses. The
% function signature is the same as that of iir_sqp_mmse.m and this function
% is compatible with iir_slb.m. The PIQP solution does not require a
% linesearch function and the dmax argument is unused.
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,sl,su,tl,tu,pl,pu}
%   x0 - initial coefficient vector in the form:
%         [ k;                          ...
%           zR(1:U);     pR(1:V);       ...
%           abs(z(1:Mon2)); angle(z(1:Mon2)); ...
%           abs(p(1:Qon2)); angle(p(1:Qon2)) ];
%         where k is the gain coefficient, zR and pR represent real
%         zeros  and poles and z and p represent conjugate zero and
%         pole pairs.
%   xu,xl - upper and lower constraints on the coefficients
%   dmax - constraint on coefficient step-size (NOT USED)
%   U - number of real zeros
%   V - number of real poles
%   M - number of conjugate zero pairs
%   Q - number of conjugate pole pairs
%   R - decimation factor, pole pairs are for z^R
%   wa - angular frequencies of desired pass-band amplitude response
%        in [0,pi]. 
%   Ad - desired pass-band amplitude response
%   Adu,Adl - upper/lower mask for the desired pass-band amplitude response
%   Wa - pass-band amplitude response weight at each frequency
%   ws - angular frequencies of desired stop-band amplitude response
%        in [0,pi]. 
%   Sd - desired stop-band amplitude response
%   Sdu,Sdl - upper/lower mask for the desired stop-band amplitude response
%   Ws - stop-band amplitude response weight at each frequency
%   wt - angular frequencies of desired group delay response in [0,pi].
%   Td - desired group delay response
%   Tdu,Tdl - upper/lower mask for the desired group delay response
%   Wt - group delay response weight at each frequency
%   wp - angular frequencies of desired phase response in [0,pi]. 
%   Pd - desired phase response
%   Pdu,Pdl - upper/lower mask for the desired phase response
%   Wp - phase response weight at each frequency
%   maxiter - maximum number of SQP iterations
%   ftol - tolerance on function value
%   ctol - tolerance on constraints
%   verbose - 
%
% Outputs:
%   xk - filter design 
%   Ek - error value at xk
%   piqp_iter - number of PIQP iterations
%   func_iter - number of function calls
%   feasible - x satisfies the constraints 

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

if (nargin ~= 34) || (nargout ~= 5)
  print_usage("[xk,Ek,piqp_iter,func_iter,feasible]= ...\n\
    iir_piqp_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...\n\
                  wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...\n\
                  wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...\n\
                  maxiter,ftol,ctol,verbose)");
endif

%
% Sanity checks
%
N=1+U+V+M+Q;
Nwa=length(wa);
Nws=length(ws);
Nwt=length(wt);
Nwp=length(wp);
if length(x0) ~= N
  error("Expected length(x0)(%d) == 1+U+V+M+Q(%d)",length(x0),N);
endif
if length(xu) ~= N
  error("Expected length(xu)(%d) == 1+U+V+M+Q(%d)",length(xu),N);
endif
if length(xl) ~= N
  error("Expected length(xl)(%d) == 1+U+V+M+Q(%d)",length(xl),N);
endif
if Nwa ~= length(Ad)
  error("Expected length(wa)(%d) == length(Ad)(%d)",Nwa,length(Ad));
endif  
if ~isempty(Adu) && Nwa ~= length(Adu)
  error("Expected length(wa)(%d) == length(Adu)(%d)",Nwa,length(Adu));
endif
if ~isempty(Adl) && Nwa ~= length(Adl)
  error("Expected lenth(wa)(%d) == length(Adl)(%d)",Nwa,length(Adl));
endif
if Nwa ~= length(Wa)
  error("Expected length(wa)(%d) == length(Wa)(%d)",Nwa,length(Wa));
endif
if any(Adu<Adl)
  error("Expected Adu>=Adl");
endif
if Nws ~= length(Sd)
  error("Expected length(ws)(%d) == length(Sd)(%d)",Nws,length(Sd));
endif  
if ~isempty(Sdu) && Nws ~= length(Sdu)
  error("Expected length(ws)(%d) == length(Sdu)(%d)",Nws,length(Sdu));
endif
if ~isempty(Sdl) && Nws ~= length(Sdl)
  error("Expected length(ws)(%d) == length(Sdl)(%d)",Nws,length(Sdl));
endif
if Nws ~= length(Ws)
  error("Expected length(ws)(%d) == length(Ws)(%d)",Nws,length(Ws));
endif
if any(Sdu<Sdl)
  error("Expected Sdu>=Sdl");
endif
if Nwt ~= length(Td)
  error("Expected length(wt)(%d) == length(Td)(%d)",Nwt,length(Td));
endif  
if ~isempty(Tdu) && Nwt ~= length(Tdu)
  error("Expected length(wt)(%d) == length(Tdu)(%d)",Nwt,length(Tdu));
endif
if ~isempty(Tdl) && Nwt ~= length(Tdl)
  error("Expected length(wt)(%d) == length(Tdl)(%d)",Nwt,length(Tdl));
endif
if Nwt ~= length(Wt)
  error("Expected length(wt)(%d) == length(Wt)(%d)",Nwt,length(Wt));
endif
if any(Tdu<Tdl)
  error("Expected Tdu>=Tdl");
endif
if Nwp ~= length(Pd)
  error("Expected length(wp)(%d) == length(Pd)(%d)",Nwp,length(Pd));
endif  
if ~isempty(Pdu) && Nwp ~= length(Pdu)
  error("Expected length(wp)(%d) == length(Pdu)(%d)",Nwp,length(Pdu));
endif
if ~isempty(Pdl) && Nwp ~= length(Pdl)
  error("Expected length(wp)(%d) == length(Pdl)(%d)",Nwp,length(Pdl));
endif
if Nwp ~= length(Wp)
  error("Expected length(wp)(%d) == length(Wp)(%d)",Nwp,length(Wp));
endif
if any(Pdu<Pdl)
  error("Expected Pdu>=Pdl");
endif
if isempty(vS)
  vS=iir_slb_set_empty_constraints();
endif
if numfields(vS) ~= 8
  error("numfields(vS)=%d, expected 8 (al,au,sl,su,tl,tu,pl and pu)",
        numfields(vS));
endif

%
% Initialise
%

% Loop
piqp_iter=0;func_iter=0;loop_iter=0;feasible=false;
xk=x0(:);  

% Error
[Ek,gradEk,hessEk]=iirE(xk,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp);
if verbose
  printf("Initial Ek=%g\n",Ek);
  printf("Initial gradEk=[");printf("%g ",gradEk);printf("]\n");
endif

% PIQP
P0=zeros(size(hessEk));
c0=zeros(size(gradEk));
rowsG=length(vS.au)+length(vS.al) + ...
      length(vS.su)+length(vS.sl) + ...
      length(vS.tu)+length(vS.tl) + ...
      length(vS.pu)+length(vS.pl);
G0=zeros(rowsG+(2*length(x0)),length(x0));
h0=zeros(rowsG+(2*length(x0)),1);
A0=[];
b0=[];
x0_lb=xl;
x0_ub=xu;
solver=piqp('dense');
solver.update_settings('max_iter', maxiter);
solver.update_settings('verbose', false);
solver.update_settings('compute_timings', verbose);
solver.setup(P0, c0, A0, b0, G0, h0, x0_lb, x0_ub);

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
  Pk=hessEk;
  ck=gradEk;
  
  % Subject to:
  Gk=[]; hk=[];
  % Pass-band amplitude upper bound, gradA*(x-xk) <= Adu-A
  if ~isempty(vS.au)
    [Ak_au,gradAk_au]=iirA(wa(vS.au),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Gk=[Gk; gradAk_au];
    hk=[hk; ctol+Adu(vS.au)-Ak_au];
  endif
  % Pass-band amplitude lower bound, A-Adl >= -gradA*(x-xk)
  if ~isempty(vS.al)
    [Ak_al,gradAk_al]=iirA(wa(vS.al),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Gk=[Gk; -gradAk_al];
    hk=[hk; ctol+Ak_al-Adl(vS.al)];
  endif
  % Stop-band amplitude upper bound, gradS*(x-xk) <= Sdu-S
  if ~isempty(vS.su)
    [Sk_su,gradSk_su]=iirA(ws(vS.su),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Gk=[Gk; gradSk_su];
    hk=[hk; ctol+Sdu(vS.su)-Sk_su];
  endif
  % Stop-band amplitude lower bound, S-Sdl >= -gradS*(x-xk)
  if ~isempty(vS.sl)
    [Sk_sl,gradSk_sl]=iirA(ws(vS.sl),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Gk=[Gk; -gradSk_sl];
    hk=[hk; ctol+Sk_sl-Sdl(vS.sl)];
  endif
  % Group delay upper bound, gradT*(x-xk) <= Tdu-T
  if ~isempty(vS.tu)
    [Tk_tu,gradTk_tu]=iirT(wt(vS.tu),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Gk=[Gk; gradTk_tu];
    hk=[hk; ctol+Tdu(vS.tu)-Tk_tu];
  endif
  % Group delay lower bound, T-Tdl >= -gradT*(x-xk)
  if ~isempty(vS.tl)
    [Tk_tl,gradTk_tl]=iirT(wt(vS.tl),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Gk=[Gk; -gradTk_tl];
    hk=[hk; ctol+Tk_tl-Tdl(vS.tl)];
  endif
  % Set phase linear constraints (avoiding phase unwrapping differences)
  if ~isempty(vS.pu) || ~isempty(vS.pl)
    [P,gradP]=iirP(wp,xk,U,V,M,Q,R);
    func_iter = func_iter+1;
  endif
  % Phase upper bound, gradP*(x-xk) <= Pdu-P
  if ~isempty(vS.pu)
    Gk=[Gk; gradP(vS.pu,:)];
    hk=[hk; ctol+Pdu(vS.pu)-P(vS.pu)];
  endif
  % Phase lower bound, P-Pdl >= -gradP*(x-xk)
  if ~isempty(vS.pl)
    Gk=[Gk; -gradP(vS.pl,:)];
    hk=[hk; ctol+P(vS.pl)-Pdl(vS.pl)];
  endif

  % Decision variable delta constraints -delta<dmax and delta<dmax
  Gk=[Gk;-eye(length(xk))];
  hk=[hk;dmax*ones(size(xk))];
  Gk=[Gk;eye(length(xk))];
  hk=[hk;dmax*ones(size(xk))];

  % Decision variable global constraints
  xk_lb=xl-xk;
  xk_ub=xu-xk;

  % Update solver
  solver.update('P',Pk,'c',ck,'G',Gk,'h',hk,'x_lb',xk_lb,'x_ub',xk_ub);

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
  xk=xk+delta;
  [Ek,gradEk,hessEk] = ...
    iirE(xk,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,verbose);
  if verbose
    printf("PIQP status=%s, run_time=%g, primal_obj=%g\n",
           result.info.status, result.info.run_time, result.info.primal_obj);
    printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
    printf("norm(delta)=%g\n",norm(delta));
    printf("xk=[ ");printf("%g ",xk');printf(" ]';\n"); 
    printf("Ek=%g\n",Ek);
    printf("gradEk=[ ");printf("%g ",gradEk');printf(" ]';\n");
    printf("norm(delta)/norm(xk)=%g\n",norm(delta)/norm(xk));
    printf("func_iter=%d, piqp_iter=%d\n",func_iter,piqp_iter);
  endif
  if norm(delta)/norm(xk) < ftol
    printf("norm(delta)/norm(xk) < ftol\n");
    feasible=true;
    break;
  endif
  
endwhile

endfunction

