function [num,den]=a2tf(a,V,Q,R)
% [num,den]=a2tf(a,V,Q,R)
% Convert a real and complex pole representation of an allpass filter
% into numerator and denominator polynomials having order (V+Q)R.
%
% Inputs:
%   a - coefficient vector [pR(1:V); abs(pr(1:Qon2)); angle(pr(1:Qon2))];
%       where pR represent real poles and pr represents conjugate zero
%       and pole pairs. 
%   V - number of real poles
%   Q - number of conjugate pole-zero pairs
%   R - decimation factor for z^R
%
% Outputs:
%   num - numerator polynomial
%   den - denominator polynomial

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
if (nargin ~=4) || (nargout~=2)
  print_usage("[num,den]=x2tf(a,V,Q,R)");
endif
if rem(Q,2) ~= 0
  error("Expected Q even");
endif
if length(a) ~= (V+Q)
  error("Expected length(a)==V+Q");
endif
if isempty(a)
  num=[1];
  den=[1];
  return;
endif

% Initialise
a=a(:)';
N=V+Q;
Qon2=Q/2;

% Denominator
pR=a(1:V);
pr=a((V+1):(V+Qon2));
thetar=a((V+Qon2+1):(V+Q));
den=1;
for k=1:V
  den=conv(den, [1, -pR(k)]);
endfor
for k=1:Qon2
  den=conv(den, [1, -2*pr(k)*cos(thetar(k)), pr(k)^2]);
endfor
den=den(:);
den=[kron(den(1:(V+Q)),[1;zeros(R-1,1)]);den(end)];

% Numerator
num=flipud(den);

endfunction
