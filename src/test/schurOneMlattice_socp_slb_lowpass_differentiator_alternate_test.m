% schurOneMlattice_socp_slb_lowpass_differentiator_alternate_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMlattice_socp_slb_lowpass_differentiator_alternate_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-5
ctol=ftol/100
maxiter=20000
verbose=false

% 1-1/z correction filter from tarczynski_lowpass_differentiator_alternate_test.m
tarczynski_lowpass_differentiator_alternate_test_D0_coef;
tarczynski_lowpass_differentiator_alternate_test_N0_coef;

% Correction filter order
nN=length(N0)-1;

% Convert transfer function to one-multiplier Schur lattice
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(N0,D0);
k0=k0(:);c0=c0(:);p0=p0(:);c0=c0(:);

% Low-pass differentiator filter specification
fap=0.18;fas=0.3;
Arp=0.005;Art=Arp;Ars=Arp;Wap=1;Wat=0.0001;Was=1;
ftp=fap;tp=length(N0)-2;tpr=0.01;Wtp=1;
fpp=fap;pp=1.5;ppr=0.0002;Wpp=1;
fdp=fap;cpr=0.1;Wdp=0.1

% Frequency points
n=1000;
w=pi*(1:(n-1))'/n;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);
ntp=ceil(ftp*n/0.5);
npp=ceil(fpp*n/0.5);
ndp=ceil(fdp*n/0.5);

% Pass and transition band amplitudes
wa=w;
Azm1=2*sin(wa/2);
Ad=[wa(1:nap)/2;zeros(n-1-nap,1)];
Adu=[wa(1:nas-1)/2; zeros(n-nas,1)] + ...
    [(Arp/2)*ones(nap,1);(Art/2)*ones((nas-nap-1),1);(Ars/2)*ones(n-nas,1)];
Adl=Ad-[(Arp/2)*ones(nap,1);zeros(n-1-nap,1)];
Adl(find(Adl<=0))=0;
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas,1)];

% Group delay
wt=w(1:ntp);
Tzm1=0.5;
Td=tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));

% Phase response with z^{-1}-1 removed
wp=w(1:npp);
Pzm1=(pi/2)-(wp/2);
Pd=(pp*pi)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% dAsqdw response
Asqd=Ad.^2;
dAsqddw=Ad;
Azm1=2*sin(wa/2);
Azm1sq=Azm1.^2;
dAzm1sqdw=2*sin(wa);
wd=wa(1:ndp);
Dd=dAsqddw(1:ndp);
Wd=Wdp*ones(size(wd));
Cd=(Dd-(Asqd(1:ndp).*cot(wd/2)))./Azm1sq(1:ndp);
Cdu=Cd+(cpr/2);
Cdl=Cd-(cpr/2);
dpr=cpr*Azm1sq(1:ndp);
Ddu=Dd+(dpr/2);
Ddl=Dd-(dpr/2);

% Coefficient constraints
dmax=0.1; % For compatibility with SQP
rho=127/128;
Nk=length(k0);
Nc=length(c0);
kc_u=[rho*ones(Nk,1);10*ones(Nc,1)];
kc_l=-kc_u;
kc_active=[find((k0)~=0);(Nk+(1:Nc))'];

% Sanity check
nachk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Ad(nachk)=[");printf("%g ",Ad(nachk));printf(" ]\n");
printf("Adu(nachk)=[");printf("%g ",Adu(nachk));printf(" ]\n");
printf("Adl(nachk)=[");printf("%g ",Adl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");

% Calculate the initial response
Asq0=schurOneMlatticeAsq(wa,k0,epsilon0,p0,c0);
A0=sqrt(Asq0).*Azm1;
P0=schurOneMlatticeP(wp,k0,epsilon0,p0,c0) + Pzm1;
T0=schurOneMlatticeT(wt,k0,epsilon0,p0,c0) + Tzm1;

%
% PCLS pass
%
printf("\nPCLS pass :\n");
feasible=false;
[k2,c2,slb_iter,opt_iter,func_iter,feasible] = schurOneMlattice_slb ...
  (@schurOneMlattice_socp_mmse, ...
   k0,epsilon0,p0,c0,kc_u,kc_l,kc_active,dmax, ...
   wa,(Ad./Azm1).^2,(Adu./Azm1).^2,(Adl./Azm1).^2,Wa, ...
   wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
   wp,Pd-Pzm1,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
   wd,Cd,Cdu,Cdl,Wd, ...
   maxiter,ftol,ctol,verbose);
if feasible == 0
  error("k2 (PCLS) infeasible");
endif

% Recalculate epsilon, p and c
printf("\nBefore recalculating epsilon and c:\n");
print_polynomial(epsilon0,"epsilon0");
print_polynomial(c2,"c2");
printf("\n");
[N2,D2]=schurOneMlattice2tf(k2,epsilon0,p0,c2);
[k2r,epsilon2,p2,c2]=tf2schurOneMlattice(N2,D2);
k2r=k2r(:);epsilon2=epsilon2(:);p2=p2(:);c2=c2(:);
if max(abs(k2-k2r))>10*eps
  error("max(abs(k2-k2r))(%g*eps)>10*eps",max(abs(k2-k2r))/eps);
endif

% Calculate the overall response
Csq2=schurOneMlatticeAsq(wa,k2,epsilon2,p2,c2);
Asq2=Csq2.*Azm1sq;
A2=sqrt(Asq2);
wp=w(1:npp);
Pzm1=(pi/2)-(wp/2);
P2=schurOneMlatticeP(wp,k2,epsilon2,p2,c2) + Pzm1;
T2=schurOneMlatticeT(wt,k2,epsilon2,p2,c2) + Tzm1;
dCsqdw2=schurOneMlatticedAsqdw(wd,k2,epsilon2,p2,c2);
dAsqdw2=(Csq2(1:ndp).*dAzm1sqdw(1:ndp))+(dCsqdw2.*Azm1sq(1:ndp));

% Plot response error
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
if 0
  axis(ax(1),[0 0.5 Arp*[-1,1]]);
  axis(ax(2),[0 0.5 Ars*[-1,1]]);
else
  axis(ax(1),[0 0.5 0.004*[-1,1]]);
  axis(ax(2),[0 0.5 0.004*[-1,1]]);
endif
strP=sprintf(["Differentiator PCLS : ", ...
 "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"],fap,Arp,fas,Ars,tp,tpr,ppr);
title(strP);
ylabel("Amplitude error");
grid("on");
subplot(312);
plot(wp*0.5/pi,([P2 Pdl Pdu]+(wp*tp))/pi);
axis([0 0.5 pp+(ppr*[-1,1])]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[T2 Tdl Tdu]);
axis([0 0.5 tp+(tpr*[-1,1])]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_error_response"),"-dpdflatex");
close

% Plot filter dAsqdw error
plot(wd*0.5/pi,[dAsqdw2,Ddl,Ddu]-Dd)
axis([0 fdp 0.1*[-1,1]])
strP=sprintf(["Differentiation filter dAsqdw error : ", ...
              "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"], ...
             fap,Arp,fas,Ars,tp,tpr,ppr);
ylabel("dAsqdw error");
title(strP);
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_dAsqdw"),"-dpdflatex");
close

%% Plot correction filter dCsqdw error
plot(wd*0.5/pi,[dCsqdw2,Cdl,Cdu]-Cd)
axis([0 fdp 0.1*[-1,1]])
strP=sprintf(["Correction filter dCsqdw error : ", ...
              "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"], ...
             fap,Arp,fas,Ars,tp,tpr,ppr);
ylabel("dCsqdw error");
title(strP);
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_correction"),"-dpdflatex");
close

% Pole-zero plot
zplane(qroots(conv(N2,[1,-1])),qroots(D2));
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

% Check transfer function
HH=freqz(N2,D2,wa);
if max(abs((abs(HH).^2)-Csq2)) > 10*eps
  error("max(abs((abs(HH).^2)-Csq2))(%g*eps) > 10*eps", max(abs((abs(HH).^2)-Csq2))/eps);
endif

% Save results
print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(epsilon2,"epsilon2");
print_polynomial(epsilon2,"epsilon2",strcat(strf,"_epsilon2_coef.m"));
print_polynomial(p2,"p2");
print_polynomial(p2,"p2",strcat(strf,"_p2_coef.m"));
print_polynomial(c2,"c2");
print_polynomial(c2,"c2",strcat(strf,"_c2_coef.m"));
print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"maxiter=%d %% Maximum iterations\n",maxiter);
fprintf(fid,"dmax=%d %% SQP step-size constraint\n",dmax);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"nN=%d %% Correction filter order\n",nN);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"Arp=%g %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Art=%g %% Amplitude transition band peak-to-peak ripple\n",Art);
fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
fprintf(fid,"Ars=%g %% Amplitude stop band peak-to-peak ripple\n",Ars);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"tp=%g %% Pass band group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"pp=%g %% Nominal pass band phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fprintf(fid,"fdp=%g %% dAsqdw pass band upper edge\n",fdp);
fprintf(fid, ...
        "cpr=%g %% Correction filter dCsqdw pass band peak-to-peak ripple\n", ...
        cpr);
fprintf(fid,"Wdp=%g %% Correction filter dCsqdw pass band weight\n",Wdp);
fclose(fid);

eval(sprintf(["save %s.mat ftol ctol n ", ...
              "fap fas Arp Ars Wap Wat Was ", ...
              "tp tpr Wtp pp ppr Wpp fdp cpr Wd ", ...
              "N0 D0 k0 epsilon0 p0 c0 k2 epsilon2 p2 c2 N2 D2"], ...
             strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
