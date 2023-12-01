% tarczynski_parallel_allpass_bandpass_hilbert_test.m
% Copyright (C) 2017-2023 Robert G. Jenssen
%
% Use the method of Tarczynski et al to design a bandpass Hilbert filter
% as the difference of two parallel allpass filters. See:
% "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

% Disable group delay warnings
warning("off");

delete("tarczynski_parallel_allpass_bandpass_hilbert_test.diary");
delete("tarczynski_parallel_allpass_bandpass_hilbert_test.diary.tmp");
diary tarczynski_parallel_allpass_bandpass_hilbert_test.diary.tmp

tic;

strf="tarczynski_parallel_allpass_bandpass_hilbert_test";

% Initialise with the result of tarczynski_parallel_allpass_bandpass_test.m
% Note that the initial filters are swapped to get the desired passband phase
Db0 = [   1.0000000000,  -1.8896420762,   1.1851087257,   1.1354840927, ... 
         -2.5805074455,   2.1148671967,  -0.3997762976,  -0.8276413628, ... 
          1.0054762267,  -0.5159272604,   0.1296151332 ]';
Da0 = [   1.0000000000,  -1.3249813230,   0.8978004911,   0.8919687861, ... 
         -1.9646494147,   1.7116313675,  -0.3716958949,  -0.6039880527, ... 
          0.8116637093,  -0.4321107682,   0.1379462636 ]';

% Filter specification
tol=1e-6
maxiter=5000
ma=length(Da0)-1
mb=length(Db0)-1
fasl=0.05,fapl=0.1,fapu=0.2,fasu=0.25,Wasl=10,Watl=0.1,Wap=5,Watu=0.1,Wasu=5
ftpl=0.11,ftpu=0.19,td=16,tdr=0.2,Wtp=1
fppl=0.11,fppu=0.19,pd=1.5,pdr=0.002,Wpp=10

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
ab0 = [Da0(2:end);Db0(2:end)];
WISEJ_PAB([],ma,mb,Ad,Wa,Td,Wt,Pd,Wp);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ab1,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_PAB,ab0,opt);
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
ab1=ab1(:);
Da=[1;ab1(1:ma)];
Db=[1;ab1((ma+1):end)];
D=conv(Da,Db);
N=0.5*(conv(flipud(Da),Db)-conv(flipud(Db),Da));

% Calculate response
nplot=512;
[H,wplot]=freqz(N,D,nplot);
P=unwrap(arg(H));
T=delayz(N,D,nplot);

% Plot response
subplot(311);
plot(wplot*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 5]);
grid("on");
strt=sprintf("Parallel all-pass filters : ma=%d,mb=%d,td=%g",ma,mb,td);
title(strt);
subplot(312);
plot(wplot*0.5/pi,mod((P+(wplot*td))/pi,2));
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 0 2]);
grid("on");
subplot(313);
plot(wplot*0.5/pi,T);
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
plot(wplot*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([minf maxf -0.3 0.1]);
grid("on");
title(strt);
subplot(312);
plot(wplot*0.5/pi,(P+(wplot*td))/pi);
ylabel("Phase(rad./$\\pi$)");
axis([minf maxf 1.5-pdr 1.5+pdr]);
grid("on");
subplot(313);
plot(wplot*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([minf maxf (td-tdr) (td+tdr)]);
grid("on");
print(strcat(strf,"_response_passband"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(roots(N),roots(D));
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Plot phase response
Ha=freqz(flipud(Da),Da,nplot);
Hb=freqz(flipud(Db),Db,nplot);
plot(wplot*0.5/pi,(unwrap(arg(Ha))+(wplot*td))/pi,"-", ...
     wplot*0.5/pi,(unwrap(arg(Hb))+(wplot*td))/pi,"--");
strt=sprintf("Allpass phase response error from linear phase (-w*td): \
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
print_polynomial(Da,"Da0");
print_polynomial(Da,"Da0",strcat(strf,"_Da0_coef.m"));
print_polynomial(Db,"Db0");
print_polynomial(Db,"Db0",strcat(strf,"_Db0_coef.m"));
print_polynomial(N,"N");
print_polynomial(D,"D");
save tarczynski_parallel_allpass_bandpass_hilbert_test.mat ...
     tol maxiter ma mb ...
     fasl fapl fapu fasu Wasl Watl Wap Watu Wasu ...
     ftpl ftpu td Wtp ...
     fppl fppu pd Wpp ...
     ab0 ab1 Da Db N D

% Done
toc;
diary off
movefile tarczynski_parallel_allpass_bandpass_hilbert_test.diary.tmp ...
         tarczynski_parallel_allpass_bandpass_hilbert_test.diary;
