% schurOneMlattice_sqp_slb_bandpass_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMlattice_sqp_slb_bandpass_test.diary");
unlink("schurOneMlattice_sqp_slb_bandpass_test.diary.tmp");
diary schurOneMlattice_sqp_slb_bandpass_test.diary.tmp

script_id=tic;

format compact

tol_mmse=2e-5
tol_pcls=2e-5
maxiter=2000
verbose=false;

% Bandpass R=2 filter specification
fapl=0.1,fapu=0.2,dBap=2,Wap=1
fasl=0.05,fasu=0.25,dBas=36
Wasl_mmse=1e6,Wasu_mmse=1e6,Wasl_pcls=1e6,Wasu_pcls=1e6
ftpl=0.09,ftpu=0.21,tp=16,tpr=tp/200,Wtp_mmse=6,Wtp_pcls=6

% Initial filter (found by trial-and-error for iir_sqp_slb_bandpass_test.m)
U=2,V=0,M=18,Q=10,R=2
x0=[ 0.00005, ...
     1, -1, ...
     0.9*ones(1,6), [1 1 1], (11:16)*pi/20, (7:9)*pi/10, ...
     0.81*ones(1,5), (4:8)*pi/10 ]';
[n0,d0]=x2tf(x0,U,V,M,Q,R);
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(n0,d0);

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
Wa_mmse=[Wasl_mmse*ones(nasl,1); ...
         zeros(napl-nasl-1,1); ...
         Wap*ones(napu-napl+1,1); ...
         zeros(nasu-napu-1,1); ...
         Wasu_mmse*ones(n-nasu+1,1)];
Wa_pcls=[Wasl_pcls*ones(nasl,1); ...
         zeros(napl-nasl-1,1); ...
         Wap*ones(napu-napl+1,1); ...
         zeros(nasu-napu-1,1); ...
         Wasu_pcls*ones(n-nasu+1,1)];

% Group delay constraints
ntpl=floor(n*ftpl/0.5);
ntpu=ceil(n*ftpu/0.5);
wt=(ntpl:ntpu)'*pi/n;
ntp=length(wt);
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt_mmse=Wtp_mmse*ones(ntp,1);
Wt_pcls=Wtp_pcls*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Constraints on the coefficients
dmax=0.05
rho=127/128
k0=k0(:);
c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kc_u=[rho*ones(size(k0));10*ones(size(c0))];
kc_l=-kc_u;
kc_active=[find((k0)~=0);(Nk+(1:Nc))'];

% Common strings
strT=sprintf...
  ("%%s:fapl=%g,fapu=%g,dBap=%g,fasl=%g,fasu=%g,dBas=%g,Wtp=%%g,Was=%%g",
   fapl,fapu,dBap,fasl,fasu,dBas);
strF=sprintf("schurOneMlattice_sqp_slb_bandpass_test_%%s_%%s");

%
% SOCP MMSE pass
%
run_id=tic;
[k1p,c1p,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_sqp_mmse([],k0,epsilon0,p0,c0, ...
                            kc_u,kc_l,kc_active,dmax, ...
                            wa,Asqd,Asqdu,Asqdl,Wa_mmse, ...
                            wt,Td,Tdu,Tdl,Wt_mmse, ...
                            wp,Pd,Pdu,Pdl,Wp, ...
                            maxiter,tol_mmse,verbose);
toc(run_id);
if feasible == 0 
  error("k1p,c1p(mmse) infeasible");
endif
% Recalculate epsilon1, p1 and c1
[n1,d1]=schurOneMlattice2tf(k1p,epsilon0,ones(size(p0)),c1p);
[k1,epsilon1,p1,c1]=tf2schurOneMlattice(n1,d1);
% Plot the MMSE response
strFmmse=sprintf(strF,"mmse","k1c1");
strTmmse=sprintf(strT,"Schur 1-multiplier SQP MMSE",Wtp_mmse,Wasl_mmse);
schurOneMlattice_sqp_slb_bandpass_plot ...
  (k1,epsilon1,p1,c1,ftpl,ftpu,dBap,ftpl,ftpu,tp,5*tpr, ...
   fasl,fasu,dBas,strFmmse,strTmmse);
%
% MMSE amplitude and delay at local peaks
%
Asq=schurOneMlatticeAsq(wa,k1,epsilon1,p1,c1);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=schurOneMlatticeAsq(wAsqS,k1,epsilon1,p1,c1);
printf("d1:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMlatticeT(wt,k1,epsilon1,p1,c1);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMlatticeT(wTS,k1,epsilon1,p1,c1);
printf("k1c1:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k1c1:TS=[ ");printf("%f ",TS');printf(" ] (samples)\n");

%
% SOCP PCLS pass 1
%
run_id=tic;
[k2p,c2p,slb_iter,opt_iter,func_iter,feasible] = ...
schurOneMlattice_slb(@schurOneMlattice_sqp_mmse, ...
                     k1,epsilon1,p1,c1, ...
                     kc_u,kc_l,kc_active,dmax, ...
                     wa,Asqd,Asqdu,Asqdl,Wa_pcls, ...
                     wt,Td,Tdu,Tdl,Wt_pcls, ...
                     wp,Pd,Pdu,Pdl,Wp, ...
                     maxiter,tol_pcls,verbose);
toc(run_id);
if feasible == 0 
  error("k2p,c2p(pcls) infeasible");
endif
% Recalculate epsilon2, p2 and c2
[n2,d2]=schurOneMlattice2tf(k2p,epsilon1,ones(size(p1)),c2p);
[k2,epsilon2,p2,c2]=tf2schurOneMlattice(n2,d2);
% Plot the PCLS response
strFpcls=sprintf(strF,"pcls","k2c2");
strTpcls=sprintf(strT,"Schur 1-multiplier SQP PCLS",Wtp_pcls,Wasl_pcls);
schurOneMlattice_sqp_slb_bandpass_plot ...
  (k2,epsilon2,p2,c2,ftpl,ftpu,dBap,ftpl,ftpu,tp,tpr, ...
   fasl,fasu,dBas,strFpcls,strTpcls);

%
% PCLS amplitude and delay at local peaks
%
Asq=schurOneMlatticeAsq(wa,k2,epsilon2,p2,c2);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=schurOneMlatticeAsq(wAsqS,k2,epsilon2,p2,c2);
printf("k2c2:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k2c2:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMlatticeT(wt,k2,epsilon2,p2,c2);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMlatticeT(wTS,k2,epsilon2,p2,c2);
printf("k2c2:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k2c2:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

if 0
  %
  % SOCP PCLS pass 2. This works
  %
  dBas=36,tpr=0.06,Wtp_pcls=8
  Asqdu=[(10^(-dBas/10))*ones(nasl,1); ...
         ones(nasu-nasl-1,1); ...
         (10^(-dBas/10))*ones(n-nasu+1,1)];
  Asqdl=[zeros(napl-1,1); ...
         (10^(-dBap/10))*ones(napu-napl+1,1); ...
         zeros(n-napu,1)];

  Tdu=(tp+(tpr/2))*ones(ntp,1);
  Tdl=(tp-(tpr/2))*ones(ntp,1);
  Wt_pcls=Wtp_pcls*ones(ntp,1);
  run_id=tic;
  [k3p,c3p,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_slb(@schurOneMlattice_sqp_mmse, ...
                       k2,epsilon2,p2,c2, ...
                       kc_u,kc_l,kc_active,dmax, ...
                       wa,Asqd,Asqdu,Asqdl,Wa_pcls, ...
                       wt,Td,Tdu,Tdl,Wt_pcls, ...
                       wp,Pd,Pdu,Pdl,Wp, ...
                       maxiter,tol_pcls,verbose);
  toc(run_id);
  if feasible == 0 
    error("k3p,c3p(pcls) infeasible");
  endif
  % Recalculate epsilon3, p3 and c3
  [n3,d3]=schurOneMlattice2tf(k3p,epsilon2,ones(size(p2)),c3p);
  [k3,epsilon3,p3,c3]=tf2schurOneMlattice(n3,d3);
  % Plot the PCLS response
  strFpcls=sprintf(strF,"pcls","k3c3");
  strTpcls=sprintf(strT,"Schur 1-multiplier SQP PCLS",Wtp_pcls,Wasl_pcls);
  schurOneMlattice_sqp_slb_bandpass_plot ...
    (k3,epsilon3,p3,c3,ftpl,ftpu,dBap,ftpl,ftpu,tp,tpr, ...
     fasl,fasu,dBas,strFpcls,strTpcls);

  %
  % PCLS amplitude and delay at local peaks
  %
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
endif

%
% Save the results
%
fid=fopen("schurOneMlattice_sqp_slb_bandpass_test.spec","wt");
fprintf(fid,"tol_mmse=%g %% Tolerance on coef. update for MMSE\n",tol_mmse);
fprintf(fid,"tol_pcls=%g %% Tolerance on coef. update for PCLS\n",tol_pcls);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"length(c0)=%d %% Tap coefficients\n",length(c0));
fprintf(fid,"sum(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",sum(k0~=0));
fprintf(fid,"dmax=%f %% Constraint on norm of coefficient SQP step size\n",dmax);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal passband filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp_mmse=%d %% Delay pass band weight(MMSE)\n",Wtp_mmse);
fprintf(fid,"Wtp_pcls=%d %% Delay pass band weight(PCLS)\n",Wtp_pcls);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBas=%d %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl_mmse=%d %% Ampl. lower stop band weight(MMSE)\n",Wasl_mmse);
fprintf(fid,"Wasu_mmse=%d %% Ampl. upper stop band weight(MMSE)\n",Wasu_mmse);
fprintf(fid,"Wasl_pcls=%d %% Ampl. lower stop band weight(PCLS)\n",Wasl_pcls);
fprintf(fid,"Wasu_pcls=%d %% Ampl. upper stop band weight(PCLS)\n",Wasu_pcls);
fclose(fid);
print_polynomial(k2,"k2");
print_polynomial(k2,"k2","schurOneMlattice_sqp_slb_bandpass_test_k2_coef.m");
print_polynomial(epsilon2,"epsilon2");
print_polynomial(epsilon2,"epsilon2",...
                 "schurOneMlattice_sqp_slb_bandpass_test_epsilon2_coef.m","%2d");
print_polynomial(p2,"p2");
print_polynomial(p2,"p2","schurOneMlattice_sqp_slb_bandpass_test_p2_coef.m");
print_polynomial(c2,"c2");
print_polynomial(c2,"c2","schurOneMlattice_sqp_slb_bandpass_test_c2_coef.m");
print_polynomial(n2,"n2");
print_polynomial(n2,"n2","schurOneMlattice_sqp_slb_bandpass_test_n2_coef.m");
print_polynomial(d2,"d2");
print_polynomial(d2,"d2","schurOneMlattice_sqp_slb_bandpass_test_d2_coef.m");
save schurOneMlattice_sqp_slb_bandpass_test.mat fapl fapu fasl fasu ...
     ftpl ftpu dBap Wap dBas Wasl_mmse Wasu_mmse Wasl_pcls Wasu_pcls ...
     tp tpr Wtp_mmse Wtp_pcls dmax rho tol_mmse tol_pcls ...
     x0 n0 d0 k0 epsilon0 p0 c0 k1 epsilon1 p1 c1 k2 epsilon2 p2 c2 n2 d2

% Done
toc(script_id);
diary off
movefile schurOneMlattice_sqp_slb_bandpass_test.diary.tmp ...
         schurOneMlattice_sqp_slb_bandpass_test.diary;
