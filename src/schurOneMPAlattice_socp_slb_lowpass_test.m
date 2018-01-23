% schurOneMPAlattice_socp_slb_lowpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("schurOneMPAlattice_socp_slb_lowpass_test.diary");
unlink("schurOneMPAlattice_socp_slb_lowpass_test.diary.tmp");
diary schurOneMPAlattice_socp_slb_lowpass_test.diary.tmp

tic;

format compact

tol=1e-7
ctol=tol
maxiter=2000
verbose=false

% Initial coefficients found by tarczynski_parallel_allpass_test.m
D1_0 = [   1.0000000000,   0.6972798665,  -0.2975063336,  -0.3126562447, ... 
          -0.1822052424,   0.0540552781,   0.0875338385,  -0.1043232331, ... 
           0.1845967625,   0.0440769201,  -0.1321004303,   0.0451935651 ]';
D2_0 = [   1.0000000000,   0.1561448902,  -0.3135750868,   0.3178486046, ... 
           0.1300071229,   0.0784801583,  -0.0638101281,  -0.1841985576, ... 
           0.2692566953,  -0.0893426643,  -0.1362443194,   0.1339411607, ... 
          -0.0582212263 ]';

% Lattice decomposition of D1_0, D2_0
[A1k0,A1epsilon0,A1p0,~] = tf2schurOneMlattice(flipud(D1_0),D1_0);
[A2k0,A2epsilon0,A2p0,~] = tf2schurOneMlattice(flipud(D2_0),D2_0);

% Low pass filter specification
if 0
  n=400
  difference=false
  m1=11 % Allpass model filter 1 denominator order
  m2=12 % Allpass model filter 2 denominator order
  fap=0.15 % Pass band amplitude response edge
  dBap=3 % Pass band amplitude response ripple
  Wap=1 % Pass band amplitude response weight
  Wat=0 % Transition band amplitude response weight
  fas=0.2 % Stop band amplitude response edge
  dBas=40 % Stop band amplitude response ripple
  Was=1e4 % Stop band amplitude response weight
  ftp=0.175 % Pass band group delay response edge
  td=(m1+m2)/2 % Pass band nominal group delay
  tdr=0.04 % Pass band group delay response ripple
  Wtp=1 % Pass band group delay response weight
else
  n=400
  difference=false
  m1=11 % Allpass model filter 1 denominator order
  m2=12 % Allpass model filter 2 denominator order
  fap=0.125 % Pass band amplitude response edge
  dBap=0.1 % Pass band amplitude response ripple
  Wap=1 % Pass band amplitude response weight
  Wat=0 % Transition band amplitude response weight
  fas=0.25 % Stop band amplitude response edge
  dBas=60 % Stop band amplitude response ripple
  Was=1e2 % Stop band amplitude response weight
  ftp=0.175 % Pass band group delay response edge
  td=(m1+m2)/2 % Pass band nominal group delay
  tdr=td/500 % Pass band group delay response ripple
  Wtp=1 % Pass band group delay response weight
endif

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=[ones(nap,1); zeros(n-nap,1)];
Asqdu=[ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1); zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=td*ones(ntp,1);
Tdu=(td+(tdr/2))*ones(ntp,1);
Tdl=(td-(tdr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Linear constraints
dmax=inf;
rho=127/128
k0=[A1k0(:);A2k0(:)];
k_u=rho*ones(size(k0));
k_l=-k_u;
k_active=find(k0~=0);

% Common strings
strf="schurOneMPAlattice_socp_slb_lowpass_test";

%
% SOCP PCLS
%
[A1k,A2k,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                         A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                         difference, ...
                         k_u,k_l,k_active,dmax, ...
                         wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                         wp,Pd,Pdu,Pdl,Wp,maxiter,tol,ctol,verbose);
if feasible == 0 
  error("A1k,A2k(pcls) infeasible");
endif
% Recalculate A1epsilon, A1p, A2epsilon and A2p
A1d=schurOneMAPlattice2tf(A1k,A1epsilon0,A1p0);
A2d=schurOneMAPlattice2tf(A2k,A2epsilon0,A2p0);
[A1k,A1epsilon,A1p,~]=tf2schurOneMlattice(flipud(A1d(:)),A1d(:));
[A2k,A2epsilon,A2p,~]=tf2schurOneMlattice(flipud(A2d(:)),A2d(:));

% Plot
schurOneMPAlattice_socp_slb_lowpass_plot ...
  (A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference, ...
   fap,dBap,ftp,td,tdr,fas,dBas,strf);

% Amplitude and delay at local peaks
Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AsqS=schurOneMPAlatticeAsq(wAsqS,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
printf("A1,A2:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("A1,A2:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMPAlatticeT(wTS,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
printf("A1,A2:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("A1,A2:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

%
% Save the results
%
fid=fopen("schurOneMPAlattice_socp_slb_lowpass_test.spec","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"m1=%d %% Allpass model filter 1 denominator order\n",m1);
fprintf(fid,"m2=%d %% Allpass model filter 2 denominator order\n",m2);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wat=%d %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%d %% amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"td=%g %% Nominal pass band filter group delay\n",td);
fprintf(fid,"tdr=%g %% Delay pass band peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fclose(fid);

print_polynomial(A1k,"A1k");
print_polynomial(A1k,"A1k",strcat(strf,"_A1k_coef.m"));
print_polynomial(A1epsilon,"A1epsilon");
print_polynomial(A1epsilon,"A1epsilon",strcat(strf,"_A1epsilon_coef.m"),"%2d");
print_polynomial(A1p,"A1p");
print_polynomial(A1p,"A1p",strcat(strf,"_A1p_coef.m"));
print_polynomial(A2k,"A2k");
print_polynomial(A2k,"A2k",strcat(strf,"_A2k_coef.m"));
print_polynomial(A2epsilon,"A2epsilon");
print_polynomial(A2epsilon,"A2epsilon",strcat(strf,"_A2epsilon_coef.m"),"%2d");
print_polynomial(A2p,"A2p");
print_polynomial(A2p,"A2p",strcat(strf,"_A2p_coef.m"));

save schurOneMPAlattice_socp_slb_lowpass_test.mat ...
     rho tol ctol difference n m1 m2 ...
     fap dBap Wap Wat fas dBas Was ftp td tdr Wtp ...
     D1_0 D2_0 A1k A1epsilon A1p A2k A2epsilon A2p

% Done
toc;
diary off
movefile schurOneMPAlattice_socp_slb_lowpass_test.diary.tmp ...
       schurOneMPAlattice_socp_slb_lowpass_test.diary;
