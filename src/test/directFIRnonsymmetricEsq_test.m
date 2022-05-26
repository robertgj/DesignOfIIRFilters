% directFIRnonsymmetricEsq_test.m
% Copyright (C) 2021 Robert G. Jenssen

test_common;

delete("directFIRnonsymmetricEsq_test.diary");
delete("directFIRnonsymmetricEsq_test.diary.tmp");
diary directFIRnonsymmetricEsq_test.diary.tmp

%
% FIR filter from yalmip_kyp_lowpass_test.m
%
h = [  0.0008656281,  0.0021696544,  0.0015409094, -0.0044622917, ... 
      -0.0158159316, -0.0238564167, -0.0115295105,  0.0369399475, ... 
       0.1209482871,  0.2146857085,  0.2753128363,  0.2671184150, ... 
       0.1864131493,  0.0680195698, -0.0338776291, -0.0783792857, ... 
      -0.0609991209, -0.0114347624,  0.0303914254,  0.0408361994, ... 
       0.0229705268, -0.0030363605, -0.0182941274, -0.0172426361, ... 
      -0.0067422453,  0.0030663947,  0.0067934959,  0.0053367805, ... 
       0.0023609590,  0.0004446292, -0.0000798085 ];
h=h(:)';
N=length(h)-1;
d=10;fap=0.1;Wap=1;Wat=0.0001;fas=0.2;Was=100;Wtp=0.1;Wpp=0.01;
scaleAsq=1;
nplot=1000;
nap=ceil((fap*nplot)/0.5)+1;
nas=floor((fas*nplot)/0.5)+1;
fa=(0:(nplot-1))'*0.5/nplot;
wa=2*pi*fa;
Asqd=[scaleAsq*ones(nap,1);zeros(nplot-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(nplot-nas+1,1)];
ft=fa(1:nap);
wt=2*pi*ft;
Td=d*ones(nap,1);
Wt=Wtp*ones(nap,1);
fp=fa(1:nap);
wp=2*pi*fp;
Pd=-wp*d;
Wp=Wpp*ones(nap,1);

% Find the squared-error
Esq=directFIRnonsymmetricEsq(h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Check the squared-error response
[H,wplot]=freqz(h,1,nplot);
P=unwrap(arg(H));
T=grpdelay(h,1,nplot);
Asq=abs(H).^2;
AsqErr=Wa.*((Asq-Asqd).^2);
AsqErrSum=sum(diff(wa).*(AsqErr(1:(end-1))+AsqErr(2:end)))/2;
TErr=Wt.*((T(1:nap)-Td).^2);  
TErrSum=sum(diff(wt).*(TErr(1:(end-1))+TErr(2:end)))/2;
PErr=Wp.*((P(1:nap)-Pd).^2);  
PErrSum=sum(diff(wp).*(PErr(1:(end-1))+PErr(2:end)))/2;
if abs(AsqErrSum+TErrSum+PErrSum-Esq) > eps
  error("abs(AsqErrSum+TErrSum+PErrSum-Esq) > eps");
endif

% Find the gradients of Esq
[~,gradEsq]=directFIRnonsymmetricEsq(h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Check the gradients of the squared-error response wrt h
del=1e-6;
delh=zeros(1,N+1);
delh(1)=del/2;
diff_Esqh=zeros(1,N+1);
for k=1:(N+1)
  EsqhPdel2=directFIRnonsymmetricEsq(h+delh,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  EsqhMdel2=directFIRnonsymmetricEsq(h-delh,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  diff_Esqh(k)=(EsqhPdel2-EsqhMdel2)/del;
  delh=circshift(delh,1);
endfor
if max(max(abs(diff_Esqh-gradEsq))) > del/1e4
  error("max(max(abs(diff_Esqh-gradEsq))) > del/1e4");
endif

% Done
diary off
movefile directFIRnonsymmetricEsq_test.diary.tmp ...
         directFIRnonsymmetricEsq_test.diary;
