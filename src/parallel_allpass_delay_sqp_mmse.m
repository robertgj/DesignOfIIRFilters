function [ak,sqp_iter,func_iter,feasible]= ...
  parallel_allpass_delay_sqp_mmse(vS,a0,au,al,dmax,V,Q,R,DD, ...
                                   wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                                   maxiter,tol,ctol,verbose)
% [ak,sqp_iter,func_iter,feasible] = ...
%   parallel_allpass_delay_sqp_mmse(vS,a0,au,al,dmax,V,Q,R,DD, ...
%                                    wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
%                                    maxiter,tol,ctol,verbose)
%
% SQP MMSE optimisation with multiple frequency constraints
% on the amplitude and group delay responses of a filter consisting of the
% parallel combination of an allpass filter and a pure delay. The allpass
% filter is defined by the real and complex conjugate pole locations.
%
% Inputs:
%   vS - structure of peak constraint frequencies {al,au,tl,tu}
%   ab0 - initial coefficient vector in the form:
%         [ Rp(1:V) rp(1:(Q/2)) thetap(1:(Q/2)) ]
%         where Rp are the radiuses of the real poles of the allpass
%         filter and {rp,thetap} the polar coordinates of a pair
%         of complex conjugate poles of the allpass filter.
%   au - upper constraints on the pole radiuses of the allpass filter
%   al - lower constraints on the pole radiuses of the allpass filter
%   dmax - limit on coefficient step size
%   V - number of real poles of the allpass filter 
%   Q - number of complex poles of the allpass filter
%   R - decimation factor. The poles, pk, are roots of [z^R-pk].
%   DD - samples of delay in the delay branch
%   wa - angular frequencies of desired pass-band squared amplitude response
%        in [0,pi]. 
%   Asqd - desired pass-band squared amplitude response
%   Asqdu,Asqdl - upper and lower mask for the desired pass-band squared
%               amplitude response
%   Wa - pass-band squared amplitude response weight at each frequency
%   wt - angular frequencies of desired pass-band group delay response
%        in [0,pi]. 
%   Td - desired pass-band group delay response
%   Tdu,Tdl - upper and lower mask for the pass-band group delay response
%   Wt - pass-band group delay response weight at each frequency
%   maxiter - maximum number of SQP iterations
%   tol - tolerance on coefficient update
%   ctol - tolerance on constraints
%   verbose -
%
% Outputs:
%   ak - filter design 
%   sqp_iter - number of SQP iterations
%   func_iter - number of function calls
%   feasible - abk satisfies the constraints 

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

%
% Sanity checks
%
if nargin != 23
  print_usage("[ak,sqp_iter,func_iter,feasible]= ...\n\
    parallel_allpass_delay_sqp_mmse(vS,a0,au,al,dmax,V,Q,R,DD, ...\n\
                                    wa,Asqd,Asqdu,Asqdl,Wa, ...\n\
                                    wt,Td,Tdu,Tdl,Wt, ...\n\
                                    maxiter,tol,ctol,verbose)");
endif
wa=wa(:);
Nwa=length(wa);
wt=wt(:);
Nwt=length(wt);
Na=V+Q;

if isempty(vS)
  vS=parallel_allpass_delay_slb_set_empty_constraints();
else
  if ((numfields(vS) ~= 4) ...
      || ~isfield(vS,"al") || ~isfield(vS,"au") ...
      || ~isfield(vS,"tl") || ~isfield(vS,"tu"))
    error("numfields(vS)=%d, expected 4 (al,au,tl and tu)",numfields(vS));
  endif
endif

if length(a0) ~= Na
  error("Expected length(a0)(%d) == V(%d)+Q(%d)",length(a0),V,Q);
endif
if length(au) ~= Na
  error("Expected length(au)(%d) == length(a0)(%d)",length(au),Na);
endif
if length(al) ~= Na
  error("Expected length(al(%d) == length(a0)(%d)",length(al),Na);
endif
if Nwa ~= length(Asqd)
  error("Expected length(wa)(%d) == length(Asqd)(%d)",Nwa,length(Asqd));
endif  
if (~isempty(vS.au)) && (Nwa ~= length(Asqdu))
  error("Expected length(wa)(%d) == length(Asqdu)(%d)",Nwa,length(Asqdu));
endif  
if (~isempty(vS.al)) && (Nwa ~= length(Asqdl))
  error("Expected length(wa)(%d) == length(Asqdl)(%d)",Nwa,length(Asqdl));
endif  
if Nwa ~= length(Wa)
  error("Expected length(wa)(%d) == length(Wa)(%d)",Nwa,length(Wa));
endif
if Nwt ~= length(Td)
  error("Expected length(wt)(%d) == length(Td)(%d)",Nwt,length(Td));
endif  
if (~isempty(vS.tu)) && (Nwt ~= length(Tdu))
  error("Expected length(wt)(%d) == length(Tdu)(%d)",Nwt,length(Tdu));
endif  
if (~isempty(vS.tl)) && (Nwt ~= length(Tdl))
  error("Expected length(wt)(%d) == length(Tdl)(%d)",Nwt,length(Tdl));
endif  
if Nwt ~= length(Wt)
  error("Expected length(wt)(%d) == length(Wt)(%d)",Nwa,length(Wt));
endif

% Initialise
ak=a0(:);
au=au(:);
al=al(:);
onesa=ones(1,Na);
feasible=false;
sqp_iter=0;func_iter=0;loop_iter=0;

% Initialise objective function persistent constants
[Esq,gradEsq,diagHessEsq]=...
  parallel_allpass_delay_sqp_mmse_fx(ak,V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);

% Initialise the approximation to the Hessian for the BFGS update
W=diag(diagHessEsq);
invW=inv(W);

% Initialise constraint function persistent constants
gx=parallel_allpass_delay_sqp_mmse_gx(ak,vS,V,Q,R,DD, ...
                                      wa,Asqdu,Asqdl,wt,Tdu,Tdl,ctol,false);

% Initial check on constraints. Do not need to proceed if they are satisfied.
if (isempty(gx) == false) && all(gx > -ctol)
  sqp_lm=[];
  sqp_iter=0;
  [~,~,~,func_iter] = parallel_allpass_delay_sqp_mmse_fx();
  feasible=true;
  printf("parallel_allpass_delay_sqp_mmse():gx constraints satisfied by a0!\n");
  return;
endif
  
%
% Step 2 : Solve for the Lagrange multipliers at the active constraints  
%
% Sequential Quadratic Programming (SQP) loop  
a=[];Esq=inf;sqp_lm=[];func_iter=0;sqp_iter=0;liter=0;feasible=false;
try
  [a,Esq,sqp_lm,sqp_iter,liter,feasible] = ...
  sqp_bfgs(ak, ...
           @parallel_allpass_delay_sqp_mmse_fx, ...
           @parallel_allpass_delay_sqp_mmse_gx,
           "armijo_kim",al,au,dmax,{W,invW},"bfgs",tol,maxiter,verbose);
  [~,~,~,func_iter] = parallel_allpass_delay_sqp_mmse_fx();
catch
  a=[];
  Esq=inf;
  sqp_lm=[];
  [~,~,~,func_iter] = parallel_allpass_delay_sqp_mmse_fx();
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
  ak=a;
  [~,~,~,func_iter] = parallel_allpass_delay_sqp_mmse_fx();
elseif sqp_iter>=maxiter
  warning("Maximum SQP iterations reached (%d). Bailing out!\n", sqp_iter);
  printf("a=[ ");printf("%f ",a);printf("]';\n");
else
  warning("Solution not feasible after %d SQP iterations!\n", sqp_iter); 
endif

endfunction

function [Esq,gradEsq,diagHessEsq,func_iter] = ...
  parallel_allpass_delay_sqp_mmse_fx(a,_V,_Q,_R,_DD,_wa,_Asqd,_Wa,_wt,_Td,_Wt);
  persistent N V Q R DD wa Asqd Wa wt Td Wt
  persistent func_iter=0
  persistent init_complete=false

  % Initialise persistent (constant) values
  if nargin == 1
    if init_complete == false
      error("nargin==1 && init_complete==false");
    endif
  elseif nargout == 4
    % Hack to avoid a global for func_iter
    Esq=inf;gradEsq=[];diagHessEsq=[];
    return;
  elseif nargin == 11
    V=_V;Q=_Q;R=_R;DD=_DD
    N=V+Q;
    wa=_wa;Asqd=_Asqd;Wa=_Wa;
    wt=_wt;Td=_Td;Wt=_Wt;
    func_iter=0;
    init_complete=true;
  else
    print_usage("[Esq,gradEsq,diagHessEsq,func_iter]=...\n\
      parallel_allpass_delay_sqp_mmse(x,...);");
  endif
  if nargout == 0
    return;
  endif

  % Calculate error, error gradient and error Hessian 
  func_iter=func_iter+1;
  if nargout == 3
    [Esq,gradEsq,diagHessEsq]=...
      parallel_allpass_delayEsq(a,V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
  elseif nargout == 2
    [Esq,gradEsq]=parallel_allpass_delayEsq(a,V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
    diagHessEsq=ones(size(gradEsq));
  elseif nargout == 1
    Esq=parallel_allpass_delayEsq(a,V,Q,R,DD,wa,Asqd,Wa,wt,Td,Wt);
    gradEsq=zeros(1,N);
    diagHessEsq=ones(size(gradEsq));
  endif
  gradEsq=gradEsq(:);
  diagHessEsq=diagHessEsq(:);
endfunction

function [gx,B] = parallel_allpass_delay_sqp_mmse_gx ...
  (a,_vS,_V,_Q,_R,_DD,_wa,_Asqdu,_Asqdl,_wt,_Tdu,_Tdl,_ctol,_verbose)
 
  persistent vS V Q R DD N wa Asqdu Asqdl wt Tdu Tdl
  persistent ctol verbose
  persistent init_complete=false

  % Initialise persistent values
  if nargin == 1
    if init_complete == false
      error("nargin==1 && init_complete==false");
    endif
  elseif nargin == 14
    % Initialise constraints
    if isempty(_vS) 
      parallel_allpass_delay_slb_set_empty_constraints(vS);
    else
      vS.al=_vS.al;vS.au=_vS.au;
      vS.tl=_vS.tl;vS.tu=_vS.tu;
    endif
    V=_V;Q=_Q;R=_R;DD=_DD;N=V+Q;
    wa=_wa;Asqdu=_Asqdu;Asqdl=_Asqdl;
    wt=_wt;Tdu=_Tdu;Tdl=_Tdl;
    ctol=_ctol;
    verbose=_verbose;
    init_complete=true;
  else
    print_usage("[gx,B] = parallel_allpass_delay_sqp_mmse_gx(x, ... );");
  endif
  % Do nothing
  if nargout == 0
    return;
  endif
  if parallel_allpass_delay_slb_constraints_are_empty(vS)
    gx=[];
    B=[];
    return;
  endif
 
  % Find response at constraint frequencies
  if nargout == 2
    [Asql,gradAsql]=parallel_allpass_delayAsq(wa(vS.al),a,V,Q,R,DD);
    [Asqu,gradAsqu]=parallel_allpass_delayAsq(wa(vS.au),a,V,Q,R,DD);
    [Tl,gradTl]=parallel_allpass_delayT(wt(vS.tl),a,V,Q,R,DD);
    [Tu,gradTu]=parallel_allpass_delayT(wt(vS.tu),a,V,Q,R,DD); 
  else
    gradAsql=[];
    Asql=parallel_allpass_delayAsq(wa(vS.al),a,V,Q,R,DD);
    gradAsqu=[];
    Asqu=parallel_allpass_delayAsq(wa(vS.au),a,V,Q,R,DD);
    gradTl=[];
    Tl=parallel_allpass_delayT(wt(vS.tl),a,V,Q,R,DD);
    gradTu=[];
    Tu=parallel_allpass_delayT(wt(vS.tu),a,V,Q,R,DD);
  endif

  % Construct constraint vector
  gx=[Asql-Asqdl(vS.al);Asqdu(vS.au)-Asqu;Tl-Tdl(vS.tl);Tdu(vS.tu)-Tu];

  % Construct constraint gradient matrix 
  B=[];
  if nargout == 2
    B=[gradAsql;-gradAsqu;gradTl;-gradTu]';
  endif

  % Show
  if verbose
    if all(gx>-ctol)
      printf("All constraints satisfied!\n");
    endif
    parallel_allpass_delay_slb_show_constraints(vS,wa,Asqu,Asql,wt,Tu,Tl);
  endif

endfunction
