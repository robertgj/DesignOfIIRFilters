% schurOneMlattice_socp_slb_bandpass_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMlattice_socp_slb_bandpass_test.diary");
unlink("schurOneMlattice_socp_slb_bandpass_test.diary.tmp");
diary schurOneMlattice_socp_slb_bandpass_test.diary.tmp

script_id=tic;

format compact

tol_mmse=2e-5
tol_pcls=1e-5
maxiter=2000
verbose=false

% Bandpass R=2 filter specification
fapl=0.1,fapu=0.2,dBap=2,Wap=1
fasl=0.05,fasu=0.25,dBas=36
Wasl_mmse=5e5,Wasu_mmse=5e5,Wasl_pcls=5e5,Wasu_pcls=5e5
ftpl=0.09,ftpu=0.21,tp=16,tpr=tp/400,Wtp_mmse=5,Wtp_pcls=5

% Initial filter (found by schurOneMlattice_sqp_slb_bandpass_test.m)
k2 = [   0.0000000000,   0.6700649121,   0.0000000000,   0.5095927841, ... 
         0.0000000000,   0.3530950698,   0.0000000000,   0.4226101122, ... 
         0.0000000000,   0.2998161684,   0.0000000000,   0.2506360582, ... 
         0.0000000000,   0.1500588956,   0.0000000000,   0.0997749565, ... 
         0.0000000000,   0.0337774737,   0.0000000000,   0.0132997738 ];
epsilon2 = [  0,   1,  0,  -1, ... 
              0,   1,  0,  -1, ... 
              0,   1,  0,  -1, ... 
              0,  -1,  0,   1, ... 
              0,  -1,  0,  -1 ];
p2 = [   1.1295664714,   1.1295664714,   0.5020643322,   0.5020643322, ... 
         0.8808680317,   0.8808680317,   0.6090696002,   0.6090696002, ... 
         0.9560382815,   0.9560382815,   0.7016820295,   0.7016820295, ... 
         0.9064825147,   0.9064825147,   1.0544477287,   1.0544477287, ... 
         0.9540006881,   0.9540006881,   0.9867875035,   0.9867875035 ];
c2 = [   0.0730774319,  -0.0057147055,  -0.2811046156,  -0.4868041665, ... 
        -0.1756278864,   0.1023744226,   0.3828984087,   0.3093469544, ... 
         0.0262694549,  -0.0786586977,  -0.0820574825,  -0.0143086345, ... 
        -0.0074868593,  -0.0325448194,  -0.0255597241,   0.0035756026, ... 
         0.0243271945,   0.0170796074,   0.0023781365,  -0.0003723380, ... 
         0.0042017367 ];

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
dmax=inf;
rho=127/128
k2=k2(:);
c2=c2(:);
Nk=length(k2);
Nc=length(c2);
kc_u=[rho*ones(size(k2));10*ones(size(c2))];
kc_l=-kc_u;
kc_active=[find((k2)~=0);(Nk+(1:Nc))'];

% Common strings
strT=sprintf...
  ("%%s:fapl=%g,fapu=%g,dBap=%g,fasl=%g,fasu=%g,dBas=%g,Wtp=%%g,Was=%%g",
   fapl,fapu,dBap,fasl,fasu,dBas);
strF=sprintf("schurOneMlattice_socp_slb_bandpass_test_%%s_%%s");

%
% SOCP PCLS pass
%
run_id=tic;
[k3p,c3p,slb_iter,opt_iter,func_iter,feasible] = ...
schurOneMlattice_slb(@schurOneMlattice_socp_mmse, ...
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
[n3,d3]=schurOneMlattice2tf(k3p,epsilon2,p2,c3p);
[k3,epsilon3,p3,c3]=tf2schurOneMlattice(n3,d3);
% Plot the PCLS response
strFpcls=sprintf(strF,"pcls","k3c3");
strTpcls=sprintf(strT,"Schur 1-multiplier SOCP PCLS",Wtp_pcls,Wasl_pcls);
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
AsqS=schurOneMlatticeAsq(wAsqS,k3,epsilon2,p3,c3);
printf("k3c3:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k3c3:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMlatticeT(wt,k3,epsilon3,p3,c3);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMlatticeT(wTS,k3,epsilon3,p3,c3);
printf("k3c3:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k3c3:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

%
% Save the results
%
fid=fopen("schurOneMlattice_socp_slb_bandpass_test.spec","wt");
fprintf(fid,"tol_mmse=%g %% Tolerance on coef. update for MMSE\n",tol_mmse);
fprintf(fid,"tol_pcls=%g %% Tolerance on coef. update for PCLS\n",tol_pcls);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"length(c2)=%d %% Tap coefficients\n",length(c2));
fprintf(fid,"sum(k2~=0)=%d %% Num. non-zero all-pass coef.s\n",sum(k2~=0));
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
print_polynomial(k3,"k3");
print_polynomial(k3,"k3","schurOneMlattice_socp_slb_bandpass_test_k3_coef.m");
print_polynomial(epsilon3,"epsilon3");
print_polynomial(epsilon3,"epsilon3",...
  "schurOneMlattice_socp_slb_bandpass_test_epsilon3_coef.m","%2d");
print_polynomial(p3,"p3");
print_polynomial(p3,"p3","schurOneMlattice_socp_slb_bandpass_test_p3_coef.m");
print_polynomial(c3,"c3");
print_polynomial(c3,"c3","schurOneMlattice_socp_slb_bandpass_test_c3_coef.m");
print_polynomial(n3,"n3");
print_polynomial(n3,"n3","schurOneMlattice_socp_slb_bandpass_test_n3_coef.m");
print_polynomial(d3,"d3");
print_polynomial(d3,"d3","schurOneMlattice_socp_slb_bandpass_test_d3_coef.m");
save schurOneMlattice_socp_slb_bandpass_test.mat fapl fapu fasl fasu ...
     ftpl ftpu dBap Wap dBas Wasl_mmse Wasu_mmse Wasl_pcls Wasu_pcls ...
     tp tpr Wtp_mmse Wtp_pcls dmax rho tol_mmse tol_pcls ...
     k2 epsilon2 p2 c2 k3 epsilon3 p3 c3 n3 d3

% Done
toc(script_id);
diary off
movefile schurOneMlattice_socp_slb_bandpass_test.diary.tmp ...
       schurOneMlattice_socp_slb_bandpass_test.diary;
