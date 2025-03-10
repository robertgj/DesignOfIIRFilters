% schurOneMlattice_socp_slb_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="schurOneMlattice_socp_slb_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-5
ctol=ftol/10
maxiter=2000
verbose=false

% Deczky3 lowpass filter specification
n=500
fap=0.15,dBap=0.1,Wap=1
ftp=0.25,tp=9,tpr=0.02,Wtp=1
Wat=2*ftol
fas=0.35,dBas=47,Was=100

% Initial filter similar to Deczky Example 3a
U=1;V=2;M=8;Q=4;R=1;
K0=0.005;
Z0=-2;
P0=[0.5,0.5];
z0=[exp(j*2*pi*0.35),1.5*exp(j*2*pi*0.2),1.5*exp(j*2*pi*0.14), ...
    1.5*exp(j*2*pi*0.08)];
p0=[0.7*exp(j*2*pi*0.16),0.6*exp(j*2*pi*0.12)];
x0=[K0,Z0,P0,abs(z0),angle(z0),abs(p0),angle(p0)]';
[n0,d0]=x2tf(x0,U,V,M,Q,R);
d0=[d0(:);zeros(length(n0)-length(d0),1)];

% Convert transfer function to one-multiplier Schur lattice
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(n0,d0);

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=[ones(nap,1); zeros(n-nap,1)];
Asqdu=[ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1); zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

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
dmax=0; % For compatibility with SQP
rho=127/128;
k0=k0(:);
c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kc_u=[rho*ones(size(k0));10*ones(size(c0))];
kc_l=-kc_u;
kc_active=[find((k0)~=0);(Nk+(1:Nc))'];
  
% Common strings
strt=sprintf(["Schur one-multiplier lattice lowpass filter SOCP %%s response : ", ...
 "fap=%g,dBap=%g,fas=%g,dBas=%g"],fap,dBap,fas,dBas);

%
% SOCP PCLS
%
tic;
[k2p,c2p,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_slb(@schurOneMlattice_socp_mmse, ...
                       k0,epsilon0,p0,c0,kc_u,kc_l,kc_active,dmax, ...
                       wa,Asqd,Asqdu,Asqdl,Wa, ...
                       wt,Td,Tdu,Tdl,Wt, ...
                       wp,Pd,Pdu,Pdl,Wp, ...
                       wd,Dd,Ddu,Ddl,Wd, ...
                       maxiter,ftol,ctol,verbose);
toc;
if feasible == 0 
  error("k2p,c2p(pcls) infeasible");
endif

% Recalculate epsilon2, p2 and c2
[N2,D2]=schurOneMlattice2tf(k2p,epsilon0,ones(size(p0)),c2p);
[k2,epsilon2,p2,c2]=tf2schurOneMlattice(N2,D2);

% Trim zeros from n2 and d2
N2=N2(1:(U+M+1));
D2=D2(1:(V+Q+1));

% Plot
schurOneMlattice_socp_slb_lowpass_plot ...
  (N2,D2,k2,epsilon2,p2,c2,fap,dBap,ftp,tp,tpr,fas,dBas, ...
   strcat(strf,"_pcls_k2c2"),sprintf(strt,"PCLS"));

% Amplitude and delay at local peaks
Asq=schurOneMlatticeAsq(wa,k2,epsilon2,p2,c2);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AsqS=schurOneMlatticeAsq(wAsqS,k2,epsilon2,p2,c2);
printf("k2,c2:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k2,c2:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMlatticeT(wt,k2,epsilon2,p2,c2);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMlatticeT(wTS,k2,epsilon2,p2,c2);
printf("k2,c2:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k2,c2:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

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
fprintf(fid,"%% length(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",length(k0));
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Delay pass band weight\n",Wtp);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fclose(fid);

print_pole_zero(x0,U,V,M,Q,R,"x0");
print_pole_zero(x0,U,V,M,Q,R,"x0",strcat(strf,"_x0_coef.m"));
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

eval(sprintf(["save %s.mat x0 n0 d0 k0 epsilon0 p0 c0 fap dBap Wap ", ...
 "ftp tp tpr Wtp Wat fas dBas Was rho ftol ctol k2 epsilon2 p2 c2 N2 D2"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
