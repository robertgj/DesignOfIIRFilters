function [P,gradP,hessP]=iirP(w,x,U,V,M,Q,R,tol)
% [P,gradP,hessP]=iirP(w,x,U,V,M,Q,R,tol)
% Given the U real zeros, V real poles, M conjugate zeros and 
% Q conjugate poles of an IIR filter with decimation R find the 
% phase response, P, gradients and second derivatives at 
% angular frequency w. x is the vector [K R0 Rp r0 theta0 rp thetap]
% of coefficients of the filter. K is a gain factor. R0 is a vector
% of U real zero radiuses, Rp is a vector of V real pole radiuses.
% r0 is a vector of M/2 zero radiuses and theta0 is a vector of M/2
% zero angles that together define M/2 conjugate pairs of zeros. 
% Likewise, rp is a vector of Q/2 pole radiuses and thetap is a 
% vector of Q/2 pole angles that together define Q/2 conjugate 
% pairs of poles.
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
%   P - phase response at angular frequencies, w
%   gradP - gradient of phase response at angular frequencies, w,
%           with respect to x
%   hessP - hessian of phase response at angular frequencies, w,
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
%   4. Do not expect sensible results when w=0 and R0j=1 or
%      if w=0 and r0j=1 and theta0j=0
% 
% References:
% [1] A.G.Deczky, "Synthesis of recusive digital filters using the
% minimum p-error criterion" IEEE Trans. Audio Electroacoust.,
% Vol. AU-20, pp. 257-263, October 1972
% [2] M.A.Richards, "Applications of Deczkys Program for Recursive
% Filter Design to the Design of Recursive Decimators" IEEE Trans.
% ASSP-30 No. 5, pp. 811-814, October 1982

% Copyright (C) 2017-2025 Robert G. Jenssen
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
if nargin<7 || nargout>3
  print_usage("[P,gradP,hessP]=iirP(w,x,U,V,M,Q,R [,tol])");
endif
if nargin == 7
  tol=2e-12;
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

% Sanity checks on x
if any(iscomplex(x))
  error("Complex coefficient found in x!");
endif

% Allow empty frequency vector
if isempty(w)
  P=[]; gradP=[]; hessP=[]; return;
endif

% Constants
s=1/R;
w=w(:);
Nw=length(w);
Mon2=M/2;
Qon2=Q/2;

% Extract coefficients from x
x=x(:)';
K=x(1);
R0=x((1+1):(1+U));
Rp=x((1+U+1):(1+U+V));
r0=x((1+U+V+1):(1+U+V+Mon2));
theta0=x((1+U+V+Mon2+1):(1+U+V+M));
rp=x((1+U+V+M+1):(1+U+V+M+Qon2));
thetap=x((1+U+V+M+Qon2+1):(1+U+V+M+Q));

if 0 && R>2 && any(rp<0)
  error("FIXME: R>2 && any(rp)<0 fails!");
endif

% In the following, the real zero coefficients are organised as
% (Nw, U), the real pole coefficients are organised as (Nw, V, R),
% the conjugate zero polynomial coefficients are organised 
% as (Nw, Mon2) and the conjugate pole polynomial coefficients 
% are organised as (Nw, Qon2, R). Recall that w is a column vector
% and R0, Rp, r0, theta0, rp and thetap are row vectors.

%
% Phase
%

% For real zeros create Nw-by-U arrays
PR0=zeros(Nw,1);
if U > 0
  wR0=kron(w,ones(1,U));
  sinwR0=sin(wR0);
  coswR0=cos(wR0);
  kR0=kron(ones(Nw,1),R0);
  kPR0=atan2(sinwR0,(coswR0 - kR0));
  PR0=sum(kPR0,2);
endif

% For real poles create Nw-by-V-by-R 3-D arrays
PRp=zeros(Nw,1);
if V > 0
  % atan2 does not take complex arguments
  absRp=abs(Rp);
  thetaRp=(Rp<0)*pi;
  kaRps=reshape(kron(ones(1,R),kron(ones(Nw,1),absRp.^s)),Nw,V,R);
  ksthetaRp=reshape(kron(ones(1,R),kron(ones(Nw,1),s*thetaRp)),Nw,V,R);
  kcoswRp=reshape(kron(ones(1,R),kron(cos(w),ones(1,V))),Nw,V,R);
  ksinwRp=reshape(kron(ones(1,R),kron(sin(w),ones(1,V))),Nw,V,R);
  kspiRp=reshape(s*2*pi*kron(0:(R-1),ones(Nw,V)),Nw,V,R);
  kcosspiRp=cos(kspiRp+ksthetaRp);
  ksinspiRp=sin(kspiRp+ksthetaRp);
  numPRp=ksinwRp-(kaRps.*ksinspiRp);
  denomPRp=kcoswRp-(kaRps.*kcosspiRp);
  kPRp=atan2(numPRp,denomPRp);
  PRp=sum(sum(kPRp,3),2);
endif

% For conjugate zeros create Nw-by-Mon2 arrays
Pr0=zeros(Nw,1);
if M > 0
  kr0=kron(ones(Nw,1),r0);
  kr02=kron(ones(Nw,1),r0.^2);
  kcoswr0=kron(cos(w),ones(1,Mon2));
  ksinwr0=kron(sin(w),ones(1,Mon2));
  kcos2wr0=kron(cos(2*w),ones(1,Mon2));
  ksin2wr0=kron(sin(2*w),ones(1,Mon2));
  kcostheta0=kron(ones(Nw,1),cos(theta0));
  numPr0=ksin2wr0-2*kr0.*kcostheta0.*ksinwr0;
  denomPr0=kcos2wr0-2*kr0.*kcostheta0.*kcoswr0+kr02;
  kPr0=atan2(numPr0,denomPr0);
  Pr0=sum(kPr0,2);
endif

% For conjugate poles create Nw-by-Qon2-by-R 3-D arrays
Prp=zeros(Nw,1);
if Q > 0
  % atan2 does not take complex arguments
  absrp=abs(rp);
  athetap=thetap-((rp<0)*pi);
  karps=reshape(kron(ones(1,R),kron(ones(Nw,1),absrp.^s)),Nw,Qon2,R);
  karp2s=reshape(kron(ones(1,R),kron(ones(Nw,1),absrp.^(2*s))),Nw,Qon2,R);
  ksathetap=reshape(kron(ones(1,R),kron(ones(Nw,1),s*athetap)),Nw,Qon2,R);
  kspirp=reshape(s*2*pi*kron(0:(R-1),ones(Nw,Qon2)),Nw,Qon2,R);
  kcossathetap=cos(kspirp+ksathetap);
  kwrp=reshape(kron(ones(1,R),kron(w,ones(1,Qon2))),Nw,Qon2,R);
  kcoswrp=reshape(kron(ones(1,R),kron(cos(w),ones(1,Qon2))),Nw,Qon2,R);
  kcos2wrp=reshape(kron(ones(1,R),kron(cos(2*w),ones(1,Qon2))),Nw,Qon2,R);
  ksinwrp=reshape(kron(ones(1,R),kron(sin(w),ones(1,Qon2))),Nw,Qon2,R);
  ksin2wrp=reshape(kron(ones(1,R),kron(sin(2*w),ones(1,Qon2))),Nw,Qon2,R);
  numParp=ksin2wrp-2*karps.*kcossathetap.*ksinwrp;
  denomParp=kcos2wrp-2*karps.*kcossathetap.*kcoswrp+karp2s;
  kPrp=atan2(numParp,denomParp);
  Prp=sum(sum(kPrp,3),2);
endif

% Phase
P=((((V+Q)*R)-(U+M))*w)+PR0-PRp+Pr0-Prp;
if iscomplex(P)
   error("Complex value found in P!?!");
endif

% Phase unwrapping
P=unwrap(mod(P,2*pi));
if nargout==1
  return;
endif

%
% Gradient of phase with respect to coefficients
%

gradP=zeros(Nw,1+U+V+M+Q);

% For real zeros create Nw-by-U arrays
if U > 0
  kR02=kron(ones(Nw,1),R0.^2);
  denomR0=1-(2*kR0.*coswR0)+kR02;
  if any(any(denomR0 == 0))
    error("denomAR0 has zero entry");
  endif
  gradPR0=sinwR0./denomR0;
  gradP(:,(1+1):(1+U))=gradPR0;
endif

% For real poles create Nw-by-V-by-R 3-D arrays then sum over R
if V > 0
  iRpnz=find(Rp~=0);
  Rpsm1=zeros(size(Rp));
  Rpsm1(iRpnz)=Rp(iRpnz).^(s-1);
  kRpsm1=reshape(kron(ones(1,R),kron(ones(Nw,1),Rpsm1)),Nw,V,R);
  kRps=reshape(kron(ones(1,R),kron(ones(Nw,1),Rp.^s)),Nw,V,R);
  kRp2s=reshape(kron(ones(1,R),kron(ones(Nw,1),Rp.^(2*s))),Nw,V,R);
  kwRp=reshape(kron(ones(1,R),kron(w,ones(1,V))),Nw,V,R);
  kcoswspiRp=cos(kwRp-kspiRp);
  ksinwspiRp=sin(kwRp-kspiRp);
  denomRp=1-(2*kRps.*kcoswspiRp)+kRp2s;
  if any(any(denomRp == 0))
    error("denomRp has zero entry");
  endif
  gradPRp=-s*sum((kRpsm1.*ksinwspiRp)./denomRp,3);
  if max(max(abs(imag(gradPRp))))>tol
    error("abs(imag(gradPRp))>tol!");
  endif
  gradPRp=real(gradPRp);
  gradP(:,(1+U+1):(1+U+V))=gradPRp;
endif

% For conjugate zeros create Nw-by-Mon2 arrays
if M > 0
  P0n=ksin2wr0-(2*kr0.*kcostheta0.*ksinwr0);
  P0d=kcos2wr0-(2*kr0.*kcostheta0.*kcoswr0)+kr02;
  P0n2d2=P0n.^2 + P0d.^2;
  ksintheta0=kron(ones(Nw,1),sin(theta0));
  delP0ndelr0=-(2*kcostheta0.*ksinwr0);
  delP0ddelr0=-(2*kcostheta0.*kcoswr0)+(2*kr0);
  delP0ndeltheta0=(2*kr0.*ksintheta0.*ksinwr0);
  delP0ddeltheta0=(2*kr0.*ksintheta0.*kcoswr0);

  gradPr0=((P0d.*delP0ndelr0)-(P0n.*delP0ddelr0))./P0n2d2;
  gradP(:,(1+U+V+1):(1+U+V+Mon2))=gradPr0;

  gradPtheta0=((P0d.*delP0ndeltheta0)-(P0n.*delP0ddeltheta0))./P0n2d2;
  gradP(:,(1+U+V+Mon2+1):(1+U+V+M))=gradPtheta0;
endif

% For conjugate poles create Nw-by-Qon2-by-R 3-D arrays then sum over R
if Q > 0
  irpnz=find(rp~=0);
  rpsm1=zeros(1,Qon2);
  rpsm1(irpnz)=rp(irpnz).^(s-1);
  rp2sm1=zeros(1,Qon2);
  rp2sm1(irpnz)=rp(irpnz).^((2*s)-1);
  krpsm1=reshape(kron(ones(1,R),kron(ones(Nw,1),rpsm1)),Nw,Qon2,R);
  krp2sm1=reshape(kron(ones(1,R),kron(ones(Nw,1),rp2sm1)),Nw,Qon2,R);
  krps=reshape(kron(ones(1,R),kron(ones(Nw,1),rp.^s)),Nw,Qon2,R);
  krp2s=reshape(kron(ones(1,R),kron(ones(Nw,1),rp.^(2*s))),Nw,Qon2,R);
  ksthetap=reshape(kron(ones(1,R),kron(ones(Nw,1),s*thetap)),Nw,Qon2,R);
  kcossthetap=cos(kspirp+ksthetap);
  ksinsthetap=sin(kspirp+ksthetap);

  Ppn=ksin2wrp-(2*krps.*kcossthetap.*ksinwrp);
  Ppd=kcos2wrp-(2*krps.*kcossthetap.*kcoswrp)+krp2s;
  Ppn2d2=(Ppn.^2) + (Ppd.^2);
  delPpndelrp=-2*s*krpsm1.*kcossthetap.*ksinwrp;
  delPpddelrp=-(2*s*krpsm1.*kcossthetap.*kcoswrp) + (2*s*krp2sm1);
  delPpndelthetap=2*s*krps.*ksinsthetap.*ksinwrp;
  delPpddelthetap=2*s*krps.*ksinsthetap.*kcoswrp;
  
  kgradPrp=-((Ppd.*delPpndelrp)-(Ppn.*delPpddelrp))./Ppn2d2;
  gradPrp=sum(kgradPrp,3);
  if max(max(abs(imag(gradPrp))))>tol
    error("abs(imag(gradPrp))>tol!");
  endif
  gradPrp=real(gradPrp);
  gradP(:,(1+U+V+M+1):(1+U+V+M+Qon2))=gradPrp;

  kgradPthetap=-((Ppd.*delPpndelthetap)-(Ppn.*delPpddelthetap))./Ppn2d2;
  gradPthetap=sum(kgradPthetap,3);
  if max(max(abs(imag(gradPthetap))))>tol
    error("abs(imag(gradPthetap))>tol!");
  endif
  gradPthetap=real(gradPthetap);
  gradP(:,(1+U+V+M+Qon2+1):(1+U+V+M+Q))=gradPthetap;
endif
if nargout==2
  return;
endif

%
% Hessian or second derivatives of phase with respect to coefficients
%

% Initialise
hessP=zeros(Nw,1+U+V+M+Q,1+U+V+M+Q);

% Utility matrixes for the diagonals
DU=zeros(U,U*U);
DU(1:U,1:(1+U):(U*U))=eye(U);
DV=zeros(V,V*V);
DV(1:V,1:(1+V):(V*V))=eye(V);
DMon2=zeros(Mon2,Mon2*Mon2);
DMon2(1:Mon2,1:(1+Mon2):(Mon2*Mon2))=eye(Mon2);
DQon2=zeros(Qon2,Qon2*Qon2);
DQon2(1:Qon2,1:(1+Qon2):(Qon2*Qon2))=eye(Qon2);

if U>0
  % hdel2PdelR02
  del2PdelR02=gradPR0*2.*(coswR0-kR0)./denomR0;
  hdel2PdelR02=permute(reshape((del2PdelR02*DU)',U,U,Nw),[3,1,2]);
  % del2PdelR02 column
  hessP(:,(1+1):(1+U),(1+1):(1+U))=hdel2PdelR02;
endif
  
if V>0 
  % hdel2PdelRp2
  Rpsm2=zeros(size(Rp));
  Rpsm2(iRpnz)=Rp(iRpnz).^(s-2);
  kRpsm2=kron(ones(Nw,1),Rpsm2);
  kRpsm2=reshape(kron(ones(1,R),kRpsm2),Nw,V,R);
  Rp2sm2=zeros(size(Rp));
  Rp2sm2(iRpnz)=Rp(iRpnz).^((2*s)-2);
  kRp2sm2=kron(ones(Nw,1),Rp2sm2);
  kRp2sm2=reshape(kron(ones(1,R),kRp2sm2),Nw,V,R);

  del2PdelRp2=-(s*(s-1)*kRpsm2.*ksinwspiRp./denomRp) ...
              -(2*s*s*kRp2sm2.*ksinwspiRp.*(kcoswspiRp-kRps)./(denomRp.^2));
  del2PdelRp2=sum(del2PdelRp2,3);
  hdel2PdelRp2=permute(reshape((del2PdelRp2*DV)',V,V,Nw),[3,1,2]);
  % del2PdelRp2 column
  hessP(:,(1+U+1):(1+U+V),(1+U+1):(1+U+V))=hdel2PdelRp2;
endif

if M>0
  del2P0ndelr02=0;
  del2P0ndeltheta0delr0=2*ksintheta0.*ksinwr0;
  del2P0ndeltheta02=2*kr0.*kcostheta0.*ksinwr0;
  del2P0ddelr02=2;
  del2P0ddeltheta0delr0=2*ksintheta0.*kcoswr0;
  del2P0ddeltheta02=2*kr0.*kcostheta0.*kcoswr0;
  
  delP0n2d2delr0=((2*P0n.*delP0ndelr0)+(2*P0d.*delP0ddelr0))./(P0n2d2.^2);
  delP0n2d2deltheta0= ...
    ((2*P0n.*delP0ndeltheta0)+(2*P0d.*delP0ddeltheta0))./(P0n2d2.^2);
  
  % hdel2Pdelr02
  del2Pdelr02=(((delP0ddelr0.*delP0ndelr0) + ...
                (P0d.*del2P0ndelr02) - ...
                (delP0ndelr0.*delP0ddelr0) - ...
                (P0n.*del2P0ddelr02))./P0n2d2) ...
             - (((P0d.*delP0ndelr0) - ...
                 (P0n.*delP0ddelr0)).*delP0n2d2delr0);
  hdel2Pdelr02=permute(reshape((del2Pdelr02*DMon2)',Mon2,Mon2,Nw),[3,1,2]);

  % hdel2Pdeltheta0delr0
  del2Pdeltheta0delr0=(((delP0ddeltheta0.*delP0ndelr0) + ...
                        (P0d.*del2P0ndeltheta0delr0) - ...
                        (delP0ndeltheta0.*delP0ddelr0) - ...
                        (P0n.*del2P0ddeltheta0delr0))./P0n2d2) ...
                    - (((P0d.*delP0ndelr0) - ...
                        (P0n.*delP0ddelr0)).*delP0n2d2deltheta0);
  hdel2Pdeltheta0delr0=...
   permute(reshape((del2Pdeltheta0delr0*DMon2)',Mon2,Mon2,Nw),[3,1,2]);

  % hdel2Pdeltheta02
  del2Pdeltheta02=(((delP0ddeltheta0.*delP0ndeltheta0) + ...
                    (P0d.*del2P0ndeltheta02) - ...
                    (delP0ndeltheta0.*delP0ddeltheta0) - ...
                    (P0n.*del2P0ddeltheta02))./P0n2d2) ...
                - (((P0d.*delP0ndeltheta0) - ...
                    (P0n.*delP0ddeltheta0)).*delP0n2d2deltheta0);
  hdel2Pdeltheta02=...
    permute(reshape((del2Pdeltheta02*DMon2)',Mon2,Mon2,Nw),[3,1,2]);

  % del2Pdelr02 column
  hessP(:,(1+U+V+1):(1+U+V+Mon2),(1+U+V+1):(1+U+V+Mon2))=hdel2Pdelr02;
  % del2Pdeltheta02 column
  hessP(:,(1+U+V+Mon2+1):(1+U+V+M),(1+U+V+Mon2+1):(1+U+V+M))=hdel2Pdeltheta02;
  % del2Pdeltheta0delr0 column
  hessP(:,(1+U+V+Mon2+1):(1+U+V+M),(1+U+V+1):(1+U+V+Mon2))=hdel2Pdeltheta0delr0;
  % del2Pdeltheta0delr0 row
  hessP(:,(1+U+V+1):(1+U+V+Mon2),(1+U+V+Mon2+1):(1+U+V+M))= ...
  hdel2Pdeltheta0delr0;
%  permute(hdel2Pdeltheta0delr0,[1,3,2]);
endif

if Q>0
  rpsm1=zeros(size(rp));
  rpsm1(irpnz)=rp(irpnz).^(s-1);
  krpsm1=kron(ones(Nw,1),rpsm1);
  krpsm1=reshape(kron(ones(1,R),krpsm1),Nw,Qon2,R);
  
  rpsm2=zeros(size(rp));
  rpsm2(irpnz)=rp(irpnz).^(s-2);
  krpsm2=kron(ones(Nw,1),rpsm2);
  krpsm2=reshape(kron(ones(1,R),krpsm2),Nw,Qon2,R);

  krp2sm2=kron(ones(Nw,1),rpsm1.^2);
  krp2sm2=reshape(kron(ones(1,R),krp2sm2),Nw,Qon2,R);

  del2Ppndelrp2=-2*s*(s-1)*krpsm2.*kcossthetap.*ksinwrp;
  del2Ppndelthetapdelrp=2*s*s*krpsm1.*ksinsthetap.*ksinwrp;
  del2Ppndelthetap2=2*s*s*krps.*kcossthetap.*ksinwrp;
  del2Ppddelrp2=-(2*s*(s-1)*krpsm2.*kcossthetap.*kcoswrp) + ...
                ((2*s)*((2*s)-1)*krp2sm2);
  del2Ppddelthetapdelrp=2*s*s*krpsm1.*ksinsthetap.*kcoswrp;
  del2Ppddelthetap2=2*s*s*krps.*kcossthetap.*kcoswrp;
  
  delPpn2d2delrp=((2*Ppn.*delPpndelrp)+(2*Ppd.*delPpddelrp))./(Ppn2d2.^2);
  delPpn2d2delthetap= ...
    ((2*Ppn.*delPpndelthetap)+(2*Ppd.*delPpddelthetap))./(Ppn2d2.^2);

  % hdel2Pdelrp2
  del2Pdelrp2=(((delPpddelrp.*delPpndelrp) + ...
                (Ppd.*del2Ppndelrp2) - ...
                (delPpndelrp.*delPpddelrp) - ...
                (Ppn.*del2Ppddelrp2))./Ppn2d2) ...
             - (((Ppd.*delPpndelrp) - ...
                 (Ppn.*delPpddelrp)).*delPpn2d2delrp);
  del2Pdelrp2= -sum(del2Pdelrp2,3);
  hdel2Pdelrp2=permute(reshape((del2Pdelrp2*DQon2)',Qon2,Qon2,Nw),[3,1,2]);

  % hdel2Pdelthetapdelrp
  del2Pdelthetapdelrp=(((delPpddelthetap.*delPpndelrp) + ...
                        (Ppd.*del2Ppndelthetapdelrp) - ...
                        (delPpndelthetap.*delPpddelrp) - ...
                        (Ppn.*del2Ppddelthetapdelrp))./Ppn2d2) ...
                    - (((Ppd.*delPpndelrp) - ...
                        (Ppn.*delPpddelrp)).*delPpn2d2delthetap);
  del2Pdelthetapdelrp= -sum(del2Pdelthetapdelrp,3);
  hdel2Pdelthetapdelrp=...
    permute(reshape((del2Pdelthetapdelrp*DQon2)',Qon2,Qon2,Nw),[3,1,2]);

  % hdel2Pdelthetap2
  del2Pdelthetap2=(((delPpddelthetap.*delPpndelthetap) + ...
                    (Ppd.*del2Ppndelthetap2) - ...
                    (delPpndelthetap.*delPpddelthetap) - ...
                    (Ppn.*del2Ppddelthetap2))./Ppn2d2) ...
                - (((Ppd.*delPpndelthetap) - ...
                    (Ppn.*delPpddelthetap)).*delPpn2d2delthetap);
  del2Pdelthetap2= -sum(del2Pdelthetap2,3);
  hdel2Pdelthetap2=...
    permute(reshape((del2Pdelthetap2*DQon2)',Qon2,Qon2,Nw),[3,1,2]);

  % del2Pdelrp2 column
  hessP(:,(1+U+V+M+1):(1+U+V+M+Qon2),(1+U+V+M+1):(1+U+V+M+Qon2))= ...
    hdel2Pdelrp2;
  % del2Pdelthetapdelrp column
  hessP(:,(1+U+V+M+Qon2+1):(1+U+V+M+Q),(1+U+V+M+1):(1+U+V+M+Qon2))= ...
    hdel2Pdelthetapdelrp;
  % del2Pdelthetap2 column
  hessP(:,(1+U+V+M+Qon2+1):(1+U+V+M+Q),(1+U+V+M+Qon2+1):(1+U+V+M+Q))= ...
    hdel2Pdelthetap2;
  % del2Pdelthetapdelrp row
  hessP(:,(1+U+V+M+1):(1+U+V+M+Qon2),(1+U+V+M+Qon2+1):(1+U+V+M+Q))= ...
    permute(hdel2Pdelthetapdelrp, [1,3,2]);
endif

% Remove a redundant frequency dimension
sizeH=size(hessP);
if length(sizeH)==3 && sizeH(1)==1
  hessP=reshape(hessP,sizeH(2),sizeH(3));
endif

% Sanity checks on hessP
hessP=fixResultNaN(hessP);
if any(any(any(isinf(hessP))))
  error("hessP has inf!");
endif
if max(max(max(abs(imag(hessP)))))>tol
  error("R=%d,max(abs(imag(hessP)))(%g)>tol!",
        R,max(max(max(abs(imag(hessP))))));
endif

hessP=real(hessP);

endfunction
