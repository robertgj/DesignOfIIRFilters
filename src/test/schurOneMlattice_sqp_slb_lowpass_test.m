% schurOneMlattice_sqp_slb_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="schurOneMlattice_sqp_slb_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=4e-5
ctol=ftol
maxiter=2000
verbose=false

% Deczky3 lowpass filter specification
n=400
norder=10
fap=0.15,dBap=0.4,Wap=1
fas=0.3,dBas=46,Was_mmse=1e8,Was_pcls=1e8
ftp=0.25,tp=10,tpr=0.08,Wtp_mmse=0.1,Wtp_pcls=1
% Initial filter from deczky3_sqp_test.m
U=0;V=0;Q=6;M=10;R=1;
Z0=[exp(j*2*pi*0.41),exp(j*2*pi*0.305),1.5*exp(j*2*pi*0.2), ...
   1.5*exp(j*2*pi*0.14),1.5*exp(j*2*pi*0.08)];
P0=[0.7*exp(j*2*pi*0.16),0.6*exp(j*2*pi*0.12),0.5*exp(j*2*pi*0.05)];
K0=0.0096312406;
x0=[K0,abs(Z0),angle(Z0),abs(P0),angle(P0)]';
[n0,d0]=x2tf(x0,U,V,M,Q,R);
d0=[d0(:);zeros(length(n0)-length(d0),1)];
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(n0,d0);

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=[ones(nap,1); zeros(n-nap,1)];
Asqdu=[ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1); zeros(n-nap,1)];
Wa_mmse=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was_mmse*ones(n-nas+1,1)];
Wa_pcls=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was_pcls*ones(n-nas+1,1)];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt_mmse=Wtp_mmse*ones(ntp,1);
Wt_pcls=Wtp_pcls*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% dAsqdw constraints
wd=[];
Dd=[];
Ddu=[];
Ddl=[];
Wd=[];

% Constraints on the coefficients
dmax=0.05;
rho=127/128
k0=k0(:);
c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kc_u=[rho*ones(size(k0));10*ones(size(c0))];
kc_l=-kc_u;
kc_active=[find((k0)~=0);(Nk+(1:Nc))'];

% Common strings
strt=sprintf(["Schur one-multiplier lattice lowpass filter SQP %%s response : ", ...
 "fap=%g,dBap=%g,fas=%g,dBas=%g"],fap,dBap,fas,dBas);

%
% SQP MMSE
%
tic;
[k1p,c1p,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_sqp_mmse([],k0,epsilon0,p0,c0, ...
                             kc_u,kc_l,kc_active,dmax, ...
                             wa,Asqd,Asqdu,Asqdl,Wa_mmse, ...
                             wt,Td,Tdu,Tdl,Wt_mmse, ...
                             wp,Pd,Pdu,Pdl,Wp, ...
                             wd,Dd,Ddu,Ddl,Wd, ...
                             maxiter,ftol,ctol,verbose);
toc;
if feasible == 0 
  error("k1p,c1p(mmse) infeasible");
endif
% Recalculate epsilon1, p1 and c1
[n1,d1]=schurOneMlattice2tf(k1p,epsilon0,p0,c1p);
[k1,epsilon1,p1,c1]=tf2schurOneMlattice(n1,d1);
schurOneMlattice_sqp_slb_lowpass_plot ...
  (k1,epsilon1,p1,c1,fap,2*dBap,ftp,tp,2*tpr,fas,dBas, ...
   strcat(strf,"_mmse_k1c1"),sprintf(strt,"MMSE"));

%
% SQP PCLS
%
tic;
[k2p,c2p,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_slb(@schurOneMlattice_sqp_mmse, ...
                       k1,epsilon1,p1,c1, ...
                       kc_u,kc_l,kc_active,dmax, ...
                       wa,Asqd,Asqdu,Asqdl,Wa_pcls, ...
                       wt,Td,Tdu,Tdl,Wt_pcls, ...
                       wp,Pd,Pdu,Pdl,Wp, ...
                       wd,Dd,Ddu,Ddl,Wd, ...
                       maxiter,ftol,ctol,verbose);
toc;
if feasible == 0 
  error("k2p,c2p(pcls) infeasible");
endif
% Recalculate epsilon2, p2 and c2
[N2,D2]=schurOneMlattice2tf(k2p,epsilon1,p1,c2p);
[k2,epsilon2,p2,c2]=tf2schurOneMlattice(N2,D2);
schurOneMlattice_sqp_slb_lowpass_plot ...
  (k2,epsilon2,p2,c2,fap,dBap,ftp,tp,tpr,fas,dBas, ...
   strcat(strf,"_pcls_k2c2"),sprintf(strt,"PCLS"));

%
% Final amplitude and delay at local peaks
%
Asq=schurOneMlatticeAsq(wa,k2,epsilon2,p2,c2);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa(nap);wa(nas)]);
AsqS=schurOneMlatticeAsq(wAsqS,k2,epsilon2,p2,c2);
printf("d1:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMlatticeT(wt,k2,epsilon2,p2,c2);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt(ntp)]);
TS=schurOneMlatticeT(wTS,k2,epsilon2,p2,c2);
printf("d1:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:TS=[ ");printf("%f ",TS');printf(" ] (samples)\n");

% Check transfer function
HH=freqz(N2,D2,wa);
if max(abs((abs(HH).^2)-Asq)) > 100*eps
  error("max(abs((abs(HH).^2)-Asq)) > 100*eps");
endif

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"%% length(c0)=%d %% Tap coefficients\n",length(c0));
fprintf(fid,"%% sum(k0~=0)=%d %% Num. non-zero lattice coefficients\n", ...
        sum(k0~=0));
fprintf(fid,"dmax=%f %% Constraint on norm of coefficient SQP step size\n",dmax);
fprintf(fid,"rho=%f %% Constraint on lattice coefficient magnitudes\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp_mmse=%g %% Delay pass band weight for MMSE\n",Wtp_mmse);
fprintf(fid,"Wtp_pcls=%g %% Delay pass band weight for PCLS\n",Wtp_pcls);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%g %% amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was_mmse=%g %% Amplitude stop band weight for MMSE\n",Was_mmse);
fprintf(fid,"Was_pcls=%g %% Amplitude stop band weight for PCLS\n",Was_pcls);
fclose(fid);

print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(epsilon2,"epsilon2");
print_polynomial(epsilon2,"epsilon2",strcat(strf,"_epsilon2_coef.m"),"%2d");
print_polynomial(p2,"p2");
print_polynomial(p2,"p2",strcat(strf,"_p2_coef.m"));
print_polynomial(c2,"c2");
print_polynomial(c2,"c2",strcat(strf,"_c2_coef.m"));
print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

eval(sprintf(["save %s.mat x0 n0 d0 k0 epsilon0 p0 c0 ", ...
 "fap dBap Wap ftp tp tpr Wtp_mmse Wtp_pcls fas dBas Was_mmse ", ...
 "Was_pcls dmax rho ftol ctol k1 epsilon1 p1 c1 k2 epsilon2 p2 c2 N2 D2"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
