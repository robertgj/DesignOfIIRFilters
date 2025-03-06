% parallel_allpass_socp_slb_bandpass_hilbert_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="parallel_allpass_socp_slb_bandpass_hilbert_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
ftol=1e-5
ctol=1e-8
verbose=false

%
% Initial coefficients 
%
tarczynski_parallel_allpass_bandpass_hilbert_test_Da0_coef;
tarczynski_parallel_allpass_bandpass_hilbert_test_Db0_coef;
[a0,Va,Qa]=tf2a(Da0);Ra=1;
[b0,Vb,Qb]=tf2a(Db0);Rb=1;
ab0=[a0(:);b0(:)];
ma=length(a0);
mb=length(b0);
K=1;
printf("Initial ab0=[");printf("%14.10f ",ab0');printf("]'\n");


%
% Band-pass filter specification for parallel all-pass filters
%
polyphase=false
difference=true
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=0.04
dBas=40
Wap=1
Watl=1e-3
Watu=1e-3
Wasl=200
Wasu=200
ftpl=0.12
ftpu=0.18
tp=16
tpr=tp/1600
Wtp=10
fppl=0.12
fppu=0.18
pd=1.5 % Initial phase offset in multiples of pi radians
pdr=1/10000 % Peak-to-peak phase ripple in multiples of pi radians
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
Wp=Wpp*ones(nppu-nppl+1,1);

% Sanity checks
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
rho=0.999;
[al,au]=aConstraints(Va,Qa,rho);
[bl,bu]=aConstraints(Vb,Qb,rho);
abl=[al(:);bl(:)];
abu=[au(:);bu(:)];

% Find initial response
Asq0=parallel_allpassAsq(wa,ab0,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
T0=parallel_allpassT(wa,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
P0=parallel_allpassP(wa,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
             
% Plot initial response
subplot(311);
plot(wa*0.5/pi,10*log10(Asq0));
axis([0 0.5 -80 5]);
grid("on");
ylabel("Amplitude(dB)");
strt=sprintf("Initial parallel allpass bandpass Hilbert : ma=%d,mb=%d",ma,mb);
title(strt);
subplot(312);
plot(wa*0.5/pi,T0);
axis([0 0.5 0 20]);
grid("on");
ylabel("Delay(samples)");
subplot(313);
plot(wa*0.5/pi,(P0+(wa*tp))/pi);
axis([0 0.5 0 2]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
print(strcat(strf,"_ab0"),"-dpdflatex");
close

%
% MMSE pass
%
try
  feasible=false;
  [abm,opt_iter,func_iter,feasible]= ...
    parallel_allpass_socp_mmse([],ab0,abu,abl, ...
                               K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference, ...
                               wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                               wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose);
catch
  feasible=false;
  warning("Caught parallel_allpass_socp_mmse");
end_try_catch
if ~feasible
  error("abm infeasible");
endif

%
% PCLS pass
%
try
  feasible=false;
  [ab1,slb_iter,opt_iter,func_iter,feasible]= ...
    parallel_allpass_slb(@parallel_allpass_socp_mmse,abm,abu,abl, ...
                         K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference, ...
                         wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                         wp,Pd,Pdu,Pdl,Wp,maxiter,ftol,ctol,verbose);
catch
  feasible=false;
  warning("Caught parallel_allpass_slb");
end_try_catch
if ~feasible
  error("ab1 infeasible");
endif

% Find overall filter polynomials
a1=[ab1(1:ma)];
b1=[ab1((ma+1):end)];
[Na1,Da1]=a2tf(a1,Va,Qa,Ra);
Da1=Da1(:);
[Nb1,Db1]=a2tf(b1,Vb,Qb,Rb);
Db1=Db1(:);
Nab1=(conv(flipud(Da1),Db1)-conv(flipud(Db1),Da1))/2;
Dab1=conv(Da1,Db1);

% Find response
nplot=512;
[Hab1,wplot]=freqz(Nab1,Dab1,nplot);
Tab1=delayz(Nab1,Dab1,nplot);
Pab1=unwrap(arg(Hab1));

% Plot response
subplot(311);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
strt=sprintf ...
       ("Parallel allpass bandpass Hilbert : ma=%d,mb=%d,dBap=%g,dBas=%g,tp=%d",
        ma,mb,dBap,dBas,tp);
title(strt);
subplot(312);
plot(wplot*0.5/pi,mod((Pab1+(wplot*tp))/pi,2));
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 0 2]);
grid("on");
subplot(313);
plot(wplot*0.5/pi,Tab1);
ylabel("Delay(samples)");
axis([0 0.5 10 30]);
grid("on");
xlabel("Frequency");
print(strcat(strf,"_ab1"),"-dpdflatex");
close

% Plot passband response
subplot(311);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([min([fapl,ftpl,fppl]) max([fapu,ftpu,fppl]) -0.06 0.02]);
grid("on");
title(strt);
subplot(312);
plot(wplot*0.5/pi,mod((Pab1+(wplot*tp))/pi,2));
ylabel("Phase(rad./$\\pi$)");
axis([min([fapl,ftpl,fppl]) max([fapu,ftpu,fppl]) pd-(2*pdr) pd+(2*pdr)]);
grid("on");
subplot(313);
plot(wplot*0.5/pi,Tab1);
ylabel("Delay(samples)");
axis([min([fapl,ftpl,fppl]) max([fapu,ftpu,fppl]) tp-tpr tp+tpr]);
grid("on");
xlabel("Frequency");
print(strcat(strf,"_ab1pass"),"-dpdflatex");
close

% Plot poles and zeros
zplane(qroots(flipud(Da1)),qroots(Da1));
title("Allpass filter A");
print(strcat(strf,"_a1pz"),"-dpdflatex");
close
zplane(qroots(flipud(Db1)),qroots(Db1));
title("Allpass filter B");
print(strcat(strf,"_b1pz"),"-dpdflatex");
close

% Plot phase response
Pa=allpassP(wplot,a1,Va,Qa,Ra);
Pb=allpassP(wplot,b1,Vb,Qb,Rb);
plot(wplot*0.5/pi,(Pa+(wplot*tp))/pi,"-", ...
     wplot*0.5/pi,(Pb+(wplot*tp))/pi,"--");
strt=sprintf("Parallel allpass bandpass Hilbert : all-pass filter phase \
responses : ma=%d,mb=%d,tp=%g",ma,mb,tp);
title(strt);
ylabel("All-pass filter phase(rad./$\\pi$)");
xlabel("Frequency");
legend("Filter A","Filter B","location","northwest");
legend("boxoff");
grid("on");
print(strcat(strf,"_ab1phase"),"-dpdflatex");
close

% PCLS amplitude at local peaks
Asq=parallel_allpassAsq(wa,ab1,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=parallel_allpassAsq(wAsqS,ab1,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
printf("d1:fAS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

% PCLS delay at local peaks
T=parallel_allpassT(wt,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=parallel_allpassT(wTS,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
printf("d1:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:TS=[ ");printf("%f ",TS');printf(" ] (samples)\n");

% PCLS phase at local peaks
P=parallel_allpassP(wp,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
vPl=local_max(Pdl-P);
vPu=local_max(P-Pdu);
wPS=unique([wp(vPl);wp(vPu);wp([1,end])]);
PS=parallel_allpassP(wPS,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
printf("d1:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("d1:PS=[ ");printf("%f ",(PS+(wPS*tp))'/pi);printf(" ] (rad./pi)\n");

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"polyphase=%d %% Use polyphase combination\n",polyphase);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n",difference);
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"rho=%g %% Constraint on allpass pole radius\n",rho);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"ma=%d %% Allpass model filter A denominator order\n",ma);
fprintf(fid,"Va=%d %% Allpass model filter A no. of real poles\n",Va);
fprintf(fid,"Qa=%d %% Allpass model filter A no. of complex poles\n",Qa);
fprintf(fid,"Ra=%d %% Allpass model filter A decimation\n",Ra);
fprintf(fid,"mb=%d %% Allpass model filter B denominator order\n",mb);
fprintf(fid,"Vb=%d %% Allpass model filter B no. of real poles\n",Vb);
fprintf(fid,"Qb=%d %% Allpass model filter B no. of complex poles\n",Qb);
fprintf(fid,"Rb=%d %% Allpass model filter B decimation\n",Rb);
fprintf(fid,"fapl=%g %% Pass band amplitude response lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Pass band amplitude response upper edge\n",fapu);
fprintf(fid,"dBap=%g %% Pass band amplitude response ripple(dB)\n",dBap);
fprintf(fid,"Wap=%g %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"Watl=%g %% Lower transition band amplitude response weight\n",Watl);
fprintf(fid,"Watu=%g %% Upper transition band amplitude response weight\n",Watu);
fprintf(fid,"fasl=%g %% Stop band amplitude response lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Stop band amplitude response upper edge\n",fasu);
fprintf(fid,"dBas=%g %% Stop band amplitude response ripple(dB)\n",dBas);
fprintf(fid,"Wasl=%g %% Lower stop band amplitude response weight\n",Wasl);
fprintf(fid,"Wasu=%g %% Upper stop band amplitude response weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Pass band group-delay response lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band group-delay response upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Pass band nominal group-delay response (samples)\n",tp);
fprintf(fid,"tpr=%g %% Pass band group-delay response ripple(samples)\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group-delay response weight\n",Wtp);
fprintf(fid,"fppl=%g %% Pass band phase response lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Pass band phase response upper edge\n",fppu);
fprintf(fid,"pd=%g %% Pass band initial phase response (rad./pi)\n",pd);
fprintf(fid,"pdr=%g %% Pass band phase response ripple(rad./pi)\n",pdr);
fprintf(fid,"Wpp=%g %% Pass band phase response weight\n",Wpp);
fclose(fid);

% Save results
print_allpass_pole(a1,Va,Qa,Ra,"a1");
print_allpass_pole(a1,Va,Qa,Ra,"a1",strcat(strf,"_a1_coef.m"));
print_allpass_pole(b1,Vb,Qb,Rb,"b1");
print_allpass_pole(b1,Vb,Qb,Rb,"b1",strcat(strf,"_b1_coef.m"));
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"));
print_polynomial(Db1,"Db1");
print_polynomial(Db1,"Db1",strcat(strf,"_Db1_coef.m"));
print_polynomial(Nab1,"Nab1");
print_polynomial(Nab1,"Nab1",strcat(strf,"_Nab1_coef.m"));
print_polynomial(Dab1,"Dab1");
print_polynomial(Dab1,"Dab1",strcat(strf,"_Dab1_coef.m"));

eval(sprintf("save %s.mat ma mb Ra Rb ab0 ab1 Da1 Db1 n\
     ftol ctol polyphase difference rho n fapl fapu dBap Wap Watl Watu  \
     fasl fasu dBas Wasl Wasu ftpl ftpu tp tpr Wtp fppl fppu pd pdr Wpp",strf));

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
