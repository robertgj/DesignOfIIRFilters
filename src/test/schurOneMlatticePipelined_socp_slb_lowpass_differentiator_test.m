% schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

ftol=1e-3
ctol=5e-8
maxiter=20000
verbose=false

% 1-1/z correction filter from tarczynski_lowpass_differentiator_test.m
tarczynski_lowpass_differentiator_test_D0_coef;
tarczynski_lowpass_differentiator_test_N0_coef;

% Correction filter order
nN=length(N0)-1;

% Convert transfer function to one-multiplier Schur lattice
[k0,epsilon0,c0,kk0,ck0]=tf2schurOneMlatticePipelined(N0,D0);
Nk=length(k0);
Nc=length(c0);
Nkk=length(kk0);
Nck=length(ck0);
Nx=Nk+Nc+Nkk+Nck;

% Low-pass differentiator filter specification
fap=0.3;fas=0.4;
Arp=0.004;Art=0.004;Ars=0.008;Wap=1;Wat=0.0001;Was=1;
fpp=fap;pp=1.5;ppr=0.0008;Wpp=1;
ftp=fap;tp=nN-1;tpr=0.04;Wtp=0.1;
fdp=0.1;cpr=0.02;cn=4;Wdp=0.1;

% Frequency points
n=400;
w=pi*(1:(n-1))'/n;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);
ntp=ceil(ftp*n/0.5);
npp=ceil(fpp*n/0.5);
ndp=ceil(fdp*n/0.5);

% Pass and transition band amplitudes of combined filters
wa=w;
Fz=[1;-1];
Ad=[wa(1:nap)/2;zeros(n-nap-1,1)];
Adu=[wa(1:(nas-1))/2;zeros(n-nas,1)]+ ...
    [(Arp/2)*ones(nap,1);(Art/2)*ones((nas-nap-1),1);Ars*ones(n-nas,1)];
Adl=Ad-[(Arp/2)*ones(nap,1);zeros(n-nap-1,1)];
Adl(find(Adl<=0))=0;
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas,1)];
% Amplitude response of (1-z^-1)
Az=2*sin(wa/2);

% Phase response of combined filters
wp=w(1:npp);
Pd=(pp*pi)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));
% Phase response of (1-z^-1)
Pz=(pi/2)-(wp/2);

% Group delay of combined filters
wt=w(1:ntp);
Td=tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));
% Group delay response of (1-z^-1)
Tz=0.5;

% dCsqdw response of correction filter
Rdp=1:ndp;
wd=wa(Rdp);
dCsqdwd=((Ad(Rdp)./Az(Rdp)).^2).*((2./wd)-cot(wd/2));
dCsqdwErr=(cpr/2)*((Rdp(:)/ndp).^cn);
dCsqdwdu=dCsqdwd+(dCsqdwErr/2);
dCsqdwdl=dCsqdwd-(dCsqdwErr/2);
Wd=Wdp*ones(size(wd));
% dCsqdw response of (1-z^-1)
dCsqdwz=2*sin(wd);

% Coefficient constraints
dmax=0; % For compatibility with SQP
rho=0.999;
kc_u=[rho*ones(Nk,1);10*ones(Nc,1);rho*ones(Nkk,1);10*ones(Nck,1)];
kc_l=-kc_u;
kc_active=find([k0(:);c0(:);kk0(:);ck0(:)]);

% Sanity check
nachk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Ad(nachk)=[");printf("%g ",Ad(nachk));printf(" ]\n");
printf("Adu(nachk)=[");printf("%g ",Adu(nachk));printf(" ]\n");
printf("Adl(nachk)=[");printf("%g ",Adl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");

% Calculate the initial response of combined filters
Csq0=schurOneMlatticePipelinedAsq(wa,k0,epsilon0,c0,kk0,ck0);
A0c=sqrt(Csq0);
A0=A0c.*Az;
P0c=schurOneMlatticePipelinedP(wp,k0,epsilon0,c0,kk0,ck0);
P0=P0c+Pz;
T0c=schurOneMlatticePipelinedT(wt,k0,epsilon0,c0,kk0,ck0);
T0=T0c+Tz;
% Calculate the initial dCsqdw response of correction filter
dCsqdw0=schurOneMlatticePipelineddAsqdw(wd,k0,epsilon0,c0,kk0,ck0);

%
% MMSE pass
%
printf("\nMMSE pass :\n");
feasible=false;
[k1,c1,kk1,ck1,opt_iter,func_iter,feasible] = ...
schurOneMlatticePipelined_socp_mmse([], ...
   k0,epsilon0,c0,kk0,ck0,kc_u,kc_l,kc_active,dmax, ...
   wa,(Ad./Az).^2,(Adu./Az).^2,(Adl./Az).^2,Wa, ...
   wt,Td-Tz,Tdu-Tz,Tdl-Tz,Wt, ...
   wp,Pd-Pz,Pdu-Pz,Pdl-Pz,Wp, ...
   wd,dCsqdwd,dCsqdwdu,dCsqdwdl,Wd, ...
   maxiter,ftol,ctol,verbose);
if feasible == 0
  error("k2 (MMSE) infeasible");
endif

%
% PCLS pass
%
printf("\nPCLS pass :\n");
feasible=false;
[k2,c2,kk2,ck2,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMlatticePipelined_slb ...
  (@schurOneMlatticePipelined_socp_mmse, ...
   k1,epsilon0,c1,kk1,ck1,kc_u,kc_l,kc_active,dmax, ...
   wa,(Ad./Az).^2,(Adu./Az).^2,(Adl./Az).^2,Wa, ...
   wt,Td-Tz,Tdu-Tz,Tdl-Tz,Wt, ...
   wp,Pd-Pz,Pdu-Pz,Pdl-Pz,Wp, ...
   wd,dCsqdwd,dCsqdwdu,dCsqdwdl,Wd, ...
   maxiter,ftol,ctol,verbose);
if feasible == 0
  error("k2 (PCLS) infeasible");
endif

% Calculate the overall responses
Csq2=schurOneMlatticePipelinedAsq(wa,k2,epsilon0,c2,kk2,ck2);
A2c=sqrt(Csq2);
A2=A2c.*Az;
P2c=schurOneMlatticePipelinedP(wp,k2,epsilon0,c2,kk2,ck2);
P2=P2c+Pz;
T2c=schurOneMlatticePipelinedT(wt,k2,epsilon0,c2,kk2,ck2);
T2=T2c+Tz;
dCsqdw2c=schurOneMlatticePipelineddAsqdw(wd,k2,epsilon0,c2,kk2,ck2);

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
plot(wd*0.5/pi,dCsqdw2c);
axis([0 0.5 -0.05 0.15]);
grid("on");
ylabel("dCsqdw");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_pcls_correction"),"-dpdflatex");
close

% Plot correction filter dCsqdw error response
plot(wd*0.5/pi,[dCsqdw2c,dCsqdwdl,dCsqdwdu]-dCsqdwd);
grid("on");
strP=sprintf(["Lowpass differentiator dCsqdw error : ", ...
 "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g"],fap,Arp,fas,Ars,tp);
title(strP);
ylabel("dCsqdw error");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_pcls_dCsqdw_error"),"-dpdflatex");
close

% Plot response
subplot(311);
[ax,ha,hs]=plotyy ...
             (wa(1:nap)*0.5/pi, ...
              [A2(1:nap),Adl(1:nap),Adu(1:nap)], ...
              wa(nas:end)*0.5/pi, ...
              [A2(nas:end),[Adl(nas:end),Adu(nas:end)]]);
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
zticks([]);
print(strcat(strf,"_pcls_response"),"-dpdflatex");
close

% Plot response errors
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
axis(ax(1),[0 0.5 Arp*[-1,1]]);
axis(ax(2),[0 0.5 0.01*[-1,1]]);
grid("on");
strP=sprintf(["Lowpass differentiator response errors : ", ...
 "fap=%g,Arp=%g,fas=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"],fap,Arp,fas,Ars,tp,tpr,ppr);
title(strP);
ylabel("Amplitude error");
subplot(312);
plot(wp*0.5/pi,([P2 Pdl Pdu]+(wp*tp))/pi);
axis([0 0.5 pp+(0.001*[-1,1])]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
subplot(313);
plot(wt*0.5/pi,[T2 Tdl Tdu]);
axis([0 0.5 tp+(tpr*[-1,1])]);
grid("on");
ylabel("Delay(samples)");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_pcls_error"),"-dpdflatex");
close

% Pole-zero plot
[A,B,C,dd]=schurOneMlatticePipelined2Abcd(k2,epsilon0,c2,kk2,ck2);
[N2,D2]=Abcd2tf(A,B,C,dd);
D2=D2(1:length(D0));
zplane(qroots(conv(N2(:),Fz)),qroots(D2));
zticks([]);
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

% Check transfer function
HH=freqz(N2,D2,wa);
if max(abs((abs(HH).^2)-Csq2)) > 20*eps
  error("max(abs((abs(HH).^2)-Csq2)) > 20*eps");
endif

% Save results
print_polynomial(epsilon0,"epsilon0");
print_polynomial(epsilon0,"epsilon0",strcat(strf,"_epsilon0_coef.m"));
print_polynomial(k2,"k2");
print_polynomial(k2,"k2",strcat(strf,"_k2_coef.m"));
print_polynomial(c2,"c2");
print_polynomial(c2,"c2",strcat(strf,"_c2_coef.m"));
print_polynomial(kk2,"kk2");
print_polynomial(kk2,"kk2",strcat(strf,"_kk2_coef.m"));
print_polynomial(ck2,"ck2");
print_polynomial(ck2,"ck2",strcat(strf,"_ck2_coef.m"));

print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"maxiter=%d %% Maximum iterations\n",maxiter);
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
fprintf(fid,"Ars=%g %% Amplitude stop band peak ripple\n",Ars);
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
fprintf(fid,"cn=%d %% Correction filter pass band dCsqdw w exponent\n",cn);
fprintf(fid,"Wdp=%g %% Correction filter dCsqdw pass band weight\n",Wdp);
fclose(fid);

eval(sprintf(["save %s.mat ftol ctol n ", ...
              "fap fas Arp Art Ars tp tpr pp ppr fdp cpr cn ", ...
              "Wap Wat Was Wtp Wpp Wdp ", ...
              "N0 D0 k0 epsilon0 c0 kk0 ck0 ", ...
              "k2 c2 kk2 ck2 N2 D2"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
