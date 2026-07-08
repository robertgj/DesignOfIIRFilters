function [invA,invU,invL,L,U] = tridiagonal_inverse(c,d,e)
% [invA,invU,invL,L,U] = tridiagonal_inverse(c,d,e)
%
% Find the LU decomposition of a tridiagonal system, A=L*U:
%     _                    _     _               _   _                    _ 
%     |d(1) e(1)            |   |1                |  |u(1) e(1)            |
%     |c(2) d(2)  .         |   |l(2) 1           |  |     u(2)  .         |
% A=  |       .   .         | = |     l(3) 1      |  |       .   .         |
%     |       .   .  e(n-1) |   |         .  .    |  |           .  e(n-1) |
%     |_        c(n) d(n)  _|   |_         l(n) 1_|  |_             u(n)  _|
%
% Then invert L and U to find A^{-1}=U^{-1}*L^{-1}.
% c,d,e must be [N,n-1], [N,n] and [N,n-1] matrixes, respectively.
% See:
% [1] Section 4.3,"Matrix Calculations",3rd Edn,Golub and Van Loan
% [2] Section 9.6,"Accuracy and Stability of Numerical Algorithms",2002,Higham
%

% Copyright (C) 2026 Robert G. Jenssen
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
  if (nargin~=3) || ((nargout~=1) && (nargout~=3) && (nargout~=5))
    print_usage(["A=tridiagonal_inverse(c,d,e)\n", ...
                 "[invA,invL,invU] = tridiagonal_inverse(c,d,e)\n", ...
                 "[invA,invL,invU,L,U] = tridiagonal_inverse(c,d,e)\n"]);
  endif

  if ndims(c)>2 || ndims(d)>2 || ndims(e)>2
    error("Expected number of dimensions <=2!");
  endif
  
  if rows(c)~=rows(d) || rows(d)~=rows(e)
    error("Expected equal number of rows!");
  endif

  if columns(c) ~= columns(d)-1
    error("columns(c) ~= columns(d)-1");
  endif
  if columns(d)-1 ~= columns(e)
    error("columns(d)-1 ~= columns(e)");
  endif

  % Pad c for convenience
  c=[zeros(rows(c),1),c];
  
  % Use Higham Eq. 9.19 recurrence relation
  N=rows(d);
  n=columns(d);
  l=zeros(N,n);
  u=[d(:,1),zeros(N,n-1)];
  for m=2:n,
    l(:,m)=c(:,m)./u(:,m-1);
    u(:,m)=d(:,m)-(l(:,m).*e(:,m-1));
  endfor

  % Use Golub and Van Loan Algorithm 4.3.2 to find invL=L\eye(n)
  invL=zeros(N,n,n);
  invL(:,1,1)=ones(N,1);
  for m=2:n,
    invL(:,m,[m-1:m])=[-l(:,m),ones(N,1)];
  endfor
  for p=1:(n-1),
    for q=(p+2):n,
      invL(:,q,p)=-invL(:,q-1,p).*l(:,q);
    endfor
  endfor
  
  % Use Golub and Van Loan Algorithm 4.3.3 to find invU=U\eye(n)
  invU=zeros(N,n,n);
  for m=1:n,
    invU(:,m,m)=1./u(:,m);
  endfor
  for p=1:(n-1),
    for q=(p+1):n,
      invU(:,p,q)=-invU(:,p,q-1).*e(:,q-1)./u(:,q);
    endfor
  endfor
    
  % Done
  for m=1:N,
    invA(m,:,:)=squeeze(invU(m,:,:))*squeeze(invL(m,:,:));
  endfor
  if N==1
    invA=squeeze(invA);
  endif

  if (nargout == 1) || (nargout == 3)
    return;
  endif
  
  % Set up L and U
  L=zeros(N,n,n);
  L(:,1,1)=ones(1,N);
  for m=2:n
    L(:,m,m)=ones(1,N);
    L(:,m,m-1)=l(:,m);
  endfor

  U=zeros(N,n,n);
  for m=1:(n-1)
    U(:,m,[m:(m+1)])=[u(:,m),e(:,m)];
  endfor
  U(:,n,n)=u(:,n);
  
endfunction
