% directFIRsymmetric_socp_slb_bandpass_test.m
% Copyright (C) 2017 Robert G. Jenssen

% Optimisation of Schur one-multiplier lattice bandpass filter response with
% 10-bit signed-digit coefficients having Ito et al. allocation and SOCP
% relaxation solution.

test_common;

unlink("directFIRsymmetric_socp_slb_bandpass_test.diary");
unlink("directFIRsymmetric_socp_slb_bandpass_test.diary.tmp");
diary directFIRsymmetric_socp_slb_bandpass_test.diary.tmp

tic;

maxiter=5000
verbose=false;
tol=1e-5;
ctol=tol;
strf="directFIRsymmetric_socp_slb_bandpass_test";

% Band pass filter
M=15;
fapl=0.1;fapu=0.2;Wap=1;dBap=2;
fasl=0.05;fasu=0.25;Wasl=20;Wasu=40;dBas=47;

% Desired magnitude response
npoints=1000;
wa=(0:npoints)'*pi/npoints;
nasl=ceil(npoints*fasl/0.5)+1;
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
nasu=floor(npoints*fasu/0.5)+1;  
na=[1 nasl napl napu nasu length(wa)];
Ad=[zeros(napl-1,1); ...
    ones(napu-napl+1,1); ...
    zeros(npoints-napu+1,1)];
Adu=[(10^(-dBas/20))*ones(nasl,1); ...
     ones(nasu-nasl-1,1); ...
     (10^(-dBas/20))*ones(npoints-nasu+2,1)];
Adl=[-(10^(-dBas/20))*ones(napl-1,1); ...
      (10^(-dBap/20))*ones(napu-napl+1,1); ...
     -(10^(-dBas/20))*ones(npoints-napu+1,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(npoints-nasu+2,1)];

% Sanity checks
nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu,nasu+1];
printf ...
  ("nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu,nasu+1];\n");
printf("nchka=[ ");printf("%d ",nchka);printf("];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)'/(2*pi));printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Make an initial band pass filter
h0=remez(2*M,[0 fasl fapl fapu fasu 0.5]*2,[0 0 1 1 0 0],[10 1 10],'bandpass');
hM0=h0(1:(M+1));
hM0_active=1:length(hM0);

% SLB SOCP pass
[hM1,slb_iter,socp_iter,func_iter,feasible]= ...
directFIRsymmetric_slb(@directFIRsymmetric_socp_mmsePW, ...
                       hM0,hM0_active,na,wa,Ad,Adu,Adl,Wa, ...
                       maxiter,tol,ctol,verbose);
if feasible==false
  error("directFIRsymmetric_slb failed!");
endif

% Show results
printf("hM1=[ ");printf("%g ",hM1');printf("]';\n");
print_polynomial(hM1,"hM1",strcat(strf,"_hM1_coef.m"),"%12.8f");

% Amplitude and delay at local peaks
A=directFIRsymmetricA(wa,hM1);
vAl=local_max(Adl-A);
vAu=local_max(A-Adu);
wAS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AS=directFIRsymmetricA(wAS,hM1);
printf("hM1:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("hM1:AS=[ ");printf("%f ",20*log10(AS'));printf(" ] (dB)\n");

% Calculate response
nplot=1001;
wplot=(0:(nplot-1))'*pi/nplot;
A_hM1=directFIRsymmetricA(wplot,hM1);

% Plot amplitude response
subplot(211)
plot(wplot*0.5/pi,20*log10(abs(A_hM1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -2 1]);
strt=sprintf("Direct-form symmetric bandpass filter pass-band : \
fapl=%g,fapu=%g,dBap=%g,Wap=1",fapl,fapu,dBap,Wap);
title(strt);
grid("on");
subplot(212)
plot(wplot*0.5/pi,20*log10(abs(A_hM1)));
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 -30]);
strt=sprintf("Direct-form symmetric bandpass filter stop-band : \
fasl=%g,fasu=%g,dBas=%g,Wasl=%g,Wasu=%g",fasl,fasu,dBas,Wasl,Wasu);
title(strt);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"maxiter=%d %% SOCP iteration limit\n",maxiter);
fprintf(fid,"npoints=%g %% Frequency points across the band\n",npoints);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBas=%d %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%d %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Amplitude upper stop band weight\n",Wasu);
fclose(fid);

% Save results
save directFIRsymmetric_socp_slb_bandpass_test.mat ...
     tol ctol npoints hM0 fapl fapu dBap Wap fasl fasu dBas Wasl Wasu hM1
       
% Done
toc;
diary off
movefile directFIRsymmetric_socp_slb_bandpass_test.diary.tmp ...
         directFIRsymmetric_socp_slb_bandpass_test.diary;
