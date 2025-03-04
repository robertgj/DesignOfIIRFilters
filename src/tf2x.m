function [x,U,V,M,Q]=tf2x(b,a,tol)
% [x,U,V,M,Q]=tf2x(b,a,tol)
%
% Inputs:
%   b - numerator polynomial
%   a - denominator polynomial
%   tol - tolerance on real zero/pole imaginary parts
%
% Outputs:
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

% Sanity checks
if nargin < 2
  print_usage("[x,U,V,M,Q]=tf2x(b,a,tol)");
endif
if nargin==2
  tol=100*eps;
endif

% Find real and complex zeros
z=qroots(b);

% Find real and complex poles
p=qroots(a);

% Find gain
bnz = b(abs(b)>tol);
anz = a(abs(a)>tol);
if isempty(bnz)
  K=0;
else
  K=bnz(1)/anz(1);
endif

[x,U,V,M,Q]=zp2x(z,p,K,tol);

endfunction
