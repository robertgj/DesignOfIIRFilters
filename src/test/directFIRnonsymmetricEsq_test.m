% directFIRnonsymmetricEsq_test.m
% Copyright (C) 2021-2026 Robert G. Jenssen

test_common;

delete("directFIRnonsymmetricEsq_test.diary");
delete("directFIRnonsymmetricEsq_test.diary.tmp");
diary directFIRnonsymmetricEsq_test.diary.tmp

%
% FIR filter from yalmip_kyp_lowpass_test.m
%
h =   [  0.0024629409,  0.0043299063,  0.0008282373, -0.0115481441, ... 
        -0.0278864843, -0.0325179405, -0.0066048486,  0.0572758926, ... 
         0.1445170633,  0.2220942579,  0.2561794255,  0.2318957749, ... 
         0.1611645154,  0.0739876834,  0.0009749025, -0.0403275948, ... 
        -0.0484701847, -0.0329188013, -0.0072304664,  0.0156129560, ... 
         0.0262868789,  0.0218829195,  0.0071201577, -0.0082811653, ... 
        -0.0156301553, -0.0126116904, -0.0037676802,  0.0039725804, ... 
         0.0065852969,  0.0047851743,  0.0018073130 ];
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
T=delayz(h,1,nplot);
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
