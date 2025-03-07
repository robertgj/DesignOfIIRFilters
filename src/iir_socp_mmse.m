function [xk,Ek,socp_iter,func_iter,feasible]= ...
  iir_socp_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...
                wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
                wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                maxiter,ftol,ctol,verbose)
% [xk,E,socp_iter,func_iter,feasible] =
%   iir_socp_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...
%                 wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
%                 wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
%                 maxiter,ftol,ctol,verbose)
%
% SOCP MMSE optimisation using a linear approximation to the error with
% linear constraints on the amplitude, phase and group delay responses. The
% function signature is the same as that of iir_sqp_mmse.m and this function
% is compatible with iir_slb.m. The SOCP solution does not require a
% linesearch function and the dmax argument is unused.
%
% See:
% "Optimal Design of IIR Frequency-Response-Masking Filters Using 
% Second-Order Cone Programming", W.-S.Lu and T.Hinamoto, IEEE
% Transactions on Circuits and Systems-I:Fundamental Theory and 
% Applications, Vol.50, No.11, Nov. 2003, pp.1401--1412
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
%   socp_iter - number of SOCP iterations
%   func_iter - number of function calls
%   feasible - x satisfies the constraints 

% Copyright (C) 2017-2025 Robert G. Jenssen
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
    print_usage("[xk,Ek,socp_iter,func_iter,feasible]= ...\n\
      iir_socp_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...\n\
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
    error("numfields(vS)=%d, expected 8 (al,au,sl,su,tl,tu,pl and pu)", ...
          numfields(vS));
  endif

  % Initialise
  socp_iter=0;func_iter=0;loop_iter=0;feasible=false;
  xk=x0(:);  
  [Ek,gradEk]=iirE(xk,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,verbose);
  if verbose
    printf("Initial Ek=%g\n",Ek);
    printf("Initial gradEk=[");printf("%g ",gradEk);printf("]\n");
  endif
  if verbose
    pars.fid=2;
  else
    pars.fid=0;
  endif

  %
  % Second Order Cone Programming (SOCP) loop
  %
  while 1

    loop_iter=loop_iter+1;
    if loop_iter > maxiter
      error("maxiter exceeded");
    endif

    %
    % Set up the SeDuMi problem. 
    % The vector to be minimised is [epsilon;beta;x] where epsilon is 
    % the MMSE error, beta is the coefficient step size and x is the 
    % coefficient difference vector.
    %
    bt=-[1;1;zeros(N,1)];

    % Linear coefficient constraints on pole radiuses
    Qon2=Q/2;
    D=[zeros(2+1+U,2*(V+Qon2)); ...
       -eye(V,V), eye(V,V), zeros(V,2*Qon2); ...
       zeros(M,2*(V+Qon2)); ...
       zeros(Qon2,2*V), -eye(Qon2,Qon2), eye(Qon2,Qon2); ...
       zeros(Qon2,2*(V+Qon2))];
    f=[xu((1+U+1):(1+U+V))            - xk((1+U+1):(1+U+V)); ...
       xk((1+U+1):(1+U+V))            - xl((1+U+1):(1+U+V)); ...
       xu((1+U+V+M+1):(1+U+V+M+Qon2)) - xk((1+U+V+M+1):(1+U+V+M+Qon2)); ...
       xk((1+U+V+M+1):(1+U+V+M+Qon2)) - xl((1+U+V+M+1):(1+U+V+M+Qon2))];

    % Pass-band amplitude linear constraints
    if ~isempty(vS.au)
      [Ampk_au,gradAmpk_au]=iirA(wa(vS.au),xk,U,V,M,Q,R);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.au));-gradAmpk_au']];
      f=[f; Adu(vS.au)-Ampk_au];
    endif
    if ~isempty(vS.al)
      [Ampk_al,gradAmpk_al]=iirA(wa(vS.al),xk,U,V,M,Q,R);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.al));gradAmpk_al']];
      f=[f; Ampk_al-Adl(vS.al)];
    endif

    % Stop-band amplitude linear constraints
    if ~isempty(vS.su)
      [Sk_su,gradSk_su]=iirA(ws(vS.su),xk,U,V,M,Q,R);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.su));-gradSk_su']];
      f=[f; Sdu(vS.su)-Sk_su];
    endif
    if ~isempty(vS.sl)
      [Sk_sl,gradSk_sl]=iirA(ws(vS.sl),xk,U,V,M,Q,R);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.sl));gradSk_sl']];
      f=[f; Sk_sl-Sdl(vS.sl)];
    endif

    % Group-delay linear constraints
    if ~isempty(vS.tu)
      [Tk_tu,gradTk_tu]=iirT(wt(vS.tu),xk,U,V,M,Q,R);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.tu));-gradTk_tu']];
      f=[f; Tdu(vS.tu)-Tk_tu];
    endif
    if ~isempty(vS.tl)
      [Tk_tl,gradTk_tl]=iirT(wt(vS.tl),xk,U,V,M,Q,R);
      func_iter = func_iter+1;
      D=[D, [zeros(2,length(vS.tl));gradTk_tl']];
      f=[f; Tk_tl-Tdl(vS.tl)];
    endif

    % Phase linear constraints
    if ~isempty(vS.pu) || ~isempty(vS.pl)
      [P,gradP]=iirP(wp,xk,U,V,M,Q,R);
      func_iter = func_iter+1;
    endif
    if ~isempty(vS.pu)
      D=[D, [zeros(2,length(vS.pu));-gradP(vS.pu,:)']];
      f=[f; Pdu(vS.pu)-P(vS.pu)];
    endif
    if ~isempty(vS.pl)
      D=[D, [zeros(2,length(vS.pl)); gradP(vS.pl,:)']];
      f=[f; P(vS.pl)-Pdl(vS.pl)];
    endif
    
    % SeDuMi linear constraint matrixes
    At=-D;
    ct=f;
    sedumiK.l=columns(D);

    % SeDuMi quadratic constraint matrixes

    % Step size constraints
    At1=[zeros(2,N);eye(N,N)];
    b1=[0;1;zeros(N,1)];
    c1=zeros(N,1);
    d1=0;
    At=[At, -[b1,At1]];
    ct=[ct;d1;c1];
    sedumiK.q=size(At1,2)+1;

    % MMSE constraint
    At2=[zeros(2,1); gradEk(:)];
    b2=[1;0;zeros(N,1)];
    c2=Ek;
    d2=0;
    At=[At, -[b2, At2]];
    ct=[ct;d2;c2];
    sedumiK.q=[sedumiK.q, size(At2,2)+1];
      
    %
    % Call SeDuMi
    %
    try
      [xs,ys,info]=sedumi(At,bt,ct,sedumiK,pars);
      printf("SeDuMi info.iter=%d, info.feasratio=%10.4g, r0=%10.4g\n", ...
             info.iter,info.feasratio,info.r0);
      if info.pinf 
        error("SeDuMi primary problem infeasible");
      endif
      if info.dinf
        error("SeDuMi dual problem infeasible");
      endif 
      if info.numerr == 1
        error("SeDuMi premature termination"); 
      elseif info.numerr == 2 
        error("SeDuMi numerical failure");
      elseif info.numerr
        error("SeDuMi info.numerr=%d",info.numerr);
      endif
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
    end_try_catch

    %
    % Extract results
    %
    epsilon=ys(1);
    beta=ys(2);
    delta=ys(3:end);
    xk=xk+delta;
    [Ek,gradEk]=iirE(xk,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,verbose);
    socp_iter=socp_iter+info.iter;
    if verbose
      printf("epsilon=%g\n",epsilon);
      printf("beta=%g\n",beta);
      printf("delta=[ ");printf("%g ",delta');printf(" ]';\n"); 
      printf("norm(delta)=%g\n",norm(delta));
      printf("xk=[ ");printf("%g ",xk');printf(" ]';\n");
      printf("norm(delta)/norm(xk)=%g\n",norm(delta)/norm(xk));
      printf("Ek= %g\n",Ek);
      printf("gradEk=[");printf("%g ",gradEk);printf("]\n");
      printf("func_iter=%d, socp_iter=%d\n",func_iter,socp_iter);
      info
    endif
    if norm(delta)/norm(xk) < ftol
      printf("norm(delta)/norm(xk) < ftol\n");
      feasible=true;
      break;
    endif
    
  endwhile

endfunction

