function [x,E,sqp_iter,func_iter,feasible] = ... 
           iir_sqp_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...
                        wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
                        wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                        maxiter,ftol,ctol,verbose)
% [x,E,sqp_iter,func_iter,feasible] = ...
%   iir_sqp_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R,wa,Ad,Adu,Adl,Wa, ...
%                ws,Sd,Sdu,Sdl,Ws,wt,Td,Tdu,Tdl,Wt, ...
%                wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose)
%
% SQP MMSE optimisation of a Lagrangian with constraints on the
% amplitude and group delay responses. 
%
% Inputs:
%   vS - structure of constraint frequencies, {al,au,sl,su,tl,tu,pl,pu}.
%   x0 - initial coefficient vector in the form:
%         [ k;                          ...
%           zR(1:U);     pR(1:V);       ...
%           abs(z(1:Mon2)); angle(z(1:Mon2)); ...
%           abs(p(1:Qon2)); angle(p(1:Qon2)) ];
%         where k is the gain coefficient, zR and pR represent real
%         zeros  and poles and z and p represent conjugate zero and
%         pole pairs.
%   xu - upper constraint on coefficients
%   xl - lower constraint on coefficients
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
%   maxiter - maximum number of SQP iterations
%   ftol - tolerance on function value
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
%   sqp_iter - number of SQP iterations
%   func_iter - number of iirE() function calls
%   feasible - true if a solution has been found
         
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
  print_usage("[x,E,sqp_iter,func_iter,feasible] = ...\n\
         iir_sqp_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...\n\
         wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws,wt,Td,Tdu,Tdl,Wt, ...\n\
         wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose)"); 
endif

% Sanity checks
N=1+U+V+M+Q;
Nwa=length(wa);
Nws=length(ws);
Nwt=length(wt);
Nwp=length(wp);
if length(x0) ~= N
  error("Expected length(x)(%d) == 1+U+V+M+Q(%d)",length(x),N);
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
  error("Expected lenth(ws)(%d) == length(Sdl)(%d)",Nws,length(Sdl));
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
  error("Expected Pdu>=Pdl");
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
  error("numfields(vS)=%d, expected 8(al,au,sl,su,tl,tu,pl and pu)!", ...
        numfields(vS));
endif

% Initialise objective function persistent constants
[E,gradE,hessE]=iir_sqp_mmse_fx(x0,U,V,M,Q,R, ...
                                wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp);

% Initialise the approximation to the Hessian for the BFGS update
W=diag(diag(hessE));
invW=inv(W);

% Initialise constraint function persistent constants
gx=iir_sqp_mmse_gx(x0,vS,U,V,M,Q,R, ...
                   wa,Adu,Adl,ws,Sdu,Sdl,wt,Tdu,Tdl,wp,Pdu,Pdl,ctol,false);
  
% Initial check on constraints. Do not need to proceed if they are satisfied.
if (isempty(gx) == false) && all(gx > -ctol)
  x=x0;
  sqp_lm=[];
  sqp_iter=0;
  [~,~,~,func_iter] = iir_sqp_mmse_fx();
  feasible=true;
  printf("iir_sqp_mmse() : gx constraints satisfied by x0!\n");
  return;
endif
  
%
% Step 2 : Solve for the Lagrange multipliers at the active constraints  
%
% Sequential Quadratic Programming (SQP) loop  
x=[];E=inf;sqp_lm=[];func_iter=0;sqp_iter=0;liter=0;feasible=false;
try
  [x,E,sqp_lm,sqp_iter,liter,feasible] = ...
  sqp_bfgs(x0,@iir_sqp_mmse_fx,@iir_sqp_mmse_gx,"armijo_kim", ...
           xl,xu,dmax,{W,invW},"bfgs",maxiter,ftol,ctol,verbose);
  [~,~,~,func_iter] = iir_sqp_mmse_fx();
catch
  x=[];
  E=inf;
  sqp_lm=[];
  [~,~,~,func_iter] = iir_sqp_mmse_fx();
  feasible=false;
  printf("sqp_bfgs() infeasible!\n");
  err=lasterror();
  printf("%s\n", err.message);
  for e=1:length(err.stack)
    printf("Called %s at line %d\n", ...
           err.stack(e).name,err.stack(e).line);
  endfor
  return;
end_try_catch
if (feasible)
elseif sqp_iter>=maxiter
  warning("Maximum SQP iterations reached (%d). Bailing out!\n", sqp_iter);
  printf("x=[ ");printf("%f ",x);printf("]';\n");
else
  warning("Solution not feasible after %d SQP iterations!\n", sqp_iter); 
endif

endfunction

function [E,gradE,hessE,func_iter] = ...
  iir_sqp_mmse_fx(x,_U,_V,_M,_Q,_R, ...
                  _wa,_Ad,_Wa,_ws,_Sd,_Ws,_wt,_Td,_Wt,_wp,_Pd,_Wp)
         
  persistent U V M Q R N wa Ad Wa ws Sd Ws wt Td Wt wp Pd Wp
  persistent iter=0
  persistent init_complete=false

  % Initialise persistent (constant) values 
  if nargin == 1
    if init_complete == false
      error("nargin==1 && init_complete==false");
    endif
  elseif nargout == 4
    % Hack to avoid a global for func_iter
    E=inf;gradE=[];hessE=[];func_iter=iter;
    return;
  elseif nargin == 18
    U=_U;V=_V;M=_M;Q=_Q;R=_R;
    N=1+U+V+M+Q;
    wa=_wa;Ad=_Ad;Wa=_Wa;
    ws=_ws;Sd=_Sd;Ws=_Ws;
    wt=_wt;Td=_Td;Wt=_Wt;
    wp=_wp;Pd=_Pd;Wp=_Wp;
    iter=0;
    init_complete=true;
  else
    print_usage("[E,gradE,hessE,func_iter] = iir_sqp_mmse(x, ... );");
  endif
  if nargout == 0
    return;
  endif

  % Calculate error, error gradient and error Hessian 
  iter=iter+1;
  func_iter=iter;
  if nargout == 3
    [E,gradE,hessE]=iirE(x,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp);
  elseif nargout == 2
    [E,gradE]=iirE(x,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp);
    hessE=eye(N,N);
  elseif nargout == 1
    E=iirE(x,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp);
    gradE=zeros(N,1);
    hessE=eye(N,N);
  endif
    
endfunction

function [gx,B] = iir_sqp_mmse_gx(x,_vS,_U,_V,_M,_Q,_R, ...
                                  _wa,_Adu,_Adl,_ws,_Sdu,_Sdl, ...
                                  _wt,_Tdu,_Tdl,_wp,_Pdu,_Pdl, ...
                                  _ctol,_verbose)
 
  persistent vS U V M Q R N wa Adu Adl ws Sdu Sdl wt Tdu Tdl wp Pdu Pdl
  persistent ctol verbose
  persistent init_complete=false

  % Initialise persistent values
  if nargin == 1
    if init_complete == false
      error("nargin==1 && init_complete==false");
    endif
  elseif nargin == 21
    % Initialise constraints
    if isempty(_vS) 
      iir_slb_set_empty_constraints(vS);
    else
      vS.al=_vS.al;vS.au=_vS.au;
      vS.sl=_vS.sl;vS.su=_vS.su;
      vS.tl=_vS.tl;vS.tu=_vS.tu;
      vS.pl=_vS.pl;vS.pu=_vS.pu;
    endif
    U=_U;V=_V;M=_M;Q=_Q;R=_R;
    N=1+U+V+M+Q;
    wa=_wa;Adu=_Adu;Adl=_Adl;
    ws=_ws;Sdu=_Sdu;Sdl=_Sdl;
    wt=_wt;Tdu=_Tdu;Tdl=_Tdl;
    wp=_wp;Pdu=_Pdu;Pdl=_Pdl;
    ctol=_ctol;
    verbose=_verbose;
    init_complete=true;
  else
    print_usage("[gx,B] = iir_sqp_mmse_gx(x, ... );");
  endif

  % Do nothing
  if nargout == 0
    return;
  endif
  if iir_slb_constraints_are_empty(vS)
    gx=[];
    B=[];
    return;
  endif
 
  % Find response at constraint frequencies
  if nargout == 2
    [Al,gradAl]=iirA(wa(vS.al),x,U,V,M,Q,R);
    [Au,gradAu]=iirA(wa(vS.au),x,U,V,M,Q,R);
    [Sl,gradSl]=iirA(ws(vS.sl),x,U,V,M,Q,R);
    [Su,gradSu]=iirA(ws(vS.su),x,U,V,M,Q,R);
    [Tl,gradTl]=iirT(wt(vS.tl),x,U,V,M,Q,R);
    [Tu,gradTu]=iirT(wt(vS.tu),x,U,V,M,Q,R); 
    [P,gradP]=iirP(wp,x,U,V,M,Q,R);
    Pl=P(vS.pl);
    gradPl=gradP(vS.pl,:);
    Pu=P(vS.pu);
    gradPu=gradP(vS.pu,:);
  else
    gradAl=[];
    Al=iirA(wa(vS.al),x,U,V,M,Q,R);
    gradAu=[];
    Au=iirA(wa(vS.au),x,U,V,M,Q,R);
    gradSl=[];
    Sl=iirA(ws(vS.sl),x,U,V,M,Q,R);
    gradSu=[];
    Su=iirA(ws(vS.su),x,U,V,M,Q,R);
    gradTl=[];
    Tl=iirT(wt(vS.tl),x,U,V,M,Q,R);
    gradTu=[];
    Tu=iirT(wt(vS.tu),x,U,V,M,Q,R);
    P=iirP(wp,x,U,V,M,Q,R);
    Pl=P(vS.pl);
    gradPl=[];
    Pu=P(vS.pu);
    gradPu=[];
  endif

  % Construct constraint vector
  gx=[Al-Adl(vS.al); Adu(vS.au)-Au; ...
      Sl-Sdl(vS.sl); Sdu(vS.su)-Su; ...
      Tl-Tdl(vS.tl); Tdu(vS.tu)-Tu; ...
      Pl-Pdl(vS.pl); Pdu(vS.pu)-Pu ];

  % Construct constraint gradient matrix 
  B=[];
  if nargout == 2
    % Remove constraints with zero gradient 
    for k=rows(gradAl):-1:1,
      if all(abs(gradAl(k,:))<ctol)
        Al(k)=[]; gradAl(k,:)=[]; vS.al(k)=[];
      endif
    endfor
    for k=rows(gradAu):-1:1,
      if all(abs(gradAu(k,:))<ctol)
        Au(k)=[]; gradAu(k,:)=[]; vS.au(k)=[];
      endif
    endfor
    for k=rows(gradSl):-1:1,
      if all(abs(gradSl(k,:))<ctol)
        Sl(k)=[]; gradSl(k,:)=[]; vS.sl(k)=[];
      endif
    endfor
    for k=rows(gradSu):-1:1,
      if all(abs(gradSu(k,:))<ctol)
        Su(k)=[]; gradSu(k,:)=[]; vS.su(k)=[];
      endif
    endfor
    for k=rows(gradTl):-1:1,
      if all(abs(gradTl(k,:))<ctol)
        Tl(k)=[]; gradTl(k,:)=[]; vS.tl(k)=[];
      endif
    endfor
    for k=rows(gradTu):-1:1,
      if all(abs(gradTu(k,:))<ctol)
        Tu(k)=[]; gradTu(k,:)=[]; vS.tu(k)=[];
      endif
    endfor
    for k=rows(gradPl):-1:1,
      if all(abs(gradPl(k,:))<ctol)
        Pl(k)=[]; gradPl(k,:)=[]; vS.pl(k)=[];
      endif
    endfor
    for k=rows(gradPu):-1:1,
      if all(abs(gradPu(k,:))<ctol)
        Pu(k)=[]; gradPu(k,:)=[]; vS.pu(k)=[];
      endif
    endfor
    B=[gradAl;-gradAu;gradSl;-gradSu;gradTl;-gradTu;gradPl;-gradPu]';
  endif

  % Show
  if verbose
    if all(gx>-ctol)
      printf("All constraints satisfied!\n");
    endif
    Ac=zeros(size(wa));  Ac(vS.al)=Al;  Ac(vS.au)=Au;
    Sc=zeros(size(ws));  Sc(vS.sl)=Sl;  Sc(vS.su)=Su;
    Tc=zeros(size(wt));  Tc(vS.tl)=Tl;  Tc(vS.tu)=Tu;
    Pc=zeros(size(wp));  Pc(vS.pl)=Pl;  Pc(vS.pu)=Pu;
    iir_slb_show_constraints(vS,wa,Ac,ws,Sc,wt,Tc,wp,Pc);
  endif

endfunction
