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
maxiter=2000
verbose=false

% Low-pass differentiator filter specification
if 1
  nN=10 % Order of correction filter for (z-1)
  R=2;  % Denominator polynomial in z^-2 only
  fap=0.2;fas=0.4;
  Arp=0.0009;Art=0.004;Ars=0.007;Wap=1;Wat=0.0001;Was=0.1;
  fpp=fap;pp=1.5;ppr=0.0002;Wpp=1;
  ftp=fap;tp=nN-1;tpr=0.006;Wtp=0.1;
  fdp=0.1;cpr=0.02;cn=4;Wdp=0.1;
else
  nN=12 % Order of correction filter for (z-1)
  R=2;  % Denominator polynomial in z^-2 only
  fap=0.2;fas=0.4;
  Arp=0.0004;Art=0.004;Ars=0.004;Wap=1;Wat=0.0001;Was=0.1;
  fpp=fap;pp=1.5;ppr=0.0002;Wpp=1;
  ftp=fap;tp=nN-1;tpr=0.004;Wtp=0.1;
  fdp=0.1;cpr=0.004;cn=4;Wdp=0.1;
endif

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
Rap=1:nap;
Ras=nas:length(wa);
Fz=[1;-1];
Az=2*sin(wa/2);
Azsq=Az.^2;
dAzsqdw=2*sin(wa);
Ad=[wa(Rap)/2;zeros(n-1-nap,1)];
Asqd=Ad.^2;
dAsqddw=Ad;
Adu=[wa(1:(nas-1))/2;zeros(n-nas,1)] + ...
    [(Arp/2)*ones(nap,1);(Art/2)*ones((nas-nap-1),1);(Ars/2)*ones(n-nas,1)];
Adl=Ad-([Arp*ones(nap,1);zeros(n-1-nap,1)]/2);
Adl(find(Adl<=0))=0;
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas,1)];

% Phase response with z^{-1}-1 removed
wp=w(1:npp);
Pz=(pi/2)-(wp/2);
Pd=(pi*pp)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% Group delay
wt=w(1:ntp);
Tz=0.5*ones(size(wt));
Td=tp*ones(size(wt));
Tdu=Td+(tpr*ones(ntp,1)/2);
Tdl=Td-(tpr*ones(ntp,1)/2);
Wt=Wtp*ones(size(wt));

% dAsqdw response
Rdp=1:ndp;
wd=wa(Rdp);
Dd=dAsqddw(Rdp);
Wd=Wdp*ones(size(wd));
Cd=(Dd-(Asqd(Rdp).*cot(wd/2)))./Azsq(Rdp);
Cderr=(cpr/2)*((Rdp(:)/ndp).^cn);
Cdu=Cd+Cderr;
Cdl=Cd-Cderr;
Dd=dAsqddw(Rdp);
Dderr=(Cderr.*Azsq(Rdp));
Ddu=Dd+Dderr;
Ddl=Dd-Dderr;

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
Hz=freqz(Fz,1,wi)(:);
Hi=[(-j*(wi(Rap)/2)./Hz(Rap)).*exp(-j*tp*wi(Rap)); zeros(n-nap-1,1)];
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
k0=k0(:);c0=c0(:);epilon0=epsilon0(:);p0=p0(:);p_ones=ones(size(k0));c0=c0(:);
% Calculate the initial response
Csq0=schurOneMlatticeAsq(wa,k0,epsilon0,p0,c0);
A0c=sqrt(Csq0);
A0=A0c.*Az;
P0c=schurOneMlatticeP(wp,k0,epsilon0,p0,c0);
P0=P0c(:)+Pz;
T0c=schurOneMlatticeT(wt,k0,epsilon0,p0,c0);
T0=T0c(:)+Tz;
dCsqdw0=schurOneMlatticedAsqdw(wd,k0,epsilon0,p0,c0);
dAsqdw0=(Csq0(Rdp).*dAzsqdw(Rdp))+(dCsqdw0(:).*(Azsq(Rdp)));

% Plot the initial response
subplot(311);
[ax,ha,hs]=plotyy(wa(1:nas)*0.5/pi,A0(1:nas),wa(Ras)*0.5/pi,A0(Ras));
% Copy line colour
hac=get(ha,"color");
set(hs,"color",hac);
% Set axes colour
set(ax(1),"ycolor","black");
set(ax(2),"ycolor","black");
axis(ax(1),[0 0.5 0 1]);
axis(ax(2),[0 0.5 0 0.025]);
strP= ...
  sprintf("Differentiator initial response : fap=%g,fas=%g,pp=%g$\\pi$,tp=%g",...
          fap,fas,pp,tp);
title(strP);
ylabel("Amplitude");
grid("on");
subplot(312);
plot(wp*0.5/pi,(P0+(wp*tp))/pi);
axis([0 0.5 pp+(2*ppr*[-1,1])]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,T0);
axis([0 0.5 tp+(2*tpr*[-1,1])]);
ylabel("Delay(samples)");
grid("on");
xlabel("Frequency");
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

% Pole-zero plot
zplane(qroots(conv(N0(:),Fz)),qroots(D0R(:)));
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
   wa,(Ad./Az).^2,(Adu./Az).^2,(Adl./Az).^2,Wa, ...
   wt,Td-Tz,Tdu-Tz,Tdl-Tz,Wt, ...
   wp,Pd-Pz,Pdu-Pz,Pdl-Pz,Wp, ...
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

%
% Calculate the overall response
%
[Csq2,gradCsq2]=schurOneMlatticeAsq(wa,k2,epsilon2,p2,c2);
A2=sqrt(Csq2(:)).*Az;
[P2c,gradP2c]=schurOneMlatticeP(wp,k2,epsilon2,p2,c2);
P2=P2c(:)+Pz;
[T2c,gradT2c]=schurOneMlatticeT(wt,k2,epsilon2,p2,c2);
T2=T2c(:)+Tz;
dCsqdw2=schurOneMlatticedAsqdw(wd,k2,epsilon2,p2,c2);
dAsqdw2=(Csq2(Rdp).*dAzsqdw(Rdp))+(dCsqdw2(:).*Azsq(Rdp));

%
% Plot results
%

% Pole-zero plot
zplane(qroots(conv(N2(:),Fz)),qroots(D2(:)));
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

% Plot response error
subplot(311);
[ax,ha,hs] = plotyy(wa(Rap)*0.5/pi,[A2(Rap),Adu(Rap),Adl(Rap)]-Ad(Rap), ...
                    wa(Ras)*0.5/pi,[A2(Ras),Adu(Ras),Adl(Ras)]);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
% Copy axis colour
set(ax(1),"ycolor","black");
set(ax(2),"ycolor","black");
axis(ax(1),[0 0.5 0.001*[-1,1]]);
axis(ax(2),[0 0.5 0.004*[-1,1]]);
strT=sprintf(["Differentiator PCLS error : ", ...
 "fap=%g,Arp=%g,tp=%g,tpr=%g,ppr=%g,fas=%g,Ars=%g"],fap,Arp,tp,tpr,ppr,fas,Ars);
%title(strT);
ylabel("Amplitude error");
grid("on");
subplot(312);
plot(wp*0.5/pi,(([P2 Pdu Pdl]+(wp*tp))/pi)-pp);
axis([0 0.5 (0.0002*[-1,1])]);
ylabel("Phase error(rad./$\\pi$)");
grid("on");
legend("Response","Upper PCLS constraint","Lower PCLS constraint");
legend("location","east");
legend("boxoff");
legend("right");
subplot(313);
plot(wt*0.5/pi,[T2 Tdu Tdl]);
axis([0 0.5 tp+(0.004*[-1,1])]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_pcls_error"),"-dpdflatex");
close

% Plot pass band relative amplitude response error
plot(wa(Rap)*0.5/pi,([A2(Rap),Adu(Rap),Adl(Rap)]./Ad(Rap))-1);
axis([0 fap 0.002*[-1,1]]);
strT=sprintf(["Differentiator PCLS relative error : fap=%g,Arp=%g"],fap,Arp);
title(strT);
ylabel("Relative amplitude error");
grid("on");
print(strcat(strf,"_pcls_pass_amplitude_relative_error"),"-dpdflatex");
close

% Plot filter dAsqdw error
plot(wd*0.5/pi,[dAsqdw2,Ddu,Ddl]-Dd)
axis([0 fdp 0.004*[-1,1]])
grid("on");
title("Differentiator filter $\\frac{d\\lvert A\\rvert^{2}}{dw}$ error");
ylabel("$\\frac{d\\lvert A\\rvert^{2}}{dw}$ error");
xlabel("Frequency");
legend("Response","Upper PCLS constraint","Lower PCLS constraint");
legend("location","southwest");
legend("boxoff");
legend("right");
print(strcat(strf,"_pcls_dAsqdw_error"),"-dpdflatex");
close

% Plot correction filter dCsqdw error
plot(wd*0.5/pi,[dCsqdw2,Cdu,Cdl]-Cd)
axis([0 fdp 0.01*[-1,1]])
grid("on");
title("Differentiator correction filter $\\frac{d\\lvert C\\rvert^{2}}{dw}$ error");
ylabel("$\\frac{d\\lvert C\\rvert^{2}}{dw}$ error");
xlabel("Frequency");
legend("Response","Upper PCLS constraint","Lower PCLS constraint");
legend("location","southwest");
legend("boxoff");
legend("right");
print(strcat(strf,"_pcls_dCsqdw_error"),"-dpdflatex");
close

% Plot both correction filter dCsqdw error and filter dAsqdw error
subplot(211)
plot(wd*0.5/pi,[dCsqdw2,Cdu,Cdl]-Cd)
axis([0 fdp 0.01*[-1,1]])
grid("on");
ylabel("$\\frac{d\\lvert C\\rvert^{2}}{dw}$ error");
subplot(212)
plot(wd*0.5/pi,[dAsqdw2,Ddu,Ddl]-Dd)
axis([0 fdp 0.01*[-1,1]])
grid("on");
ylabel("$\\frac{d\\lvert A\\rvert^{2}}{dw}$ error");
xlabel("Frequency");
print(strcat(strf,"_pcls_dCsqdw_dAsqdw_error"),"-dpdflatex");
close

% Plot sensitivity of response to direct form coefficients of correction filter
[A2_D,B2_D,C2_D,D2_D,dA2_Ddx,dB2_Ddx,dC2_Ddx,dD2_Ddx]=tf2Abcd(N2,D2);
[H2_D,dH2_Ddw,dH2_Ddx,d2H2_Ddwdx]= ...
  Abcd2H(wa,A2_D,B2_D,C2_D,D2_D,dA2_Ddx,dB2_Ddx,dC2_Ddx,dD2_Ddx);
[Csq2_D,gradCsq2_D]=H2Asq(H2_D,dH2_Ddx);
[P2_D,gradP2_D]=H2P(H2_D(Rap,:),dH2_Ddx(Rap,:));
[T2_D,gradT2_D]=H2T(H2_D(Rap,:),dH2_Ddw(Rap,:), ...
                    dH2_Ddx(Rap,:),d2H2_Ddwdx(Rap,:));
subplot(311);
plot(wa(Rap)*0.5/pi,gradCsq2_D(Rap,:));
strP=sprintf("Direct form correction filter coefficient sensitivity");
title(strP);
ylabel("$\\nabla_{\\chi}\\lvert C\\left(\\chi,\\omega\\right)\\rvert^{2}$");
grid("on");
subplot(312);
plot(wp*0.5/pi,gradP2_D);
ylabel("$\\nabla_{\\chi}P\\left(\\chi,\\omega\\right)$");
grid("on");
subplot(313);
plot(wt*0.5/pi,gradT2_D);
ylabel("$\\nabla_{\\chi}T\\left(\\chi,\\omega\\right)$");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_direct_sensitivity"),"-dpdflatex");
close

% Plot sensitivity of response to schur coefficients of correction filter
subplot(311);
plot(wa(Rap)*0.5/pi,gradCsq2(Rap,:));
strP=sprintf("Tapped Schur lattice correction filter coefficient sensitivity");
title(strP);
ylabel("$\\nabla_{\\chi}\\lvert C\\left(\\chi,\\omega\\right)\\rvert^{2}$");
grid("on");
subplot(312); 
plot(wp*0.5/pi,gradP2c);
ylabel("$\\nabla_{\\chi}P\\left(\\chi,\\omega\\right)$");
grid("on");
subplot(313);
plot(wt*0.5/pi,gradT2c);
ylabel("$\\nabla_{\\chi}T\\left(\\chi,\\omega\\right)$");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_schur_sensitivity"),"-dpdflatex");
close

%
% Simulation
%
exact=false;
nbits=12
nscale=2^(nbits-1)
ndigits=3
% Make a quantised noise signal
nsamples=2^14;
randn("seed",0xdeadbeef);
u=randn(nsamples,1)-0.5;
uscale=0.25;
u=uscale*u/std(u);
u=round(u*nscale);
% Quantise filter coefficients
if exact==true
 ;
elseif ndigits ~= 0 
  kf = flt2SD(k2, nbits, ndigits);
  cf = flt2SD(c2, nbits, ndigits);
else
  kf = round(k2*nscale)/nscale;
  cf = round(c2*nscale)/nscale;
endif
% Calculate noise gain
[kf_A,kf_B,kf_C,kf_D] = schurOneMlattice2Abcd(kf,epsilon2,p_ones,cf);
[Kf,Wf] = KW(kf_A,kf_B,kf_C,kf_D);
ngf=Abcd2ng(kf_A,kf_B,kf_C,kf_D);
fid=fopen(strcat(strf,"_ngf.tab"),"wt");
fprintf(fid,"%4.2f",ngf);
fclose(fid);
% Filter with lattice structure and truncated coefficients
[~,y,xx]=schurOneMlatticeFilter(kf,epsilon2,p_ones,cf,u,"none");
[~,yf,xxf]=schurOneMlatticeFilter(kf,epsilon2,p_ones,cf,u,"round");
% Remove initial transient
n60=p2n60(D2);
Rn60=(n60+1):length(u);
ub=u(Rn60);
yb=y(Rn60);
xxb=xx(Rn60,:);
yfb=yf(Rn60);
xxfb=xxf(Rn60,:);
% Check output round-off noise variance
delta=1;
est_varyd=(1+(ngf*delta*delta))/12;
printf("est_varyd=%6.4f\n",est_varyd);
fid=fopen(strcat(strf,"_est_varyd.tab"),"wt");
fprintf(fid,"%6.4f",est_varyd);
fclose(fid);
varyd=var(yb-yfb);
printf("varyd=%6.4f\n",varyd);
fid=fopen(strcat(strf,"_varyd.tab"),"wt");
fprintf(fid,"%6.4f",varyd);
fclose(fid);
% Check state variable std. deviation
stdxxfb=std(xxfb)(:)';
print_polynomial(stdxxfb,"stdxxfb","%6.2f");
print_polynomial(stdxxfb,"stdxxfb", ...
                 strcat(strf,"_stdxxfb.tab"),"%6.2f");
est_stdxxfb=sqrt(diag(Kf)(:)')*nscale*uscale;
print_polynomial(est_stdxxfb,"est_stdxxfb","%6.2f");
print_polynomial(est_stdxxfb,"est_stdxxfb", ...
                 strcat(strf,"_est_stdxxfb.tab"),"%6.2f");
% Plot frequency response for the Schur lattice implemetation
nfpts=1024;
nppts=(0:511)';
fb=nppts/nfpts;
wb=2*pi*fb;
Hfb=crossWelch(ub,yfb,nfpts);
Csqb=schurOneMlatticeAsq(wb,k2,epsilon2,p2,c2);
Pb=schurOneMlatticeP(wb,k2,epsilon2,p2,c2);
Pd=wb*(tp-0.5);
subplot(211)
plot(fb,sqrt(Csqb(:)),"-",fb,abs(Hfb(:)),"-.");
axis([0 0.5 0 0.6])
grid("on");
ylabel("Amplitude");
legend("Exact","12-bit,3-S-D");
legend("location","east");
legend("boxoff");
legend("right");
subplot(212)
plot(fb,unwrap(Pb+Pd)/pi,"-",fb,unwrap(arg(Hfb(:))+Pd)/pi,"-.");
grid("on");
axis([0 fap 1+0.004*[-1,1]])
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
print(strcat(strf,"_schur_lattice_correction_simulation"),"-dpdflatex");
close

%
% Save results
%
print_polynomial(N0,"N0");
print_polynomial(N0,"N0",strcat(strf,"_N0_coef.m"));
print_polynomial(D0R,"D0R");
print_polynomial(D0R,"D0R",strcat(strf,"_D0R_coef.m"));
print_polynomial(k0,"k0");
print_polynomial(k0,"k0",strcat(strf,"_k0_coef.m"));
print_polynomial(epsilon0,"epsilon0");
print_polynomial(epsilon0,"epsilon0",strcat(strf,"_epsilon0_coef.m"));
print_polynomial(p0,"p0");
print_polynomial(p0,"p0",strcat(strf,"_p0_coef.m"));
print_polynomial(c0,"c0");
print_polynomial(c0,"c0",strcat(strf,"_c0_coef.m"));
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
fprintf(fid,"rho=%g %% Constraint on reflection coefficients\n",rho);
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
fprintf(fid, ...
        "cpr=%g %% Correction filter pass band dCsqdw peak-to-peak ripple\n", ...
        cpr);
fprintf(fid,"cn=%d %% Correction filter pass band dCsqdw w exponent\n",cn);
fprintf(fid,"Wdp=%g %% Correction filter pass band dCsqdw weight\n",Wdp);
fclose(fid);

eval(sprintf(["save %s.mat ftol ctol n fap fas Arp Wap Art Wat Ars Was ", ...
              "tp tpr Wtp pp ppr Wpp cpr cn Wdp ", ...
              "N0 D0 k0 epsilon0 p0 c0 k2 epsilon2 p2 c2 N2 D2"], ...
             strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
