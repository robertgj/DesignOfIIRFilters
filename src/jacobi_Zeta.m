function z=jacobi_Zeta(x,k,tol)
% z=jacobi_Zeta(x,k,tol) for real scalars x and k
% See Section 22.16(iii) and equations 22.16.30 and 22.16.32 of the
% Digital Library of Mathematical Functions at https://dlmf.nist.gov/22.16

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
  if ~isscalar(x)
    error("Expect x scalar!");
  endif
  if imag(x)>tol
    error("Expect x real!");
  endif
  x=real(x);
  if ~isscalar(k)
    error("Expect k scalar!");
  endif
  if k<=0 || k>=1
    error("Expect 0<k<1!");
  endif

  k2=k^2;
  [Kk,Ek]=ellipke(k2);
  
  % Adjust elliptic integral limits
  % Apply Equation 22.16.34: Z(x+2K,k)=Z(x,k)
  xm2K=mod(x,2*Kk);
  % Apply Equation 22.16.33: Z(x+K,k)=Z(x,k)-(k^2)*sn(x,k)*cd(x,k)
  if xm2K>=Kk
    xmK=mod(xm2K,Kk);
    [snxmK,cnxmK,dnxmK]=ellipj(xmK,k2);
    del=k2*snxmK*cnxmK/dnxmK;
  else
    xmK=xm2K;
    snxmK=ellipj(xmK,k2);
    del=0;
  endif

  % Calculate Jacobi's Zeta function
  phi=asin(snxmK);
  z=elliptic_E(phi,k,tol)-(xmK*Ek/Kk)-del;
endfunction
