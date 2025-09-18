% tarczynski_parallel_allpass_lowpass_differentiator_alternate_test.m
% Copyright (C) 2025 Robert G. Jenssen
%
% Use the method of Tarczynski et al to design a lowpass differentiator filter
% as the difference of two parallel allpass filters followed by (z+1)^2.
% See: "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

strf="tarczynski_parallel_allpass_lowpass_differentiator_alternate_test";

delete(strcat(strf,".diary",strf));
delete(strcat(strf,".diary.tmp",strf));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Filter specification
tol=1e-12;maxiter=20000;
R=1;
polyphase=false;
difference=true;
if difference
  pa_sign=-1;
else
  pa_sign=1;
endif
fap=0.2;fas=0.4;Wap=1;Wat=0.02;Was=1;
ma=8;mb=ma;
tp=R*(ma+mb)/2;Wtp=0.1;pp=0.5;Wpp=1;

% Frequency points
n=1000;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);
w=pi*(1:n-1)'/n;
Rap=1:nap;

% Place one zero at z=-1.
Fz=[1;1]/2;
Hz=freqz(Fz,1,w);

% Amplitude response
Az=cos(w/2);
Ad=[w(Rap)/2;zeros(length(w)-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas,1)];

% Group delay response
Tz=0.5*ones(size(w));
Td=tp*ones(size(w));
Wt=[Wtp*ones(nap,1);zeros(length(w)-nap,1)];

% Phase response
Pz=-w/2;
Pd=(pp*pi)-(w*tp);
Wp=[Wpp*ones(nap,1);zeros(length(w)-nap,1)];

% Sanity checks
nchka=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1]';
printf("0.5*w(nchka)'/pi=[ ");printf("%6.4g ",0.5*w(nchka)'/pi);printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Ad(nchka)./Az(nchka)=[ ");
printf("%6.4g ",(Ad(nchka)./Az(nchka))');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Unconstrained minimisation with Fz removed
abi = zeros(ma+mb,1);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
WISEJ_PA([],ma,mb,R,polyphase,difference,Ad./Az,Wa,Td-Tz,Wt,Pd-Pz,Wp);
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
H0c=0.5*(Ha0+(pa_sign*Hb0));
H0=H0c.*Hz;
A0c=abs(H0c);
A0=abs(H0);
P0c=unwrap(arg(H0c(Rap)));
P0=unwrap(arg(H0(Rap)));
Ta0=delayz(flipud(Da0),Da0,w(Rap));
Tb0=delayz(flipud(Db0),Db0,w(Rap));
T0c=((Ta0+Tb0)/2);
T0=T0c+Tz(Rap);
% Alternate calculation
H0a=freqz(N0,D0,w);
A0a=abs(H0a).*Az;
P0a=unwrap(arg(H0a(Rap)))+Pz(Rap);
T0a=delayz(N0,D0,w(Rap))+Tz(Rap);
% Check
if max(abs(A0a-A0)) > 5000*eps
  warning("max(abs(A0a-A0))(%g*eps) > 5000*eps",max(abs(A0a-A0))/eps);
endif
if max(abs(P0a-P0)) > 2000*eps
  warning("max(abs(P0a-P0))(%g*eps) > 2000*eps",max(abs(P0a-P0))/eps);
endif
if max(abs(T0a-T0)) > 2e8*eps
  warning("max(abs(T0a-T0))(%g*eps) > 2e8*eps",max(abs(T0a-T0))/eps);
endif

% Plot correction filter response
subplot(311);
plot(w*0.5/pi,A0c);
ylabel("Amplitude");
axis([0 0.5 0 1]);
grid("on");
strt=sprintf ...
       (["Parallel all-pass correction response : ", ...
 "ma=%d,mb=%d,fap=%g,fas=%g,tp=%g"],
        ma,mb,fap,fas,tp);
title(strt);
subplot(312);
plot(w(1:nap)*0.5/pi,(P0c(1:nap)+(w(1:nap)*tp)-(w(1:nap).*Tz(1:nap)))/pi);
ylabel("Phase (rad./$\\pi$)");
axis([0 0.5]);
grid("on");
subplot(313);
plot(w(Rap)*0.5/pi,T0c);
axis([0 0.5]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_correction"),"-dpdflatex");
close

% Plot response
subplot(311);
plot(w*0.5/pi,A0);
ylabel("Amplitude");
axis([0 0.5 0 1]);
grid("on");
strt=sprintf("Parallel all-pass filters : ma=%d,mb=%d,fap=%g,fas=%g,tp=%g", ...
             ma,mb,fap,fas,tp);
title(strt);
subplot(312);
plot(w(Rap)*0.5/pi,(P0+(w(Rap)*tp))/pi);
ylabel("Phase (rad./$\\pi$)");
axis([0 0.5]);
grid("on");
subplot(313);
plot(w(Rap)*0.5/pi,T0);
axis([0 0.5]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot response error
subplot(311);
plot(w*0.5/pi,A0-Ad);
ylabel("Amplitude error");
axis([0 0.5 -0.1 0.1]);
grid("on");
strt=sprintf(["Parallel all-pass filter error : ",...
              "ma=%d,mb=%d,fap=%g,fas=%g,tp=%g"], ...
             ma,mb,fap,fas,tp);
title(strt);
subplot(312);
plot(w(Rap)*0.5/pi,(P0+(w(Rap)*tp))/pi);
axis([0 0.5]);
ylabel("Phase(rad./$\\pi$)");
grid("on");
subplot(313);
plot(w(Rap)*0.5/pi,T0);
axis([0 0.5]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_error"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(qroots(conv(N0,Fz)),qroots(D0));
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Plot phase response
plot(w*0.5/pi,(unwrap(arg(Ha0))+(w*tp))/pi,"-", ...
     w*0.5/pi,(unwrap(arg(Hb0))+(w*tp))/pi,"--");
strt=sprintf(["Allpass phase response adjusted for linear phase : ", ...
 "ma=%d,mb=%d,tp=%g"],ma,mb,tp);
title(strt);
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
legend("Filter A","Filter B","location","southwest");
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
print_polynomial(D0,"D0");
eval(sprintf(["save %s.mat tol maxiter n ma mb fap fas Wap Was Wtp Wpp ...\n",...
              " abi ab0 Da0 Db0 N0 D0"],strf));

% Done
toc;
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));
