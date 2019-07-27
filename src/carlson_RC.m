function [RC,err]=carlson_RC(x0,y0,tol)
% [RC,err]=carlson_RC(x0,y0,tol)
% Carlsons algorithm for computing the RC function.
% See Algorithm 2 in "Computing elliptic integrals by duplication",
% B.C.Carlson, Numerische Mathematik, 33:1-16, 1979. The case of
% y0<0 is handled with equation 2.12.

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

  % Sanity checks
  if ((nargin ~= 2) && (nargin~=3)) || (nargout>2)
    print_usage("[RC,err]=carlson_RC(x0,y0,tol)");
  endif 
  if nargin==2
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

  maxiter=10;n=0;x=x0;y=y0;s=0;RC=inf;err=inf;
  
  while 1
    lambda=(2*sqrt(x*y))+y;
    mu=(x+(2*y))/3;
    s=(y-x)/(3*mu);
    if abs(s)<0.5 && (16*(abs(s)^6)/(1-(2*abs(s))))<tol
      break;
    endif
    n=n+1;
    x=(x+lambda)/4; y=(y+lambda)/4;
    if n>maxiter
      error("n>=maxiter(%d)",maxiter);
    endif
  endwhile
  RC=(1+((s^2)*((3/10)+(s*((1/7)+s*((3/8)+(9*s/22)))))))/sqrt(mu);
  err=159*(s^6)/208;
endfunction
