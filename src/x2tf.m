function [b,a]=x2tf(x,U,V,M,Q,R)
% [b,a]=x2tf(x,U,V,M,Q,R)
%
% Inputs:
%   x - coefficient vector 
%       [k; 
%        zR(1:U); 
%        pR(1:V); 
%        abs(z(1:Mon2)); angle(z(1:Mon2)); 
%        abs(p(1:Qon2)); angle(p(1:Qon2))];
%       where k is the gain coefficient, zR and pR represent real
%       zeros and poles and z and p represent conjugate zero and pole
%       pairs. 
%   U - number of real zeros
%   V - number of real poles
%   M - number of conjugate zero pairs
%   Q - number of conjugate pole pairs
%   R - decimation factor, pole pairs are for z^R
%
% Outputs:
%   b - numerator polynomial
%   a - denominator polynomial

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

% Sanity checks
if (nargout>2) || (nargin!=6)
  print_usage("[b,a]=x2tf(x,U,V,M,Q,R)");
endif
if R<=0
  error("R<=0");
endif
x=x(:)';
N=1+U+V+M+Q;
if (length(x) != N)
  error("Expected length(x)==1+U+V+M+Q");
endif
Mon2=floor(M/2);
if (Mon2!=M/2)
  error("Expected M even");
endif
Qon2=floor(Q/2);
if (Qon2!=Q/2)
  error("Expected Q even");
endif

% Numerator
zR=x((1+1):(1+U));
zr=x((1+U+V+1):(1+U+V+Mon2));

za=x((1+U+V+Mon2+1):(1+U+V+M));
b=x(1);
for k=1:U
  b=conv(b, [1, -zR(k)]);
endfor
for k=1:Mon2
  b=conv(b, [1, -2*zr(k)*cos(za(k)), zr(k)^2]);
endfor
b=b(:);
if nargout==1
  return
endif

% Denominator
pR=x((1+U+1):(1+U+V));
pr=x((1+U+V+M+1):(1+U+V+M+Qon2));
if (any(abs(pr)>=1) || any(abs(pR)>=1))
  warning("Transfer function is not stable (poles |R|>=1)!");
endif
pa=x((1+U+V+M+Qon2+1):(1+U+V+M+Q));
Rz=zeros(1,R-1);
a=1;
for k=1:V
  a=conv(a, [1, Rz, -pR(k)]);
endfor
for k=1:Qon2
  a=conv(a, [1, Rz, -2*pr(k)*cos(pa(k)), Rz, pr(k)^2]);
endfor
a=a(:);

endfunction
