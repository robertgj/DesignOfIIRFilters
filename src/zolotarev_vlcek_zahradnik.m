function [h,wp,wm,ws,a,aplus]=zolotarev_vlcek_zahradnik(p,q,k)
% [h,wp,wm,ws,a,aplus]=zolotarev_vlcek_zahradnik(p,q,k)
% For the modified Zolotarev function, Spq(w,k), defined by Vlcek and
% Zahradnik, calculate the coefficients of the expansion of that function in
% Chebyshev polynomials of the second kind.
%
% Inputs:
%   p,q - order of the Zolotarev function Zpq(w,k)
%   k - elliptic function modulus
%
% Outputs:
%   h - FIR filter impulse response
%   wp - pass-band edge in [-1,1]
%   wm - peak in [ws,wp]
%   ws - stop-band edge in [-1,1]
%   a - coefficients of the zero-phase frequency response expanded in
%       Chebyshev polynomial of the first kind
%   aplus - coefficients of the generating function expanded in
%           Chebyshev polynomial of the second kind
%
% See Table I of [1] or Tables 4 and 5 of [2]:
% [1] "Approximation of Almost Equiripple Low-pass FIR Filters", M. Vlcek and
% P. Zahradnik, 2013 European Conference on Circuit Theory and Design,
% DOI: 10.1109/ECCTD.2013.6662301
% [2] "Almost Equiripple Low-Pass FIR Filters", M. Vlcek and
% P. Zahradnik, Circuits Syst Signal Process (2013) 32:743–757,
% DOI 10.1007/s00034-012-9484-0

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
  if nargin~=3 || nargout>6
    print_usage("[h,wp,wm,ws,a,aplus]=zolotarev_vlcek_zahradnik(p,q,k)");
  endif
  if ~isscalar(p)
    error("Expect p a scalar!")
  endif
  if p<=0
    error("Expect p>0!")
  endif
  if ~isscalar(q)
    error("Expect q a scalar!")
  endif
  if q<=0
    error("Expect q>0!")
  endif
  if ~isscalar(k)
    error("Expect k a scalar!")
  endif
  if imag(k)~=0
    error("Expect k real!")
  endif
  if k<=0 || k>=1
    error("Expect 0<k<1!")
  endif

  % Initialisation
  k2=k^2;
  K=ellipke(k2);
  n=p+q;
  u0=((2*p)+1)*K/((2*n)+2);
  [snu0,cnu0,dnu0]=ellipj(u0,k2);
  wp=(2*((cnu0/dnu0)^2))-1;
  ws=(2*(cnu0^2))-1;
  wq=(wp+ws)/2;
  Zu0=jacobi_Zeta(u0,k);
  wm=ws+(2*(snu0*cnu0)*Zu0/dnu0);

  % Body
  alpha=zeros(1,1+n+5);
  alpha(1+n)=1;
  c=zeros(7,1);
  for m=(n+2):-1:3,
    if 1
      % From [1,Table 4]
      c(1)= ((n*(n+2))-((m+3)*(m+5)))/8;

      c(2)=-((3*wm*((n*(n+2))-((m+2)*(m+4)))) ...
             +((m+3)*((2*m)+7)*(wm-wq)))/4;

      c(3)= ((3*((n*(n+2))-((m+1)*(m+3)))) ...
             +(12*wm*((((n+1)^2)*wm)-(((m+2)^2)*wq))) ...
             -(4*((m+2)*(m+3)*((wp*ws)-(wm*wq)))))/8;

      c(4)=-((3*((((n+1)^2)*wm)-(((m+1)^2)*wq))) ...
             -(((m+1)^2)*(wm-wq)) ...
             +(2*wm*((((n+1)^2)*(wm^2))-(((m+1)^2)*wp*ws))))/2;

      c(5)= ((3*((n*(n+2))-((m-1)*(m+1)))) ...
             +(12*wm*((((n+1)^2)*wm)-((m^2)*wq))) ...
             -(4*m*(m-1)*((wp*ws)-(wm*wq))))/8;

      c(6)=-((3*wm*((n*(n+2))-((m-2)*m))) ...
             +((m-1)*((2*m)-3)*(wm-wq)))/4;

      c(7)= ((n*(n+2))-((m-3)*(m-1)))/8;
    else
      % From zolotarev_vlcek_zahradnik_table_4.out
      c=[...
n^2+2*n-(m+3)^2-2*(m+3); ...
2*(m+2)^2*ws+6*(m+2)*ws+4*ws-2*(m+2)*wq-2*wq+2*(m+2)^2*wp+6*(m+2)*wp+4*wp-6*n^2*wm-12*n*wm+2*(m+2)^2*wm+2*(m+2)*wm-6*wm; ...
(-4*(m+1)^2*wp*ws)-12*(m+1)*wp*ws-8*wp*ws-4*(m+1)^2*wm*ws-8*(m+1)*wm*ws-4*wm*ws+4*(m+1)*wm*wq+4*wm*wq-4*(m+1)^2*wm*wp-8*(m+1)*wm*wp-4*wm*wp+12*n^2*wm^2+24*n*wm^2+12*wm^2+3*n^2+6*n-3*(m+1)^2-6*(m+1); ...
8*m^2*wm*wp*ws+16*m*wm*wp*ws+8*wm*wp*ws+4*m^2*ws+8*m*ws+4*ws+4*m^2*wp+8*m*wp+4*wp-8*n^2*wm^3-16*n*wm^3-8*wm^3-12*n^2*wm-24*n*wm+4*m^2*wm+8*m*wm-8*wm; ...
(-4*(m-1)*wp*ws)-4*(m-1)^2*wp*ws-8*(m-1)*wm*ws-4*(m-1)^2*wm*ws-4*wm*ws-4*(m-1)*wm*wq-4*wm*wq-8*(m-1)*wm*wp-4*(m-1)^2*wm*wp-4*wm*wp+12*n^2*wm^2+24*n*wm^2+12*wm^2+3*n^2+6*n-6*(m-1)-3*(m-1)^2; ...
2*(m-2)*ws+2*(m-2)^2*ws+2*(m-2)*wq+2*wq+2*(m-2)*wp+2*(m-2)^2*wp-6*n^2*wm-12*n*wm+6*(m-2)*wm+2*(m-2)^2*wm-2*wm; ...
n^2+2*n-2*(m-3)-(m-3)^2; ...
        ];
    endif
      alpha(1+m-3)=-alpha((1+m+3):-1:(1+m-2))*c(1:6)/c(7);    
    endfor
  % Normalisation
  s=sum(alpha(1:(n+1)).*(1:(n+1)));
  aplus=((-1)^p)*(n+1)*alpha(1:(n+1))/s;

  % Integration
  a=[0,aplus./(1:(n+1))];

  % Impulse response
  h=zeros(1,(2*n)+3);
  h(1:(n+1))=a(end:-1:2)/2;
  h((n+3):end)=a(2:end)/2;
  % Use the fast algorithm in freqz to calculate the zero-phase response
  wN=[0,(pi/(n+1)),(n*pi/(n+1)),pi];
  HN=freqz(h,1,wN).*(e.^(j*(n+1)*wN));
  if max(abs(imag(HN))>2e4*eps)
    warning("max(abs(imag(HN)))(%g)>2e4*eps",max(abs(imag(HN))));
  endif
  HN=real(HN);
  if mod(q,2)
    HN1=HN(3);
  else
    HN1=HN(4);
  endif
  if mod(p,2)
    HN2=HN(2);
  else
    HN2=HN(1);
  endif
  % Normalise h
  h(1+n+1)=-HN1;
  h=h/(HN2-HN1);
  
endfunction;
