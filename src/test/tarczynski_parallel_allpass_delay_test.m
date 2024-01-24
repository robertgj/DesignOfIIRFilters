% tarczynski_parallel_allpass_delay_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen
%
% Design a lowpass filter from the parallel combination of an allpass
% filter and a delay using the method of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

strf="tarczynski_parallel_allpass_delay_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

for tarczynski_parallel_allpass_delay_flat_delay=[true,false]

  if tarczynski_parallel_allpass_delay_flat_delay
    strn=strcat(strf,"_flat_delay");
  else
    strn=strf;
  endif
  
  % Filter specification
  tol=1e-9
  maxiter=5000
  polyphase=false
  n=1000;
  R=1
  fap=0.15
  Wap=1
  ftp=0.175
  if tarczynski_parallel_allpass_delay_flat_delay
    Was=1000
    Wtp=10
  else
    Was=100
    Wtp=0
  endif
  fas=0.2
  m=12
  D=11
  td=10.5
  
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
  ai=[-0.9;zeros(m-1,1)];
  WISEJ_DA([],R,D,polyphase,Ad,Wa,Td,Wt);
  opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
  [a0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_DA,ai,opt);
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
  a0=a0(:);
  Da0=[1;kron(a0,[zeros(R-1,1);1])];
  Na0=0.5*(conv([zeros((D*R),1);1],Da0)+[flipud(Da0);zeros((D*R),1)]);
  
  % Calculate response
  nplot=512;
  [Ha0,wplot]=freqz(Na0,Da0,nplot);
  Ta0=delayz(Na0,Da0,nplot);

  % Plot response
  subplot(211);
  plot(wplot*0.5/pi,20*log10(abs(Ha0)));
  ylabel("Amplitude(dB)");
  axis([0 0.5 -80 5]);
  grid("on");
  s=sprintf("Parallel all-pass filter and delay : m=%d,td=%g",length(a0),td);
  title(s);
  subplot(212);
  plot(wplot*0.5/pi,Ta0);
  ylabel("Delay(samples)");
  xlabel("Frequency");
  if tarczynski_parallel_allpass_delay_flat_delay
    axis([0 0.5 (td-1) (td+1)]);
  endif
  grid("on");
  print(strcat(strn,"_response"),"-dpdflatex");
  close

  % Plot passband response
  subplot(211);
  plot(wplot*0.5/pi,20*log10(abs(Ha0)));
  ylabel("Amplitude(dB)");
  axis([0 max(fap,ftp) -3 1]);
  grid("on");
  title(s);
  subplot(212);
  plot(wplot*0.5/pi,Ta0);
  ylabel("Delay(samples)");
  xlabel("Frequency");
  if tarczynski_parallel_allpass_delay_flat_delay
    axis([0 max(fap,ftp) (td-1) (td+1)]);
  endif
  grid("on");
  print(strcat(strn,"_response_passband"),"-dpdflatex");
  close

  % Plot poles and zeros
  subplot(111);
  zplane(roots(Na0),roots(Da0));
  title(s);
  print(strcat(strn,"_pz"),"-dpdflatex");
  close

  % Save the result
  print_polynomial(Da0,"Da0");
  print_polynomial(Da0,"Da0",strcat(strn,"_Da0_coef.m"));
  print_polynomial(Na0,"Na0");
  print_polynomial(Na0,"Na0",strcat(strn,"_Na0_coef.m"));
  eval(sprintf("save %s.mat R ai a0 Da0 Na0",strn));
endfor

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
