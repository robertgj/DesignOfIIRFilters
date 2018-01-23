% schurOneMlattice_sqp_mmse_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("schurOneMlattice_sqp_mmse_test.diary");
unlink("schurOneMlattice_sqp_mmse_test.diary.tmp");
diary schurOneMlattice_sqp_mmse_test.diary.tmp

tic;

format compact

tol=1e-6
maxiter=2000
verbose=true

% Deczky3 lowpass filter specification
n=800
norder=10
fap=0.15,Wap=1
fas=0.3,Was_mmse=1e8
ftp=0.25,tp=10,Wtp_mmse=0.1 %.25
% Initial filter from deczky3_sqp_test.m
U=0;V=0;Q=6;M=10;R=1;
z0=[exp(j*2*pi*0.41),exp(j*2*pi*0.305),1.5*exp(j*2*pi*0.2), ...
   1.5*exp(j*2*pi*0.14),1.5*exp(j*2*pi*0.08)];
p0=[0.7*exp(j*2*pi*0.16),0.6*exp(j*2*pi*0.12),0.5*exp(j*2*pi*0.05)];
K0=0.0096312406;
x0=[K0,abs(z0),angle(z0),abs(p0),angle(p0)]';
[n0,d0]=x2tf(x0,U,V,M,Q,R);
d0=[d0(:);zeros(length(n0)-length(d0),1)];
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(n0,d0);

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=[ones(nap,1); zeros(n-nap,1)];
Asqdu=[];
Asqdl=[];
Wa=[Wap*ones(nap,1);zeros(nas-nap,1);Was_mmse*ones(n-nas,1)];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=tp*ones(ntp,1);
Tdu=[];
Tdl=[];
Wt=Wtp_mmse*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Constraints on the coefficients
dmax=0.1
rho=127/128
ku=rho*ones(size(k0));
cu=10*ones(size(c0));
kc_u=[ku(:);cu(:)];
kl=-ku;
cl=-cu;
kc_l=[kl(:);cl(:)];
kc_active=[find((k0(:)')~=0),(length(k0)+1):(length(k0)+length(c0))]';

% Common strings
strf="schurOneMlattice_sqp_mmse_test";
strt=sprintf("Schur one-multiplier lattice lowpass filter SQP %%s response : \
fap=%g,fas=%g",fap,fas);

%
% SQP MMSE
%
tic;
[k1,c1,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_sqp_mmse([],k0,epsilon0,p0,c0, ...
                            kc_u,kc_l,kc_active,dmax, ...
                            wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                            wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose);
toc;
if feasible == 0 
  error("k1,c1(mmse) infeasible");
endif
schurOneMlattice_sqp_slb_lowpass_plot ...
  (k1,epsilon0,ones(size(p0)),c1,fap,2,ftp,tp,tp,fas,30, ...
   strcat(strf,"_mmse_k1c1"),sprintf(strt,"MMSE"));

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"length(c0)=%d %% Tap coefficients\n",length(c0));
fprintf(fid,"length(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",length(k0));
fprintf(fid,"dmax=%f %% Constraint on norm of coefficient step size\n",dmax);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"Wtp_mmse=%d %% Delay pass band weight for MMSE\n",Wtp_mmse);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Was_mmse=%d %% Amplitude stop band weight for MMSE\n",Was_mmse);
fclose(fid);
print_polynomial(k1,"k1");
print_polynomial(k1,"k1",strcat(strf,"_k1_coef.m"));
print_polynomial(c1,"c1");
print_polynomial(c1,"c1",strcat(strf,"_c1_coef.m"));
save schurOneMlattice_sqp_mmse_test.mat n0 d0 k0 epsilon0 p0 c0 ...
     fap Wap ftp tp Wtp_mmse fas Was_mmse dmax rho tol k1 c1

% Done
toc;
diary off
movefile schurOneMlattice_sqp_mmse_test.diary.tmp ...
         schurOneMlattice_sqp_mmse_test.diary;
