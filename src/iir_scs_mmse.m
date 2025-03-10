function [xk,Ek,scs_iter,func_iter,feasible]= ...
iir_scs_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...
              wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
              wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
              maxiter,ftol,ctol,verbose)
% [xk,E,scs_iter,func_iter,feasible] =
%   iir_scs_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...
%                 wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
%                 wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
%                 maxiter,ftol,ctol,verbose)
%
% SCS MMSE optimisation using a linear approximation to the error with
% linear constraints on the amplitude, phase and group delay responses. The
% function signature is the same as that of iir_sqp_mmse.m and this function
% is compatible with iir_slb.m. The SCS solution does not require a
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
%   scs_iter - number of PIQP iterations
%   func_iter - number of function calls
%   feasible - x satisfies the constraints 

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

if (nargin ~= 34) || (nargout ~= 5)
  print_usage(["[xk,Ek,scs_iter,func_iter,feasible]= ...\n", ...
 "    iir_scs_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...\n", ...
 "                  wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...\n", ...
 "                  wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...\n", ...
 "                  maxiter,ftol,ctol,verbose)"]);
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
  error("numfields(vS)=%d, expected 8 (al,au,sl,su,tl,tu,pl and pu)", ...
        numfields(vS));
endif

%
% Initialise
%

% Loop
scs_iter=0;func_iter=0;loop_iter=0;feasible=false;
big_num=10000;
xk=x0(:);  
[Ek,gradEk,hessEk] = ...
  iirE(xk,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,verbose);

%
% SCS loop
%
while 1

  loop_iter=loop_iter+1;
  if loop_iter > maxiter
    error("maxiter exceeded");
  endif
  
  %
  % Set up the SCS problem:
  %   delta=[delta_xk,epsilon,eta]
  % where:
  %   norm(Ek+gradEk'*delta_xk)<=epsilon
  % and:
  %   norm(delta_xk)<=eta
  %
  % Minimise epsilon+eta subject to PCLS constraints and xl<=xk+delta_xk<=xu
  %
  
  % Initialise
  Ak=[];
  bk=[]; 
  % Zero cones, 
  cones.z=0;
  % Positive cones, s=b-Ax>=0
  cones.l=0;

  % Pass-band amplitude lower bound, s - gradA*(x-xk) = A-Adl+ctol, s >= 0
  if ~isempty(vS.al)
    [Ak_al,gradAk_al]=iirA(wa(vS.al),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Ak=[Ak; [-gradAk_al, zeros(length(vS.al),2)]];
    bk=[bk; (Ak_al-Adl(vS.al)+ctol)];
    cones.l=cones.l+length(vS.al);    
  endif
  % Pass-band amplitude upper bound, s + gradA*(x-xk) = Adu+ctol-A, s >= 0
  if ~isempty(vS.au)
    [Ak_au,gradAk_au]=iirA(wa(vS.au),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Ak=[Ak; [gradAk_au, zeros(length(vS.au),2)]];
    bk=[bk; (Adu(vS.au)+ctol-Ak_au)];
    cones.l=cones.l+length(vS.au);
  endif
  % Stop-band amplitude lower bound, s - gradS*(x-xk) = S-Sdl+ctol, s >= 0
  if ~isempty(vS.sl)
    [Sk_sl,gradSk_sl]=iirA(ws(vS.sl),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Ak=[Ak; [-gradSk_sl, zeros(length(vS.sl),2)]];
    bk=[bk; (Sk_sl-Sdl(vS.sl)+ctol)];
    cones.l=cones.l+length(vS.sl);
  endif
  % Stop-band amplitude upper bound,  s + gradS*(x-xk) = Sdu+ctol-S, s >= 0
  if ~isempty(vS.su)
    [Sk_su,gradSk_su]=iirA(ws(vS.su),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Ak=[Ak; [gradSk_su, zeros(length(vS.su),2)]];
    bk=[bk; (Sdu(vS.su)+ctol-Sk_su)];
    cones.l=cones.l+length(vS.su);
  endif
  % Group delay lower bound, s - gradT*(x-xk) = T-Tdl+ctol, s >= 0
  if ~isempty(vS.tl)
    [Tk_tl,gradTk_tl]=iirT(wt(vS.tl),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Ak=[Ak; [-gradTk_tl, zeros(length(vS.tl),2)]];
    bk=[bk; (Tk_tl-Tdl(vS.tl)+ctol)];
    cones.l=cones.l+length(vS.tl);
  endif
  % Group delay upper bound,  s + gradT*(x-xk) = Tdu+ctol-T, s >= 0
  if ~isempty(vS.tu)
    [Tk_tu,gradTk_tu]=iirT(wt(vS.tu),xk,U,V,M,Q,R);
    func_iter = func_iter+1;
    Ak=[Ak; [gradTk_tu, zeros(length(vS.tu),2)]];
    bk=[bk; (Tdu(vS.tu)+ctol-Tk_tu)];
    cones.l=cones.l+length(vS.tu);
  endif
  % Set phase linear constraints (avoiding phase unwrapping differences)
  if ~isempty(vS.pu) || ~isempty(vS.pl)
    [P,gradP]=iirP(wp,xk,U,V,M,Q,R);
    func_iter = func_iter+1;
  endif
  % Phase lower bound, s - gradP*(x-xk) = P-Pdl+ctol, s >= 0
  if ~isempty(vS.pl)
    Ak=[Ak; [-gradP(vS.pl,:), zeros(length(vS.pl),2)]];
    bk=[bk; (P(vS.pl)-Pdl(vS.pl)+ctol)];
    cones.l=cones.l+length(vS.pl);
  endif
  % Phase upper bound, s + gradP*(x-xk) = Pdu+ctol-P, s >= 0
  if ~isempty(vS.pu)
    Ak=[Ak; [gradP(vS.pu,:), zeros(length(vS.pu),2)]];
    bk=[bk; (Pdu(vS.pu)+ctol-P(vS.pu))];
    cones.l=cones.l+length(vS.pu);
  endif

  % Box cone for coefficient upper and lower bounds:
  %   s+delta_xk =  xu-xk, s>=0, xu >= xk+delta_xk
  %   s-delta_xk = -xl+xk, s>=0, xl <= xk+delta_xk
  cones.bu=(xu-xk);
  cones.bl=(xl-xk);
  % [r;delta_xk] stacked, r=1
  Ak=[Ak; [zeros(1,N), zeros(1,2)]; [-eye(N), zeros(N,2)]];
  bk=[bk; [1; zeros(N,1)]];
  
  % Add an SOCP constraint to minimise epsilon such that:
  %   norm(Ek+(gradEk'*delta_xk)) <= epsilon
  % SCS requires an auxilliary variable, u, such that (u,s) in RxR^(N+2) and
  % norm(s)<=u. Recalling that, for SCS, s+Ax=b, s>=0, an extra rows are added
  % to A with u-epsilon=0 and s()-gradEk'*delta_xk=Ek. The SCS cone is:
  %   norm(s()) = norm(Ek+gradEk'*delta_xk) <= epsilon
  Ak=[Ak; [zeros(1,N),-1,0]; [-gradEk',zeros(1,2)]];
  bk=[bk; [0;Ek]];
  cones.q=2;
  
  % Add an SOCP constraint to minimise eta such that:
  %   norm(delta_xk) <= eta
  % SCS requires an auxilliary variable, v, such that (v,s) in RxR^(N+2) and
  % norm(s)<=v. Recalling that, for SCS, s+Ax=b, s>=0, an extra rows are added
  % to A with v-eta=0 and s()-delta_xk=0. The SCS cone is:
  %   norm(s()) = norm(delta_xk) <= eta
  Ak=[Ak; [zeros(1,N),0,-1]; [-eye(N),zeros(N,2)]];
  bk=[bk; [0; zeros(N,1)]];
  cones.q=[cones.q,(N+1)];
  
  % Sanity check
  if rows(Ak) ~= rows(bk)
    error("rows(Ak) ~= rows(bk)");
  endif

  % Minimise epsilon+eta
  ck=[zeros(N,1);1;1];
  
  %
  % Call SCS
  %
  try
    data=struct("A",sparse(Ak),"b",bk,"c",ck);
    settings=struct("max_iters",1e4,"eps_abs",1e-9,"eps_rel",1e-9,"verbose",0);
    [delta, y, s, scs_info] = scs_direct(data, cones, settings);
    if scs_info.status_val < 0
      error("SCS failed : %s (%d)\n",scs_info.status,scs_info.status_val);
    endif
    scs_iter=scs_iter+1;
  catch
    xk=[];
    Ek=inf;
    feasible=false;
    err=lasterror();
    for frame=1:length(err.stack)
      fprintf(stderr,"Called %s at line %d\n", ...
              err.stack(frame).name,err.stack(frame).line);
    endfor
    error("%s\n", err.message);
    return;
  end_try_catch

  %
  % Extract delta_xk
  %
  delta_xk=delta(1:length(xk));
  epsilon=delta(length(xk)+1);
  eta=delta(length(xk)+2);

  % Update xk
  xk=xk+(value(delta_xk)/2);
  [Ek,gradEk,hessEk]= ...
    iirE(xk,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,verbose);
  if verbose
    printf("epsilon=%g\n",value(epsilon));  
    printf("eta=%g\n",value(eta));  
    printf("delta_xk=[ ");printf("%g ",value(delta_xk)');printf(" ]';\n"); 
    printf("norm(delta_xk)=%g\n",norm(value(delta_xk)));
    printf("xk=[ ");printf("%g ",xk');printf(" ]';\n"); 
    printf("Ek=%g\n",Ek);
    printf("gradEk=[ ");printf("%g ",gradEk');printf(" ]';\n");
    printf("norm(delta_xk)/norm(xk)=%g\n",norm(value(delta_xk))/norm(xk));
    printf("func_iter=%d, scs_iter=%d\n",func_iter,scs_iter);
  endif
  if norm(value(delta_xk))/norm(xk) < ftol
    printf("norm(value(delta_xk))/norm(xk) < ftol\n");
    feasible=true;
    break;
  endif

endwhile

endfunction

