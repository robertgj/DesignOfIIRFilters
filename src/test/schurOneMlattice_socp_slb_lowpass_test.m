% schurOneMlattice_socp_slb_lowpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("schurOneMlattice_socp_slb_lowpass_test.diary");
delete("schurOneMlattice_socp_slb_lowpass_test.diary.tmp");
diary schurOneMlattice_socp_slb_lowpass_test.diary.tmp

tic;


tol=1e-6
ctol=tol
maxiter=2000
verbose=false

% Deczky3 lowpass filter specification
n=400
norder=10
fap=0.15,dBap=0.1,Wap=1
ftp=0.25,tp=10,tpr=0.02,Wtp=1
Wat=2*tol
fas=0.3,dBas=38,Was=100
% Initial filter similar to Deczky Example 3a
U=0;V=0;Q=6;M=10;R=1;
z0=[exp(j*2*pi*0.41),exp(j*2*pi*0.305),1.5*exp(j*2*pi*0.2), ...
    1.5*exp(j*2*pi*0.14),1.5*exp(j*2*pi*0.08)];
p0=[0.7*exp(j*2*pi*0.16),0.6*exp(j*2*pi*0.12),0.5*exp(j*2*pi*0.05)];
K0=0.0096312406;
x0=[K0,abs(z0),angle(z0),abs(p0),angle(p0)]';
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
strf="schurOneMlattice_socp_slb_lowpass_test";
strt=sprintf("Schur one-multiplier lattice lowpass filter SOCP %%s response : \
fap=%g,dBap=%g,fas=%g,dBas=%g",fap,dBap,fas,dBas);

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
                       maxiter,tol,ctol,verbose);
toc;
if feasible == 0 
  error("k2p,c2p(pcls) infeasible");
endif
% Recalculate epsilon2, p2 and c2
[n2,d2]=schurOneMlattice2tf(k2p,epsilon0,ones(size(p0)),c2p);
[k2,epsilon2,p2,c2]=tf2schurOneMlattice(n2,d2);
schurOneMlattice_socp_slb_lowpass_plot ...
  (k2,epsilon2,p2,c2,fap,dBap,ftp,tp,tpr,fas,dBas, ...
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

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"length(c0)=%d %% Tap coefficients\n",length(c0));
fprintf(fid,"length(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",length(k0));
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%d %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);

print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(epsilon2,"epsilon2");
print_polynomial(epsilon2,"epsilon2",strcat(strf,"_epsilon2_coef.m"),"%2d");
print_polynomial(p2,"p2");
print_polynomial(p2,"p2",strcat(strf,"_p2_coef.m"));
print_polynomial(c2,"c2");
print_polynomial(c2,"c2",strcat(strf,"_c2_coef.m"));
print_polynomial(n2,"n2");
print_polynomial(n2,"n2",strcat(strf,"_n2_coef.m"));
print_polynomial(d2,"d2");
print_polynomial(d2,"d2",strcat(strf,"_d2_coef.m"));

save schurOneMlattice_socp_slb_lowpass_test.mat x0 n0 d0 k0 epsilon0 p0 c0 ...
     fap dBap Wap ftp tp tpr Wtp Wat fas dBas Was rho tol ctol ...
     k2 epsilon2 p2 c2 n2 d2

% Done
toc;
diary off
movefile schurOneMlattice_socp_slb_lowpass_test.diary.tmp ...
         schurOneMlattice_socp_slb_lowpass_test.diary;