% tarczynski_lowpass_differentiator_test.m
% Copyright (C) 2020-2021 Robert G. Jenssen
%
% Design a lowpass differentiator using the method of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

delete("tarczynski_lowpass_differentiator_test.diary");
delete("tarczynski_lowpass_differentiator_test.diary.tmp");
diary tarczynski_lowpass_differentiator_test.diary.tmp

% Filter specification
fap=0.25;fas=0.3;Wap=1;Wat=0.1;Was=1;
R=1;nN=10;nD=floor(nN/R);td=nN-1;
tol=1e-8;maxiter=20000;

% Frequency points
n=1000;
nap=ceil(fap*n/0.5)+1;
nas=ceil(fas*n/0.5)+1;

% Frequency vectors
wd=pi*(0:(n-1))'/n;
Hd=[-j*(wd(1:nap)/pi).*exp(-j*td*wd(1:nap)); ...
    zeros(n-nap,1)];
Wd=[Wap*ones(nap,1); ...
    Wat*ones(nas-nap-1,1); ...
    Was*ones(n-nas+1,1)];
nchk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n];
printf("nchk=[");printf("%d ",nchk);printf(" ]\n");
printf("fd(nchk)=[");printf("%g ",wd(nchk)*0.5/pi);printf(" ]\n");
printf("Hd(nchk)=[");printf("%g ",abs(Hd(nchk)));printf(" ]\n");
printf("Wd(nchk)=[");printf("%g ",Wd(nchk));printf(" ]\n");

% Unconstrained minimisation
NI=[1;zeros(nN+nD,1)];
WISEJ([],nN,nD,R,wd,Hd,Wd);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ND0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ,NI,opt);
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
ND0=ND0(:);
N0=ND0(1:(nN+1));
D0=[1; ND0((nN+2):end)];
D0R=[D0(1);kron(D0(2:end),[zeros(R-1,1);1])];

% Plot results
nplot=n;
[H,wplot]=freqz(N0,D0R,nplot);
T=grpdelay(N0',D0R',nplot);
subplot(211);
plot(wplot*0.5/pi,abs(H)-abs(Hd));
%axis([0 0.5 -0.01 0.01]);
ylabel("Amplitude error");
grid("on");
s=sprintf("Tarczynski et al. lowpass_differentiator : nN=%d,nD=%d,R=%d,td=%g",
          nN,nD,R,td);
title(s);
subplot(212);
% plot(wplot*0.5/pi,T-td); ylabel("Delay error(samples)");
plot(wplot*0.5/pi,(unwrap(arg(H))-(pi/2)+(wplot*td))/pi);
%axis([0 0.5 -0.01 0.01 ]);
ylabel("Phase error(rad./$\\pi$)");
xlabel("Frequency");
grid("on");
print("tarczynski_lowpass_differentiator_response",  "-dpdflatex");
close

subplot(111);
zplane(roots(N0),roots(D0R));
title(s);
print("tarczynski_lowpass_differentiator_pz",  "-dpdflatex");
close

% Save the result
print_polynomial(N0,"N0");
print_polynomial(N0,"N0","tarczynski_lowpass_differentiator_test_N0_coef.m");
print_polynomial(D0,"D0");
print_polynomial(D0,"D0","tarczynski_lowpass_differentiator_test_D0_coef.m");

save tarczynski_lowpass_differentiator_test.mat nN nD R N0 D0 D0R

diary off
movefile tarczynski_lowpass_differentiator_test.diary.tmp ...
         tarczynski_lowpass_differentiator_test.diary;
