% schurOneMlattice_sqp_slb_hilbert_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

unlink("schurOneMlattice_sqp_slb_hilbert_test.diary");
unlink("schurOneMlattice_sqp_slb_hilbert_test.diary.tmp");
diary schurOneMlattice_sqp_slb_hilbert_test.diary.tmp

tic;


tol=1e-4
ctol=tol
maxiter=5000
verbose=false

% Hilbert filter specification
ft1=0.05 % First transition region [0 ft1]
ft2=0.075 % Second transition region [ft1 ft2]
tp=5.5

% Frequency points
n=400;
w=pi*(0:(n-1))'/n;

% Initial filter from tarczynski_hilbert_test.m
R=2;
n0 = [ -0.0579063991,  -0.0707490525,  -0.0092677810,  -0.0274919718, ... 
       -0.1104277026,  -0.4894105730,   0.8948745630,   1.0527570805, ... 
       -0.8678508170,  -0.4990735123,   0.1861313381,   0.0311088704, ...
        0.0000000000 ]';
d0 = [  1.0000000000,   0.0000000000,  -1.4110993644,   0.0000000000, ...
        0.4589810713,   0.0000000000,  -0.0092017575,   0.0000000000, ... 
        0.0011255865,   0.0000000000,   0.0014507700,   0.0000000000, ...
       -0.0018420748 ]';
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(n0,d0);
Asq0=schurOneMlatticeAsq(w,k0,epsilon0,p0,c0);
T0=schurOneMlatticeT(w,k0,epsilon0,p0,c0);
P0=schurOneMlatticeP(w,k0,epsilon0,p0,c0);

% Amplitude constraints
wa=w;
Asqd=ones(n,1);
dBap=0.1;
nt1=ceil(ft1*n/0.5);
nt2=ceil((ft2-ft1)*n/0.5);
dBapmask=dBap*[2*ones(nt1,1);ones(nt2,1);0.5*ones(n-nt1-nt2,1)];
Asqdu=10.^(dBapmask/10);
Asqdl=10.^(-dBapmask/10);
Wat=500*tol;
Wap=1;
Wa=Wap*[Wat*ones(nt1,1);ones(n-nt1,1)];

% Group delay constraints
wt=w;
Td=tp*ones(n,1);
tpr=0.5;
tprmask=tpr*[1e6*ones(nt1,1);2*ones(nt2,1);0.5*ones(n-nt1-nt2,1)];
Tdu=tp+tprmask;
Tdl=tp-tprmask;
Wtp=5e-3;
Wt=Wtp*[zeros(nt1,1);ones(n-nt1,1)];

% Phase constraints
wp=w;
Pd=-(wp*tp)-(pi/2);
pr=0.01;
prmask=pi*pr*[1e6*ones(nt1,1);ones(nt2,1);0.5*ones(n-nt1-nt2,1)];
Pdu=Pd+prmask;
Pdl=Pd-prmask;
Wpp=1;
Wp=Wpp*[zeros(nt1,1);ones(n-nt1,1)];

% Constraints on the coefficients
dmax=0.1;
rho=1-tol;
k0=k0(:);
c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kc_u=[rho*ones(size(k0));10*ones(size(c0))];
kc_l=-kc_u;
kc_active=[find((k0)~=0);(Nk+(1:Nc))'];

% Initialise strings
strf="schurOneMlattice_sqp_slb_hilbert_test";
strM=sprintf("Hilbert filter %%s:\
R=%d,ft1=%g,ft2=%g,tp=%g,Wap=%g,Wtp=%g,Wpp=%g",R,ft1,ft2,tp,Wap,Wtp,Wpp);
strP=sprintf("Hilbert filter %%s:\
R=%d,ft1=%g,ft2=%g,dBap=%g,tp=%g,tpr=%g,pr=%g,Wap=%g,Wtp=%g,Wpp=%g",
             R,ft1,ft2,dBap,tp,tpr,pr,Wap,Wtp,Wpp);

%
% SQP MMSE
%
tic;
[k1p,c1p,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_sqp_mmse([],k0,epsilon0,p0,c0, ...
                             kc_u,kc_l,kc_active,dmax, ...
                             wa,Asqd,Asqdu,Asqdl,Wa, ...
                             wt,Td,Tdu,Tdl,Wt, ...
                             wp,Pd,Pdu,Pdl,Wp, ...
                             maxiter,tol,verbose);
toc;
if feasible == 0 
  error("k1p,c1p(mmse) infeasible");
endif
% Recalculate epsilon1, p1 and c1
[n1,d1]=schurOneMlattice2tf(k1p,epsilon0,p0,c1p);
[k1,epsilon1,p1,c1]=tf2schurOneMlattice(n1,d1);
schurOneMlattice_sqp_slb_hilbert_plot ...
  (k1,epsilon1,p1,c1,wa,wt,wp, ...
   2*dBap,tp,2*tpr,2*pr,Asqdu,Asqdl,Tdu,Tdl,Pdu,Pdl,...
   strcat(strf,"_mmse_k1c1"),sprintf(strM,"MMSE"));

%
% SQP PCLS
%
tic;
[k2p,c2p,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_slb(@schurOneMlattice_sqp_mmse, ...
                       k1,epsilon1,p1,c1, ...
                       kc_u,kc_l,kc_active,dmax, ...
                       wa,Asqd,Asqdu,Asqdl,Wa, ...
                       wt,Td,Tdu,Tdl,Wt, ...
                       wp,Pd,Pdu,Pdl,Wp, ...
                       maxiter,tol,ctol,verbose);
toc;
if feasible == 0 
  error("k2p,c2p(pcls) infeasible");
endif
% Recalculate epsilon2, p2 and c2
[n2,d2]=schurOneMlattice2tf(k2p,epsilon1,p1,c2p);
[k2,epsilon2,p2,c2]=tf2schurOneMlattice(n2,d2);
schurOneMlattice_sqp_slb_hilbert_plot ...
  (k2,epsilon2,p2,c2,wa,wt,wp,1.25*dBap,tp,2*tpr,pr, ...
   Asqdu,Asqdl,Tdu,Tdl,Pdu,Pdl, ...
   strcat(strf,"_pcls_k2c2"),sprintf(strP,"PCLS"));

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"dmax=%f %% Constraint on norm of coefficient SQP step size\n",dmax);
fprintf(fid,"rho=%f %% Constraint on lattice coefficient magnitudes\n",rho);
fprintf(fid,"ft1=%g %% First transition band [0,ft1]\n",ft1);
fprintf(fid,"ft2=%g %% Second transition band [ft1,ft2]\n",ft2);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wat=%d %% Amplitude transition band weight\n",Wat);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band filter group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Pass band group delay weight\n",Wtp);
fprintf(fid,"pr=%g pi/2 %% Pass band peak-to-peak phase ripple\n",pr);
fprintf(fid,"Wpp=%d %% Pass band phase weight\n",Wpp);
fclose(fid);
print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(epsilon2,"epsilon2");
print_polynomial(epsilon2,"epsilon2",strcat(strf,"_epsilon2_coef.m"),"%2d");
print_polynomial(p2,"p2");
print_polynomial(p2,"p2",strcat(strf,"_p2_coef.m"));
print_polynomial(c2,"c2");
print_polynomial(c2,"c2",strcat(strf,"_c2_coef.m"));
print_polynomial(n2,"n2");
print_polynomial(n2,"n2",strcat(strf,"_n2_coef.m"));
print_polynomial(d2,"d2");
print_polynomial(d2,"d2",strcat(strf,"_d2_coef.m"));

%
% Save results
%
save schurOneMlattice_sqp_slb_hilbert_test.mat ...
     tol ctol n w n0 d0 k0 epsilon0 p0 c0 dmax rho ...
     dBap Wat Wap tp tpr Wtp pr Wpp ...
     k1 epsilon1 p1 c1 k2 epsilon2 p2 c2 n2 d2

% Done
diary off
movefile schurOneMlattice_sqp_slb_hilbert_test.diary.tmp ...
         schurOneMlattice_sqp_slb_hilbert_test.diary;
