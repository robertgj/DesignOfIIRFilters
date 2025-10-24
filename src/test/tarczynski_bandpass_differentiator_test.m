% tarczynski_bandpass_differentiator_test.m
% Copyright (C) 2025 Robert G. Jenssen
%
% Design a bandpass differentiator using the method of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

strf="tarczynski_bandpass_differentiator_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Filter specification
tol=1e-8;
maxiter=20000;
R=1;
nN=11;nD=nN;
fasl=0.05,fapl=0.1,fapu=0.2,fasu=0.25,Wasl=10,Watl=0.01,Wap=1,Watu=0.01,Wasu=10
ftpl=0.1,ftpu=0.2,tp=12,Wtp=1
fppl=0.1,fppu=0.2,pp=0;Wpp=1

% Frequency points
n=1000;
f=0.5*(1:(n-1))'/n;
wd=2*pi*f;
nasl=ceil(fasl*n/0.5);
napl=ceil(fapl*n/0.5);
napu=floor(fapu*n/0.5);
nasu=floor(fasu*n/0.5);

% Frequency vectors
Hd=[zeros(napl-1,1); ...
    -j*(wd(napl:napu)/2).*exp(-j*tp*wd(napl:napu));
    zeros(n-1-napu,1);];
Hzsqm1=2*j*sin(wd).*exp(-j*wd);
Tzsqm1=1;
Wd=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-1-nasu+1,1)];

% Unconstrained minimisation
NDI=[1;zeros(nN+nD,1)];
WISEJ([],nN,nD,R,wd,Hd./Hzsqm1,Wd);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ND0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ,NDI,opt);
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
H=Hc.*Hzsqm1;
Tc=delayz(N0,D0R,wplot);
T=Tc+Tzsqm1;

% Plot response
subplot(311);
plot(wplot*0.5/pi,abs([H,Hd]));
axis([0 0.5 0 1]);
ylabel("Amplitude");
grid("on");
s=sprintf("Tarczynski et al. bandpass differentiator : nN=%d,nD=%d,R=%d,tp=%g", ...
          nN,nD,R,tp);
title(s);
subplot(312);
plot(wplot*0.5/pi,([unwrap(angle(H)),unwrap(angle(Hd))+(pp*pi)]+(wplot*tp))/pi);
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
grid("on");
subplot(313);
plot(wplot*0.5/pi,[T,tp*ones(size(T))]);
axis([0 0.5 0 2*tp ]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot errors
subplot(311);
plot(wplot*0.5/pi,abs(H-Hd));
axis([0 0.5 0 0.04]);
ylabel("Amplitude");
grid("on");
s=sprintf ...
    ("Tarczynski et al. bandpass differentiator error : nN=%d,nD=%d,R=%d,tp=%g",
     nN,nD,R,tp);
title(s);
subplot(312);
plot(wplot*0.5/pi,(unwrap(angle(H))-(unwrap(angle(Hd))+(pp*pi)))/pi);
axis([0 0.5 -0.04 0.04]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wplot*0.5/pi,T-tp)
axis([0 0.5 -1 1]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
zticks([]);
print(strcat(strf,"_error_response"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(qroots(N0),qroots(D0R));
title(s);
zticks([]);
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
