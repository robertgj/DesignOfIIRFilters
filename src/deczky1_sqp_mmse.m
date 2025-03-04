function [x,E,sqp_iter,func_iter,feasible] = ... 
  deczky1_sqp_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...
                   wa,Ad,Adu,Adl,Wa,wt,Td,Tdu,Tdl,Wt,wx, ...
                   maxiter,ftol,ctol,verbose)
% [x,E,sqp_iter,func_iter,feasible] = ...
%   deczky1_sqp_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...
%                    wa,Ad,Adu,Adl,Wa,wt,Td,Tdu,Tdl,Wt,wx, ...
%                    maxiter,ftol,ctol,verbose)
%
% SQP MMSE optimisation of a Lagrangian with constraints on the
% amplitude and group delay responses, including a constraint on the
% slope of the amplitude response in the tansition-band at frequencies wx.
%
% Inputs:
%   vS - structure of constraint frequencies, {al,au,tl,tu,ax}.
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
%   wt - angular frequencies of the desired group delay response
%   Td - desired group delay response vector
%   Tdu,Tdl - upper/lower mask for the desired group delay response
%   Wt - group delay weight at each frequency
%   wx - angular frequencies of desired transition-band amplitude response 
%        derivative
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

if (nargin ~= 25) || (nargout ~= 5)
  print_usage("[x,E,sqp_iter,func_iter,feasible] = ...\n\
         deczky1_sqp_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...\n\
         wa,Ad,Adu,Adl,Wa,wt,Td,Tdu,Tdl,Wt,wx, ...\n\
         maxiter,ftol,ctol,verbose)"); 
endif

% Sanity checks
N=1+U+V+M+Q;
Nwa=length(wa);
Nwt=length(wt);
Nwx=length(wx);
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
if isempty(vS)
  vS=deczky1_slb_set_empty_constraints();
endif
if numfields(vS) ~= 5
  error("numfields(vS)=%d, expected 5(al,au,tl,tu and ax)!",numfields(vS));
endif

% Initialise objective function persistent constants
[E,gradE,hessE]=deczky1_sqp_mmse_fx(x0,U,V,M,Q,R,wa,Ad,Wa,wt,Td,Wt);

% Initialise the approximation to the Hessian for the BFGS update
W=diag(diag(hessE));
invW=inv(W);

% Initialise constraint function persistent constants
gx=deczky1_sqp_mmse_gx(x0,vS,U,V,M,Q,R,wa,Adu,Adl,wt,Tdu,Tdl,wx,ctol,false);
  
% Initial check on constraints. Do not need to proceed if they are satisfied.
if (isempty(gx) == false) && all(gx > -ctol)
  x=x0;
  sqp_lm=[];
  sqp_iter=0;
  [dummy1,dummy2,dummy3,func_iter] = deczky1_sqp_mmse_fx();
  feasible=true;
  printf("deczky1_sqp_mmse() : gx constraints satisfied by x0!\n");
  return;
endif
  
%
% Step 2 : Solve for the Lagrange multipliers at the active constraints  
%
% Sequential Quadratic Programming (SQP) loop  
x=[];E=inf;sqp_lm=[];func_iter=0;sqp_iter=0;liter=0;feasible=false;
try
  [x,E,sqp_lm,sqp_iter,liter,feasible] = ...
  sqp_bfgs(x0,@deczky1_sqp_mmse_fx,@deczky1_sqp_mmse_gx,"armijo_kim", ...
           xl,xu,dmax,{W,invW},"bfgs",maxiter,ftol,ctol,verbose);
  [dummy1,dummy2,dummy3,func_iter] = deczky1_sqp_mmse_fx();
catch
  x=[];
  E=inf;
  sqp_lm=[];
  [dummy1,dummy2,dummy3,func_iter] = deczky1_sqp_mmse_fx();
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
         deczky1_sqp_mmse_fx(x,_U,_V,_M,_Q,_R,_wa,_Ad,_Wa,_wt,_Td,_Wt)
         
  persistent U V M Q R N wa Ad Wa wt Td Wt
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
  elseif nargin == 12
    U=_U;V=_V;M=_M;Q=_Q;R=_R;
    N=1+U+V+M+Q;
    wa=_wa;Ad=_Ad;Wa=_Wa;
    wt=_wt;Td=_Td;Wt=_Wt;
    iter=0;
    init_complete=true;
  else
    print_usage("[E,gradE,hessE,func_iter] = deczky1_sqp_mmse(x, ... );");
  endif
  if nargout == 0
    return;
  endif

  % Calculate error, error gradient and error Hessian 
  iter=iter+1;
  func_iter=iter;
  if nargout == 3
    [E,gradE,hessE]=iirE(x,U,V,M,Q,R,wa,Ad,Wa,[],[],[],wt,Td,Wt,[],[],[]);
  elseif nargout == 2
    [E,gradE]=iirE(x,U,V,M,Q,R,wa,Ad,Wa,[],[],[],wt,Td,Wt,[],[],[]);
    hessE=eye(N,N);
  elseif nargout == 1
    E=iirE(x,U,V,M,Q,R,wa,Ad,Wa,[],[],[],wt,Td,Wt,[],[],[]);
    gradE=zeros(N,1);
    hessE=eye(N,N);
  endif
    
endfunction

function [gx,B] = deczky1_sqp_mmse_gx(x,_vS,_U,_V,_M,_Q,_R, ...
                                      _wa,_Adu,_Adl,_wt,_Tdu,_Tdl,_wx, ...
                                      _ctol,_verbose)
 
  persistent vS U V M Q R N wa Adu Adl wt Tdu Tdl wx ctol verbose
  persistent init_complete=false

  % Initialise persistent values
  if nargin == 1
    if init_complete == false
      error("nargin==1 && init_complete==false");
    endif
  elseif nargin == 16
    % Initialise constraints
    if isempty(_vS) 
      deczky1_slb_set_empty_constraints(vS);
    else
      vS.al=_vS.al;vS.au=_vS.au;vS.tl=_vS.tl;vS.tu=_vS.tu;vS.ax=_vS.ax;
    endif
    U=_U;V=_V;M=_M;Q=_Q;R=_R;
    N=1+U+V+M+Q;
    wa=_wa;Adu=_Adu;Adl=_Adl;
    wt=_wt;Tdu=_Tdu;Tdl=_Tdl;
    wx=_wx;
    ctol=_ctol;
    verbose=_verbose;
    init_complete=true;
  else
    print_usage("[gx,B] = deczky1_sqp_mmse_gx(x, ... );");
  endif

  % Do nothing
  if nargout == 0
    return;
  endif
  if deczky1_slb_constraints_are_empty(vS)
    gx=[];
    B=[];
    return;
  endif
 
  % Find response at constraint frequencies
  if nargout == 2
    [Al,gradAl]=iirA(wa(vS.al),x,U,V,M,Q,R);
    [Au,gradAu]=iirA(wa(vS.au),x,U,V,M,Q,R);
    [Tl,gradTl]=iirT(wt(vS.tl),x,U,V,M,Q,R);
    [Tu,gradTu]=iirT(wt(vS.tu),x,U,V,M,Q,R); 
    [delAdelw,graddelAdelw]=iirdelAdelw(wx(vS.ax),x,U,V,M,Q,R); 
  else
    gradAl=[];
    Al=iirA(wa(vS.al),x,U,V,M,Q,R);
    gradAu=[];
    Au=iirA(wa(vS.au),x,U,V,M,Q,R);
    gradTl=[];
    Tl=iirT(wt(vS.tl),x,U,V,M,Q,R);
    gradTu=[];
    Tu=iirT(wt(vS.tu),x,U,V,M,Q,R);
    graddelAdelw=[];
    delAdelw=iirdelAdelw(wx(vS.ax),x,U,V,M,Q,R);
  endif

  % Construct constraint vector
  gx=[Al-Adl(vS.al);Adu(vS.au)-Au; ...
      Tl-Tdl(vS.tl);Tdu(vS.tu)-Tu; ...
      -delAdelw];

  % Construct constraint gradient matrix 
  B=[];
  if nargout == 2
    B=[gradAl;-gradAu;gradTl;-gradTu;-graddelAdelw]';
  endif

  % Show
  if verbose
    if all(gx>-ctol)
      printf("All constraints satisfied!\n");
    endif
    Ac=zeros(size(wa));  Ac(vS.al)=Al;  Ac(vS.au)=Au;
    Tc=zeros(size(wt));  Tc(vS.tl)=Tl;  Tc(vS.tu)=Tu;
    delAdelwc=zeros(size(wx)); delAdelwc(vS.ax)=delAdelw;
    deczky1_slb_show_constraints(vS,wa,Ac,wt,Tc,wx,delAdelwc);
  endif

endfunction
