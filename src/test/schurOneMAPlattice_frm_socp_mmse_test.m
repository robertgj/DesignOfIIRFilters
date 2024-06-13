% schurOneMAPlattice_frm_socp_mmse_test.m
% Copyright (C) 2019-2024 Robert G. Jenssen

test_common;

strf="schurOneMAPlattice_frm_socp_mmse_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
ftol=1e-6
ctol=ftol/10
verbose=false

%
% Initial filter from tarczynski_frm_allpass_test.m
%
%
% Use the filters found by tarczynski_frm_allpass_test.m
%
r0 = [    1.0000000000,   0.2459795566,   0.4610947857,  -0.1206398420, ... 
         -0.0518355550,   0.0567634483,  -0.0264386549,   0.0246267271, ... 
         -0.0176437270,  -0.0008974729,   0.0056956381 ]';
aa0 = [  -0.0216588504,  -0.0114618315,   0.0302611209,  -0.0043408321, ... 
         -0.0274279593,   0.0062386856,   0.0166035962,  -0.0208670992, ... 
         -0.0036770815,   0.0566015372,   0.0039899993,  -0.0683299841, ... 
          0.0358708912,   0.0511704141,  -0.0490317610,  -0.0006425193, ... 
          0.0797439710,  -0.0690263959,  -0.1272015380,   0.2921723028, ... 
          0.6430650464,   0.2921723028,  -0.1272015380,  -0.0690263959, ... 
          0.0797439710,  -0.0006425193,  -0.0490317610,   0.0511704141, ... 
          0.0358708912,  -0.0683299841,   0.0039899993,   0.0566015372, ... 
         -0.0036770815,  -0.0208670992,   0.0166035962,   0.0062386856, ... 
         -0.0274279593,  -0.0043408321,   0.0302611209,  -0.0114618315, ... 
         -0.0216588504 ]';
ac0 = [  -0.0181078194,   0.0563970997,   0.1769164319,   0.0607733538, ... 
         -0.0221620117,  -0.0050415353,   0.0112963303,  -0.0009704899, ... 
         -0.0074583106,  -0.0391109460,   0.1410234146,   0.4815173162, ... 
          0.1799696079,  -0.0814357412,  -0.0115214971,   0.0590494998, ... 
         -0.0510521399,  -0.0105302211,   0.0627620289,  -0.0675640305, ... 
         -0.0255600918,  -0.0675640305,   0.0627620289,  -0.0105302211, ... 
         -0.0510521399,   0.0590494998,  -0.0115214971,  -0.0814357412, ... 
          0.1799696079,   0.4815173162,   0.1410234146,  -0.0391109460, ... 
         -0.0074583106,  -0.0009704899,   0.0112963303,  -0.0050415353, ... 
         -0.0221620117,   0.0607733538,   0.1769164319,   0.0563970997, ... 
         -0.0181078194 ]';
Mmodel=9; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
mr=length(r0)-1; % Model filter order
na=length(aa0);  % FIR masking filter length
dmask=(na-1)/2; % FIR masking filter delay

% Calculate Schur one-multiplier lattice FRM filter coefficients
[k0,epsilon0,p0,~] = tf2schurOneMlattice(flipud(r0),r0);
u0=aa0((dmask+1):end);
v0=ac0((dmask+1):end);

%
% Filter specification
%
n=1000;
fap=0.29 % Pass band edge
dBap=0.1 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
Wat=0.01 % Transition band amplitude weight
fas=0.3125 % Stop band edge
dBas=40 % Stop band amplitude ripple
Was=100 % Stop band amplitude weight
ftp=fap % Delay pass band edge
tp=(Mmodel*Dmodel)+dmask;
tpr=5 % Peak-to-peak pass band delay ripple
Wtp=0.01 % Pass band delay weight
fpp=fap % Phase pass band edge
ppr=0.02 % Peak-to-peak pass band phase ripple
Wpp=0.01 % Pass band phase weight

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
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
wt=w(1:nap);
Td=zeros(nap,1);
Tdu=(tpr/2)*ones(nap,1);
Tdl=-Tdu;
Wt=Wtp*ones(nap,1);

% Phase constraints
wp=w(1:nap);
Pd=zeros(nap,1);
Pdu=(ppr*pi/2)*ones(nap,1);
Pdl=-Pdu;
Wp=Wpp*ones(nap,1);

% Coefficient constraints
rho=127/128;
kuv_u=[rho*ones(size(k0(:)));10*ones(size(u0(:)));10*ones(size(v0(:)))];
kuv_l=-kuv_u;
kuv_active=(1:(length(k0)+length(u0)+length(v0)))';
dmax=inf;

% Common strings
strt=sprintf("FRM %%s %%s : \
Mmodel=%d,Dmodel=%d,fap=%g,fas=%g,tp=%d,ppr=%g",Mmodel,Dmodel,fap,fas,tp,ppr);

%
% FRM SOCP MMSE
%
tic;
[k1,u1,v1,socp_iter,func_iter,feasible] = ...
  schurOneMAPlattice_frm_socp_mmse ...
    ([],k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,kuv_u,kuv_l,kuv_active,dmax, ...
     wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
     maxiter,ftol,ctol,verbose);
toc;
if feasible == 0 
  error("k1,u1,v1(mmse) infeasible");
endif

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"n=%d %% Frequency points\n",n);
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"Mmodel=%d %% Model filter decimation\n",Mmodel);
fprintf(fid,"Dmodel=%d %% Desired model filter passband delay\n",Dmodel);
fprintf(fid,"mr=%d %% Model filter order\n",mr);
fprintf(fid,"dmask=%d %% FIR masking filter delay\n",dmask);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Wap=%g %% Pass band amplitude weight\n",Wap);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"tp=%g %% Nominal FRM filter group delay\n",tp);
fprintf(fid,"Wtp=%g %% Pass band delay weight\n",Wtp);
fprintf(fid,"fpp=%g %% Phase pass band edge\n",fpp);
fprintf(fid,"ppr=%g %% Pass band phase peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Pass band phase weight\n",Wpp);
fclose(fid);

print_polynomial(k1,"k1");
print_polynomial(k1,"k1",strcat(strf,"_k1_coef.m"));
print_polynomial(u1,"u1");
print_polynomial(u1,"u1",strcat(strf,"_u1_coef.m"));
print_polynomial(v1,"v1");
print_polynomial(v1,"v1",strcat(strf,"_v1_coef.m"));

eval(sprintf("save %s.mat r0 u0 v0 k0 epsilon0 p0 k1 u1 v1 Mmodel Dmodel dmax \
rho ftol fap fas Wap ftp tp Wtp fpp ppr Wpp",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
