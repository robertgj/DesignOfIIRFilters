% iir_frm_parallel_allpass_socp_slb_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("iir_frm_parallel_allpass_socp_slb_test.diary");
unlink("iir_frm_parallel_allpass_socp_slb_test.diary.tmp");
diary iir_frm_parallel_allpass_socp_slb_test.diary.tmp

tic;

format compact
maxiter=5000
verbose=true
no_delay=true

%
% Initial filter is based on the filters found by
% tarczynski_frm_parallel_allpass_test.m
%
x0.r = [   1.0000000000,   0.1303406803,   0.6182310943,  -0.3796167625, ... 
           0.0608855417,  -0.0752426093,   0.1106055616,   0.0510279967, ... 
           0.0221771493 ]';
x0.s = [   1.0000000000,  -0.2074482871,   0.4387338838,  -0.4384605488, ... 
           0.1777524182,  -0.0969794295,   0.1314691246,   0.0053424747 ]';
x0.aa = [  0.0085388118,  -0.0005998888,  -0.0487067023,  -0.0627188054, ... 
           0.0042062606,   0.0276319380,  -0.0325876574,  -0.0233700884, ... 
           0.0349931375,  -0.0111883499,   0.0310987798,   0.3567787983, ... 
           0.5451832504,   0.2164952315,  -0.1752367017,  -0.1182707459, ... 
           0.0972830865,   0.0605239910,  -0.0538627841,  -0.0037239065, ... 
           0.0759694186,   0.0552752896,   0.0110415000,   0.0006290532, ... 
           0.0017429215 ]';
x0.ac = [  0.0420884945,   0.0333992597,  -0.1120202670,  -0.1270615954, ... 
           0.1049979880,   0.0805589666,  -0.2027936907,  -0.0675390158, ... 
           0.1876360201,  -0.0303535500,  -0.0732531121,   0.4317221037, ... 
           0.5625432697,   0.1452654499,  -0.1121961282,  -0.1313444595, ... 
          -0.0512433764,   0.1129137944,   0.0784747266,  -0.1141892247, ... 
          -0.0249703687,   0.1498053375,   0.0513384426,  -0.0904944957, ... 
          -0.0587000121 ]';
n=400;
tol=2e-3 % Tolerance on coefficient update
ctol=tol/100 % Tolerance on constraints
mr=length(x0.r)-1 % Allpass model filter order 
ms=length(x0.s)-1 % Allpass model filter order
na=length(x0.aa) % Masking filter FIR length
nc=length(x0.ac) % Complementary masking filter FIR length
Mmodel=9 % Model filter decimation
Dmodel=0 % Desired model filter passband delay
dmask=0 % Nominal masking filter delay
Tnominal=0 % Nominal FRM filter delay
fap=0.3 % Pass band edge
dBap=0.05 % Pass band amplitude ripple
Wap=1 % Pass band weight
tpr=inf % Peak-to-peak pass band delay ripple
Wtp=0 % Pass band delay weight
Wat=100*eps % Small transition band weight enables constraints
fas=0.31125 % Stop band edge
dBas=40 % Stop band attenuation
Was=100 % Stop band amplitude weight
rho=31/32 % Stability constraint on pole radius

% Convert x0 to vector form
[x0k,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x0);

% Constraints on allpass pole radiuses
[rl,ru]=aConstraints(Vr,Qr,rho);
[sl,su]=aConstraints(Vs,Qs,rho);
xl=[rl(:);sl(:);-inf*ones(na+nc,1)];
xu=[ru(:);su(:); inf*ones(na+nc,1)];

%
% Frequency vectors
%
w=(0:(n-1))'*pi/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Amplitude constraints
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
Td=Tnominal*ones(nap,1);
Tdu=Td+((tpr/2)*ones(nap,1));
Tdl=Td-((tpr/2)*ones(nap,1));
Wt=Wtp*ones(nap,1);

% Common strings for output plots
if no_delay
  strT=sprintf("FRM parallel allpass %%s %%s:fap=%g,fas=%g,na=%d,nc=%d",
               fap,fas,na,nc);
else
  strT=sprintf("FRM parallel allpass %%s %%s:Mmodel=%d,Dmodel=%d,fap=%g,\
fas=%g,na=%d,nc=%d", Mmodel,Dmodel,fap,fas,na,nc);
endif
strF=sprintf("iir_frm_parallel_allpass_socp_slb_test_%%s_%%s");

% Plot the initial response
nplot=512;
iir_frm_parallel_allpass_socp_slb_plot(x0,na,nc,Mmodel,Dmodel,dmask, ...
                                       nplot,fap,strT,strF,"initial");

%
% SOCP PCLS 
%
[d2k,slb_iter,opt_iter,func_iter,feasible] = ...
  iir_frm_parallel_allpass_slb(@iir_frm_parallel_allpass_socp_mmse, ...
                               x0k,xu,xl,Vr,Qr,Vs,Qs,na,nc,Mmodel, ...
                               w,Asqd,Asqdu,Asqdl,Wa,Td,Tdu,Tdl,Wt, ...
                               maxiter,tol,ctol,verbose);
if feasible == 0 
  error("d2k(pcls) infeasible");
endif
% Convert d2k to structure form
d2=iir_frm_parallel_allpass_vec_to_struct(d2k,Vr,Qr,Vs,Qs,na,nc);
% Plot the PCLS response
iir_frm_parallel_allpass_socp_slb_plot(d2,na,nc,Mmodel,Dmodel,dmask, ...
                                       nplot,fap,strT,strF,"pcls");

%
% Save the results
%
fid=fopen("iir_frm_parallel_allpass_socp_slb_test.spec","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"mr=%d %% R model filter denominator order\n",length(x0.r)-1);
fprintf(fid,"ms=%d %% S model filter denominator order\n",length(x0.s)-1);
fprintf(fid,"na=%d %% FIR masking filter length (order+1)\n",na);
fprintf(fid,"nc=%d %% FIR complementary masking filter length (order+1)\n",nc);
fprintf(fid,"Mmodel=%d %% Model filter decimation factor\n",Mmodel);
fprintf(fid,"Dmodel=%d %% Model filter nominal pass band group delay \n",Dmodel);
fprintf(fid,"dmask=%d %% FIR masking filter delay\n",dmask);
fprintf(fid,"fap=%g %% Pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band weight\n",Wap);
fprintf(fid,"tpr=%g %% Pass band delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Pass band delay weight\n",Wtp);
fprintf(fid,"fas=%g %% Stop band edge\n",fas);
fprintf(fid,"dBas=%d %% Stop band attenuation ripple\n",dBas);
fprintf(fid,"Was=%d %% Stop band weight\n",Was);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fclose(fid);
print_polynomial(d2.r,"r");
print_polynomial(d2.r,"r","iir_frm_parallel_allpass_socp_slb_test_r_coef.m");
print_polynomial(d2.s,"s");
print_polynomial(d2.s,"s","iir_frm_parallel_allpass_socp_slb_test_s_coef.m");
print_polynomial(d2.aa,"aa");
print_polynomial(d2.aa,"aa","iir_frm_parallel_allpass_socp_slb_test_aa_coef.m");
print_polynomial(d2.ac,"ac");
print_polynomial(d2.ac,"ac","iir_frm_parallel_allpass_socp_slb_test_ac_coef.m");
save iir_frm_parallel_allpass_socp_slb_test.mat ...
     x0 d2 Mmodel Dmodel fap fas dBap Wap tpr Wtp dBas Was rho tol

% Done
toc;
diary off
movefile iir_frm_parallel_allpass_socp_slb_test.diary.tmp  ...
         iir_frm_parallel_allpass_socp_slb_test.diary;
