% directFIRsymmetric_slb_update_constraints_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("directFIRsymmetric_slb_update_constraints_test.diary");
delete("directFIRsymmetric_slb_update_constraints_test.diary.tmp");
diary directFIRsymmetric_slb_update_constraints_test.diary.tmp


tol=1e-3;

% Band pass filter
M=15;
fapl=0.1;fapu=0.2;Wap=1;dBap=0.5;
fasl=0.05;fasu=0.25;Wasl=10;Wasu=20;dBas=50;

% Make a band pass filter
f=[0 fasl fapl fapu fasu 0.5];
h=remez(2*M,f*2,[0 0 1 1 0 0],[Wasl Wap Wasu],'bandpass');
hM=h(1:(M+1));

% Desired magnitude response
nplot=1000;
wa=(0:nplot)'*pi/nplot;
nasl=ceil(nplot*fasl/0.5)+1;
napl=floor(nplot*fapl/0.5)+1;
napu=ceil(nplot*fapu/0.5)+1;
nasu=floor(nplot*fasu/0.5)+1;  
Ad=[zeros(napl-1,1); ...
    ones(napu-napl+1,1); ...
    zeros(nplot-napu+1,1)];
Adu=[(10^(-dBas/20))*ones(nasl,1); ...
     ones(nasu-nasl-1,1); ...
     (10^(-dBas/20))*ones(nplot-nasu+2,1)];
Adl=[-(10^(-dBas/20))*ones(napl-1,1); ...
      (10^(-dBap/20))*ones(napu-napl+1,1); ...
     -(10^(-dBas/20))*ones(nplot-napu+1,1)];

% Common strings
strM=sprintf("Bandpass FIR : fapl=%g,fapu=%g,dBap=%g,fasl=%g,fasu=%g,dBas=%g",...
             fapl,fapu,dBap,fasl,fasu,dBas);

% Amplitude response
A=directFIRsymmetricA(wa,hM);

% Update constraints
vS=directFIRsymmetric_slb_update_constraints(A,Adu,Adl,tol);
for [v,k]=vS
  printf("%s=[ ",k);printf("%d ",v);printf("]\n");
endfor
Al=directFIRsymmetricA(wa(vS.al),hM);
Au=directFIRsymmetricA(wa(vS.au),hM);

% Show constraints
directFIRsymmetric_slb_show_constraints(vS,wa,A);

% Plot amplitude
fa=wa*0.5/pi;
subplot(211);
plot(fa,A,fa,Adu,fa,Adl,fa(vS.al),Al,"x",fa(vS.au),Au,"+");
axis([0 0.5 0.8 1.2]);
title(strM);
ylabel("Amplitude");
legend("A","Adu","Adl");
legend("boxoff");
legend("left");
legend("location","northeast");
subplot(212);
plot(fa,A,fa,Adu,fa,Adl,fa(vS.al),Al,"x",fa(vS.au),Au,"+");
axis([0 0.5 -0.02 0.02]);
ylabel("Amplitude");
xlabel("Frequency");
print("directFIRsymmetric_slb_update_constraints_test_hM","-dpdflatex");
close

% Done
diary off
movefile directFIRsymmetric_slb_update_constraints_test.diary.tmp ...
         directFIRsymmetric_slb_update_constraints_test.diary;
