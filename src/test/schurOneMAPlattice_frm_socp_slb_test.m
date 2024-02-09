% schurOneMAPlattice_frm_socp_slb_test.m
% Copyright (C) 2019-2022 Robert G. Jenssen

test_common;

strf="schurOneMAPlattice_frm_socp_slb_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;


%
% Initial filter from iir_frm_allpass_socp_slb_test.m
%
%
iir_frm_allpass_socp_slb_test_r_coef;
iir_frm_allpass_socp_slb_test_aa_coef;
iir_frm_allpass_socp_slb_test_ac_coef;
r0=r;aa0=aa;ac0=ac;

%
% Filter specification
%
n=1000;
tol=1e-4
ctol=tol/10
maxiter=2000
verbose=false
Mmodel=9; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
dmask=(length(aa0)-1)/2; % FIR masking filter delay
fap=0.3 % Pass band edge
dBap=0.05 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
Wat=0 % Transition band amplitude weight
fas=0.3105 % Stop band edge
dBas=43 % Stop band amplitude ripple 
Was=10 % Stop band amplitude weight
ftp=fap % Delay pass band edge
tp=(Mmodel*Dmodel)+dmask;
tpr=1 % Peak-to-peak pass band delay ripple
Wtp=0.02 % Pass band delay weight
fpp=fap % Phase pass band edge
pp=0 % Pass band zero-phase phase
ppr=0.01*pi % Peak-to-peak pass band phase ripple
Wpp=0.01 % Pass band phase weight
rho=31/32 % Stability constraint on pole radius

% Calculate Schur one-multiplier lattice FRM filter coefficients
[k0,epsilon0,p0,~] = tf2schurOneMlattice(flipud(r0),r0);
u0=aa0((dmask+1):end);
v0=ac0((dmask+1):end);

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
Pdu=(ppr/2)*ones(nap,1);
Pdl=-Pdu;
Wp=Wpp*ones(nap,1);

% Coefficient constraints
kuv_u=[rho*ones(size(k0(:)));10*ones(size(u0(:)));10*ones(size(v0(:)))];
kuv_l=-kuv_u;
kuv_active=(1:(length(k0)+length(u0)+length(v0)))';
dmax=inf;

%
% FRM SOCP PCLS
%
tic;
[k1,u1,v1,slb_iter,socp_iter,func_iter,feasible] = ...
  schurOneMAPlattice_frm_slb(@schurOneMAPlattice_frm_socp_mmse,
     k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,kuv_u,kuv_l,kuv_active,dmax, ...
     wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
     maxiter,tol,ctol,verbose);
toc;
if feasible == 0 
  error("k1,u1,v1(mmse) infeasible");
endif
% Recalculate epsilon1 and p1
[epsilon1,p1] = schurOneMscale(k1);

% Plot results
strt=sprintf("FRM PCLS : Mmodel=%d,Dmodel=%d,fap=%g,fas=%g,tp=%d", ...
             Mmodel,Dmodel,fap,fas,tp);
schurOneMAPlattice_frm_socp_slb_plot ...
  (k1,epsilon1,p1,u1,v1,Mmodel,Dmodel,fap,fas, ...
   strt,strcat(strf,"_%s_%s"),"PCLS");

%
% Compare with remez
%
b=remez((2*length([k0(:);u0(:);v0(:)]))-2,2*[0 fap fas 0.5],[1 1 0 0]);
Hfir=freqz(b,1,wa);
Asq=schurOneMAPlattice_frmAsq(wa,k1,epsilon1,p1,u1,v1,Mmodel,Dmodel);
subplot(111);
plot(wa*0.5/pi,10*log10(Asq),"--", ...
     wa*0.5/pi,20*log10(abs(Hfir)),"-");
legend("FRM","FIR");
legend("location","northeast");
legend("boxoff");
legend("left");
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.5 -60 5]);
grid("on");
print(strcat(strf,"_remez"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"n=%d %% Frequency points\n",n);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"Mmodel=%d %% Model filter decimation\n",Mmodel);
fprintf(fid,"Dmodel=%d %% Desired model filter passband delay\n",Dmodel);
fprintf(fid,"dmask=%d %% FIR masking filter delay\n",dmask);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%g %% Pass band amplitude ripple\n",dBap);
fprintf(fid,"Wap=%g %% Pass band amplitude weight\n",Wap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%g %% Stop band amplitude ripple\n",dBas);
fprintf(fid,"Was=%g %% Stop band amplitude weight\n",Was);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"tp=%d %% Nominal FRM filter delay\n",tp);
fprintf(fid,"tpr=tp/%g %% Peak-to-peak pass band delay ripple\n",tp/tpr);
fprintf(fid,"Wtp=%g %% Pass band delay weight\n",Wtp);
fprintf(fid,"fpp=%g %% Phase pass band edge\n",fpp);
fprintf(fid,"pp=%g*pi %% Nominal passband phase (adjusted for delay)\n",pp/pi);
fprintf(fid,"ppr=pi/%g %% Peak-to-peak pass band phase ripple\n",pi/ppr);
fprintf(fid,"Wpp=%g %% Pass band phase weight\n",Wpp);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fclose(fid);

print_polynomial(b,"b");
print_polynomial(b,"b",strcat(strf,"_b_coef.m"));
print_polynomial(k1,"k1");
print_polynomial(k1,"k1",strcat(strf,"_k1_coef.m"));
print_polynomial(epsilon1,"epsilon1");
print_polynomial(epsilon1,"epsilon1",strcat(strf,"_epsilon1_coef.m"),"%2d");
print_polynomial(p1,"p1");
print_polynomial(p1,"p1",strcat(strf,"_p1_coef.m"));
print_polynomial(u1,"u1");
print_polynomial(u1,"u1",strcat(strf,"_u1_coef.m"));
print_polynomial(v1,"v1");
print_polynomial(v1,"v1",strcat(strf,"_v1_coef.m"));

save schurOneMAPlattice_frm_socp_slb_test.mat ...
     r0 aa0 ac0 k1 epsilon1 p1 u1 v1 Mmodel Dmodel dmax rho tol ctol ...
     fap fas Wap ftp tp tpr Wtp fpp pp ppr Wpp 

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
