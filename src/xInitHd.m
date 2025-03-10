function [X0,FVEC]=xInitHd(XI,U,V,M,Q,R, ...
                           wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,maxiter,tol)
% function [X0,FVEC]=xInitHd(XI,U,V,M,Q,R, ...
%                            wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,maxiter,tol)
% Derive an IIR filter with unconstrained optimisation of the
% transfer function polynomial coefficients sand the "WISE" 
% barrier function. 
% Inputs:
%  XI - initial filter design
%  U - number of real zeros
%  V - number of real poles
%  M - number of complex zeros (M/2 conjugate pairs)
%  Q - number of complex poles (Q/2 conjugate pairs)
%  R - decimation factor
%  wa - angular frequencies of desired pass-band magnitude response (fs=2pi)
%  Ad - desired pass-band magnitude response
%  Wa - desired pass-band magnitude response weighting function
%  ws - angular frequencies of desired stop-band magnitude response
%  Sd - desired stop-band magnitude response
%  Ws - desired stop-band magnitude response weighting function
%  wt - angular frequencies of desired group delay response
%  Td - desired group delay response
%  Wt - desired group delay response weighting function
%  wp - angular frequencies of desired phase response
%  Pd - desired phase response
%  Wp - desired phase response weighting function
%  maxiter - 
%  tol - tolerance for function and x value differences
% Outputs:
%  X0 - filter design as [gain, real zero radii, real pole radii,
%       complex conjugate zero radii, complex conjugate zero angles,
%       complex conjugate pole radii, complex conjugate pole angles]
%  FVEC - minimum value from fminunc
%
% NOTE: THE USE OF SIMPLE TRAPEZOIDAL INTEGRATION OF THE ERROR
% FUNCTION REQUIRES THAT THE FREQUENCIES BE CONTIGUOUS. USE THE 
% WEIGHT TO MAKE GAPS IN FREQUENCY FOR TRANSITION BANDS.
%  
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

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

if nargin~=20
  print_usage(["[X0,FVEC]=xInitHd(XI,U,V,M,Q,R, ..\n", ...
 "    wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp,maxiter,tol)"]);
endif
% Sanity checks
if ((length(wa) ~= length(Ad)) || (length(wa) ~= length(Wa)))
  error("Expect wa, Ad and Wa to have equal length!");
endif
if ((length(ws) ~= length(Sd)) || (length(ws) ~= length(Ws)))
  error("Expect ws, Sd and Ws to have equal length!");
endif
if ((length(wt) ~= length(Td)) || (length(wt) ~= length(Wt)))
  error("Expect wt, Td and Wt to have equal length!");
endif
if ((length(wp) ~= length(Pd)) || (length(wp) ~= length(Wp)))
  error("Expect wp, Pd and Wp to have equal length!");
endif

% Initialisation
WISEJ_X(XI,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp);
opt = optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);

% Unconstrained minimisation
[X0, FVEC, INFO, OUTPUT] = fminunc(@WISEJ_X,XI,opt);
if (INFO == 1)
   printf("Converged to a solution point.\n");
elseif (INFO == 2)
  printf("Last relative step size was less that TolX.\n");
elseif (INFO == 3)
  printf("Last relative decrease in function value was less than TolF.\n");
elseif (INFO == 0)
  printf("Iteration limit exceeded.\n");
elseif (INFO == -3)
  printf("The trust region radius became excessively small.\n");
else
  error("Unknown INFO value.\n");
endif
printf("Function value=%f\n", FVEC);
printf("fminunc iterations=%d\n", OUTPUT.iterations);
printf("fminunc successful=%d??\n", OUTPUT.successful);
printf("fminunc funcCount=%d\n", OUTPUT.funcCount);
endfunction

function E=WISEJ_X(X,_U,_V,_M,_Q,_R,...
                   _wa,_Ad,_Wa,_ws,_Sd,_Ws,_wt,_Td,_Wt,_wp,_Pd,_Wp)

persistent U V M Q R N wa Ad Wa ws Sd Ws wt Td Wt wp Pd Wp

% Initialisation
E=0;
if (nargin == 18)
  U = _U; V = _V; M = _M; Q = _Q; R = _R;
  wa = _wa(:); Ad = _Ad(:); Wa = _Wa(:);
  ws = _ws(:); Sd = _Sd(:); Ws = _Ws(:);
  wt = _wt(:); Td = _Td(:); Wt = _Wt(:);
  wp = _wp(:); Pd = _Pd(:); Wp = _Wp(:);
  if isempty(X)
    return;
  endif
endif

% Sanity check
if (length(X) ~= (1+U+V+M+Q))
  error("Expected length(X) == (1+U+V+M+Q)!");
endif
% Find the error of the amplitude response 
if isempty(R), error("R empty!"); 
endif

% Find error in amplitude and delay
EAT=iirE(X,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp);

% Heuristics for the barrier function. Ignore decimation, R. 
lambda = 0.001;
rho=31/32;
t = 300;
m = V+Q;
if (m > 0)
  % Calculate barrier function
  cplxPR=(1+U+V+M+1):(1+U+V+M+(Q/2));
  cplxPPhi=(1+U+V+M+(Q/2)+1):(1+U+V+M+Q);
  p=[X((1+U+1):(1+U+V));...
     X(cplxPR).*exp( j*X(cplxPPhi));...
     X(cplxPR).*exp(-j*X(cplxPPhi))];
  p=sort(p(:),"descend");
  p=p/rho;
  A=diag(p)+diag(ones(V+Q-1,1),-1);
  b=[1;zeros(V+Q-1,1)];
  c=[zeros(1,V+Q-1), 1];
  d = zeros(m,1);
  cA_tk = c*(A^(t-1));
  for k=1:m
    d(k) = cA_tk*b;
    cA_tk = cA_tk*A;
  endfor
  d=real(d);
  EJ = sum(d.*d);
else
  EJ = 0;
endif

% Done
E = ((1-lambda)*EAT) + (lambda*EJ);

endfunction
