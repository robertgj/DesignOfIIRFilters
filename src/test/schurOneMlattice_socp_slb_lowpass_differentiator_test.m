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
fdp=0.1;cpr=0.02;cn=4;Wdp=0.1;

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
Rap=1:nap;
Ras=nas:length(wa);
Fz=[1;-1];
Az=2*sin(wa/2);
Azsq=Az.^2;
dAzsqdw=2.*sin(wa);
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
Tz=0.5;
Td=tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));

% Phase response with z^{-1}-1 removed
wp=w(1:npp);
Pz=(pi/2)-(wp/2);
Pd=(pp*pi)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% dAsqdw response
Rdp=1:ndp;
wd=w(Rdp);
Wd=Wdp*ones(size(wd));
Dd=dAsqddw(Rdp);
Cd=(Dd-(Asqd(Rdp).*cot(Ad(Rdp))))./Azsq(Rdp);
Cderr=(cpr/2)*((Rdp(:)/ndp).^cn);
Cdu=Cd+Cderr;
Cdl=Cd-Cderr;
Dd=dAsqddw(Rdp);
Dderr=(Cderr.*Azsq(Rdp));
Ddu=Dd+Dderr;
Ddl=Dd-Dderr;

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
A0c=sqrt(Csq0);
A0=A0c.*Az;
P0c=schurOneMlatticeP(wp,k0,epsilon0,p0,c0);
P0=P0c+Pz;
T0c=schurOneMlatticeT(wt,k0,epsilon0,p0,c0);
T0=T0c+Tz;
dCsqdw0=schurOneMlatticedAsqdw(wd,k0,epsilon0,p0,c0);
dAsqdw0=(Csq0(Rdp).*dAzsqdw(Rdp))+(dCsqdw0.*(Azsq(Rdp)));

%
% PCLS pass
%
printf("\nPCLS pass :\n");
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
[N2_ep0,D2_ep0]=schurOneMlattice2tf(k2,epsilon0,p0,c2);
[k2r,epsilon2,p2,c2]=tf2schurOneMlattice(N2_ep0,D2_ep0);
k2r=k2r(:);epsilon2=epsilon2(:);p2=p2(:);c2=c2(:);
if max(abs(k2-k2r))>2*eps
  error("max(abs(k2-k2r))(%g*eps)>2*eps",max(abs(k2-k2r))/eps);
endif
[N2,D2]=schurOneMlattice2tf(k2,epsilon2,p2,c2);

% Calculate the overall response
Csq2=schurOneMlatticeAsq(wa,k2,epsilon2,p2,c2);
A2c=sqrt(Csq2);
A2=A2c.*Az;
wp=w(1:npp);
Pz=(pi/2)-(wp/2);
P2c=schurOneMlatticeP(wp,k2,epsilon2,p2,c2);
P2=P2c + Pz;
T2c=schurOneMlatticeT(wt,k2,epsilon2,p2,c2);
T2=T2c + Tz;
dCsqdw2=schurOneMlatticedAsqdw(wd,k2,epsilon2,p2,c2);
dAsqdw2=(Csq2(Rdp).*dAzsqdw(Rdp))+(dCsqdw2.*(Azsq(Rdp)));

% Check transfer function
HH=freqz(N2,D2,wa);
if max(abs((abs(HH).^2)-Csq2)) > 100*eps
  error("max(abs((abs(HH).^2)-Csq2)) > 100*eps");
endif

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

% Plot filter dAsqdw error
plot(wd*0.5/pi,[dAsqdw2,Ddl,Ddu]-Dd)
axis([0 fdp 0.004*[-1,1]])
strP=sprintf(["Differentiation filter dAsqdw error : ", ...
              "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"], ...
             fap,Arp,fas,Ars,tp,tpr,ppr);
title(strP);
ylabel("dAsqdw error");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_dAsqdw_error"),"-dpdflatex");
close

%% Plot correction filter dCsqdw error
plot(wd*0.5/pi,[dCsqdw2,Cdl,Cdu]-Cd)
axis([0 fdp 0.02*[-1,1]])
strP=sprintf(["Correction filter dCsqdw error : ", ...
              "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"], ...
             fap,Arp,fas,Ars,tp,tpr,ppr);
title(strP);
ylabel("dCsqdw error");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_dCsqdw_error"),"-dpdflatex");
close

% Plot response
subplot(311);
[ax,ha,hs]=plotyy(wa(Rap)*0.5/pi,[A2(Rap),Adl(Rap),Adu(Rap)], ...
                  wa(Ras)*0.5/pi,[A2(Ras),Adl(Ras),Adu(Ras)]);
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
[ax,ha,hs]=plotyy(wa(Rap)*0.5/pi,[A2(Rap),Adl(Rap),Adu(Rap)]-Ad(Rap), ...
                  wa(Ras)*0.5/pi,[A2(Ras),[Adl(Ras),Adu(Ras)]]);
% Copy line colour
hac=get(ha,"color");
for c=1:3
  set(hs(c),"color",hac{c});
endfor
axis(ax(1),[0 0.5 0.004*[-1,1]]);
axis(ax(2),[0 0.5 0.02*[-1,1]]);
strP=sprintf(["Differentiator PCLS : ", ...
 "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"],fap,Arp,fas,Ars,tp,tpr,ppr);
title(strP);
ylabel("Amplitude error");
grid("on");
subplot(312);
plot(wp*0.5/pi,([P2 Pdl Pdu]+(wp*tp))/pi);
axis([0 0.5 pp+(0.001*[-1,1])]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[T2 Tdl Tdu]);
axis([0 0.5 tp+(0.04*[-1,1])]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_error_response"),"-dpdflatex");
close

% Pole-zero plot
zplane(qroots(conv(N2(:),Fz)),qroots(D2(:)));
print(strcat(strf,"_pz"),"-dpdflatex");
close

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
fprintf(fid,"rho=%g %% Constraint on reflection coefficients\n",rho);
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
fprintf(fid, ...
        "cpr=%g %% Correction filter dCsqdw pass band peak-to-peak ripple\n", ...
        cpr);
fprintf(fid,"cn=%d %% Correction filter pass band dCsqdw w exponent\n",cn);
fprintf(fid,"Wdp=%g %% Correction filter dCsqdw pass band weight\n",Wdp);
fclose(fid);

eval(sprintf(["save %s.mat ftol ctol rho n ", ...
              "fap fas Arp Wap Art Wat Ars Was ", ...
              "tp tpr Wtp pp ppr Wpp fdp cpr cn Wdp ", ...
              "N0 D0 k0 epsilon0 p0 c0 k2 epsilon2 p2 c2 N2 D2"], ...
             strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
