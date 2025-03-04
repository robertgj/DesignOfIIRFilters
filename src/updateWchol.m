function [W,invW]=updateWchol(H,tau)

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

% Sanity check
if any(any(isnan(H)))
  error("updateWchol() : Found NaN in H");
endif
if any(any(isinf(H)))
  error("updateWchol() : Found inf in H");
endif

% Set mu1 mu2
r1=0;
r2=1;
if tau>0.9 
  r2=r2/5; 
elseif tau<0.2 
  r2=r2*5; 
endif
wk=max(diag(H));
mu1=r1*wk;
mu2=r2*wk;

% Find modified Cholesky factor
n=rows(H);
L=zeros(n,n);

if mu1<H(1,1)
  L(1,1)=sqrt(H(1,1));
else
  L(1,1)=sqrt(mu2);
endif
L(2:n,1)=H(2:n,1)/L(1,1);

for c=2:n
  lcm2=sum(L(c,1:c-1).^2);
  if mu1<H(c,c)-lcm2
    L(c,c)=sqrt(H(c,c)-lcm2);
  else
    L(c,c)=sqrt(mu2);
  endif
  for r=(c+1):n
    L(r,c)=(H(r,c)-sum(L(c,1:(c-1)).*L(r,1:(c-1))))/L(c,c);
  endfor
endfor

% Find modified Hessian and inverse
W=L*L';    
invW=chol2inv(L');

% Sanity check
if rcond(W)<1e-8
  warning("updateWchol() : W poorly conditioned!");
endif
if any(any(isnan(W)))
  error("updateWchol() : Found NaN in W");
endif
if any(any(isinf(W)))
  error("updateWchol() : Found inf in W");
endif
if any(any(isnan(invW)))
  error("updateWchol() : Found NaN in invW");
endif
if any(any(isinf(invW)))
  error("updateWchol() : Found inf in invW");
endif

endfunction
