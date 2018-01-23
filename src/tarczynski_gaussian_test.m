% tarczynski_gaussian_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Design a Gaussian filter using the method of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

unlink("tarczynski_gaussian_test.diary");
unlink("tarczynski_gaussian_test.diary.tmp");
diary tarczynski_gaussian_test.diary.tmp

format compact
tic

% Objective function
function E=WISEJ_GAUSS(ND,_nN,_nD,_R,_wd,_Hd,_Wd)
  persistent nN nD R wd Hd Wd
  persistent init_done=false
  % Sanity checks
  if (nargin ~= 1) && (nargin ~= 7)
    print_usage("E=WISEJ_GAUSS(ND[,nN,nD,R,wd,Hd,Wd])")
  endif
  if nargin == 7
    nN=_nN;nD=_nD;R=_R;wd=_wd;Hd=_Hd;Wd=_Wd;
    init_done=true;
    if nargout == 0
      return;
    endif
  endif
  if (length(ND) != (1+nN+nD))
    error("Expected length(ND) == (1+nN+nD)!");
  endif
  % Decimate the denominator
  ND=ND(:);
  N=ND(1:(nN+1));
  if nD==0
    DR=1;
  else
    DR=[1;kron(ND((nN+2):end),[zeros(R-1,1);1])];
  endif
  % Find the error complex frequency response
  HN = freqz(N,1,wd);
  HDR = freqz(DR,1,wd);
  HNDR = HN./HDR;
  EHd = Wd.*(abs(Hd-HNDR).^2);
  % Trapezoidal integration of the weighted error
  intEHd = sum(diff(wd).*(EHd(1:(length(EHd)-1))+EHd(2:length(EHd))))/2;
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
tol=1e-10;
sf=0.5;
if 0
  nN=13;nD=0;R=0;td=6.5;
elseif 1
  nN=8;nD=4;R=2;td=5.35;
else
  nN=16;nD=8;R=2;td=9.25;
endif

% Frequency vectors
n=256;
wd=pi*(0:(n-1))'/n;
Hd=exp(-(j*td*wd)-((wd.^2)/(2*sf*sf)));
Wd=ones(size(wd));

% Unconstrained minimisation
N0=[1;ones(nN+nD,1)];
WISEJ_GAUSS([],nN,nD,R,wd,Hd,Wd);
[ND,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_GAUSS,N0,optimset("TolFun",tol,"TolX",tol));
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
printf("Function value=%10.7f\n", FVEC);
printf("fminunc iterations=%d\n", OUTPUT.iterations);
printf("fminunc successful=%d??\n", OUTPUT.successful);
printf("fminunc funcCount=%d\n", OUTPUT.funcCount);

% Create the output polynomials
ND=ND(:);
N=ND(1:(nN+1));
if nD==0
  D=1;
  DR=1;
else
  D=[1;ND((nN+2):end)];
  DR=[D(1);kron(D(2:end),[zeros(R-1,1);1])];
endif

% Plot results
nplot=n;
[H,wplot]=freqz(N',DR',nplot);
T=grpdelay(N',DR',nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)),"-",wplot*0.5/pi,20*log10(abs(Hd)),"--");
ylabel("Amplitude(dB)");
axis([0 0.5 -100 10]);
legend("WISE","Gaussian");
legend("boxoff")
legend("location","northeast")
grid("on");
s=sprintf("Tarczynski et al. gaussian : nN=%d,nD=%d,R=%d,td=%g",nN,nD,R,td);
title(s);
subplot(212);
plot(wplot*0.5/pi,T);
ylabel("Group delay(samples)");
axis([0 0.5 td-1 td+1 ]);
xlabel("Frequency");
grid("on");
print("tarczynski_gaussian_response","-dpdflatex");
close
% Response error
subplot(111);
plot(wplot*0.5/pi,abs(H)-abs(Hd));
ylabel("Amplitude Error");
xlabel("Frequency");
grid("on");
s=sprintf("Tarczynski et al. gaussian : nN=%d,nD=%d,R=%d,td=%g",nN,nD,R,td);
title(s);
grid("on");
print("tarczynski_gaussian_response_error",  "-dpdflatex");
close
% Pole-zero plot
subplot(111);
zplane(roots(N),roots(DR));
title(s);
print("tarczynski_gaussian_pz",  "-dpdflatex");
close
% Impulse response
subplot(111);
u=[1;zeros(2*nN,1)];
y=filter(N,DR,u);
plot(y);
ylabel("Amplitude");
xlabel("Sample");
title(s);
print("tarczynski_gaussian_impulse",  "-dpdflatex");
close

% Save the result
printf("N=[ ");printf("%14.10f ",N');printf("]';\n");
printf("R=%d,D=[ ",R);printf("%14.10f ",D');printf("]';\n");
fid=fopen("tarczynski_gaussian_test.coef","wt");
fprintf(fid,"N=[ ");fprintf(fid,"%14.10f ",N');fprintf(fid,"]';\n");
fprintf(fid,"R=%d,D=[ ",R);fprintf(fid,"%14.10f ",D');fprintf(fid,"]';\n");
fclose(fid);

toc;

save tarczynski_gaussian_test.mat nN nD R N D DR

diary off
movefile tarczynski_gaussian_test.diary.tmp tarczynski_gaussian_test.diary;
