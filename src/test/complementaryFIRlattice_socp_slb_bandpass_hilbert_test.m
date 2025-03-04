% complementaryFIRlattice_socp_slb_bandpass_hilbert_test.m
% Design of an FIR lattice bandpass Hilbert filter using SOCP.
% Neither the filter or the complementary filter is constrained to be
% minimum-phase.

% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="complementaryFIRlattice_socp_slb_bandpass_hilbert_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-6;
ctol=ftol;
maxiter=2000;
verbose=false;

%
% Frequency specification
%
fapl=0.1,fapu=0.2,dBap=3,Wap=1
fasl=0.05,
fasu=0.25,dBas=20,Wasl=1,Wasu=1
tp=5;tpr=1;Wtp=0.1;
pp=1.5;ppr=0.02;Wpp=1;

nplot=1000;
wplot=pi*(0:(nplot-1))'/nplot;
nasl=ceil(nplot*fasl/0.5)+1;
nasu=floor(nplot*fasu/0.5)+1;
napl=floor(nplot*fapl/0.5)+1;
napu=ceil(nplot*fapu/0.5)+1;

%
% Initial filter from iir_sqp_slb_fir_17_bandpass_test.m
%
iir_sqp_slb_fir_17_bandpass_test_d1_coef;
[b0p,~]=x2tf(d1,Ud1,Vd1,Md1,Qd1,Rd1);
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
% Check complementary responses
[A0,b0,ch0,dh0,cg0,dg0]=complementaryFIRlattice2Abcd(k0,khat0);
Hh0=Abcd2H(wplot,A0,b0,ch0,dh0);
Hg0=Abcd2H(wplot,A0,b0,cg0,dg0);
stdK0=std((Hg0.*conj(Hg0))+(Hh0.*conj(Hh0)));
if stdK0 > 10*eps
  error("stdK0(%g*eps) > 10*eps",stdK0/eps);
endif

%
% Constraints
%

% Squared-magnitude
wa=wplot;
Asqd=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(nplot-napu,1)];
Asqdu=[(10^(-dBas/10))*ones(nasl,1); ...
       ones(nasu-nasl-1,1); ...
       (10^(-dBas/10))*ones(nplot-nasu+1,1)];
Asqdl=[zeros(napl-1,1);(10^(-dBap/10))*ones(napu-napl+1,1);zeros(nplot-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(nplot-nasu+1,1)];
% Delay
wt=wplot(napl:napu);
Td=tp*ones(length(wt),1);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(length(wt),1);
% Phase
wp=wplot(napl:napu);
Pd=(pp*pi)-(tp*wplot(napl:napu));
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(length(wp),1);
% Coefficients
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
                              maxiter,ftol,ctol,verbose);
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
if stdK2 > ctol/100
  error("stdK2(%g*ctol/100) > ctol/100",100*stdK2/ctol);
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
if max(abs(yk2-yNh2)) > ctol/100
  error("max(abs(yk2-yNh2)) (%g) > %g", max(abs(yk2-yNh2)), ctol/100);
endif
if max(abs(ykhat2-yNg2)) > ctol/100
  error("max(abs(ykhat2-yNg2)) (%g) > %g", max(abs(ykhat2-yNg2)), ctol/100);
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
strt=sprintf("fasl=%g,fapl=%g,fapu=%g,fasu=%g,dBap=%g,dBas=%g,\
tp=%g,tpr=%g,pp=%g$\\pi$,ppr=%g$\\pi$",
             fasl,fapl,fapu,fasu,dBap,dBas,tp,tpr,pp,ppr);
title(strt);
subplot(312);
plot(wplot*0.5/pi,(P_plot+(wplot*tp))/pi);
axis([0 0.5 (pp-ppr) (pp+ppr)]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wplot*0.5/pi,T_plot);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 tp-tpr tp+tpr]);
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
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
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
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"nplot=%d %% Frequency points across the band\n",nplot);
fprintf(fid,"%% length(k0)=%d %% Num. FIR lattice coefficients\n",length(k0));
fprintf(fid,"%% sum(k0~=0)=%d %% Num. non-zero FIR lattice coef.s\n",sum(k0~=0));
fprintf(fid,"fasl=%g %% Lower stop band upper edge\n",fasl);
fprintf(fid,"fapl=%g %% Pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Pass band upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Upper stop band lower edge\n",fasu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%g %% Ampl. lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%g %% Ampl. upper stop band weight\n",Wasu);
fprintf(fid,"tp=%g %% Pass band group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Delay pass band weight\n",Wtp);
fprintf(fid,"pp=%4.2f %% Pass band phase(rad./pi), adjusted for tp\n",pp);
fprintf(fid,"ppr=%4.2f %% Phase pass band peak-to-peak ripple(rad./pi)\n",ppr);
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

eval(sprintf("save %s.mat ftol ctol fasl fapl fapu fasu dBap Wap dBas Wasl Wasu \
tp tpr Wtp pp ppr Wpp k2 khat2 Nh2 Ng2",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
