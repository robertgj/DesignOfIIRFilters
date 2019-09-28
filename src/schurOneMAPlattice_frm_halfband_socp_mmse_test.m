% schurOneMAPlattice_frm_halfband_socp_mmse_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("schurOneMAPlattice_frm_halfband_socp_mmse_test.diary");
unlink("schurOneMAPlattice_frm_halfband_socp_mmse_test.diary.tmp");
diary schurOneMAPlattice_frm_halfband_socp_mmse_test.diary.tmp

tic;


%
% Initial filter is found by tarczynski_frm_halfband_test.m
%
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

%
% Filter specification 
%
n=800;
tol=1e-6
maxiter=2000
verbose=true
mr=length(r0)-1 % Allpass model filter order
Mmodel=7 % Model filter FRM decimation
Dmodel=9 % Desired model filter passband delay
na=length(aa0) % FIR masking filter length
dmask=(na-1)/2 % FIR masking filter delay
fap=0.24 % Pass band edge
Wap=1 % Pass band amplitude weight
Wat=0 % Transition band  weight
ftp=0.24 % Pass band edgeW
Wtp=0.1 % Pass band delay weight
fas=0.26 % Stop band edge
dBas=50 % Stop band ripple
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
Asqd=[ones(nap,1);10^(-dBas/10)*ones(n-nap,1)];
Asqdu=zeros(size(wa));
Asqdl=zeros(size(wa));
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
ntp=ceil(ftp*n/0.5)+1;
wt=w(1:ntp);
Td=zeros(ntp,1);
Tdl=zeros(size(wt));
Tdu=zeros(size(wt));
Tdl=-Tdu;
Wt=Wtp*ones(ntp,1);

% Common strings
strt=sprintf("FRM halfband %%s %%s : \
Mmodel=%d,Dmodel=%d,fap=%g,fas=%g",Mmodel,Dmodel,fap,fas);
strf="schurOneMAPlattice_frm_halfband_socp_mmse_test";

%
% FRM halfband SOCP MMSE
%
tic;
[k1tmp,u1,v1,socp_iter,func_iter,feasible] = ...
  schurOneMAPlattice_frm_halfband_socp_mmse ...
    ([],k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,kuv_u,kuv_l,kuv_active,dmax, ...
     wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,maxiter,tol,verbose);
toc;
if feasible == 0 
  error("k1tmp,u1,v1(mmse) infeasible");
endif

% Plot the response
r1=schurOneMAPlattice2tf(k1tmp,epsilon0,p0);
[k1,epsilon1,p1,~] = tf2schurOneMlattice(flipud(r1),r1);
schurOneMAPlattice_frm_halfband_socp_slb_plot ...
  (k1,epsilon1,p1,u1,v1,Mmodel,Dmodel,n,strt,strcat(strf,"_%s_%s"),"MMSE");

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"length(k1)=%d %% Number of all-pass coefficients\n",length(k1));
fprintf(fid,"length(u1)=%d %% Number of FIR u coefficients\n",length(u1));
fprintf(fid,"length(v1)=%d %% Number of FIR v coefficients\n",length(v1));
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"Wtp=%d %% Delay pass band weight for MMSE\n",Wtp);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Was=%d %% Amplitude stop band weight for MMSE\n",Was);
fclose(fid);

print_polynomial(r1,"r1");
print_polynomial(r1,"r1",strcat(strf,"_r1_coef.m"));
print_polynomial(k1,"k1");
print_polynomial(k1,"k1",strcat(strf,"_k1_coef.m"));
print_polynomial(epsilon1,"epsilon1");
print_polynomial(k1,"epsilon1",strcat(strf,"_epsilon1_coef.m"));
print_polynomial(u1,"u1");
print_polynomial(u1,"u1",strcat(strf,"_u1_coef.m"));
print_polynomial(v1,"v1");
print_polynomial(v1,"v1",strcat(strf,"_v1_coef.m"));

save schurOneMAPlattice_frm_halfband_socp_mmse_test.mat ...
     r0 aa0 k0 epsilon0 p0 u0 v0 Mmodel Dmodel ...
     fap Wap ftp Wtp fas Was dmax rho tol k1 u1 v1

% Done
toc;
diary off
movefile schurOneMAPlattice_frm_halfband_socp_mmse_test.diary.tmp ...
       schurOneMAPlattice_frm_halfband_socp_mmse_test.diary;
