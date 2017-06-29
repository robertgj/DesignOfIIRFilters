% schurNSlattice_sqp_mmse_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurNSlattice_sqp_mmse_test.diary");
unlink("schurNSlattice_sqp_mmse_test.diary.tmp");
diary schurNSlattice_sqp_mmse_test.diary.tmp

tic;

format compact

tol=1e-3
maxiter=2000
verbose=false

% Deczky3 lowpass filter specification
n=800
norder=10
fap=0.15,Wap=1,dBap=0.2
fas=0.3,Was_mmse=1e4,dBas=30
ftp=0.25,tp=10,tpr=0.1,Wtp_mmse=0.01

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
Asqdu=[];
Asqdl=[];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was_mmse*ones(n-nas+1,1)];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=tp*ones(ntp,1);
Tdu=[];
Tdl=[];
Wt=Wtp_mmse*ones(ntp,1);

% Common strings
strT=sprintf("Schur normalised-scaled lattice lowpass filter SQP %%s \
response : fap=%g,fas=%g",fap,fas);
strF=sprintf("schurNSlattice_sqp_mmse_test_%%s_%%s");

% Constraints on the coefficients are given by section:
%  [s10(1),s11(1),s20(1),s02(1),s00(1),s22(1),s10(2),s11(2),...,s22(Ns)]
dmax=0.05
rho=1-tol
Ns=length(s10_0);
sxx_u=reshape(kron([10*ones(2,1);rho*ones(4,1)],ones(1,Ns)),1,6*Ns);
sxx_l=-sxx_u;

% Find the active coefficients. Note the bitwise & operation!
[Esq,gradEsq]=...
  schurNSlatticeEsq(s10_0,s11_0,s20_0,s00_0,s02_0,s22_0,wa,Asqd,Wa,wt,Td,Wt);
sxx_0=reshape([s10_0;s11_0;s20_0;s00_0;s02_0;s22_0],1,6*Ns);
sxx_active=intersect(find(gradEsq),find((sxx_0~=0)&(sxx_0~=1)));

% Enforce s02=-s20,s22=s00?
sxx_symmetric=true;

%
% SQP MMSE
%
tic;
[s10_1,s11_1,s20_1,s00_1,s02_1,s22_1,sqp_iter,func_iter,feasible] = ...
  schurNSlattice_sqp_mmse([],s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                          sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
                          wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                          maxiter,tol,verbose);
toc;
if feasible == 0 
  error("s10_1,s11_1,s20_1,s00_1,s02_1,s22_1(mmse) infeasible");
endif
schurNSlattice_sqp_slb_lowpass_plot ...
  (s10_1,s11_1,s20_1,s00_1,s02_1,s22_1,fap,dBap,ftp,tp,tpr,fas,dBas, ...
   sprintf(strF,"mmse","sxx_1"),sprintf(strT,"MMSE"));

%
% Find simulated state standard deviation in bits
%
% Make a quantised noise signal with standard deviation 0.25*2^nbits
nbits=10;
scale=2^(nbits-1);
nsamples=2^12;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u);
dir_extra_bits=0;
u_dir_scaled=round(u*scale*(2^dir_extra_bits));
u=round(u*scale);
% Simulate
[yapf,yf,xxf]=schurNSlatticeFilter(s10_1,s11_1,s20_1,s00_1,s02_1,s22_1, ...
                                   u,"round");
% Plot frequency response
nfpts=1024;
nppts=(0:511);
Hf=crossWelch(u,yf,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(Hf)));
xlabel("Frequency")
ylabel("Amplitude(dB)")
axis([0 0.5 -50 5]);
grid("on");
print("schurNSlattice_sqp_mmse_test_response","-dpdflatex");
close
% Show state variable std. deviation in bits
stdxxf=std(xxf)
print_polynomial(stdxxf,"stdxxf",...
                 "schurNSlattice_sqp_mmse_test.stdxxf_false.val","%5.1f");

%
% Save the results
%
fid=fopen("schurNSlattice_sqp_mmse_test.spec","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"sxx_symmetric=%1d %% Enforce s02=-s20 and s22=s00\n",sxx_symmetric);
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
print_polynomial(s10_1,"s10_1");
print_polynomial(s10_1,"s10_1","schurNSlattice_sqp_mmse_test_s10_1_coef.m");
print_polynomial(s11_1,"s11_1");
print_polynomial(s11_1,"s11_1","schurNSlattice_sqp_mmse_test_s11_1_coef.m");
print_polynomial(s20_1,"s20_1");
print_polynomial(s20_1,"s20_1","schurNSlattice_sqp_mmse_test_s20_1_coef.m");
print_polynomial(s00_1,"s00_1");
print_polynomial(s00_1,"s00_1","schurNSlattice_sqp_mmse_test_s00_1_coef.m");
print_polynomial(s02_1,"s02_1");
print_polynomial(s02_1,"s02_1","schurNSlattice_sqp_mmse_test_s02_1_coef.m");
print_polynomial(s22_1,"s22_1");
print_polynomial(s22_1,"s22_1","schurNSlattice_sqp_mmse_test_s22_1_coef.m");
save schurNSlattice_sqp_mmse_test.mat n0 d0 ...
     fap Wap ftp tp Wtp_mmse fas Was_mmse dmax rho tol ...
     s10_0 s11_0 s20_0 s00_0 s02_0 s22_0 ...
     s10_1 s11_1 s20_1 s00_1 s02_1 s22_1

% Done
toc;
diary off
movefile schurNSlattice_sqp_mmse_test.diary.tmp ...
       schurNSlattice_sqp_mmse_test.diary;
