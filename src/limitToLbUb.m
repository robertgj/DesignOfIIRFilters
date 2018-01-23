function alpha=limitToLbUb(x,d,lb,ub,tol)
% alpha=limitToLbUb(x,d,lb,ub,tol)
% Find alpha so that lb<=x+alpha*d<=ub

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

% Sanity check on inputs 
if any((x==lb) & (d<0))
  alpha=0;
  warning("limitToLbUb() found alpha=0 at lower bound");
  return
endif
if any((x==ub) & (d>0))
  alpha=0;
  warning("limitToLbUb() found alpha=0 at upper bound");
  return
endif

% Lower bound violations by x+d
ixdmlb=find((x+d<lb).*(d<0));
if isempty(ixdmlb)
  alb=1;
else
  alb=(lb(ixdmlb)-x(ixdmlb))./d(ixdmlb);
endif

% Upper bound violations by x+d
iubmxd=find((x+d>ub).*(d>0));
if isempty(iubmxd)
  aub=1;
else
  aub=(ub(iubmxd)-x(iubmxd))./d(iubmxd);
endif

% Limit alpha, x+alpha*d 
alpha=[aub;alb];
alpha=alpha(find(alpha>0));
alpha=min([alpha; 1]);

% Sanity check
if any((x+alpha*d)>(ub+tol))
  printf("alpha=%f\n",alpha);
  printf("x=[ ");printf("%f ",x);printf("]';\n");
  printf("d=[ ");printf("%f ",d);printf("]';\n");
  printf("x+alpha*d=[ ");printf("%f ",x+d);printf("]';\n");
  printf("ub+tol=[ ");printf("%f ",ub+tol);printf("]';\n");
  error("x+alpha*d>ub+tol");
elseif any((x+alpha*d)<(lb-tol))
  printf("alpha=%f\n",alpha);
  printf("x=[ ");printf("%f ",x);printf("]';\n");
  printf("d=[ ");printf("%f ",d);printf("]';\n");
  printf("x+alpha*d=[ ");printf("%f ",x+d);printf("]';\n");
  printf("lb-tol=[ ");printf("%f ",lb-tol);printf("]';\n");
  error("x+alpha*d<lb-tol");
endif

endfunction
