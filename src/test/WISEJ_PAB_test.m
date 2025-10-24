% WISEJ_PAB_test.m
% Copyright (C) 2025 Robert G. Jenssen
%
% Use the method of Tarczynski et al to design a bandpass filter as the
% difference of two parallel allpass filters. See:
% "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

strf="WISEJ_PAB_test";

delete(strcat(strf,".diary",strf));
delete(strcat(strf,".diary.tmp",strf));
eval(sprintf("diary %s.diary.tmp",strf));

function E=WISEJ_PAB(ab,_ma,_mb,_Ad,_Wa,_Td,_Wt,_Pd,_Wp)
% E=WISEJ_PAB(ab,ma,mb,Ad,Wa)
% E=WISEJ_PAB(ab,ma,mb,Ad,Wa,Td,Wt)
% E=WISEJ_PAB(ab,ma,mb,Ad,Wa,Td,Wt,Pd,Wp)
%
% Objective function for minimising the response error of a parallel
% all-pass band-pass filter using the method of Tarczynski et al. As the
% filter is band-pass the response uses the difference of the all-pass
% filter responses.

% The argument ab is the concatenation of the two allpass filter denominator
% transfer function polynomials.
%
% First initialise the common parameters of the filter structure with:
%  WISEJ_PAB([],ma,mb,Ad,Wa,Td,Wt,Pd,Wp)
%
% The initialised filter parameters are:
%  ma - order of first allpass filter
%  mb - order of second allpass filter
%  Ad - desired filter amplitude response
%  Wa - filter amplitude response weighting factor
%  Td - desired filter group-delay response
%  Wt - filter group-delay response weighting factor
%  Pd - desired filter phase response
%  Wp - filter phase response weighting factor
%
% See "A WISE Method for Designing IIR Filters", A.Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

  persistent ma mb Ad Wa Td Wt Pd Wp
  persistent init_done=false

  if (nargin ~= 1) && (nargin ~= 5) && (nargin ~= 7) && (nargin ~= 9)
    print_usage("E=WISEJ_PAB(ab[,ma,mb,Ad,Wa,Td,Wt,Pd,Wp])");
  endif
  if nargin>=5
    ma=_ma; mb=_mb; Ad=_Ad; Wa=_Wa; Td=[]; Wt=[]; Pd=[]; Wp=[];
    if (length(Ad) ~= length(Wa))
      error("Expected length(Ad) == length(Wa)!");
    endif
    if nargin>=7
      Td=_Td; Wt=_Wt; 
      if (length(Ad) ~= length(Td))
        error("Expected length(Ad) == length(Td)!");
      endif 
      if (length(Td) ~= length(Wt))
        error("Expected length(Td) == length(Wt)!");
      endif
    endif
    if nargin==9
      Pd=_Pd; Wp=_Wp;
      if (length(Ad) ~= length(Pd))
        error("Expected length(Ad) == length(Pd)!");
      endif 
      if (length(Pd) ~= length(Wp))
        error("Expected length(Pd) == length(Wp)!");
      endif
    endif
    init_done=true;
  endif
    
  if init_done==false
    error("init_done == false!");
  endif

  if isempty(ab)
    return;
  endif
  
  % Sanity checks
  if (length(ab) ~= (ma+mb))
    error("Expected length(ab) == (ma+mb)!");
  endif
  
  % Find the allpass denominator polynomials
  ab=ab(:);
  Da=[1;ab(1:ma)];
  Db=[1;ab((ma+1):end)];
  D=conv(Da,Db);
  N=(conv(flipud(Da),Db)-conv(flipud(Db),Da))/2;
  
  % Trapezoidal integration of the weighted amplitude error
  [H,wa]=freqz(N,D,length(Ad));
  EAd = Wa.*(abs(abs(H)-Ad).^2);
  intEAd = sum(diff(wa).*(EAd(1:(length(EAd)-1))+EAd(2:end)))/2;

  % Add trapezoidal integration of the weighted group delay response error
  if isempty(Td)
    intETd = 0;
  else
    % This fails !?! : wt=wa; T=delayz(N,D,wt);
    [T,wt]=delayz(N,D,length(Td));
    ETd = Wt.*(abs(T-Td).^2);
    intETd = sum(diff(wt).*(ETd(1:(length(ETd)-1))+ETd(2:end)))/2;
  endif

  % Add trapezoidal integration of the weighted phase response error
  if isempty(Pd)
    intEPd = 0;
  else
    wp = wa;
    EPd = Wp.*(abs(unwrap(arg(H(1:length(Pd))))-Pd).^2);
    intEPd = sum(diff(wp).*(EPd(1:(length(EPd)-1))+EPd(2:end)))/2;
  endif

  % Heuristics for the barrier function
  lambda = 0.001;
  if (ma+mb) > 0
    M = (ma+mb);
    t = 300;
    rho = 31/32;
    % Convert to state variable form
    Drho=D./(rho.^(0:(length(D)-1))).';
    Drho=Drho(:).'/Drho(1);
    nDrho=length(Drho);
    AD=[zeros(nDrho-2,1) eye(nDrho-2); -Drho(nDrho:-1:2)];
    bD=[zeros(nDrho-2,1);1];
    cD=-Drho(nDrho:-1:2);
    dD=1;
    % Calculate barrier function
    f = zeros(M,1);
    cAD_t = cD*(AD^(t-1));
    for k=1:M
      f(k) = cAD_t*bD;
      cAD_t = cAD_t*AD;
    endfor
    f = real(f);
    EJ = sum(f.*f);
  else
    EJ = 0;
  endif
  % Done
  E = ((1-lambda)*(intEAd+intETd+intEPd)) + (lambda*EJ);
endfunction

tic;

% Filter specification
maxiter=20000
tol=1e-8
% Initial filter for parallel_allpass_bandpass_test.m
ma=mb=10
tp=16
fasl=0.05,ftpl=0.09,fapl=0.10,fapu=0.20,ftpu=0.21,fasu=0.25
Wasl=20,Watl=0.01,Wap=1,Wtp=0.5,Watu=0.01,Wasu=10

% Frequency points
n=1000;
w=pi*(0:(n-1))'/n;
% Desired amplitude response
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Ad=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];
% Desired delay response
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
Td=tp*ones(n,1);
Wt=[zeros(ntpl-1,1);
    Wtp*ones(ntpu-ntpl+1,1); ...
    zeros(n-ntpu,1)];

% Unconstrained minimisation
abi=[1;zeros(ma-1,1);1;zeros(mb-1,1)];
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
WISEJ_PAB([],ma,mb,Ad,Wa,Td,Wt);
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
nplot=512;
[H0,wplot]=freqz(N0,D0,nplot);
T0=delayz(N0,D0,nplot);

% Plot response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H0)));
ylabel("Amplitude(dB)");
axis([0 0.5 -80 5]);
grid("on");
strt=sprintf("Parallel all-pass filters : ma=%d,mb=%d,tp=%g",ma,mb,tp);
title(strt);
subplot(212);
plot(wplot*0.5/pi,T0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 2*tp]);
grid("on");
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H0)));
ylabel("Amplitude(dB)");
axis([min(fapl,ftpl) max(fapu,ftpu) -3 1]);
grid("on");
title(strt);
subplot(212);
plot(wplot*0.5/pi,T0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([min(fapl,ftpl) max(fapu,ftpu) (tp+(0.1*[-1,1]))]);
grid("on");
zticks([]);
print(strcat(strf,"_response_passband"),"-dpdflatex");
close

% Plot poles and zeros
subplot(111);
zplane(qroots(N0),qroots(D0));
title(strt);
zticks([]);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Plot phase response
Ha=freqz(flipud(Da0),Da0,nplot);
Hb=freqz(flipud(Db0),Db0,nplot);
plot(wplot*0.5/pi,unwrap(arg(Ha))+(wplot*tp),"-", ...
     wplot*0.5/pi,unwrap(arg(Hb))+(wplot*tp),"--");
strt=sprintf(["Allpass phase response adjusted for linear phase : ", ...
 "ma=%d,mb=%d,tp=%g"],ma,mb,tp);
title(strt);
ylabel("Linear phase error(rad.)");
xlabel("Frequency");
legend("Filter A","Filter B","location","northwest");
legend("boxoff");
grid("on");
zticks([]);
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
eval(sprintf("save %s.mat ma mb tp abi ab0 Da0 Db0 N0 D0",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
