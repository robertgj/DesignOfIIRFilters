% tarczynski_parallel_allpass_bandpass_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen
%
% Use the method of Tarczynski et al to design a bandpass filter as the
% difference of two parallel allpass filters. See:
% "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

% Disable group delay warnings
warning("off");

delete("tarczynski_parallel_allpass_bandpass_test.diary");
delete("tarczynski_parallel_allpass_bandpass_test.diary.tmp");
diary tarczynski_parallel_allpass_bandpass_test.diary.tmp

tic;

strf="tarczynski_parallel_allpass_bandpass_test";

% Filter specification
maxiter=20000
tol=1e-8
% Initial filter for parallel_allpass_bandpass_test.m
fasl=0.05,fapl=0.1,fapu=0.2,fasu=0.25,Watl=0.1,Wap=1,Watu=0.1
ma=mb=10,td=16,Wasl=10,Wasu=10,Wtp=1,ftpl=0.09,ftpu=0.21

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

% Unconstrained minimisation
ab0=[1;zeros(ma-1,1);1;zeros(mb-1,1)];
WISEJ_PAB([],ma,mb,Ad,Wa,Td,Wt);
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
T=grpdelay(N,D,nplot);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("Parallel all-pass filters : ma=%d,mb=%d,td=%g",ma,mb,td);
title(strt);
subplot(212);
plot(wplot*0.5/pi,T);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 2*td]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([min(fapl,ftpl) max(fapu,ftpu) -3 1]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,T);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([min(fapl,ftpl) max(fapu,ftpu) (td-0.1) (td+0.1)]);
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
plot(wplot*0.5/pi,unwrap(arg(Ha))+(wplot*td),"-", ...
     wplot*0.5/pi,unwrap(arg(Hb))+(wplot*td),"--");
strt=sprintf("Allpass phase response error from linear phase (-w*td): \
ma=%d,mb=%d,td=%g",ma,mb,td);
title(strt);
ylabel("Linear phase error(rad.)");
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
save tarczynski_parallel_allpass_bandpass_test.mat ma mb ab0 ab1 Da Db N D

% Done
toc;
diary off
movefile tarczynski_parallel_allpass_bandpass_test.diary.tmp ...
         tarczynski_parallel_allpass_bandpass_test.diary;
