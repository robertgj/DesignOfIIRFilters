% tarczynski_parallel_allpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
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
difference=false
n=1000;
R=1
fap=0.15
Wap=1
ftp=0.175
strf="tarczynski_parallel_allpass_test";
for flat_delay=[false,true],
  if flat_delay
    flatstr = "_flat_delay";
    Wtp=2
    fas=0.2
    Was=100
    ma=11
    mb=12
  else
    flatstr = "";
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
  Td=td*ones(size(w));
  Wt=[Wtp*ones(ntp,1);zeros(length(Td)-ntp,1)];

  % Unconstrained minimisation
  abi=[1;zeros(ma-1,1);1;zeros(mb-1,1)];
  opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
  WISEJ_PA([],ma,mb,R,polyphase,difference,Ad,Wa,Td,Wt);
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
  Da0=[1;kron(ab0(1:ma),[zeros(R-1,1);1])];
  Db0=[1;kron(ab0((ma+1):end),[zeros(R-1,1);1])];
  D0=conv(Da0,Db0);
  N0=0.5*(conv(Db0,flipud(Da0))+conv(Da0,flipud(Db0)));

  % Calculate response
  nplot=512;
  [Ha,wplot]=freqz(flipud(Da0),Da0,nplot);
  Hb=freqz(flipud(Db0),Db0,nplot);
  H=0.5*(Ha+Hb);
  Ta=delayz(flipud(Da0),Da0,nplot);
  Tb=delayz(flipud(Db0),Db0,nplot);
  T=0.5*(Ta+Tb);

  % Plot response
  subplot(211);
  plot(wplot*0.5/pi,20*log10(abs(H)));
  ylabel("Amplitude(dB)");
  axis([0 0.5 -80 5]);
  grid("on");
  if flat_delay
    s=sprintf("Parallel all-pass filters : ma=%d,mb=%d,td=%g",ma,mb,td);
  else
    s=sprintf("Parallel all-pass filters : ma=%d,mb=%d",ma,mb);
  endif
  title(s);
  subplot(212);
  plot(wplot*0.5/pi,T);
  ylabel("Delay(samples)");
  xlabel("Frequency");
  if flat_delay
    axis([0 0.5 (td-1) (td+1)]);
  endif
  grid("on");
zticks([]);
  print(sprintf("%s%s_response",strf,flatstr),"-dpdflatex");
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
zticks([]);
  print(sprintf("%s%s_response_passband",strf,flatstr),"-dpdflatex");
  close

  % Plot poles and zeros
  subplot(111);
  zplane(qroots(N0),qroots(D0));
  title(s);
zticks([]);
  print(sprintf("%s%s_pz",strf,flatstr),"-dpdflatex");
  close

  % Plot phase response
  if flat_delay
    % Plot phase response of parallel filters
    Ha=freqz(flipud(Da0),Da0,nplot);
    Hb=freqz(flipud(Db0),Db0,nplot);
    plot(wplot*0.5/pi,unwrap(arg(Ha))+(wplot*td), ...
         wplot*0.5/pi,unwrap(arg(Hb))+(wplot*td));
    strt=sprintf(["Allpass phase response adjusted for linear phase : ", ...
                  "ma=%d,mb=%d,td=%g"],ma,mb,td);
    title(strt);
    ylabel("Linear phase error(rad.)");
    xlabel("Frequency");
    legend("Filter A","Filter B","location","northwest");
    legend("boxoff");
    grid("on");
zticks([]);
    print(sprintf("%s%s_phase",strf,flatstr),"-dpdflatex");
    close
  endif

  % Save the result
  print_polynomial(Da0,"Da0");
  print_polynomial(Da0,"Da0",sprintf("%s%s_Da0_coef.m",strf,flatstr));
  print_polynomial(Db0,"Db0");
  print_polynomial(Db0,"Db0",sprintf("%s%s_Db0_coef.m",strf,flatstr));
  print_polynomial(N0,"N0");
  print_polynomial(D0,"D0");
  
endfor

% Done
toc;
diary off
save tarczynski_parallel_allpass_test.mat R ma mb
movefile tarczynski_parallel_allpass_test.diary.tmp ...
         tarczynski_parallel_allpass_test.diary;
