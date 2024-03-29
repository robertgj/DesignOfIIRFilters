% schurNSlatticeEsq_test.m
% Copyright (C) 2017-2023 Robert G. Jenssen

test_common;

delete("schurNSlatticeEsq_test.diary");
delete("schurNSlatticeEsq_test.diary.tmp");
diary schurNSlatticeEsq_test.diary.tmp

if 0
  % Deczky3 lowpass filter specification
  n=800;
  norder=10;
  fap=0.15;Wap=1;
  fas=0.3;Was_mmse=1;
  ftp=0.25;tp=10;Wtp_mmse=1;
  % Initial filter from deczky3_sqp_test.m
  U=0;V=0;Q=6;M=10;R=1;
  z0=[exp(j*2*pi*0.41),exp(j*2*pi*0.305),1.5*exp(j*2*pi*0.2), ...
      1.5*exp(j*2*pi*0.14),1.5*exp(j*2*pi*0.08)];
  p0=[0.7*exp(j*2*pi*0.16),0.6*exp(j*2*pi*0.12),0.5*exp(j*2*pi*0.05)];
  K0=0.0096312406;
  x0=[K0,abs(z0),angle(z0),abs(p0),angle(p0)]';
  [n0,d0]=x2tf(x0,U,V,M,Q,R);
  d0=[d0(:);zeros(length(n0)-length(d0),1)];
  [s10_0,s11_0,s20_0,s00_0,s02_0,s22_0]=tf2schurNSlattice(n0,d0);
  % Amplitude constraints
  wa=(0:(n-1))'*pi/n;
  nap=ceil(n*fap/0.5)+1;
  nas=floor(n*fas/0.5)+1;
  Asqd=[ones(nap,1); zeros(n-nap,1)];
  Asqdu=[];
  Asqdl=[];
  Wa=[Wap*ones(nap,1);zeros(nas-nap,1);Was_mmse*ones(n-nas,1)];
  % Group delay constraints
  ntp=ceil(n*ftp/0.5)+1;
  wt=(0:(ntp-1))'*pi/n;
  Td=tp*ones(ntp,1);
  Tdu=[];
  Tdl=[];
  Wt=Wtp_mmse*ones(ntp,1);
else
  % R=2 bandpass filter from iir_sqp_slb_bandpass_test.m
  fapl=0.1;fapu=0.2;Wap=1;
  fasl=0.05;fasu=0.25;Wasl=2;Wasu=2;
  ftpl=0.09;ftpu=0.21;tp=16;Wtp=1;
  n0 = [   0.0119898572,   0.0055005262,   0.0227465629,   0.0227676952, ... 
           0.0477699159,   0.0346032386,   0.0300158271,   0.0007692638, ... 
          -0.0021264872,  -0.0305118086,  -0.0677680871,  -0.1021835628, ... 
          -0.0704487200,   0.0361830861,   0.1357812748,   0.1570834904, ... 
           0.0638315615,  -0.0390403107,  -0.0989222753,  -0.0714382761, ... 
          -0.0337487587 ]';
  d0 = [   1.0000000000,   0.0000000000,   1.7122688809,   0.0000000000, ... 
           1.9398016652,   0.0000000000,   1.9464309420,   0.0000000000, ... 
           1.7222723403,   0.0000000000,   1.2656797602,   0.0000000000, ... 
           0.8103366569,   0.0000000000,   0.4372977468,   0.0000000000, ... 
           0.1983164681,   0.0000000000,   0.0654678098,   0.0000000000, ... 
           0.0147305592 ]';

  % Desired magnitude-squared response
  nplot=256;
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
endif

% Convert filter transfer function to Schur 1-multiplier lattice form
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n0,d0);
Ns=length(s10);

% Calculate the squared error response
Esq=schurNSlatticeEsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);

% Check the squared error response (delayz is not accurate??)
Asq=schurNSlatticeAsq(wa,s10,s11,s20,s00,s02,s22);
T=schurNSlatticeT(wt,s10,s11,s20,s00,s02,s22);
AsqErr=Wa.*((Asq-Asqd).^2);
AsqErrSum=sum(diff(wa).*(AsqErr(1:(length(wa)-1))+AsqErr(2:end)))/2;
TErr=Wt.*((T-Td).^2);  
TErrSum=sum(diff(wt).*(TErr(1:(length(wt)-1))+TErr(2:end)))/2;
absErrEsq=abs(AsqErrSum+TErrSum-Esq);
if absErrEsq > eps
  error("abs(AsqErrSum+TErrSum-Esq)(%g*eps) > eps",absErrEsq/eps);
endif

% Calculate the gradient of the squared error response
[Esq,gradEsq]=schurNSlatticeEsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);

% Check the gradients of the squared error wrt k
del=1e-6;
tol=del/5000;
dels=zeros(size(s10));
dels(1)=del/2;
diff_Esq=zeros(1,6*Ns);
for l=1:Ns
  % s10
  EsqP=schurNSlatticeEsq(s10+dels,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  EsqM=schurNSlatticeEsq(s10-dels,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  diff_Esq(1+((l-1)*6))=(EsqP-EsqM)/del;
  % s11
  EsqP=schurNSlatticeEsq(s10,s11+dels,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  EsqM=schurNSlatticeEsq(s10,s11-dels,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  diff_Esq(2+((l-1)*6))=(EsqP-EsqM)/del;
  % s20
  EsqP=schurNSlatticeEsq(s10,s11,s20+dels,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  EsqM=schurNSlatticeEsq(s10,s11,s20-dels,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  diff_Esq(3+((l-1)*6))=(EsqP-EsqM)/del;
  % s02
  EsqP=schurNSlatticeEsq(s10,s11,s20,s00+dels,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  EsqM=schurNSlatticeEsq(s10,s11,s20,s00-dels,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  diff_Esq(4+((l-1)*6))=(EsqP-EsqM)/del;
  % s00
  EsqP=schurNSlatticeEsq(s10,s11,s20,s00,s02+dels,s22,wa,Asqd,Wa,wt,Td,Wt);
  EsqM=schurNSlatticeEsq(s10,s11,s20,s00,s02-dels,s22,wa,Asqd,Wa,wt,Td,Wt);
  diff_Esq(5+((l-1)*6))=(EsqP-EsqM)/del;
  % s22
  EsqP=schurNSlatticeEsq(s10,s11,s20,s00,s02,s22+dels,wa,Asqd,Wa,wt,Td,Wt);
  EsqM=schurNSlatticeEsq(s10,s11,s20,s00,s02,s22-dels,wa,Asqd,Wa,wt,Td,Wt);
  diff_Esq(6+((l-1)*6))=(EsqP-EsqM)/del;
  % Shift dels
  dels=circshift(dels,1);
endfor
max_gradEsq_error=max(abs(diff_Esq-gradEsq));
if max_gradEsq_error > tol 
  error("max(abs(diff_Esq-gradEsq))(%g*tol) > tol",max_gradEsq_error/tol);
endif

% Calculate the diagonal of the Hessian of the squared error response
[Esq,gradEsq,diagHessEsq]=...
  schurNSlatticeEsq(s10,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);

% Check the diagonal of the Hessian of the squared error wrt k
del=1e-6;
tol=del/20;
dels=zeros(size(s10));
dels(1)=del/2;
diff_gradEsq=zeros(1,6*Ns);
for l=1:Ns
  % s10
  [EsqP,gradEsqP]=...
    schurNSlatticeEsq(s10+dels,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  [EsqP,gradEsqM]=...         
    schurNSlatticeEsq(s10-dels,s11,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  lindex=1+((l-1)*6);
  diff_gradEsq(lindex)=(gradEsqP(lindex)-gradEsqM(lindex))/del;
  % s11
  [EsqP,gradEsqP]=...
    schurNSlatticeEsq(s10,s11+dels,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  [EsqP,gradEsqM]=...             
    schurNSlatticeEsq(s10,s11-dels,s20,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  lindex=2+((l-1)*6);
  diff_gradEsq(lindex)=(gradEsqP(lindex)-gradEsqM(lindex))/del;
  % s20
  [EsqP,gradEsqP]=...
    schurNSlatticeEsq(s10,s11,s20+dels,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  [EsqP,gradEsqM]=...                 
    schurNSlatticeEsq(s10,s11,s20-dels,s00,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  lindex=3+((l-1)*6);
  diff_gradEsq(lindex)=(gradEsqP(lindex)-gradEsqM(lindex))/del;
  % s02
  [EsqP,gradEsqP]=...
    schurNSlatticeEsq(s10,s11,s20,s00+dels,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  [EsqP,gradEsqM]=...                     
    schurNSlatticeEsq(s10,s11,s20,s00-dels,s02,s22,wa,Asqd,Wa,wt,Td,Wt);
  lindex=4+((l-1)*6);
  diff_gradEsq(lindex)=(gradEsqP(lindex)-gradEsqM(lindex))/del;
  % s00
  [EsqP,gradEsqP]=...
    schurNSlatticeEsq(s10,s11,s20,s00,s02+dels,s22,wa,Asqd,Wa,wt,Td,Wt);
  [EsqP,gradEsqM]=...                         
    schurNSlatticeEsq(s10,s11,s20,s00,s02-dels,s22,wa,Asqd,Wa,wt,Td,Wt);
  lindex=5+((l-1)*6);
  diff_gradEsq(lindex)=(gradEsqP(lindex)-gradEsqM(lindex))/del;
  % s22
  [EsqP,gradEsqP]=...
    schurNSlatticeEsq(s10,s11,s20,s00,s02,s22+dels,wa,Asqd,Wa,wt,Td,Wt);
  [EsqP,gradEsqM]=...                             
    schurNSlatticeEsq(s10,s11,s20,s00,s02,s22-dels,wa,Asqd,Wa,wt,Td,Wt);
  lindex=6+((l-1)*6);
  diff_gradEsq(lindex)=(gradEsqP(lindex)-gradEsqM(lindex))/del;
  % Shift dels
  dels=circshift(dels,1);
endfor
max_diagHessEsq_error=max(abs(diff_gradEsq-diagHessEsq));
if max_diagHessEsq_error > tol
  error("max_diagHessEsq_error(%g*tol) > tol",max_diagHessEsq_error/tol);
endif

% Done
diary off
movefile schurNSlatticeEsq_test.diary.tmp schurNSlatticeEsq_test.diary;
