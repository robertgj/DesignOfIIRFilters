function [a1,a2]=tf2pa(n,d)
% [a1,a2]=tf2pa(n,d)
% Find the denominator polynomials, a1 and a2, of the parallel
% allpass filter that implements the transfer function n(z)/d(z)
  
% Copyright (C) 2017 Robert G. Jenssen
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

  % Find the spectral factor
  try
    q=spectralfactor(n,d);
  catch
    err=lasterror();
    warning("Caught exception!\n%s\n",err.message);
    for e=1:length(err.stack)
      warning("Called %s at line %d\n",err.stack(e).name,err.stack(e).line);
    endfor
    error("tf2pa() failed");
  end_try_catch

  % Roots of n+q
  nq=n+q;
  z=roots(nq);

  % Find denominators of a1 and a2
  a1=[1];
  a2=[1];
  for m=1:length(z)
    if abs(z(m)) == 1
      error("All-pass pole on unit circle!");
    elseif abs(z(m)) > 1
      a1=conv(a1, [1 -1/z(m)]);
    else
      a2=conv(a2, [1 -z(m)]);
    endif
  endfor
  tol=10*eps;
  if max(abs(imag(a1)))>tol
    warning("max(abs(imag(a1)))>%3d*eps",tol/eps);
  endif
  if max(abs(imag(a2)))>tol
    warning("max(abs(imag(a2)))>%3d*eps",tol/eps);
  endif
  a1=real(a1(:)');
  a2=real(a2(:)');
endfunction
