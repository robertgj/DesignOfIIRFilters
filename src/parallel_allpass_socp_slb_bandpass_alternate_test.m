% parallel_allpass_socp_slb_bandpass_alternate_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("parallel_allpass_socp_slb_bandpass_alternate_test.diary");
unlink("parallel_allpass_socp_slb_bandpass_alternate_test.diary.tmp");
diary parallel_allpass_socp_slb_bandpass_alternate_test.diary.tmp

tic;

%
% Options
%

format compact
verbose=false
maxiter=2000
strf="parallel_allpass_socp_slb_bandpass_alternate_test";

%
% Initial coefficients found by tarczynski_parallel_allpass_bandpass_test.m
%
Da0 = [   1.0000000000,   0.6291532594,   0.1516899257,   1.1492007108, ... 
          0.7862650993,   0.0097304221,   0.5832470538,   0.6897399905, ... 
         -0.0404801056,   0.2144812938,   0.4428147626,  -0.0239059890, ... 
          0.1461717773,   0.1697445649,  -0.0042457438,   0.0593353657, ... 
         -0.0109692667 ]';
Db0 = [   1.0000000000,   0.1269093856,  -0.5846438654,   0.9070007830, ... 
          0.6136674087,  -0.4000844512,   0.3768763539,   0.6354187865, ... 
         -0.2340756250,   0.1185993375,   0.4406329571,  -0.1582047197, ... 
          0.0473535629,   0.1397988987,  -0.0291104459,   0.0643853648, ... 
         -0.0117657427 ]';

%
% Band-pass filter specification for parallel all-pass filters
%
tol=1e-4
ctol=5e-8
polyphase=false
difference=true
Ra=1
Rb=1
ma=length(Da0)-1
mb=length(Db0)-1
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=2
Wap=0.2
Watl=0.1
Watu=0.1
dBas=60
Wignore=1e-5
Wasl=Wignore
Wasu=Wignore
fttl=0.05
ftpl=0.08
ftpu=0.22
fttu=0.25
td=20
tpr=td/250
Wtp=0.1
ttr=td/2
Wttl=Wignore
Wttu=Wignore

% Convert coefficients to a vector
ab0=zeros(ma+mb,1);
[ab0(1:ma),Va,Qa]=tf2a(Da0);
[ab0((ma+1):end),Vb,Qb]=tf2a(Db0);
printf("Initial ab0=[");printf("%g ",ab0');printf("]'\n");

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
nttl=floor(n*fttl/0.5)+1;
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
nttu=ceil(n*fttu/0.5)+1;
wt=wa(nttl:nttu);
Td=td*ones(nttu-nttl+1,1);
Tdu=[(td+(ttr/2))*ones(ntpl-nttl,1); ...
     (td+(tpr/2))*ones(ntpu-ntpl+1,1);
     (td+(ttr/2))*ones(nttu-ntpu,1)];
Tdl=[(td-(ttr/2))*ones(ntpl-nttl,1); ...
     (td-(tpr/2))*ones(ntpu-ntpl+1,1);
     (td-(ttr/2))*ones(nttu-ntpu,1)];
Wt=[Wttl*ones(ntpl-nttl,1);Wtp*ones(ntpu-ntpl+1,1);Wttu*ones(nttu-ntpu,1)];

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

nchkt=[nttl,nttl+1,ntpl-1,ntpl,ntpl+1,ntpu-1,ntpu,ntpu+1,nttu-1,nttu]-nttl+1;
printf("0.5*wt(nchkt)'/pi=[ ");printf("%6.4g ",0.5*wt(nchkt)'/pi);printf("];\n");
printf("Td(nchkt)=[ ");printf("%6.4g ",Td(nchkt)');printf("];\n");
printf("Tdu(nchkt)=[ ");printf("%6.4g ",Tdu(nchkt)');printf("];\n");
printf("Tdl(nchkt)=[ ");printf("%6.4g ",Tdl(nchkt)');printf("];\n");
printf("Wt(nchkt)=[ ");printf("%6.4g ",Wt(nchkt)');printf("];\n");

% Linear constraints
rho=127/128
[al,au]=aConstraints(Va,Qa,rho);
[bl,bu]=aConstraints(Vb,Qb,rho);
abl=[al(:);bl(:)];
abu=[au(:);bu(:)];

% Find initial response
Nab0=0.5*(conv(flipud(Da0),Db0)-conv(flipud(Db0),Da0));
Dab0=conv(Da0,Db0);
nplot=512;
[Hab0,wplot]=freqz(Nab0,Dab0,nplot);
Tab0=grpdelay(Nab0,Dab0,nplot);

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
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 40]);
grid("on");
print(strcat(strf,"_ab0"),"-dpdflatex");
close
% Plot initial poles and zeros
subplot(111);
zplane(roots(Nab0),roots(Dab0));
title(strt);
print(strcat(strf,"_ab0pz"),"-dpdflatex");
close

%
% Compare initial error values
%
Asq0=parallel_allpassAsq(wa,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
Wa_stop=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    zeros(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];
Asq0Err_stop=trapz(wa,((Asq0-Asqd).^2).*Wa_stop);
Wa_transition=[zeros(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    zeros(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    zeros(n-nasu+1,1)];
Asq0Err_transition=trapz(wa,((Asq0-Asqd).^2).*Wa_transition);
Wa_pass=[zeros(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    zeros(n-nasu+1,1)];
Asq0Err_pass=trapz(wa,((Asq0-Asqd).^2).*Wa_pass);
printf("Asq0Err_stop=%g,Asq0Err_transition=%g,Asq0Err_pass=%g\n", ...
       Asq0Err_stop,Asq0Err_transition,Asq0Err_pass);

T0=parallel_allpassT(wt,ab0,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
Wt_transition=[Wttl*ones(ntpl-nttl,1); ...
               zeros(ntpu-ntpl+1,1); ...
               Wttu*ones(nttu-ntpu,1)];
T0Err_transition=trapz(wt,((T0-Td).^2).*Wt_transition);
Wt_pass=[zeros(ntpl-nttl,1);Wtp*ones(ntpu-ntpl+1,1);zeros(nttu-ntpu,1)];
T0Err_pass=trapz(wt,((T0-Td).^2).*Wt_pass);
printf("T0Err_transition=%g,T0Err_pass=%g\n",T0Err_transition,T0Err_pass);

%
% PCLS pass
%
[ab1,slb_iter,opt_iter,func_iter,feasible]= ...
parallel_allpass_slb(@parallel_allpass_socp_mmse,ab0,abu,abl, ...
                     Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference, ...
                     wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                     wp,Pd,Pdu,Pdl,Wp,maxiter,tol,ctol,verbose);
if !feasible
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
Tab1=grpdelay(Nab1,Dab1,nplot);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hab1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("Parallel allpass bandpass : ma=%d,mb=%d,td=%g,dBap=%g,dBas=%g",
             ma,mb,td,dBap,dBas);
title(strt);
subplot(212);
plot(wplot*0.5/pi,Tab1);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 40]);
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
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([min(fapl,ftpl) max(fapu,ftpu) td-tpr td+tpr]);
grid("on");
print(strcat(strf,"_ab1pass"),"-dpdflatex");
close

% Plot phase response
Pa=allpassP(wplot,a1,Va,Qa,Ra);
Pb=allpassP(wplot,b1,Vb,Qb,Rb);
plot(wplot*0.5/pi,Pa+(wplot*td),"-",wplot*0.5/pi,Pb+(wplot*td),"--");
strt=sprintf("Parallel allpass bandpass filter : all-pass filter phase \
responses adjusted for linear phase (w*td): ma=%d,mb=%d,td=%g",ma,mb,td);
title(strt);
ylabel("All-pass filter phase (rad.)\n(Adjusted for linear phase.)");
xlabel("Frequency");
legend("Filter A","Filter B","location","northwest");
legend("boxoff");
grid("on");
print(strcat(strf,"_ab1phase"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(roots(Nab1),roots(Dab1));
title(strt);
print(strcat(strf,"_ab1pz"),"-dpdflatex");
close
zplane(roots(flipud(Da1)),roots(Da1));
title("Allpass filter A");
print(strcat(strf,"_a1pz"),"-dpdflatex");
close
zplane(roots(flipud(Db1)),roots(Db1));
title("Allpass filter B");
print(strcat(strf,"_b1pz"),"-dpdflatex");
close

% PCLS amplitude at local peaks
Asq=parallel_allpassAsq(wa,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=parallel_allpassAsq(wAsqS,ab1,Va,Qa,Ra,Vb,Qb,Rb,polyphase,difference);
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
fid=fopen(strcat(strf,".spec"),"wt");
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
fprintf(fid,"Wap=%f %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"Watl=%f %% Lower transition band amplitude response weight\n",Watl);
fprintf(fid,"Watu=%f %% Upper transition band amplitude response weight\n",Watu);
fprintf(fid,"fasl=%g %% Stop band amplitude response lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Stop band amplitude response upper edge\n",fasu);
fprintf(fid,"dBas=%f %% Stop band amplitude response ripple(dB)\n",dBas);
fprintf(fid,"Wasl=%f %% Lower stop band amplitude response weight\n",Wasl);
fprintf(fid,"Wasu=%f %% Upper stop band amplitude response weight\n",Wasu);
fprintf(fid,"fttl=%g %% Transition band group-delay response lower edge\n",fttl);
fprintf(fid,"ftpl=%g %% Pass band group-delay response lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band group-delay response upper edge\n",ftpu);
fprintf(fid,"fttu=%g %% Transition band group-delay response upper edge\n",fttu);
fprintf(fid,"td=%f %% Pass band nominal group-delay response(samples)\n",td);
fprintf(fid,"tpr=%f %% Pass band group-delay response ripple(samples)\n",tpr);
fprintf(fid, ...
        "ttr=%f %% Transition band group-delay response ripple(samples)\n",ttr);
fprintf(fid,"Wtp=%d %% Pass band group-delay response weight\n",Wtp);
fprintf(fid, ...
        "Wttl=%f %% Lower transition band group-delay response weight\n",Wttl);
fprintf(fid, ...
        "Wttu=%f %% Upper transition band group-delay response weight\n",Wttu);
fclose(fid);

% Save results
print_pole_zero([1;a1],0,Va,0,Qa,Ra,"a1");
print_pole_zero([1;a1],0,Va,0,Qa,Ra,"a1",strcat(strf,"_a1_coef.m"),"%18.12g");
print_pole_zero([1;b1],0,Vb,0,Qb,Rb,"b1");
print_pole_zero([1;b1],0,Vb,0,Qb,Rb,"b1",strcat(strf,"_b1_coef.m"),"%18.12g");
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1",strcat(strf,"_Da1_coef.m"),"%18.12g");
print_polynomial(Db1,"Db1");
print_polynomial(Db1,"Db1",strcat(strf,"_Db1_coef.m"),"%18.12g");
print_polynomial(Nab1,"Nab1");
print_polynomial(Nab1,"Nab1",strcat(strf,"_Nab1_coef.m"),"%18.12g");
print_polynomial(Dab1,"Dab1");
print_polynomial(Dab1,"Dab1",strcat(strf,"_Dab1_coef.m"),"%18.12g");

% Done 
save parallel_allpass_socp_slb_bandpass_alternate_test.mat ...
     ma mb Ra Rb ab0 ab1 Da1 Db1 ...
     tol ctol polyphase difference rho n fapl fapu dBap Wap Watl Watu  ...
     fasl fasu dBas Wasl Wasu ftpl ftpu td tpr ttr Wtp Wttl Wttu

toc;
diary off
movefile parallel_allpass_socp_slb_bandpass_alternate_test.diary.tmp ...
         parallel_allpass_socp_slb_bandpass_alternate_test.diary;
