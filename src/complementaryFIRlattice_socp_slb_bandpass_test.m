% complementaryFIRlattice_socp_slb_bandpass_test.m
% Design of an FIR lattice filter using SOCP. Neither the filter or the
% complementary filter is constrained to be minimum-phase.
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("complementaryFIRlattice_socp_slb_bandpass_test.diary");
delete("complementaryFIRlattice_socp_slb_bandpass_test.diary.tmp");
diary complementaryFIRlattice_socp_slb_bandpass_test.diary.tmp

strf="complementaryFIRlattice_socp_slb_bandpass_test";

script_id=tic;

tol=1e-6;
ctol=tol;
exptol=tol/1e2;
maxiter=2000;
verbose=false;

%
% Filter specification from iir_sqp_slb_fir_17_bandpass_test.m
%
Ud0=2;Vd0=0;Md0=14;Qd0=0;Rd0=1;
d0 = [   0.0918354149, ...
         0.5087750776,   0.9990000000, ...
         0.7092591369,   0.9990000000,   0.9990000000,   0.9990000000, ... 
         0.9990000000,   0.9990000000,   0.9990000000, ...
         0.9639556927,   1.6146874564,   2.2183638254,   2.5826636428, ... 
         0.2679750853,   2.9547181274,   1.8761069186 ]';
[b0p,~]=x2tf(d0,Ud0,Vd0,Md0,Qd0,Rd0);
% Find lattice coefficients (b1 is scaled to |H|<=1 and returned as b)
[b0,bc0,k0,khat0]=complementaryFIRlattice(b0p(:));
k0=k0(:);
khat0=khat0(:);
Nk=length(k0);
zplane(qroots(b0));
print(strcat(strf,"_initial_b0_pz"),"-dpdflatex");
close
zplane(qroots(bc0));
print(strcat(strf,"_initial_bc0_pz"),"-dpdflatex");
close

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
tpr=1;
Wtp=0.1;
pp=1.5*pi;
ppr=0.02*pi;
Wpp=1;

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
Pd=pp-(tp*wplot(npl:npu));
Pdu=Pd+(ppr/2);
Pdl=Pd-(ppr/2);
Wp=Wpp*ones(length(wp),1);

% Constraints on the coefficients
dmax=inf;
kkhat_u=(63/64)*ones(2*Nk,1);
kkhat_l=-kkhat_u;
kkhat_active=[find(k0~=0),(Nk+find(khat0~=0))];
kkhat_active=kkhat_active(:);

%
% SOCP PCLS pass
%
run_id=tic;
[k2,khat2,slb_iter,opt_iter,func_iter,feasible] = ...
  complementaryFIRlattice_slb(@complementaryFIRlattice_socp_mmse, ...
                              k0,khat0,kkhat_u,kkhat_l,kkhat_active,dmax, ...
                              wa,Asqd,Asqdu,Asqdl,Wa, ...
                              wt,Td,Tdu,Tdl,Wt, ...
                              wp,Pd,Pdu,Pdl,Wp, ...
                              maxiter,tol,ctol,verbose);
toc(run_id);
if feasible == 0 
  error("k2,khat2(pcls) infeasible");
endif

% Find the impulse response
[A2,b2,ch2,dh2,cg2,dg2]=complementaryFIRlattice2Abcd(k2,khat2);
[Nh2,Dh2]=Abcd2tf(A2,b2,ch2,dh2);
[Ng2,Dg2]=Abcd2tf(A2,b2,cg2,dg2);
Hh2=freqz(Nh2,Dh2,wplot);
Hg2=freqz(Ng2,Dg2,wplot);
stdK2=std((Hg2.*conj(Hg2))+(Hh2.*conj(Hh2)));
if stdK2 > exptol
  error("stdK2(%g*exptol) > exptol",stdK2/exptol);
endif

% Compare to expected
k2exp = [   0.9843737242,   0.9841867648,   0.9841429684,   0.9839804102, ... 
            0.9842033717,   0.9843739460,   0.9843742966,   0.9840630634, ... 
            0.9843746979,   0.9629684164,   0.9666949443,   0.9843739765, ... 
            0.9234826024,   0.9571339447,   0.9842698881,   0.9843185716, ... 
            0.1408380456 ]';
if norm(k2exp-k2)>exptol
  error("norm(k2exp-k2)(%g*exptol) > exptol",norm(k2exp-k2)/exptol);
endif
khat2exp = [  -0.0204337457,  -0.0252342132,   0.0172871552,   0.0618210478, ... 
               0.0549686528,   0.0431589176,   0.0826067627,   0.0901262325, ... 
              -0.1107303490,  -0.4501326504,  -0.4480180626,   0.0503961185, ... 
               0.5258041229,   0.4614365718,   0.0540761666,  -0.1628553470, ... 
               0.9837324061 ]';
if norm(khat2exp-khat2)>exptol
  error("norm(khat2exp-khat2)(%g*exptol) > exptol",norm(khat2exp-khat2)/exptol);
endif
Nh2exp = [   0.0957863656,   0.0556424771,  -0.0647286225,  -0.2071819392, ... 
            -0.2067699420,  -0.0120677003,   0.1927519452,   0.2087919832, ... 
             0.0525065055,  -0.0879281690,  -0.0896047523,  -0.0252302452, ... 
             0.0002184713,  -0.0185153572,  -0.0164098736,   0.0088505616, ... 
             0.0138882862 ];
if norm(Nh2exp-Nh2)>exptol
  error("norm(Nh2exp-Nh2)(%g*exptol) > exptol",norm(Nh2exp-Nh2)/exptol);
endif
Ng2exp = [   0.6690532473,  -0.4003796331,   0.2705539964,   0.4629766233, ... 
             0.2658539238,   0.0146999751,  -0.0880025939,  -0.0702364458, ... 
            -0.0356404332,  -0.0232361897,  -0.0133823107,   0.0052219660, ... 
             0.0173559277,   0.0129662088,   0.0015994535,  -0.0036120212, ... 
            -0.0019883447 ];
if norm(Ng2exp-Ng2)>exptol
  error("norm(Ng2exp-Ng2)(%g*exptol) > exptol",norm(Ng2exp-Ng2)/exptol);
endif

%
% Simulate the filter
%

% Make a noise signal with standard deviation 0.25
nsamples=2^14;
rand("state",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=u/std(u);

% Filter
[yk2 ykhat2 xxk2]=complementaryFIRlatticeFilter(k2,khat2,u);
yk2=yk2(:);
ykhat2=ykhat2(:);
yNh2=filter(Nh2,1,u);
yNh2=yNh2(:);
yNg2=filter(Ng2,1,u);
yNg2=yNg2(:);

% Compare
if max(abs(yk2-yNh2)) > exptol
  error("max(abs(yk2-yNh2)) (%g) > %g", max(abs(yk2-yNh2)), exptol);
endif
if max(abs(ykhat2-yNg2)) > exptol
  error("max(abs(ykhat2-yNg2)) (%g) > %g", max(abs(ykhat2-yNg2)), exptol);
endif

%
% Plot the PCLS response
%
Asq_plot=complementaryFIRlatticeAsq(wplot,k2,khat2);
T_plot=complementaryFIRlatticeT(wplot,k2,khat2);
P_plot=complementaryFIRlatticeP(wplot,k2,khat2);
subplot(311);
plot(wplot*0.5/pi,10*log10(Asq_plot));
ylabel("Amplitude(dB)");
axis([0 0.5 -30 1]);
grid("on");
strt=sprintf ...
       ("fsl=%g,fpl=%g,fpu=%g,fsu=%g,dBap=%g,dBas=%g,tp=%g,tpr=%g,pp=%g,ppr=%g",
        fsl,fpl,fpu,fsu,dBap,dBas,tp,tpr,pp/pi,ppr/pi);
title(strt);
subplot(312);
plot(wplot*0.5/pi,T_plot);
ylabel("Group delay(samples)");
axis([0 0.5 tp-tpr tp+tpr]);
grid("on");
subplot(313);
plot(wplot*0.5/pi,(P_plot+(wplot*tp))/pi);
ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
xlabel("Frequency");
axis([0 0.5 (pp-ppr)/pi (pp+ppr)/pi]);
grid("on");
print(strcat(strf,"_pcls_response"),"-dpdflatex");
close
zplane(qroots(Nh2));
print(strcat(strf,"_pcls_Nh2_pz"),"-dpdflatex");
close
zplane(qroots(Ng2));
print(strcat(strf,"_pcls_Ng2_pz"),"-dpdflatex");
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
fprintf(fid,"length(k0)=%d %% Num. FIR lattice coefficients\n",length(k0));
fprintf(fid,"sum(k0~=0)=%d %% Num. non-zero FIR lattice coef.s\n",sum(k0~=0));
fprintf(fid,"fsl=%g %% Lower stop band upper edge\n",fsl);
fprintf(fid,"fpl=%g %% Pass band lower edge\n",fpl);
fprintf(fid,"fpu=%g %% Pass band upper edge\n",fpu);
fprintf(fid,"fsu=%g %% Upper stop band lower edge\n",fsu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%g %% Ampl. lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%g %% Ampl. upper stop band weight\n",Wasu);
fprintf(fid,"tp=%g %% Pass band group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Delay pass band weight\n",Wtp);
fprintf(fid,"pp/pi=%4.2f %% Pass band phase(adjusted for tp,units of pi)\n",
        pp/pi);
fprintf(fid,"ppr/pi=%4.2f %% Phase pass band peak-to-peak ripple(units of pi)\n",
        ppr/pi);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(khat2,"khat2");
print_polynomial(khat2,"khat2",strcat(strf,"_khat2_coef.m"));
print_polynomial(std(xxk2),"std(xxk2)");
print_polynomial(std(xxk2),"std(xxk2)",strcat(strf,"_std_xxk2.m"));
print_polynomial(Nh2,"Nh2");
print_polynomial(Nh2,"Nh2",strcat(strf,"_Nh2_coef.m"));
print_polynomial(Ng2,"Ng2");
print_polynomial(Ng2,"Ng2",strcat(strf,"_Ng2_coef.m"));
save complementaryFIRlattice_socp_slb_bandpass_test.mat ...
     tol ctol fsl fpl fpu fsu dBap Wap dBas Wasl Wasu tp tpr Wtp pp ppr Wpp ...
     k2 khat2 Nh2 Ng2

% Done
toc(script_id);
diary off
movefile complementaryFIRlattice_socp_slb_bandpass_test.diary.tmp ...
         complementaryFIRlattice_socp_slb_bandpass_test.diary;
