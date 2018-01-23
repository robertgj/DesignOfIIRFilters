% directFIRsymmetric_slb_exchange_constraints_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("directFIRsymmetric_slb_exchange_constraints_test.diary");
unlink("directFIRsymmetric_slb_exchange_constraints_test.diary.tmp");
diary directFIRsymmetric_slb_exchange_constraints_test.diary.tmp

format compact;

tol=1e-3;

% Band pass filter
M=15;
fapl=0.1;fapu=0.2;Wap=1;dBap=0.5;
fasl=0.05;fasu=0.25;Wasl=10;Wasu=20;dBas=45;

% Make a band pass filter
f=[0 fasl fapl fapu fasu 0.5];
h0=remez(2*M,f*2,[0 0 1 1 0 0],[Wasl Wap Wasu],'bandpass');
hM0=h0(1:(M+1));
hM_active=1:length(hM0);

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
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(nplot-nasu+2,1)];

% Common strings
strd=sprintf("directFIRsymmetric_slb_exchange_constraints_test_%%s");
strM=sprintf ...
       ("Bandpass FIR %%s : fapl=%g,fapu=%g,dBap=%g,fasl=%g,fasu=%g,dBas=%g",...
        fapl,fapu,dBap,fasl,fasu,dBas);

% Amplitude response
A0=directFIRsymmetricA(wa,hM0);
vR=directFIRsymmetric_slb_update_constraints(A0,Adu,Adl,tol);

% Optimise
na=[1 nasl napl napu nasu length(wa)];
[hM1,socp_iter,func_iter,feasible]= ...
  directFIRsymmetric_mmsePW(vR,hM0,hM_active,na,wa,Ad,Adu,Adl,Wa,0,0,false);
if feasible==false
  error("hM1 not feasible");
endif

% Update constraints
A1=directFIRsymmetricA(wa,hM1);
vS=directFIRsymmetric_slb_update_constraints(A1,Adu,Adl,tol);

% Show constraints before exchange
printf("vR before exchange constraints:\n");
directFIRsymmetric_slb_show_constraints(vR,wa,A1);
printf("vS before exchange constraints:\n");
directFIRsymmetric_slb_show_constraints(vS,wa,A1);

% Plot amplitude
fa=wa*0.5/pi;
subplot(211);
plot(fa,[A0,A1,Adu,Adl], ...
     fa(vR.al),A0(vR.al),'*', ...
     fa(vR.au),A0(vR.au),'+');
axis([0,0.5,0.7,1.2]);
strM0=sprintf(strM,"before exchange");
title(strM0);
ylabel("Amplitude");
ylabel("Amplitude");
legend("A0","A1","Adu","Adl","location","northeast");
legend("boxoff");
legend("left");
subplot(212);
plot(fa,[A0,A1,Adl,Adu],fa(vR.al),A0(vR.al),'*',fa(vR.au),A0(vR.au),'+');
axis([0 0.5,-0.02,0.05]);
ylabel("Amplitude");
xlabel("Frequency")
print(sprintf(strd,"vR_A0_A1"),"-dpdflatex");
close

% Exchange constraints
[vR,vS,exchanged]= ...
  directFIRsymmetric_slb_exchange_constraints(vS,vR,A1,Adu,Adl,tol);
printf("vR after exchange constraints:\n");
directFIRsymmetric_slb_show_constraints(vR,wa,A1);
printf("vS after exchange constraints:\n");
directFIRsymmetric_slb_show_constraints(vS,wa,A1);

% Plot amplitude
subplot(211);
plot(fa,[A0,A1,Adu,Adl], ...
     fa(vR.al),A1(vR.al),'*', ...
     fa(vR.au),A1(vR.au),'+', ...
     fa(vS.al),A1(vS.al),'*', ...
     fa(vS.au),A1(vS.au),'+');
axis([0,0.5,0.7,1.2]);
strM1=sprintf(strM,"after exchange");
title(strM1);
ylabel("Amplitude");
legend("A0","A1","Adu","Adl","location","northeast");
legend("boxoff");
legend("left");
subplot(212);
plot(fa,[A0,A1,Adu,Adl], ...
     fa(vR.al),A1(vR.al),'*', ...
     fa(vR.au),A1(vR.au),'+', ...
     fa(vS.al),A1(vS.al),'*', ...
     fa(vS.au),A1(vS.au),'+');
axis([0, 0.5, -0.02, 0.05]);
ylabel("Amplitude");
xlabel("Frequency")
print(sprintf(strd,"vR_A0_vS_A1"),"-dpdflatex");
close

% Done
diary off
movefile directFIRsymmetric_slb_exchange_constraints_test.diary.tmp ...
         directFIRsymmetric_slb_exchange_constraints_test.diary;
