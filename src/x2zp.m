function [z,p,K]=x2zp(x,U,V,M,Q,R)
% [z,p,K]=x2zp(x,U,V,M,Q,R)
% Convert the single vector x description to zero and pole vectors and gain.
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
%   z - zeros
%   p - poles
%   K - gain

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
if (nargout~=3) || ((nargin~=5)&&(nargin~=6))
  print_usage("[z,p,K]=x2zp(x,U,V,M,Q,R)");
endif
if nargin==5
  R=1;
endif
if R<=0
  error("R<=0");
endif
x=x(:);
N=1+U+V+M+Q;
if (length(x) ~= N)
  error("Expected length(x)==1+U+V+M+Q");
endif
if mod(M,2)~=0
  error("Expected M even");
endif
Mon2=M/2;
if mod(Q,2)~=0
  error("Expected Q even");
endif
Qon2=Q/2;

% Gain
K=x(1);

% Zeros
zr=x((1+1):(1+U));
zc=x((1+U+V+1):(1+U+V+Mon2))...
   .*exp(j*x((1+U+V+Mon2+1):(1+U+V+M)));
z=sort([zr(:);zc(:);conj(zc(:))]);

% Poles
piR=2*pi*(0:(R-1))/R;
pr=(x((1+U+1):(1+U+V)).^(1/R)).*exp(j*piR);
pc=((x((1+U+V+M+1):(1+U+V+M+Qon2)).^(1/R)).*exp(j*piR))...
   .*kron(exp(j*x((1+U+V+M+Qon2+1):(1+U+V+M+Q))/R),ones(1,R));
p=sort([pr(:);pc(:);conj(pc(:))]);

endfunction
