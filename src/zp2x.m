function [x,U,V,M,Q]=zp2x(z,p,k,tol)
% [x,U,V,M,Q]=zp2x(z,p,k,tol)
%
% Convert transfer function gain scalar, zero vector and pole vector
% to the single vector x with U, V, M, and Q. The conjugate poles and
% zeros are sorted by the Octave "sort" function by radius and then
% by angle.
%
% !!! NOTE !!! : For IIR filters with symmetric numerator polynomials
% (eg: Butterworth etc.) the sorting order may depend on small errors in
% the calculation of the absolute value.
%
% Inputs:
%   z - zeros
%   p - poles
%   k - gain
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

% Copyright (C) 2018 Robert G. Jenssen
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
if (nargin < 3) || (nargout~=5)
  print_usage("[x,U,V,M,Q]=zp2x(z,p,k,tol)");
endif
if nargin==3
  tol=100*eps;
endif
if ~isscalar(k)
  error("k not a scalar");
endif

% Initialise
z=sort(z(:));
p=sort(p(:));

% Find real zeros
nRz=find(abs(imag(z))<tol);
Rz=real(z(nRz));

% Find complex poles
nrz=find(imag(z)>=tol);
rz=abs(z(nrz));
argz=angle(z(nrz));

% Find real poles
nRp=find(abs(imag(p))<tol);
Rp=real(p(nRp));

% Find complex poles
nrp=find(imag(p)>=tol);
rp=abs(p(nrp));
argp=angle(p(nrp));

% Make output vector
x=[k;Rz;Rp;rz;argz;rp;argp];
U = length(Rz);
V = length(Rp);
M = 2*length(rz);
Q = 2*length(rp);

% Sanity checks
if mod(M,2)
  error("M(%d) is not even!",M);
endif
if length(argz) ~= (M/2)
  error("length(argz)=%d not consistent with M=%d",length(argz),M);
endif;
if mod(Q,2)
  error("Q(%d) is not even!",Q);
endif
if length(argp) ~= (Q/2)
  error("length(argp)=%d not consistent with Q=%d",length(argp),Q);
endif;
if length(x) ~= 1+U+V+M+Q
  error("length(x)=%d not consistent with U=%d, V=%d, M=%d and Q=%d",
        length(x),U,V,M,Q);
endif;

endfunction
