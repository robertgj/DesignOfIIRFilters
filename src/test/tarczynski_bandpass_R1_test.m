% tarczynski_bandpass_R1_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen
%
% Use the method of Tarczynski et al to design a bandpass filter. See:
% "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

strf="tarczynski_bandpass_R1_test";

delete(strcat(strf,".diary",strf));
delete(strcat(strf,".diary.tmp",strf));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Filter specification
maxiter=10000
tol=1e-10
N=20
R=1
td=16
fasl=0.05,fapl=0.10,fapu=0.20,fasu=0.25
Wasl=2,Watl=0.01,Wap=1,Watu=0.01,Wasu=1

% Frequency points
n=1000;
w=pi*(0:(n-1))'/n;
% Desired amplitude response
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Hd=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)].*exp(-j*w*td);
Wd=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];

% Find the initial band-pass filter (working around inaccuracies)
M=12;
[Ni,Di]=butter(M/2,2*[fapl fapu],"bandpass");
Ni=[Ni(:);zeros(N-M,1)];
Di=[Di(:);zeros(N-M,1)];

% Unconstrained minimisation
NDi=[Ni;Di(2:end)];
WISEJ([],N,N,R,w,Hd,Wd);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ND0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ,NDi,opt);
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
ND0=ND0(:);
N0=[ND0(1:(N+1))];
D0=[1;ND0((N+2):end)];

% Calculate initial response
nplot=512;
[Hi,wplot]=freqz(Ni,Di,nplot);
Ti=delayz(Ni,Di,nplot);

% Plot initial response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hi)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("Initial band-pass R=1 filter");
title(strt);
subplot(212);
plot(wplot*0.5/pi,Ti);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 30]);
grid("on");
print(strcat(strf,"_initial"),"-dpdflatex");
close

% Calculate response
[H0,wplot]=freqz(N0,D0,nplot);
T0=delayz(N0,D0,nplot);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H0)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("Band-pass R=1 filter : td=%g",td);
title(strt);
subplot(212);
plot(wplot*0.5/pi,T0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 30]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H0)));
ylabel("Amplitude(dB)");
axis([fapl fapu -3 1]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,T0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([fapl fapu td+2*[-1,1]]);
grid("on");
print(strcat(strf,"_response_passband"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(qroots(N0),qroots(D0));
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Save the result
print_polynomial(N0,"N0");
print_polynomial(N0,"N0",strcat(strf,"_N0_coef.m"));
print_polynomial(D0,"D0");
print_polynomial(D0,"D0",strcat(strf,"_D0_coef.m"));
eval(sprintf(strcat("save %s.mat N R td fasl fapl fapu fasu ",
                    " Wasl Watl Wap Watu Wasu M Ni Di N0 D0"),strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
