function x=elliptic_F(phi,k,tol)
% x=elliptic_F(phi,k,tol) for scalars phi and k
% See Equation 4.1 of "Computing elliptic integrals by duplication",
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
  
  if (nargin~=2 && nargin~=3) || nargout>1
    print_usage("x=elliptic_F(phi,k,tol)");
  endif
  if nargin==2
    tol=10*eps;
  endif
  if ~isscalar(phi)
    error("Expect phi scalar!");
  endif
  if ~isscalar(k)
    error("Expect k scalar!");
  endif
  if abs(imag(k))>tol
    error("Expect k real!");
  endif
  k=real(k);
  if k<0 || k>1
    error("Expect 0<=k<=1!");
  endif
  if abs(sin(phi))==1 && k==1
    error("abs(sin(phi))==1 && k==1");
  endif
  if phi==0
    x=0;
    return;
  endif
  if k==0
    x=phi;
    return;
  endif
  
  sp=sin(phi);
  sp2=sp^2;
  x=sp*carlson_RF(1-sp2,1-(sp2*(k^2)),1,tol);
  
endfunction
