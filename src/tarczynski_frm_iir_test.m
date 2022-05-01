% tarczynski_frm_iir_test.m
% Copyright (C) 2017-2022 Robert G. Jenssen
%
% Design an FRM filter from IIR model and FIR masking filters using
% the method of Tarczynski et al. The masking filters have odd lengths
% (ie: even order) and are symmetric (ie: linear phase).

test_common;

pkg load optim;

delete("tarczynski_frm_iir_test.diary");
delete("tarczynski_frm_iir_test.diary.tmp");
diary tarczynski_frm_iir_test.diary.tmp

tic;

verbose=true
maxiter=2000

function [n,dM,d,aM,a,aa,ac]=vec2frm_iir(adac,mn,mr,na,nc,M,D)
  adac=adac(:);
  a=adac(1:(mn+1));
  d=[1;adac((mn+1+1):(mn+1+mr))];
  if mn>mr
    d=[d;zeros(mn-mr,1)];
  elseif mn<mr
    a=[a;zeros(mr-mn,1)];
  endif
  aM=[a(1);kron(a(2:end),[zeros(M-1,1);1])];
  dM=[d(1);kron(d(2:end),[zeros(M-1,1);1])];
  if rem(na,2) == 1
    una=(na+1)/2;
    aa=adac((mn+1+mr+1):(mn+1+mr+una));
    aa=[aa;flipud(aa(1:(una-1)))];
  else
    una=na/2;
    aa=adac((mn+1+mr+1):(mn+1+mr+una));
    aa=[aa;flipud(aa(1:una))];
  endif
  if rem(nc,2) == 1
    unc=(nc+1)/2;
    ac=adac((mn+1+mr+una+1):end);
    ac=[ac;flipud(ac(1:(unc-1)))];
  else
    unc=nc/2;
    ac=adac((mn+1+mr+una+1):end);
    ac=[ac;flipud(ac(1:unc))];
  endif
  if na>nc
    ac=[zeros((na-nc)/2,1);ac; zeros((na-nc)/2,1)];
  elseif na<nc
    aa=[zeros((nc-na)/2,1);aa; zeros((nc-na)/2,1)];
  endif
  n=[conv(aM,aa-ac);zeros(M*D,1)]+[zeros(M*D,1);conv(ac,dM)];
endfunction

function E=WISEJ_FRM_IIR(adac,_mn,_mr,_na,_nc,_M,_D,_wa,_Ad,_Wa,_ws,_Sd,_Ws)

  persistent mn mr na nc M D wa Ad Wa ws Sd Ws
  persistent init_done=false

  if nargin==13
    mn=_mn; mr=_mr; na=_na; nc=_nc; M=_M; D=_D;
    wa=_wa; Ad=_Ad; Wa=_Wa; ws=_ws; Sd=_Sd; Ws=_Ws;
    init_done=true;
  endif
  if isempty(adac)
    return;
  endif
  if init_done==false
    error("init_done == false!");
  endif
  
  % Find the FRM filter polynomials
  [n,dM]=vec2frm_iir(adac,mn,mr,na,nc,M,D);
 
  % Find the error response in the passband
  Ha=freqz(n,dM,wa);
  EAd = Wa.*(abs(Ha-Ad).^2);

  % Find the error response in the stopband
  Hs=freqz(n,dM,ws);
  ESd = Ws.*((abs(Hs)-abs(Sd)).^2);

  if 1
    % Trapezoidal integration of the weighted error
    intEd = sum(diff(wa).*((EAd(1:(length(EAd)-1))+EAd(2:end))/2)) + ...
            sum(diff(ws).*((ESd(1:(length(ESd)-1))+ESd(2:end))/2));
  else
    intEd = sum(EAd)+sum(ESd);
  endif
 
  % Heuristics for the barrier function
  lambda = 0.001;
  if (mn+mr) > 0
    bM = mr*M;
    T = 300;
    rho = 31/32;
    % Convert to state variable form
    Drho=dM./(rho.^(0:(length(dM)-1)))';
    Drho=Drho(:)'/Drho(1);
    nDrho=length(Drho);
    AD=[zeros(nDrho-2,1) eye(nDrho-2); -Drho(nDrho:-1:2)];
    bD=[zeros(nDrho-2,1);1];
    cD=-Drho(nDrho:-1:2);
    dD=1;
    % Calculate barrier function
    f = zeros(bM,1);
    cAD_Tk = cD*(AD^(T-1));
    for k=1:bM
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

if 1
  % Alternative filter specification based on tarczynski_frm_allpass_test.m
  tol=1e-4 % Tolerance on coefficient update vector
  n=1000 % Number of frequency points
  mn=10 % Model filter numerator order (mn+1 coefficients)
  mr=10 % Model filter denominator order (mr coefficients)
  na=41 % Masking filter FIR length
  nc=41 % Complementary masking filter FIR length
  M=9 % Decimation
  D=7 % Desired model filter passband delay
  d=(max(na,nc)-1)/2 % Nominal masking filter delay
  fpass=0.3 % Pass band edge
  fstop=0.31 % Stop band edge 
  dBas=50 % Stop band attenuation
  Wap=1 % Pass band weight
  Wapextra=100 % Extra pass band amplitude weight for extra points
  Wasextra=200 % Extra stop band amplitude weight for extra points
  Was=200 % Stop band amplitude weight
  edge_factor=0.1 % Add extra frequencies near band edges
  edge_ramp=1 % Linear change of extra weights
elseif 0
  % Filter specification (based on Lu and Hinamoto example)
  tol=1e-6 % Tolerance on coefficient update vector
  n=800 % Number of frequency points
  mn=14 % Model filter numerator order (mn+1 coefficients)
  mr=10 % Model filter denominator order (mr coefficients)
  na=41 % Masking filter FIR length
  nc=33 % Complementary masking filter FIR length
  M=9 % Decimation
  D=7 % Desired model filter passband delay
  d=(max(na,nc)-1)/2 % Nominal masking filter delay
  fpass=0.3 % Pass band edge
  fstop=0.305 % Stop band edge
  dBas=60 % Stop band attenuation
  Wap=1 % Pass band weight
  Wapextra=10 % Pass band amplitude weight for extra points
  Wasextra=10 % Stop band amplitude weight for extra points
  Was=10 % Stop band amplitude weight
  edge_factor=0.1 % Add extra frequencies near band edges
  edge_ramp=1 % Linear change of extra weights
elseif 0
  % Filter specification with even length masking filters
  tol=1e-6 % Tolerance on coefficient update vector
  n=800 % Number of frequency points
  mn=10 % Model filter numerator order (mn+1 coefficients)
  mr=10 % Model filter denominator order (mr coefficients)
  na=32 % Masking filter FIR length
  nc=34 % Complementary masking filter FIR length
  M=9 % Decimation
  D=7 % Desired model filter passband delay
  d=(max(na,nc)-1)/2 % Nominal masking filter delay
  fpass=0.3 % Pass band edge
  fstop=0.305 % Stop band edge 
  dBas=100 % Stop band attenuation
  Wap=1 % Pass band weight
  Wapextra=0 % Extra pass band amplitude weight for extra points
  Wasextra=0 % Extra stop band amplitude weight for extra points
  Was=5 % Stop band amplitude weight
  edge_factor=0.1 % Add extra frequencies near band edges
  edge_ramp=0 % Linear change of extra weights
else
  % Alternative filter specification based on Lu and Hinamoto example
  tol=1e-6 % Tolerance on coefficient update vector
  n=800 % Number of frequency points
  mn=10 % Model filter numerator order (mn+1 coefficients)
  mr=10 % Model filter denominator order (mr coefficients)
  na=33 % Masking filter FIR length
  nc=33 % Complementary masking filter FIR length
  M=9 % Decimation
  D=7 % Desired model filter passband delay
  d=(max(na,nc)-1)/2 % Nominal masking filter delay
  fpass=0.3 % Pass band edge
  fstop=0.305 % Stop band edge 
  dBas=100 % Stop band attenuation
  Wap=1 % Pass band weight
  Wapextra=0 % Extra pass band amplitude weight for extra points
  Wasextra=0 % Extra stop band amplitude weight for extra points
  Was=5 % Stop band amplitude weight
  edge_factor=0.1 % Add extra frequencies near band edges
  edge_ramp=0 % Linear change of extra weights
endif

% Frequencies and vectors
[wpass,Hpass,Wpass,wstop,Hstop,Wstop,fadp,fads,faap,faas,facp,facs]=...
frm_lowpass_vectors(n,M,D,d,fpass,fstop,dBas,Wap,Wapextra,Wasextra,Was,...
                    edge_factor,edge_ramp);

% Initial model filter
a0=remez(mn,2*[0 fadp fads 0.5],[1 1 0 0]);
d0=[1;zeros(mr,1)];
% Initial masking filter
aa0=remez(na-1,2*[0 faap faas 0.5],[1 1 0 0]);
% Initial complementary masking filter
ac0=remez(nc-1,2*[0 facp facs 0.5],[1 1 0 0]);
% Initial filter vector
adac0=[a0;d0(2:end);aa0(1:((na+1)/2));ac0(1:((nc+1)/2))];

% Unconstrained minimisation
WISEJ_FRM_IIR([],mn,mr,na,nc,M,D,wpass,Hpass,Wpass,wstop,Hstop,Wstop);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[adac1,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_FRM_IIR,adac0,opt);
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
[n1,dM1,d1,aM1,a1,aa1,ac1]=vec2frm_iir(adac1,mn,mr,na,nc,M,D);

% Calculate filter response
nplot=512;
[Hw_frm,wplot]=freqz(n1,dM1,nplot);
Tw_frm=grpdelay(n1,dM1,nplot);
Hw_aa=freqz(aa1,1,nplot);
Hw_ac=freqz(ac1,1,nplot);
Hw_ad=freqz(aM1,dM1,nplot);
Tw_ad=grpdelay(aM1,dM1,nplot);

% Plot overall response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_frm)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 5]);
grid("on");
s=sprintf("FRM filter : mn=%d,mr=%d,na=%d,nc=%d,M=%d,D=%d,Was=%d", ...
          mn,mr,na,nc,M,D,Was);
title(s);
subplot(212);
plot(wplot*0.5/pi,Tw_frm);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 60 120]);
grid("on");
print("tarczynski_frm_iir_test_response","-dpdflatex");
close

% Plot masking filter responses
subplot(111);
plot(wplot*0.5/pi,20*log10(abs(Hw_aa)),wplot*0.5/pi,20*log10(abs(Hw_ac)));
ylabel("Amplitude(dB)");
axis([0 0.5 -40 5]);
grid("on");
s=sprintf("FRM masking filters : na=%d,nc=%d",na,nc);
title(s);
print("tarczynski_frm_iir_test_masking_response","-dpdflatex");
close

% Plot model filter response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(Hw_ad)));
ylabel("Amplitude(dB)");
axis([0 0.5 -10 10]);
grid("on");
s=sprintf("FRM IIR model filter : mn=%d,mr=%d,M=%d,D=%d",mn,mr,M,D);
title(s);
subplot(212);
plot(wplot*0.5/pi,Tw_ad);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 100]);
grid("on");
print("tarczynski_frm_iir_test_model_response","-dpdflatex");
close

% Save the results
print_polynomial(a1,"x0.a");
print_polynomial(a1,"x0.a","tarczynski_frm_iir_test_a_coef.m");
print_polynomial(d1,"x0.d");
print_polynomial(d1,"x0.d","tarczynski_frm_iir_test_d_coef.m");
print_polynomial(aa1,"x0.aa");
print_polynomial(aa1,"x0.aa","tarczynski_frm_iir_test_aa_coef.m");
print_polynomial(ac1,"x0.ac");
print_polynomial(ac1,"x0.ac","tarczynski_frm_iir_test_ac_coef.m");

save tarczynski_frm_iir_test.mat ...
     n1 dM1 d1 a1 aM1 aa1 ac1 M D mn mr na nc fpass fstop Was

% Done
toc;
diary off
movefile tarczynski_frm_iir_test.diary.tmp tarczynski_frm_iir_test.diary;
