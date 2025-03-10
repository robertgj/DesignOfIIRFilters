% tarczynski_lowpass_differentiator_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen
%
% Design a lowpass differentiator using the method of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

strf="tarczynski_lowpass_differentiator_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Filter specification
fap=0.3;fas=0.4;Wap=1;Wat=0.01;Was=1;
R=1;nN=11;nD=floor(nN/R);tp=nN-1;
tol=1e-8;maxiter=20000;

% Frequency points
n=1000;
wd=pi*(1:(n-1))'/n;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);

% Frequency vectors
Hzm1=freqz([1;-1],1,wd)(:);
Hd=[-j*(wd(1:nap)/2).*exp(-j*tp*wd(1:nap)); zeros(n-nap-1,1)];
Wd=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas,1)];

nchk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nchk=[");printf("%d ",nchk);printf(" ]\n");
printf("fd(nchk)=[");printf("%g ",wd(nchk)*0.5/pi);printf(" ]\n");
printf("Hd(nchk)=[");printf("%g ",abs(Hd(nchk)));printf(" ]\n");
printf("Wd(nchk)=[");printf("%g ",Wd(nchk));printf(" ]\n");

% Unconstrained minimisation
NI=[1;zeros(nN+nD,1)];
WISEJ([],nN,nD,R,wd,Hd./Hzm1,Wd);
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

% Calculate response
wplot=wd;
Hc=freqz(N0,D0R,wplot);
H=Hc.*Hzm1;
Tc=delayz(N0,D0R,wplot);
T=Tc+0.5;

% Plot response
subplot(311);
plot(wplot*0.5/pi,abs(H));
axis([0 0.5 0 1]);
ylabel("Amplitude");
grid("on");
s=sprintf("Tarczynski et al. lowpass differentiator : nN=%d,nD=%d,R=%d,tp=%g",
          nN,nD,R,tp);
title(s);
subplot(312);
plot(wplot*0.5/pi,(unwrap(angle(H))+(wplot*tp))/pi);
axis([0 0.5]);
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
grid("on");
subplot(313);
plot(wplot*0.5/pi,T);
axis([0 0.5 0 2*tp ]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot errors
subplot(311);
plot(wplot*0.5/pi,abs(H)-abs(Hd));
axis([0 0.5 -0.01 0.01]);
ylabel("Amplitude");
grid("on");
s=sprintf ...
    ("Tarczynski et al. lowpass differentiator error : nN=%d,nD=%d,R=%d,tp=%g",
          nN,nD,R,tp);
title(s);
subplot(312);
plot(wplot*0.5/pi,unwrap(angle(H)-angle(Hd))/pi);
axis([0 0.5 -0.01 0.01]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wplot*0.5/pi,T-tp)
axis([0 0.5 -0.2 0.2]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_error_response"),"-dpdflatex");
close

% Plot correction filter response
subplot(311);
plot(wplot*0.5/pi,abs(Hc));
axis([0 0.5 0 1]);
ylabel("Amplitude");
grid("on");
s=sprintf(["Tarczynski et al. lowpass_differentiator correction : ", ...
 "nN=%d,nD=%d,R=%d,tp=%g"],nN,nD,R,tp);
title(s);
subplot(312);
plot(wplot*0.5/pi,(unwrap(angle(Hc))+(wplot*(tp-0.5)))/pi);
axis([0 0.5]);
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
grid("on");
subplot(313);
plot(wplot*0.5/pi,Tc);
axis([0 0.5 0 2*tp]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_correction_response"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(qroots(conv([1;-1],N0)),qroots(D0R));
title(s);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Save the result
print_polynomial(N0,"N0");
print_polynomial(N0,"N0",strcat(strf,"_N0_coef.m"));
print_polynomial(D0,"D0");
print_polynomial(D0,"D0",strcat(strf,"_D0_coef.m"));

eval(sprintf("save %s.mat nN nD R N0 D0 D0R",strf));

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
