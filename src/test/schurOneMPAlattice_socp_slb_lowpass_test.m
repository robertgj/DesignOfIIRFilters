% schurOneMPAlattice_socp_slb_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="schurOneMPAlattice_socp_slb_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

tol=1e-7
ctol=tol
maxiter=5000
verbose=false

% Initial coefficients found by tarczynski_parallel_allpass_test.m
tarczynski_parallel_allpass_test_flat_delay_Da0_coef;
tarczynski_parallel_allpass_test_flat_delay_Db0_coef;

% Lattice decomposition of Da0, Db0
[A1k0,A1epsilon0,A1p0,~] = tf2schurOneMlattice(flipud(Da0),Da0);
[A2k0,A2epsilon0,A2p0,~] = tf2schurOneMlattice(flipud(Db0),Db0);

% Low pass filter specification
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
Was=10 % Stop band amplitude response weight
ftp=0.175 % Pass band group delay response edge
td=(m1+m2)/2 % Pass band nominal group delay
tdr=0.08 % Pass band group delay response ripple
Wtp=2 % Pass band group delay response weight

 
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

% dAsqdw constraints
wd=[];
Dd=[];
Ddu=[];
Ddl=[];
Wd=[];

% Linear constraints
dmax=inf;
rho=127/128
k0=[A1k0(:);A2k0(:)];
k_u=rho*ones(size(k0));
k_l=-k_u;
k_active=find(k0~=0);

%
% SOCP PCLS
%
[A1k,A2k,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                         A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                         difference, ...
                         k_u,k_l,k_active,dmax, ...
                         wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                         wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
                         maxiter,tol,ctol,verbose);
if feasible == 0 
  error("A1k,A2k(pcls) infeasible");
endif

% Recalculate A1epsilon, A1p, A2epsilon and A2p
[A1epsilon,A1p]=schurOneMscale(A1k);
A1k=A1k(:)';A1epsilon=A1epsilon(:)';A1p=A1p(:)';
[A2epsilon,A2p]=schurOneMscale(A2k);
A2k=A2k(:)';A2epsilon=A2epsilon(:)';A2p=A2p(:)';

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

% Check transfer function
Da1=schurOneMAPlattice2tf(A1k,A1epsilon,A1p);
Da1=Da1(:);
Db1=schurOneMAPlattice2tf(A2k,A2epsilon,A2p);
Db1=Db1(:);
N1=(conv(flipud(Da1),Db1)+conv(flipud(Db1),Da1))/2;
D1=conv(Da1,Db1);
HH=freqz(N1,D1,wa);
if max(abs((abs(HH).^2)-Asq)) > 100*eps
  error("max(abs((abs(HH).^2)-Asq))(%g*eps) > 100*eps",
        max(abs((abs(HH).^2)-Asq))/eps);
endif

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"m1=%d %% Allpass filter 1 denominator order\n",m1);
fprintf(fid,"m2=%d %% Allpass filter 2 denominator order\n",m2);
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

print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));
print_polynomial(Db1,"Db1");
print_polynomial(Db1,"Db1",strcat(strf,"_Db1_coef.m"));
print_polynomial(N1,"N1");
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

eval(sprintf("save %s.mat ... \n\
     rho tol ctol difference n m1 m2 ...\n\
     fap dBap Wap Wat fas dBas Was ftp td tdr Wtp ...\n\
     Da0 Db0 A1k A1epsilon A1p A2k A2epsilon A2p Da1 Db1 N1 D1",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
