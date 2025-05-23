% schurOneMPAlattice_socp_slb_bandpass_hilbert_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="schurOneMPAlattice_socp_slb_bandpass_hilbert_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
verbose=false

%
% Initial coefficients from tarczynski_parallel_allpass_bandpass_hilbert_test.m
%
tarczynski_parallel_allpass_bandpass_hilbert_test_Da0_coef;
tarczynski_parallel_allpass_bandpass_hilbert_test_Db0_coef;

% Lattice decomposition of Da0, Db0
[A1k0,A1epsilon0,A1p0,~] = tf2schurOneMlattice(flipud(Da0),Da0);
[A2k0,A2epsilon0,A2p0,~] = tf2schurOneMlattice(flipud(Db0),Db0);

%
% Band-pass filter specification for parallel all-pass filters
%
tol=1e-4
ctol=4e-6
difference=true
dmax=inf;
rho=0.999
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=0.1
dBas=40
Wap=1
Watl=1e-3
Watu=1e-3
Wasl=100
Wasu=100
ftpl=0.11
ftpu=0.19
tp=16
tpr=0.02
Wtp=10
fppl=0.11
fppu=0.19
pp=3.5 % Initial phase offset in multiples of pi radians
ppr=0.0004 % Peak-to-peak phase ripple in multiples of pi radians
Wpp=200
fdpl=fapl % Pass band dAsqdw response lower edge
fdpu=fapu % Pass band dAsqdw response upper edge
dp=0      % Pass band dAsqdw response nominal value
dpr=0.4   % Pass band dAsqdw response ripple
Wdp=0.001 % Pass band dAsqdw response weight

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

% Desired pass-band dAsqdw response
ndpl=floor(n*fdpl/0.5)+1;
ndpu=ceil(n*fdpu/0.5)+1;
wd=wa(ndpl:ndpu);
Dd=dp*ones(length(wd),1);
Ddu=Dd+(dpr/2);
Ddl=Dd-(dpr/2);
Wd=Wdp*ones(length(wd),1);

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

nchkd=[ndpl-1,ndpl,ndpl+1,ndpu-1,ndpu,ndpu+1];
printf("0.5*wa(nchkd)'/pi=[ ");printf("%6.4g ",0.5*wa(nchkd)'/pi);printf("];\n");

% Linear constraints
k0=[A1k0(:);A2k0(:)];
k_u=rho*ones(size(k0));
k_l=-k_u;
k_active=find(k0~=0);

%
% SOCP PCLS
%
try
  feasible=false;
  [A1k,A2k,slb_iter,opt_iter,func_iter,feasible] = ...
    schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                           A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                           difference,k_u,k_l,k_active,dmax, ...
                           wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                           wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
                           maxiter,tol,ctol,verbose);
catch
  feasible=false;
  warning("Caught schurOneMPAlattice_slb!");
end_try_catch;
if feasible == 0 
  error("A1k,A2k(PCLS) infeasible");
endif

% Recalculate A1epsilon, A1p, A2epsilon and A2p
[A1epsilon,A1p]=schurOneMscale(A1k);
A1k=A1k(:)';A1epsilon=A1epsilon(:)';A1p=A1p(:)';
[A2epsilon,A2p]=schurOneMscale(A2k);
A2k=A2k(:)';A2epsilon=A2epsilon(:)';A2p=A2p(:)';

% Find response
Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
T=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
P=schurOneMPAlatticeP(wp,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
D=schurOneMPAlatticedAsqdw(wd,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);

% Amplitude, delay and phase at local peaks
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=schurOneMPAlatticeAsq(wAsqS,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
printf("A1,A2:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("A1,A2:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMPAlatticeT(wTS,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
printf("A1,A2:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("A1,A2:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

vPl=local_max(Pdl-P);
vPu=local_max(P-Pdu);
wPS=unique([wp(vPl);wp(vPu);wp([1,end])]);
PS=schurOneMPAlatticeP(wPS,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
printf("A1,A2:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("A1,A2:PS=[ ");printf("%f ",(PS+(wPS*tp))'/pi-pp);printf("] (rad./pi)\n");

vDl=local_max(Ddl-D);
vDu=local_max(D-Ddu);
wDS=unique([wd(vDl);wd(vDu);wd([1,end])]);
DS=schurOneMPAlatticedAsqdw(wDS,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
printf("A1,A2:fDS=[ ");printf("%f ",wDS'*0.5/pi);printf(" ] (fs==1)\n");
printf("A1,A2:DS=[ ");printf("%f ",DS');printf("]\n");

% Plot response
subplot(411);
ax=plotyy(wa*0.5/pi,10*log10(Asq),wa*0.5/pi,10*log10(Asq));
axis(ax(1),[0 0.5 0.2*[-1 1]]);
axis(ax(2),[0 0.5 -44 -36]);
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf("Parallel all-pass bandpass Hilbert : dBap=%g,dBas=%g",dBap,dBas);
title(strt);
subplot(412);
plot(wp*0.5/pi,mod((unwrap(P)+(tp*wp))/pi,2.0));
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 (mod(pp,2.0)+(ppr*[-1 1]/2))]);
grid("on");
subplot(413);
plot(wt*0.5/pi,T);
ylabel("Delay(samples)");
axis([0 0.5 (tp+(0.02*[-1 1]))]);
grid("on");
subplot(414);
plot(wd*0.5/pi,D);
ylabel("$\\frac{dAsq}{d\\omega}$");
xlabel("Frequency");
axis([0 0.5 (dp+(dpr*[-1 1]/2))]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot poles and zeros
A1d=schurOneMAPlattice2tf(A1k,A1epsilon,A1p);
A1d=A1d(:);
A2d=schurOneMAPlattice2tf(A2k,A2epsilon,A2p);
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
close

% Check transfer function
HH=freqz(N2,D2,wa);
if max(abs((abs(HH).^2)-Asq)) > 2e4*eps
  error("max(abs((abs(HH).^2)-Asq))(%g*eps) > 2e4*eps",
        max(abs((abs(HH).^2)-Asq))/eps);
endif

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n",difference);
fprintf(fid,"rho=%f %% Constraint on all-pass pole radius\n",rho);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"fasl=%g %% Stop band amplitude response lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Pass band amplitude response lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Pass band amplitude response upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Stop band amplitude response upper edge\n",fasu);
fprintf(fid,"dBap=%f %% Pass band amplitude response ripple(dB)\n",dBap);
fprintf(fid,"dBas=%f %% Stop band amplitude response ripple(dB)\n",dBas);
fprintf(fid,"Wasl=%d %% Lower stop band amplitude response weight\n",Wasl);
fprintf(fid,"Watl=%d %% Lower transition band amplitude response weight\n",Watl);
fprintf(fid,"Wap=%d %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"Watu=%d %% Upper transition band amplitude response weight\n",Watu);
fprintf(fid,"Wasu=%d %% Upper stop band amplitude response weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Pass band group-delay response lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band group-delay response upper edge\n",ftpu);
fprintf(fid,"tp=%f %% Pass band nominal group-delay response(samples)\n",tp);
fprintf(fid,"tpr=%f %% Pass band group-delay response ripple(samples)\n",tpr);
fprintf(fid,"Wtp=%d %% Pass band group-delay response weight\n",Wtp);
fprintf(fid,"fppl=%g %% Pass band phase response lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Pass band phase response upper edge\n",fppu);
fprintf(fid,"pp=%f %% Pass band nominal phase response(rad./pi)\n",pp);
fprintf(fid,"ppr=%f %% Pass band phase response ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%d %% Pass band phase response weight\n",Wpp);
fprintf(fid,"fdpl=%g %% Pass band dAsqdw response lower edge\n",fdpl);
fprintf(fid,"fdpu=%g %% Pass band dAsqdw response upper edge\n",fdpu);
fprintf(fid,"dp=%f %% Pass band nominal dAsqdw response\n",dp);
fprintf(fid,"dpr=%f %% Pass band dAsqdw response ripple\n",dpr);
fprintf(fid,"Wdp=%d %% Pass band dAsqdw response weight\n",Wpp);
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

print_polynomial(A1d,"A1d");
print_polynomial(A1d,"A1d",strcat(strf,"_A1d_coef.m"));
print_polynomial(A2d,"A2d");
print_polynomial(A2d,"A2d",strcat(strf,"_A2d_coef.m"));

print_polynomial(N2,"N2");
print_polynomial(N2,"N2",strcat(strf,"_N2_coef.m"));
print_polynomial(D2,"D2");
print_polynomial(D2,"D2",strcat(strf,"_D2_coef.m"));

eval(sprintf(["save %s.mat ...\n", ...
 "     n difference tol ctol rho  ...\n", ...
 "     fapl fapu dBap Wap Watl Watu ...\n", ...
 "     fasl fasu dBas Wasl Wasu ...\n", ...
 "     ftpl ftpu tp tpr Wtp ...\n", ...
 "     fppl fppu pp ppr Wpp ...\n", ...
 "     fdpl fdpu dp dpr Wdp ...\n", ...
 "     Da0 Db0 A1k A1epsilon A1p A2k A2epsilon A2p A1d A2d N2 D2"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
