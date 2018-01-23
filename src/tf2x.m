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

% Sanity checks
if nargin < 2
  print_usage("[x,U,V,M,Q]=tf2x(b,a,tol)");
endif
if nargin==2
  tol=1e-9;
endif

% Find real and complex zeros
bz=roots(b);
irz=find(abs(imag(bz))<tol);
iz=find(imag(bz)>tol);

% Find real and complex poles
ap=roots(a);
if any(abs(ap)>=1)
   warning("Transfer function is not stable (poles |R|>=1)!");
endif
irp=find(abs(imag(ap))<tol);
ip=find(imag(ap)>tol);

% Find gain
bnz = b(abs(b)>tol);
anz = a(abs(a)>tol);
if isempty(bnz)
  K=0;
else
  K=bnz(1)/anz(1);
endif

% Make outputs
x=[K; ...
   bz(irz); ...
   ap(irp); ...
   abs(bz(iz)); angle(bz(iz)); ...
   abs(ap(ip)); angle(ap(ip))];
U = length(irz);
V = length(irp);
M = 2*length(iz);
Q = 2*length(ip);

% Sanity checks
if length(b) ~= 1+U+M
  error("length(b)=%d not consistent with U=%d and M=%d", length(b), U, M);
endif;
if length(a) ~= 1+V+Q
  error("length(a)=%d not consistent with V=%d and Q=%d", length(a), V, Q);
endif;

endfunction
