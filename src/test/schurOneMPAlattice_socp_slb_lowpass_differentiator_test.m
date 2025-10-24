% schurOneMPAlattice_socp_slb_lowpass_differentiator_test.m
% Copyright (C) 2025 Robert G. Jenssen
%
% The low pass differentiatot is implemented as the polyphase
% difference of order 7 and order 8 all pass filters in series
% with a zero at z=-1.

test_common;

strf="schurOneMPAlattice_socp_slb_lowpass_differentiator_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-5
ctol=ftol/100
maxiter=2000
verbose=false

% Initial filter 
tarczynski_parallel_allpass_lowpass_differentiator_test_Da0_coef;
tarczynski_parallel_allpass_lowpass_differentiator_test_Db0_coef;
polyphase=true;
difference=true;

% Convert transfer functions to one-multiplier Schur lattices
A1k0=schurdecomp(Da0);
A2k0=schurdecomp(Db0);
A1k0=A1k0(:);
A2k0=A2k0(:);
A2k0=[A2k0;0]; % Polyphase
NA1k=length(A1k0);
NA2k=length(A2k0);
Nk=NA1k+NA2k;
A1kones=ones(size(A1k0));
A2kones=ones(size(A2k0));

% Low-pass differentiator filter specification
rho=1023/1024;
fap=0.2;fas=0.4;
Arp=0.002;Ars=0.001;Wap=10;Wat=0.1;Was=1;
fpp=fap;pp=0.5;ppr=0.0008;Wpp=0.5;
ftp=fap;tp=(NA1k+NA2k)/2;tpr=0.016;Wtp=1;
fdp=fap;cpr=0.1;cn=4;Wdp=10;

% Frequency points
n=1000;
w=pi*(0:(n-1))'/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;
ntp=ceil(ftp*n/0.5)+1;
npp=ceil(fpp*n/0.5)+1;
ndp=ceil(fdp*n/0.5)+1;

% Pass and transition band amplitudes
wa=w;
Rap=1:nap;
Ras=nas:length(wa);
Fz=[1;1]/2;
Az=cos(wa/2);
Azsq=Az.^2;
dAzsqdw=-sin(wa)/2;
Ad=[wa(Rap)/2;zeros(n-nap,1)];
Asqd=Ad.^2;
dAsqddw=Ad;
Adu=[wa(1:(nas-1))/2;zeros(n-nas+1,1)]+ ...
    [(Arp/2)*ones(nas-1,1); (Ars/2)*ones(n-nas+1,1)];
Adu(find(Adu>(1-Arp)))=1-Arp;
Adl=Ad-[(Arp/2)*ones(nap,1);zeros(n-nap,1)];
Adl(find(Adl<=0))=0;
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas+1,1)];
% Sanity check
nachk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1,n];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Ad(nachk)=[");printf("%g ",Ad(nachk));printf(" ]\n");
printf("Adu(nachk)=[");printf("%g ",Adu(nachk));printf(" ]\n");
printf("Adl(nachk)=[");printf("%g ",Adl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");

% Group delay
Rtp=2:ntp;
wt=w(Rtp);
Tz=0.5*ones(size(wt));
Td=tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));

% Phase response
Rpp=2:npp;
wp=w(Rpp);
Pz=-wp/2;
Pd=(pp*pi)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% dAsqdw response
Rdp=1:ndp;
wd=w(Rdp);
Wd=Wdp*ones(size(wd));
%Cd=((Azsq(Rdp).*dAsqddw(Rdp))-(Asqd(Rdp).*dAzsqdw(Rdp)))./(Azsq(Rdp).^2);
Cd=((wa(Rdp)/2).*(sec(wa(Rdp)/2).^2)).*(1+((wa(Rdp)/2).*tan(wa(Rdp)/2)));
Cderr=(cpr/2)*((Rdp(:)/ndp).^cn);
Cdu=Cd+Cderr;
Cdl=Cd-Cderr;
Dd=dAsqddw(Rdp);
Dderr=(Cderr.*Azsq(Rdp));
Ddu=Dd+Dderr;
Ddl=Dd-Dderr;

% Coefficient constraints
dmax=inf; % For compatibility with SQP
k_u=rho*ones(Nk,1);
k_l=-k_u;
k0=[A1k0;A2k0];
k_active=find(k0~=0);

% Calculate the initial response
Csq0=schurOneMPAlatticeAsq(wa,A1k0,A1kones,A1kones, ...
                           A2k0,A2kones,A2kones,difference);
A0c=sqrt(Csq0);
A0=A0c.*Az;
P0c=schurOneMPAlatticeP(wp,A1k0,A1kones,A1kones, ...
                        A2k0,A2kones,A2kones,difference);
P0=P0c+Pz;
T0c=schurOneMPAlatticeT(wt,A1k0,A1kones,A1kones, ...
                        A2k0,A2kones,A2kones,difference);
T0=T0c+Tz;
dCsqdw0=schurOneMPAlatticedAsqdw(wd,A1k0,A1kones,A1kones, ...
                                 A2k0,A2kones,A2kones,difference);
dAsqdw0=(Csq0(Rdp).*dAzsqdw(Rdp))+(dCsqdw0.*(Azsq(Rdp)));

% Plot initial response
subplot(311);
plot(wa*0.5/pi,[A0 Ad Adl Adu]);
ylabel("Amplitude");
axis([0 0.5 0 1]);
grid("on");
strt=sprintf("Initial parallel allpass");
title(strt);
subplot(312);
plot(wp*0.5/pi,([P0 Pd Pdl Pdu]+(wp*tp))/pi);
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 pp+(0.004*[-1 1])]);
grid("on");
subplot(313);
plot(wt*0.5/pi,[T0 Td Tdl Tdu]);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 tp+0.02*[-1,1]]);
grid("on");
zticks([]);
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

%
% MMSE pass
%
printf("\nMMSE pass :\n");
feasible=false;
[A1k1,A2k1,opt_iter,func_iter,feasible] =  ...
  schurOneMPAlattice_socp_mmse ...
    ([], ...
     A1k0,A1kones,A1kones,A2k0,A2kones,A2kones, ...
     difference, ...
     k_u,k_l,k_active,dmax, ...
     wa,(Ad./Az).^2,(Adu./Az).^2,(Adl./Az).^2,Wa, ...
     wt,Td-Tz,Tdu-Tz,Tdl-Tz,Wt, ...
     wp,Pd-Pz,Pdu-Pz,Pdl-Pz,Wp, ...
     wd,Cd,Cdu,Cdl,Wd, ...
     maxiter,ftol,ctol,verbose);
if feasible == 0
  error("MMSE infeasible");
endif

%
% PCLS pass
%
printf("\nPCLS pass :\n");
feasible=false;
[A1k2,A2k2,slb_iter,opt_iter,func_iter,feasible] =  ...
  schurOneMPAlattice_slb ...
    (@schurOneMPAlattice_socp_mmse, ...
     A1k1,A1kones,A1kones,A2k1,A2kones,A2kones, ...
     difference, ...
     k_u,k_l,k_active,dmax, ...
     wa,(Ad./Az).^2,(Adu./Az).^2,(Adl./Az).^2,Wa, ...
     wt,Td-Tz,Tdu-Tz,Tdl-Tz,Wt, ...
     wp,Pd-Pz,Pdu-Pz,Pdl-Pz,Wp, ...
     wd,Cd,Cdu,Cdl,Wd, ...
     maxiter,ftol,ctol,verbose);
if feasible == 0
  error("PCLS infeasible");
endif

% Calculate the overall response
Csq2=schurOneMPAlatticeAsq(wa,A1k2,A1kones,A1kones, ...
                           A2k2,A2kones,A2kones,difference);
A2c=sqrt(Csq2);
A2=A2c.*Az;
P2c=schurOneMPAlatticeP(wp,A1k2,A1kones,A1kones, ...
                        A2k2,A2kones,A2kones,difference);
P2=P2c+Pz;
T2c=schurOneMPAlatticeT(wt,A1k2,A1kones,A1kones, ...
                        A2k2,A2kones,A2kones,difference);
T2=T2c+Tz;
dCsqdw2= ...
  schurOneMPAlatticedAsqdw(wd,A1k2,A1kones,A1kones, ...
                           A2k2,A2kones,A2kones,difference);
dAsqdw2=(Csq2(Rdp).*dAzsqdw(Rdp))+(dCsqdw2.*(Azsq(Rdp)));

% Find overall filter polynomials
[N2,D2]=schurOneMPAlattice2tf(A1k2,A1kones,A1kones, ...
                              A2k2,A2kones,A2kones,difference);

% Sanity check
Hc=freqz(conv(N2,Fz),D2,w);
if max(abs(abs(Hc)-A2)) > 1e4*eps
  error("max(abs(abs(Hc)-A2))(%g*eps) > 1e4*eps",max(abs(abs(Hc)-A2))/eps);
endif
Tc=delayz(conv(N2,Fz),D2,wt);
if max(abs(abs(Tc)-T2)) > 1e7*eps
  error("max(abs(abs(Tc)-T2))(%g*eps) > 1e7*eps",max(abs(abs(Tc)-T2))/eps);
endif

% Plot correction filter response
subplot(411);
plot(wa*0.5/pi,A2c);
axis([0 0.5 0 1.2]);
grid("on");
strP=sprintf(["Lowpass differentiator correction filter : ", ...
              "fap=%g,Arp=%g,fas=%g,Ars=%g,ppr=%g,tp=%g,tpr=%g"], ...
             fap,Arp,fas,Ars,ppr,tp,tpr);
title(strP);
ylabel("Amplitude");
subplot(412);
plot(wp*0.5/pi,(P2c+(wp*(tp-0.5)))/pi);
axis([0 0.5 pp+(0.0008*[-1,1])]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
subplot(413);
plot(wt*0.5/pi,T2c);
axis([0 0.5 (tp-0.5)+0.01*[-1,1]]);
grid("on");
ylabel("Delay(samples)");
subplot(414);
plot(wd*0.5/pi,dCsqdw2);
axis([0 0.5 0 2]);
grid("on");
ylabel("dCsqdw");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_correction_response"),"-dpdflatex");
close

% Plot filter dAsqdw error
plot(wd*0.5/pi,[dAsqdw2,Ddl,Ddu]-Dd)
axis([0 fdp 0.04*[-1,1]])
strP=sprintf(["Differentiation filter dAsqdw error : ", ...
              "fap=%g,Arp=%g,fas=%g,Ars=%g,ppr=%g,tp=%g,tpr=%g"], ...
             fap,Arp,fas,Ars,ppr,tp,tpr);
title(strP);
ylabel("dAsqdw error");
xlabel("Frequency");
grid("on");
zticks([]);
print(strcat(strf,"_dAsqdw_error"),"-dpdflatex");
close

% Plot correction filter dCsqdw error
plot(wd*0.5/pi,[dCsqdw2,Cdl,Cdu]-Cd)
axis([0 fdp 0.2*[-1,1]])
strP=sprintf(["Correction filter dCsqdw error : ", ...
              "fap=%g,Arp=%g,fas=%g,Ars=%g,ppr=%g,tp=%g,tpr=%g"], ...
             fap,Arp,fas,Ars,ppr,tp,tpr);
title(strP);
ylabel("dCsqdw error");
xlabel("Frequency");
grid("on");
zticks([]);
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
axis(ax(1),[0 0.5 0 0.8]);
axis(ax(2),[0 0.5 0 0.001]);
grid("on");
strP=sprintf(["Low pass differentiator response : ", ...
              "fap=%g,Arp=%g,fas=%g,Ars=%g,ppr=%g,tp=%g,tpr=%g"], ...
             fap,Arp,fas,Ars,ppr,tp,tpr);
title(strP);
ylabel("Amplitude");
subplot(312);
plot(wp*0.5/pi,([P2 Pdl Pdu]+(wp*tp))/pi);
axis([0 0.5 pp+0.001*[-1,1]]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
subplot(313);
plot(wt*0.5/pi,[T2 Tdl Tdu]);
axis([0 0.5 tp+0.01*[-1,1]]);
grid("on");
ylabel("Delay(samples)");
xlabel("Frequency");
zticks([]);
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
axis(ax(1),[0 0.5 0.002*[-1,1]]);
axis(ax(2),[0 0.5 0.001*[-1,1]]);
strP=sprintf(["Low pass differentiator response error : ", ...
              "fap=%g,Arp=%g,fas=%g,Ars=%g,ppr=%g,tp=%g,tpr=%g"], ...
             fap,Arp,fas,Ars,ppr,tp,tpr);
title(strP);
ylabel("Amplitude error");
grid("on");
subplot(312);
plot(wp*0.5/pi,([P2 Pdl Pdu]+(wp*tp))/pi);
axis([0 0.5 pp+(0.0008*[-1,1])]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,[T2 Tdl Tdu]);
axis([0 0.5 tp+(0.01*[-1,1])]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
zticks([]);
print(strcat(strf,"_error_response"),"-dpdflatex");
close

% Plot relative pass band response error
ha=plot(wa(Rap)*0.5/pi,([A2(Rap),Adl(Rap),Adu(Rap)]./Ad(Rap))-1);
axis([0 fap 0.004*[-1,1]]);
grid("on");
strP=sprintf(["Low pass differentiator relative response error : ", ...
              "fap=%g,Arp=%g,fas=%g,Ars=%g,ppr=%g,tp=%g,tpr=%g"], ...
             fap,Arp,fas,Ars,ppr,tp,tpr);
title(strP);
ylabel("Relative amplitude error");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_pass_relative_error_response"),"-dpdflatex");
close

% Pole-zero plot
D1k2=schurOneMAPlattice2tf(A1k2);
zplane(qroots(flipud(D1k2(:))),qroots(D1k2(:)));
zticks([]);
print(strcat(strf,"_D1k2_pz"),"-dpdflatex");
close
D2k2=schurOneMAPlattice2tf(A2k2);
D2k2(end)=0;
zplane(qroots(flipud(D2k2(:))),qroots(D2k2(:)));
zticks([]);
print(strcat(strf,"_D2k2_pz"),"-dpdflatex");
close
zplane(qroots(conv(N2(:),Fz)),qroots(D2(:)));
zticks([]);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Save results
print_polynomial(A1k2,"A1k2");
print_polynomial(A1k2,"A1k2",strcat(strf,"_A1k2_coef.m"));
print_polynomial(A2k2,"A2k2");
print_polynomial(A2k2,"A2k2",strcat(strf,"_A2k2_coef.m"));

print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"maxiter=%d %% Maximum iterations\n",maxiter);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"difference=%g %% Difference of all pass filters\n",difference);
fprintf(fid,"rho=%g %% Constraint on reflection coefficients\n",rho);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"NA1k=%d %% Allpass filter 1 order\n",NA1k);
fprintf(fid,"NA2k=%d %% Allpass filter 2 order\n",NA2k);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"Arp=%g %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
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

eval(sprintf(["save %s.mat ftol ctol n difference ", ...
              "fap fas Arp Ars Wap Wat Was ", ...
              "tp tpr Wtp pp ppr Wpp fdp cpr cn Wdp ", ...
              "Da0 Db0 A1k0 A2k0 A1k2 A2k2 N2 D2"], ...
             strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
