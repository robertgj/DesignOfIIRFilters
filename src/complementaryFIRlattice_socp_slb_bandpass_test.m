% complementaryFIRlattice_socp_slb_bandpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("complementaryFIRlattice_socp_slb_bandpass_test.diary");
unlink("complementaryFIRlattice_socp_slb_bandpass_test.diary.tmp");
diary complementaryFIRlattice_socp_slb_bandpass_test.diary.tmp

script_id=tic;

format compact

tol=1e-6
ctol=tol
maxiter=2000
verbose=false

% Filter specification from complementaryFIRlattice_socp_slb_bandpass_test.m
Ud0=2;Vd0=0;Md0=14;Qd0=0;Rd0=1;
d0 = [   0.0920209477, ...
         0.9990000000,   0.5128855702, ...
         0.7102414018,   0.9990000000,   0.9990000000,   0.9990000000, ... 
         0.9990000000,   0.9990000000,   0.9990000000, ...
        -0.9667931503,   0.2680255295,   2.2176753593,   3.3280228348, ... 
         3.7000375301,   4.4072989555,   4.6685041037 ]';
[b0p,~]=x2tf(d0,Ud0,Vd0,Md0,Qd0,Rd0);
% Find lattice coefficients (b1 is scaled to |H|<=1 and returned as b)
[b0,bc0,k0,khat0]=complementaryFIRlattice(b0p(:));
k0=k0(:);
khat0=khat0(:);
Nk=length(k0);
% Frequency specifications
nplot=1000;
wplot=pi*(0:(nplot-1))'/nplot;
fsl=0.05;fpl=0.1;fpu=0.2;fsu=0.25;
nsl=ceil(nplot*fsl/0.5)+1;
npl=floor(nplot*fpl/0.5)+1;
npu=ceil(nplot*fpu/0.5)+1;
nsu=floor(nplot*fsu/0.5)+1;
dBap=3;
dBas=20;
Wasl=100;Wap=1;Wasu=100;
tp=5;
tpr=0.5;
Wtp=0.01;
ppr=0.1;
Wpp=0.01;
% Initial response
Asq0=complementaryFIRlatticeAsq(wplot,k0,khat0);
T0=complementaryFIRlatticeT(wplot,k0,khat0);
P0=complementaryFIRlatticeP(wplot,k0,khat0);
% Squared-magnitude
wa=wplot;
Asqd=[zeros(npl-1,1);ones(npu-npl+1,1);zeros(nplot-npu,1)];
Asqdu=[(10^(-dBas/10))*ones(nsl,1); ...
       ones(nsu-nsl-1,1); ...
       (10^(-dBas/10))*ones(nplot-nsu+1,1)];
Asqdl=[zeros(npl-1,1);(10^(-dBap/10))*ones(npu-npl+1,1);zeros(nplot-npu,1)];
Wa=[Wasl*ones(nsl,1); ...
    zeros(npl-nsl-1,1); ...
    Wap*ones(npu-npl+1,1); ...
    zeros(nsu-npu-1,1); ...
    Wasu*ones(nplot-nsu+1,1)];
% Delay
wt=wplot(npl:npu);
Td=tp*ones(length(wt),1);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(length(wt),1);
% Phase
wp=wplot(npl:npu);
Pd=(P0(npl)+(tp*wplot(npl)))-(tp*wplot(npl:npu));
Pdu=Pd+(ppr/2);
Pdl=Pd-(ppr/2);
Wp=Wpp*ones(length(wp),1);

% Constraints on the coefficients
dmax=inf;
kkhat_u=ones(2*Nk,1);
kkhat_l=-kkhat_u;
kkhat_active=[find(k0~=0),(Nk+find(khat0~=0))];
kkhat_active=kkhat_active(:);
% Common strings
strt=sprintf("%%s:fsl=%g,fpl=%g,fpu=%g,fsu=%g,dBap=%g,dBas=%g,tp=%g",
             fsl,fpl,fpu,fsu,dBap,dBas,tp);
strf="complementaryFIRlattice_socp_slb_bandpass_test";

% Plot the initial response
Asq_plot=complementaryFIRlatticeAsq(wplot,k0,khat0);
T_plot=complementaryFIRlatticeT(wplot,k0,khat0);
P_plot=complementaryFIRlatticeP(wplot,k0,khat0);
subplot(311);
plot(wplot*0.5/pi,10*log10(Asq_plot));
ylabel("Amplitude(dB)");
axis([0 0.5 -40 5]);
grid("on");
title(sprintf(strt,"Initial"));
subplot(312);
plot(wplot*0.5/pi,T_plot);
ylabel("Group delay(samples)");
axis([0 0.5 tp-(2*tpr) tp+(2*tpr)]);
grid("on");
subplot(313);
plot(wplot*0.5/pi,(P_plot+(wplot*tp))/pi);
ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
xlabel("Frequency");
axis([0 0.5 0 2]);
grid("on");
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

%
% SOCP MMSE pass
%
run_id=tic;
[k1,khat1,opt_iter,func_iter,feasible] = ...
  complementaryFIRlattice_socp_mmse([],k0,khat0, ...
                                    kkhat_u,kkhat_l,kkhat_active,dmax, ...
                                    wa,Asqd,Asqdu,Asqdl,Wa, ...
                                    wt,Td,Tdu,Tdl,Wt, ...
                                    wp,Pd,Pdu,Pdl,Wp, ...
                                    maxiter,tol,verbose);
toc(run_id);
if feasible == 0 
  error("k1,khat1(mmse) infeasible");
endif
% Plot the MMSE response
Asq_plot=complementaryFIRlatticeAsq(wplot,k1,khat1);
T_plot=complementaryFIRlatticeT(wplot,k1,khat1);
P_plot=complementaryFIRlatticeP(wplot,k1,khat1);
subplot(311);
plot(wplot*0.5/pi,10*log10(Asq_plot));
ylabel("Amplitude(dB)");
axis([0 0.5 -40 5]);
grid("on");
title(sprintf(strt,"MMSE"));
subplot(312);
plot(wplot*0.5/pi,T_plot);
ylabel("Group delay(samples)");
axis([0 0.5 tp-(2*tpr) tp+(2*tpr)]);
grid("on");
subplot(313);
plot(wplot*0.5/pi,(P_plot+(wplot*tp))/pi);
ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
xlabel("Frequency");
axis([0 0.5 0 2]);
grid("on");
print(strcat(strf,"_mmse_response"),"-dpdflatex");
close

%
% SOCP PCLS pass
%
run_id=tic;
[k2,khat2,slb_iter,opt_iter,func_iter,feasible] = ...
  complementaryFIRlattice_slb(@complementaryFIRlattice_socp_mmse, ...
                              k1,khat1,kkhat_u,kkhat_l,kkhat_active,dmax, ...
                              wa,Asqd,Asqdu,Asqdl,Wa, ...
                              wt,Td,Tdu,Tdl,Wt, ...
                              wp,Pd,Pdu,Pdl,Wp, ...
                              maxiter,tol,ctol,verbose);
toc(run_id);
if feasible == 0 
  error("k2,khat2(pcls) infeasible");
endif
% Plot the PCLS response
Asq_plot=complementaryFIRlatticeAsq(wplot,k2,khat2);
T_plot=complementaryFIRlatticeT(wplot,k2,khat2);
P_plot=complementaryFIRlatticeP(wplot,k2,khat2);
subplot(311);
plot(wplot*0.5/pi,10*log10(Asq_plot));
ylabel("Amplitude(dB)");
axis([0 0.5 -40 5]);
grid("on");
title(sprintf(strt,"PCLS"));
subplot(312);
plot(wplot*0.5/pi,T_plot);
ylabel("Group delay(samples)");
axis([0 0.5 tp-(2*tpr) tp+(2*tpr)]);
grid("on");
subplot(313);
plot(wplot*0.5/pi,(P_plot+(wplot*tp))/pi);
ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
xlabel("Frequency");
axis([0 0.5 0 2]);
grid("on");
print(strcat(strf,"_pcls_response"),"-dpdflatex");
close

%
% PCLS amplitude and delay at local peaks
%
Asq=complementaryFIRlatticeAsq(wa,k2,khat2);
T=complementaryFIRlatticeT(wt,k2,khat2);
P=complementaryFIRlatticeP(wp,k2,khat2);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nsl,npl,npu,nsu,end])]);
AsqS=complementaryFIRlatticeAsq(wAsqS,k2,khat2);
printf("k2khat2:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k2khat2:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=complementaryFIRlatticeT(wTS,k2,khat2);
printf("kkhat2:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kkhat2:TS=[ ");printf("%f ",TS');printf(" (samples)\n");
vPl=local_max(Pdl-P);
vPu=local_max(P-Pdu);
wPS=unique([wp(vPl);wp(vPu);wp([1,end])]);
PS=complementaryFIRlatticeP(wPS,k2,khat2);
PS=(PS(:)+(wPS(:)*tp))/pi;
printf("kkhat2:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kkhat2:PS=[ ");printf("%f ",PS');printf(" (samples)\n");

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"nplot=%d %% Frequency points across the band\n",nplot);
fprintf(fid,"length(k1)=%d %% Num. FIR lattice coefficients\n",length(k1));
fprintf(fid,"sum(k1~=0)=%d %% Num. non-zero FIR lattice coef.s\n",sum(k1~=0));
fprintf(fid,"fsl=%g %% Lower stop band upper edge\n",fsl);
fprintf(fid,"fpl=%g %% Pass band lower edge\n",fpl);
fprintf(fid,"fpu=%g %% Pass band upper edge\n",fpu);
fprintf(fid,"fsu=%g %% Upper stop band lower edge\n",fsu);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"dBas=%d %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%d %% Ampl. lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Ampl. upper stop band weight\n",Wasu);
fprintf(fid,"tp=%g %% Nominal passband filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple\n",ppr);
fprintf(fid,"Wpp=%d %% Phase pass band weight\n",Wpp);
fclose(fid);
print_polynomial(k1,"k1");
print_polynomial(k1,"k1",strcat(strf,"_k1_coef.m"));
print_polynomial(khat1,"khat1");
print_polynomial(khat1,"khat1",strcat(strf,"_khat1_coef.m"));
print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(khat2,"khat2");
print_polynomial(khat2,"khat2",strcat(strf,"_khat2_coef.m"));
save complementaryFIRlattice_socp_slb_bandpass_test.mat ...
     tol ctol fsl fpl fpu fsu dBap Wap dBas Wasl Wasu tp tpr Wtp ppr Wpp ...
     k1 khat1 k2 khat2

% Done
toc(script_id);
diary off
movefile complementaryFIRlattice_socp_slb_bandpass_test.diary.tmp ...
       complementaryFIRlattice_socp_slb_bandpass_test.diary;
