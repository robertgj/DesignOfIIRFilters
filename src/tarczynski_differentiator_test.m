% tarczynski_differentiator_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Design a full-band differentiator using the method of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

unlink("tarczynski_differentiator_test.diary");
unlink("tarczynski_differentiator_test.diary.tmp");
diary tarczynski_differentiator_test.diary.tmp

format compact

% Objective function
function E=WISEJ_DIFF(ND,_nN,_nD,_R,_wd,_Hd,_Wd)
  persistent nN nD R wd Hd Wd td
  persistent init_done=false
  % Sanity checks
  if (nargin ~= 1) && (nargin ~= 7)
    print_usage("E=WISEJ_ND(ND[,nN,nD,R,wd,Hd,Wd,td])")
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
R=2;nN=12;nD=6;td=(nN-1)/2;tol=1e-9;

% Frequency points
n=1024;
wd=pi*(0:(n-1))'/n;

% Frequency vectors
Hd=(wd/pi).*exp(-j*td*wd)*exp(j*pi/2);
Wd=ones(n,1);

% Unconstrained minimisation
N0=[1;zeros(nN+nD,1)];
WISEJ_DIFF([],nN,nD,R,wd,Hd,Wd);
[ND,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_DIFF,N0,optimset("TolFun",tol,"TolX",tol));
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
nplot=512;
[H,wplot]=freqz(N,DR,nplot);
T=grpdelay(N',DR',nplot);
subplot(211);
plot(wplot*0.5/pi,abs(H)-wplot/pi);
axis([0 0.5 -0.01 0.01]);
ylabel("Amplitude error");
grid("on");
s=sprintf("Tarczynski et al. differentiator : nN=%d,nD=%d,R=%d,td=%g",
          nN,nD,R,td);
title(s);
subplot(212);
% plot(wplot*0.5/pi,T-td); ylabel("Delay error(samples)");
plot(wplot*0.5/pi,unwrap(arg(H))-(pi/2)+(wplot*td));
axis([0 0.5 -0.1 0.1 ]);
ylabel("Phase error(radians)");
xlabel("Frequency");
grid("on");
print("tarczynski_differentiator_response",  "-dpdflatex");
close

subplot(111);
zplane(roots(N),roots(DR));
title(s);
print("tarczynski_differentiator_pz",  "-dpdflatex");
close

% Save the result
sort(roots(N))
sort(roots(DR))
fprintf("N=[ ");fprintf("%14.10f ",N');fprintf("]';\n");
fprintf("R=%d,D=[ ",R);fprintf("%14.10f ",D');fprintf("]';\n");
fid=fopen("tarczynski_differentiator_test.coef","wt");
fprintf(fid,"N=[ ");fprintf(fid,"%14.10f ",N');fprintf(fid,"]';\n");
fprintf(fid,"R=%d,D=[ ",R);fprintf(fid,"%14.10f ",D');fprintf(fid,"]';\n");
fclose(fid);

save tarczynski_differentiator_test.mat nN nD R N D DR

diary off
movefile tarczynski_differentiator_test.diary.tmp ...
       tarczynski_differentiator_test.diary;
