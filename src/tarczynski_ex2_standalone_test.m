% tarczynski_ex2_standalone_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Design a filter implementing the response of Example 2 of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432
%
% This standalone version only uses Octave functions

test_common;

unlink("tarczynski_ex2_standalone_test.diary");
unlink("tarczynski_ex2_standalone_test.diary.tmp");
diary tarczynski_ex2_standalone_test.diary.tmp

strf="tarczynski_ex2_standalone_test";

warning("error","Octave:nonconformant-args");
warning("error","Octave:undefined-return-values");
warning("error","Octave:broadcast");
warning("error","Octave:divide-by-zero");
warning("error","Octave:possible-matlab-short-circuit-operator");

% Filter specification
transf=0.02;
f1=0.5-transf;f2=0.5+transf;
a1=1;a2=0.5;
t1=14.3;t2=20;
R=2;nN=24;nD=2;
tol=1e-9;
maxiter=10000;

% Frequency points
n=1024;
wd=pi*(0:(n-1))'/n;
% Transition band
bw=round((0.5-transf)*n);
bt=n-(2*bw);
vbw=(0:(bt-1))'/bt;
% Frequency vectors
Ha=[a1*ones(n/2,1);a2*ones(n/2,1)];
Ht=[t1*ones(n/2,1);t2*ones(n/2,1)];
Hd=Ha.*exp(-j*wd.*Ht);
Wd=[10*ones(bw,1); ones(bt,1); 50*ones(bw,1)];

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
N0=ND0(:);
N0=ND0(1:(nN+1));
D0=[1; ND0((nN+2):end)];
D0R=[D0(1);kron(D0(2:end), [zeros(R-1,1);1])];

% Plot results
nplot=512;
[H,wplot]=freqz(N0,D0R,nplot);
T=grpdelay(N0',D0R',nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([0 0.5 -8 2]);
grid("on");
s=sprintf("Tarczynski et al. Example 2 : nN=%d,nD=%d,R=%d",nN,nD,R);
title(s);
subplot(212);
plot(wplot*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 10 25]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

subplot(111);
zplane(roots(N0),roots(D0R))
title(s);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Print results
print_polynomial(N0,"N0");
print_polynomial(N0,"N0",strcat(strf,"_N0_coef.m"));
print_polynomial(D0,"D0");
print_polynomial(D0,"D0",strcat(strf,"_D0_coef.m"));

% Save the result
save tarczynski_ex2_standalone_test.mat a1 a2 t1 t2 transf nN nD R N0 D0 D0R

diary off
movefile tarczynski_ex2_standalone_test.diary.tmp ...
         tarczynski_ex2_standalone_test.diary;
