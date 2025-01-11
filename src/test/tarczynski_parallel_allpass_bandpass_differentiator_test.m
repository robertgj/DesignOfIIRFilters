% tarczynski_parallel_allpass_bandpass_differentiator_test.m
% Copyright (C) 2025 Robert G. Jenssen
%
% Use the method of Tarczynski et al to design a bandpass differentiator filter
% as the difference of two parallel allpass filters. See:
% "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

strf="tarczynski_parallel_allpass_bandpass_differentiator_test";

delete(strcat(strf,".diary",strf));
delete(strcat(strf,".diary.tmp",strf));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Filter specification
tol=1e-8
maxiter=5000
fasl=0.05,fapl=0.1,fapu=0.22,fasu=0.25
Wasl=10,Watl=0.01,Wap=10,Watu=0.05,Wasu=20
fppl=0.1,fppu=0.22,pp=0.5,Wpp=1
ftpl=0.1,ftpu=0.22,tp=10,Wtp=0.5

% Frequency points
n=1000;
f=0.5*(1:(n-1))'/n;
w=2*pi*f;

% Initial filter
ma=11;
mb=11;
abi=[1;zeros(ma+mb-1,1)];
Azsqm1=2*sin(w);
Tzsqm1=1;
Pzsqm1=(pi/2)-w;
Hzsqm1=2*j*exp(-j*w).*sin(w);

% Desired amplitude response
nasl=ceil(n*fasl/0.5);
napl=floor(n*fapl/0.5);
napu=ceil(n*fapu/0.5);
nasu=floor(n*fasu/0.5);
Ad=[zeros(napl-1,1);w(napl:napu)/2;zeros(n-1-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-1-nasu+1,1)];

% Desired phase response
nppl=floor(n*fppl/0.5);
nppu=ceil(n*fppu/0.5);
Pd=(pp*pi)-(tp*w);
Wp=[zeros(nppl-1,1);
    Wpp*ones(nppu-nppl+1,1); ...
    zeros(n-1-nppu,1)];

% Desired delay response
ntpl=floor(n*ftpl/0.5);
ntpu=ceil(n*ftpu/0.5);
Td=tp*ones(n-1,1);
Wt=[zeros(ntpl-1,1);
    Wtp*ones(ntpu-ntpl+1,1); ...
    zeros(n-1-ntpu,1)];

% Sanity checks
nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napl+1,napu-1,napu,napu+1, ...
       nasu-1,nasu,nasu+1]';
printf("0.5*w(nchka)'/pi=[ ");printf("%6.4g ",0.5*w(nchka)'/pi);printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

nchkt=[ntpl-1,ntpl,ntpl+1,ntpu-1,ntpu,ntpu+1];
printf("0.5*w(nchkt)'/pi=[ ");printf("%6.4g ",0.5*w(nchkt)'/pi);printf("];\n");
printf("Wt(nchkt)=[ ");printf("%6.4g ",Wt(nchkt)');printf("];\n");

nchkp=[nppl-1,nppl,nppl+1,nppu-1,nppu,nppu+1];
printf("0.5*w(nchkp)'/pi=[ ");printf("%6.4g ",0.5*w(nchkp)'/pi);printf("];\n");
printf("Wp(nchkp)=[ ");printf("%6.4g ",Wp(nchkp)');printf("];\n");

% Unconstrained minimisation
WISEJ_PAB([],ma,mb,Ad./Azsqm1,Wa,Td-Tzsqm1,Wt,Pd-Pzsqm1,Wp);
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
Ha0=freqz(flipud(Da0),Da0,w);
Hb0=freqz(flipud(Db0),Db0,w);
Hab0=0.5*(Ha0-Hb0);
H0=Hab0.*Hzsqm1;
P0=unwrap(arg(H0));
Ta0=delayz(flipud(Da0),Da0,w);
Tb0=delayz(flipud(Db0),Db0,w);
Tab0=(0.5*(Ta0+Tb0));
T0=Tab0+Tzsqm1;

% Plot response
subplot(311);
plot(w*0.5/pi,[Ad,abs(H0)]);
ylabel("Amplitude");
axis([0 0.5 0 1]);
grid("on");
strt=sprintf("Parallel all-pass filters : ma=%d,mb=%d,tp=%g,pp=%g",
             ma,mb,tp,pp);
title(strt);
subplot(312);
plot(w*0.5/pi,(P0+(w*tp))/pi);
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 0 1]);
grid("on");
subplot(313);
plot(w*0.5/pi,T0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 20]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response error
minf=min([fapl,ftpl,fppl]);
maxf=max([fapu,ftpu,fppu]);
subplot(311);
plot(w*0.5/pi,Ad-abs(H0));
ylabel("Amplitude");
axis([minf maxf 0.1*[-1,1]]);
grid("on");
strt=sprintf("Parallel all-pass filters error : ma=%d,mb=%d,tp=%g,pp=%g",
             ma,mb,tp,pp);
title(strt);
subplot(312);
plot(w*0.5/pi,(P0-Pd)/pi);
ylabel("Phase(rad./$\\pi$)");
axis([minf maxf 0.02*[-1 1]]);
grid("on");
subplot(313);
plot(w*0.5/pi,T0-tp);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([minf maxf 0.2*[-1 1]]);
grid("on");
print(strcat(strf,"_passband_error"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(qroots(N0),qroots(D0));
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Plot phase response
plot(w*0.5/pi,(unwrap(arg(Ha0))+(w*(tp-Tzsqm1)))/pi,"-", ...
     w*0.5/pi,(unwrap(arg(Hb0))+(w*(tp-Tzsqm1)))/pi,"--");
strt=sprintf("Allpass phase response adjusted for linear phase : \
ma=%d,mb=%d,tp=%g",ma,mb,tp);
title(strt);
ylabel("Linear phase error(rad./$\\pi$)");
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
print_polynomial(N0,"N0",strcat(strf,"_N0_coef.m"));
print_polynomial(D0,"D0");
print_polynomial(D0,"D0",strcat(strf,"_D0_coef.m"));

eval(sprintf("save %s.mat tol maxiter ma mb ...\n\
     fasl fapl fapu fasu Wasl Watl Wap Watu Wasu ...\n\
     ftpl ftpu tp Wtp fppl fppu pp Wpp abi ab0 Da0 Db0 N0 D0",strf));

% Done
toc;
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));
