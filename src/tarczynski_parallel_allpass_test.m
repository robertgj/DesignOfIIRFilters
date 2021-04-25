% tarczynski_parallel_allpass_test.m
% Copyright (C) 2017-2021 Robert G. Jenssen
%
% Design a lowpass filter from two parallel allpass filters using
% the method of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

delete("tarczynski_parallel_allpass_test.diary");
delete("tarczynski_parallel_allpass_test.diary.tmp");
diary tarczynski_parallel_allpass_test.diary.tmp

tic;


% Filter specification
tol=1e-6
maxiter=5000
polyphase=false
flat_delay=true
n=1000;
R=1
fap=0.15
Wap=1
ftp=0.175
if flat_delay
  Wtp=2
  fas=0.2
  Was=100
  ma=11
  mb=12
else
  Wtp=0
  fas=0.17
  Was=100
  ma=5
  mb=6
endif
td=(ma+mb)/2

% Frequency points
w=pi*(0:(n-1))'/n;
nap=ceil(fap*n/0.5)+1;
ntp=ceil(ftp*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Frequency vectors
Ad=[ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];
Td=td*ones(n,1);
Wt=[Wtp*ones(ntp,1);zeros(n-ntp,1)];

% Unconstrained minimisation
ab0=[1;zeros(ma-1,1);1;zeros(mb-1,1)];
WISEJ_PA([],ma,mb,R,polyphase,w,Ad,Wa,Td,Wt);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ab1,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_PA,ab0,opt);
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
Da=[1;kron(ab1(1:ma),[zeros(R-1,1);1])];
Db=[1;kron(ab1((ma+1):end),[zeros(R-1,1);1])];
D=conv(Da,Db);
N=0.5*(conv(Db,flipud(Da))+conv(Da,flipud(Db)));

% Calculate response
nplot=512;
[Ha,wplot]=freqz(flipud(Da),Da,nplot);
Hb=freqz(flipud(Db),Db,nplot);
H=0.5*(Ha+Hb);
Ta=grpdelay(flipud(Da),Da,nplot);
Tb=grpdelay(flipud(Db),Db,nplot);
T=0.5*(Ta+Tb);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
s=sprintf("Parallel all-pass filters : ma=%d,mb=%d,td=%g",ma,mb,td);
title(s);
subplot(212);
plot(wplot*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
if flat_delay
  axis([0 0.5 (td-1) (td+1)]);
endif
grid("on");
print("tarczynski_parallel_allpass_response","-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([0 max(fap,ftp) -3 1]);
grid("on");
title(s);
subplot(212);
plot(wplot*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
if flat_delay
  axis([0 max(fap,ftp) (td-0.1) (td+0.1)]);
endif
grid("on");
print("tarczynski_parallel_allpass_response_passband","-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(roots(N),roots(D));
title(s);
print("tarczynski_parallel_allpass_pz","-dpdflatex");
close

% Plot phase response
if flat_delay
  % Plot phase response of parallel filters
  Ha=freqz(flipud(Da),Da,nplot);
  Hb=freqz(flipud(Db),Db,nplot);
  plot(wplot*0.5/pi,unwrap(arg(Ha))+(wplot*td), ...
       wplot*0.5/pi,unwrap(arg(Hb))+(wplot*td));
  strt=sprintf("Allpass phase response error from linear phase (-w*td): \
ma=%d,mb=%d,td=%g",ma,mb,td);
  title(strt);
  ylabel("Linear phase error(rad.)");
  xlabel("Frequency");
  legend("Filter A","Filter B","location","northwest");
  legend("boxoff");
  grid("on");
  print("tarczynski_parallel_allpass_phase","-dpdflatex");
  close
endif

% Save the result
print_polynomial(Da,"Da0");
print_polynomial(Da,"Da0","tarczynski_parallel_allpass_test_Da0_coef.m");
print_polynomial(Db,"Db0");
print_polynomial(Db,"Db0","tarczynski_parallel_allpass_test_Db0_coef.m");
print_polynomial(N,"N");
print_polynomial(D,"D");
save tarczynski_parallel_allpass_test.mat R ma mb ab0 ab1 Da Db N D

% Done
toc;
diary off
movefile tarczynski_parallel_allpass_test.diary.tmp tarczynski_parallel_allpass_test.diary;
