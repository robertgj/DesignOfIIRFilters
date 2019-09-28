function x=jacobi_Theta(z,k,tol)
% x=jacobi_Theta(z,k,tol)

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
  
  if (nargin~=2 && nargin~=3) || nargout>1
    print_usage("x=jacobi_Theta(z,k,tol)");
  endif
  if nargin==2
    tol=eps;
  endif
  if ~isscalar(k)
    error("Expect k scalar!");
  endif
  if abs(imag(k))>tol
    error("Expect k real!");
  endif
  k=real(k);
  if k<=0 || k>=1
    error("Expect 0<k<1 !");
  endif
  
  k2=k^2;
  K=carlson_RF(0,1-k2,1);
  Kp=carlson_RF(0,k2,1);
  tp=K/Kp;
  if tp>1
    q=exp(-pi*tp);
    u=z/(tp*(jacobi_theta3(0,q)^2));
    x=jacobi_theta2(u*j*tp,q,tol);
    x=x*sqrt(tp).*exp(-u.*u*tp/pi);
  else
    q=exp(-pi/tp);
    u=z/(jacobi_theta3(0,q)^2);
    x=jacobi_theta4(u,q,tol);
  endif

endfunction
