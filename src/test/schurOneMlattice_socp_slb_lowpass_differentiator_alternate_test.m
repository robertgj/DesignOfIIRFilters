% schurOneMlattice_socp_slb_lowpass_differentiator_alternate_test.m
% Copyright (C) 2024 Robert G. Jenssen

test_common;

strf="schurOneMlattice_socp_slb_lowpass_differentiator_alternate_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

tol=1e-4
ctol=tol/10
maxiter=20000
verbose=false
use_tarczynski=false
use_abrupt_Ad=true
use_MMSE=false

% Polynomials from iir_sqp_slb_lowpass_differentiator_alternate_test.m
% (correction filter for 1-z^{-1}). PCLS optimisation does not improve these.
if use_tarczynski
  tarczynski_lowpass_differentiator_alternate_test_D0_coef;
  tarczynski_lowpass_differentiator_alternate_test_N0_coef;
else
  iir_sqp_slb_lowpass_differentiator_alternate_test_D1_coef; D0=D1;
  iir_sqp_slb_lowpass_differentiator_alternate_test_N1_coef; N0=N1;
endif
% Correction filter order
nN=length(N0)-1;

% Convert transfer function to one-multiplier Schur lattice
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(N0,D0);
k0=k0(:);c0=c0(:);p0=p0(:);c0=c0(:);

% Low-pass differentiator filter specification
if use_tarczynski
  fap=0.2;fas=0.3;
  Arp=0.2;Art=0.2;Ars=0.2;Wap=1;Wat_mmse=0.01;Wat_pcls=0.0001;Was=2;
  ftp=fap;td=nN-1;tdr=0.2;Wtp=1;
  fpp=fap;pr=0.1;Wpp=1;
else
  fap=0.2;fas=0.3;
  Arp=0.01;Art=0.05;Ars=0.01;Wap=1;Wat_mmse=0.01;Wat_pcls=0.0001;Was=2;
  ftp=fap;td=nN-1;tdr=0.02;Wtp=0.5;
  fpp=fap;pr=0.00006;Wpp=0.5;
endif

% Frequency points
n=1000;
w=pi*(1:(n-1))'/n;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);
ntp=ceil(ftp*n/0.5);
npp=ceil(fpp*n/0.5);

% Pass and transition band amplitudes
wa=w;
Azm1=2*sin(wa/2);
if use_abrupt_Ad
  Ad=[wa(1:nap)/2;zeros(n-nap-1,1)];
else
  Ad=[w(1:nap)/2; (w(nap)/2)*((nas-nap-1):-1:1)'/(nas-nap-1);zeros(n-nas,1)];
endif
Adu=[wa(1:nas-1)/2; zeros(n-nas,1)] + ...
    [(Arp/2)*ones(nap,1);(Art/2)*ones((nas-nap-1),1);(Ars/2)*ones(n-nas,1)];
Adl=Ad-[(Arp/2)*ones(nap,1);(Art/2)*ones(nas-nap-1,1);(Ars/2)*ones(n-nas,1)];
Adl(find(Adl<=0))=0;
Wa_mmse=[Wap*ones(nap,1); Wat_mmse*ones(nas-nap-1,1); Was*ones(n-nas,1)];
Wa_pcls=[Wap*ones(nap,1); Wat_pcls*ones(nas-nap-1,1); Was*ones(n-nas,1)];

% Group delay
wt=w(1:ntp);
Tzm1=0.5;
Td=td*ones(size(wt));
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wt=Wtp*ones(size(wt));

% Phase response with 1-z^{-1} removed
wp=w(1:npp);
Pzm1=(pi/2)-(wp/2);
Pd=(pi/2)-(wp*td);
Pdu=Pd+(pr*pi/2);
Pdl=Pd-(pr*pi/2);
Wp=Wpp*ones(size(wp));

% Coefficient constraints
dmax=0; % For compatibility with SQP
rho=127/128;
Nk=length(k0);
Nc=length(c0);
kc_u=[rho*ones(Nk,1);10*ones(Nc,1)];
kc_l=-kc_u;
kc_active=ones(Nk+Nc,1);

% Sanity check
nachk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Ad(nachk)=[");printf("%g ",Ad(nachk));printf(" ]\n");
printf("Adu(nachk)=[");printf("%g ",Adu(nachk));printf(" ]\n");
printf("Adl(nachk)=[");printf("%g ",Adl(nachk));printf(" ]\n");
printf("Wa_mmse(nachk)=[");printf("%g ",Wa_mmse(nachk));printf(" ]\n");
printf("Wa_pcls(nachk)=[");printf("%g ",Wa_pcls(nachk));printf(" ]\n");

% Calculate the initial response
Asq0=schurOneMlatticeAsq(wa,k0,epsilon0,p0,c0);
A0=sqrt(Asq0).*Azm1;
P0=schurOneMlatticeP(wp,k0,epsilon0,p0,c0) + Pzm1;
T0=schurOneMlatticeT(wt,k0,epsilon0,p0,c0) + Tzm1;

if use_MMSE
  %
  % MMSE pass
  %
  printf("\nMMSE pass :\n");
  feasible=false;
  [k1,c1,opt_iter,func_iter,feasible] = schurOneMlattice_socp_mmse ...
      ([], ...
       k0,epsilon0,p0,c0,kc_u,kc_l,kc_active,dmax, ...
       wa,(Ad./Azm1).^2,(Adu./Azm1).^2,(Adl./Azm1).^2,Wa_mmse, ...
       wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
       wp,Pd-Pzm1,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
       maxiter,tol,verbose);
  if feasible == 0
    error("k1 (MMSE) infeasible");
  endif

  % Calculate the MMSE response
  Asq1=schurOneMlatticeAsq(wa,k1,epsilon0,p0,c1);
  A1=sqrt(Asq1).*Azm1;
  P1=schurOneMlatticeP(wp,k1,epsilon0,p0,c1) + Pzm1;
  T1=schurOneMlatticeT(wt,k1,epsilon0,p0,c1) + Tzm1;
else
  k1=k0;
  c1=c0;
endif

%
% PCLS pass
%
printf("\nPCLS pass :\n");
feasible=false;
[k2,c2,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMlattice_slb ...
    (@schurOneMlattice_socp_mmse, ...
     k1,epsilon0,p0,c1,kc_u,kc_l,kc_active,dmax, ...
     wa,(Ad./Azm1).^2,(Adu./Azm1).^2,-(Adl./Azm1).^2,Wa_pcls, ...
     wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
     wp,Pd-Pzm1,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
     maxiter,tol,ctol,verbose);
if feasible == 0
  error("k2 (PCLS) infeasible");
endif

% Calculate the overall response
[epsilon2,p2]=schurOneMscale(k2);
Asq2=schurOneMlatticeAsq(wa,k2,epsilon2,p2,c2);
A2=sqrt(Asq2).*Azm1;
P2=schurOneMlatticeP(wp,k2,epsilon2,p2,c2) + Pzm1;
T2=schurOneMlatticeT(wt,k2,epsilon2,p2,c2) + Tzm1;

% Plot response
subplot(311);
[ax,ha,hs]=plotyy ...
             (wa(1:nap)*0.5/pi, ...
              ([A2(1:nap),Adl(1:nap),Adu(1:nap)])-Ad(1:nap), ...
              wa(nas:end)*0.5/pi, ...
              [A2(nas:end),[Adl(nas:end),Adu(nas:end)]]);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 -Arp Arp]);
axis(ax(2),[0 0.5 -Ars Ars]);
strP=sprintf("Differentiator PCLS : \
fap=%g,Arp=%g,fas=%g,Ars=%g,td=%g,tdr=%g,pr=%g",fap,Arp,fas,Ars,td,tdr,pr);
title(strP);
ylabel("Amplitude error");
grid("on");
subplot(312);
plot(wp*0.5/pi,([P2 Pdl Pdu]-Pd)/pi);
axis([0 0.5 (pr*[-1,1])]);
ylabel("Phase error(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[T2 Tdl Tdu]);
axis([0 0.5 (td+(tdr*[-1,1]))]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_response"),"-dpdflatex");
close

% Pole-zero plot
[N2,D2]=schurOneMlattice2tf(k2,epsilon0,p0,c2);
print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));
zplane(roots(conv(N2,[1,-1])),roots(D2));
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

% Save results
print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(epsilon2,"epsilon2","%2d");
print_polynomial(epsilon2,"epsilon2",strcat(strf,"_epsilon2_coef.m"),"%2d");
print_polynomial(p2,"p2");
print_polynomial(p2,"p2",strcat(strf,"_p2_coef.m"));
print_polynomial(c2,"c2");
print_polynomial(c2,"c2",strcat(strf,"_c2_coef.m"));

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"maxiter=%d %% Maximum iterations\n",maxiter);
fprintf(fid,"dmax=%d %% SQP step-size constraint\n",dmax);
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"nN=%d %% Correction filter order\n",nN);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"Arp=%g %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Art=%g %% Amplitude transition band peak-to-peak ripple\n",Art);
fprintf(fid,"Wat_mmse=%g %% Amplitude transition band weight(MMSE)\n",Wat_mmse);
fprintf(fid,"Wat_pcls=%g %% Amplitude transition band weight(PCLS)\n",Wat_pcls);
fprintf(fid,"Ars=%g %% Amplitude stop band peak-to-peak ripple\n",Ars);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"td=%g %% Pass band group delay\n",td);
fprintf(fid,"tdr=%g %% Pass band group delay peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"pr=%g %% Phase pass band peak-to-peak ripple(rad./$\\pi$))\n",pr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

eval(sprintf("save %s.mat ...\n\
tol ctol n fap fas Arp Ars td tdr pr Wap Wat_mmse Wat_pcls Was Wtp Wpp ...\n\
N0 D0 k0 epsilon0 p0 c0 k2 epsilon2 p2 c2 N2 D2",strf))

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
