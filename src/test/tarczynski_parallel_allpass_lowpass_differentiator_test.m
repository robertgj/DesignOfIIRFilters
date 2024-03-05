% tarczynski_parallel_allpass_lowpass_differentiator_test.m
% Copyright (C) 2024 Robert G. Jenssen
%
% Use the method of Tarczynski et al to design a lowpass differentiator filter
% as (z-1) followed by the sum of two parallel allpass filters. See:
% "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

strf="tarczynski_parallel_allpass_lowpass_differentiator_test";

delete(strcat(strf,".diary",strf));
delete(strcat(strf,".diary.tmp",strf));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Filter specification
tol=1e-8;maxiter=20000;
R=1;
polyphase=false;
difference=false;
if difference
  pa_sign=-1;
else
  pa_sign=1;
endif
fap=0.2;fas=0.3;Wap=1;Wat=0.01;Was=2;
ma=11;mb=12;
td=R*(ma+mb+1)/2;Wtp=0.5;Wpp=0.05;

% Frequency points
n=1000;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);
w=pi*(1:n-1)'/n;

% Amplitude response
wa=w;
Azm1=(2*sin(wa/2));
if 1
  Ad=[wa(1:nap)/2;zeros(n-nap-1,1)];
else
  Ad=[w(1:nap)/2; (w(nap)/2)*((nas-nap-1):-1:1)'/(nas-nap-1);zeros(n-nas,1)];
endif
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas,1)];

% Group delay response
wt=w(1:nap);
Tzm1=0.5*ones(size(wt));
Td=td*ones(size(wt));
Wt=Wtp*ones(size(wt));

% Phase response
wp=w(1:nap);
Pzm1=(pi/2)-(wp/2);
Pd=(pi/2)-(wp*td);
Wp=Wpp*ones(size(wp));

% Sanity checks
nchka=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1]';
printf("0.5*w(nchka)'/pi=[ ");printf("%6.4g ",0.5*w(nchka)'/pi);printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Ad(nchka)./Azm1(nchka)=[ ");
printf("%6.4g ",(Ad(nchka)./(sin(w(nchka))/2))');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Unconstrained minimisation with (1-z^(-1)) removed
abi = zeros(ma+mb,1);
WISEJ_PA([],ma,mb,R,polyphase,difference,Ad./Azm1,Wa,Td-Tzm1,Wt,Pd-Pzm1,Wp);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ab0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_PA,abi,opt);
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
N0=0.5*(conv(flipud(Da0),Db0)+(pa_sign*conv(flipud(Db0),Da0)));

% Calculate response
Ha0=freqz(flipud(Da0),Da0,w);
Hb0=freqz(flipud(Db0),Db0,w);
Hzm1=freqz([1;-1],1,w);
H0=0.5*(Ha0+(pa_sign*Hb0)).*Hzm1;
A0=abs(H0);
P0=unwrap(arg(H0(1:nap)));
Ta0=delayz(flipud(Da0),Da0,w(1:nap));
Tb0=delayz(flipud(Db0),Db0,w(1:nap));
T0=((Ta0+Tb0)/2)+Tzm1;
% Alternate calculation
H0a=freqz(N0,D0,w);
A0a=abs(H0a).*Azm1;
P0a=unwrap(arg(H0a(1:nap)))+Pzm1;
T0a=delayz(N0,D0,wt)+Tzm1;
% Check
if max(abs(A0a-A0)) > 100*eps
  error("max(abs(A0a-A0)) > 100*eps");
endif
if max(abs(P0a-P0)) > 200*eps
  error("max(abs(P0a-P0)) > 200*eps");
endif
if max(abs(T0a-T0)) > 2e4*eps
  error("max(abs(T0a-T0)) > 2e4*eps");
endif

% Plot response
subplot(311);
plot(wa*0.5/pi,A0);
ylabel("Amplitude");
axis([0 0.5 0 0.8]);
grid("on");
strt=sprintf("Parallel all-pass filters : ma=%d,mb=%d,fap=%g,fas=%g,td=%g",
             ma,mb,fap,fas,td);
title(strt);
subplot(312);
plot(wp*0.5/pi,(P0+(wp*td))/pi);
ylabel("Phase (rad./$\\pi$)");
axis([0 0.5]);
grid("on");
subplot(313);
plot(wt*0.5/pi,T0);
axis([0 0.5]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot response error
subplot(311);
plot(wa*0.5/pi,A0-Ad);
ylabel("Amplitude error");
axis([0 0.5 -0.1 0.1]);
grid("on");
title(strt);
subplot(312);
plot(wp*0.5/pi,(P0-Pd)/pi);
axis([0 0.5]);
ylabel("Phase error(rad./$\\pi$)");
grid("on");
subplot(313);
plot(wt*0.5/pi,T0-Td);
axis([0 0.5]);
ylabel("Delay error(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_response_error"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(roots(conv(N0,[1;-1])),roots(D0));
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Save the result
print_polynomial(Da0,"Da0");
print_polynomial(Da0,"Da0",strcat(strf,"_Da0_coef.m"));
print_polynomial(Db0,"Db0");
print_polynomial(Db0,"Db0",strcat(strf,"_Db0_coef.m"));
print_polynomial(N0,"N0");
print_polynomial(D0,"D0");
eval(sprintf("save %s.mat ...\n\
     tol maxiter n ma mb fap fas Wap Was Wtp Wpp abi ab0 Da0 Db0 N0 D0",strf));

% Done
toc;
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));
