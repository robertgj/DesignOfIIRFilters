function b=zolotarev_vlcek_unbehauen(p,q,k)
% b=zolotarev_vlcek_unbehauen(p,q,k)
% For the Zolotarev function, Zpq(w,k), defined by Vlcek and Unbehauen,
% calculate the power series expansion coefficients, b(m)w^m, as per
% Table IV of [1](with the corrections in [2]). I failed to duplicate the
% results of Table VI for the Chebychev Type 1 expansion shown in Table V
% (with the corrections in [2]).
% [1] "Zolotarev Polynomials and Optimal FIR Filters", M. Vlcek and
%      R. Unbehauen, IEEE Transactions on Signal Processing, Vol. 47,
%      No. 3, March, 1999, pp. 717-730
% [2] Corrections to "Zolotarev Polynomials and Optimal FIR Filters",
%     M. Vlcek and R. Unbehauen, IEEE Transactions on Signal Processing,
%     Vol. 48, No.7, July, 2000 p. 2171

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
if nargin~=3 || nargout>1
  print_usage("b=zolotarev_vlcek_unbehauen(p,q,k)");
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
u0=p*K/n;
[snu0,cnu0,dnu0]=ellipj(u0,k2);
wp=(2*((cnu0/dnu0)^2))-1;
ws=(2*(cnu0^2))-1;
wq=(wp+ws)/2;
Zu0=jacobi_Zeta(u0,k);
wm=ws+(2*(snu0*cnu0)*Zu0/dnu0);

% Table IV of [1]
b=zolotarev_vlcek_unbehauen_power_sum(p,q,wp,ws,wq,wm);

endfunction;

% Table IV of [1]
function b=zolotarev_vlcek_unbehauen_power_sum(p,q,wp,ws,wq,wm)
  n=p+q;
  beta=zeros(1,1+n+4);
  beta(1+n)=1;
  d=zeros(1,6);
  for m=(n+2):-1:3,
    d(1)=(m+2)*(m+1)*wp*ws*wm;
    d(2)=-((m+1)*(m-1)*wp*ws)-((m+1)*((2*m)+1)*(wm*wq));
    d(3)=(wm*(((n^2)*(wm^2))-((m^2)*wp*ws)))+...
         ((m^2)*(wm-wq))+ ...
         (3*m*(m-1)*wq);
    d(4)=((m-1)*(m-2)*((wp*ws)-(wm*wq)-1))-...
         (3*wm*(((n^2)*wm)-(((m-1)^2)*wq)));
    d(5)=(((2*m)-5)*(m-2)*(wm-wq))+ ...
         (3*wm*((n^2)-((m-2)^2)));
    d(6)=(n^2)-((m-3)^2);
    beta(1+m-3)=sum(d(1:5).*beta(1+(m+3)-(1:5)))/d(6);
  endfor
  sn=sum(beta(1+(0:n)));
  b=((-1)^p)*beta(1+(0:n))/sn;
endfunction;

% Table V of [1]. This does not reproduce the a(m) of Table VI of [1]
function a=zolotarev_vlcek_unbehauen_chebychev_sum(p,q,wp,ws,wq,wm)
  n=p+q;
  alpha=zeros(1,1+n+5);
  alpha(1+n)=1;
  c=zeros(1,7);
  for m=(n+2):-1:3,
    c(1)=((n^2)-((m+3)^2))/8;
    c(2)=((((2*m)+5)*(m+2)*(wm-wq))+...
          (3*wm*((n^2)-((m+2)^2))))/4;
    c(3)=((3*((n^2)-((m+1)^2))/4)+...
          (3*wm*(((n^2)*wm)-(((m+1)^2)*wq)))- ...
          ((m+1)*(m+2)*((wp*ws)-(wm*wq))))/2;
    c(4)=(3*((n^2)-(m^2))/2)+ ...
         ((m^2)*(wm-wq))+ ...
         (wm*(((n^2)*(wm^2))-((m^2)*wp*ws)));
    c(5)=((3*((n^2)-((m-1)^2))/4)+ ...
          (3*wm*(((n^2)*wm)-(((m-1)^2)*wq)))- ...
          ((m-1)*(m-2)*((wp*ws)-(wm*wq))))/2;
    c(6)=((((2*m)-5)*(m-2)*(wm-wq))+ ...
          (3*wm*((n^2)-((m-2)^2))))/4;
    c(7)=((n^2)-((m-3)^2))/8;
    alpha(1+m-3)=sum(c(1:6).*alpha(1+(m+4)-(1:6)))/c(7);
  endfor

  sn=(alpha(1+0)/2)+sum(alpha(1+(1:n)));
  a(1+0)=((-1)^p)*alpha(1+0)/(2*sn);
  for m=1:n,
    a(1+m)=((-1)^p)*alpha(1+m)/sn;
  endfor
endfunction;
