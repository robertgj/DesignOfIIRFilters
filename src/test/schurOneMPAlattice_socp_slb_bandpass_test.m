% schurOneMPAlattice_socp_slb_bandpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="schurOneMPAlattice_socp_slb_bandpass_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

tol=1e-4
ctol=5e-8
maxiter=2000
verbose=false

%
% Initial coefficients found by tarczynski_parallel_allpass_bandpass_test.m
%
tarczynski_parallel_allpass_bandpass_test_Da0_coef;
tarczynski_parallel_allpass_bandpass_test_Db0_coef;

% Lattice decomposition of Da0, Db0
[A1k0,A1epsilon0,A1p0,~] = tf2schurOneMlattice(flipud(Da0),Da0);
[A2k0,A2epsilon0,A2p0,~] = tf2schurOneMlattice(flipud(Db0),Db0);

%
% Band-pass filter specification for parallel all-pass filters
%
difference=true
rho=127/128
m1=length(Da0)-1;
m2=length(Db0)-1;
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=2
Wap=1
Watl=0.1
Watu=0.1
dBas=53
Wasl=1e4
Wasu=1e4
ftpl=0.09
ftpu=0.21
td=16
tdr=td/200
Wtp=0.1

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
Td=td*ones(ntpu-ntpl+1,1);
Tdu=(td+(tdr/2))*ones(ntpu-ntpl+1,1);
Tdl=(td-(tdr/2))*ones(ntpu-ntpl+1,1);
Wt=Wtp*ones(ntpu-ntpl+1,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% dAsqdw constraints
wd=[];
Dd=[];
Ddu=[];
Ddl=[];
Wd=[];

% Linear constraints
dmax=inf;
k0=[A1k0(:);A2k0(:)];
k_u=rho*ones(size(k0));
k_l=-k_u;
k_active=find(k0~=0);

%
% SOCP PCLS
%
[A1k,A2k,slb_iter,opt_iter,func_iter,feasible] = ...
  schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                         A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                         difference,k_u,k_l,k_active,dmax, ...
                         wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                         wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
                         maxiter,tol,ctol,verbose);
if feasible == 0 
  error("A1k,A2k(pcls) infeasible");
endif
% Recalculate A1epsilon, A1p, A2epsilon and A2p
[A1epsilon,A1p]=schurOneMscale(A1k);
A1k=A1k(:)';A1epsilon=A1epsilon(:)';A1p=A1p(:)';
[A2epsilon,A2p]=schurOneMscale(A2k);
A2k=A2k(:)';A2epsilon=A2epsilon(:)';A2p=A2p(:)';

% Find response
Asq=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
T=schurOneMPAlatticeT(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);

% Plot response
subplot(211);
plot(wa*0.5/pi,10*log10(abs(Asq)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("Parallel allpass bandpass : m1=%d,m2=%d,dBap=%g,dBas=%g",
             m1,m2,dBap,dBas);
title(strt);
subplot(212);
plot(wa*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 20]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wa*0.5/pi,10*log10(abs(Asq)));
ylabel("Amplitude(dB)");
axis([min(fapl,ftpl) max(fapu,ftpu) -3 1]);
grid("on");
title(strt);
subplot(212);
plot(wa*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([min(fapl,ftpl) max(fapu,ftpu) td-tdr td+tdr]);
grid("on");
print(strcat(strf,"_passband_response"),"-dpdflatex");
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

% Amplitude and delay at local peaks
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

% Check transfer function
N2=(conv(flipud(A1d),A2d)-conv(flipud(A2d),A1d))/2;
D2=conv(A1d,A2d);
HH=freqz(N2,D2,wa);
if max(abs((abs(HH).^2)-Asq)) > 2000*eps
  error("max(abs((abs(HH).^2)-Asq))(%g*eps)>2000*eps",
        max(abs((abs(HH).^2)-Asq))/eps);
endif

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"m1=%d %% Allpass model filter 1 denominator order\n",m1);
fprintf(fid,"m2=%d %% Allpass model filter 2 denominator order\n",m2);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n",difference);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
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

eval(sprintf("save %s.mat ...\n\
     n m1 m2 difference tol ctol rho  ...\n\
     fapl fapu dBap Wap Watl Watu ...\n\
     fasl fasu dBas Wasl Wasu ...\n\
     ftpl ftpu td tdr Wtp ...\n\
     Da0 Db0 A1k A1epsilon A1p A2k A2epsilon A2p A1d A2d N2 D2",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
