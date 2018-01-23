function [T,Ap]=lanczos_tridiag(A,tol)
% [T,Ap]=lanczos_tridiag(A,tol)
% Use unsymmetric Lanczos tridiagonalisation to find the similarity
% transform, T, that reduces unsymmetric matrix, A, to tridiagonal
% form, Ap. See "Matrix Computation, 3rd Edition" Golub and Van Loan,
% Section 9.4.3.

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

if (nargin ~= 1) && (nargin ~= 2)
  print_usage("[T,Ap]=lanczos_tridiag(A[,tol])")
endif
if columns(A) ~= rows(A)
  error("Expected A to be a square matrix");
endif
if nargin == 1
   tol = 1e-6
endif

% Initialise
IA=eye(size(A));
N=rows(A);
Alpha=zeros(N,1);
Beta=zeros(N-1,1);
Gamma=zeros(N-1,1);
p=zeros(size(A));
t=zeros(size(A));
r = rand(N,1);
r = r/norm(r,2);
s = rand(N,1);
s = s/norm(s,2);

% k=0
k=0;
t(:,k+1)=s;
p(:,k+1)=r/(r'*s);
k=1;
Alpha(k)=p(:,k)'*A*t(:,k);
r=(A-Alpha(k)*IA)'*p(:,k);
s=(A-Alpha(k)*IA)*t(:,k);

% k=1:N
while 1
  if norm(r,2)<tol 
    T=inv(p)';
    break; 
  elseif norm(s,2)<tol 
    T=t;
    break;
  elseif abs(r'*s)<tol
    error("lanczos_tridiag() failed with serious breakdown");
    return;
  elseif k==N
    r
    norm(r,2)
    s
    norm(s,2)
    Alpha
    Beta
    Gamma
    error("lanczos_tridiag() failed with k==N");
    return;
  else
    Gamma(k)=norm(s,2);
    Beta(k)=(r'*s)/Gamma(k);
    t(:,k+1)=s/Gamma(k);
    p(:,k+1)=r/Beta(k);
    k=k+1;
    Alpha(k)=p(:,k)'*A*t(:,k);
    r=(A-Alpha(k)*IA)'*p(:,k) - Gamma(k-1)*p(:,k-1);
    s=(A-Alpha(k)*IA)*t(:,k)  - Beta(k-1)*t(:,k-1);
  endif
endwhile
Ap=diag(Alpha)+diag(Beta,1)+diag(Gamma,-1);

endfunction
