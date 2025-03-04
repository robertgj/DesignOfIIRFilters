function x=elliptic_Pi(phi,n,k,tol)
% x=elliptic_Pi(phi,n,k,tol) for scalars phi, n and modulus, k
% See Equation 19.2.7 of the "Digital Library of Mathematical
% Functions", https://dlmf.nist.gov/19.2 . Note that this definition
% differs in the sign of n from that in Equation 4.3 of "Computing
% elliptic integrals by duplication", B.C.Carlson, Numerische
% Mathematik, 33:1-16, 1979

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
  
  if (nargin~=3 && nargin~=4) || nargout>1
    print_usage("x=elliptic_Pi(phi,n,k,tol)");
  endif
  if nargin==3
    tol=10*eps;
  endif
  if ~isscalar(phi)
    error("Expect phi scalar!");
  endif
  if (phi<0) || (phi>(pi/2))
    error("Expect 0<=phi<=pi/2 !");
  endif
  if ~isscalar(n)
    error("Expect n scalar!");
  endif
  if (n*(sin(phi)^2))>=1
    error("Expect (n*(sin(phi)^2))<1 !");
  endif
  if ~isscalar(k)
    error("Expect k scalar!");
  endif
  if abs(imag(k))>tol
    error("Expect k real!");
  endif
  k=real(k);
  if k<0 || k>1
    error("Expect 0<=k<=1 !");
  endif

  % Special values
  if phi==0
    x=0;
    return;
  endif
  if n==0 && k==0
    x=phi;
    return;
  endif
  if n==0
    sp=sin(phi);
    sp2=sp^2;
    x=sp*carlson_RF(1-sp2,1-(sp2*(k^2)),1,tol);
    return;
  endif
  if n==1 && k==0
    x=tan(phi);
    return;
  endif
  if n==1 && k==1
    c=1/(sin(phi)^2);
    x=(carlson_RC(c,c-1)+(sqrt(c)/(c-1)))/2;
    return;
  endif
  if k==0
    c=1/(sin(phi)^2);
    x=carlson_RC(c-1,c-n);
    return;
  endif
  if k==1
    c=1/(sin(phi)^2);
    x=(carlson_RC(c,c-1)-(n*carlson_RC(c,c-n)))/(1-n);    
    return;
  endif
  
  sp=sin(phi);
  sp2=sin(phi)^2;
  ksp2=(k*sp)^2;
  x=sp*(carlson_RF(1-sp2,1-ksp2,1,tol) + ...
        ((n/3)*sp2*carlson_RJ(1-sp2,1-ksp2,1,1-(n*sp2),tol)));

endfunction
