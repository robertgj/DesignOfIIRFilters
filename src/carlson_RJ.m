function [RJ,err]=carlson_RJ(x0,y0,z0,p0,tol)
% [RF,err]=carlson_RJ(x0,y0,z0,p0,tol)
% Carlsons algorithm for computing the RJ function.
% See Algorithm 3 in "Computing elliptic integrals by duplication",
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
  if ((nargin ~= 4) && (nargin~=5)) || (nargout>2)
    print_usage("[RJ,err]=carlson_RJ(x0,y0,z0,p0,tol)");
  endif 
  if nargin==4
    tol=10*eps;
  endif
  if ~isscalar(x0)
    error("Expect x0 a scalar");
  endif 
  if x0<0
    error("Expect x0>=0");
  endif
  if ~isscalar(y0)
    error("Expect y0 a scalar");
  endif 
  if y0<=0
    error("Expect y0>0");
  endif
  if ~isscalar(z0)
    error("Expect z0 a scalar");
  endif
  if z0<=0
    error("Expect z0>0");
  endif
  if ~isscalar(p0)
    error("Expect p0 a scalar");
  endif
  if p0<=0
    error("Expect p0>0");
  endif

  maxiter=10;n=0;s=zeros(1,5);RJ=inf;err=inf;
  sumz=0;x=x0;y=y0;z=z0;p=p0;
  
  while 1
    lambda=sqrt(x*y)+sqrt(x*z)+sqrt(y*z);
    mu=(x+y+z+(2*p))/5;
    X=1-(x/mu); Y=1-(y/mu); Z=1-(z/mu); P=1-(p/mu);
    a=((p*(sqrt(x)+sqrt(y)+sqrt(z)))+sqrt(x*y*z))^2;
    b=p*((p+lambda)^2);
    epsilon=max([abs(X),abs(Y),abs(Z),abs(P)]);
    if epsilon<1 && (3*(epsilon^6)/((1-epsilon)^(3/2)))<tol
      break;
    endif
    sumz=sumz+(carlson_RC(a,b)/(4^n));
    x=(x+lambda)/4; y=(y+lambda)/4; z=(z+lambda)/4; p=(p+lambda)/4;
    n=n+1;
    if n>maxiter
      error("n>maxiter(%d)",maxiter);
    endif
  endwhile
  s(2)=((X^2)+(Y^2)+(Z^2)+(2*(P^2)))/(2*2);
  s(3)=((X^3)+(Y^3)+(Z^3)+(2*(P^3)))/(2*3);
  s(4)=((X^4)+(Y^4)+(Z^4)+(2*(P^4)))/(2*4);
  s(5)=((X^5)+(Y^5)+(Z^5)+(2*(P^5)))/(2*5);
  err=(-(s(2)^3)/10)+(3*(s(3)^2)/10)+(3*s(2)*s(4)/5);
  RJ=(3*sumz)+(1+(3*s(2)/7)+(s(3)/3)+(3*(s(2)^2)/22)+ ...
               (3*s(4)/11)+(3*s(2)*s(3)/13)+(3*s(5)/13))/((4^n)*(mu^(3/2)));

endfunction
