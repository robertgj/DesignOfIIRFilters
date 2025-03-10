% schurOneMlattice_socp_slb_lowpass_differentiator_R2_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMlattice_socp_slb_lowpass_differentiator_R2_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-6
ctol=ftol/100
maxiter=20000
verbose=false
plot_dAsqdw=false

% Low-pass differentiator filter specification
nN=10; % Order of correction filter for (z-1)
R=2;   % Denominator polynomial in z^-2 only
fap=0.2;fas=0.4;
Arp=0.0009;Art=0.004;Ars=0.007;Wap=1;Wat=0.0001;Was=0.1;
fpp=fap;pp=1.5;ppr=0.0002;Wpp=1;
ftp=fap;tp=nN-1;tpr=0.006;Wtp=0.1;
fdp=fap;dpr=0.1;cpr=0.013;Wdp=0.1;

%{
% An alternative filter:
fap=0.25;fas=0.45;
Arp=0.01;Art=0.02;Ars=0.02;Wap=1;Wat=0.0001;Was=1;
fpp=fap;pp=1.5;ppr=0.002;Wpp=1;
ftp=fap;tp=nN-1;tpr=0.2;Wtp=0.1;
fdp=fap;dpr=0.6;cpr=0.6;Wdp=0.1;
%}

% Frequency points
n=1000;
w=pi*(1:(n-1))'/n;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);
npp=ceil(fpp*n/0.5);
ntp=ceil(ftp*n/0.5);
ndp=ceil(fdp*n/0.5);

% Pass and transition band amplitudes
wa=w;
Azm1=2*sin(wa/2);
Azm1sq=Azm1.^2;
dAzm1sqdw=2*sin(wa);
Ad=[wa(1:nap)/2;zeros(n-1-nap,1)];
Asqd=Ad.^2;
dAsqddw=Ad;
Adu=[wa(1:nas-1)/2; zeros(n-nas,1)] + ...
    ([Arp*ones(nap,1);Art*ones((nas-nap-1),1);Ars*ones(n-nas,1)]/2);
Adl=Ad-([Arp*ones(nap,1);zeros(n-1-nap,1)]/2);
Adl(find(Adl<=0))=0;
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas,1)];

% Phase response with z^{-1}-1 removed
wp=w(1:npp);
Pzm1=(pi/2)-(wp/2);
Pd=(pi*pp)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% Group delay
wt=w(1:ntp);
Tzm1=0.5;
Td=tp*ones(size(wt));
Tdu=Td+(tpr*ones(ntp,1)/2);
Tdl=Td-(tpr*ones(ntp,1)/2);
Wt=Wtp*ones(size(wt));

% dAsqdw response
wd=wa(1:ndp);
Dd=dAsqddw(1:ndp);
Wd=Wdp*ones(size(wd));
Cd=(Dd-(Asqd(1:ndp).*cot(w(1:ndp)/2)))./Azm1sq(1:ndp);
if plot_dAsqdw
  Ddu=Dd+(dpr/2);
  Ddl=Dd-(dpr/2);
  Cdu=Cd+((dpr/2)./Azm1sq(1:ndp));
  Cdl=Cd-((dpr/2)./Azm1sq(1:ndp));
else
  Cdu=Cd+(cpr/2);
  Cdl=Cd-(cpr/2);
  Ddu=Dd+((cpr/2)./Azm1sq(1:ndp));
  Ddl=Dd-((cpr/2)./Azm1sq(1:ndp));
endif

% Sanity check
nachk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Ad(nachk)=[");printf("%g ",Ad(nachk));printf(" ]\n");
printf("Adu(nachk)=[");printf("%g ",Adu(nachk));printf(" ]\n");
printf("Adl(nachk)=[");printf("%g ",Adl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");

%
% Use the WISE method of Tarczynski et al. to find an initial filter
%
wi=pi*(1:(n-1))'/n;
bzm1=[1,-1];
Hzm1=freqz(bzm1,1,wi)(:);
Hi=[(-j*(wi(1:nap)/2)./Hzm1(1:nap)).*exp(-j*tp*wi(1:nap)); zeros(n-nap-1,1)];
Wi=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas,1)];

% Unconstrained minimisation
nD=floor(nN/2);
NI=[1;zeros(nN+nD,1)];
WISEJ([],nN,nD,R,wi,Hi,Wi);
opt=optimset("TolFun",ftol,"TolX",ftol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ND0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ,NI,opt);
if (INFO == 1)
  printf("Converged to a solution point.\n");
elseif (INFO == 2)
  printf("Last relative step size was less that TolX.\n");
elseif (INFO == 3)
  printf("Last relative decrease in function value was less than TolF.\n");
elseif (INFO == 0)
  printf("Iteration limit exceeded.\n");
elseif (INFO == -3)
  printf("The trust region radius became excessively small.\n");
else
  error("Unknown INFO value.\n");
endif
printf("Function value=%f\n", FVEC);
printf("fminunc iterations=%d\n", OUTPUT.iterations);
printf("fminunc successful=%d??\n", OUTPUT.successful);
printf("fminunc funcCount=%d\n", OUTPUT.funcCount);

% Convert to Schur one-multiplier coefficients
ND0=ND0(:);
N0=ND0(1:(nN+1));
D0=[1; ND0((nN+2):end)];
D0R=[D0(1);kron(D0(2:end),[zeros(R-1,1);1])];
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(N0,D0R);
k0=k0(:);c0=c0(:);epilon0=epsilon0(:);p0=p0(:);c0=c0(:);

% Calculate the initial response
Csq0=schurOneMlatticeAsq(wa,k0,epsilon0,p0,c0);
A0=sqrt(Csq0).*Azm1;
P0=schurOneMlatticeP(wp,k0,epsilon0,p0,c0) + Pzm1;
T0=schurOneMlatticeT(wt,k0,epsilon0,p0,c0) + Tzm1;
dCsqdw0=schurOneMlatticedAsqdw(wd,k0,epsilon0,p0,c0);
dAsqdw0=(Csq0(1:ndp).*dAzm1sqdw(1:ndp))+(dCsqdw0.*(Azm1sq(1:ndp)));

% Plot the initial response
subplot(311);
[ax,ha,hs]=plotyy(wa(1:nas)*0.5/pi, ...
                  [A0(1:nas),Adl(1:nas),Adu(1:nas)], ...
                  wa(nas:end)*0.5/pi, ...
                  [A0(nas:end),Adl(nas:end),Adu(nas:end)]);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 0 1]);
axis(ax(2),[0 0.5 0 0.025]);
strP=sprintf(["Differentiator initial response : ", ...
 "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g"],
             fap,Arp,fas,Ars,tp);
title(strP);
ylabel("Amplitude(dB)");
grid("on");
subplot(312);
plot(wp*0.5/pi,([P0 Pdl Pdu]+(wp*tp))/pi);
axis([0 0.5 pp+ppr*[-1,1]]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[T0 Tdl Tdu]);
axis([0 0.5 tp+tpr*[-1,1]]);
ylabel("Delay(samples)");
grid("on");
xlabel("Frequency");
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

% Pole-zero plot
zplane(qroots(conv(N0,bzm1)),qroots(D0R));
print(strcat(strf,"_initial_pz"),"-dpdflatex");
close

%
% PCLS pass
%
printf("\nPCLS pass :\n");

% Coefficient constraints
dmax=0;
rho=127/128;
Nk=length(k0);
Nc=length(c0);
kc_u=[rho*ones(Nk,1);10*ones(Nc,1)];
kc_l=-kc_u;
kc_active=[find((k0)~=0);(Nk+(1:Nc))'];

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
if max(abs(k2-k2r))>eps
  error("max(abs(k2-k2r))(%g*eps)>eps",max(abs(k2-k2r))/eps);
endif

% Pole-zero plot
zplane(qroots(conv(N2,bzm1)),qroots(D2));
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

% Calculate the overall response
Csq2=schurOneMlatticeAsq(wa,k2,epsilon2,p2,c2);
A2=sqrt(Csq2).*Azm1;
wp=w(1:npp);
Pzm1=(pi/2)-(wp/2);
P2=schurOneMlatticeP(wp,k2,epsilon2,p2,c2) + Pzm1;
T2=schurOneMlatticeT(wt,k2,epsilon2,p2,c2) + Tzm1;
dCsqdw2=schurOneMlatticedAsqdw(wd,k2,epsilon2,p2,c2);
dAsqdw2=(Csq2(1:ndp).*dAzm1sqdw(1:ndp))+(dCsqdw2.*Azm1sq(1:ndp));

% Plot response error
subplot(311);
[ax,ha,hs]=plotyy(wa(1:nap)*0.5/pi, ...
                  [A2(1:nap),Adl(1:nap),Adu(1:nap)]-Ad(1:nap), ...
                  wa(nas:end)*0.5/pi, ...
                  [A2(nas:end),Adl(nas:end),Adu(nas:end)]);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 0.001*[-1,1]]);
axis(ax(2),[0 0.5 0.004*[-1,1]]);
strP=sprintf(["Differentiator PCLS error : ", ...
 "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"],fap,Arp,fas,Ars,tp,tpr,ppr);
title(strP);
ylabel("Amplitude");
grid("on");
subplot(312);
plot(wp*0.5/pi,([P2 Pdl Pdu]-Pd)/pi);
axis([0 0.5 0.0002*[-1,1]]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[T2 Tdl Tdu]-tp);
axis([0 0.5 (0.004*[-1,1])]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_error"),"-dpdflatex");
close

% Plot correction filter dAsqdw error
if plot_dAsqdw
  plot(wd*0.5/pi,[dAsqdw2,Ddl,Ddu]-Dd)
  axis([0 fdp 0.1*[-1,1]])
  strP=sprintf(["Differentiation filter dAsqdw error : ", ...
 "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"],fap,Arp,fas,Ars,tp,tpr,ppr);
  ylabel("dAsqdw");
else
  plot(wd*0.5/pi,[dCsqdw2,Cdl,Cdu]-Cd)
  axis([0 fdp 0.01*[-1,1]])
  strP=sprintf(["Correction filter dCsqdw error : ", ...
 "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"],fap,Arp,fas,Ars,tp,tpr,ppr);
  ylabel("dCsqdw");
endif
title(strP);
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_correction"),"-dpdflatex");
close

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
fprintf(fid,"Was=%g %% Amplitude stop band weight(PCLS)\n",Was);
fprintf(fid,"fpp=%g %% Phase pass band upper edge\n",fpp);
fprintf(fid,"pp=%g %% Nominal pass band phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fprintf(fid,"ftp=%g %% Delay pass band upper edge\n",ftp);
fprintf(fid,"tp=%g %% Pass band group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"fdp=%g %% dAsqdw pass band upper edge\n",fdp);
fprintf(fid,"dpr=%g %% Pass band dAsqdw peak-to-peak ripple\n",dpr);
fprintf(fid,"Wdp=%g %% Pass band dAsqdw weight\n",Wdp);
fclose(fid);

eval(sprintf(["save %s.mat ftol ctol n fap fas Arp Ars tp tpr pp ppr dpr ", ...
 "Wap Wat Was Wtp Wpp Wdp N0 D0 k0 epsilon0 p0 c0 k2 epsilon2 p2 c2 N2 D2"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
