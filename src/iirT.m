function [T,gradT,hessT]=iirT(w,x,U,V,M,Q,R,tol)
% [T,gradT,hessT]=iirT(w,x,U,V,M,Q,R,tol)
% Given the U real zeros, V real poles, M conjugate zeros and Q 
% conjugate poles of an IIR filter with decimation R find the  
% group delay, T, and gradient and Hessian at angular frequency w. 
% x is the vector [K R0 Rp r0 theta0 rp thetap] of coefficients of 
% the filter. K is a gain factor. R0 is a vector of U real zero 
% radiuses, Rp is a vector of V real pole radiuses. r0 is a vector 
% of M/2 zero radiuses and theta0 is a vector of M/2 zero angles 
% that together define M/2 conjugate pairs of zeros. Likewise, rp 
% is a vector of Q/2 pole radiuses and thetap is a vector of Q/2 
% pole angles that together define Q/2 conjugate pairs of poles. 
% The tol argument allows for errors in the complex number 
% calculations required if the real or complex poles have radius
% less than zero.
%
% TODO : Add an option to only calculate the diagonal of the Hessian
%
% Inputs:
%   w - vector of angular frequencies
%   x - coefficient vector 
%       [k; 
%        zR(1:U); 
%        pR(1:V); 
%        abs(z(1:Mon2)); angle(z(1:Mon2)); 
%        abs(p(1:Qon2)); angle(p(1:Qon2))];
%       where k is the gain coefficient, zR and pR represent real
%       zeros and poles and z and p represent conjugate zero and pole
%       pairs. 
%   U - number of real zeros
%   V - number of real poles
%   M - number of conjugate zero pairs
%   Q - number of conjugate pole pairs
%   R - decimation factor, pole pairs are for z^R
%   tol - tolerance for maximum imaginary component of a real value
%
% Outputs:
%   T - group delay at angular frequencies, w
%   gradT - gradient of group delay at angular frequencies, w,
%           with respect to x
%   hessT - hessian of group delay at angular frequencies, w,
%           with respect to x
%
% !!! NOTE WELL !!! :
%
%   1. For multiple frequencies results are returned with
%      frequency varying in dimension 1.
%
%   2. The gradients are with respect to the filter coefficients, 
%      NOT the frequency.
%
%   3. Note the Hessian is defined as:
%        del2fdelx1delx1  del2fdelx1delx2  del2fdelx1delx3 ...
%        del2fdelx2delx1  del2fdelx2delx2  del2fdelx2delx3 ...
%        etc
% 
% References:
% [1] A.G.Deczky, "Synthesis of recusive digital filters using the
% minimum p-error criterion" IEEE Trans. Audio Electroacoust.,
% Vol. AU-20, pp. 257-263, October 1972
% [2] M.A.Richards, "Applications of Deczkys Program for Recursive
% Filter Design to the Design of Recursive Decimators" IEEE Trans.
% ASSP-30 No. 5, pp. 811-814, October 1982

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

% Sanity checks
if (nargin<7) || (nargin>8) || (nargout>3)
  print_usage("[T,gradT,hessT]=iirT(w,x,U,V,M,Q,R,tol)");
endif
if nargin == 7
  tol=1e-9;
endif
if ~isscalar(U)
  error ("Expect U scalar");
endif
if ~isscalar(V)
  error ("Expect V scalar");
endif
if ~isscalar(M)
  error ("Expect M scalar");
endif
if ~isscalar(Q)
  error ("Expect Q scalar");
endif
if ~isscalar(R)
  error ("Expect R scalar");
endif
if ~isscalar(tol)
  error ("Expect tol scalar");
endif
if length(x) ~= 1+U+V+Q+M
  error ("Expect length(x) == 1+U+V+Q+M");
endif
if rem(M,2)
  error ("Expected an even number of conjugate zeros");
endif
if rem(Q,2)
  error ("Expected an even number of conjugate poles");
endif

% Allow empty frequency vector
if isempty(w) || (nargout==0)
  T=[]; gradT=[]; hessT=[]; return;
endif

% Constants
s=1/R;
w=w(:);
Nw=length(w);
Mon2=M/2;
Qon2=Q/2;
UV=U+V;
UVMon2=UV+Mon2;
UVM=UV+M;
UVMQon2=UVM+Qon2;
UVMQ=UVM+Q;

% Extract coefficients from x
K=x(1);
R0=x((1+1):(1+U));
R0=R0(:)';
Rp=x((1+U+1):(1+UV));
Rp=Rp(:)';
r0=x((1+UV+1):(1+UVMon2));
r0=r0(:)';
theta0=x((1+UVMon2+1):(1+UVM));
theta0=theta0(:)';
rp=x((1+UVM+1):(1+UVMQon2));
rp=rp(:)';
thetap=x((1+UVMQon2+1):(1+UVMQ));
thetap=thetap(:)';

% Sanity checks on x
if iscomplex(x)
  error("Complex coefficient found in x!");
endif

% In the following, the real zero coefficients are organised as
% (Nw, U), the real pole coefficients are organised as (Nw, V, R),
% the conjugate zero polynomial coefficients are organised 
% as (Nw, Mon2) and the conjugate pole polynomial coefficients 
% are organised as (Nw, Qon2, R)

% For real zeros
wZ=kron(w,ones(1,U));
coswZ=cos(wZ);
kR0=kron(ones(Nw,1),R0);
kR02=kron(ones(Nw,1),R0.^2);

% For real poles
kRp=kron(ones(Nw,1),Rp);
kRp=reshape(kron(ones(1,R),kRp),Nw,V,R);
kRps=kRp.^s;
kRp2s=kRps.^2;
wP=kron(ones(1,R),kron(w,ones(1,V)));
thetaRp=zeros(size(Rp));
sthetaRp=kron(ones(1,R),kron(ones(Nw,1),s*thetaRp));
spiPR=s*2*pi*kron(0:(R-1),ones(Nw,V));
kcoswP=reshape(cos(wP-sthetaRp-spiPR),Nw,V,R);

% For conjugate zeros
kr0=kron(ones(Nw,1),r0);
kr02=kron(ones(Nw,1),r0.^2);
w0=kron(w,ones(1,Mon2));
theta0=kron(ones(Nw,1),theta0);
cosw0Ptheta0=cos(w0+theta0);
cosw0Mtheta0=cos(w0-theta0);

% For conjugate poles create Nw-by-Qon2-by-R 3-D arrays
krp=kron(ones(Nw,1),rp);
krp=reshape(kron(ones(1,R),krp),Nw,Qon2,R);
krps=krp.^s;
krp2s=krps.^2;
wp=kron(ones(1,R),kron(w,ones(1,Qon2)));
sthetap=kron(ones(1,R),kron(ones(Nw,1),s*thetap));
spipR=s*2*pi*kron(0:(R-1),ones(Nw,Qon2));
kcoswpPsthetap=reshape(cos(wp+sthetap+spipR),Nw,Qon2,R);
kcoswpMsthetap=reshape(cos(wp-sthetap-spipR),Nw,Qon2,R);

numAR0=1-(2*kR0.*coswZ)+kR02;
denomARp=1-(2*kRps.*kcoswP)+kRp2s;
if any(any(denomARp == 0))
  error("denomARp has zero entry");
endif
numAzplus=1-(2*kr0.*cosw0Ptheta0)+kr02;
numAzminus=1-(2*kr0.*cosw0Mtheta0)+kr02;
denomAplus=1-(2*krps.*kcoswpPsthetap)+krp2s;
if any(any(denomAplus == 0))
  error("denomAplus has zero entry");
endif
denomAminus=1-(2*krps.*kcoswpMsthetap)+krp2s;
if any(any(denomAminus == 0))
  error("denomAminus has zero entry");
endif

%
% Delay
%

T=zeros(Nw,1);
numTZ=1-(kR0.*coswZ);
numTP=1-(kRps.*kcoswP);
numTpplus=1-(krps.*kcoswpPsthetap);
numTpminus=1-(krps.*kcoswpMsthetap);
numTzplus=1-(kr0.*cosw0Ptheta0);
numTzminus=1-(kr0.*cosw0Mtheta0);
Tp=sum(sum(numTP./denomARp,3),2) + ...
    sum(sum((numTpplus./denomAplus)+(numTpminus./denomAminus),3),2);
Tz=sum(numTZ./numAR0,2)+...
    sum((numTzplus./numAzplus)+(numTzminus./numAzminus),2);
T=-(((V+Q)*R)-U-M)+Tp-Tz;

% Sanity checks on T
T=fixResultNaN(T);
if any(isinf(T))
  error("T has inf!");
endif
if max(abs(imag(T)))>tol
  error("abs(imag(T))>tol!");
endif
T=real(T);
if nargout==1
  return;
endif

%
% Gradient of delay
%

% For real poles
iRpnz=find(Rp!=0);
Rps1=zeros(size(Rp));
Rps1(iRpnz)=Rp(iRpnz).^(s-1);
kRps1=kron(ones(Nw,1),Rps1);
kRps1=reshape(kron(ones(1,R),kRps1),Nw,V,R);

% For conjugate zeros
sinw0Ptheta0=sin(w0+theta0);
sinw0Mtheta0=sin(w0-theta0);

% For conjugate poles
rps1=zeros(size(rp));
irpnz=find(rp!=0);
rps1(irpnz)=rp(irpnz).^(s-1);
krps1=kron(ones(Nw,1),rps1);
krps1=reshape(kron(ones(1,R),krps1),Nw,Qon2,R);
krp2s1=krps1.*krps;
krp3s1=krp2s1.*krps;
ksinwpPsthetap=reshape(sin(wp+sthetap+spipR),Nw,Qon2,R);
ksinwpMsthetap=reshape(sin(wp-sthetap-spipR),Nw,Qon2,R);

% delT/delK
delTdelK=zeros(Nw,1);

% delT/delR0
numAR02=numAR0.^2;
delTdelR0=((2*kR0-(kR02+1).*coswZ)./numAR02);

% delT/delRp
numdelTdelRp=kRps1.*((1+kRp2s).*kcoswP-2*kRps);
denomARp2=denomARp.^2;
delTdelRp=s*sum(numdelTdelRp./denomARp2,3);

% delT/delr0
numAzminus2=numAzminus.^2;
numAzplus2=numAzplus.^2;
delTdelr0=((2*kr0-(kr02+1).*cosw0Mtheta0)./numAzminus2)+...
          ((2*kr0-(kr02+1).*cosw0Ptheta0)./numAzplus2);

% delT/deltheta0
delTdeltheta0=((kr0.*(kr02-1).*sinw0Mtheta0)./numAzminus2)-...
              ((kr0.*(kr02-1).*sinw0Ptheta0)./numAzplus2);

% delT/delrp
numdelTdelrpminus=((krps1+krp3s1).*kcoswpMsthetap)-(2*krp2s1);
numdelTdelrpplus =((krps1+krp3s1).*kcoswpPsthetap)-(2*krp2s1);
denomAminus2=denomAminus.^2;
denomAplus2=denomAplus.^2;
delTdelrp=s*sum((numdelTdelrpminus./denomAminus2)+...
                (numdelTdelrpplus./denomAplus2),3);

% delT/delthetap
numdelTdelthetapminus=(krps.*(1-krp2s)).*ksinwpMsthetap;
numdelTdelthetapplus =(krps.*(1-krp2s)).*ksinwpPsthetap;
delTdelthetap=s*sum((numdelTdelthetapminus./denomAminus2)-...
                    (numdelTdelthetapplus./denomAplus2),3);

% Make gradT
gradT=zeros(Nw,1+UVMQ);
gradT(:,1)=delTdelK;
gradT(:,(1+1):(1+U))=delTdelR0;
gradT(:,(1+U+1):(1+UV))=delTdelRp;
gradT(:,(1+UV+1):(1+UVMon2))=delTdelr0;
gradT(:,(1+UVMon2+1):(1+UVM))=delTdeltheta0;
gradT(:,(1+UVM+1):(1+UVMQon2))=delTdelrp;
gradT(:,(1+UVMQon2+1):(1+UVMQ))=delTdelthetap;

% Sanity checks on gradT
gradT=fixResultNaN(gradT);
if any(any(isinf(gradT)))
  error("gradT has inf!");
endif
if max(max(abs(imag(gradT))))>tol
  error("abs(imag(gradT))>tol!");
endif
gradT=real(gradT);
if nargout==2
  return;
endif

%
% Hessian of delay
%

% Extra stuff
kR03=kron(ones(Nw,1),R0.^3);
Rps2=zeros(size(Rp));
Rps2(iRpnz)=Rp(iRpnz).^(s-2);
kRps2=kron(ones(Nw,1),Rps2);
kRps2=reshape(kron(ones(1,R),kRps2),Nw,V,R);
kRp3s=kRp2s.*kRps;
kRp4s=kRp3s.*kRps;
kr03=kron(ones(Nw,1),r0.^3);
kr04=kron(ones(Nw,1),r0.^4);
rps2=zeros(size(rp));
rps2(irpnz)=rp(irpnz).^(s-2);
krps2=kron(ones(Nw,1),rps2);
krps2=reshape(kron(ones(1,R),krps2),Nw,Qon2,R);
krp4s=krp2s.^2;
kcoswP2=kcoswP.^2;
kcoswpMsthetap2=kcoswpMsthetap.^2;
kcoswpPsthetap2=kcoswpPsthetap.^2;

% Common denominators
numAR03=numAR0.^3;
denomARp3=denomARp.^3;
numAzminus3=numAzminus.^3;
numAzplus3=numAzplus.^3;
denomAminus3=denomAminus.^3;
denomAplus3=denomAplus.^3;

% Utility matrixes for the diagonals
DU=zeros(U,U,U);
for k=1:U, DU(k,k,k)=1; endfor
DU=reshape(DU,U,U*U);
DV=zeros(V,V,V);
for k=1:V, DV(k,k,k)=1; endfor
DV=reshape(DV,V,V*V);
DMon2=zeros(Mon2,Mon2,Mon2);
for k=1:Mon2, DMon2(k,k,k)=1; endfor
DMon2=reshape(DMon2,Mon2,Mon2*Mon2);
DQon2=zeros(Qon2,Qon2,Qon2);
for k=1:Qon2, DQon2(k,k,k)=1; endfor
DQon2=reshape(DQon2,Qon2,Qon2*Qon2);

% Note that the delay Hessian contains only diagonal sub-matrices
% that are constructed in the same way as the amplitude Hessian 
% diagonal correction matrices ie: a Nw*Qon2 or Nw*Mon2 matrix is
% converted to an array of Nw*Qon2*Qon2 or Nw*Mon2*Mon2 diagonal
% matrices

% hdel2TdelR02
del2TdelR02=2*(kR03.*coswZ-3*kR02+3*kR0.*coswZ-cos(2*wZ))./numAR03;
hdel2TdelR02=permute(reshape((del2TdelR02*DU)',U,U,Nw),[3,1,2]);

% hdel2TdelRp2

numdel2TdelRp2=(s+1)*kcoswP.*kRp4s + ...
               (2*((s-1)*kcoswP2 - (2*s+1))).*kRp3s + ...
               6*kcoswP.*kRp2s - ...
               2*(s+1)*kcoswP2.*kRps + 2*(2*s-1)*kRps - ...
               (s-1)*kcoswP;
del2TdelRp2=-s*kRps2.*numdel2TdelRp2./denomARp3;
del2TdelRp2=sum(del2TdelRp2,3);
hdel2TdelRp2=permute(reshape((del2TdelRp2*DV)',V,V,Nw),[3,1,2]);

% hdel2Tdelr02
del2Tdelr02=2*(kr03.*cosw0Mtheta0-...
               3*kr02+...
               3*kr0.*cosw0Mtheta0-...
               cos(2*(w0-theta0)))./numAzminus3;
del2Tdelr02=del2Tdelr02+2*(kr03.*cosw0Ptheta0-...
                           3*kr02+...
                           3*kr0.*cosw0Ptheta0-...
                           cos(2*(w0+theta0)))./numAzplus3;
hdel2Tdelr02=permute(reshape((del2Tdelr02*DMon2)',Mon2,Mon2,Nw),[3,1,2]);

% hdel2Tdeltheta0delr0
del2Tdeltheta0delr0=sinw0Ptheta0.*...
(kr04+2*kr03.*cosw0Ptheta0-6*kr02+2*kr0.*cosw0Ptheta0+1)./numAzplus3;
del2Tdeltheta0delr0=del2Tdeltheta0delr0 - sinw0Mtheta0.*...
(kr04+2*kr03.*cosw0Mtheta0-6*kr02+2*kr0.*cosw0Mtheta0+1)./numAzminus3;
hdel2Tdeltheta0delr0=...
permute(reshape((del2Tdeltheta0delr0*DMon2)',Mon2,Mon2,Nw),[3,1,2]);

% hdel2Tdeltheta02
del2Tdeltheta02=...
    (kr02.*cosw0Mtheta0-2*kr0.*(1+sinw0Mtheta0.^2)+cosw0Mtheta0)./numAzminus3;
del2Tdeltheta02=del2Tdeltheta02+...
    (kr02.*cosw0Ptheta0-2*kr0.*(1+sinw0Ptheta0.^2)+cosw0Ptheta0)./numAzplus3;
del2Tdeltheta02=(kr0-kr03).*del2Tdeltheta02;
hdel2Tdeltheta02=...
permute(reshape((del2Tdeltheta02*DMon2)',Mon2,Mon2,Nw),[3,1,2]);

% hdel2Tdelrp2
del2Tdelrp2=(2*krps.*(s*(krp2s-1)-(krp2s+1)).*(kcoswpPsthetap2)+...
             (s*(krp4s-1)+(krp4s+6*krp2s+1)).*kcoswpPsthetap-...
              4*s*krps.*(krp2s-1)-2*krps.*(krp2s+1))./denomAplus3;
del2Tdelrp2=del2Tdelrp2 +...
    (2*krps.*(s*(krp2s-1)-(krp2s+1)).*(kcoswpMsthetap2)+...
     (s*(krp4s-1)+(krp4s+6*krp2s+1)).*kcoswpMsthetap-...
     4*s*krps.*(krp2s-1)-2*krps.*(krp2s+1))./denomAminus3;
del2Tdelrp2=-s*krps2.*del2Tdelrp2;
del2Tdelrp2=sum(del2Tdelrp2,3);
hdel2Tdelrp2=permute(reshape((del2Tdelrp2*DQon2)',Qon2,Qon2,Nw),[3,1,2]);

% hdel2Tdelthetapdelrp
del2Tdelthetapdelrp=((2*krps.*(krp2s+1).*kcoswpMsthetap+...
                      (krp4s-6*krp2s+1)).*ksinwpMsthetap)./denomAminus3;
del2Tdelthetapdelrp=del2Tdelthetapdelrp-...
    ((2*krps.*(krp2s+1).*kcoswpPsthetap+...
      (krp4s-6*krp2s+1)).*ksinwpPsthetap)./denomAplus3;
del2Tdelthetapdelrp=s*s*krps1.*del2Tdelthetapdelrp;
del2Tdelthetapdelrp=sum(del2Tdelthetapdelrp,3);
hdel2Tdelthetapdelrp=...
    permute(reshape((del2Tdelthetapdelrp*DQon2)',Qon2,Qon2,Nw),[3,1,2]);

% hdel2Tdelthetap2
del2Tdelthetap2=...
    (2*krps.*(kcoswpPsthetap2)+...
     (krp2s+1).*kcoswpPsthetap-4*krps)./denomAplus3;
del2Tdelthetap2=del2Tdelthetap2+...
    (2*krps.*(kcoswpMsthetap2)+...
     (krp2s+1).*kcoswpMsthetap-4*krps)./denomAminus3;
del2Tdelthetap2=s*s*krps.*(krp2s-1).*del2Tdelthetap2;
del2Tdelthetap2=sum(del2Tdelthetap2,3);
hdel2Tdelthetap2=...
    permute(reshape((del2Tdelthetap2*DQon2)',Qon2,Qon2,Nw),[3,1,2]);

% hdel2Tdelr02
del2Tdelr02=2*(kr03.*cosw0Mtheta0-...
               3*kr02+3*kr0.*cosw0Mtheta0-...
               cos(2*(w0-theta0)))./numAzminus3;
del2Tdelr02=del2Tdelr02+2*(kr03.*cosw0Ptheta0-...
                           3*kr02+3*kr0.*cosw0Ptheta0-...
                           cos(2*(w0+theta0)))./numAzplus3;
hdel2Tdelr02=permute(reshape((del2Tdelr02*DMon2)',Mon2,Mon2,Nw),[3,1,2]);

% hdel2Tdeltheta0delr0
del2Tdeltheta0delr0=sinw0Ptheta0.*...
(kr04+2*kr03.*cosw0Ptheta0-6*kr02+2*kr0.*cosw0Ptheta0+1)./numAzplus3;
del2Tdeltheta0delr0=del2Tdeltheta0delr0 - sinw0Mtheta0.*...
(kr04+2*kr03.*cosw0Mtheta0-6*kr02+2*kr0.*cosw0Mtheta0+1)./numAzminus3;
hdel2Tdeltheta0delr0=...
permute(reshape((del2Tdeltheta0delr0*DMon2)',Mon2,Mon2,Nw),[3,1,2]);

% hdel2Tdeltheta02
del2Tdeltheta02=...
    (kr02.*cosw0Mtheta0-2*kr0.*(1+sinw0Mtheta0.^2)+cosw0Mtheta0)./numAzminus3;
del2Tdeltheta02=del2Tdeltheta02+...
    (kr02.*cosw0Ptheta0-2*kr0.*(1+sinw0Ptheta0.^2)+cosw0Ptheta0)./numAzplus3;
del2Tdeltheta02=(kr0-kr03).*del2Tdeltheta02;
hdel2Tdeltheta02=...
permute(reshape((del2Tdeltheta02*DMon2)',Mon2,Mon2,Nw),[3,1,2]);

% hdel2Tdelrp2
del2Tdelrp2=(2*krps.*(s*(krp2s-1)-(krp2s+1)).*(kcoswpPsthetap2)+...
             (s*(krp4s-1)+(krp4s+6*krp2s+1)).*kcoswpPsthetap-...
              4*s*krps.*(krp2s-1)-2*krps.*(krp2s+1))./denomAplus3;
del2Tdelrp2=del2Tdelrp2 +...
    (2*krps.*(s*(krp2s-1)-(krp2s+1)).*(kcoswpMsthetap2)+...
     (s*(krp4s-1)+(krp4s+6*krp2s+1)).*kcoswpMsthetap-...
     4*s*krps.*(krp2s-1)-2*krps.*(krp2s+1))./denomAminus3;
del2Tdelrp2=-s*krps2.*del2Tdelrp2;
del2Tdelrp2=sum(del2Tdelrp2,3);
hdel2Tdelrp2=permute(reshape((del2Tdelrp2*DQon2)',Qon2,Qon2,Nw),[3,1,2]);

% hdel2Tdelthetapdelrp
del2Tdelthetapdelrp=((2*krps.*(krp2s+1).*kcoswpMsthetap+...
                      (krp4s-6*krp2s+1)).*ksinwpMsthetap)./denomAminus3;
del2Tdelthetapdelrp=del2Tdelthetapdelrp-...
    ((2*krps.*(krp2s+1).*kcoswpPsthetap+...
      (krp4s-6*krp2s+1)).*ksinwpPsthetap)./denomAplus3;
del2Tdelthetapdelrp=s*s*krps1.*del2Tdelthetapdelrp;
del2Tdelthetapdelrp=sum(del2Tdelthetapdelrp,3);
hdel2Tdelthetapdelrp=...
    permute(reshape((del2Tdelthetapdelrp*DQon2)',Qon2,Qon2,Nw),[3,1,2]);

% hdel2Tdelthetap2
del2Tdelthetap2=...
    (2*krps.*(kcoswpPsthetap2)+...
     (krp2s+1).*kcoswpPsthetap-4*krps)./denomAplus3;
del2Tdelthetap2=del2Tdelthetap2+...
    (2*krps.*(kcoswpMsthetap2)+...
     (krp2s+1).*kcoswpMsthetap-4*krps)./denomAminus3;
del2Tdelthetap2=s*s*krps.*(krp2s-1).*del2Tdelthetap2;
del2Tdelthetap2=sum(del2Tdelthetap2,3);
hdel2Tdelthetap2=...
    permute(reshape((del2Tdelthetap2*DQon2)',Qon2,Qon2,Nw),[3,1,2]);


% Make the Hessian of the delay response
hessT=zeros(Nw,1+UVMQ,1+UVMQ);

% delTdelR0 column
hessT(:,(1+1):(1+U),(1+1):(1+U))=hdel2TdelR02;
% delTdelRp column
hessT(:,(1+U+1):(1+UV),(1+U+1):(1+UV))=hdel2TdelRp2;
% delTdelr0 column
hessT(:,(1+UV+1):(1+UVMon2),(1+UV+1):(1+UVMon2))=hdel2Tdelr02;
hessT(:,(1+UVMon2+1):(1+UVM),(1+UV+1):(1+UVMon2))=hdel2Tdeltheta0delr0;
% delTdeltheta0 column
hessT(:,(1+UVMon2+1):(1+UVM),(1+UVMon2+1):(1+UVM))=hdel2Tdeltheta02;
% delTdelrp column
hessT(:,(1+UVM+1):(1+UVMQon2),(1+UVM+1):(1+UVMQon2))=hdel2Tdelrp2;
hessT(:,(1+UVMQon2+1):(1+UVMQ),(1+UVM+1):(1+UVMQon2))=hdel2Tdelthetapdelrp;
% delTdelthetap column
hessT(:,(1+UVMQon2+1):(1+UVMQ),(1+UVMQon2+1):(1+UVMQ))=hdel2Tdelthetap2;

% delTdelr0 row
hessT(:,(1+UV+1):(1+UVMon2),(1+UVMon2+1):(1+UVM))= ...
    permute(hdel2Tdeltheta0delr0,[1,3,2]);
% delTdelrp row
hessT(:,(1+UVM+1):(1+UVMQon2),(1+UVMQon2+1):(1+UVMQ))= ...
    permute(hdel2Tdelthetapdelrp, [1,3,2]);

% Remove a redundant frequency dimension
sizeH=size(hessT);
if sizeH(1) == 1
  hessT=reshape(hessT,sizeH(2),sizeH(3));
endif

% Sanity checks on hessT
hessT=fixResultNaN(hessT);
if any(any(any(isinf(hessT))))
  error("hessT has inf!");
endif
if max(max(max(abs(imag(hessT)))))>tol
  error("abs(imag(hessT))>tol!");
endif
hessT=real(hessT);

endfunction
