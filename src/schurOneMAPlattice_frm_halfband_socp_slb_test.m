% schurOneMAPlattice_frm_halfband_socp_slb_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMAPlattice_frm_halfband_socp_slb_test.diary");
unlink("schurOneMAPlattice_frm_halfband_socp_slb_test.diary.tmp");
diary schurOneMAPlattice_frm_halfband_socp_slb_test.diary.tmp

tic;

format compact

%
% Initial filter is found by tarczynski_frm_halfband_test.m
%

%
% Filter specification
%
n=800;
tol=1e-5
maxiter=2000
verbose=false

if 1
  r0 = [   1.0000000000,   0.4654027371,  -0.0749201995,   0.0137121216, ... 
           0.0035706175,  -0.0098219303   ]';
  aa0 = [ -0.0019232288,   0.0038703625,   0.0038937068,  -0.0055310972, ... 
          -0.0073554558,   0.0065538587,   0.0124707197,   0.0002190941, ... 
          -0.0274067156,  -0.0109227368,   0.0373112692,   0.0338245953, ... 
          -0.0500281266,  -0.0817426036,   0.0547645647,   0.3116242327, ... 
           0.4439780707,   0.3116242327,   0.0547645647,  -0.0817426036, ... 
          -0.0500281266,   0.0338245953,   0.0373112692,  -0.0109227368, ... 
          -0.0274067156,   0.0002190941,   0.0124707197,   0.0065538587, ... 
          -0.0073554558,  -0.0055310972,   0.0038937068,   0.0038703625, ... 
          -0.0019232288  ]';
  Mmodel=7 % Model filter FRM decimation
  Dmodel=9 % Desired model filter passband delay
  dBap=0.1 % Pass band amplitude ripple
  tpr=0.4 % Peak-to-peak pass band delay ripple
  dBas=45 % Stop band amplitude ripple
else 
  r0 = [   1.0000000000,   0.4268488267,  -0.0317251967,  -0.0154534827, ... 
           0.0191464815,  -0.0030145193,  -0.0045338772 ]';
  aa0 = [  0.0021429989,   0.0034892719,  -0.0042819826,  -0.0023721012, ... 
           0.0046545446,   0.0041687504,  -0.0086028453,  -0.0025908625, ... 
           0.0116079760,  -0.0024962176,  -0.0228420082,   0.0119922344, ... 
           0.0246549624,  -0.0222050941,  -0.0357212812,   0.0433955283, ... 
           0.0398228758,  -0.0913972722,  -0.0409314244,   0.3174162326, ... 
           0.5379853724,   0.3174162326,  -0.0409314244,  -0.0913972722, ... 
           0.0398228758,   0.0433955283,  -0.0357212812,  -0.0222050941, ... 
           0.0246549624,   0.0119922344,  -0.0228420082,  -0.0024962176, ... 
           0.0116079760,  -0.0025908625,  -0.0086028453,   0.0041687504, ... 
           0.0046545446,  -0.0023721012,  -0.0042819826,   0.0034892719, ... 
           0.0021429989 ]';
  Mmodel=9 % Model filter FRM decimation
  Dmodel=11 % Desired model filter passband delay
  dBap=0.045 % Pass band amplitude ripple
  tpr=0.45 % Peak-to-peak pass band delay ripple
  dBas=46 % Stop band amplitude ripple 
endif
mr=length(r0)-1 % Allpass model filter order
na=length(aa0) % FIR masking filter length
dmask=(na-1)/2 % FIR masking filter delay
Tnominal=(Mmodel*Dmodel)+dmask % Nominal FRM filter group delay
fap=0.24 % Amplitude pass band edge
Wap=1 % Pass band amplitude weight
ftp=0.24 % Delay pass band edge
Wtp=0.2 % Pass band delay weight
fas=0.26 % Amplitude stop band edge
Was=100 % Stop band amplitude weight
rho=31/32 % Stability constraint on lattice coefficients
dmax=0; % Unused

%
% Extract FRM filters
%
[k0,epsilon0,~,~]=tf2schurOneMlattice(flipud(r0),r0);
p0=ones(size(k0));
k0=k0(:);
u0=aa0(1:2:(dmask+1));
u0=u0(:);
v0=aa0(2:2:dmask);
v0=v0(:);
kuv_u=[rho*ones(size(k0));10*ones(size(u0));10*ones(size(v0))];
kuv_l=-kuv_u;
kuv_active=(1:(length(k0)+length(u0)+length(v0)))';

%
% Frequency vectors
%
w=(0:(n-1))'*pi/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Amplitude constraints
wa=w;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
ntp=ceil(ftp*n/0.5)+1;
wt=w(1:ntp);
Td=zeros(ntp,1);
Tdu=(tpr/2)*ones(ntp,1);
Tdl=-Tdu;
Wt=Wtp*ones(ntp,1);

% Common strings for output plots
strT=sprintf("FRM halfband %%s %%s : \
fap=%g,ftp=%g,fas=%g,mr=%d,Mmodel=%d,Dmodel=%d,dmask=%d", ...
             fap,ftp,fas,mr,Mmodel,Dmodel,dmask);
strF=sprintf("schurOneMAPlattice_frm_halfband_socp_slb_test_%%s_%%s");

% Plot the initial response
schurOneMAPlattice_frm_halfband_socp_slb_plot ...
  (r0,u0,v0,Mmodel,Dmodel,n,strT,strF,"initial");

%
% SOCP PCLS 
%
[k2,u2,v2,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMAPlattice_frm_halfband_slb ...
    (@schurOneMAPlattice_frm_halfband_socp_mmse, ...
     k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,kuv_u,kuv_l,kuv_active,dmax, ...
     wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,maxiter,tol,verbose);
if feasible == 0 
  error("k2(pcls) infeasible");
endif

% Plot the PCLS response
r2=schurOneMAPlattice2tf(k2,epsilon0,p0);
schurOneMAPlattice_frm_halfband_socp_slb_plot ...
  (r2,u2,v2,Mmodel,Dmodel,n,strT,strF,"PCLS");

%
% Save the results
%
fid=fopen("schurOneMAPlattice_frm_halfband_socp_slb_test.spec","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"mr=%d %% Allpass model filter denominator order\n",mr);
fprintf(fid,"na=%d %% FIR masking filter length (order+1)\n",na);
fprintf(fid,"Mmodel=%d %% Model filter FRM decimation factor\n",Mmodel);
fprintf(fid,"Dmodel=%d %% Model filter nominal pass band group delay \n",Dmodel);
fprintf(fid,"dmask=%d %% FIR masking filter delay\n",dmask);
fprintf(fid,"Tnominal=%g %% Nominal FRM filter group delay\n",Tnominal);
fprintf(fid,"fap=%g %% Pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Pass band weight\n",Wap);
fprintf(fid,"tpr=%g %% Pass band delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Pass band delay weight\n",Wtp);
fprintf(fid,"fas=%g %% Stop band edge\n",fas);
fprintf(fid,"dBas=%d %% Stop band attenuation ripple\n",dBas);
fprintf(fid,"Was=%d %% Stop band weight\n",Was);
fprintf(fid,"rho=%f %% Constraint on all-pass lattice coefficients\n",rho);
fclose(fid);

print_polynomial(r2,"r2");
print_polynomial(r2,"r2",sprintf(strF,"r2","coef.m"));
print_polynomial(k2,"k2");
print_polynomial(k2,"k2",sprintf(strF,"k2","coef.m"));
printf("epsilon0=[ ");printf("%2d ",epsilon0);printf("]\n");
print_polynomial(epsilon0,"epsilon0",sprintf(strF,"epsilon0","coef.m"),"%2d");
print_polynomial(u2,"u2");
print_polynomial(u2,"u2",sprintf(strF,"u2","coef.m"));
print_polynomial(v2,"v2");
print_polynomial(v2,"v2",sprintf(strF,"v2","coef.m"));

save schurOneMAPlattice_frm_halfband_socp_slb_test.mat ...
     r0 aa0 k0 epsilon0 p0 k2 u2 v2 Mmodel Dmodel ...
     fap fas dBap Wap tpr Wtp dBas Was rho tol

% Done
toc;
diary off
movefile schurOneMAPlattice_frm_halfband_socp_slb_test.diary.tmp ...
       schurOneMAPlattice_frm_halfband_socp_slb_test.diary;
