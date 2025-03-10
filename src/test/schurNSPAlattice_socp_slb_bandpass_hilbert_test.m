% schurNSPAlattice_socp_slb_bandpass_hilbert_test.m
% Copyright (C) 2023-2025 Robert G. Jenssen

test_common;

strf="schurNSPAlattice_socp_slb_bandpass_hilbert_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=5000
verbose=false

%
% Initial coefficients
%
tarczynski_parallel_allpass_bandpass_hilbert_test_Da0_coef;
tarczynski_parallel_allpass_bandpass_hilbert_test_Db0_coef;
[~,~,A1s20_0,A1s00_0,A1s02_0,A1s22_0] = tf2schurNSlattice(flipud(Da0(:)),Da0(:));
[~,~,A2s20_0,A2s00_0,A2s02_0,A2s22_0] = tf2schurNSlattice(flipud(Db0(:)),Db0(:));

%
% Band-pass filter specification for parallel all-pass filters
%
tol=1e-4
ctol=tol/2
difference=true
dmax=inf;
rho=0.999
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=0.08
dBas=37
Wap=1
Watl=1e-3
Watu=1e-3
Wasl=400
Wasu=400
ftpl=0.11
ftpu=0.19
tp=16
tpr=0.008
Wtp=2
fppl=0.11
fppu=0.19
pp=3.5 % Initial phase offset in multiples of pi radians
ppr=0.002 % Peak-to-peak phase ripple in multiples of pi radians
Wpp=100

%
% Frequency vectors
%
n=1000;
wa=(0:(n-1))'*pi/n;

% Desired squared magnitude response
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Asqd=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)];
Asqdu=[(10^(-dBas/10))*ones(nasl,1); ...
       ones(nasu-nasl-1,1); ...
       (10^(-dBas/10))*ones(n-nasu+1,1)];
Asqdl=[zeros(napl-1,1);(10^(-dBap/10))*ones(napu-napl+1,1);zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];

% Desired pass-band group delay response
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
wt=wa(ntpl:ntpu);
Td=tp*ones(length(wt),1);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(length(wt),1);

% Desired pass-band phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=wa(nppl:nppu);
Pd=(pp*pi)-(tp*wp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(length(wp),1);

%
% Sanity checks
%
nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napl+1,napu-1,napu,napu+1, ...
       nasu-1,nasu,nasu+1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

nchkt=[ntpl-1,ntpl,ntpl+1,ntpu-1,ntpu,ntpu+1];
printf("0.5*wa(nchkt)'/pi=[ ");printf("%6.4g ",0.5*wa(nchkt)'/pi);printf("];\n");

nchkp=[nppl-1,nppl,nppl+1,nppu-1,nppu,nppu+1];
printf("0.5*wa(nchkp)'/pi=[ ");printf("%6.4g ",0.5*wa(nchkp)'/pi);printf("];\n");

Asq0=schurNSPAlatticeAsq(wa, ...
  A1s20_0,A1s00_0,A1s02_0,A1s22_0,A2s20_0,A2s00_0,A2s02_0,A2s22_0,difference);
T0=schurNSPAlatticeT(wt, ...
  A1s20_0,A1s00_0,A1s02_0,A1s22_0,A2s20_0,A2s00_0,A2s02_0,A2s22_0,difference);
P0=schurNSPAlatticeP(wp, ...
  A1s20_0,A1s00_0,A1s02_0,A1s22_0,A2s20_0,A2s00_0,A2s02_0,A2s22_0,difference);

% Linear constraints
A12_0=[A1s20_0(:);A1s00_0(:);A1s02_0(:);A1s22_0(:); ...
       A2s20_0(:);A2s00_0(:);A2s02_0(:);A2s22_0(:)];
sxx_u=rho*ones(size(A12_0));
sxx_l=-sxx_u;
sxx_active=find(A12_0~=0);
sxx_symmetric=true;

%
% SOCP PCLS
%
try
  feasible=false;
  [A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
   slb_iter,opt_iter,func_iter,feasible] = ...
     schurNSPAlattice_slb(@schurNSPAlattice_socp_mmse,
                          A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
                          A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
                          difference, ...
                          sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
                          wa,Asqd,Asqdu,Asqdl,Wa, ...
                          wt,Td,Tdu,Tdl,Wt, ...
                          wp,Pd,Pdu,Pdl,Wp, ...
                          maxiter,tol,ctol,verbose);
catch
  feasible = false;
  warning("Caught schurNSPAlattice_slb!");
end_try_catch
if feasible == 0 
  error("A12(pcls) infeasible");
endif

% Check symmetry
if max(abs(A1s20+A1s02))>eps
  error("max(abs(A1s20+A1s02))>eps");
endif
if max(abs(A1s00-A1s22))>eps
  error("max(abs(A1s00-A1s22))>eps");
endif
if max(abs(A2s20+A2s02))>eps
  error("max(abs(A2s20+A2s02))>eps");
endif
if max(abs(A2s00-A2s22))>eps
  error("max(abs(A2s00-A2s22))>eps");
endif

% Find response
Asq=schurNSPAlatticeAsq(wa,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                        difference);
P=schurNSPAlatticeP(wp,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                    difference);
T=schurNSPAlatticeT(wt,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                    difference);

% Plot response
subplot(311);
ax=plotyy(wa*0.5/pi,10*log10(Asq),wa*0.5/pi,10*log10(Asq));
axis(ax(1),[0 0.5 -0.1 0.1]);
axis(ax(2),[0 0.5 -60 -20]);
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf("Parallel all-pass bandpass Hilbert : dBap=%g,dBas=%g",dBap,dBas);
title(strt);
subplot(312);
plot(wp*0.5/pi,((P+(tp*wp))/pi)-pp);
ylabel("Phase error(rad./$\\pi$)");
axis([0 0.5 ((ppr/20)*[-1 1])]);
grid("on");
subplot(313);
plot(wt*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 (tp+((tpr/2)*[-1 1]))]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Check the transfer function.
% As filter order increases, schurNSlattice2Abcd() is increasingly inaccurate.
% See schurNSlattice2Abcd_test.m and compare with schurOneMlattice2Abcd_test.m
% The N2, and D2 returned here have frequency response errors.
A1d=schurNSAPlattice2tf(A1s20,A1s00,A1s02,A1s22);
A1d=A1d(:);
A2d=schurNSAPlattice2tf(A2s20,A2s00,A2s02,A2s22);
A2d=A2d(:);
N2=(conv(A1d,flipud(A2d))-conv(A2d,flipud(A1d)))/2;
D2=conv(A1d,A2d);
HH=freqz(N2,D2,wa);
if max(abs((abs(HH).^2)-Asq)) > 100*eps
  warning(["With freqz, N2 and D2, max(abs((abs(HH).^2)-Asq))(%g/eps)>100*eps\n", ...
 "   !!!! Re-write schurNSlattice2Abcd.cc with extra precision arithmetic !!!!"],
          max(abs((abs(HH).^2)-Asq))/eps);
endif
H1=freqz(flipud(A1d),A1d,wa);
H2=freqz(flipud(A2d),A2d,wa);
HH=(H1-H2)/2;
if max(abs((abs(HH).^2)-Asq)) > 100*eps
  warning(["With freqz, A1d and A2d, max(abs((abs(HH).^2)-Asq))(%g*eps)>100*eps\n", ...
 "   !!!! Re-write schurNSlattice2Abcd.cc with extra precision arithmetic !!!!"],
          max(abs((abs(HH).^2)-Asq))/eps);
endif

% Plot poles and zeros
A1d=schurNSAPlattice2tf(A1s20,A1s00,A1s02,A1s22);
A1d=A1d(:);
A2d=schurNSAPlattice2tf(A2s20,A2s00,A2s02,A2s22);
A2d=A2d(:);
zplane(qroots(flipud(A1d)),qroots(A1d));
title("Allpass filter 1");
print(strcat(strf,"_A1pz"),"-dpdflatex");
close
zplane(qroots(flipud(A2d)),qroots(A2d));
title("Allpass filter 2");
print(strcat(strf,"_A2pz"),"-dpdflatex");
close
N2=(conv(A1d,flipud(A2d))-conv(A2d,flipud(A1d)))/2;
D2=conv(A1d,A2d);
zplane(qroots(N2),qroots(D2));
title("Parallel allpass filter ");
print(strcat(strf,"_A12pz"),"-dpdflatex");

% Amplitude, delay and phase at local peaks
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=schurNSPAlatticeAsq(wAsqS, ...
                         A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,...
                         difference);
printf("A1,A2:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("A1,A2:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurNSPAlatticeT(wTS, ...
                     A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                     difference);
printf("A1,A2:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("A1,A2:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

vPl=local_max(Pdl-P);
vPu=local_max(P-Pdu);
wPS=unique([wp(vPl);wp(vPu);wp([1,end])]);
PS=schurNSPAlatticeP(wPS, ...
                     A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22, ...
                     difference);
printf("A1,A2:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("A1,A2:PS=[ ");printf("%f ",(PS+(wPS*tp))'/pi-pp);printf("] (rad./pi)\n");

% Make a quantised noise signal with standard deviation 0.25
nsamples=2^15;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=u/std(u);
% Filter
[A1yap,~,A1xx]=schurNSlatticeFilter(zeros(size(A1s20)),zeros(size(A1s20)), ...
                                    A1s20,A1s00,A1s02,A1s22,u,"none");
[A2yap,~,A2xx]=schurNSlatticeFilter(zeros(size(A2s20)),zeros(size(A2s20)), ...
                                    A2s20,A2s00,A2s02,A2s22,u,"none");
% Check state variable std. deviation
A1stdx=std(A1xx);
A2stdx=std(A2xx);
% Check simulated response
nfpts=2^11;
nppts=(0:((nfpts/2)-1));
mov_window=20;
fpts=nppts/nfpts;
Hsim=crossWelch(u,(A1yap-A2yap)/2,nfpts);
Asim=abs(Hsim);
Asim=movmean(Asim,mov_window);
subplot(311);
ax=plotyy(fpts,20*log10(Asim),fpts,20*log10(Asim));
axis(ax(1),[0 0.5 -0.1 0.1]);
axis(ax(2),[0 0.5 -60 -20]);
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf...
("Simulated parallel all-pass bandpass Hilbert (moving mean of 10 samples)");
title(strt);
subplot(312);
Psim=unwrap(arg(Hsim));
Psim=movmean(Psim,mov_window);
plot(fpts,mod(((Psim+(tp*2*pi*nppts/nfpts))/pi),1));
axis([0 0.5 0.5+((0.01)*[0 1])])
grid("on");
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency")
subplot(313);
Tsim=-diff(Psim)/((fpts(2)-fpts(1))*2*pi);
Tsim=movmean(Tsim,mov_window);
plot(fpts(2:end),Tsim);
axis([0 0.5 (tp+(0.1*[-1 1]))]);
grid("on");
ylabel("Delay(samples)");
xlabel("Frequency")
print(strcat(strf,"_sim"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen("schurNSPAlattice_socp_slb_bandpass_hilbert_test_spec.m","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"difference=%d %% difference of all-pass filters\n",difference);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"sxx_symmetric=%d %% enforce s02=-s20 and s22=s00\n",sxx_symmetric);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"dBas=%d %% amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%d %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Watl=%d %% Amplitude transition band lower weight\n",Watl);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Watu=%d %% Amplitude upper transition band weight\n",Watu);
fprintf(fid,"Wasu=%d %% Amplitude upper stop band weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fprintf(fid,"fppl=%g %% Phase pass band lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Phase pass band upper edge\n",fppu);
fprintf(fid,"pp=%g %% Nominal pass band filter phase\n",pp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple\n",ppr);
fprintf(fid,"Wpp=%d %% Phase pass band weight\n",Wpp);
fclose(fid);

print_polynomial(A1s20,"A1s20");
print_polynomial(A1s20,"A1s20",strcat(strf,"_A1s20_coef.m"));
print_polynomial(A1s00,"A1s00");
print_polynomial(A1s00,"A1s00",strcat(strf,"_A1s00_coef.m"));

print_polynomial(A2s20,"A2s20");
print_polynomial(A2s20,"A2s20",strcat(strf,"_A2s20_coef.m"));
print_polynomial(A2s00,"A2s00");
print_polynomial(A2s00,"A2s00",strcat(strf,"_A2s00_coef.m"));

print_polynomial(A1d,"A1d");
print_polynomial(A1d,"A1d",strcat(strf,"_A1d_coef.m"));
print_polynomial(A2d,"A2d");
print_polynomial(A2d,"A2d",strcat(strf,"_A2d_coef.m"));

print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

print_polynomial(A1stdx,"A1stdx");
print_polynomial(A1stdx,"A1stdx",strcat(strf,"_A1stdx.m"),"%6.4f");
print_polynomial(A2stdx,"A2stdx");
print_polynomial(A2stdx,"A2stdx",strcat(strf,"_A2stdx.m"),"%6.4f");

eval(sprintf(["save %s.mat ...\n", ...
 "     rho tol ctol difference sxx_symmetric n ...\n", ...
 "     fasl fapl fapu fasu dBap dBas Wasl Watl Wap Watu Wasu ...\n", ...
 "     ftpl ftpu tp tpr Wtp ...\n", ...
 "     fppl fppu pp ppr Wpp ...\n", ...
 "     Da0 Db0 ...\n", ...
 "     A1s20 A1s00 A1s02 A1s22 A2s20 A2s00 A2s02 A2s22 A1d A2d N2 D2"],strf));
        
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
