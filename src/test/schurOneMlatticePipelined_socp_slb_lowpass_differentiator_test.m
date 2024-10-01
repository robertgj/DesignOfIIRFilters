% schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test.m
% Copyright (C) 2024 Robert G. Jenssen

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
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(N0,D0);
k0=k0(:);c0=c0(:);epsilon0=epsilon0(:);p0=p0(:);c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kk0=k0(1:(Nk-1)).*k0(2:Nk);
Nkk=length(kk0);
ck0=c0(2:Nk).*k0(2:Nk);
Nck=length(ck0);
Nx=Nk+Nc+Nkk+Nck;

% Low-pass differentiator filter specification
fap=0.18;fas=0.3;
Arp=0.004;Art=0.005;Ars=0.003;Wap=1;Wat=0.0001;Was=1;
ftp=fap;td=length(N0)-2;tdr=0.01;Wtp=1;
fpp=fap;pp=1.5;ppr=0.0002;Wpp=1;
fdp=fap;dpr=0.04;Wdp=1;

% Frequency points
n=1000;
w=pi*(1:(n-1))'/n;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);
ntp=ceil(ftp*n/0.5);
npp=ceil(fpp*n/0.5);
ndp=ceil(fdp*n/0.5);

% Pass and transition band amplitudes of combined filters
wa=w;
Ad=[wa(1:nap)/2;zeros(n-1-nap,1)];
Adu=[wa(1:nas-1)/2; zeros(n-nas,1)] + ...
    [(Arp/2)*ones(nap,1);(Art/2)*ones((nas-nap-1),1);Ars*ones(n-nas,1)];
Adl=Ad-[(Arp/2)*ones(nap,1);zeros(n-1-nap,1)];
Adl(find(Adl<=0))=0;
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas,1)];
% Amplitude response of (1-z^-1)
Azm1=2*sin(wa/2);

% Group delay of combined filters
wt=w(1:ntp);
Td=td*ones(size(wt));
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wt=Wtp*ones(size(wt));
% Group delay response of (1-z^-1)
Tzm1=0.5;

% Phase response of combined filters
wp=w(1:npp);
Pd=(pp*pi)-(wp*td);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));
% Phase response of (1-z^-1)
Pzm1=(pi/2)-(wp/2);

% dAsqdw response of correction filter
wd=wa(1:ndp);
dAsqdwd=((Ad(1:ndp)./Azm1(1:ndp)).^2).*((2./wd)-cot(wd/2));
dAsqdwdu=dAsqdwd+(dpr/2);
dAsqdwdl=dAsqdwd-(dpr/2);
Wd=Wdp*ones(size(wd));
% dAsqdw response of (1-z^-1)
dAsqdwzm1=2*sin(wd);

% Coefficient constraints
dmax=0; % For compatibility with SQP
rho=127/128;
kc_u=[rho*ones(Nk,1);10*ones(Nc,1);rho*ones(Nkk,1);10*ones(Nck,1)];
kc_l=-kc_u;
kc_active=[1:(Nkk+Nc+Nkk),(Nk+Nc+Nkk+1):2:Nx]';

% Sanity check
nachk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Ad(nachk)=[");printf("%g ",Ad(nachk));printf(" ]\n");
printf("Adu(nachk)=[");printf("%g ",Adu(nachk));printf(" ]\n");
printf("Adl(nachk)=[");printf("%g ",Adl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");

% Calculate the initial response of combined filters
Asq0=schurOneMlatticePipelinedAsq(wa,k0,epsilon0,c0,kk0,ck0);
A0=sqrt(Asq0).*Azm1;
P0=schurOneMlatticePipelinedP(wp,k0,epsilon0,c0,kk0,ck0) + Pzm1;
T0=schurOneMlatticePipelinedT(wt,k0,epsilon0,c0,kk0,ck0) + Tzm1;
% Calculate the initial response of correction filter
dAsqdw0=schurOneMlatticePipelineddAsqdw(wd,k0,epsilon0,c0,kk0,ck0);

%
% MMSE pass
%
printf("\nMMSE pass :\n");
feasible=false;
[k1,c1,kk1,ck1,opt_iter,func_iter,feasible] = ...
schurOneMlatticePipelined_socp_mmse([], ...
   k0,epsilon0,c0,kk0,ck0,kc_u,kc_l,kc_active,dmax, ...
   wa,(Ad./Azm1).^2,(Adu./Azm1).^2,(Adl./Azm1).^2,Wa, ...
   wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
   wp,Pd-Pzm1,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
   wd,dAsqdwd,dAsqdwdu,dAsqdwdl,Wd, ...
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
   wa,(Ad./Azm1).^2,(Adu./Azm1).^2,(Adl./Azm1).^2,Wa, ...
   wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
   wp,Pd-Pzm1,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
   wd,dAsqdwd,dAsqdwdu,dAsqdwdl,Wd, ...
   maxiter,ftol,ctol,verbose);
if feasible == 0
  error("k2 (PCLS) infeasible");
endif

% Calculate the overall responses
Asq2=schurOneMlatticePipelinedAsq(wa,k2,epsilon0,c2,kk2,ck2);
A2=sqrt(Asq2).*Azm1;
P2=schurOneMlatticePipelinedP(wp,k2,epsilon0,c2,kk2,ck2) + Pzm1;
T2=schurOneMlatticePipelinedT(wt,k2,epsilon0,c2,kk2,ck2) + Tzm1;
dAsqdw2=schurOneMlatticePipelineddAsqdw(wd,k2,epsilon0,c2,kk2,ck2);

% Plot response errors
subplot(411);
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
axis(ax(1),[0 0.5 0.004*[-1,1]]);
axis(ax(2),[0 0.5 0.004*[-1,1]]);
grid("on");
strP=sprintf("Lowpass differentiator response errors : \
fap=%g,Arp=%g,fas=%g,Ars=%g,td=%g,tdr=%g,ppr=%g",fap,Arp,fas,Ars,td,tdr,ppr);
title(strP);
ylabel("Amplitude");
subplot(412);
plot(wp*0.5/pi,([P2 Pdl Pdu]-Pd)/pi);
axis([0 0.5 ppr*[-1,1]]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
subplot(413);
plot(wt*0.5/pi,[T2 Tdl Tdu]-td);
axis([0 0.5 tdr*[-1,1]]);
grid("on");
ylabel("Delay(samples)");
subplot(414);
plot(wd*0.5/pi,[dAsqdw2 dAsqdwdl dAsqdwdu]-dAsqdwd);
axis([0 0.5 0.04*[-1,1]]);
grid("on");
ylabel("dAsqdw");
xlabel("Frequency");
print(strcat(strf,"_pcls_error"),"-dpdflatex");
close

% Pole-zero plot
[A,B,C,dd]=schurOneMlatticePipelined2Abcd(k2,epsilon0,c2,kk2,ck2);
[N2,D2]=Abcd2tf(A,B,C,dd);
D2=D2(1:length(D0));
zplane(qroots(conv(N2,[1,-1])),qroots(D2));
print(strcat(strf,"_pcls_pz"),"-dpdflatex");
close

% Check transfer function
HH=freqz(N2,D2,wa);
if max(abs((abs(HH).^2)-Asq2)) > 20*eps
  error("max(abs((abs(HH).^2)-Asq2)) > 20*eps");
endif

% Save results
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
fprintf(fid,"Ars=%g %% Amplitude stop band peak ripple\n",Ars);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"td=%g %% Pass band group delay\n",td);
fprintf(fid,"tdr=%g %% Pass band group delay peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"pp=%g %% Nominal pass band phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

eval(sprintf(strcat("save %s.mat ftol ctol n fap fas Arp Ars td tdr pp ppr",
                    " Wap Wat Was Wtp Wpp N0 D0 k0 epsilon0 p0 c0 kk0 ck0",
                    " k2 c2 kk2 ck2 N2 D2"),strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
