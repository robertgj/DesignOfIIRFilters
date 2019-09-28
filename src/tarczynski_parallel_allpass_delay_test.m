% tarczynski_parallel_allpass_delay_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Design a lowpass filter from the parallel combination of an allpass
% filter and a delay using the method of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

unlink("tarczynski_parallel_allpass_delay_test.diary");
unlink("tarczynski_parallel_allpass_delay_test.diary.tmp");
diary tarczynski_parallel_allpass_delay_test.diary.tmp

tic;


tarczynski_parallel_allpass_delay_flat_delay=false

function E=WISEJ_DA(a,_R,_D,_poly,_w,_Ad,_Wa,_Td,_Wt)
% E=WISEJ_DA(a[,R,D,poly,w,Ad,Wa,Td,Wt])
% Objective function for minimising the response error of the parallel
% combination of an allpass filter and a pure delay using the method of
% Tarczynski et al. See "A WISE Method for Designing IIR Filters",
% A. Tarczynski et al., IEEE Transactions on Signal Processing,
% Vol. 49, No. 7, pp. 1421-1432
%
% The filter transfer function is:
%   H(z)=(z^(-D)+a(z))/2
%
% For the polyphase combination:
%   H(z)=(z^(-D*R)+z^(-1)*a(z^R))/2

  persistent R D polyphase w Ad Wa Td Wt
  persistent init_done=false

  if (nargin != 1) && (nargin != 9)
    print_usage("E=WISEJ_DA(a[,R,D,poly,w,Ad,Wa,Td,Wt])");
  endif
  if nargin==9
    R=_R; D=_D; polyphase=_poly; w=_w; Ad=_Ad; Wa=_Wa; Td=_Td; Wt=_Wt;
    init_done=true;
  endif
  if isempty(a)
    return;
  endif
  if init_done==false
    error("init_done == false!");
  endif
  
  % Sanity checks
  if (polyphase == true) && (R > 2)
    error("Expected ((polyphase == true) && (R <= 2))!");
  endif
  if (length(w) != length(Ad))
    error("Expected length(w) == length(Ad)!");
  endif
  if (length(w) != length(Wa))
    error("Expected length(w) == length(Wa)!");
  endif 
  if (length(w) != length(Td))
    error("Expected length(w) == length(Td)!");
  endif
  if (length(w) != length(Wt))
    error("Expected length(w) == length(Wt)!");
  endif
  
  % Find the allpass denominator polynomials
  a=a(:);
  if R>1
    DaR=[1;kron(a,[zeros(R-1,1);1])];
  else
    DaR=[1;a];
  endif
  
  % Find the error response in the passband
  Ha_aR=freqz(flipud(DaR),DaR,w);
  if polyphase
    Ha=0.5*(exp(-j*D*R*w)+(exp(-j*w).*Ha_aR));
  else
    Ha=0.5*(exp(-j*D*R*w)+Ha_aR);
  endif
  EAd = Wa.*abs((abs(Ha)-abs(Ad)).^2);

  % Find the group delay error response
  Ta_aR=grpdelay(flipud(DaR),DaR,length(w));
 if polyphase
    T=0.5*((D*R)+Ta_aR+1);
  else
    T=0.5*((D*R)+Ta_aR);
  endif
  ETd = Wt.*((T-Td).^2);

  % Trapezoidal integration of the weighted error
  intEd = sum(diff(w).*((EAd(1:(length(EAd)-1))+EAd(2:end))/2)) + ...
          sum(diff(w).*((ETd(1:(length(ETd)-1))+ETd(2:end))/2));
  
  % Heuristics for the barrier function
  lambda = 0.001;
  if (D+length(a)) > 0
    M = (D+length(a))*R;
    T = 300;
    rho = 31/32;
    % Convert to state variable form
    Drho=DaR./(rho.^(0:(length(DaR)-1)))';
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
maxiter=5000
polyphase=false
n=1000;
R=1
fap=0.15
Wap=1
ftp=0.175
if tarczynski_parallel_allpass_delay_flat_delay
  Wtp=10
else
  Wtp=0
endif
fas=0.2
Was=1000
m=12
D=11
td=10.25

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
a0=[ -0.9;zeros(m-1,1)];
WISEJ_DA([],R,D,polyphase,w,Ad,Wa,Td,Wt);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[a1,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_DA,a0,opt);
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
a1=a1(:);
Da1=[1;kron(a1,[zeros(R-1,1);1])];
Na1=0.5*(conv([zeros((D*R),1);1],Da1)+[flipud(Da1);zeros((D*R),1)]);

% Calculate response
nplot=512;
[Ha1,wplot]=freqz(Na1,Da1,nplot);
Ta1=grpdelay(Na1,Da1,nplot);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Ha1)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
s=sprintf("Parallel all-pass filter and delay : m=%d,td=%g",length(a1),td);
title(s);
subplot(212);
plot(wplot*0.5/pi,Ta1);
ylabel("Group delay(samples)");
xlabel("Frequency");
if tarczynski_parallel_allpass_delay_flat_delay
  axis([0 0.5 (td-1) (td+1)]);
endif
grid("on");
print("tarczynski_parallel_allpass_delay_response","-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Ha1)));
ylabel("Amplitude(dB)");
axis([0 max(fap,ftp) -3 1]);
grid("on");
title(s);
subplot(212);
plot(wplot*0.5/pi,Ta1);
ylabel("Group delay(samples)");
xlabel("Frequency");
if tarczynski_parallel_allpass_delay_flat_delay
  axis([0 max(fap,ftp) (td-1) (td+1)]);
endif
grid("on");
print("tarczynski_parallel_allpass_delay_response_passband","-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(roots(Na1),roots(Da1));
title(s);
print("tarczynski_parallel_allpass_delay_pz","-dpdflatex");
close

% Save the result
print_polynomial(Da1,"Da1");
print_polynomial(Da1,"Da1","tarczynski_parallel_allpass_delay_test_Da1_coef.m");
print_polynomial(Na1,"Na1");
print_polynomial(Na1,"Na1","tarczynski_parallel_allpass_delay_test_Na1_coef.m");
save tarczynski_parallel_allpass_delay_test.mat R a0 a1 Da1 Na1

% Done
toc;
diary off
movefile tarczynski_parallel_allpass_delay_test.diary.tmp ...
       tarczynski_parallel_allpass_delay_test.diary;
