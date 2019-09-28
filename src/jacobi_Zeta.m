function z=jacobi_Zeta(x,k,tol)
% z=jacobi_Zeta(x,k,tol)
% See Section 22.16(iii) and equations 22.16.31 and 22.16.32
% of the Digital Library of Mathematical Functions
% at https://dlmf.nist.gov/22.16

% Copyright (C) 2019 Robert G. Jenssen
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
  
  if (nargin~=2 && nargin ~=3) || nargout>1
    print_usage("z=jacobi_Zeta(x,k,tol)");
  endif
  if nargin==2
    tol=eps;
  endif
  if length(size(x))>2
    error("length(size(x))>2");
  endif
  if any(any(imag(x)>tol))
    error("Expect x real!");
  endif
  x=real(x);
  if ~isscalar(k)
    error("Expect k scalar!");
  endif
  if abs(imag(k))>tol
    error("Expect k real!");
  endif
  k=real(k);
  if k<=0 || k>=1
    error("Expect 0<k<1!");
  endif

  k2=k^2;
  [Kk,Ek]=ellipke(k2);
  
  % Calculate Jacobi's Zeta function as (jacobi_Theta'/jacobi_Theta)
  jt2=jacobi_theta3k(0,k,tol)^2;
  z=jacobi_theta4kp(x/jt2,k,tol)./(jt2*jacobi_theta4k(x/jt2,k,tol));
  
endfunction
