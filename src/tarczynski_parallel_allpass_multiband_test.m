% tarczynski_parallel_allpass_multiband_test.m
% Copyright (C) 2020 Robert G. Jenssen
%
% Use the method of Tarczynski et al to design a multi-band-pass filter as the
% difference of two parallel allpass filters. See:
% "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

delete("tarczynski_parallel_allpass_multiband_test.diary");
delete("tarczynski_parallel_allpass_multiband_test.diary.tmp");
diary tarczynski_parallel_allpass_multiband_test.diary.tmp

tic;

strf="tarczynski_parallel_allpass_multiband_test";

% Filter specification
maxiter=20000
tol=1e-8
npoints=1000;

% Initial filter for parallel_allpass_multiband_test.m
ma=mb=12;
fas1u=0.05;
fap1l=0.075;fap1u=0.1;
ftp1l=0.075;ftp1u=0.1;
fas2l=0.125;fas2u=0.15;
fap2l=0.175;fap2u=0.225;
ftp2l=0.175;ftp2u=0.225;
fas3l=0.25;
Was1=1;Wap1=1;Was2=2;Wap2=1;Was3=1;
tp1=tp2=24;
Wtp1=0.02;Wtp2=0.02;

% Desired amplitude response
nas1u=ceil(npoints*fas1u/0.5)+1;
nap1l=floor(npoints*fap1l/0.5)+1;
nap1u=ceil(npoints*fap1u/0.5)+1;
nas2l=floor(npoints*fas2l/0.5)+1;
nas2u=ceil(npoints*fas2u/0.5)+1;
nap2l=floor(npoints*fap2l/0.5)+1;
nap2u=ceil(npoints*fap2u/0.5)+1;
nas3l=floor(npoints*fas3l/0.5)+1;

Ad=[zeros(nap1l-1,1); ...
    ones(nap1u-nap1l+1,1); ...
    zeros(nap2l-nap1u-1,1); ...
    ones(nap2u-nap2l+1,1); ...
    zeros(npoints-nap2u,1)];
Wa=[Was1*ones(nap1l-1,1); ...
    Wap1*ones(nap1u-nap1l+1,1); ...
    Was2*ones(nap2l-nap1u-1,1); ...
    Wap2*ones(nap2u-nap2l+1,1); ...
    Was3*ones(npoints-nap2u,1)];

% Desired group delay response
ntp1l=floor(npoints*ftp1l/0.5);
ntp1u=ceil(npoints*ftp1u/0.5);
ntp2l=floor(npoints*ftp2l/0.5);
ntp2u=ceil(npoints*ftp2u/0.5);
Td=[zeros(nap1l-1,1); ...
    tp1*ones(nap1u-nap1l+1,1); ...
    zeros(nap2l-nap1u-1,1); ...
    tp2*ones(nap2u-nap2l+1,1); ...
    zeros(npoints-nap2u,1)];
Wt=[zeros(ntp1l-1,1); ...
    Wtp1*ones(ntp1u-ntp1l+1,1); ...
    zeros(ntp2l-ntp1u-1,1); ...
    Wtp2*ones(ntp2u-ntp2l+1,1); ...
    zeros(npoints-ntp2u,1)];

% Unconstrained minimisation
ab0=[1;zeros(ma-1,1);1;zeros(mb-1,1)];
WISEJ_PAB([],ma,mb,Ad,Wa,Td,Wt);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ab1,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_PAB,ab0,opt);
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
ab1=ab1(:);
Da=[1;ab1(1:ma)];
Db=[1;ab1((ma+1):end)];
D=conv(Da,Db);
N=0.5*(conv(flipud(Da),Db)-conv(flipud(Db),Da));

% Calculate response
nplot=512;
[H,wplot]=freqz(N,D,nplot);
T=grpdelay(N,D,nplot);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([0 0.5 -50 5]);
grid("on");
strt=sprintf("Parallel all-pass filters : ma=%d,mb=%d,tp1=%g,tp2=%g", ...
             ma,mb,tp1,tp2);
title(strt);
subplot(212);
plot(wplot*0.5/pi,T);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 (ceil(max(tp1,tp2)/10)+1)*10]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([0 0.5 -3 1]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,T);
ylabel("Group delay(samples)");
xlabel("Frequency");
axis([0 0.5 (floor(min(tp1,tp2)/10)-1)*10 (ceil(max(tp1,tp2)/10)+1)*10]);
grid("on");
print(strcat(strf,"_response_passband"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(roots(N),roots(D));
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Plot phase response
Ha=freqz(flipud(Da),Da,nplot);
Hb=freqz(flipud(Db),Db,nplot);
plot(wplot*0.5/pi,(unwrap(arg(Ha))+(wplot*(tp1+tp2)/2))/pi,"-", ...
     wplot*0.5/pi,(unwrap(arg(Hb))+(wplot*(tp1+tp2)/2))/pi,"-.");
strt=sprintf("Allpass phase response error from -w*(tp1+tp2)/(2$\\pi$) : \
ma=%d,mb=%d,tp1=%g,tp2=%g",ma,mb,tp1,tp2);
title(strt);
ylabel("Linear phase error(rad./$\\pi$)");
xlabel("Frequency");
legend("Filter A","Filter B");
legend("location","northwest");
legend("boxoff");
grid("on");
print(strcat(strf,"_phase"),"-dpdflatex");
close

% Save the result
print_polynomial(Da,"Da0");
print_polynomial(Da,"Da0",strcat(strf,"_Da0_coef.m"));
print_polynomial(Db,"Db0");
print_polynomial(Db,"Db0",strcat(strf,"_Db0_coef.m"));
print_polynomial(N,"N");
print_polynomial(D,"D");
save tarczynski_parallel_allpass_multiband_test.mat ma mb ab0 ab1 Da Db N D

% Done
toc;
diary off
movefile tarczynski_parallel_allpass_multiband_test.diary.tmp ...
         tarczynski_parallel_allpass_multiband_test.diary;
