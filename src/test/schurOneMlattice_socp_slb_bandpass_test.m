% schurOneMlattice_socp_slb_bandpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="schurOneMlattice_socp_slb_bandpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

script_id=tic;

maxiter=10000
ftol=1e-4
ctol=1e-6
verbose=false

% Bandpass filter specification (Also ftpl=0.095,ftpu=0.205)
fapl=0.08,fapu=0.22,dBap=0.08,Wap=1,Wat=0.01
fasl=0.05,fasu=0.25,dBas=40,Wasl=20000,Wasu=10000
ftpl=0.1,ftpu=0.2,tp=16,tpr=tp/500,Wtp=1

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

% Group delay constraints
ntpl=floor(n*ftpl/0.5);
ntpu=ceil(n*ftpu/0.5);
wt=(ntpl:ntpu)'*pi/n;
ntp=length(wt);
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
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
dmax=inf;
rho=127/128
k0=k0(:);
c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kc_u=[rho*ones(size(k0));10*ones(size(c0))];
kc_l=-kc_u;
kc_active=(1:(Nk+Nc))';

%
% SOCP MMSE pass
%
run_id=tic;
[k1p,c1p,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_socp_mmse([], ...
                             k0,epsilon0,ones(size(k0)),c0, ...
                             kc_u,kc_l,kc_active,dmax, ...
                             wa,Asqd,Asqdu,Asqdl,Wa, ...
                             wt,Td,Tdu,Tdl,Wt, ...
                             wp,Pd,Pdu,Pdl,Wp, ...
                             wd,Dd,Ddu,Ddl,Wd, ...
                             maxiter,ftol,ctol,verbose);
toc(run_id);
if feasible == 0 
  error("k1p,c1p(MMSE) infeasible");
endif

%
% SOCP PCLS pass
%
run_id=tic;
[k2p,c2p,slb_iter,opt_iter,func_iter,feasible] = ...
schurOneMlattice_slb(@schurOneMlattice_socp_mmse, ...
                     k1p,epsilon0,ones(size(k0)),c1p, ...
                     kc_u,kc_l,kc_active,dmax, ...
                     wa,Asqd,Asqdu,Asqdl,Wa, ...
                     wt,Td,Tdu,Tdl,Wt, ...
                     wp,Pd,Pdu,Pdl,Wp, ...
                     wd,Dd,Ddu,Ddl,Wd, ...
                     maxiter,ftol,ctol,verbose);
toc(run_id);
if feasible == 0 
  error("k2p,c2p(PCLS) infeasible");
endif

% Recalculate epsilon3, p3 and c3
[N3,D3]=schurOneMlattice2tf(k2p,epsilon0,ones(size(k0)),c2p);
[k3,epsilon3,p3,c3]=tf2schurOneMlattice(N3,D3);

% PCLS amplitude and delay at local peaks
Asq=schurOneMlatticeAsq(wa,k3,epsilon3,p3,c3);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=schurOneMlatticeAsq(wAsqS,k3,epsilon3,p3,c3);
printf("k3c3:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k3c3:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMlatticeT(wt,k3,epsilon3,p3,c3);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMlatticeT(wTS,k3,epsilon3,p3,c3);
printf("k3c3:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k3c3:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

% Check transfer function
HH=freqz(N3,D3,wa);
if max(abs((abs(HH).^2)-Asq)) > 5e-11
  error("max(abs((abs(HH).^2)-Asq))(%g) > 5e-11", max(abs((abs(HH).^2)-Asq)));
endif

% Plot the PCLS response
strt=sprintf(["Schur 1-multiplier SOCP PCLS : fasl=%g,fapl=%g,fapu=%g,fasu=%g,", ...
 "dBap=%6.4g,dBas=%g"],fasl,fapl,fapu,fasu,dBap,dBas);
subplot(211);
[ax,ha,hs]=plotyy(wa*0.5/pi,10*log10(Asq),wa*0.5/pi,10*log10(Asq));
axis(ax(1),[0 0.5 -0.1 0.02]);
axis(ax(2),[0 0.5 -dBas+[-5,1]]);
grid("on");
title(strt);
ylabel("Amplitude(dB)");
subplot(212);
plot(wt*0.5/pi,T);
axis([0 0.5 tp+(0.02*[-1,1])]);
grid("on");
ylabel("Delay(samples)");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_pcls_response"),"-dpdflatex");
close

% Pole-zero plot
zplane(qroots(N3(:)),qroots(D3(:)));
title(strt);
zticks([]);
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"%% length(c0)=%d %% Tap coefficients\n",length(c0));
fprintf(fid,"%% sum(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",sum(k0~=0));
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal passband filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Delay pass band weight\n",Wtp);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%g %% Ampl. lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%g %% Ampl. upper stop band weight\n",Wasu);
fclose(fid);

print_polynomial(k3,"k3");
print_polynomial(k3,"k3",strcat(strf,"_k3_coef.m"));
print_polynomial(epsilon3,"epsilon3");
print_polynomial(epsilon3,"epsilon3",strcat(strf,"_epsilon3_coef.m"),"%2d");
print_polynomial(p3,"p3");
print_polynomial(p3,"p3",strcat(strf,"_p3_coef.m"));
print_polynomial(c3,"c3");
print_polynomial(c3,"c3",strcat(strf,"_c3_coef.m"));

print_polynomial(N3,"N3");
print_polynomial(N3,"N3",strcat(strf,"_N3_coef.m"));
print_polynomial(D3,"D3");
print_polynomial(D3,"D3",strcat(strf,"_D3_coef.m"));

eval(sprintf(strcat("save %s.mat dmax rho ftol ctol ", ...
                    " fapl fapu fasl fasu dBap Wap dBas Wasl Wasu ", ...
                    " ftpl ftpu tp tpr Wtp ", ...
                    " k3 epsilon3 p3 c3 N3 D3"),strf));

% Done
toc(script_id);
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
