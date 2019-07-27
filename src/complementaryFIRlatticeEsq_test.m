% complementaryFIRlatticeEsq_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

unlink("complementaryFIRlatticeEsq_test.diary");
unlink("complementaryFIRlatticeEsq_test.diary.tmp");
diary complementaryFIRlatticeEsq_test.diary.tmp

tic;
verbose=true;

% Bandpass minimum-phase filter specification
Ud1=2;Vd1=0;Md1=14;Qd1=0;Rd1=1;
d1 = [   0.0920209477, ...
         0.9990000000,   0.5128855702, ...
         0.7102414018,   0.9990000000,   0.9990000000,   0.9990000000, ... 
         0.9990000000,   0.9990000000,   0.9990000000, ...
        -0.9667931503,   0.2680255295,   2.2176753593,   3.3280228348, ... 
         3.7000375301,   4.4072989555,   4.6685041037 ]';
[b1,~]=x2tf(d1,Ud1,Vd1,Md1,Qd1,Rd1);
% Find lattice coefficients (b1 is scaled to |H|<=1 and returned as b)
[b,bc,k,khat]=complementaryFIRlattice(b1(:));
Nk=length(k);
% Frequency specifications
nplot=1024;
[H,wplot]=freqz(b,1,nplot);
td=5.5;
fsl=0.05;fpl=0.1;fpu=0.2;fsu=0.25;
nsl=floor(nplot*fsl/0.5)+1;
npl=floor(nplot*fpl/0.5)+1;
npu=ceil(nplot*fpu/0.5)+1;
nsu=ceil(nplot*fsu/0.5)+1;
% Squared-magnitude
wa=wplot;
Asqd=[zeros(npl,1);ones(npu-npl,1);zeros(nplot-npu,1)];
Wasl=100;Wap=1;Wasu=100;
Wa=[Wasl*ones(nsl,1); ...
    zeros(npl-nsl,1); ...
    Wap*ones(npu-npl,1); ...
    zeros(nsu-npu,1); ...
    Wasu*ones(nplot-nsu,1)];
% Delay
wt=wplot(npl:npu);
Td=td*ones(length(wt),1);
Wtsl=0;Wtp=1;Wtsu=0;
Wt=Wtp*ones(length(wt),1);
% Phase
wp=wplot(npl:npu);
Pd_npl=arg(H(npl));
Pd=-(td*wp)+(Pd_npl+(td*wplot(npl)));
Wpp=0.1;
Wp=Wpp*ones(length(wp),1);

% Check the squared-error response
Asq=complementaryFIRlatticeAsq(wa,k,khat);
T=complementaryFIRlatticeT(wt,k,khat);
P=complementaryFIRlatticeP(wp,k,khat);
ErrorAsq=Wa.*((Asq-Asqd).^2);
ErrorT=Wt.*((T-Td).^2);
ErrorP=Wp.*((P-Pd).^2);
ErrorAsqTP=sum(diff(wa).*(ErrorAsq(1:(end-1))+ErrorAsq(2:end))/2) + ...
           sum(diff(wt).*(ErrorT(1:(end-1))+ErrorT(2:end))/2) + ...
           sum(diff(wp).*(ErrorP(1:(end-1))+ErrorP(2:end))/2);
[Esq,gradEsq]=complementaryFIRlatticeEsq(k,khat,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
tol=10*eps;
if max(abs(ErrorAsqTP-Esq)) > tol
  error("max(abs(ErrorAsqTP-Esq))(%g*eps) > %g*eps", ...
        max(abs(ErrorAsqTP-Esq))/eps,tol/eps);
endif

% Check the gradients of the squared-error wrt k
del=1e-6;
delk=zeros(size(k));
delk(1)=del/2;
diff_Esqk=zeros(1,Nk);
for l=1:Nk
  EsqkPdel2= ...
    complementaryFIRlatticeEsq(k+delk,khat,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqkMdel2= ...
    complementaryFIRlatticeEsq(k-delk,khat,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  delk=shift(delk,1);
  diff_Esqk(l)=(EsqkPdel2-EsqkMdel2)/del;
endfor
if max(abs(diff_Esqk-gradEsq(1:Nk))) > del/1407
  error("max(abs(diff_Esqk-gradEsq(1:Nk))) > del/1407");
endif

% Check the gradient of the squared-magnitude response wrt khat
del=1e-6;
delkhat=zeros(size(khat));
delkhat(1)=del/2;
diff_Esqkhat=zeros(1,Nk);
for l=1:Nk
  EsqkhatPdel2= ...
    complementaryFIRlatticeEsq(k,khat+delkhat,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqkhatMdel2= ...
    complementaryFIRlatticeEsq(k,khat-delkhat,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  delkhat=shift(delkhat,1);
  diff_Esqkhat(l)=(EsqkhatPdel2-EsqkhatMdel2)/del;
endfor
if max(abs(diff_Esqkhat-gradEsq((Nk+1):(2*Nk)))) > del/1967
  error("max(abs(diff_Esqkhat-gradEsq((Nk+1):(2*Nk)))) > del/1967");
endif

% Done
toc;
diary off
movefile complementaryFIRlatticeEsq_test.diary.tmp ...
         complementaryFIRlatticeEsq_test.diary;
