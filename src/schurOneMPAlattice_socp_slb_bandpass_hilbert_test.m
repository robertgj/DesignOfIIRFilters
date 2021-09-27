% schurOneMPAlattice_socp_slb_bandpass_hilbert_test.m
% Copyright (C) 2017-2021 Robert G. Jenssen

test_common;

delete("schurOneMPAlattice_socp_slb_bandpass_hilbert_test.diary");
delete("schurOneMPAlattice_socp_slb_bandpass_hilbert_test.diary.tmp");
diary schurOneMPAlattice_socp_slb_bandpass_hilbert_test.diary.tmp

tic;


tol=1e-4
ctol=1e-5
maxiter=2000
verbose=false
strf="schurOneMPAlattice_socp_slb_bandpass_hilbert_test";

%
% Initial coefficients from tarczynski_parallel_allpass_bandpass_hilbert_test.m
%
tarczynski_parallel_allpass_bandpass_hilbert_test_Da0_coef;
tarczynski_parallel_allpass_bandpass_hilbert_test_Db0_coef;

% Lattice decomposition of D1_0, D2_0
[A1k0,A1epsilon0,A1p0,~] = tf2schurOneMlattice(flipud(Da0),Da0);
[A2k0,A2epsilon0,A2p0,~] = tf2schurOneMlattice(flipud(Db0),Db0);

%
% Band-pass filter specification for parallel all-pass filters
%
difference=true
rho=0.999
m1=length(Da0)-1
m2=length(Db0)-1
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=0.2
dBas=30 
Wap=1
Watl=1e-3
Watu=1e-3
Wasl=1000
Wasu=1000
ftpl=0.11
ftpu=0.19
td=16
tdr=td/200
Wtp=10
fppl=0.11
fppu=0.19
pd=3.5 % Initial phase offset in multiples of pi radians
pdr=1/500 % Peak-to-peak phase ripple in multiples of pi radians
Wpp=2000

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
Td=td*ones(size(wt),1);
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wt=Wtp*ones(size(wt),1);

% Desired pass-band phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=wa(nppl:nppu);
Pd=(pd*pi)-(td*wp);
Pdu=Pd+(pdr*pi/2);
Pdl=Pd-(pdr*pi/2);
%Wp=[zeros(nppl-1,1);Wpp*ones(nppu-nppl+1,1);zeros(n-nppu,1)];
Wp=Wpp*ones(nppu-nppl+1,1);

%
% Relative errors
%
EsqA0sl=schurOneMPAlatticeEsq ...
         (A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference, ...
          wa,Asqd,[ones(nasl,1);zeros(n-nasl,1)], ...
          wt,Td,zeros(size(wt)), ...
          wp,Pd,zeros(size(wp)))
EsqA0p=schurOneMPAlatticeEsq ...
         (A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference, ...
          wa,Asqd,[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)], ...
          wt,Td,zeros(size(wt)), ...
          wp,Pd,zeros(size(wp)))
EsqA0su=schurOneMPAlatticeEsq ...
         (A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference, ...
          wa,Asqd,[zeros(nasu-1,1);ones(n-nasu+1,1)], ...
          wt,Td,zeros(size(wt)), ...
          wp,Pd,zeros(size(wp)))
EsqT0=schurOneMPAlatticeEsq ...
        (A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference, ...
         wa,Asqd,zeros(size(wa)), ...
         wt,Td,ones(size(wt)), ...
         wp,Pd,zeros(size(wp)))
EsqP0=schurOneMPAlatticeEsq ...
        (A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference, ...
         wa,Asqd,zeros(size(wa)), ...
         wt,Td,zeros(size(wt)), ...
         wp,Pd,ones(size(wp)))

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

% Linear constraints
dmax=0.05;
k0=[A1k0(:);A2k0(:)];
k_u=rho*ones(size(k0));
k_l=-k_u;
k_active=find(k0~=0);

%
% Plot initial response
%
Asq0=schurOneMPAlatticeAsq(wa,A1k0,A1epsilon0,A1p0, ...
                           A2k0,A2epsilon0,A2p0,difference);
T0=schurOneMPAlatticeT(wa,A1k0,A1epsilon0,A1p0, ...
                       A2k0,A2epsilon0,A2p0,difference);
P0=schurOneMPAlatticeP(wa,A1k0,A1epsilon0,A1p0, ...
                       A2k0,A2epsilon0,A2p0,difference);
subplot(311);
plot(wa*0.5/pi,10*log10(abs(Asq0)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("Initial parallel all-pass bandpass Hilbert");
title(strt);
subplot(312);
plot(wa*0.5/pi,mod((P0+(td*wa))/pi,2));
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 1.498 1.502]);
grid("on");
subplot(313);
plot(wa*0.5/pi,T0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 15.5 16.5]);
grid("on");
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

%
% SOCP PCLS
%
[A1k,A2k,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                         A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                         difference,k_u,k_l,k_active,dmax, ...
                         wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                         wp,Pd,Pdu,Pdl,Wp,maxiter,tol,ctol,verbose);
if feasible == 0 
  error("A1k,A2k(PCLS) infeasible");
endif
% Recalculate A1epsilon, A1p, A2epsilon and A2p
A1d=schurOneMAPlattice2tf(A1k,A1epsilon0,A1p0);
A1d=A1d(:);
A2d=schurOneMAPlattice2tf(A2k,A2epsilon0,A2p0);
A2d=A2d(:);
[A1k,A1epsilon,A1p,~]=tf2schurOneMlattice(flipud(A1d),A1d);
[A2k,A2epsilon,A2p,~]=tf2schurOneMlattice(flipud(A2d),A2d);

% Find response
Asq12=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
T12=schurOneMPAlatticeT(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
P12=schurOneMPAlatticeP(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);

% Plot response
subplot(311);
plot(wa*0.5/pi,10*log10(abs(Asq12)));
ylabel("Amplitude(dB)");
axis([0 0.5 -40 5]);
grid("on");
strt=sprintf("Parallel all-pass bandpass Hilbert : m1=%d,m2=%d,dBap=%g,dBas=%g",
             m1,m2,dBap,dBas);
title(strt);
subplot(312);
plot(wa*0.5/pi,mod((P12+(td*wa))/pi,2));
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 0 2]);
grid("on");
subplot(313);
plot(wa*0.5/pi,T12);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 20]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
minf=min([fapl,ftpl,fppl]);
maxf=max([fapu,ftpu,fppu]);
subplot(311);
plot(wa*0.5/pi,10*log10(abs(Asq12)));
ylabel("Amplitude(dB)");
axis([minf maxf -2*dBap dBap]);
grid("on");
title(strt);
subplot(312);
plot(wa*0.5/pi,mod((P12+(td*wa))/pi,2));
ylabel("Phase(rad./$\\pi$)");
axis([minf maxf mod(pd-pdr,2) mod(pd+pdr,2)]);
grid("on");
subplot(313);
plot(wa*0.5/pi,T12);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([minf maxf td-tdr td+tdr]);
grid("on");
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Plot poles and zeros
zplane(roots(flipud(A1d)),roots(A1d));
title("Allpass filter 1");
print(strcat(strf,"_A1pz"),"-dpdflatex");
close
zplane(roots(flipud(A2d)),roots(A2d));
title("Allpass filter 2");
print(strcat(strf,"_A2pz"),"-dpdflatex");
close

% Amplitude, delay and phase at local peaks
Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=schurOneMPAlatticeAsq(wAsqS,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
printf("A1,A2:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("A1,A2:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

T=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMPAlatticeT(wTS,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
printf("A1,A2:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("A1,A2:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

P=schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
vPl=local_max(Pdl-P);
vPu=local_max(P-Pdu);
wPS=unique([wp(vPl);wp(vPu);wp([1,end])]);
PS=schurOneMPAlatticeP(wPS,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
printf("A1,A2:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("A1,A2:PS=[ ");printf("%f ",(PS+(wPS*td))'/pi);printf(" (rad./pi)\n");

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"m1=%d %% Allpass model filter 1 denominator order\n",m1);
fprintf(fid,"m2=%d %% Allpass model filter 2 denominator order\n",m2);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n",difference);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"rho=%f %% Constraint on all-pass pole radius\n",rho);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"fapl=%g %% Pass band amplitude response lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Pass band amplitude response upper edge\n",fapu);
fprintf(fid,"dBap=%f %% Pass band amplitude response ripple(dB)\n",dBap);
fprintf(fid,"Wap=%d %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"Watl=%d %% Lower transition band amplitude response weight\n",Watl);
fprintf(fid,"Watu=%d %% Upper transition band amplitude response weight\n",Watu);
fprintf(fid,"fasl=%g %% Stop band amplitude response lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Stop band amplitude response upper edge\n",fasu);
fprintf(fid,"dBas=%f %% Stop band amplitude response ripple(dB)\n",dBas);
fprintf(fid,"Wasl=%d %% Lower stop band amplitude response weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Upper stop band amplitude response weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Pass band group-delay response lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band group-delay response upper edge\n",ftpu);
fprintf(fid,"td=%f %% Pass band nominal group-delay response(samples)\n",td);
fprintf(fid,"tdr=%f %% Pass band group-delay response ripple(samples)\n",tdr);
fprintf(fid,"Wtp=%d %% Pass band group-delay response weight\n",Wtp);
fprintf(fid,"fppl=%g %% Pass band phase response lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Pass band phase response upper edge\n",fppu);
fprintf(fid,"pd=%f %% Pass band nominal phase response(rad./pi)\n",mod(pd,2));
fprintf(fid,"pdr=%f %% Pass band phase response ripple(rad./pi)\n",pdr);
fprintf(fid,"Wpp=%d %% Pass band phase response weight\n",Wpp);
fclose(fid);

print_polynomial(A1k,"A1k");
print_polynomial(A1k,"A1k",strcat(strf,"_A1k_coef.m"));
print_polynomial(A1epsilon,"A1epsilon");
print_polynomial(A1epsilon,"A1epsilon",strcat(strf,"_A1epsilon_coef.m"),"%2d");
print_polynomial(A1p,"A1p");
print_polynomial(A1p,"A1p",strcat(strf,"_A1p_coef.m"));
print_polynomial(A2k,"A2k");
print_polynomial(A2k,"A2k",strcat(strf,"_A2k_coef.m"));
print_polynomial(A2epsilon,"A2epsilon");
print_polynomial(A2epsilon,"A2epsilon",strcat(strf,"_A2epsilon_coef.m"),"%2d");
print_polynomial(A2p,"A2p");
print_polynomial(A2p,"A2p",strcat(strf,"_A2p_coef.m"));

save schurOneMPAlattice_socp_slb_bandpass_hilbert_test.mat ...
     n m1 m2 difference tol ctol rho  ...
     fapl fapu dBap Wap Watl Watu ...
     fasl fasu dBas Wasl Wasu ...
     ftpl ftpu td tdr Wtp ...
     fppl fppu pd pdr Wpp ...
     Da0 Db0 A1k A1epsilon A1p A2k A2epsilon A2p

% Done
toc;
diary off
movefile schurOneMPAlattice_socp_slb_bandpass_hilbert_test.diary.tmp ...
         schurOneMPAlattice_socp_slb_bandpass_hilbert_test.diary;
