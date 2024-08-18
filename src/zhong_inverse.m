function B=zhong_inverse(A)
% B=zhong_inverse(A)
% Use the algorithm of Xu Zhong to calculate the inverse of a lower
% Hessenberg matrix. See Theorem 1 of "On Inverses and Generalized
% Inverses of Hessenberg Matrices", Xu Zhong, "Linear Algebra and
% its Applications", Vol. 101, 1988, pp. 167-180.

% Copyright (C) 2017-2024 Robert G. Jenssen
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
  
  if nargin ~= 1
    print_usage("B=zhong_inverse(A)");
  endif
  if rows(A) ~= columns(A)
    error("rows(A) ~= columns(A)");
  endif
  if isempty(A)
    error("A is empty!");
  endif

  if rows(A)<=2
    B=inv(A);
    return;
  endif

  % P
  N=rows(A);
  P=A(1:(N-1),2:N);
  if ~istril(P)
    error("A is not lower hessenberg");
  endif
  if any(diag(P)==0)
    % Elimination will fail
    B=inv(A);
    return;
  endif

  % alpha
  alpha=diag(A,1);
  
  % x recurrence
  x=[1;zeros(N-1,1)];
  for l=2:N
    x(l)=-(A(l-1,1:(l-1))*x(1:(l-1)))/alpha(l-1);
  endfor

  % w recurrence
  w=zeros(1,N);
  w(N)=1/(A(N,1:N)*x);
  for l=(N-1):-1:1
    w(l)=-(w((l+1):N)*A((l+1):N,l+1))/alpha(l);
  endfor

  % Construct the inverse
  B=zeros(N,N);
  B(2:N,1:(N-1))=inv(P);
  B=B+(x*w);
  
endfunction
