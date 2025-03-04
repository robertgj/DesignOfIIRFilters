function [RF,err]=carlson_RF(x0,y0,z0,tol)
% [RF,err]=carlson_RF(x0,y0,z0,tol)
% Carlsons algorithm for computing the RF function.
% See Algorithm 1 in "Computing elliptic integrals by duplication",
% B.C.Carlson, Numerische Mathematik, 33:1-16, 1979

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

  % Sanity checks
  if ((nargin ~= 3) && (nargin~=4)) || (nargout>2)
    print_usage("[RF,err]=carlson_RF(x0,y0,z0,tol)");
  endif 
  if nargin==3
    tol=10*eps;
  endif
  if ~isscalar(x0)
    error("Expect x0 a scalar");
  endif 
  if ~isscalar(y0)
    error("Expect y0 a scalar");
  endif 
  if ~isscalar(z0)
    error("Expect z0 a scalar");
  endif

  maxiter=10;n=0;x=x0;y=y0;z=z0;s=[0,0,0];RF=inf;err=inf;
  while 1
    lambda=sqrt(x*y)+sqrt(x*z)+sqrt(y*z);
    mu=(x+y+z)/3;
    X=1-(x/mu); Y=1-(y/mu); Z=1-(z/mu);
    epsilon=max([abs(X),abs(Y),abs(Z)]);
    if epsilon<1 && ((epsilon^6)/(4*(1-epsilon)))<tol
      break;
    endif
    n=n+1;
    x=(x+lambda)/4; y=(y+lambda)/4; z=(z+lambda)/4;
    if n>maxiter
      error("n>=maxiter(%d)",maxiter);
    endif
  endwhile
  s(2)=((X^2)+(Y^2)+(Z^2))/(2*2);
  s(3)=((X^3)+(Y^3)+(Z^3))/(2*3);
  err=(5*(s(2)^3)/26)+(3*(s(3)^2)/26);
  RF=(1/sqrt(mu))*(1+(s(2)/5)+(s(3)/7)+((s(2)^2)/6)+(3*s(2)*s(3)/11));
endfunction
