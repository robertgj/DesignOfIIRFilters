function [E,gradE,hessE]=iirE(x,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp)
% [E,gradE,hessE]=iirE(x,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp)
%
% Inputs:
%   x - coefficient vector in the form:
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
%   wa - angular frequencies of desired pass-band amplitude response in [0,pi]
%   Ad - desired pass-band amplitude response
%   Wa - pass-band amplitude weight vector
%   ws - angular frequencies of desired stop-band amplitude response 
%   Sd - desired stop-band amplitude response
%   Ws - stop-band amplitude weight vector
%   wt - angular frequencies of the desired group delay response
%   Td - desired group delay response 
%   Wt - group delay weight vector
%   wp - angular frequencies of the desired phase response
%   Pd - desired phase response 
%   Wp - phase response weight vector
%   
% Outputs:
%   E - the error value at x
%   gradE - gradient of the error value at x
%   hessE - Hessian of the error value at x

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

if nargout>3 || nargin!=18
  print_usage("[E,gradE,hessE]=iirE(x,U,V,M,Q,R,wa,Ad,Wa,ws,Sd,Ws,wt,Td,Wt,wp,Pd,Wp)");
endif

N=1+U+V+M+Q;
if N!=length(x)
  error("Expected length(x)==(1+U+V+M+Q)!");
endif

if nargout==1
  if (isempty(wa))
    EA = 0;
  else
    EA = Aerror(x,U,V,M,Q,R,wa,Ad,Wa);
  endif
  if (isempty(ws))
    ES = 0;
  else
    ES = Aerror(x,U,V,M,Q,R,ws,Sd,Ws);
  endif
  if (isempty(wt))
    ET = 0;
  else
    ET = Terror(x,U,V,M,Q,R,wt,Td,Wt);
  endif
  if (isempty(wp))
    EP = 0;
  else
    EP = Perror(x,U,V,M,Q,R,wp,Pd,Wp);
  endif
  E = EA + ES + ET + EP;
elseif nargout==2
  if (isempty(wa))
    EA = 0;
    gradEA = zeros(1,N);
  else
    [EA,gradEA] = Aerror(x,U,V,M,Q,R,wa,Ad,Wa);
  endif
  if (isempty(ws))
    ES = 0;
    gradES = zeros(1,N);
  else
    [ES,gradES] = Aerror(x,U,V,M,Q,R,ws,Sd,Ws);
  endif
  if (isempty(wt))
    ET = 0;
    gradET = zeros(1,N);
  else
    [ET,gradET] = Terror(x,U,V,M,Q,R,wt,Td,Wt);
  endif
  if (isempty(wp))
    EP = 0;
    gradEP = zeros(1,N);
  else
    [EP,gradEP] = Perror(x,U,V,M,Q,R,wp,Pd,Wp);
  endif
  E = EA + ES + ET + EP;
  gradE = gradEA + gradES + gradET + gradEP;
  gradE = gradE(:);
elseif nargout==3
  if isempty(wa)
    EA = 0;
    gradEA = zeros(1,N);
    hessEA = zeros(N,N);
  else
    [EA,gradEA,hessEA] = Aerror(x,U,V,M,Q,R,wa,Ad,Wa);
  endif
  if isempty(ws)
    ES = 0;
    gradES = zeros(1,N);
    hessES = zeros(N,N);
  else
    [ES,gradES,hessES] = Aerror(x,U,V,M,Q,R,ws,Sd,Ws);
  endif
  if (isempty(wt))
    ET = 0;
    gradET = zeros(1,N);
    hessET = zeros(N,N);
  else
    [ET,gradET,hessET] = Terror(x,U,V,M,Q,R,wt,Td,Wt);
  endif
  if isempty(wp)
    EP = 0;
    gradEP = zeros(1,N);
    hessEP = zeros(N,N);
  else
    [EP,gradEP,hessEP] = Perror(x,U,V,M,Q,R,wp,Pd,Wp);
  endif
  E = EA + ES + ET + EP;
  gradE = gradEA + gradES + gradET + gradEP;
  gradE = gradE(:);
  hessE = hessEA + hessES + hessET + hessEP;
endif

endfunction
