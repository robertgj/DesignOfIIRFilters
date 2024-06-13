% schurOneMAPlattice_frm_halfband_socp_slb_test.m

% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="schurOneMAPlattice_frm_halfband_socp_slb_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

%
% Filter specification
%
maxiter=2000
ftol=1e-5
ctol=ftol/100
verbose=false
n=800;

% Initial filter is found by tarczynski_frm_halfband_test.m
tarczynski_frm_halfband_test_r0_coef;
tarczynski_frm_halfband_test_aa0_coef;

Mmodel=7 % Model filter FRM decimation
Dmodel=9 % Desired model filter passband delay
dBap=0.05 % Pass band amplitude ripple
tpr=0.335 % Peak-to-peak pass band delay ripple
dBas=45 % Stop band amplitude ripple
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

% Common strings
strt=sprintf("FRM halfband %%s %%s : \
fap=%g,ftp=%g,fas=%g,mr=%d,Mmodel=%d,Dmodel=%d,dmask=%d", ...
             fap,ftp,fas,mr,Mmodel,Dmodel,dmask);

% Plot the initial response
schurOneMAPlattice_frm_halfband_socp_slb_plot ...
  (k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,n,strt,strcat(strf,"_%s_%s"),"initial");

%
% SOCP PCLS 
%
[k2,u2,v2,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMAPlattice_frm_halfband_slb ...
    (@schurOneMAPlattice_frm_halfband_socp_mmse, ...
     k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,kuv_u,kuv_l,kuv_active,dmax, ...
     wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,maxiter,ftol,ctol,verbose);
if feasible == 0 
  error("k2(pcls) infeasible");
endif

% Recalculate epsilon2 and p2
[epsilon2,p2] = schurOneMscale(k2);

% Plot the PCLS response
schurOneMAPlattice_frm_halfband_socp_slb_plot ...
  (k2,epsilon2,p2,u2,v2,Mmodel,Dmodel,n,strt,strcat(strf,"_%s_%s"),"PCLS");

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"mr=%d %% Allpass model filter denominator order\n",mr);
fprintf(fid,"na=%d %% FIR masking filter length (order+1)\n",na);
fprintf(fid,"Mmodel=%d %% Model filter FRM decimation factor\n",Mmodel);
fprintf(fid,"Dmodel=%d %% Model filter nominal pass band group delay \n",Dmodel);
fprintf(fid,"dmask=%d %% FIR masking filter delay\n",dmask);
fprintf(fid,"Tnominal=%g %% Nominal FRM filter group delay\n",Tnominal);
fprintf(fid,"fap=%g %% Pass band edge\n",fap);
fprintf(fid,"dBap=%g %% Pass band amplitude peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Pass band weight\n",Wap);
fprintf(fid,"tpr=%g %% Pass band delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band delay weight\n",Wtp);
fprintf(fid,"fas=%g %% Stop band edge\n",fas);
fprintf(fid,"dBas=%g %% Stop band attenuation ripple\n",dBas);
fprintf(fid,"Was=%g %% Stop band weight\n",Was);
fprintf(fid,"rho=%f %% Constraint on all-pass lattice coefficients\n",rho);
fclose(fid);

print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
printf("epsilon2=[ ");printf("%2d ",epsilon2);printf("]\n");
print_polynomial(epsilon2,"epsilon2",strcat(strf,"_epsilon2_coef.m"),"%2d");
print_polynomial(p2,"p2");
print_polynomial(p2,"p2",strcat(strf,"_p2_coef.m"));
print_polynomial(u2,"u2");
print_polynomial(u2,"u2",strcat(strf,"_u2_coef.m"));
print_polynomial(v2,"v2");
print_polynomial(v2,"v2",strcat(strf,"_v2_coef.m"));

eval(sprintf("save %s.mat Mmodel Dmodel fap fas dBap Wap tpr Wtp dBas Was \
rho ftol ctol r0 aa0 k0 epsilon0 p0 k2 epsilon2 p2 u2 v2",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
