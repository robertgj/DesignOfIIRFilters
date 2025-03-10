% schurOneMlatticePipelined_socp_slb_bandpass_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMlatticePipelined_socp_slb_bandpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

script_id=tic;

maxiter=2000
ftol=1e-4
ctol=1e-7
verbose=false

% Bandpass filter specification
fapl=0.095,fapu=0.205,dBap=-20*log10(0.99),Wap=1
fasl=0.05,fasu=0.25,dBas=40,Wat=0.0001,Wasl=1000,Wasu=1000
ftpl=0.1,ftpu=0.2,tp=16,tpr=tp/400,Wtp=0.1

% Initial filter (found by tarczynski_bandpass_R1_test.m)
tarczynski_bandpass_R1_test_N0_coef;
tarczynski_bandpass_R1_test_D0_coef;
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(N0,D0);

% Amplitude constraints
n=500;
wa=(0:(n-1))'*pi/n;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Asqd=[zeros(napl-1,1); ...
      ones(napu-napl+1,1); ...
      zeros(n-napu,1)];
Asqdu=[(10^(-dBas/10))*ones(nasl,1); ...
       ones(nasu-nasl-1,1); ...
       (10^(-dBas/10))*ones(n-nasu+1,1)];
Asqdl=[zeros(napl-1,1); ...
       (10^(-dBap/10))*ones(napu-napl+1,1); ...
       zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Wat*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Wat*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];
nachk=[1, ...
       nasl-1,nasl,nasl+1, ...
       napl-1,napl,napl+1, ...
       napu-1,napu,napu+1, ...
       nasu-1,nasu,nasu+1, ...
       n-1];

% Group delay constraints
ntpl=floor(n*ftpl/0.5);
ntpu=ceil(n*ftpu/0.5);
wt=(ntpl:ntpu)'*pi/n;
ntp=length(wt);
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% dAsqdw constraints
wd=[];
Dd=[];
Ddu=[];
Ddl=[];
Wd=[];

% Constraints on the coefficients
dmax=0;
rho=127/128
k0=k0(:);
c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kk0=k0(1:(Nk-1)).*k0(2:Nk);
Nkk=length(kk0);
ck0=c0(2:Nk).*k0(2:Nk);
Nck=length(ck0);
Nx=Nk+Nc+Nkk+Nck;
kc_u=[rho*ones(Nk,1);10*ones(Nc,1);rho*ones(Nkk,1);10*ones(Nck,1)];
kc_l=-kc_u;
kc_active=(1:Nx)';

%
% SOCP MMSE pass
%
run_id=tic;
[k1,c1,kk1,ck1,opt_iter,func_iter,feasible] = ...
  schurOneMlatticePipelined_socp_mmse([], ...
                                      k0,epsilon0,c0,kk0,ck0, ...
                                      kc_u,kc_l,kc_active,dmax, ...
                                      wa,Asqd,Asqdu,Asqdl,Wa, ...
                                      wt,Td,Tdu,Tdl,Wt, ...
                                      wp,Pd,Pdu,Pdl,Wp, ...
                                      wd,Dd,Ddu,Ddl,Wd, ...
                                      maxiter,ftol,ctol,verbose);
toc(run_id);
if feasible == 0 
  error("k1,c1(MMSE) infeasible");
endif

%
% SOCP PCLS pass
%
run_id=tic;
[k2,c2,kk2,ck2,slb_iter,opt_iter,func_iter,feasible] = ...
schurOneMlatticePipelined_slb(@schurOneMlatticePipelined_socp_mmse, ...
                              k1,epsilon0,c1,kk1,ck1, ...
                              kc_u,kc_l,kc_active,dmax, ...
                              wa,Asqd,Asqdu,Asqdl,Wa, ...
                              wt,Td,Tdu,Tdl,Wt, ...
                              wp,Pd,Pdu,Pdl,Wp, ...
                              wd,Dd,Ddu,Ddl,Wd, ...
                              maxiter,ftol,ctol,verbose);
toc(run_id);
if feasible == 0 
  error("k2,c2(PCLS) infeasible");
endif

% Plot the PCLS response
pcls_strf=strcat(strf,"_pcls_response");

%
% PCLS amplitude and delay at local peaks
%
Asq=schurOneMlatticePipelinedAsq(wa,k2,epsilon0,c2,kk2,ck2);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=schurOneMlatticePipelinedAsq(wAsqS,k2,epsilon0,c2,kk2,ck2);
printf("k3c3:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k3c3:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMlatticePipelinedT(wt,k2,epsilon0,c2,kk2,ck2);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMlatticePipelinedT(wTS,k2,epsilon0,c2,kk2,ck2);
printf("k3c3:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k3c3:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

% Check transfer function
[A2,B2,C2,dd2]=schurOneMlatticePipelined2Abcd(k2,epsilon0,c2,kk2,ck2);
[N2,D2]=Abcd2tf(A2,B2,C2,dd2);
D2=D2(1:(Nk+1));
H2=freqz(N2,D2,wa);
if max(abs((abs(H2).^2)-Asq)) > 2e-11
  error("max(abs((abs(H2).^2)-Asq))(%g)>2e-11", max(abs((abs(H2).^2)-Asq)));
endif

% Plot results
strt=sprintf("Pipelined Schur bandpass : \
fasl=%g,fapl=%g,fapu=%g,fasu=%g,dBap=%6.4g,dBas=%g",
             fasl,fapl,fapu,fasu,dBap,dBas);

% Pole-zero plot
zplane(qroots(N2(:)),qroots(D2(:)));
title(sprintf(strt," "));
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

% Response
subplot(211);
[ax,ha,hs]=plotyy(wa*0.5/pi,10*log10(Asq),wa*0.5/pi,10*log10(Asq));
axis(ax(1),[0 0.5 -0.1 0.02]);
axis(ax(2),[0 0.5 -dBas+[-5,1]]);
grid("on");
title(strt);
ylabel("Amplitude(dB)");
subplot(212);
plot(wt*0.5/pi,T);
axis([0 0.5 tp+(tpr*[-1,1])]);
grid("on");
ylabel("Delay(samples)");
xlabel("Frequency");
print(strcat(strf,"_pcls_response"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"%% length(c0)=%d %% Tap coefficients\n",length(c0));
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%g %% Ampl. lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%g %% Ampl. upper stop band weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal passband filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Delay pass band weight\n",Wtp);
fclose(fid);

print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(epsilon0,"epsilon0");
print_polynomial(epsilon0,"epsilon0",strcat(strf,"_epsilon0_coef.m"));
print_polynomial(c2,"c2");
print_polynomial(c2,"c2",strcat(strf,"_c2_coef.m"));
print_polynomial(kk2,"kk2");
print_polynomial(kk2,"kk2",strcat(strf,"_kk2_coef.m"));
print_polynomial(ck2,"ck2");
print_polynomial(ck2,"ck2",strcat(strf,"_ck2_coef.m"));

print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

eval(sprintf(strcat("save %s.mat ftol ctol dmax rho",
                    " fapl fapu fasl fasu dBap Wap dBas Wasl Wasu",
                    " ftpl ftpu tp tpr Wtp",
                    " N0 D0 k0 c0 kk0 ck0",
                    " k2 c2 kk2 ck2 N2 D2"),strf));

% Done
toc(script_id);
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
