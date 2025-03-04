% tarczynski_pink_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Design a full-band pink noise filter using the method of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

delete("tarczynski_pink_test.diary");
delete("tarczynski_pink_test.diary.tmp");
diary tarczynski_pink_test.diary.tmp

tic

% Filter specification
R=1;nN=11;nD=11;td=(nN-1)/2;tol=1e-9;maxiter=5000;

% Frequency points
n=1000;
wd=pi*(10:(n-1))'/n;

% Frequency vectors
Hd=(0.1*exp(-j*td*wd)./sqrt(0.5*wd/pi));
Wd=ones(size(wd));

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
nplot=1024;
[H,wplot]=freqz(N0,D0R,nplot);
T=delayz(N0',D0R',nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
hold on
plot(wd*0.5/pi,20*log10(abs(Hd)));
ylabel("Amplitude error");
grid("on");
s=sprintf("Tarczynski et al. pink : nN=%d,nD=%d,R=%d,td=%g",
          nN,nD,R,td);
title(s);
subplot(212);
plot(wplot*0.5/pi,T);
ylabel("Delay(samples)");
axis([0 0.5 0 10 ]);
xlabel("Frequency");
grid("on");
print("tarczynski_pink_test_response",  "-dpdflatex");
close

subplot(111);
zplane(qroots(N0),qroots(D0R));
title(s);
print("tarczynski_pink_test_pz",  "-dpdflatex");
close

% Save the result
print_polynomial(N0,"N0");
print_polynomial(N0,"N0","tarczynski_pink_test_N0_coef.m");
print_polynomial(D0,"D0");
print_polynomial(D0,"D0","tarczynski_pink_test_D0_coef.m");
toc;

save tarczynski_pink_test.mat nN nD R N0 D0 D0R

diary off
movefile tarczynski_pink_test.diary.tmp tarczynski_pink_test.diary;
