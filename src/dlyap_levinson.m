function X=dlyap_levinson(P,Q)
% X=dlyap_levinson(P,Q)
% Find the Levinson solution to the 
% discrete Lyapunov equation X=PXP'+Q*Q'
% See Roberts and Mullis p. 393 and p. 527

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
if (nargin ~= 2)
  print_usage("X=dlyap_levinson(P,Q)");
endif
if (rows(P) ~= columns(P))
  error("Expect square argument P");
endif 
if (columns(Q) ~= 1) || (rows(Q) ~= rows(P))
  error("Expect columns(Q)=1 and rows(Q)=rows(P)!");
endif

% Le Verrier's algorithm for the characteristic equation of P
N=rows(P);
B=eye(N);
a=[1 zeros(1,N)];
% Loop
for k=2:(N+1)
  a(k)=-trace(P*B)/(k-1);
  B=P*B+a(k)*eye(N);
endfor

% Find similarity transform
x=zeros(N,1);
T=zeros(N);
for k=1:N
  x=P*x+Q*a(k);
  T(:,N-k+1)=x;
endfor

% Find reflection coefficients
gmma=atog(a);

% Find autocorrelation
r=gtor(gmma,1);

% Toeplitz matrix
R=toeplitz(r(1:N));

% Build X
X=T*R*T';
endfunction

