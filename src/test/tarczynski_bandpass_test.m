% tarczynski_bandpass_test.m
% Copyright (C) 2017-2023 Robert G. Jenssen


test_common;

pkg load optim;

delete("tarczynski_bandpass_test.diary");
delete("tarczynski_bandpass_test.diary.tmp");
diary tarczynski_bandpass_test.diary.tmp

tic;


% Initial filter (found by trial-and-error)
U=2,V=0,M=18,Q=10,R=2
x0=[ 0.00005, ...
     1, -1, ...
     0.9*ones(1,6), [1 1 1], (11:16)*pi/20, (7:9)*pi/10, ...
     0.81*ones(1,5), (4:8)*pi/10 ]';
[N0,D0]=x2tf(x0,U,V,M,Q,R);
N0=N0/D0(1);
D0=D0/D0(1);
D0R=D0(3:2:end);
ND0=[N0(:);D0R];
nN=length(N0)-1;
nD=length(D0R);

% Frequency points
td=16;
dBas=30;
fapl=0.1;fapu=0.2;fasl=0.05;fasu=0.25;
Wasl=1;Watl=0.001;Wap=1;Watu=0.001;Wasu=1;
n=500;
wd=(0:(n-1))'*pi/n;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Hd=[(10^(-dBas/20))*ones(napl-1,1); ...
    ones(napu-napl+1,1); ...
    (10^(-dBas/20))*ones(n-napu,1)].*exp(-j*wd*td);
Wd=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];

% Unconstrained minimisation
WISEJ([],nN,nD,R,wd,Hd,Wd);
tol=1e-6;
maxiter=10000;
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ND,FVEC,INFO,OUTPUT]=fminunc(@WISEJ,ND0,opt);
if (INFO == 1)
  printf("Converged to a solution point.\n");
elseif (INFO == 2)
  printf("Last relative step size was less that TolX.\n");
elseif (INFO == 3)
  printf("Last relative decrease in function value was less than TolF.\n");
elseif (INFO == 0)
  printf("Iteration limit exceeded.\n");
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
ND=ND(:);
N=ND(1:(nN+1));
D=[1; ND((nN+2):(nN+1+nD))];
DR=[D(1);kron(D(2:length(D)), [zeros(R-1,1);1])];

% Plot results
nplot=512;
[H,wplot]=freqz(N,DR,nplot);
T=delayz(N',DR',nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
s=sprintf("Tarczynski bandpass example : nN=%d,nD=%d,R=%d",nN,nD,R);
title(s);
subplot(212);
plot(wplot*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 25]);
grid("on");
print("tarczynski_bandpass_test_response","-dpdflatex");
close

subplot(111);
zplane(qroots(N),qroots(DR))
title(s);
print("tarczynski_bandpass_test_pz","-dpdflatex");
close

% Print results
print_polynomial(N,"N");
print_polynomial(N,"N","tarczynski_bandpass_test_N_coef.m");
print_polynomial(D,"D");
print_polynomial(D,"D","tarczynski_bandpass_test_D_coef.m");
[x,U,V,M,Q]=tf2x(N,D);
print_pole_zero(x,U,V,M,Q,R,"x");
print_pole_zero(x,U,V,M,Q,R,"x","tarczynski_bandpass_test_x_coef.m");

% Save the result
save tarczynski_bandpass_test.mat U V M Q R x0 fapl fapu fasl fasu ...
     Wap Watl Watu Wasl Wasu td dBas n nN nD R ND N D DR

% Done
toc
diary off
movefile tarczynski_bandpass_test.diary.tmp tarczynski_bandpass_test.diary;
