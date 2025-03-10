% schurOneMlattice_socp_slb_lowpass_differentiator_test.m
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="schurOneMlattice_socp_slb_lowpass_differentiator_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-5
ctol=ftol/100
maxiter=20000
verbose=false

% Initial 1-1/z correction filter 
tarczynski_lowpass_differentiator_test_D0_coef;
tarczynski_lowpass_differentiator_test_N0_coef;

% Correction filter order
nN=length(N0)-1;

% Convert transfer function to one-multiplier Schur lattice
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(N0,D0);
k0=k0(:);epsilon0=epsilon0(:);p0=p0(:);c0=c0(:);

% Low-pass differentiator filter specification
fap=0.3;fas=0.4;
Arp=0.004;Art=0.02;Ars=0.02;Wap=1;Wat=0.0001;Was=0.1;
ftp=fap;tp=nN-1;tpr=0.04;Wtp=0.1;
fpp=fap;pp=1.5;ppr=0.0008;Wpp=1;
fdp=fap;dpr=0.04;Wdp=0.1;

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
Azm1sq=Azm1.^2;
dAzm1sqdw=2.*sin(wa);
Ad=[wa(1:nap)/2;zeros(n-1-nap,1)];
Asqd=Ad.^2;
dAsqddw=Ad;
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
wd=w(1:ndp);
Dd=dAsqddw(1:ndp);
Ddu=Dd+(dpr/2);
Ddl=Dd-(dpr/2);
Wd=Wdp*ones(size(wd));
Cd=(Dd-(Asqd(1:ndp).*cot(Ad(1:ndp))))./Azm1sq(1:ndp);
Cdu=Cd+((dpr/2)./Azm1sq(1:ndp));
Cdl=Cd-((dpr/2)./Azm1sq(1:ndp));

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
Csq0=schurOneMlatticeAsq(wa,k0,epsilon0,p0,c0);
A0=sqrt(Csq0).*Azm1;
P0=schurOneMlatticeP(wp,k0,epsilon0,p0,c0) + Pzm1;
T0=schurOneMlatticeT(wt,k0,epsilon0,p0,c0) + Tzm1;
dCsqdw0=schurOneMlatticedAsqdw(wd,k0,epsilon0,p0,c0);
dAsqdw0=(Csq0(1:ndp).*dAzm1sqdw(1:ndp))+(dCsqdw0.*(Azm1sq(1:ndp)));

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

% Pole-zero plot
[N2,D2]=schurOneMlattice2tf(k2,epsilon0,p0,c2);
zplane(qroots(conv(N2,[1,-1])),qroots(D2));
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Recalculate epsilon, p and c
printf("\nBefore recalculating epsilon and c:\n");
print_polynomial(epsilon0,"epsilon0");
print_polynomial(c2,"c2");
[k2r,epsilon2,p2,c2]=tf2schurOneMlattice(N2,D2);
k2r=k2r(:);epsilon2=epsilon2(:);p2=p2(:);c2=c2(:);
if max(abs(k2-k2r))>2*eps
  error("max(abs(k2-k2r))(%g*eps)>2*eps",max(abs(k2-k2r))/eps);
endif

% Calculate the overall response
Csq2=schurOneMlatticeAsq(wa,k2,epsilon2,p2,c2);
A2c=sqrt(Csq2);
A2=A2c.*Azm1;
wp=w(1:npp);
Pzm1=(pi/2)-(wp/2);
P2c=schurOneMlatticeP(wp,k2,epsilon2,p2,c2);
P2=P2c + Pzm1;
T2c=schurOneMlatticeT(wt,k2,epsilon2,p2,c2);
T2=T2c + Tzm1;
dCsqdw2=schurOneMlatticedAsqdw(wd,k2,epsilon2,p2,c2);
dAsqdw2=(Csq2(1:ndp).*dAzm1sqdw(1:ndp))+(dCsqdw2.*(Azm1sq(1:ndp)));

% Plot correction filter response
subplot(411);
plot(wa*0.5/pi,A2c);
axis([0 0.5 0 1]);
grid("on");
strP=sprintf(["Lowpass differentiator correction filter : ", ...
 "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g"],fap,Arp,fas,Ars,tp);
title(strP);
ylabel("Amplitude");
subplot(412);
plot(wp*0.5/pi,(P2c+(wp*(tp-0.5)))/pi);
axis([0 0.5 1+(0.001*[-1,1])]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
subplot(413);
plot(wt*0.5/pi,T2c);
axis([0 0.5 (tp-0.5)+tpr*[-1,1]]);
grid("on");
ylabel("Delay(samples)");
subplot(414);
plot(wd*0.5/pi,dCsqdw2);
axis([0 0.5 -0.1 0.3]);
grid("on");
ylabel("dAsqdw");
xlabel("Frequency");
print(strcat(strf,"_correction_response"),"-dpdflatex");
close

% Plot response
subplot(311);
rap=1:nap;
ras=nas:(n-1);
[ax,ha,hs]=plotyy(wa(rap)*0.5/pi,[A2(rap),Adl(rap),Adu(rap)], ...
                  wa(ras)*0.5/pi,[A2(ras),Adl(ras),Adu(ras)]);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 0 1]);
axis(ax(2),[0 0.5 0.01*[0,1]]);
grid("on");
strP=sprintf(["Lowpass differentiator response : ", ...
 "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"],fap,Arp,fas,Ars,tp,tpr,ppr);
title(strP);
ylabel("Amplitude");
subplot(312);
plot(wp*0.5/pi,([P2 Pdl Pdu]+(wp*tp))/pi);
axis([0 0.5 pp+0.001*[-1,1]]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
subplot(313);
plot(wt*0.5/pi,[T2 Tdl Tdu]);
axis([0 0.5 tp+tpr*[-1,1]]);
grid("on");
ylabel("Delay(samples)");
xlabel("Frequency");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot response errors
subplot(311);
[ax,ha,hs]=plotyy(wa(rap)*0.5/pi,[A2(rap),Adl(rap),Adu(rap)]-Ad(rap), ...
                  wa(ras)*0.5/pi,[A2(ras),[Adl(ras),Adu(ras)]]);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 0.004*[-1,1]]);
axis(ax(2),[0 0.5 0.02*[-1,1]]);
strP=sprintf(["Differentiator PCLS error : ", ...
 "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"],fap,Arp,fas,Ars,tp,tpr,ppr);
title(strP);
ylabel("Amplitude");
grid("on");
subplot(312);
plot(wp*0.5/pi,([P2 Pdl Pdu]-Pd)/pi);
axis([0 0.5 0.001*[-1,1]]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[T2 Tdl Tdu]-tp);
axis([0 0.5 0.04*[-1,1]]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_error_response"),"-dpdflatex");
close

% Check transfer function
HH=freqz(N2,D2,wa);
if max(abs((abs(HH).^2)-Csq2)) > 100*eps
  error("max(abs((abs(HH).^2)-Csq2)) > 100*eps");
endif

%
% Simulation sanity check
%
nsamples=2^24;
n60=p2n60(D2);
t=(1:(n60+nsamples))';
rand ("seed",0xDEADBEEF);
u=rand(n60+nsamples,1)-0.5;
u=0.25*u/std(u);
% Filter
y=filter(conv(N2,[1,-1]),D2,u);
if 0
  [~,ycorr,~]=schurOneMlatticeFilter(k2,epsilon2,p2,c2,u,"none");
  yy=filter([1,-1],1,ycorr);
  if max(abs(y-yy))>10*eps
    error("max(abs(y-yy))(%g)>10*eps",max(abs(y-yy))/eps);
  endif
endif
% Frequency response
u60=u(n60:end);
y60=y(n60:end);
nTxy=2^12;
Txy=crossWelch(u60,y60,nTxy);
% Plot simulated frequency response
Tf=(0:((nTxy/2)-1))/nTxy;
Tw=2*pi*Tf;
nTap=ceil(fap*nTxy)+1;
rTap=1:nTap;
nTas=floor(fas*nTxy)+1;
rTas=nTas:length(Txy);
TPp=-pi/2;
subplot(211)
ax=plotyy(Tf(rTap),(abs(Txy(rTap)))-(pi*Tf(rTap)), Tf(rTas),abs(Txy(rTas)));
axis(ax(1),[0 0.5 0.004*[-1,1]]);
axis(ax(2),[0 0.5 0.02*[-1,1]]);
grid("on");
ylabel("Amplitude");
title("Simulated differentiator PCLS error");
subplot(212)
plot(Tf(rTap),unwrap(arg(Txy(rTap))+(Tw(rTap)*tp)-TPp)/pi)
axis([0 0.5 0.001*[-1,1]]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
print(strcat(strf,"_simulated_error_response"),"-dpdflatex");
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
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"ftp=%g %% Delay pass band upper edge\n",ftp);
fprintf(fid,"tp=%g %% Pass band group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"fpp=%g %% Phase pass band upper edge\n",fpp);
fprintf(fid,"pp=%g %% Nominal pass band phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fprintf(fid,"fdp=%g %% dAsqdw pass band upper edge\n",fdp);
fprintf(fid,"dpr=%g %% dAsqdw pass band peak-to-peak ripple\n",dpr);
fprintf(fid,"Wdp=%g %% dAsqdw pass band weight\n",Wdp);
fclose(fid);

eval(sprintf(["save %s.mat ftol ctol n fap fas Arp Ars tp tpr pp ppr fdp dpr ", ...
 "Wap Wat Was Wtp Wpp Wdp N0 D0 k0 epsilon0 p0 c0 k2 epsilon2 p2 c2 N2 D2"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
