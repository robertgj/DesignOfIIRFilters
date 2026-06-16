% schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_bandpass_hilbert_test.m
%
% Design a band-pass Hilbert filter implemented as a doubly-pipelined
% parallel all-pass Schur one-multiplier lattice in series with a
% parallel all-pass half-band anti-aliasing filter. The doubly-pipelined
% parallel all-pass bandpass Hilbert implementation in
% schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq.m etc adds a z^2 delay
% for convenience (all coefficients are in the transition matrix).
%
% This script takes a long time to run!

% Copyright (C) 2026 Robert G. Jenssen

test_common;

pkg load optim;

strf=["schurOneMPAlatticeDoublyPipelinedAntiAliased", ...
      "_socp_slb_bandpass_hilbert_test"];

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

%
% Options
%
tol=1e-10;
ftol=1e-3
ctol=1e-4
maxiter=4000
verbose=false
do_profiling=false
use_best_filter_found=true
if use_best_filter_found
  warning(["Reporting the best filter found so far. \n", ...
           "Set \"use_best_filter_found=false\" to re-run."]);
endif

%
% Band-pass Hilbert filter specification
%
R=2;
difference=true;
Ni=5; % Initial low-pass filter order
fasl=0.05,fapl=0.1,fapu=0.2,fasu=0.25,fasuu=0.3
dBap=0.4,dBasl=40,dBasu=20,dBasuu=40
Wasl=100,Watl=0.01,Wap=1,Watu=0.01,Wasu=0.01
fppl=0.1,fppu=0.2,pp=3.5,ppr=0.006,Wpp=10
ftpl=0.1,ftpu=0.2,tp=16,tpr=0.4,Wtp=10
fdpl=0.1,fdpu=0.2,dp=0,dpr=10,Wdp=0.01
% Group delay response of z^-2
Tz2=2;
% Half-band Butterworth anti-aliasing filter
maa=11;
faap=0.25;

%
% Initial filters from tarczynski_parallel_allpass_bandpass_hilbert_R2_test.m
%

% Doubly-pipelined parallel all-pass band-pass Hilbert filter
tarczynski_parallel_allpass_bandpass_hilbert_R2_test_Da0_coef;Da0=Da0(:)';
tarczynski_parallel_allpass_bandpass_hilbert_R2_test_Db0_coef;Db0=Db0(:)';
% Convert the R=2 band-pass Hilbert filter to parallel Schur lattice filters
[A1k0,~,~,~]=tf2schurOneMlattice(fliplr(Da0),Da0);
[A2k0,~,~,~]=tf2schurOneMlattice(fliplr(Db0),Db0);
NA1k=length(A1k0);
NA2k=length(A2k0);

% Half-band Butterworth anti-aliasing filter
[Naa,Daa]=butter(maa,faap*2);
[Aaa1_0,Aaa2_0]=tf2pa(Naa,Daa);
[Aaa1k0,~,~,~]=tf2schurOneMlattice(fliplr(Aaa1_0),Aaa1_0);
[Aaa2k0,~,~,~]=tf2schurOneMlattice(fliplr(Aaa2_0),Aaa2_0);
% The anti-aliasing filter is assumed to be Butterworth half-band (ie:R=2)!
Aaa1k0(1:2:end)=0;
Aaa2k0(1:2:end)=0;
Aaa1kones=ones(size(Aaa1k0));
Aaa2kones=ones(size(Aaa2k0));
NAaa1k=length(Aaa1k0);
NAaa2k=length(Aaa2k0);

% Reflection coefficient constraint
rho=127/128;
dmax=inf; % For compatibility with SQP

% Frequency points
n=1000;
w=pi*(0:(n-1))'/n;

% Pass and transition band amplitudes of combined filters
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
naap=floor(n*faap/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
nasuu=floor(n*fasuu/0.5)+1;
wa=w;
Asqd=[zeros(napl-1,1); ...
      ones(napu-napl+1,1); ...
      zeros(length(wa)-napu,1)];
Asqdu=[(10^(-dBasl/10))*ones(nasl,1); ...
       ones(nasu-nasl-1,1); ...
       (10^(-dBasu/10))*ones(nasuu-nasu,1); ...
       (10^(-dBasuu/10))*ones(length(wa)-nasuu+1,1)];
Asqdl=[zeros(napl-1,1); ...
       (10^(-dBap/10))*ones(napu-napl+1,1); ...
       zeros(length(wa)-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(length(wa)-nasu+1,1)];

% Phase response of combined filters
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=w(nppl:nppu);
Pd=(pp*pi)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));
% Phase response of z^-2
Pz2=-(wp*Tz2);

% Pass-band group delay response of combined filters
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
wt=w(ntpl:ntpu);
Td=tp*ones(ntpu-ntpl+1,1);
Tdu=(tp+(tpr/2))*ones(ntpu-ntpl+1,1);
Tdl=(tp-(tpr/2))*ones(ntpu-ntpl+1,1);
Wt=Wtp*ones(size(wt));

% dAsqdw response of combined filters
ndpl=floor(n*fdpl/0.5);
ndpu=ceil(n*fdpu/0.5);
wd=w(ndpl:ndpu);
dp=0;
Dd=dp*ones(size(wd));
Ddu=Dd+(dpr/2);
Ddl=Dd-(dpr/2);
Wd=Wdp*ones(size(wd));

% Sanity checks
nachk=[1, ...
       nasl-1,nasl,nasl+1,napl-1,napl,napl+1, ...
       napu-1,napu,napu+1,nasu-1,nasu,nasu+1, ...
       n-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Asqd(nachk)=[");printf("%g ",Asqd(nachk));printf(" ]\n");
printf("Asqdu(nachk)=[");printf("%g ",Asqdu(nachk));printf(" ]\n");
printf("Asqdl(nachk)=[");printf("%g ",Asqdl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");
npchk=[1,length(wp)];
printf("npchk=[");printf("%d ",npchk);printf(" ]\n");
printf("wp(npchk)*0.5/pi=[");printf("%g ",wp(npchk)*0.5/pi);printf(" ]\n");
printf("Pd(npchk)=[");printf("%g ",Pd(npchk));printf(" ]\n");
printf("Pdu(npchk)=[");printf("%g ",Pdu(npchk));printf(" ]\n");
printf("Pdl(npchk)=[");printf("%g ",Pdl(npchk));printf(" ]\n");
printf("Wp(npchk)=[");printf("%g ",Wp(npchk));printf(" ]\n");
ntchk=[1,length(wt)];
printf("ntchk=[");printf("%d ",ntchk);printf(" ]\n");
printf("wt(ntchk)*0.5/pi=[");printf("%g ",wt(ntchk)*0.5/pi);printf(" ]\n");
printf("Td(ntchk)=[");printf("%g ",Td(ntchk));printf(" ]\n");
printf("Tdu(ntchk)=[");printf("%g ",Tdu(ntchk));printf(" ]\n");
printf("Tdl(ntchk)=[");printf("%g ",Tdl(ntchk));printf(" ]\n");
printf("Wt(ntchk)=[");printf("%g ",Wt(ntchk));printf(" ]\n");

%
% Coefficient constraints
%
k_u=rho*ones(NA1k+NA2k+NAaa1k+NAaa2k,1);
k_l=-k_u;

%
% Optimisation
%
if use_best_filter_found == true
  A1k2 = [   0.3111367513,   0.5163401027,   0.2159463379,   0.2273139277 ]';
  A2k2 = [   0.6790060761,   0.0195542108,   0.4008769139,   0.4571588246, ... 
             0.2564567428,   0.2651313254 ]';
  Aaa1k2 = [ 0.0000000000,   0.9060096239,   0.0000000000,   0.2483775651, ... 
             0.0000000000,   0.0281009916 ]';
  Aaa2k2 = [ 0.0000000000,   0.5962212566,   0.0000000000,   0.0723849755, ... 
             0.0000000000 ]';
else

  if do_profiling
    profile on;
  endif
  
  % MMSE pass
  printf("\nMMSE pass :\n");
  feasible=false;
  k_active=find(abs([A1k0,A2k0]) > 1e-10);
  [A1k1,A2k1,Aaa1k1,Aaa2k1,socp_iter,func_iter,feasible]= ...
    schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_mmse ...
      ([], ...
       A1k0,A2k0,difference,Aaa1k0,Aaa2k0, ...
       k_u,k_l,k_active,dmax, ...
       wa,Asqd,Asqdu,Asqdl,Wa, ...
       wt,Td+Tz2,Tdu+Tz2,Tdl+Tz2,Wt, ...
       wp,Pd+Pz2,Pdu+Pz2,Pdl+Pz2,Wp, ...
       wd,Dd,Ddu,Ddl,Wd, ...
       maxiter,ftol,ctol,verbose);
  if feasible == 0
    error("MMSE infeasible");
  endif
  
  Asq1=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
         (wa,A1k1,A2k1,difference,Aaa1k1,Aaa2k1);
  T1=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
       (wt,A1k1,A2k1,difference,Aaa1k1,Aaa2k1);
  P1=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
       (wp,A1k1,A2k1,difference,Aaa1k1,Aaa2k1);
  dAsqdw1=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
            (wd,A1k1,A2k1,difference,Aaa1k1,Aaa2k1);

  % PCLS pass
  printf("\nPCLS pass :\n");
  feasible=false;
  k_active=find(abs([A1k0,A2k0,Aaa1k0,Aaa2k0]) > tol);
  [A1k2,A2k2,Aaa1k2,Aaa2k2,slb_iter,socp_iter,func_iter,feasible]= ...
    schurOneMPAlatticeDoublyPipelinedAntiAliased_slb ...
      (@schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_mmse, ...
       A1k1,A2k1,difference,Aaa1k1,Aaa2k1,k_u,k_l,k_active,dmax, ...
       wa,Asqd,Asqdu,Asqdl,Wa, ...
       wt,Td+Tz2,Tdu+Tz2,Tdl+Tz2,Wt, ...
       wp,Pd+Pz2,Pdu+Pz2,Pdl+Pz2,Wp, ...
       wd,Dd,Ddu,Ddl,Wd, ...
       maxiter,ftol,ctol,verbose);
  if feasible == 0
    error("PCLS infeasible");
  endif

  if do_profiling
    profile off;
    T=profile("info");
    profshow(T);
  endif

endif

%
% Plot results
%

% Calculate anti-aliasing filter PCLS response
Aaasq2=schurOneMPAlatticeAsq ...
         (w,Aaa1k2,Aaa1kones,Aaa1kones,Aaa2k2,Aaa2kones,Aaa2kones);
Taa2=schurOneMPAlatticeT ...
       (w,Aaa1k2,Aaa1kones,Aaa1kones,Aaa2k2,Aaa2kones,Aaa2kones);

% Calculate overall PCLS response
Asq2=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
     (wa,A1k2,A2k2,difference,Aaa1k2,Aaa2k2);
T2=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
     (wt,A1k2,A2k2,difference,Aaa1k2,Aaa2k2);
P2=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
     (wp,A1k2,A2k2,difference,Aaa1k2,Aaa2k2);
dAsqdw2=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
     (wd,A1k2,A2k2,difference,Aaa1k2,Aaa2k2);

% Plot anti-aliasing PCLS amplitude response
subplot(211)
ax=plotyy(w(1:naap)*0.5/pi,   10*log10(Aaasq2(1:naap,:)), ...
          w(naap:end)*0.5/pi, 10*log10(Aaasq2(naap:end,:)));
axis(ax(1),[0 0.5 -0.15 0.05]);
axis(ax(2),[0 0.5 -60 -20]);
grid("on")
tstr=sprintf(["Bandpass Hilbert anti-aliasing filter PCLS response : ", ...
              "fasl=%g,fapl=%g,fapu=%g,fasu=%g,", ...
              "dBap=%g,dBasl=%g,dBasu=%g,tp=%g"], ...
             fasl,fapl,fapu,fasu,dBap,dBasl,dBasu,tp);
title(tstr);
ylabel("Amplitude(dB)");
zticks([]);
subplot(212)
plot(w*0.5/pi,Taa2)
axis([0 0.5 0 20])
grid("on")
ylabel("Delay(samples)");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_antialias_response"),"-dpdflatex");
close

% Plot overall PCLS response
subplot(311);
[ax,hp,hs]=plotyy(wa*0.5/pi,10*log10([Asq2,Asqdl,Asqdu]), ...
                  wa*0.5/pi,10*log10([Asq2,Asqdl,Asqdu]));
axis(ax(2),[0 0.5 -0.6 0.2]);
axis(ax(1),[0 0.5 -50 -30]);
grid("on");
strP=sprintf(["Bandpass Hilbert R=2 filter PCLS response : ", ...
              "fasl=%g,fapl=%g,fapu=%g,fasu=%g,", ...
              "dBap=%g,dBasl=%g,dBasu=%g,tp=%g,tpr=%g,ppr=%g"], ...
             fasl,fapl,fapu,fasu,dBap,dBasl,dBasu,tp,tpr,ppr);
title(strP);
% Copy line colour
hpc=get(hp,"color");
for p=1:length(hpc)
  set(hs(p),"color",hpc{p});
endfor
ylabel("Ampl.(dB)","color","black");
zticks([]);
subplot(312);
plot(wp*0.5/pi,mod((unwrap([P2 Pdl+Pz2 Pdu+Pz2])+(wp*(tp+Tz2)))/pi,2));
axis([0 0.5 mod(pp,2)+(ppr*[-1,1])]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
zticks([]);
subplot(313);
plot(wt*0.5/pi,[T2 Tdl+Tz2 Tdu+Tz2]);
axis([0 0.5 tp+Tz2+(tpr*[-1,1])]);
grid("on");
ylabel("Delay(samples)");
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
close

%
% Save results
%

% Convert to transfer functions
[AA1k2,BA1k2,CA1k2,DA1k2] = schurOneMAPlatticeDoublyPipelined2Abcd(A1k2);
[~,DA1k2]=Abcd2tf(AA1k2,BA1k2,CA1k2,DA1k2);
[AA2k2,BA2k2,CA2k2,DA2k2] = schurOneMAPlatticeDoublyPipelined2Abcd(A2k2);
[~,DA2k2]=Abcd2tf(AA2k2,BA2k2,CA2k2,DA2k2);
DAaa1k2=schurOneMAPlattice2tf(Aaa1k2);
DAaa2k2=schurOneMAPlattice2tf(Aaa2k2);
Naa2=(conv(fliplr(DAaa1k2),DAaa2k2)+conv(fliplr(DAaa2k2),DAaa1k2))/2;
Daa2=conv(DAaa1k2,DAaa2k2);                        
N2=conv((conv(fliplr(DA1k2),DA2k2)-conv(fliplr(DA2k2),DA1k2))/2,Naa2);
D2=conv(conv(DA1k2,DA2k2),Daa2);
% Sanity check
H2c=freqz(N2,D2,wa);
Asq2c=abs(H2c).^2;
if max(abs(Asq2-Asq2c)) > tol
  error("max(abs(Asq2-Asq2c))(%g*tol) > tol",max(abs(Asq2-Asq2c))/tol);
endif
T2c=delayz(N2,D2,wt);
if max(abs(T2-T2c)) > tol
  error("max(abs(T2-T2c))(%g*tol) > tol",max(abs(T2-T2c))/tol);
endif

% Save coefficients
print_polynomial(A1k2,"A1k2");
print_polynomial(A1k2,"A1k2",strcat(strf,"_A1k2_coef.m"));
print_polynomial(A2k2,"A2k2");
print_polynomial(A2k2,"A2k2",strcat(strf,"_A2k2_coef.m"));

print_polynomial(Aaa1k2,"Aaa1k2");
print_polynomial(Aaa1k2,"Aaa1k2",strcat(strf,"_Aaa1k2_coef.m"));
print_polynomial(Aaa2k2,"Aaa2k2");
print_polynomial(Aaa2k2,"Aaa2k2",strcat(strf,"_Aaa2k2_coef.m"));

print_polynomial(DA1k2,"DA1k2");
print_polynomial(DA1k2,"DA1k2",strcat(strf,"_DA1k2_coef.m"));
print_polynomial(DA2k2,"DA2k2");
print_polynomial(DA2k2,"DA2k2",strcat(strf,"_DA2k2_coef.m"));

print_polynomial(DAaa1k2,"DAaa1k2");
print_polynomial(DAaa1k2,"DAaa1k2",strcat(strf,"_DAaa1k2_coef.m"));
print_polynomial(DAaa2k2,"DAaa2k2");
print_polynomial(DAaa2k2,"DAaa2k2",strcat(strf,"_DAaa2k2_coef.m"));

print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"maxiter=%d %% Maximum iterations\n",maxiter);
fprintf(fid,"tol=%g %% Tolerance on results\n",tol);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"rho=%g %% Constraint on reflection coefficients\n",rho);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"maa=%d %% Order of half-band anti-aliasing filter\n",maa);
fprintf(fid,"NAaa1k=%d %% Order of anti-aliasing all-pass filter 1\n",NAaa1k);
fprintf(fid,"NAaa2k=%d %% Order of anti-aliasing all-pass filter 2\n",NAaa2k);
fprintf(fid,"NA1k=%d %% Order of band-pass Hilbert all-pass filter 1\n",NA1k);
fprintf(fid,"NA2k=%d %% Order of band-pass Hilbert all-pass filter 2\n",NA2k);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"Wasl=%g %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Watl=%g %% Amplitude lower transition band weight\n",Watl);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Watu=%g %% Amplitude upper transition band weight\n",Watu);
fprintf(fid,"Wasu=%g %% Amplitude upper stop band weight\n",Wasu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple(dB)\n",dBap);
fprintf(fid,"dBasl=%g %% Amplitude lower stop band peak ripple(dB)\n",dBasl);
fprintf(fid,"dBasu=%g %% Amplitude upper stop band peak ripple(dB)\n",dBasu);
fprintf(fid,"fppl=%g %% Pass band phase lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Pass band phase lower edge\n",fppu);
fprintf(fid,"pp=%g %% Nominal pass band phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Pass band phase peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Pass band phase weight\n",Wpp);
fprintf(fid,"ftpl=%g %% Pass band group delay lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band group delay upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Pass band group delay(samples)\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"fdpl=%g %% Pass band dAsqdw lower edge\n",fppl);
fprintf(fid,"fdpu=%g %% Pass band dAsqdw upper edge\n",fppu);
fprintf(fid,"dp=%g %% Nominal pass band dAsqdw\n",dp);
fprintf(fid,"dpr=%g %% Pass band dAsqdw peak-to-peak ripple\n",dpr);
fprintf(fid,"Wdp=%g %% Pass band dAsqdw weight\n",Wdp);
fclose(fid);

eval(sprintf(["save %s.mat tol ftol ctol rho n use_best_filter_found ", ...
              "maa fasl fapl fapu fasu dBap Wap dBasl dBasu Wasl Wasu ", ...
              "fppl fppu pp ppr Wpp ftpl ftpu tp tpr Wtp ", ...
              "fdpl fdpu dp dpr Wdp ", ...
              "Da0 Db0 A1k0 A2k0 Aaa1k0 Aaa2k0 ", ...
              "A1k2 A2k2 Aaa1k2 Aaa2k2 DA1k2 DA2k2 Naa2 Daa2 N2 D2"], ...
              strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
