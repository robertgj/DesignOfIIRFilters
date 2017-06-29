% tarczynski_pink_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% Design a full-band pink noise filter using the method of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

unlink("tarczynski_pink_test.diary");
unlink("tarczynski_pink_test.diary.tmp");
diary tarczynski_pink_test.diary.tmp

format compact
tic

% Objective function
function E=WISEJ_PINK(ND,_nN,_nD,_R,_wd,_Hd,_Wd)
  persistent nN nD R wd Hd Wd
  persistent init_done=false
  % Sanity checks
  if (nargin ~= 1) && (nargin ~= 7)
    print_usage("E=WISEJ_PINK(ND[,nN,nD,R,wd,Hd,Wd])")
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
  N=ND(1:(nN+1));
  DR=[1;kron(ND((nN+2):end),[zeros(R-1,1);1])];
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
R=1;nN=11;nD=11;td=(nN-1)/2;tol=1e-9;

% Frequency points
n=1000;
wd=pi*(10:(n-1))'/n;

% Frequency vectors
Hd=(0.1*exp(-j*td*wd)./sqrt(0.5*wd/pi));
Wd=ones(size(wd));

% Unconstrained minimisation
N0=[1;zeros(nN+nD,1)];
WISEJ_PINK([],nN,nD,R,wd,Hd,Wd);
[ND,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_PINK,N0,optimset("TolFun",tol,"TolX",tol));
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
D=[1; ND((nN+2):end)];
DR=[D(1);kron(D(2:end),[zeros(R-1,1);1])];

% Plot results
nplot=1024;
[H,wplot]=freqz(N,DR,nplot);
T=grpdelay(N',DR',nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
hold on
plot(wd*0.5/pi,20*log10(abs(Hd)));
ylabel("Amplitude error");
grid("on");
s=sprintf("Tarczynski et al. pink : nN=%d,nD=%d,R=%d,td=%g",
          nN,nD,R,td);
title(s);
subplot(212);
plot(wplot*0.5/pi,T);
ylabel("Group delay(samples)");
axis([0 0.5 0 10 ]);
xlabel("Frequency");
grid("on");
print("tarczynski_pink_response",  "-dpdflatex");
close

subplot(111);
zplane(roots(N),roots(DR));
title(s);
print("tarczynski_pink_pz",  "-dpdflatex");
close

% Save the result
printf("N=[ ");printf("%14.10f ",N');printf("]';\n");
printf("R=%d,D=[ ",R);printf("%14.10f ",D');printf("]';\n");
fid=fopen("tarczynski_pink_test.coef","wt");
fprintf(fid,"N=[ ");fprintf(fid,"%14.10f ",N');fprintf(fid,"]';\n");
fprintf(fid,"R=%d,D=[ ",R);fprintf(fid,"%14.10f ",D');fprintf(fid,"]';\n");
fclose(fid);

toc;

save tarczynski_pink_test.mat nN nD R N D DR

diary off
movefile tarczynski_pink_test.diary.tmp tarczynski_pink_test.diary;
