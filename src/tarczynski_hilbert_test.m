% tarczynski_hilbert_test.m
% Copyright (C) 2017-2021 Robert G. Jenssen
%
% Design a full-band Hilbert transform filter, H(w)=-jsign(w), using
% the method of Tarczynski et al.  See "A WISE Method for Designing 
% IIR Filters", A. Tarczynski et al., IEEE Transactions on Signal 
% Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

pkg load optim;

delete("tarczynski_hilbert_test.diary");
delete("tarczynski_hilbert_test.diary.tmp");
diary tarczynski_hilbert_test.diary.tmp


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
  PNDRd=unwrap(mod(arg(HNDRd)+(wd*td),2*pi));
  Pd=unwrap(mod(arg(Hd)+(wd*td),2*pi));
  EHd = Wd.*((abs(Hd-HNDRd).^2) + 0.01*(Pd-PNDRd).^2);
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
R=2;nN=11;nD=6;td=nN/2;tol=1e-9;maxiter=5000;

% Frequency points
n=1024;
wd=pi*(-n:(n-1))'/n;

% Frequency vectors
Pd=[0.5*pi*ones(n,1);0;-0.5*pi*ones(n-1,1)]-wd*td;
Hd=[ones(n,1);0;ones(n-1,1)].*exp(j*Pd);
Wd=ones(2*n,1);

% Initial filter
if 0
  b0=remez(nN,[0.1 0.9],[1 1],'hilbert');
  N0=[b0;zeros(nD,1)];
else
  N0=[1;zeros(nN+nD,1)];
endif

% Unconstrained minimisation
WISEJ_HILBERT([],nN,nD,R,wd,Hd,Wd,td);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ND,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_HILBERT,N0,opt);
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
H=freqz(N,DR,wd);
subplot(111);
zplane(roots(N),roots(DR));
s=sprintf("Tarczynski nN=%d,nD=%d,R=%d,td=%g IIR Hilbert filter",nN,nD,R,td);
title(s);
print("tarczynski_hilbert_pz",  "-dpdflatex");
close

subplot(211);
plot(wd*0.5/pi,abs(H));
axis([-0.5 0.5 0.6 1.2]);
grid("on");
title(s);
ylabel("Amplitude");
subplot(212);
plot(wd*0.5/pi,unwrap(mod(arg(H)+(wd*td),2*pi)))
axis([-0.5 0.5 -pi pi]);
grid("on");
ylabel("Phase(rad.)\n(less delay)");
xlabel("Frequency");
print("tarczynski_hilbert_response",  "-dpdflatex");
close

% Compare with remez
b0=remez(nN,[0.1 0.9],[1 1],'hilbert');
h=freqz(b0,1,wd);
t=grpdelay(b0,1,wd);
subplot(211);
plot(wd*0.5/pi,abs(h))
axis([-0.5 0.5 0 1.2])
grid("on");
title("Remez nN=11 FIR Hilbert filter");
ylabel("Amplitude");
subplot(212);
plot(wd*0.5/pi,unwrap(mod(arg(h)+(wd*td),2*pi)));
axis([-0.5 0.5 0 2*pi])
grid("on");
ylabel("Phase(rad.)\n(less delay)");
xlabel("Frequency");
print("remez_hilbert_response",  "-dpdflatex");
close

% Save the result
sort(roots(N))
sort(roots(DR))
printf("R=%d\n",R);
print_polynomial(N,"N");
print_polynomial(N,"N","tarczynski_hilbert_test_N_coef.m");
print_polynomial(D,"D");
print_polynomial(D,"D","tarczynski_hilbert_test_D_coef.m");
save tarczynski_hilbert_test.mat nN nD R N D DR

diary off
movefile tarczynski_hilbert_test.diary.tmp tarczynski_hilbert_test.diary;
