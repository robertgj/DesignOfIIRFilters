% directFIRsymmetric_slb_lowpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("directFIRsymmetric_slb_lowpass_test.diary");
unlink("directFIRsymmetric_slb_lowpass_test.diary.tmp");
diary directFIRsymmetric_slb_lowpass_test.diary.tmp

%
% Initialise
%
maxiter=100;
verbose=true;
tol=1e-5;
ctol=tol;
strf="directFIRsymmetric_slb_lowpass_test";

% Low pass filter
M=15;
fap=0.1;Wap=1;dBap=0.02;
fas=0.2;Was=10;dBas=52;

% Desired magnitude response
nplot=1000;
wa=(0:nplot)'*pi/nplot;
nap=ceil(nplot*fap/0.5)+1;
nas=floor(nplot*fas/0.5)+1;
na=[1 nap nas (nplot+1)];
Ad=[ones(nap,1);zeros(nplot-nap+1,1)];
Adu=[ones(nas-1,1);(10^(-dBas/20))*ones(nplot-nas+2,1)];
Adl=[(10^(-dBap/20))*ones(nap,1);-(10^(-dBas/20))*ones(nplot-nap+1,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(nplot-nas+2,1)]; 

% Make an initial low pass filter
h0=remez(2*M,[0 0.1 0.25 0.5]*2,[1 1 0 0]);
hM0=h0(1:(M+1));
hM_active=1:length(hM0);

%
% Find SLB solution
%
[hM1,slb_iter,socp_iter,func_iter,feasible]= ...
  directFIRsymmetric_slb(@directFIRsymmetric_mmsePW, ...
                         hM0,hM_active,na,wa,Ad,Adu,Adl,Wa, ...
                         maxiter,tol,ctol,verbose);
if feasible==false
  error("hM1 not feasible");
endif

%
% Plot exact solution
%
A0=directFIRsymmetricA(wa,hM0);
A1=directFIRsymmetricA(wa,hM1);
subplot(211)
plot(wa*0.5/pi,A0,"-",wa*0.5/pi,A1,"--",wa*0.5/pi,Adu,"-",wa*0.5/pi,Adl,"-");
axis([0 0.5 0.994 1.001]);
ylabel("Amplitude");
legend("Initial","PCLS","Adu","Adl","location","northeast");
legend("boxoff");
legend("left");
grid("on");
strt=sprintf("Lowpass FIR : fap=%g,dBap=%g,Wap=%g,fas=%g,dBas=%g,Was=%g", ...
             fap,dBap,Wap,fas,dBas,Was);
title(strt);
subplot(212)
plot(wa*0.5/pi,A0,"-",wa*0.5/pi,A1,"--",wa*0.5/pi,Adu,"-",wa*0.5/pi,Adl,"-");
axis([0 0.5 -0.004 0.004]);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

%
% Try SLB solution with one coefficient truncated
%
hM_inactive=6;
hM_active(hM_inactive)=[];
nbits=10;nscale=2^(nbits-1);
hM1t=hM1;
hM1t(hM_inactive)=round(hM1(hM_inactive)*nscale)/nscale;
dBapt=0.05;
dBast=52;
Adut=[ones(nas-1,1);(10^(-dBast/20))*ones(nplot-nas+2,1)];
Adlt=[(10^(-dBapt/20))*ones(nap,1);-(10^(-dBast/20))*ones(nplot-nap+1,1)];
[hM2,slb_iter,socp_iter,func_iter,feasible]=...
  directFIRsymmetric_slb(@directFIRsymmetric_mmsePW,hM1t,hM_active,na, ...
                         wa,Ad,Adut,Adlt,Wa,maxiter,tol,ctol,verbose);
if feasible==false
  error("hM2 not feasible");
endif

%
% Plot solution with one coefficient truncated 
%
A2=directFIRsymmetricA(wa,hM2);
subplot(211)
plot(wa*0.5/pi,A0,"-",wa*0.5/pi,A2,"--",wa*0.5/pi,Adut,"-",wa*0.5/pi,Adlt,"-");
axis([0 0.5 0.994 1.001]);
ylabel("Amplitude");
legend("Initial","PCLS","Adut","Adlt","location","northeast");
legend("boxoff");
legend("left");
grid("on");
strt=sprintf("Lowpass FIR (coefficient %d rounded to %d bits) : \
fap=%g,dBapt=%g,Wap=%g,fas=%g,dBast=%g,Was=%g", ...
             hM_inactive,nbits,fap,dBapt,Wap,fas,dBast,Was);
title(strt);
subplot(212)
plot(wa*0.5/pi,A0,"-",wa*0.5/pi,A2,"--",wa*0.5/pi,Adut,"-",wa*0.5/pi,Adlt,"-");
axis([0 0.5 -0.004 0.004]);
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
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%d %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);

print_polynomial(hM1,"hM1");
print_polynomial(hM1,"hM1",strcat(strf,"_hM1_coef.m"));
print_polynomial(hM1t,"hM1t");
print_polynomial(hM2,"hM2");
print_polynomial(hM2,"hM2",strcat(strf,"_hM2_coef.m"));

save directFIRsymmetric_slb_lowpass_test.mat ...
     tol ctol maxiter M nplot ...
     fap Wap dBap fas Was dBas wa Ad Adu Adl Wa h0 hM1 ...
     nbits hM_inactive hM1t hM2 dBapt dBast Adut Adlt

% Done
diary off
movefile directFIRsymmetric_slb_lowpass_test.diary.tmp ...
         directFIRsymmetric_slb_lowpass_test.diary;

