function [k,c,sqp_iter,func_iter,feasible]= ...
         schurOneMlattice_sqp_mmse(vS,k0,epsilon0,p0,c0, ...
                                   kc_u,kc_l,kc_active,dmax, ...
                                   wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                                   wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose)
% [k,c,sqp_iter,func_iter,feasible] = ...
%   schurOneMlattice_sqp_mmse(vS,k0,epsilon0,p0,c0, ...
%                             kc_u,kc_l,kc_active,dmax, ...
%                             wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                             wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose)
%
% SQP MMSE optimisation of a one-multiplier Schur lattice filter with
% constraints on the amplitude, and low pass group delay responses. 
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu}
%   k0 - initial allpass filter multipliers
%   epsilon0,p0 - state scaling coefficients. These have no effect on the
%                 response but can improve numerical accuracy.
%   c0 - initial numerator tap coefficients
%   kc_u,kc_l - upper and lower bounds on the allpass filter coefficients
%   kc_active - indexes of elements of coefficients being optimised
%   dmax - maximum coefficient step-size
%   wa - angular frequencies of squared-magnitude response in [0,pi]. 
%   Asqd - desired squared amplitude response
%   Asqdu,Asqdl - upper/lower mask for the desired squared amplitude response
%   Wa - squared amplitude response weight at each frequency
%   wt - angular frequencies of delay response in [0,pi]. 
%   Td - desired passband group delay response
%   Tdu,Tdl - upper/lower mask for the desired group delay response
%   Wt - group delay response weight at each frequency
%   wp - angular frequencies of phase response 
%   Pd - desired phase response
%   Pdu,Pdl - upper/lower mask for the desired phase response
%   Wp - phase response weight at each frequency
%   maxiter - maximum number of SQP iterations
%   tol - tolerance
%   verbose - 
%
% Outputs:
%   k,c - filter design
%   sqp_iter - number of SQP iterations
%   func_iter - number of function calls
%   feasible - design satisfies the constraints 

% Copyright (C) 2017 Robert G. Jenssen
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
    print_usage("[k,c,sqp_iter,func_iter,feasible]= ...\n\
      schurOneMlattice_sqp_mmse(vS,k0,epsilon0,p0,c0, ...\n\
                                kc_u,kc_l,kc_active,dmax, ...\n\
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
  if isempty(wa) && isempty(wt) && isempty(wp)
    error("wa, wt and wp empty");
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

  %
  % Sanity checks on coefficient vectors
  %
  Nk=length(k0);
  Nc=length(c0);
  Nkc=Nk+Nc;
  if (Nkc==0)
    error("Coefficient vectors are empty");
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
  % Initialise
  %
  % Coefficient vector being optimised
  kc0=[k0(:);c0(:)];
  xkc0=kc0(kc_active);
  xkcu=kc_u(kc_active);
  xkcl=kc_l(kc_active);
  % Initialise objective function persistent constants
  [E,gradE,hessE]=schurOneMlattice_sqp_mmse_fx(xkc0, ...
                                               k0,epsilon0,p0,c0,kc_active, ...
                                               wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  % Initialise the approximation to the Hessian for the BFGS update
  W=diag(diag(hessE));
  invW=inv(W);
  % Initialise constraint function persistent constants
  gx=schurOneMlattice_sqp_mmse_gx(xkc0,vS,k0,epsilon0,p0,c0,kc_active, ...
                                  wa,Asqdu,Asqdl,wt,Tdu,Tdl, ...
                                  wp,Pdu,Pdl,tol,false);
  % Initial check on constraints. Do not need to proceed if they are satisfied.
  if (isempty(gx) == false) && all(gx > -tol)
    k=k0;
    c=c0;
    sqp_lm=[];
    sqp_iter=0;
    [~,~,~,func_iter] = schurOneMlattice_sqp_mmse_fx();
    feasible=true;
    printf("schurOneMlattice_sqp_mmse() : k0,c0 satisfies constraints\n");
    return;
  endif
  
  %
  % Sequential Quadratic Programming (SQP) loop
  %
  try
    xkc=[];E=inf;sqp_lm=[];sqp_iter=0;func_iter=0;loop_iter=0;feasible=false;
    [xkc,E,sqp_lm,sqp_iter,loop_iter,feasible] = ...
      sqp_bfgs(xkc0, ...
               @schurOneMlattice_sqp_mmse_fx,@schurOneMlattice_sqp_mmse_gx, ...
               "armijo_kim",xkcl,xkcu,dmax,{W,invW},"bfgs", ...
               tol,maxiter,verbose);
    [~,~,~,func_iter] = schurOneMlattice_sqp_mmse_fx();
  catch
    k=[];c=[];
    sqp_lm=[];
    [~,~,~,func_iter] = schurOneMlattice_sqp_mmse_fx();
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
  kc1=kc0;
  kc1(kc_active)=xkc;
  k=kc1(1:Nk);
  c=kc1((Nk+1):end);
  if verbose
    printf("k=[ ");printf("%f ",k');printf("]';\n");
    printf("c=[ ");printf("%f ",c');printf("]';\n");
  endif
  if feasible
    printf("Feasible MMSE solution after %d SQP iterations\n", sqp_iter);
  elseif sqp_iter>=maxiter
    warning("Maximum SQP iterations reached (%d). Bailing out!\n", sqp_iter);
  else
    warning("Solution not feasible after %d SQP iterations!\n", sqp_iter); 
  endif

endfunction

function [E,gradE,hessE,func_iter] = ...
         schurOneMlattice_sqp_mmse_fx(xkc, ...
                                      _k0,_epsilon0,_p0,_c0,_kc_active, ...
                                      _wa,_Asqd,_Wa,_wt,_Td,_Wt,_wp,_Pd,_Wp)
         
  persistent k0 epsilon0 p0 c0 kc_active wa Asqd Wa wt Td Wt wp Pd Wp
  persistent func_iter=0
  persistent init_done=false

  % Initialise persistent (constant) values
  if nargin == 15
    k0=_k0;epsilon0=_epsilon0;p0=_p0;c0=_c0;kc_active=_kc_active;
    wa=_wa;Asqd=_Asqd;Wa=_Wa;wt=_wt;Td=_Td;Wt=_Wt;wp=_wp;Pd=_Pd;Wp=_Wp;
    func_iter=0;
    init_done=true;
  elseif nargout == 4
    % Hack to avoid a global for func_iter
    E=inf;gradE=[];hessE=[];
    return;
  elseif nargin == 1
    if init_done == false
      error("init_done==false");
    endif
  else
    print_usage("[E,gradE,hessE] = schurOneMlattice_sqp_mmse_fx(xkc);\n\
schurOneMlattice_sqp_mmse_fx(xkc0,k0,epsilon0,p0,c0,kc_active, ...\n\
                             wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);\n\
[~,~,~,func_iter] = schurOneMlattice_sqp_mmse_fx(xkc);");
  endif

  % Initialise k and c
  Nk=length(k0);
  kc=[k0(:);c0(:)];
  kc(kc_active)=xkc;
  k=kc(1:Nk);
  c=kc((Nk+1):end);
  
  % Calculate error, error gradient and diagonal of error Hessian
  Nkc_active=length(kc_active);
  if nargout == 3
    [E,gradE,diagHessE]=...
      schurOneMlatticeEsq(k,epsilon0,p0,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    gradE=gradE(:);
    gradE=gradE(kc_active);
    hessE=diag(diagHessE(kc_active));
  elseif nargout == 2
    [E,gradE]=schurOneMlatticeEsq(k,epsilon0,p0,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    gradE=gradE(:);
    gradE=gradE(kc_active);
    hessE=eye(Nkc_active,Nkc_active);
  elseif nargout == 1
    E=schurOneMlatticeEsq(k,epsilon0,p0,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    gradE=zeros(Nkc_active,1);
    hessE=eye(Nkc_active,Nkc_active);
  endif
    
  func_iter=func_iter+1;
  
endfunction

function [gx,B]=...
         schurOneMlattice_sqp_mmse_gx(xkc, ...
                                      _vS,_k0,_epsilon0,_p0,_c0,_kc_active, ...
                                      _wa,_Asqdu,_Asqdl,_wt,_Tdu,_Tdl, ...
                                      _wp,_Pdu,_Pdl,_tol,_verbose)
 
  persistent vS k0 epsilon0 p0 c0 kc_active
  persistent wa Asqdu Asqdl wt Tdu Tdl wp Pdu Pdl tol verbose
  persistent init_done=false

  % Initialise persistent values
  if nargin == 18
    % Initialise constraints
    if isempty(_vS) 
      schurOneMlattice_slb_set_empty_constraints(vS);
    else
      vS.al=_vS.al;vS.au=_vS.au;
      vS.tl=_vS.tl;vS.tu=_vS.tu;
      vS.pl=_vS.pl;vS.pu=_vS.pu;
    endif
    k0=_k0;epsilon0=_epsilon0;p0=_p0;c0=_c0;kc_active=_kc_active;
    wa=_wa;Asqdu=_Asqdu;Asqdl=_Asqdl;wt=_wt;Tdu=_Tdu;Tdl=_Tdl;
    wp=_wp;Pdu=_Pdu;Pdl=_Pdl;tol=_tol;verbose=_verbose;
    init_done=true;
  elseif nargin == 1
    if init_done == false
      error("init_done==false");
    endif
  else
    print_usage("[gx,B] = schurOneMlattice_sqp_mmse_gx(kc); \n\
schurOneMlattice_sqp_mmse_gx(xkc,vS,k0,epsilon0,p0,c0,kc_active, ...\n\
                             wa,Asqdu,Asqdl,wt,Tdu,Tdl, ...\n\
                             wp,Pdu,Pdl,tol,verbose)");
  endif

  % Do nothing
  if schurOneMlattice_slb_constraints_are_empty(vS)
    gx=[];
    B=[];
    return;
  endif

  % Initialise k and c
  Nk=length(k0);
  kc=[k0(:);c0(:)];
  kc(kc_active)=xkc;
  k=kc(1:Nk);
  c=kc((Nk+1):end);
  
  % Find response at constraint frequencies
  if nargout == 2
    [Asql,gradAsql]=schurOneMlatticeAsq(wa(vS.al),k,epsilon0,p0,c);
    [Asqu,gradAsqu]=schurOneMlatticeAsq(wa(vS.au),k,epsilon0,p0,c);
    [Tl,gradTl]=schurOneMlatticeT(wt(vS.tl),k,epsilon0,p0,c);
    [Tu,gradTu]=schurOneMlatticeT(wt(vS.tu),k,epsilon0,p0,c); 
  else
    Asql=schurOneMlatticeAsq(wa(vS.al),k,epsilon0,p0,c);
    Asqu=schurOneMlatticeAsq(wa(vS.au),k,epsilon0,p0,c);
    Tl=schurOneMlatticeT(wt(vS.tl),k,epsilon0,p0,c);
    Tu=schurOneMlatticeT(wt(vS.tu),k,epsilon0,p0,c);
  endif
  % Work-around for phase unwrapping
  if nargout == 2
    [P,gradP]=schurOneMlatticeP(wp,k,epsilon0,p0,c); 
    Pl=P(vS.pl);gradPl=gradP(vS.pl,:);
    Pu=P(vS.pu);gradPu=gradP(vS.pu,:);
  else
    P=schurOneMlatticeP(wp,k,epsilon0,p0,c);
    Pl=P(vS.pl);
    Pu=P(vS.pu);
  endif

  % Construct constraint vector
  gx=[Asql-Asqdl(vS.al); Asqdu(vS.au)-Asqu; ...
          Tl-Tdl(vS.tl);   Tdu(vS.tu)-Tu; ...
          Pl-Pdl(vS.pl);   Pdu(vS.pu)-Pu];

  % Construct constraint gradient matrix
  if nargout==2
    B=[gradAsql; -gradAsqu; gradTl; -gradTu; gradPl; -gradPu];
    B=B(:,kc_active)';
  else
    B=[];
  endif
  
  % Show
  if verbose
    if all(gx>-tol)
      printf("All constraints satisfied!\n");
    endif
  endif

endfunction
