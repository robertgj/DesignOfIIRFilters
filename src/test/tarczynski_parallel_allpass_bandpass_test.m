% tarczynski_parallel_allpass_bandpass_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen
%
% Use the method of Tarczynski et al to design a bandpass filter as the
% difference of two parallel allpass filters. See:
% "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

strf="tarczynski_parallel_allpass_bandpass_test";

delete(strcat(strf,".diary",strf));
delete(strcat(strf,".diary.tmp",strf));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Filter specification
maxiter=20000
tol=1e-8
% Initial filter for parallel_allpass_bandpass_test.m
ma=mb=10
td=16
fasl=0.05,ftpl=0.09,fapl=0.10,fapu=0.20,ftpu=0.21,fasu=0.25
Wasl=20,Watl=0.01,Wap=1,Wtp=0.5,Watu=0.01,Wasu=10

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
abi=[1;zeros(ma-1,1);1;zeros(mb-1,1)];
WISEJ_PAB([],ma,mb,Ad,Wa,Td,Wt);
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
[H0,wplot]=freqz(N0,D0,nplot);
T0=delayz(N0,D0,nplot);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H0)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("Parallel all-pass filters : ma=%d,mb=%d,td=%g",ma,mb,td);
title(strt);
subplot(212);
plot(wplot*0.5/pi,T0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 2*td]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H0)));
ylabel("Amplitude(dB)");
axis([min(fapl,ftpl) max(fapu,ftpu) -3 1]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,T0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([min(fapl,ftpl) max(fapu,ftpu) (td-0.1) (td+0.1)]);
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
Ha=freqz(flipud(Da0),Da0,nplot);
Hb=freqz(flipud(Db0),Db0,nplot);
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
print_polynomial(Da0,"Da0");
print_polynomial(Da0,"Da0",strcat(strf,"_Da0_coef.m"));
print_polynomial(Db0,"Db0");
print_polynomial(Db0,"Db0",strcat(strf,"_Db0_coef.m"));
print_polynomial(N0,"N0");
print_polynomial(D0,"D0");
eval(sprintf("save %s.mat ma mb abi ab0 Da0 Db0 N0 D0",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
