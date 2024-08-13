function [xk,Ek,yalmip_iter,func_iter,feasible]= ...
iir_yalmip_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...
                wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
                wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                maxiter,ftol,ctol,verbose,solver_options)
% [xk,E,sedumi_iter,func_iter,feasible] =
%   iir_yalmip_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...
%                   wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
%                   wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
%                   maxiter,ftol,ctol,verbose,solver_options)
%
% YALMIP MMSE optimisation using a linear approximation to the error with
% linear constraints on the amplitude, phase and group delay responses, based
% on iir_socp_mmse.m. The function arguments are as required for iir_slb.m
% with the addition of solver_options to select the solver used by YALMIP.
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
%   solver_options - an additional argument to select the solver used by YALMIP
%
% Outputs:
%   xk - filter design 
%   Ek - error value at xk
%   yalmip_iter - number of PIQP iterations
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

if ((nargin ~= 34) && (nargin ~= 35)) || (nargout ~= 5)
  print_usage("[xk,Ek,yalmip_iter,func_iter,feasible]= ...\n\
    iir_yalmip_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...\n\
                    wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...\n\
                    wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...\n\
                    maxiter,ftol,ctol,verbose[,solver_options])");
endif

if nargin == 34
  solver_options=sdpsettings("solver","sedumi");
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
yalmip_iter=0;func_iter=0;loop_iter=0;feasible=false;xk=x0(:);
[Ek,gradEk] = iirE(xk,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,verbose);

%
% Loop
%
while 1

  loop_iter=loop_iter+1;
  if loop_iter > maxiter
    error("maxiter exceeded");
  endif
  
  %
  % Set up the YALMIP problem
  % 
  delta_xk=sdpvar(N,1);
  eta=sdpvar(1,1);
  epsilon=sdpvar(1,1);

  % SOCP constraint
  Constraints=[];
  Constraints=[Constraints,norm(Ek+((gradEk.')*delta_xk))<=epsilon];
  
  % Coefficient constraints
  Constraints=[Constraints,norm(delta_xk)<=eta];
  Constraints=[Constraints,xl<=(xk+delta_xk)<=xu];
  
  % Pass-band amplitude upper bound, A+gradA*(x-xk) <= Adu+ctol
  if ~isempty(vS.au)
    [Ak_au,gradAk_au]=iirA(wa(vS.au),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Constraints=[Constraints,((Ak_au+(gradAk_au*delta_xk))<=Adu(vS.au)+ctol)];
  endif
  % Pass-band amplitude lower bound, A+gradA*(x-xk) >= Adl-ctol
  if ~isempty(vS.al)
    [Ak_al,gradAk_al]=iirA(wa(vS.al),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Constraints=[Constraints,(Ak_al+(gradAk_al*delta_xk)>=Adl(vS.al)-ctol)];
  endif
  % Stop-band amplitude upper bound,  S+gradS*(x-xk) <= Sdu+ctol
  if ~isempty(vS.su)
    [Sk_su,gradSk_su]=iirA(ws(vS.su),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Constraints=[Constraints,(Sk_su+(gradSk_su*delta_xk)<=Sdu(vS.su)+ctol)];
  endif
  % Stop-band amplitude lower bound, S+gradS*(x-xk) >= Sdl-ctol
  if ~isempty(vS.sl)
    [Sk_sl,gradSk_sl]=iirA(ws(vS.sl),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Constraints=[Constraints,(Sk_sl+(gradSk_sl*delta_xk)>=Sdl(vS.sl)-ctol)];
  endif
  % Group delay upper bound,  T+gradT*(x-xk) <= Tdu+ctol
  if ~isempty(vS.tu)
    [Tk_tu,gradTk_tu]=iirT(wt(vS.tu),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Constraints=[Constraints,(Tk_tu+(gradTk_tu*delta_xk)<=Tdu(vS.tu)+ctol)];
  endif
  % Group delay lower bound, T+gradT*(x-xk) >= Tdl-ctol
  if ~isempty(vS.tl)
    [Tk_tl,gradTk_tl]=iirT(wt(vS.tl),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Constraints=[Constraints,(Tk_tl+(gradTk_tl*delta_xk)>=Tdl(vS.tl)-ctol)];
  endif
  % Set phase linear constraints (avoiding phase unwrapping differences)
  if ~isempty(vS.pu) || ~isempty(vS.pl)
    [P,gradP]=iirP(wp,xk,U,V,M,Q,R);
    func_iter = func_iter+1;
  endif
  % Phase upper bound, s + gradP*(x-xk) = Pdu+ctol-P, s >= 0
  if ~isempty(vS.pu)
    Constraints=[Constraints, ...
                 (P(vS.pu)+(gradP(vS.pu,:)*delta_xk)<=Pdu(vS.pu)+ctol)];
  endif
  % Phase lower bound, s - gradP*(x-xk) = P-Pdl+ctol, s >= 0
  if ~isempty(vS.pl)
    Constraints=[Constraints, ...
                 (P(vS.pl)+(gradP(vS.pl,:)*delta_xk)>=Pdl(vS.pl)+ctol)];
  endif
  
  %
  % Call solver through YALMIP
  %
  try
    Objective=epsilon+eta;
    sol=optimize(Constraints,Objective,solver_options);
    if sol.problem
      error("YALMIP solver %s failed : %s",solver_options.solver,sol.info);
    endif
    yalmip_iter=yalmip_iter+1;
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

  %
  % Update xk
  %
  xk=xk+(value(delta_xk)/2);
  [Ek,gradEk]=iirE(xk,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,verbose);
  if verbose
    printf("epsilon=%g\n",value(epsilon));  
    printf("eta=%g\n",value(eta)); 
    printf("delta_xk=[ ");printf("%g ",value(delta_xk)');printf(" ]';\n"); 
    printf("norm(delta_xk)=%g\n",norm(value(delta_xk)));
    printf("xk=[ ");printf("%g ",xk');printf(" ]';\n"); 
    printf("Ek=%g\n",Ek);
    printf("gradEk=[ ");printf("%g ",gradEk');printf(" ]';\n");
    printf("norm(delta_xk)/norm(xk)=%g\n",norm(value(delta_xk))/norm(xk));
    printf("func_iter=%d, yalmip_iter=%d\n",func_iter,yalmip_iter);
  endif
  if norm(value(delta_xk))/norm(xk) < ftol
    printf("norm(value(delta_xk))/norm(xk) < ftol\n");
    feasible=true;
    break;
  endif
  
endwhile

endfunction

