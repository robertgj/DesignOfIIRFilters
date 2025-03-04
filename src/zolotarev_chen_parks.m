function [u,x,f,um,xm,fm,a,fa,b,fb]=zolotarev_chen_parks(k,N,L,nf)
% [u,x,f,um,xm,fm,a,fa,b,fb]=zolotarev_chen_parks(k,N,L,nf)
% The Zolotarev polynomial is an equi-ripple approximation to 0
% in the regions [-1,1] and (a,b). This function calculates the
% Chen-Parks form of the Zolotarev polynomial with elliptic
% modulus, k, order N, L zeros in the region (a,b) and nf values
% of u in each section of the path [0,jKp]U(jKp,K+jKP]U(K+jKp,K]
% with K=K(k) and Kp=K(sqrt(1-(k^2))).
%
% Outputs:
%   u - the path in the complex u-plane
%   x - corresponding path in the x-plane [-1,1]U(1,a]U(a,b)
%   f - Zolotarev function values (length 3*nf)
%   um,xm - u and x at the maximum
%   fm - value at the maximum
%   a,b - boundaries of the region to the right of the maximum
%   fa,fb - values at the boundaries of the region (a,b)
%
% See:
%  [1] "Analytic Design of Optimal FIR Narrow-Band Filters Using Zolotarev
%      Polynomials", Xiangkun Chen and T. W. Parks, IEEE Transactions on
%      Circuits and Systems, Vol. 33, No. 11, November 1986, pp. 1065-1071
%  [2] "Zolotarev Polynomials and Optimal FIR Filters", M. Vlcek and
%       R. Unbehauen, IEEE Transactions on Signal Processing, Vol. 47,
%       No. 3, March, 1999, pp. 717-730
%  [3] Corrections to "Zolotarev Polynomials and Optimal FIR Filters",
%      M. Vlcek and R. Unbehauen, IEEE Transactions on Signal Processing,
%      Vol. 48, No.7, July, 2000 p. 2171

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
if (nargin~=3 && nargin~=4) || nargout>10
  print_usage("[u,x,f,um,xm,fm,a,fa,b,fb]=zolotarev_chen_parks(k,N,L,nf)");
endif
if nargin==3
  nf=1000;
endif
if k<=0 || k>=1
  error("Expect 0<k<1!")
endif
if N<=L
  error("Expect N>L!")
endif
if L<=0
  error("Expect L>0!")
endif

% Complete elliptic integral of the first kind
k2=k^2;
K=ellipke(k2);
Kp=ellipke(1-k2);

% Path in the u-plane
u=[(j*Kp*(0:nf)/nf),((K*(1:nf)/nf)+(j*Kp)),(K+(j*Kp*((nf-1):-1:0)/nf))];
[snu,cnu,dnu]=ellipj(u,k2);

% Zolotarev function
LKN=L*K/N;
[snLKN,cnLKN,dnLKN]=ellipj(LKN,k2);
[snupLKN,cnupLKN,dnupLKN]=ellipj(u+(LKN),k2);
[snumLKN,cnumLKN,dnumLKN]=ellipj(u-(LKN),k2);
x=((snu.^2)+(snLKN^2))./((snu.^2)-(snLKN^2));
HumLKN=jacobi_Eta(u-LKN,k);
HupLKN=jacobi_Eta(u+LKN,k);
tmp=(HumLKN./HupLKN).^N;
f=(((-1)^L)/2)*(tmp+(1./tmp));

% Maximum value
ZLKN=jacobi_Zeta(LKN,k);
sm=elliptic_F(asin(sqrt(ZLKN/((k2*snLKN)*((cnLKN*dnLKN)+(snLKN*ZLKN))))),k);
um=sm+(j*Kp);
snum=ellipj(um,k2);
xm=real(((snum^2)+(snLKN^2))./((snum^2)-(snLKN^2)));
HummLKN=jacobi_Eta(um-LKN,k);
HumpLKN=jacobi_Eta(um+LKN,k);
fm=real(((-1)^L/2)*(((HummLKN/HumpLKN)^N)+((HumpLKN/HummLKN)^N)));

% Values at a and b
a=real(((snu(nf+1+nf)^2)+(snLKN^2))./((snu(nf+1+nf)^2)-(snLKN^2)));
fa=real(((-1)^L/2)* ...
        (((jacobi_Eta(u(nf+1+nf)-LKN,k)/jacobi_Eta(u(nf+1+nf)+LKN,k))^N) + ...
         ((jacobi_Eta(u(nf+1+nf)+LKN,k)/jacobi_Eta(u(nf+1+nf)-LKN,k))^N)));
b=((snu(end)^2)+(snLKN^2))./((snu(end)^2)-(snLKN^2));
fb=((-1)^L/2)* ...
   (((jacobi_Eta(u(end)-LKN,k)/jacobi_Eta(u(end)+LKN,k))^N) + ...
    ((jacobi_Eta(u(end)+LKN,k)/jacobi_Eta(u(end)-LKN,k))^N));

endfunction
