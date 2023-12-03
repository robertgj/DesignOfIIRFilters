% schurOneMPAlattice_socp_slb_bandpass_delay_test.m
% Copyright (C) 2023 Robert G. Jenssen
%
% Find a parallel all-pass one-multiplier Schur lattice bandpass filter for
% which the phase at the phase pass-band lower edge is (w*tp)+(n*pi).

test_common;

strf="schurOneMPAlattice_socp_slb_bandpass_delay_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=10000
verbose=false

%
% Band-pass filter specification for parallel all-pass filters
%
tol=1e-4
ctol=1e-7
difference=true
dmax=inf;
rho=0.999
fasl=0.05
fapl=0.10
fapu=0.15
fasu=0.20
dBap=0.08
dBas=51
Wap=1
Watl=0.01
Watu=0.01
Wasl=1000
Wasu=2000
ftpl=0.10
ftpu=0.15
tp=16
tpr=0.16
Wtp=10
fppl=0.10
fppu=0.15
pd=3 % Initial phase offset in multiples of pi radians
pdr=0.006 % Peak-to-peak phase ripple in multiples of pi radians
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
Pd=(pd*pi)-(tp*wp);
Pdu=Pd+(pdr*pi/2);
Pdl=Pd-(pdr*pi/2);
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

%
% Initial coefficients
%
tarczynski_parallel_allpass_bandpass_test_Da0_coef;
tarczynski_parallel_allpass_bandpass_test_Db0_coef;

% Lattice decomposition of Da0, Db0
[A1k0,A1epsilon0,A1p0,~] = tf2schurOneMlattice(flipud(Da0),Da0);
[A2k0,A2epsilon0,A2p0,~] = tf2schurOneMlattice(flipud(Db0),Db0);

% Find initial response
Asq0=schurOneMPAlatticeAsq(wa,A1k0,A1epsilon0,A1p0, ...
                           A2k0,A2epsilon0,A2p0,difference);
T0=schurOneMPAlatticeT(wt,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference);
P0=schurOneMPAlatticeP(wp,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference);

% Plot initial response
subplot(311);
ax=plotyy(wa*0.5/pi,10*log10(Asq0),wa*0.5/pi,10*log10(Asq0));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -1 1]);
axis(ax(2),[0 0.5 -60 -20]);
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf("Parallel all-pass bandpass initial response");
title(strt);
subplot(312);
plot(wp*0.5/pi,((P0+(tp*wp))/pi)-pd);
ylabel("Phase error(rad./$\\pi$)");
%axis([0 0.5 -0.002 0.002]);
grid("on");
subplot(313);
plot(wt*0.5/pi,T0);
ylabel("Delay(samples)");
xlabel("Frequency");
%axis([0 0.5 tp-0.1 tp+0.1]);
grid("on");
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

%
% SOCP MMSE
%

% Linear constraints
k0=[A1k0(:);A2k0(:)];
k_u=rho*ones(size(k0));
k_l=-k_u;
k_active=find(k0~=0);

try
  feasible=0;
  [A1k1,A2k1,socp_iter,func_iter,feasible] = ...
    schurOneMPAlattice_socp_mmse([], ...
                                 A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                                 difference,k_u,k_l,k_active,dmax, ...
                                 wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                                 wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose);
catch
  printf("%s\n", lasterror().message);
end_try_catch
if feasible == 0
  error("A1k,A2k(MMSE) infeasible for tp=%d",tp);
endif

% Find MMSE response
Asq1=schurOneMPAlatticeAsq ...
       (wa,A1k1,A1epsilon0,A1p0,A2k1,A2epsilon0,A2p0,difference);
T1=schurOneMPAlatticeT(wt,A1k1,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference);
P1=schurOneMPAlatticeP(wp,A1k1,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference);

% Plot MMSE response
subplot(311);
ax=plotyy(wa*0.5/pi,10*log10(Asq1),wa*0.5/pi,10*log10(Asq1));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -1 1]);
axis(ax(2),[0 0.5 -60 -20]);
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf("Parallel all-pass bandpass MMSE response");
title(strt);
subplot(312);
plot(wp*0.5/pi,((P1+(tp*wp))/pi)-pd);
ylabel("Phase error(rad./$\\pi$)");
%axis([0 0.5 -0.002 0.002]);
grid("on");
subplot(313);
plot(wt*0.5/pi,T1);
ylabel("Delay(samples)");
xlabel("Frequency");
%axis([0 0.5 tp-0.1 tp+0.1]);
grid("on");
print(strcat(strf,"_mmse_response"),"-dpdflatex");
close

%
% SOCP PCLS
%
try
  feasible=0;
  [A1k,A2k,slb_iter,opt_iter,func_iter,feasible] = ...
    schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                           A1k1,A1epsilon0,A1p0,A2k1,A2epsilon0,A2p0, ...
                           difference,k_u,k_l,k_active,dmax, ...
                           wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                           wp,Pd,Pdu,Pdl,Wp,maxiter,tol,ctol,verbose);
catch
  printf("%s\n", lasterror().message);
end_try_catch
if feasible == 0 
  error("A1k,A2k(PCLS) infeasible for tp=%d",tp);
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

% Plot response
subplot(311);
ax=plotyy(wa*0.5/pi,10*log10(Asq),wa*0.5/pi,10*log10(Asq));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -1 1]);
axis(ax(2),[0 0.5 -60 -40]);
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf("Parallel all-pass bandpass : dBap=%g,dBas=%g",dBap,dBas);
title(strt);
subplot(312);
plot(wp*0.5/pi,((P+(tp*wp))/pi)-pd);
ylabel("Phase error(rad./$\\pi$)");
axis([0 0.5 -0.002 0.002]);
grid("on");
subplot(313);
plot(wt*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 tp-0.1 tp+0.1]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot poles and zeros
A1d=schurOneMAPlattice2tf(A1k,A1epsilon,A1p);
A1d=A1d(:);
A2d=schurOneMAPlattice2tf(A2k,A2epsilon,A2p);
A2d=A2d(:);
zplane(roots(flipud(A1d)),roots(A1d));
title("Allpass filter 1");
print(strcat(strf,"_A1pz"),"-dpdflatex");
close
zplane(roots(flipud(A2d)),roots(A2d));
title("Allpass filter 2");
print(strcat(strf,"_A2pz"),"-dpdflatex");
close
zplane(roots(conv(A1d,flipud(A2d))-conv(A2d,flipud(A1d))),roots(conv(A1d,A2d)));
title("Parallel allpass filter ");
print(strcat(strf,"_A12pz"),"-dpdflatex");
close

% Maximum pass-band error compared to a delay
Htp=freqz([zeros(1,tp),1],1,wa);
[N,D]=schurOneMPAlattice2tf(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
H=freqz(N,D,wa);
dB_error_tp_sample_delay=20*log10(abs(H-(cos(mod(pd,2)*pi)*Htp)));
max_dB_error_tp_sample_delay=max(dB_error_tp_sample_delay(nppl:nppu));
printf("max_dB_error_tp_sample_delay=%10.6f dB\n",max_dB_error_tp_sample_delay);

% Plot amplitude error compared to a tp sample delay
plot(wa*0.5/pi,dB_error_tp_sample_delay)
xlabel("Frequency");
ylabel("Amplitude error (dB)");
title(sprintf("Parallel all-pass bandpass : \
Amplitude error compared to a %d sample delay",tp));
grid("on");
text(0.2,-40,sprintf("Max. phase pass band amplitude error=%7.3f dB",
                     max_dB_error_tp_sample_delay));
print(strcat(strf,"_error"),"-dpdflatex");
close

% Maximum stop-band error
max_dB_error_stop_band=max(10*log10([Asq(1:nasl);(Asq(nasu:end))]));
printf("max_dB_error_stop_band=%10.6f dB\n",max_dB_error_stop_band);

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
printf("A1,A2:PS=[ ");printf("%f ",(PS+(wPS*tp))'/pi-pd);printf("] (rad./pi)\n");

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
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
fprintf(fid,"pd=%f %% Pass band nominal phase response(rad./pi)\n",pd);
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

save schurOneMPAlattice_socp_slb_bandpass_delay_test.mat ...
     n difference tol ctol rho  ...
     fapl fapu dBap Wap Watl Watu ...
     fasl fasu dBas Wasl Wasu ...
     ftpl ftpu tp tpr Wtp ...
     fppl fppu pd pdr Wpp ...
     Da0 Db0 A1k A1epsilon A1p A2k A2epsilon A2p ...
     N D max_dB_error_tp_sample_delay max_dB_error_stop_band
 
% Done
toc;
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));
