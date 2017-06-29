% schurNSlattice_sqp_slb_lowpass_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurNSlattice_sqp_slb_lowpass_test.diary");
unlink("schurNSlattice_sqp_slb_lowpass_test.diary.tmp");
diary schurNSlattice_sqp_slb_lowpass_test.diary.tmp


format compact

maxiter=5000
verbose=false

% Deczky3 lowpass filter specification
tol_mmse=1e-3
tol_pcls=1e-5
n=400
norder=10
fap=0.15,dBap=0.2,Wap=1
fas=0.3,dBas=46,Was_mmse=1e4,Was_pcls=1e6
ftp=0.25,tp=9.5,tpr=0.1,Wtp_mmse=0.01,Wtp_pcls=0.1
% Initial filter from deczky3_sqp_test.m
U=0;V=0;Q=6;M=10;R=1;
z0=[exp(j*2*pi*0.41),exp(j*2*pi*0.305),1.5*exp(j*2*pi*0.2), ...
   1.5*exp(j*2*pi*0.14),1.5*exp(j*2*pi*0.08)];
p0=[0.7*exp(j*2*pi*0.16),0.6*exp(j*2*pi*0.12),0.5*exp(j*2*pi*0.05)];
K0=0.0096312406;
x0=[K0,abs(z0),angle(z0),abs(p0),angle(p0)]';
[n0,d0]=x2tf(x0,U,V,M,Q,R);
d0=[d0(:);zeros(length(n0)-length(d0),1)];
[s10_0,s11_0,s20_0,s00_0,s02_0,s22_0]=tf2schurNSlattice(n0,d0);

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=[ones(nap,1); zeros(n-nap,1)];
Asqdu=[ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1); zeros(n-nap,1)];
Wa_mmse=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was_mmse*ones(n-nas+1,1)];
Wa_pcls=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was_pcls*ones(n-nas+1,1)];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt_mmse=Wtp_mmse*ones(ntp,1);
Wt_pcls=Wtp_pcls*ones(ntp,1);

% Common strings
strT=sprintf("Schur normalised-scaled lattice lowpass filter SQP %%s response : \
fap=%g,dBap=%g,fas=%g,dBas=%g",fap,dBap,fas,dBas);
strF=sprintf("schurNSlattice_sqp_slb_lowpass_test_%%s_%%s");

% Constraints on the coefficients
dmax=0.05
rho=1-tol_pcls
Ns=length(s10_0);
sxx_u=reshape(kron([10*ones(2,1);rho*ones(4,1)],ones(1,Ns)),1,6*Ns);
sxx_l=-sxx_u;

% Find the active coefficients. Note the bitwise & operation!
[Esq,gradEsq]=...
  schurNSlatticeEsq(s10_0,s11_0,s20_0,s00_0,s02_0,s22_0,...
                    wa,Asqd,Wa_mmse,wt,Td,Wt_mmse);
sxx_0=reshape([s10_0;s11_0;s20_0;s02_0;s00_0;s22_0],1,6*Ns);
sxx_active=intersect(find(gradEsq),find((sxx_0~=0)&(sxx_0~=1)));

% Enforce s02=-s20,s22=s00?
sxx_symmetric=false;

%
% SQP MMSE
%
tic;
[s10_1,s11_1,s20_1,s00_1,s02_1,s22_1,opt_iter,func_iter,feasible] = ...
  schurNSlattice_sqp_mmse([],s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                          sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
                          wa,Asqd,Asqdu,Asqdl,Wa_mmse, ...
                          wt,Td,Tdu,Tdl,Wt_mmse, ...
                          maxiter,tol_mmse,verbose);
toc;
if feasible == 0 
  error("s10_1,s11_1,s20_1,s00_1,s02_1,s22_1(mmse) infeasible");
endif
schurNSlattice_sqp_slb_lowpass_plot ...
  (s10_1,s11_1,s20_1,s00_1,s02_1,s22_1,fap,dBap,ftp,tp,tpr*2,fas,dBas, ...
   sprintf(strF,"mmse","sxx_1"),sprintf(strT,"MMSE"));

%
% SQP PCLS
%
tic;
[s10_2,s11_2,s20_2,s00_2,s02_2,s22_2,slb_iter,opt_iter,func_iter,feasible] = ...
  schurNSlattice_slb(@schurNSlattice_sqp_mmse, ...
                     s10_1,s11_1,s20_1,s00_1,s02_1,s22_1, ...
                     sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
                     wa,Asqd,Asqdu,Asqdl,Wa_pcls, ...
                     wt,Td,Tdu,Tdl,Wt_pcls, ...
                     maxiter,tol_pcls,verbose);
toc;
if feasible == 0 
  error("s10_2,s11_2,s20_2,s00_2,s02_2,s22_2(pcls) infeasible");
endif
schurNSlattice_sqp_slb_lowpass_plot ...
  (s10_2,s11_2,s20_2,s00_2,s02_2,s22_2,fap,dBap,ftp,tp,tpr,fas,dBas, ...
   sprintf(strF,"pcls","sxx_2"),sprintf(strT,"PCLS"));

%
% Final amplitude and delay at local peaks
%
Asq=schurNSlatticeAsq(wa,s10_2,s11_2,s20_2,s00_2,s02_2,s22_2);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa(nap);wa(nas)]);
AsqS=schurNSlatticeAsq(wAsqS,s10_2,s11_2,s20_2,s00_2,s02_2,s22_2);
printf("d1:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurNSlatticeT(wt,s10_2,s11_2,s20_2,s00_2,s02_2,s22_2);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt(ntp)]);
TS=schurNSlatticeT(wTS,s10_2,s11_2,s20_2,s00_2,s02_2,s22_2);
printf("d1:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:TS=[ ");printf("%f ",TS');printf(" ] (samples)\n");

%
% Find state variance
%
[A,B,C,D]=schurNSlattice2Abcd(s10_2,s11_2,s20_2,s00_2,s02_2,s22_2);
[K,W]=KW(A,B,C,D);
print_polynomial(diag(K),"diag(K)",...
                 "schurNSlattice_sqp_slb_lowpass_test.diagK.val","%10.4f");

%
% Save the results
%
fid=fopen("schurNSlattice_sqp_slb_lowpass_test.spec","wt");
fprintf(fid,"tol_mmse=%g %% Tolerance on coefficient update vector for MMSE\n",
        tol_mmse);
fprintf(fid,"tol_pcls=%g %% Tolerance on coefficient update vector for PCLS\n",
        tol_pcls);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"sxx_symmetric=%1d %% Enforce s02=-s20 and s22=s00\n",sxx_symmetric);
fprintf(fid,"dmax=%f %% Constraint on norm of coefficient SQP step size\n",dmax);
fprintf(fid,"rho=%f %% Constraint on lattice coefficient magnitudes\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp_mmse=%d %% Delay pass band weight for MMSE\n",Wtp_mmse);
fprintf(fid,"Wtp_pcls=%d %% Delay pass band weight for PCLS\n",Wtp_pcls);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%d %% amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was_mmse=%g %% Amplitude stop band weight for MMSE\n",Was_mmse);
fprintf(fid,"Was_pcls=%g %% Amplitude stop band weight for PCLS\n",Was_pcls);
fclose(fid);
print_polynomial(s10_2,"s10_2");
print_polynomial(s10_2,"s10_2", ...
                 "schurNSlattice_sqp_slb_lowpass_test_s10_2_coef.m");
print_polynomial(s11_2,"s11_2");
print_polynomial(s11_2,"s11_2", ...
                 "schurNSlattice_sqp_slb_lowpass_test_s11_2_coef.m");
print_polynomial(s20_2,"s20_2");
print_polynomial(s20_2,"s20_2", ...
                 "schurNSlattice_sqp_slb_lowpass_test_s20_2_coef.m");
print_polynomial(s00_2,"s00_2");
print_polynomial(s00_2,"s00_2", ...
                 "schurNSlattice_sqp_slb_lowpass_test_s00_2_coef.m");
print_polynomial(s02_2,"s02_2");
print_polynomial(s02_2,"s02_2", ...
                 "schurNSlattice_sqp_slb_lowpass_test_s02_2_coef.m");
print_polynomial(s22_2,"s22_2");
print_polynomial(s22_2,"s22_2", ...
                 "schurNSlattice_sqp_slb_lowpass_test_s22_2_coef.m");
save schurNSlattice_sqp_slb_lowpass_test.mat x0 n0 d0 ...
     fap dBap Wap ftp tp tpr Wtp_mmse Wtp_pcls fas dBas Was_mmse Was_pcls ...
     dmax rho tol_mmse tol_pcls ...
     s10_0 s11_0 s20_0 s00_0 s02_0 s22_0 ...
     s10_1 s11_1 s20_1 s00_1 s02_1 s22_1 ...
     s10_2 s11_2 s20_2 s00_2 s02_2 s22_2

% Done
diary off
movefile schurNSlattice_sqp_slb_lowpass_test.diary.tmp ...
       schurNSlattice_sqp_slb_lowpass_test.diary;
