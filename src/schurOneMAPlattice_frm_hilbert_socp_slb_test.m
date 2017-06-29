% schurOneMAPlattice_frm_hilbert_socp_slb_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMAPlattice_frm_hilbert_socp_slb_test.diary");
unlink("schurOneMAPlattice_frm_hilbert_socp_slb_test.diary.tmp");
diary schurOneMAPlattice_frm_hilbert_socp_slb_test.diary.tmp

tic;

format compact

%
% Initial filter from tarczynski_frm_halfband_test.m
%
n=800
maxiter=2000
verbose=false

if 1
  tol=75e-6
  r0 = [   1.0000000000,   0.4654027371,  -0.0749201995,   0.0137121216, ... 
           0.0035706175,  -0.0098219303 ]';
  aa0 = [ -0.0019232288,   0.0038703625,   0.0038937068,  -0.0055310972, ... 
          -0.0073554558,   0.0065538587,   0.0124707197,   0.0002190941, ... 
          -0.0274067156,  -0.0109227368,   0.0373112692,   0.0338245953, ... 
          -0.0500281266,  -0.0817426036,   0.0547645647,   0.3116242327, ... 
           0.4439780707,   0.3116242327,   0.0547645647,  -0.0817426036, ... 
          -0.0500281266,   0.0338245953,   0.0373112692,  -0.0109227368, ... 
          -0.0274067156,   0.0002190941,   0.0124707197,   0.0065538587, ... 
          -0.0073554558,  -0.0055310972,   0.0038937068,   0.0038703625, ... 
          -0.0019232288 ]';
  Mmodel=7; % Model filter decimation
  Dmodel=9; % Desired model filter passband delay
  dBap=0.1 % Pass band amplitude ripple
  Wap=1 % Pass band amplitude weight
  tpr=0.76 % Peak-to-peak pass band delay ripple
  Wtp=0.01 % Pass band delay weight
  ppr=0.004*pi/2 % Peak-to-peak pass band phase ripple
  Wpp=0.1 % Pass band phase weight
  % Also feasible is:
  if 0
    dBap=0.15 % Pass band amplitude ripple
    tpr=0.385 % Peak-to-peak pass band delay ripple
    Wtp=0.02 % Pass band delay weight
  endif
else 
  tol=1e-6
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
  dBap=0.1 % Pass band amplitude ripple
  Wap=1 % Pass band amplitude weight
  tpr=0.7 % Peak-to-peak pass band delay ripple
  Wtp=0.01 % Pass band delay weight
  ppr=0.004*pi/2 % Peak-to-peak pass band phase ripple
  Wpp=0.1 % Pass band phase weight
endif
mr=length(r0)-1 % Model filter order
dmask=(length(aa0)-1)/2 % FIR masking filter delay
tp=(Mmodel*Dmodel)+dmask % Nominal FRM filter group delay
fap=0.01 % Amplitude pass band edge
fas=0.49 % Amplitude stop band edge
ftp=0.01 % Delay pass band edge
fts=0.49 % Delay stop band edge
fpp=0.01 % Phase pass band edge
fps=0.49 % Phase stop band edge
pp=-pi/2 % Nominal passband phase (adjusted for delay)

% Convert to Hilbert
rm1=ones(size(r0));
rm1(2:2:end)=-1;
[k0,epsilon0,p0,~]=tf2schurOneMlattice(flipud(r0).*rm1,r0.*rm1);
dmask=(length(aa0)-1)/2;
u0=aa0(1:2:(dmask+1));
um1=ones(size(u0));
um1(2:2:end)=-1;
u0=u0.*um1;
v0=aa0(2:2:dmask);
vm1=ones(size(v0));
vm1(2:2:end)=-1;
v0=v0.*vm1;

%
% Frequency vectors
%
n=800;
w=(0:(n-1))'*pi/n;

% Amplitude constraints
nap=floor(fap*n/0.5)+1;
nas=ceil(fas*n/0.5)+1;
wa=w(nap:nas);
Asqd=ones(size(wa));
Asqdu=Asqd;
Asqdl=10^(-dBap/10)*ones(size(wa));
Wa=Wap*ones(size(wa));

% Group delay constraints
ntp=floor(ftp*n/0.5)+1;
nts=ceil(fts*n/0.5)+1;
wt=w(ntp:nts);
Td=zeros(size(wt));
Tdu=(tpr/2)*ones(size(wt));
Tdl=-Tdu;
Wt=Wtp*ones(size(wt));

% Phase constraints
npp=floor(fpp*n/0.5)+1;
nps=ceil(fps*n/0.5)+1;
wp=w(npp:nps);
Pd=pp*ones(size(wp));
Pdu=pp+(ppr/2)*ones(size(wp));
Pdl=pp-(ppr/2)*ones(size(wp));
Wp=Wpp*ones(size(wp));

% Coefficient constraints
rho=127/128;
kuv_u=[rho*ones(size(k0(:)));10*ones(size(u0(:)));10*ones(size(v0(:)))];
kuv_l=-kuv_u;
kuv_active=(1:(length(k0)+length(u0)+length(v0)))';
dmax=inf;

% Common strings
strT=sprintf("FRM Hilbert %%s %%s : \
Mmodel=%d,Dmodel=%d,fap=%g,fas=%g,tp=%d",Mmodel,Dmodel,fap,fas,tp);
strF=sprintf("schurOneMAPlattice_frm_hilbert_socp_slb_test_%%s_%%s");

% Plot the initial response
schurOneMAPlattice_frm_hilbert_socp_slb_plot ...
  (k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,n,strT,strF,"initial");

%
% FRM hilbert SOCP PCLS
%
tic;
[k2tmp,u2,v2,slb_iter,socp_iter,func_iter,feasible] = ...
  schurOneMAPlattice_frm_hilbert_slb ...
    (@schurOneMAPlattice_frm_hilbert_socp_mmse, ...
     k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,kuv_u,kuv_l,kuv_active,dmax, ...
     wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
     maxiter,tol,verbose);
toc;
if feasible == 0 
  error("k2tmp,u2,v2(pcls) infeasible");
endif

% Recalculate epsilon2
r2=schurOneMAPlattice2tf(k2tmp,epsilon0,p0);
[k2,epsilon2,p2,~] = tf2schurOneMlattice(flipud(r2),r2);

% Plot the response
schurOneMAPlattice_frm_hilbert_socp_slb_plot ...
  (k2,epsilon2,p2,u2,v2,Mmodel,Dmodel,n,strT,strF,"PCLS", ...
   wa,Asqdu,Asqdl,wt,Tdu,Tdl,wp,Pdu,Pdl);

%
% Save the results
%
fid=fopen("schurOneMAPlattice_frm_hilbert_socp_slb_test.spec","wt");
fprintf(fid,"n=%d %% Frequency points\n",n);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"Mmodel=%d %% Model filter decimation\n",Mmodel);
fprintf(fid,"Dmodel=%d %% Desired model filter passband delay\n",Dmodel);
fprintf(fid,"mr=%d %% Model filter order\n",mr);
fprintf(fid,"dmask=%d %% FIR masking filter delay\n",dmask);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBap=%g %% Pass band amplitude ripple\n",dBap);
fprintf(fid,"Wap=%g %% Pass band amplitude weight\n",Wap);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"fts=%g %% Delay stop band edge\n",fts);
fprintf(fid,"tp=%d %% Nominal FRM filter group delay\n",tp);
fprintf(fid,"tpr=tp/%g %% Peak-to-peak pass band delay ripple\n",tp/tpr);
fprintf(fid,"Wtp=%g %% Pass band delay weight\n",Wtp);
fprintf(fid,"fpp=%g %% Phase pass band edge\n",fpp);
fprintf(fid,"fps=%g %% Phase stop band edge\n",fps);
fprintf(fid,"pp=%g*pi %% Nominal passband phase (adjusted for delay)\n",pp/pi);
fprintf(fid,"ppr=pi/%g %% Peak-to-peak pass band phase ripple\n",pi/ppr);
fprintf(fid,"Wpp=%g %% Pass band phase weight\n",Wpp);
fclose(fid);

print_polynomial(r2,"r2");
print_polynomial(r2,"r2",sprintf(strF,"r2","coef.m"));
print_polynomial(k2,"k2");
print_polynomial(k2,"k2",sprintf(strF,"k2","coef.m"));
print_polynomial(epsilon2,"epsilon2");
print_polynomial(epsilon2,"epsilon2",sprintf(strF,"epsilon2","coef.m"),"%2d");
print_polynomial(p2,"p2");
print_polynomial(p2,"p2",sprintf(strF,"p2","coef.m"));
print_polynomial(u2,"u2");
print_polynomial(u2,"u2",sprintf(strF,"u2","coef.m"));
print_polynomial(v2,"v2");
print_polynomial(v2,"v2",sprintf(strF,"v2","coef.m"));

save schurOneMAPlattice_frm_hilbert_socp_slb_test.mat ...
     r0 u0 v0 k0 epsilon0 p0 r2 u2 v2 k2 epsilon2 p2 ...
     Mmodel Dmodel dmax rho tol ...
     fap fas dBap Wap ftp fts tp tpr Wtp fpp fps pp ppr Wpp 

% Done
toc;
diary off
movefile schurOneMAPlattice_frm_hilbert_socp_slb_test.diary.tmp ...
       schurOneMAPlattice_frm_hilbert_socp_slb_test.diary;
