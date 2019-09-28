function [wr,w,Q,twoargHp,wdr,Qdr,twoargHpdr,Zpqmax,wmax,wp,ws]= ...
         zolotarevFIRcascade_Q(arg1,p,q,k)
% Helper function. Given p, q, and k, the parameters of a Zolotarev
% polynomial, calculate the normalised zero-phase response, Q, in the
% w-domain.
%
% See:
% [1] "Cascade Structure of Narrow Equiripple Bandpass FIR Filters",
% P.Zahradnik, M.Susta,B.Simak and M.Vlcek, IEEE Transactions on Circuits
% and Systems-II:Express Briefs, Vol. 64, No. 4, April 2017, pp. 407-411
%
% Inputs:
%   arg1 - either an integer defining the number of complex numbers
%          in each of the three parts, u1, u2 and u3, defining the path,
%          u, or a struct defining the y1, x2 and y3 components of the path.
%          Both u and {y1,x2,y3} should correspond to u1=[0,jK'],
%          u2=[jK',K+jK'] and u3=[K+jK',K] respectively.
%   p,q,k - Zolotarev polynomial parameters
%
% Outputs:
%   wr - list of all roots of Q, including those that may be at +1 and/or -1
%   w - w-domain path corresponding to u
%   Q - normalised zero-phase response
%   twoargHp - 2x the phase response of the Jacobi Eta function of u+u0
%   wdr - locations of double roots of Q.
%   Qdr - values of Q at wdr
%   twoargHpdr - values of twoargHp at multiples of pi/(p+q)
%   Zpqmax - maximum value of the Zolotarev polynomial, Zpq
%   wmax - position in the w-domain of Zpqmax
%   wp - w-domain upper edge of the central lobe of the Zolotarev polynomial 
%   ws - w-domain lower edge of the central lobe of the Zolotarev polynomial 
  
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
  
  if (nargin~=4) || (nargout>11)
    print_usage("[wr,w,Q,twoargHp,wdr,Qdr,twoargHpdr,Zpqmax,wmax,wp,ws]= ...\n\
      zolotarevFIRcascade_Q(nf,p,q,k)\n\
[wr,w,Q,twoargHp,wdr,Qdr,twoargHpdr,Zpqmax,wmax,wp,ws]= ...\n\
      zolotarevFIRcascade_Q({y1,x2,y3},p,q,k)");
  endif

  n=p+q;
  K=ellipke(k^2);
  Kp=ellipke(1-(k^2));
  u0=p*K/n;

  % Set up the path in the u-domain
  if isstruct(arg1) && all(isfield(arg1,{"y1","x2","y3"}))
    y1=arg1.y1;x2=arg1.x2;y3=arg1.y3;
    y1=sort(y1(:),"ascend")';
    x2=sort(x2(:),"ascend")';
    y3=sort(y3(:),"descend")';
    if iscomplex(y1) || iscomplex(x2) || iscomplex(y3)
      error("arg1 complex");
    endif
    if min(y1)<0 || max(y1)>1
      error("min(y1)<0 || max(y1)>1");
    endif
    if min(x2)<0 || max(x2)>1
      error("min(x2)<0 || max(x2)>1");
    endif
    if min(y3)<0 || max(y3)>1
      error("min(y3)<0 || max(y3)>1");
    endif
    u1=j*Kp*y1;
    Ru1=1:length(y1);
    u2=(K*x2)+(j*Kp);
    u3=K+(j*Kp*y3);
    Ru3=(length(y1)+length(x2)+1):(length(y1)+length(x2)+length(y3));
    u=[u1,u2,u3];
  elseif isscalar(arg1) && isreal(arg1)
    nf=round(arg1);
    u1=j*Kp*(0:nf)/nf;
    Ru1=1:(nf+1);
    u2=(K*(1:nf)/nf)+(j*Kp);
    u3=K+(j*Kp*((nf-1):-1:0)/nf);
    Ru3=(((2*nf)+2):((3*nf)+1));
    u=[u1,u2,u3];
  else
    error("arg1 undefined");
  endif

  % Evaluate the Zolotarev polynomial over u
  [w,Q,twoargHp,Zpqmax,wmax,wp,ws]=zolotarevFIRcascade_Qu(u,u0,Kp,p,q,k);

  % Find the zeros of Q in the u-domain with cubic spline interpolation
  ur1=spline((twoargHp(Ru1)),imag(u(Ru1)), (1:q)*pi/n);
  ur3=spline((twoargHp(Ru3)),imag(u(Ru3)),-(1:p)*pi/n);

  % Choose the double zeros of Q in the u-domain
  if     mod(q,2)==1 && mod(p,2)==1
    ur1=ur1(2:2:end);
    ur3=ur3(2:2:end);
  elseif mod(q,2)==0 && mod(p,2)==1
    ur1=ur1(1:2:end);
    ur3=ur3(2:2:end);
  elseif mod(q,2)==1 && mod(p,2)==0
    ur1=ur1(2:2:end);
    ur3=ur3(1:2:end);
  else
    ur1=ur1(1:2:end);
    ur3=ur3(1:2:end);
  endif

  % Convert locations of double roots of Q from u-domain to w-domain
  [wur1,Qur1,twoargHpur1]=zolotarevFIRcascade_Qu((j*ur1),u0,Kp,p,q,k);
  if max(abs(Qur1))>20*eps
    error("max(abs(Qur1))>20*eps");
  endif
  [wur3,Qur3,twoargHpur3]=zolotarevFIRcascade_Qu(K+(j*ur3),u0,Kp,p,q,k);
  if max(abs(Qur3))>20*eps
    error("max(abs(Qur3))>20*eps");
  endif
  wdr=[wur1,wur3];
  Qdr=[Qur1,Qur3];
  twoargHpdr=[twoargHpur1,twoargHpur3];

  % Build the complete list of roots of Q
  wr=kron([wur1,wur3],[1,1]);
  if mod(q,2)==1 
    wr=[-1 wr];
  endif
  if mod(p,2)==1
    wr=[1 wr];
  endif
  % Sort ascending in z-domain angular frequency
  wr=sort(wr,"descend");
  if length(wr)~=n
    error("length(wr)~=n");
  endif
  
endfunction

function [w,Q,twoargHp,Zpqmax,wmax,wp,ws]=zolotarevFIRcascade_Qu(u,u0,Kp,p,q,k)
% [w,Q,twoargHp,Zpqmax,wmax,wp,ws]=zolotarevFIRcascade_Qu(u,u0,Kp,p,q,k)
% Helper function for zolotarevFIRcascade_Q
  
  if (nargin~=6) || nargout>7
    print_usage("[w,Q,twoargHp,Zpqmax,wmax,wp,ws]= ...\n\
      zolotarevFIRcascade_Qu(u,u0,Kp,p,q,k)");
  endif
  
  n=p+q;

  [snu0,cnu0,dnu0]=ellipj(u0,k^2);
  Zu0=jacobi_Zeta(u0,k);

  wp=(2*((cnu0/dnu0)^2))-1;
  ws=(2*(cnu0^2))-1;
  wmax=ws+(2*snu0*cnu0*Zu0/dnu0);
  smax=elliptic_F(asin(sqrt(Zu0/(((k^2)*snu0)*((cnu0*dnu0)+(snu0*Zu0))))),k);
  umax=smax+(j*Kp);
  Hpmax=jacobi_Eta(umax+u0,k);
  Hmmax=jacobi_Eta(umax-u0,k);
  Zpqmax=real(((-1)^p)*cosh(n*log(Hpmax./Hmmax)));
  
  [snu,cnu]=ellipj(u,k^2);
  w=(((snu*cnu0).^2)+((cnu*snu0).^2))./((snu.^2)-(snu0^2));
  if max(imag(w))>eps
    error("max(imag(w))>eps");
  endif
  w=real(w);
  
  Hp=zeros(size(u));
  Hm=zeros(size(u));
  Hp=jacobi_Eta(u+u0,k);
  Hm=jacobi_Eta(u-u0,k);
  Hpm=Hp./Hm;
  
  Zpq=real(((-1)^p)*cosh(n*log(Hpm)));
  Q=(1+Zpq)/(1+Zpqmax);
  twoargHp=2*arg(Hp);

endfunction
