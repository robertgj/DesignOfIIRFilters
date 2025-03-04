function x=jacobi_theta2(z,q,tol)
% x=jacobi_theta2(z,q,tol)
% See Section 20.2 of "NIST Digital Library of Mathematical
% Functions", http://dlmf.nist.gov/, edited by F. W. J. Olver, et al.

% Calculate at least three terms for improved accuracy. If an argument
% is close to a zero of cos or sin, the argument is "further" from the
% zero for later terms.

% Copyright (C) 2019-2025 Robert G. Jenssen
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
  
  if (nargin~=2 && nargin~=3) || nargout>1
    print_usage("x=jacobi_theta2(z,q,tol)");
  endif
  if nargin==2
    tol=eps;
  endif

  if length(size(z))>2
    error("length(size(z))>2");
  endif
  if ~isscalar(q)
    error("Expect q scalar!");
  endif
  if abs(imag(q))>tol
    error("Expect q real!");
  endif
  q=real(q);
  if q<0 || q>=1
    error("Expect 0<=q<1 !");
  endif
  
  x=zeros(size(z));
  qe=1;
  maxiter=100;
  n=0;
  nn=1;
  while 1
    dx=2*(q^(qe/4))*cos(nn*z);
    x=x+dx;
    if all(all(abs(dx)<tol)) && n>1
      break;
    endif
    qe=qe+(8*n)+8;
    nn=nn+2;
    n=n+1;
    if n>=maxiter
      error("n>=maxiter");
    endif
  endwhile

endfunction
