% tarczynski_allpass_phase_shift_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Design an allpass filter with a phase shift of pi over a transition
% band using the method of Tarczynski et al.
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

delete("tarczynski_allpass_phase_shift_test.diary");
delete("tarczynski_allpass_phase_shift_test.diary.tmp");
diary tarczynski_allpass_phase_shift_test.diary.tmp

tic;


function E=WISEJ_PS(a,_w,_td,_D,_Pd,_Wp)
% E=WISEJ_PS(a,[w,td,D,Pd,Wp])
% Objective function for minimising the phase error of an allpass
% intended to be combined with a pure delay, D. Here we calculate
% the zero-phase response, obtained by adding w*D to the phase of
% the allpass filter. See "A WISE Method for Designing IIR Filters",
% A. Tarczynski et al., IEEE Transactions on Signal Processing,
% Vol. 49, No. 7, pp. 1421-1432

  persistent w td D Pd Wp
  persistent init_done=false

  if (nargin != 1) && (nargin != 6)
    print_usage("E=WISEJ_PS(a[,w,td,D,Pd,Wp])");
  endif
  if nargin==6
    w=_w(:); td=_td; D=_D; Pd=_Pd(:); Wp=_Wp(:);
    init_done=true;
  endif
  if isempty(a)
    return;
  endif
  if init_done==false
    error("init_done == false!");
  endif
  
  % Sanity checks
  if (length(w) != length(Pd))
    error("Expected length(w) == length(Pd)!");
  endif
  if (length(w) != length(Wp))
    error("Expected length(w) == length(Wp)!");
  endif 
  
  % Find the phase response
  Da=[1;a(:)];
  Ha=freqz(flipud(Da),Da,w);
  EPd = (Wp.*(Pd-rem(unwrap(arg(Ha))+(w*td),2*pi))).^2;

  % Trapezoidal integration of the weighted error
  intEd = sum(diff(w).*((EPd(1:(length(EPd)-1))+EPd(2:end))/2));
  
  % Heuristics for the barrier function
  lambda = 0.001;
  if (length(a)) > 0
    M = (length(a));
    T = 300;
    rho = 31/32;
    % Convert to state variable form
    Drho=Da./(rho.^(0:(length(Da)-1)))';
    Drho=Drho(:)'/Drho(1);
    nDrho=length(Drho);
    AD=[zeros(nDrho-2,1) eye(nDrho-2); -Drho(nDrho:-1:2)];
    bD=[zeros(nDrho-2,1);1];
    cD=-Drho(nDrho:-1:2);
    dD=1;
    % Calculate barrier function
    f = zeros(M,1);
    cAD_Tk = cD*(AD^(T-1));
    for k=1:M
      f(k) = cAD_Tk*bD;
      cAD_Tk = cAD_Tk*AD;
    endfor
    f = real(f);
    EJ = sum(f.*f);
  else
    EJ = 0;
  endif
  % Done
  E = ((1-lambda)*intEd) + (lambda*EJ);
endfunction

% Filter specification
tol=1e-9
maxiter=2000
n=1000;
fp=0.15
Wp=1
fs=0.2
Ws=2
m=11
D=10
td=D

% Frequency points
w=pi*(0:(n-1))'/n;
np=ceil(fp*n/0.5)+1;
ns=floor(fs*n/0.5)+1;

% Frequency vectors for zero-phase response
Pd=[zeros(np,1);zeros(ns-np-1,1);-pi*ones(n-ns+1,1)];
W=[Wp*ones(np,1);zeros(ns-np-1,1);Ws*ones(n-ns+1,1)];

% Unconstrained minimisation
a0=[-0.9;zeros(m-1,1)];
WISEJ_PS([],w,td,D,Pd,W);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[a1,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_PS,a0,opt);
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

% Create the denominator polynomial
Da1=[1;a1(:)];

% Calculate response
nplot=n;
[Ha1,wplot]=freqz(flipud(Da1),Da1,nplot);
Ta1=grpdelay(flipud(Da1),Da1,nplot);

% Plot delay/allpass lowpass response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Ha1+exp(-j*wplot*D))/2));
ylabel("Amplitude(dB");
axis([0 0.5 -50 5]);
s=sprintf("All-pass/delay lowpass filter response : fp=%g,fs=%g,D=%d",fp,fs,D);
title(s);
grid("on");
subplot(212);
plot(wplot*0.5/pi,(Ta1+D)/2);
ylabel("Group delay(samples)");
xlabel("Frequency");
%axis([0 max(fp,fp) (td-1) (td+1)]);
grid("on");
print("tarczynski_allpass_phase_shift_lowpass_response","-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(roots(flipud(Da1)),roots(Da1));
s=sprintf("All-pass/delay lowpass filter pole-zero : fp=%g,fs=%g,D=%d",fp,fs,D);
title(s);
print("tarczynski_allpass_phase_shift_pz","-dpdflatex");
close

% Plot phase response error
subplot(111);
plot(wplot*0.5/pi,(Pd-rem(unwrap(arg(Ha1))+(wplot*td),2*pi)).*(W~=0));
ylabel("Phase error(rad)");
axis([0 0.5 -0.2 0.2]);
grid("on");
s=sprintf("All-pass filter phase response error : m=%d,td=%g,D=%d",m,td,D);
title(s);
print("tarczynski_allpass_phase_shift_phase_error","-dpdflatex");
close

% Save the filter specification
fid=fopen("tarczynski_allpass_phase_shift_test.spec","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"m=%d %% Allpass model filter denominator order\n",m);
fprintf(fid,"td=%d %% Filter delay\n",td);
fprintf(fid,"D=%d %% Delay branch samples\n",D);
fprintf(fid,"fp=%g %% Pass band amplitude response edge\n",fp);
fprintf(fid,"Wp=%d %% Pass band amplitude response weight\n",Wp);
fprintf(fid,"fs=%g %% Stop band amplitude response edge\n",fs);
fprintf(fid,"Ws=%d %% Stop band amplitude response weight\n",Ws);
fclose(fid);

% Save the result
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1","tarczynski_allpass_phase_shift_test_Da1_coef.m");
save tarczynski_allpass_phase_shift_test.mat m td D fp Wp fs Ws a0 Da1 

% Done
toc;
diary off
movefile tarczynski_allpass_phase_shift_test.diary.tmp tarczynski_allpass_phase_shift_test.diary;
