% schurOneMlatticeEsq_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

delete("schurOneMlatticeEsq_test.diary");
delete("schurOneMlatticeEsq_test.diary.tmp");
diary schurOneMlatticeEsq_test.diary.tmp

verbose=true;

% R=2 bandpass filter
fapl=0.1;fapu=0.2;Wap=10;
fasl=0.05;fasu=0.25;Wasl=20;Wasu=20;
ftpl=0.09;ftpu=0.21;tp=16;Wtp=100;
n = [   0.0127469845,   0.0032780608,   0.0285568297,   0.0217618336, ... 
        0.0543730436,   0.0291811860,   0.0325479489,  -0.0069026091, ... 
       -0.0040414137,  -0.0430974012,  -0.0720651216,  -0.1000828758, ... 
       -0.0551462733,   0.0517204345,   0.1392956867,   0.1495935341, ... 
        0.0498555510,  -0.0445198094,  -0.1009805373,  -0.0681447152, ... 
       -0.0338056405 ]';
d = [   1.0000000000,   0.0000000000,   1.8632536514,   0.0000000000, ... 
        2.2039281157,   0.0000000000,   2.2677909197,   0.0000000000, ... 
        2.0451496224,   0.0000000000,   1.5409563677,   0.0000000000, ... 
        1.0011650113,   0.0000000000,   0.5514123431,   0.0000000000, ... 
        0.2533493166,   0.0000000000,   0.0849599294,   0.0000000000, ... 
        0.0186365784 ]';

% Desired magnitude-squared response
nplot=1024;
wa=(0:(nplot-1))'*pi/nplot;
nasl=ceil(nplot*fasl/0.5)+1;
napl=floor(nplot*fapl/0.5)+1;
napu=ceil(nplot*fapu/0.5)+1;
nasu=floor(nplot*fasu/0.5)+1;
Asqd=[zeros(napl-1,1); ...
      ones(napu-napl+1,1); ...
      zeros(nplot-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(nplot-nasu+1,1)];

% Desired group delay response
ntpl=floor(nplot*ftpl/0.5);
ntpu=ceil(nplot*ftpu/0.5);
wt=(ntpl:ntpu)'*pi/nplot;
ntp=length(wt);
Td=tp*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Desired phase response
wp=wt;
h=freqz(n,d,wp);
P=unwrap(atan2(imag(h),real(h)));
Pd=((wp-wp(1))*((P(end)-P(1))/(wp(end)-wp(1))))+P(1);
Wpp=1e4;
Wp=Wpp*ones(size(wp));

% Convert filter transfer function to Schur 1-multiplier lattice form
[k,epsilon,p,c]=tf2schurOneMlattice(n,d);
Nk=length(k);
Nc=length(c);
[Esq,gradEsq,diagHessEsq]=...
  schurOneMlatticeEsq(k,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Check the squared-error response
Asq=schurOneMlatticeAsq(wa,k,epsilon,p,c);
AsqErr=Wa.*((Asq-Asqd).^2);
AsqErrSum=sum(diff(wa).*(AsqErr(1:(length(wa)-1))+AsqErr(2:end)))/2;
T=schurOneMlatticeT(wt,k,epsilon,p,c);
TErr=Wt.*((T-Td).^2);  
TErrSum=sum(diff(wt).*(TErr(1:(length(wt)-1))+TErr(2:end)))/2;
P=schurOneMlatticeP(wp,k,epsilon,p,c);
PErr=Wp.*((P-Pd).^2);  
PErrSum=sum(diff(wp).*(PErr(1:(length(wp)-1))+PErr(2:end)))/2;
if abs(AsqErrSum+TErrSum+PErrSum-Esq) > eps
  error("abs(AsqErrSum+TErrSum+PErrSum-Esq) > eps");
endif

% Check the gradients of the squared-error wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
diff_Esqk=zeros(1,size(k));
for l=1:Nk
  EsqkPdel2=schurOneMlatticeEsq(k+delk,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqkMdel2=schurOneMlatticeEsq(k-delk,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  delk=shift(delk,1);
  diff_Esqk(l)=(EsqkPdel2-EsqkMdel2)/del;
endfor
if max(abs(diff_Esqk-gradEsq(1:Nk))) > del/142
  error("max(abs(diff_Esqk-gradEsq(1:Nk))) > del/142");
endif

% Check the gradient of the squared-error response wrt c
del=1e-6;
delc=zeros(size(c));
delc(1)=del/2;
diff_Esqc=zeros(1,size(c));
for l=1:Nc
  EsqcPdel2=schurOneMlatticeEsq(k,epsilon,p,c+delc,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqcMdel2=schurOneMlatticeEsq(k,epsilon,p,c-delc,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  delc=shift(delc,1);
  diff_Esqc(l)=(EsqcPdel2-EsqcMdel2)/del;
endfor
if max(abs(diff_Esqc-gradEsq((Nk+1):end))) > del/230.07
  error("max(abs(diff_Esqc-gradEsq((Nk+1):end))) > del/230.07");
endif

% Check the diagonal of the Hessian of the squared-error wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
diff_dEsqdk=zeros(1,size(k));
for l=1:Nk
  [EsqkPdel2,gradEsqkPdel2] = ...
    schurOneMlatticeEsq(k+delk,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  [EsqkMdel2,gradEsqkMdel2] = ...
    schurOneMlatticeEsq(k-delk,epsilon,p,c,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  delk=shift(delk,1);
  diff_dEsqdk(l)=(gradEsqkPdel2(l)-gradEsqkMdel2(l))/del;
endfor
if max(abs(diff_dEsqdk-diagHessEsq(1:Nk))) > del/0.29258
  error("max(abs(diff_dEsqdk-diagHessEsq(1:Nk))) > del/0.29258");
endif

% Check the diagonal of the Hessian of the squared-error wrt c
del=1e-6;
delc=zeros(size(c));
delc(1)=del/2;
diff_dEsqdc=zeros(1,size(c));
for l=1:Nc
  [EsqkPdel2,gradEsqkPdel2] = ...
    schurOneMlatticeEsq(k,epsilon,p,c+delc,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  [EsqkMdel2,gradEsqkMdel2] = ...
    schurOneMlatticeEsq(k,epsilon,p,c-delc,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  delc=shift(delc,1);
  diff_dEsqdc(l)=(gradEsqkPdel2(Nk+l)-gradEsqkMdel2(Nk+l))/del;
endfor
if max(abs(diff_dEsqdc-diagHessEsq((Nk+1):end))) > del/0.6043
  error("max(abs(diff_dEsqdc-diagHessEsq((Nk+1):end))) > del/0.6043");
endif

% Done
diary off
movefile schurOneMlatticeEsq_test.diary.tmp schurOneMlatticeEsq_test.diary;
