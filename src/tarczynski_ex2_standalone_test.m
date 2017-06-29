% tarczynski_ex2_standalone_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% Design a filter implementing the response of Example 2 of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432
%
% This standalone version only uses Octave functions

test_common;

unlink("tarczynski_ex2_standalone_test.diary");
unlink("tarczynski_ex2_standalone_test.diary.tmp");
diary tarczynski_ex2_standalone_test.diary.tmp

format compact

warning("error","Octave:nonconformant-args");
warning("error","Octave:undefined-return-values");
warning("error","Octave:broadcast");
warning("error","Octave:divide-by-zero");
warning("error","Octave:possible-matlab-short-circuit-operator");

global nN nD R wd Hd Wd

% Objective function
function E=WISEJ_ND(ND)
  global nN nD R wd Hd Wd
  % Sanity check
  if (length(ND) != (1+nN+nD))
    error("Expected length(ND) == (1+nN+nD)!");
  endif
  % Decimate the denominator
  N=ND(1:(nN+1));
  DR=[1;kron(ND((nN+2):(nN+1+nD)), [zeros(R-1,1);1])];
  % Find the error complex frequency response 
  HNDRd = freqz(N,DR, wd);
  EHd = Wd.*(abs(Hd-HNDRd).^2);
  % Trapezoidal integration of the error
  intEHd = sum(diff(wd).*(EHd(1:(length(EHd)-1))+EHd(2:(length(EHd))))/2);
  % Heuristics for the barrier function
  lambda = 0.001;
  if (nD > 0)
    M = nD*R;
    T = 300;
    rho = 31/32;
    % Convert to state variable form
    DRrho=DR./(rho.^(0:(length(DR)-1))');
    DRrho=DRrho(:)'/DRrho(1);
    nDRrho=length(DRrho);
    ADR=[zeros(nDRrho-2,1) eye(nDRrho-2); -DRrho(nDRrho:-1:2)];
    bDR=[zeros(nDRrho-2,1);1];
    cDR=-DRrho(nDRrho:-1:2);
    dDR=1;
    % Calculate barrier function
    f = zeros(M,1);
    cADR_Tk = cDR*(ADR^(T-1));
    for k=1:M
      f(k) = cADR_Tk*bDR;
      cADR_Tk = cADR_Tk*ADR;
    endfor
    f = real(f);
    EJ = sum(f.*f);
  else
    EJ = 0;
  endif
  % Done
  E = ((1-lambda)*intEHd) + (lambda*EJ);
endfunction

% Filter specification
transf=0.02;
f1=0.5-transf;f2=0.5+transf;
a1=1;a2=0.5;
t1=14.3;t2=20;
R=2;nN=24;nD=2;
tol=1e-9;

% Frequency points
n=1024;
wd=pi*(0:(n-1))'/n;
% Transition band
bw=round((0.5-transf)*n);
bt=n-(2*bw);
vbw=(0:(bt-1))'/bt;
% Frequency vectors
Ha=[a1*ones(n/2,1);a2*ones(n/2,1)];
Ht=[t1*ones(n/2,1);t2*ones(n/2,1)];
Hd=Ha.*exp(-j*wd.*Ht);
Wd=[10*ones(bw,1); ones(bt,1); 50*ones(bw,1)];

% Unconstrained minimisation
N0=[1;zeros(nN+nD,1)];
[ND,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_ND,N0,optimset("TolFun",tol,"TolX",tol));
if (INFO == 1)
  printf("Converged to a solution point.\n");
elseif (INFO == 2)
  printf("Last relative step size was less that TolX.\n");
elseif (INFO == 3)
  printf("Last relative decrease in function value was less than TolF.\n");
elseif (INFO == 0)
  printf("Iteration limit exceeded.\n");
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
ND=ND(:);
N=ND(1:(nN+1));
D=[1; ND((nN+2):(nN+1+nD))];
DR=[D(1);kron(D(2:length(D)), [zeros(R-1,1);1])];

% Plot results
nplot=512;
[H,wplot]=freqz(N,DR,nplot);
T=grpdelay(N',DR',nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([0 0.5 -8 2]);
grid("on");
s=sprintf("Tarczynski et al. Example 2 : nN=%d,nD=%d,R=%d",nN,nD,R);
title(s);
subplot(212);
plot(wplot*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 10 25]);
grid("on");
print("tarczynski_ex2_standalone_response",  "-dpdflatex");
close

subplot(111);
zplane(roots(N),roots(DR))
title(s);
print("tarczynski_ex2_standalone_pz",  "-dpdflatex");
close

% Print results
print_polynomial(N,"N");
print_polynomial(N,"N","tarczynski_ex2_standalone_test_N_coef.m");
print_polynomial(D,"D");
print_polynomial(D,"D","tarczynski_ex2_standalone_test_D_coef.m");
[x,U,V,M,Q]=tf2x(N,D);
print_pole_zero(x,U,V,M,Q,R,"x");
print_pole_zero(x,U,V,M,Q,R,"x","tarczynski_ex2_standalone_test_x_coef.m");

% Save the result
save tarczynski_ex2_standalone_test.mat a1 a2 t1 t2 transf nN nD R N D DR

diary off
movefile tarczynski_ex2_standalone_test.diary.tmp ...
       tarczynski_ex2_standalone_test.diary;
