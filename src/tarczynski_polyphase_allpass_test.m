% tarczynski_polyphase_allpass_test.m
% Copyright (C) 2017-2022 Robert G. Jenssen
%
% Design a lowpass filter from the polyphase combination of two
% allpass filters using the method of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

delete("tarczynski_polyphase_allpass_test.diary");
delete("tarczynski_polyphase_allpass_test.diary.tmp");
diary tarczynski_polyphase_allpass_test.diary.tmp

tic;


% Filter specification
tol=1e-6
maxiter=20000
R=2
ma=11
mb=11
td=(R*(ma+mb))/2
polyphase=true
strf="tarczynski_polyphase_allpass_test";

for flat_delay=[false,true],
  
  if flat_delay
    flatstr="_flat_delay";
    fap=0.22
    Wap=1
    ftp=0.22
    Wtp=5
    fas=0.28
  else
    flatstr="";
    fap=0.24
    Wap=1
    ftp=0
    Wtp=0
    fas=0.26
  endif
  Was=1000

  % Frequency points
  n=1000;
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
  abi=[1;zeros(ma-1,1);1;zeros(mb-1,1)];
  WISEJ_PA([],ma,mb,R,polyphase,Ad,Wa,Td,Wt);
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

  % Create the output polynomials (Da and Db are coefficients in z^R)
  ab0=ab0(:);
  Da0=[1;ab0(1:ma)];
  Db0=[1;ab0((ma+1):end)];
  Da0R=[1;kron(ab0(1:ma),[zeros(R-1,1);1])];
  Db0R=[1;kron(ab0((ma+1):end),[zeros(R-1,1);1])];
  D0=conv(Da0R,Db0R);
  N0=0.5*([conv(Db0R,flipud(Da0R));0]+[0;conv(Da0R,flipud(Db0R))]);

  % Calculate response
  nplot=512;
  [Ha0,wplot]=freqz(flipud(Da0R),Da0R,nplot);
  Hb0=freqz(flipud(Db0R),Db0R,nplot);
  Ta0=grpdelay(flipud(Da0R),Da0R,nplot);
  Tb0=grpdelay(flipud(Db0R),Db0R,nplot);
  H0=0.5*(Ha0+(exp(-j*wplot).*Hb0));
  T0=0.5*(Ta0+Tb0+1);

  % Plot response
  subplot(211);
  plot(wplot*0.5/pi,20*log10(abs(H0)));
  ylabel("Amplitude(dB)");
  axis([0 0.5 -80 5]);
  grid("on");
  if flat_delay
    s=sprintf("Polyphase all-pass filters : ma=%d,mb=%d,td=%g",ma,mb,td);
  else
    s=sprintf("Polyphase all-pass filters : ma=%d,mb=%d",ma,mb);
  endif    
  title(s);
  subplot(212);
  plot(wplot*0.5/pi,T0);
  ylabel("Delay(samples)");
  xlabel("Frequency");
  if flat_delay
    axis([0 0.5 (td-1) (td+1)]);
  endif
  grid("on");
  print(sprintf("%s%s_response",strf,flatstr),"-dpdflatex");
  close

  % Plot passband response
  subplot(211);
  plot(wplot*0.5/pi,20*log10(abs(H0)));
  ylabel("Amplitude(dB)");
  if flat_delay
    axis([0 max(fap,ftp) -1e-5 1e-5]);
  else
    axis([0 max(fap,ftp) -1e-4 1e-4]);
  endif
  grid("on");
  title(s);
  subplot(212);
  plot(wplot*0.5/pi,T0);
  ylabel("Delay(samples)");
  xlabel("Frequency");
  if flat_delay
    axis([0 max(fap,ftp) (td-0.2) (td+0.2)]);
  endif
  grid("on");
  print(sprintf("%s%s_response_passband",strf,flatstr),"-dpdflatex");
  close

  % Plot phase response
  if flat_delay
  % Plot phase response of polyphase parallel filters
    plot(wplot*0.5/pi,unwrap(arg(Ha0))+(wplot*R*ma), ...
         wplot*0.5/pi,unwrap(arg(Hb0))+(wplot*((R*mb)-1)));
    strt=sprintf("Allpass phase response error from linear phase (-w*td): \
ma=%d,mb=%d,td=%g",ma,mb,td);
    title(strt);
    ylabel("Linear phase error(rad.)");
    xlabel("Frequency");
    legend("Filter A","Filter B","location","northwest");
    text(0.02,-3.5,"Note: the filter B phase includes the polyphase delay")
    legend("boxoff");
    grid("on");
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
save tarczynski_polyphase_allpass_test.mat R ma mb
movefile tarczynski_polyphase_allpass_test.diary.tmp tarczynski_polyphase_allpass_test.diary;
