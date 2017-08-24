% schurOneMlattice_socp_slb_hilbert_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMlattice_socp_slb_hilbert_test.diary");
unlink("schurOneMlattice_socp_slb_hilbert_test.diary.tmp");
diary schurOneMlattice_socp_slb_hilbert_test.diary.tmp

tic;

format compact;

tol=1e-6
maxiter=2000
verbose=false

% Hilbert filter specification
ft=0.05 % Transition bandwidth [0 ft]
tp=5.5

% Frequency points
n=256;
w=pi*(0:(n-1))'/n;

% Initial filter from tarczynski_hilbert_test.m
n0 = [  -0.0579060701,  -0.0707488132,  -0.0092404640,  -0.0274579731, ...
        -0.1104130391,  -0.4893854880,   0.8949334384,   1.0530071415, ...
        -0.8682713761,  -0.4995254712,   0.1864234803,   0.0312522437, ...
         0.0000000000 ]';
d0 = [   1.0000000000,   0.0000000000,  -1.4115940676,   0.0000000000, ...
         0.4595341482,   0.0000000000,  -0.0092849195,   0.0000000000, ...
         0.0011168533,   0.0000000000,   0.0014520227,   0.0000000000, ...
        -0.0018389921 ]';
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(n0,d0);
Asq0=schurOneMlatticeAsq(w,k0,epsilon0,p0,c0);
T0=schurOneMlatticeT(w,k0,epsilon0,p0,c0);
P0=schurOneMlatticeP(w,k0,epsilon0,p0,c0);

% Amplitude constraints
wa=w;
Asqd=ones(n,1);
dBap=0.5
nt=ceil(ft*n/0.5);
dBapmask=dBap*[2*ones(nt,1);ones(nt,1);ones(n-(2*nt),1)/2];
Asqdu=10.^(dBapmask/10);
Asqdl=10.^(-dBapmask/10);
Wat=10*tol
Wap_mmse=1
Wa_mmse=Wap_mmse*[Wat*ones(nt,1);ones(n-nt,1)];
Wap_pcls=1
Wa_pcls=Wap_pcls*[Wat*ones(nt,1);ones(n-nt,1)];

% Group delay constraints
wt=w;
Td=tp*ones(n,1);
tpr=0.2;
ntt=floor(nt*1.5);
trmask=[100*tpr*ones(ntt,1);0.5*tpr*ones(n-ntt,1)];
Tdu=Td+trmask;
Tdl=Td-trmask;
Wtt=0
Wtp=0.1
Wt=[Wtt*ones(ntt,1);Wtp*ones(n-ntt,1)];

% Phase constraints
wp=w;
Pd=-(wp*tp)-(pi/2);
pr=0.01
prmask=(pi/2)*[2*ones(nt,1);1.5*pr*ones(nt,1);0.5*pr*ones(n-(2*nt),1)];
Pdu=Pd+prmask;
Pdl=Pd-prmask;
Wpt=10*tol
Wpp=100
Wp=[Wpt*ones(nt,1);Wpp*ones(n-nt,1)];

% Constraints on the coefficients
dmax=inf;
rho=1-tol;
k0=k0(:);
c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kc_u=[rho*ones(size(k0));10*ones(size(c0))];
kc_l=-kc_u;
kc_active=[find((k0)~=0);(Nk+(1:Nc))'];

% Initialise strings
strF=sprintf("schurOneMlattice_socp_slb_hilbert_test_%%s");
strM=sprintf("Hilbert filter %%s:ft=%g,tp=%g,Wap=%%g,Wpp=%g",ft,tp,Wpp);
strP=sprintf("Hilbert filter %%s:ft=%g,dBap=%g,tp=%g,pr=%g,Wap=%%g,Wpp=%g",
             ft,dBap,tp,pr,Wpp);

%
% SOCP MMSE
%
tic;
[k1p,c1p,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_socp_mmse([],k0,epsilon0,p0,c0, ...
                             kc_u,kc_l,kc_active,dmax, ...
                             wa,Asqd,Asqdu,Asqdl,Wa_mmse, ...
                             wt,Td,Tdu,Tdl,Wt, ...
                             wp,Pd,Pdu,Pdl,Wp, ...
                             maxiter,tol,verbose);
toc;
if feasible == 0 
  error("k1p,c1p(mmse) infeasible");
endif
% Recalculate epsilon1, p1 and c1
[n1,d1]=schurOneMlattice2tf(k1p,epsilon0,ones(size(p0)),c1p);
[k1,epsilon1,p1,c1]=tf2schurOneMlattice(n1,d1);
schurOneMlattice_sqp_slb_hilbert_plot ...
  (k1,epsilon1,p1,c1,wa,wt,wp, ...
   2*dBap,tp,0.2,pr,Asqdu,Asqdl,Tdu,Tdl,Pdu,Pdl, ...
   sprintf(strF,"mmse_k1c1"),sprintf(strM,"MMSE",Wap_mmse));

%
% SOCP PCLS
%
tic;
[k2p,c2p,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_slb(@schurOneMlattice_socp_mmse, ...
                       k1,epsilon1,p1,c1, ...
                       kc_u,kc_l,kc_active,dmax, ...
                       wa,Asqd,Asqdu,Asqdl,Wa_pcls, ...
                       wt,Td,Tdu,Tdl,Wt, ...
                       wp,Pd,Pdu,Pdl,Wp, ...
                       maxiter,tol,verbose);
toc;
if feasible == 0 
  error("k2p,c2p(pcls) infeasible");
endif
% Recalculate epsilon2, p2 and c2
[n2,d2]=schurOneMlattice2tf(k2p,epsilon1,ones(size(p1)),c2p);
[k2,epsilon2,p2,c2]=tf2schurOneMlattice(n2,d2);
schurOneMlattice_sqp_slb_hilbert_plot ...
  (k2,epsilon2,p2,c2,wa,wt,wp, ...
   dBap,tp,0.2,pr,Asqdu,Asqdl,Tdu,Tdl,Pdu,Pdl, ...
   sprintf(strF,"pcls_k2c2"),sprintf(strP,"PCLS",Wap_pcls));

%
% Save the results
%
fid=fopen("schurOneMlattice_socp_slb_hilbert_test.spec","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"rho=%f %% Constraint on lattice coefficient magnitudes\n",rho);
fprintf(fid,"ft=%g %% Transition band width [0,ft]\n",ft);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wat=%d %% Amplitude transition band weight\n",Wat);
fprintf(fid,"Wap_mmse=%g %% Amplitude pass band weight for MMSE\n",Wap_mmse);
fprintf(fid,"Wap_pcls=%g %% Amplitude pass band weight for PCLS\n",Wap_pcls);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"pr=%g pi/2 %% Phase pass band peak-to-peak ripple\n",pr);
fprintf(fid,"Wpt=%d %% Phase transition band weight\n",Wpt);
fprintf(fid,"Wpp=%d %% Phase pass band weight\n",Wpp);
fclose(fid);
print_polynomial(k2,"k2");
print_polynomial(k2,"k2","schurOneMlattice_socp_slb_hilbert_test_k2_coef.m");
print_polynomial(epsilon2,"epsilon2");
print_polynomial(epsilon2,"epsilon2", ...
                 "schurOneMlattice_socp_slb_hilbert_test_epsilon2_coef.m","%2d");
print_polynomial(p2,"p2");
print_polynomial(p2,"p2","schurOneMlattice_socp_slb_hilbert_test_p2_coef.m");
print_polynomial(c2,"c2");
print_polynomial(c2,"c2","schurOneMlattice_socp_slb_hilbert_test_c2_coef.m");
print_polynomial(n2,"n2");
print_polynomial(n2,"n2","schurOneMlattice_socp_slb_hilbert_test_n2_coef.m");
print_polynomial(d2,"d2");
print_polynomial(d2,"d2","schurOneMlattice_socp_slb_hilbert_test_d2_coef.m");

%
% Save results
%
save schurOneMlattice_socp_slb_hilbert_test.mat ...
     tol n w n0 d0 k0 epsilon0 p0 c0 rho Asqd dBap tp Pd pr ...
     k1 epsilon1 p1 c1 k2 epsilon2 p2 c2 n2 d2

% Done
diary off
movefile schurOneMlattice_socp_slb_hilbert_test.diary.tmp ...
       schurOneMlattice_socp_slb_hilbert_test.diary;
