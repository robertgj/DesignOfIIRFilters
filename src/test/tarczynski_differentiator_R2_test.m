% tarczynski_differentiator_R2_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Design a full-band differentiator using the method of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

delete("tarczynski_differentiator_R2_test.diary");
delete("tarczynski_differentiator_R2_test.diary.tmp");
diary tarczynski_differentiator_R2_test.diary.tmp

% Filter specification
R=2;nN=8;nD=4;td=5.5;tol=1e-5;maxiter=5000;

% Frequency points
n=200;
wd=pi*(0:(n-1))'/n;

% Frequency vectors
Hd=(-j*wd/pi).*exp(-j*td*wd);
Wd=ones(n,1);

% Unconstrained minimisation
NDi=[1;zeros(nN+nD,1)];
WISEJ([],nN,nD,R,wd,Hd,Wd);
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
nplot=512;
[H,wplot]=freqz(N0,D0R,nplot);
T=delayz(N0',D0R',nplot);
subplot(211);
plot(wplot*0.5/pi,abs(H)-wplot/pi);
axis([0 0.5 -0.01 0.01]);
ylabel("Amplitude error");
grid("on");
s=sprintf("Tarczynski et al. differentiator : nN=%d,nD=%d,R=%d,td=%g", ...
          nN,nD,R,td);
title(s);
subplot(212);
plot(wplot*0.5/pi,(unwrap(arg(H))+(pi/2)+(wplot*td))/pi);
axis([0 0.5 -0.01 0.01 ]);
ylabel("Phase error(rad./$\\pi$)");
xlabel("Frequency");
grid("on");
zticks([]);
print("tarczynski_differentiator_R2_test_response",  "-dpdflatex");
close

subplot(111);
zplane(qroots(N0),qroots(D0R));
title(s);
zticks([]);
print("tarczynski_differentiator_R2_test_pz",  "-dpdflatex");
close

% Save the result
print_polynomial(N0,"N0");
print_polynomial(N0,"N0","tarczynski_differentiator_R2_test_N0_coef.m");
print_polynomial(D0,"D0");
print_polynomial(D0,"D0","tarczynski_differentiator_R2_test_D0_coef.m");

save tarczynski_differentiator_R2_test.mat nN nD R NDi N0 D0 D0R

diary off
movefile tarczynski_differentiator_R2_test.diary.tmp ...
         tarczynski_differentiator_R2_test.diary;
