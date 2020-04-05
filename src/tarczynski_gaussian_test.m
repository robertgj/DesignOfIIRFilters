% tarczynski_gaussian_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Design a Gaussian filter using the method of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

delete("tarczynski_gaussian_test.diary");
delete("tarczynski_gaussian_test.diary.tmp");
diary tarczynski_gaussian_test.diary.tmp

tic

% Filter specification
tol=1e-10;
sf=0.5;
if 0
  nN=13;nD=0;R=0;td=6.5;
elseif 1
  nN=8;nD=4;R=2;td=5.35;
else
  nN=16;nD=8;R=2;td=9.25;
endif

% Frequency vectors
n=256;
wd=pi*(0:(n-1))'/n;
Hd=exp(-(j*td*wd)-((wd.^2)/(2*sf*sf)));
Wd=ones(size(wd));

% Unconstrained minimisation
NI=[1;ones(nN+nD,1)];
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
printf("Function value=%10.7f\n", FVEC);
printf("fminunc iterations=%d\n", OUTPUT.iterations);
printf("fminunc successful=%d??\n", OUTPUT.successful);
printf("fminunc funcCount=%d\n", OUTPUT.funcCount);

% Create the output polynomials
ND0=ND0(:);
N0=ND0(1:(nN+1));
if nD==0
  D0=1;
  D0R=1;
else
  D0=[1;ND0((nN+2):end)];
  D0R=[D0(1);kron(D0(2:end),[zeros(R-1,1);1])];
endif

% Plot results
nplot=n;
[H,wplot]=freqz(N0',D0R',nplot);
T=grpdelay(N0',D0R',nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)),"-",wplot*0.5/pi,20*log10(abs(Hd)),"--");
ylabel("Amplitude(dB)");
axis([0 0.5 -100 10]);
legend("WISE","Gaussian");
legend("boxoff")
legend("location","northeast")
grid("on");
s=sprintf("Tarczynski et al. gaussian : nN=%d,nD=%d,R=%d,td=%g",nN,nD,R,td);
title(s);
subplot(212);
plot(wplot*0.5/pi,T);
ylabel("Group delay(samples)");
axis([0 0.5 td-1 td+1 ]);
xlabel("Frequency");
grid("on");
print("tarczynski_gaussian_response","-dpdflatex");
close
% Response error
subplot(111);
plot(wplot*0.5/pi,abs(H)-abs(Hd));
ylabel("Amplitude Error");
xlabel("Frequency");
grid("on");
s=sprintf("Tarczynski et al. gaussian : nN=%d,nD=%d,R=%d,td=%g",nN,nD,R,td);
title(s);
grid("on");
print("tarczynski_gaussian_response_error",  "-dpdflatex");
close
% Pole-zero plot
subplot(111);
zplane(roots(N0),roots(D0R));
title(s);
print("tarczynski_gaussian_pz",  "-dpdflatex");
close
% Impulse response
subplot(111);
u=[1;zeros(2*nN,1)];
y=filter(N0,D0R,u);
plot(y);
ylabel("Amplitude");
xlabel("Sample");
title(s);
print("tarczynski_gaussian_impulse",  "-dpdflatex");
close

% Save the result
print_polynomial(N0,"N0");
print_polynomial(N0,"N0","tarczynski_gaussian_test_N0_coef.m");
print_polynomial(D0,"D0");
print_polynomial(D0,"D0","tarczynski_gaussian_test_D0_coef.m");

toc;

save tarczynski_gaussian_test.mat nN nD R N0 D0 D0R

diary off
movefile tarczynski_gaussian_test.diary.tmp tarczynski_gaussian_test.diary;
