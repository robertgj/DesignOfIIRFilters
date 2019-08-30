% directFIRsymmetric_slb_bandpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

% Also M=31;dBap=0.039217209;dBas=60.01714835;dBapt=0.188164;dBast=44.152;

test_common;

unlink("directFIRsymmetric_slb_bandpass_test.diary");
unlink("directFIRsymmetric_slb_bandpass_test.diary.tmp");
diary directFIRsymmetric_slb_bandpass_test.diary.tmp

%
% Initialise
%
maxiter=500;
verbose=true;
tol=1e-5;
ctol=tol;
strf="directFIRsymmetric_slb_bandpass_test";

% Band pass filter
M=16;
fapl=0.1;fapu=0.2;Wap=1;dBap=1;
fasl=0.05;fasu=0.25;Wasl=20;Wasu=40;dBas=36.947;

% Desired magnitude response
nplot=1000;
wa=(0:nplot)'*pi/nplot;
nasl=ceil(nplot*fasl/0.5)+1;
napl=floor(nplot*fapl/0.5)+1;
napu=ceil(nplot*fapu/0.5)+1;
nasu=floor(nplot*fasu/0.5)+1;  
na=[1 nasl napl napu nasu length(wa)];
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

% Make an initial band pass filter
h0=remez(2*M,[0 fasl fapl fapu fasu 0.5]*2,[0 0 1 1 0 0], ...
         [Wasl Wap Wasu],'bandpass');
hM0=h0(1:(M+1));
hM_active=1:length(hM0);

%
% Find exact SLB solution
%
[hM1,slb_iter,socp_iter,func_iter,feasible]= ...
  directFIRsymmetric_slb(@directFIRsymmetric_mmsePW, ...
                         hM0,hM_active,na,wa,Ad,Adu,Adl,Wa, ...
                         maxiter,tol,ctol,verbose);
if feasible==false
  error("directFIRsymmetric_slb failed!");
endif

%
% Plot exact solution
%
A0=directFIRsymmetricA(wa,hM0);
A1=directFIRsymmetricA(wa,hM1);
subplot(211)
plot(wa*0.5/pi,A0,"-",wa*0.5/pi,A1,"--",wa*0.5/pi,Adu,"-",wa*0.5/pi,Adl,"-");
axis([0 0.5 0.6 1.2]);
ylabel("Amplitude");
legend("Initial","PCLS","Adu","Adl","location","northeast");
legend("boxoff");
legend("left");
grid("on");
strt=sprintf("Bandpass FIR : fapl=%g,fapu=%g,dBap=%g,Wap=%g,\
fasl=%g,fasu=%g,dBas=%g,Wasl=%g,Wasu=%g", ...
             fapl,fapu,dBap,Wap,fasl,fasu,dBas,Wasl,Wasu);
title(strt);
subplot(212)
plot(wa*0.5/pi,A0,"-",wa*0.5/pi,A1,"--",wa*0.5/pi,Adu,"-",wa*0.5/pi,Adl,"-");
axis([0 0.5 -0.02 0.02]);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

%
% Try SLB solution with some coefficients rounded
%
dBapt=3;
dBast=25;
hM_inactive=[7,9,11];
hM_active(hM_inactive)=[];
nbits=8;nscale=2^(nbits-1);
hM1t=hM1;
hM1t(hM_inactive)=round(hM1(hM_inactive)*nscale)/nscale;
Adut=[(10^(-dBast/20))*ones(nasl,1); ...
      ones(nasu-nasl-1,1); ...
      (10^(-dBast/20))*ones(nplot-nasu+2,1)];
Adlt=[-(10^(-dBast/20))*ones(napl-1,1); ...
      (10^(-dBapt/20))*ones(napu-napl+1,1); ...
     -(10^(-dBast/20))*ones(nplot-napu+1,1)];
[hM2,slb_iter,socp_iter,func_iter,feasible]= ...
  directFIRsymmetric_slb(@directFIRsymmetric_mmsePW,hM1t,hM_active,na, ...
                         wa,Ad,Adut,Adlt,Wa,maxiter,tol,ctol,verbose);
if feasible==false
  error("hM2 not feasible");
endif

%
% Plot solution with some coefficients truncated
%
A2=directFIRsymmetricA(wa,hM2);
subplot(211)
plot(wa*0.5/pi,A0,"-",wa*0.5/pi,A2,"--",wa*0.5/pi,Adut,"-",wa*0.5/pi,Adlt,"-");
axis([0 0.5 0.6 1.2]);
ylabel("Amplitude");
legend("Initial","PCLS","Adut","Adlt","location","northeast");
legend("boxoff");
legend("left");
grid("on");
strt=sprintf("Bandpass FIR (coefficients %d,%d,%d rounded to %d bits) : \
fapl=%g,fapu=%g,dBapt=%g,fasl=%g,fasu=%g,dBast=%g", ...
             hM_inactive,nbits,fapl,fapu,dBapt,fasl,fasu,dBast);
title(strt);
subplot(212)
plot(wa*0.5/pi,A0,"-",wa*0.5/pi,A2,"--",wa*0.5/pi,Adut,"-",wa*0.5/pi,Adlt,"-");
axis([0 0.5 -0.1 0.1]);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_truncated"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"nplot=%d %% Frequency points across the band\n",nplot);
fprintf(fid,"M=%d %% M+1 distinct coefficients\n",M);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"fasl=%g %% Amplitude lower stop band edge\n",fasl);
fprintf(fid,"Wasl=%d %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"fasu=%g %% Amplitude upper stop band edge\n",fasu);
fprintf(fid,"Wasu=%d %% Amplitude upper stop band weight\n",Wasu);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple\n",dBas);
fclose(fid);

print_polynomial(hM1,"hM1");
print_polynomial(hM1,"hM1",strcat(strf,"_hM1_coef.m"));
print_polynomial(hM1t,"hM1t");
print_polynomial(hM2,"hM2");
print_polynomial(hM2,"hM2",strcat(strf,"_hM2_coef.m"));

save directFIRsymmetric_slb_bandpass_test.mat ...
     tol ctol maxiter M nplot fapl fapu Wap dBap fasl fasu Wasl Wasu dBas ...
     wa Ad Adu Adl Wa h0 hM1 ...
     nbits hM_inactive hM1t hM2 dBapt dBast Adut Adlt

% Done
diary off
movefile directFIRsymmetric_slb_bandpass_test.diary.tmp ...
         directFIRsymmetric_slb_bandpass_test.diary;

