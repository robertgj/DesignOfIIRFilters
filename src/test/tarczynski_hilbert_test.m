% tarczynski_hilbert_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen
%
% Design a full-band Hilbert transform filter, H(w)=-jsign(w), using
% the method of Tarczynski et al.  See "A WISE Method for Designing 
% IIR Filters", A. Tarczynski et al., IEEE Transactions on Signal 
% Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

strf="tarczynski_hilbert_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Objective function
function E=WISEJ_HILBERT(ND,_nN,_nD,_R,_wd,_Hd,_Wd,_td)
  persistent nN nD R wd Hd Wd td
  persistent init_done=false
  % Sanity checks
  if (nargin ~= 1) && (nargin ~= 8)
    print_usage("E=WISEJ_HILBERT(ND[,nN,nD,R,wd,Hd,Wd,td])")
  endif
  if nargin == 8
    nN=_nN;nD=_nD;R=_R;wd=_wd;Hd=_Hd;Wd=_Wd;td=_td;
    init_done=true;
    if nargout == 0
      return;
    endif
  endif
  if (length(ND) ~= (1+nN+nD))
    error("Expected length(ND) == (1+nN+nD)!");
  endif
  % Decimate the denominator
  N=ND(1:(nN+1));
  DR=[1;kron(ND((nN+2):(nN+1+nD)), [zeros(R-1,1);1])];
  % Find the error complex frequency response 
  HNDRd=freqz(N,DR,wd);
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
R=2;nN=11;nD=6;td=nN/2;ft=0.02;pp=5;tol=1e-9;maxiter=5000;

% Frequency points
n=1024;
wd=pi*(-n:(n-1))'/n;
ntt=floor(ft*0.5/n);

% Frequency vectors
Pd=(0.5*pi*[-ones(n,1);0;ones(n-1,1)])-(wd*td);
Hd=[ones(n,1);1;ones(n-1,1)].*exp(j*Pd);
Wd=ones(2*n,1);

% Initial filter
Ni=[1;zeros(nN+nD,1)];

% Unconstrained minimisation
WISEJ_HILBERT([],nN,nD,R,wd,Hd,Wd,td);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ND0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_HILBERT,Ni,opt);
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
ND0=ND0(:);
N0=ND0(1:(nN+1));
D0=[1; ND0((nN+2):(nN+1+nD))];
D0R=[D0(1);kron(D0(2:length(D0)), [zeros(R-1,1);1])];

% Plot results
H0=freqz(N0,D0R,wd);
subplot(111);
zplane(qroots(N0),qroots(D0R));
s=sprintf("Tarczynski nN=%d,nD=%d,R=%d,td=%g IIR Hilbert filter",nN,nD,R,td);
title(s);
print("tarczynski_hilbert_test_pz","-dpdflatex");
close

subplot(211);
plot(wd*0.5/pi,abs(H0));
axis([-0.5 0.5 0.6 1.2]);
grid("on");
title(s);
ylabel("Amplitude");
subplot(212);
plot(wd*0.5/pi,(unwrap(arg(H0))+(wd*td)+(pp*pi))/pi)
axis([-0.5 0.5 -1 1]);
grid("on");
ylabel("Phase error(rad./$\\pi$)");
xlabel("Frequency");
print("tarczynski_hilbert_test_response","-dpdflatex");
close

% Compare with remez
b0=remez(nN,[0.1 0.9],[1 1],'hilbert');
H=freqz(b0,1,wd);
subplot(211);
plot(wd*0.5/pi,abs(H))
axis([-0.5 0.5 0 1.2])
grid("on");
title("Remez nN=11 FIR Hilbert filter");
ylabel("Amplitude");
subplot(212);
plot(wd*0.5/pi,(unwrap(arg(H))+(wd*td)+(pp*pi))/pi);
axis([-0.5 0.5 -1 1])
grid("on");
ylabel("Phase errror(rad./$\\pi$)");
xlabel("Frequency");
print("tarczynski_hilbert_test_remez_response","-dpdflatex");
close

% Save the result
sort(qroots(N0))
sort(qroots(D0R))
printf("R=%d\n",R);
print_polynomial(N0,"N0");
print_polynomial(N0,"N0","tarczynski_hilbert_test_N0_coef.m");
print_polynomial(D0,"D0");
print_polynomial(D0,"D0","tarczynski_hilbert_test_D0_coef.m");
eval(sprintf("save %s.mat nN nD R N0 D0 D0R",strf));

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
