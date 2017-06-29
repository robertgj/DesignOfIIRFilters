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
%           with respect to x (NOT IMPLEMENTED!)
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
%
% !!! WARNING !!!
%   hessP is not implemented
% !!! WARNING !!!

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

% Sanity checks
if nargin<7 || nargout>3
  print_usage("[P,gradP,hessP]=iirP(w,x,U,V,M,Q,R [,tol])");
endif
if nargout == 3
  error ("hessP not implemented!");
endif
if nargin == 7
  tol=1e-9;
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
if (iscomplex(x) != 0)
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
UV=U+V;
UVMon2=UV+Mon2;
UVM=UV+M;
UVMQon2=UVM+Qon2;
UVMQ=UVM+Q;
N=1+UVMQ;

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

% In the following, the real zero coefficients are organised as
% (Nw, U), the real pole coefficients are organised as (Nw, V, R),
% the conjugate zero polynomial coefficients are organised 
% as (Nw, Mon2) and the conjugate pole polynomial coefficients 
% are organised as (Nw, Qon2, R). Recall that w is a column vector
% and R0, Rp, r0, theta0, rp and thetap are row vectors.

% Phase

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
  athetap=thetap+((rp<0)*pi);
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

% Gradient of phase
gradP=zeros(Nw,N);

% For real zeros create Nw-by-U arrays
if U > 0
  kR02=kron(ones(Nw,1),R0.^2);
  gradP(:,1+1:1+U)=sinwR0./(1 - 2*kR0.*coswR0 + kR02);
endif

% For real poles create Nw-by-V-by-R 3-D arrays
if V > 0
  iRpnz=find(Rp!=0);
  Rpsm1=zeros(size(Rp));
  Rpsm1(iRpnz)=Rp(iRpnz).^(s-1);
  kRpsm1=reshape(kron(ones(1,R),kron(ones(Nw,1),Rpsm1)),Nw,V,R);
  kRps=reshape(kron(ones(1,R),kron(ones(Nw,1),Rp.^s)),Nw,V,R);
  kRps2=reshape(kron(ones(1,R),kron(ones(Nw,1),Rp.^(2*s))),Nw,V,R);
  kwRp=reshape(kron(ones(1,R),kron(w,ones(1,V))),Nw,V,R);
  kcoswspiRp=cos(kwRp-kspiRp);
  ksinwspiRp=sin(kwRp-kspiRp);
  gradPRp=-s*sum((kRpsm1.*ksinwspiRp)./(1-2*kRps.*kcoswspiRp+kRps2),3);
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

  gradPr0=((P0n.*((2*kcostheta0.*kcoswr0)-2*kr0)) ...
           -P0d.*(2*kcostheta0.*ksinwr0))./P0n2d2;
  gradP(:,(1+U+V+1):(1+U+V+Mon2))=gradPr0;

  gradPtheta0=((P0d.*(2*kr0.*ksintheta0.*ksinwr0)) ...
               -P0n.*(2*kr0.*ksintheta0.*kcoswr0))./P0n2d2;
  gradP(:,(1+U+V+Mon2+1):(1+U+V+M))=gradPtheta0;
endif

% For conjugate poles create Nw-by-Qon2-by-R 3-D arrays
if Q > 0
  irpnz=find(rp!=0);
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

  Ppn=ksin2wrp-2*krps.*kcossthetap.*ksinwrp;
  Ppd=kcos2wrp-2*krps.*kcossthetap.*kcoswrp+krp2s;
  Ppn2d2=Ppn.^2 + Ppd.^2;

  kgradPrp=-(Ppd.*(-2*s*krpsm1.*kcossthetap.*ksinwrp) ...
             -Ppn.*(-2*s*krpsm1.*kcossthetap.*kcoswrp + 2*s*krp2sm1))./Ppn2d2;
  gradPrp=sum(kgradPrp,3);
  if max(max(abs(imag(gradPrp))))>tol
    error("abs(imag(gradPrp))>tol!");
  endif
  gradPrp=real(gradPrp);
  gradP(:,(1+U+V+M+1):(1+U+V+M+Qon2))=gradPrp;

  kgradPthetap=-(Ppd.*(2*s*krps.*ksinsthetap.*ksinwrp) ...
                 -Ppn.*(2*s*krps.*ksinsthetap.*kcoswrp))./Ppn2d2;
  gradPthetap=sum(kgradPthetap,3);
  if max(max(abs(imag(gradPthetap))))>tol
    error("abs(imag(gradPthetap))>tol!");
  endif
  gradPthetap=real(gradPthetap);
  gradP(:,(1+U+V+M+Qon2+1):(1+U+V+M+Q))=gradPthetap;
endif

endfunction
