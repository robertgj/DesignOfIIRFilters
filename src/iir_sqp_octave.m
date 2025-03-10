function [x,E,sqp_iter,func_iter,feasible] = ...
  iir_sqp_octave(x0,U,V,M,Q,R,wa,Ad,Wa,wt,Td,Wt,maxiter,tol,verbose)
% [x,E,sqp_iter,func_iter,feasible] = ...
%   iir_sqp_octave(x0,U,V,M,Q,R,wa,Ad,Wa,wt,Td,Wt, maxiter,tol,verbose)
%
% Call the Octave sqp function.
%
% Inputs:
%   x0 - initial coefficient vector in the form:
%         [ k;                          ...
%           zR(1:U);     pR(1:V);       ...
%           abs(z(1:Mon2)); angle(z(1:Mon2)); ...
%           abs(p(1:Qon2)); angle(p(1:Qon2)) ];
%         where k is the gain coefficient, zR and pR represent real
%         zeros  and poles and z and p represent conjugate zero and
%         pole pairs. 
%   U - number of real zeros
%   V - number of real poles
%   M - number of conjugate zero pairs
%   Q - number of conjugate pole pairs
%   R - decimation factor, pole pairs are for z^R
%   wa - angular frequencies of desired amplitude response in [0,pi].
%        Assumed to be equally spaced
%   Ad - desired amplitude response
%   Wa - amplitude weight (a single value or a vector)
%   wt - angular frequencies of the desired group delay response
%   Td - desired group delay response vector
%   Wt - group delay weight (a single value or a vector)
%   maxiter - maximum number of SQP iterations
%   tol - tolerance
%   verbose -
%   
% Outputs:
%   x - filter design 
%   E - error value at x
%   sqp_iter - number of SQP iterations
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

if (nargin~=15) || (nargout ~= 5)
  print_usage(["[x,E,sqp_iter,func_iter,feasible] = ...\n", ...
 "        iir_sqp_octave(x0,U,V,M,Q,R,wa,Ad,Wa,wt,Td,Wt,maxiter,tol,verbose)"]);
endif

% Initialise iir_E, etc persistent values (rather than use globals)
iir_E([],U,V,M,Q,R,wa,Ad,Wa,wt,Td,Wt);
iir_gradE([],U,V,M,Q,R,wa,Ad,Wa,wt,Td,Wt);
iir_hessE([],U,V,M,Q,R,wa,Ad,Wa,wt,Td,Wt);

% Upper and lower constraints on x
[xl, xu]=xConstraints(U,V,M,Q);

% Octave SQP
x=[];E=0;info=0;sqp_iter=0;func_iter=0;sqp_lm=[];feasible=false;x0=x0(:);
try
  [x,E,info,sqp_iter,func_iter,sqp_lm] = ...
    sqp(x0,{@iir_E,@iir_gradE,@iir_hessE_diag},[],[],xl,xu,maxiter,tol);
catch
  err=lasterror();
  warning("Caught exception!\n%s\n", err.message);
  for e=1:length(err.stack)
    warning("Called %s at line %d\n", ...
           err.stack(e).name,err.stack(e).line);
  endfor
end_try_catch

% Check info 
if info==101
  feasible=true;
elseif info==102
  feasible=false;
  warning("BFGS update failed");
elseif info==103
  feasible=false;
  warning("Maximum number of iterations reached");
elseif info==104
  feasible=false;
  warning("The stepsize, delta X, is less than tol*norm(x)");
else
  feasible=false;
  warning("Unknown error: info=%d",info);
endif
endfunction

function E = iir_E(x,_U,_V,_M,_Q,_R,_wa,_Ad,_Wa,_wt,_Td,_Wt)
  persistent U V M Q R wa Ad Wa wt Td Wt
  if nargin~=1 && nargin~=12
    print_usage("E=iir_E(x[,_U,_V,_M,_Q,_R,_wa,_Ad,_Wa,_wt,_Td,_Wt])");
  elseif nargin == 12
    E=inf;
    U=_U;V=_V;M=_M;Q=_Q;R=_R;
    wa=_wa;Ad=_Ad;Wa=_Wa;wt=_wt;Td=_Td;Wt=_Wt;
  else
    EA = Aerror(x,U,V,M,Q,R,wa,Ad,Wa);
    if ~isempty(wt)
      ET = Terror(x,U,V,M,Q,R,wt,Td,Wt);
    else
      ET = 0;
    endif
    E=EA+ET;
  endif
endfunction

function gradE = iir_gradE(x,_U,_V,_M,_Q,_R,_wa,_Ad,_Wa,_wt,_Td,_Wt)
  persistent U V M Q R wa Ad Wa wt Td Wt 
  if nargin~=1 && nargin~=12
    print_usage("gradE=iir_gradE(x[,_U,_V,_M,_Q,_R,_wa,_Ad,_Wa,_wt,_Td,_Wt])");
  elseif nargin == 12
    E=inf;
    U=_U;V=_V;M=_M;Q=_Q;R=_R;
    wa=_wa;Ad=_Ad;Wa=_Wa;wt=_wt;Td=_Td;Wt=_Wt;
  else
    [EA,gradEA] = Aerror(x,U,V,M,Q,R,wa,Ad,Wa);
    if ~isempty(wt)
      [ET,gradET] = Terror(x,U,V,M,Q,R,wt,Td,Wt);
    else
      ET = 0;
      gradET = zeros(rows(gradEA),columns(gradEA));
    endif
    gradE=gradEA+gradET;
    gradE=gradE(:);
  endif
endfunction

function hessE = iir_hessE(x,_U,_V,_M,_Q,_R,_wa,_Ad,_Wa,_wt,_Td,_Wt)
  persistent U V M Q R wa Ad Wa wt Td Wt
  if nargin~=1 && nargin~=12
    print_usage("hessE=iir_hessE(x[,_U,_V,_M,_Q,_R,_wa,_Ad,_Wa,_wt,_Td,_Wt,_tol])");
  elseif nargin == 12
    E=inf;
    U=_U;V=_V;M=_M;Q=_Q;R=_R;
    wa=_wa;Ad=_Ad;Wa=_Wa;wt=_wt;Td=_Td;Wt=_Wt;
  else
    [EA,gradEA,hessEA] = Aerror(x,U,V,M,Q,R,wa,Ad,Wa);
    if ~isempty(wt)
      [ET,gradET,hessET] = Terror(x,U,V,M,Q,R,wt,Td,Wt);
    else
      ET = 0;
      gradET = zeros(rows(gradEA),columns(gradEA));
      hessET = zeros(rows(hessEA),columns(hessEA));
    endif
    hessE=hessEA+hessET;
  endif
endfunction

function hessE_diag = iir_hessE_diag(x)
  hessE = iir_hessE(x);
  hessE_diag = diag(diag(hessE));
endfunction
