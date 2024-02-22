function [a1,V1,Q1,a2,V2,Q2]=x2pa(x,U,V,M,Q,R,tol)
% [a1,V1,Q1,a2,V2,Q2]=x2pa(x,U,V,M,Q,R,tol)
% Find the all-pass single vector representations, a1 and a2, of
% the parallel allpass filter with the single vector representation, x
  
% Copyright (C) 2018 Robert G. Jenssen
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

  if ((nargin ~=6) && (nargin ~=7)) || (nargout~=6)
    print_usage("[a1,V1,Q1,a2,V2,Q2]=x2pa(x,U,V,M,Q,R,tol)");
  endif
  if nargin==6
    tol=10*eps;
  endif
  
  % Find the spectral factor
  [n,d]=x2tf(x,U,V,M,Q,R);
  n=n(:);
  d=d(:);
  try
    q=spectralfactor(n,d);
  catch
    err=lasterror();
    warning("Caught exception!\n%s\n",err.message);
    for e=1:length(err.stack)
      warning("Called %s at line %d\n",err.stack(e).name,err.stack(e).line);
    endfor
    error("x2pa() failed");
  end_try_catch

  % Roots of n+q
  nq=n(:)+q(:);
  z=qroots(nq);

  % Find all-pass poles
  p1=[];
  p2=[];
  for k=1:length(z)
    if abs(abs(z(k))-1)<tol
      error("All-pass pole on unit circle!");
    elseif abs(z(k)) > 1
      p1=[p1; 1/z(k)];
    else
      p2=[p2; z(k)];
    endif
  endfor

  % Convert to single-vector all-pass representation
  [a1,V1,Q1]=p2a(p1);
  a1=a1(:);
  [a2,V2,Q2]=p2a(p2);
  a2=a2(:);
  
endfunction
