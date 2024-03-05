% tarczynski_parallel_allpass_bandpass_hilbert_test.m
% Copyright (C) 2017-2023 Robert G. Jenssen
%
% Use the method of Tarczynski et al to design a bandpass Hilbert filter
% as the difference of two parallel allpass filters. See:
% "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

strf="tarczynski_parallel_allpass_bandpass_hilbert_test";

delete(strcat(strf,".diary",strf));
delete(strcat(strf,".diary.tmp",strf));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Initialise with the result of tarczynski_parallel_allpass_bandpass_test.m
tarczynski_parallel_allpass_bandpass_test_Da0_coef;Dai=Da0;clear Da0;
tarczynski_parallel_allpass_bandpass_test_Db0_coef;Dbi=Db0;clear Db0;

% Filter specification
tol=1e-6
maxiter=5000
ma=length(Dai)-1
mb=length(Dbi)-1
fasl=0.05,fapl=0.1,fapu=0.2,fasu=0.25,Wasl=20,Watl=0.01,Wap=2,Watu=0.01,Wasu=10
ftpl=0.1,ftpu=0.2,td=16,Wtp=0.5
fppl=0.1,fppu=0.2,pd=1.5,Wpp=0.5

% Frequency points
n=1000;
w=pi*(0:(n-1))'/n;

% Desired amplitude response
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Ad=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];

% Desired delay response
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
Td=td*ones(n,1);
Wt=[zeros(ntpl-1,1);
    Wtp*ones(ntpu-ntpl+1,1); ...
    zeros(n-ntpu,1)];

% Desired phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
Pd=(pd*pi)-td*w;
Wp=[zeros(nppl-1,1);
    Wpp*ones(nppu-nppl+1,1); ...
    zeros(n-nppu,1)];

% Sanity checks
nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napl+1,napu-1,napu,napu+1, ...
       nasu-1,nasu,nasu+1]';
printf("0.5*w(nchka)'/pi=[ ");printf("%6.4g ",0.5*w(nchka)'/pi);printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

nchkt=[ntpl-1,ntpl,ntpl+1,ntpu-1,ntpu,ntpu+1];
printf("0.5*w(nchkt)'/pi=[ ");printf("%6.4g ",0.5*w(nchkt)'/pi);printf("];\n");
printf("Wt(nchkt)=[ ");printf("%6.4g ",Wt(nchkt)');printf("];\n");

nchkp=[nppl-1,nppl,nppl+1,nppu-1,nppu,nppu+1];
printf("0.5*w(nchkp)'/pi=[ ");printf("%6.4g ",0.5*w(nchkp)'/pi);printf("];\n");
printf("Wp(nchkp)=[ ");printf("%6.4g ",Wp(nchkp)');printf("];\n");

% Unconstrained minimisation
abi = [Dai(2:end);Dbi(2:end)];
WISEJ_PAB([],ma,mb,Ad,Wa,Td,Wt,Pd,Wp);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ab0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_PAB,abi,opt);
if (INFO == 1)
  printf("Converged to a solution point.\n");
elseif (INFO == 2)
  printf("Last relative step size was less that TolX.\n");
elseif (INFO == 3)
  printf("Last relative decrease in function value was less than TolF.\n");
elseif (INFO == 0)
  printf("Iteration limit exceeded.\n");
elseif (INFO == -1)
  printf("Algorithm terminated by OutputFcn.\n");
elseif (INFO == -3)
  printf("The trust region radius became excessively small.\n");
else
  error("Unknown INFO value.\n");
endif
printf("Function value=%f\n", FVEC);
printf("fminunc iterations=%d\n", OUTPUT.iterations);
printf("fminunc successful=%d??\n", OUTPUT.successful);
printf("fminunc funcCount=%d\n", OUTPUT.funcCount);

% Create the output polynomials
ab0=ab0(:);
Da0=[1;ab0(1:ma)];
Db0=[1;ab0((ma+1):end)];
D0=conv(Da0,Db0);
N0=0.5*(conv(flipud(Da0),Db0)-conv(flipud(Db0),Da0));

% Calculate response
nplot=512;
[Ha0,wplot]=freqz(flipud(Da0),Da0,nplot);
[Hb0,wplot]=freqz(flipud(Db0),Db0,nplot);
H0=0.5*(Ha0-Hb0);
P0=unwrap(arg(H0));
Ta0=delayz(flipud(Da0),Da0,nplot);
Tb0=delayz(flipud(Db0),Db0,nplot);
T0=0.5*(Ta0+Tb0);

% Plot response
subplot(311);
plot(wplot*0.5/pi,20*log10(abs(H0)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 5]);
grid("on");
strt=sprintf("Parallel all-pass filters : ma=%d,mb=%d,td=%g,pd=%d(rad./$\\pi$)",
             ma,mb,td,pd);
title(strt);
subplot(312);
plot(wplot*0.5/pi,((P0+(wplot*td))/pi));
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 0 2]);
grid("on");
subplot(313);
plot(wplot*0.5/pi,T0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 2*td]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
minf=min([fapl,ftpl,fppl]);
maxf=max([fapu,ftpu,fppu]);
subplot(311);
plot(wplot*0.5/pi,20*log10(abs(H0)));
ylabel("Amplitude(dB)");
axis([minf maxf -0.4 0.1]);
grid("on");
title(strt);
subplot(312);
plot(wplot*0.5/pi,pd-((P0+(wplot*td))/pi));
ylabel("Phase error(rad./$\\pi$)");
axis([minf maxf -0.001 0.001]);
grid("on");
subplot(313);
plot(wplot*0.5/pi,T0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([minf maxf td+[-0.1 0.1]]);
grid("on");
print(strcat(strf,"_response_passband"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(roots(N0),roots(D0));
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Plot phase response
plot(wplot*0.5/pi,(unwrap(arg(Ha0))+(wplot*td))/pi,"-", ...
     wplot*0.5/pi,(unwrap(arg(Hb0))+(wplot*td))/pi,"--");
strt=sprintf("Allpass phase response adjusted for linear phase : \
ma=%d,mb=%d,td=%g",ma,mb,td);
title(strt);
ylabel("Linear phase error(rad./$\\pi$)");
xlabel("Frequency");
legend("Filter A","Filter B","location","northwest");
legend("boxoff");
grid("on");
print(strcat(strf,"_phase"),"-dpdflatex");
close

% Save the result
print_polynomial(Da0,"Da0");
print_polynomial(Da0,"Da0",strcat(strf,"_Da0_coef.m"));
print_polynomial(Db0,"Db0");
print_polynomial(Db0,"Db0",strcat(strf,"_Db0_coef.m"));
print_polynomial(N0,"N0");
print_polynomial(D0,"D0");
eval(sprintf("save %s.mat tol maxiter ma mb ...\n\
     fasl fapl fapu fasu Wasl Watl Wap Watu Wasu ...\n\
     ftpl ftpu td Wtp fppl fppu pd Wpp abi ab0 Da0 Db0 N0 D0",strf));

% Done
toc;
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));
