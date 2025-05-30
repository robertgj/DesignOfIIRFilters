% parallel_allpass_socp_slb_bandpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="parallel_allpass_socp_slb_bandpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false
maxiter=2000

%
% Initial coefficients found by tarczynski_parallel_allpass_bandpass_test.m
%
tarczynski_parallel_allpass_bandpass_test_Da0_coef;
tarczynski_parallel_allpass_bandpass_test_Db0_coef;

% Convert coefficients to a vector
[a0,Va,Qa]=tf2a(Da0);
[b0,Vb,Qb]=tf2a(Db0);
ab0=[a0(:);b0(:)];
printf("Initial ab0=[");printf("%g ",ab0');printf("]'\n");

%
% Band-pass filter specification for parallel all-pass filters
%
tol=1e-4
ctol=1e-7
polyphase=false
difference=true
rho=0.999 
Ra=1
Rb=1
K=1
ma=length(a0)
mb=length(b0)
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=2
Wap=1
Watl=0.01
Watu=0.01
dBas=50
Wasl=5000
Wasu=2000
ftpl=0.09
ftpu=0.21
tp=16
tpr=tp/400
Wtp=2

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
Td=tp*ones(ntpu-ntpl+1,1);
Tdu=(tp+(tpr/2))*ones(ntpu-ntpl+1,1);
Tdl=(tp-(tpr/2))*ones(ntpu-ntpl+1,1);
Wt=Wtp*ones(ntpu-ntpl+1,1);

% Desired pass-band phase response
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

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

% Linear constraints
[al,au]=aConstraints(Va,Qa,rho);
[bl,bu]=aConstraints(Vb,Qb,rho);
abl=[al(:);bl(:)];
abu=[au(:);bu(:)];

% Find initial response
Nab0=0.5*(conv(flipud(Da0),Db0)-conv(flipud(Db0),Da0));
Dab0=conv(Da0,Db0);
nplot=512;
[Hab0,wplot]=freqz(Nab0,Dab0,nplot);
Tab0=delayz(Nab0,Dab0,nplot);

% Plot initial response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab0)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("Initial parallel allpass bandpass : ma=%d,mb=%d",ma,mb);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 20]);
grid("on");
print(strcat(strf,"_ab0"),"-dpdflatex");
close

%
% PCLS pass
%
try
  feasible=false
  [ab1,slb_iter,opt_iter,func_iter,feasible]= ...
     parallel_allpass_slb(@parallel_allpass_socp_mmse,ab0,abu,abl, ...
                          K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference, ...
                          wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                          wp,Pd,Pdu,Pdl,Wp,maxiter,tol,ctol,verbose);
catch
  feasible = false;
  warning("Caught parallel_allpass_slb!");
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

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 5]);
grid("on");
strt=sprintf("Parallel allpass bandpass : ma=%d,mb=%d,dBap=%g,dBas=%g", ...
             ma,mb,dBap,dBas);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 20]);
grid("on");
print(strcat(strf,"_ab1"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([min(fapl,ftpl) max(fapu,ftpu) -3 1]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([min(fapl,ftpl) max(fapu,ftpu) (tp+[-1 1]*0.04)]);
grid("on");
print(strcat(strf,"_ab1pass"),"-dpdflatex");
close

% Plot phase response
Pa=allpassP(wplot,a1,Va,Qa,Ra);
Pb=allpassP(wplot,b1,Vb,Qb,Rb);
plot(wplot*0.5/pi,(Pa+(wplot*tp))/pi,"-",wplot*0.5/pi,(Pb+(wplot*tp))/pi,"--");
strt=sprintf(["Allpass phase response adjusted for linear phase ", ...
 "ma=%d,mb=%d,tp=%g"], ma,mb,tp);
title(strt);
ylabel("All-pass filter phase (rad./$\\pi$)");
xlabel("Frequency");
legend("Filter A","Filter B","location","northwest");
legend("boxoff");
grid("on");
print(strcat(strf,"_ab1phase"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(qroots(flipud(Da1)),qroots(Da1));
title("Allpass filter A");
print(strcat(strf,"_a1pz"),"-dpdflatex");
close
zplane(qroots(flipud(Db1)),qroots(Db1));
title("Allpass filter B");
print(strcat(strf,"_b1pz"),"-dpdflatex");
close
zplane(qroots(Nab1),qroots(Dab1));
title("Parallel allpass filters");
print(strcat(strf,"_ab1pz"),"-dpdflatex");
close

% PCLS amplitude at local peaks
Asq=parallel_allpassAsq(wa,ab1,K,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=parallel_allpassAsq(wAsqS,ab1,1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
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

% Save the filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"polyphase=%d %% Use polyphase combination\n",polyphase);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n",difference);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
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
fprintf(fid,"tp=%f %% Pass band nominal group-delay response (samples)\n",tp);
fprintf(fid,"tpr=%f %% Pass band group-delay response ripple(samples)\n",tpr);
fprintf(fid,"Wtp=%d %% Pass band group-delay response weight\n",Wtp);
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

eval(sprintf(["save %s.mat ...\n", ...
 "  ma mb Ra Rb ab0 ab1 Da1 Db1 ... \n", ...
 "  tol ctol polyphase difference rho n fapl fapu dBap Wap Watl Watu  ...\n", ...
 "  fasl fasu dBas Wasl Wasu ftpl ftpu tp tpr Wtp"],strf));

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
