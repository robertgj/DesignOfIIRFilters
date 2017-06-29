% tarczynski_deczky1_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("tarczynski_deczky1_test.diary");
unlink("tarczynski_deczky1_test.diary.tmp");
diary tarczynski_deczky1_test.diary.tmp

tic;

format compact

% Objective function
function E=WISEJ_ND(ND,_nN,_nD,_R,_wd,_Ad,_Wa,_Td,_Wt)
  persistent nN nD R wd Ad Wa Td Wt
  persistent init_done=false
  if nargin == 9
    nN=_nN;nD=_nD;R=_R;wd=_wd;Ad=_Ad;Wa=_Wa;Td=_Td;Wt=_Wt;
    init_done=true;
    return;
  elseif nargin ~=1
    print_usage("E=WISEJ_ND(ND[,nN,nD,R,wd,Ad,Wa,Td,Wt])");
  elseif init_done==false
    error("init_done==false");
  endif
  % Sanity check
  if (length(ND) != (1+nN+nD))
    error("Expected length(ND) == (1+nN+nD)!");
  endif
  
  % Decimate the denominator
  N=ND(1:(nN+1));
  DR=[1;kron(ND((nN+2):(nN+1+nD)), [zeros(R-1,1);1])];
  % Find the amplitude error response 
  HNDRd = freqz(N,DR, wd);
  EAd = Wa.*((abs(Ad)-abs(HNDRd)).^2);
  % Find the delay error response 
  warning('off');
  TNDRd = grpdelay(N,DR, wd);
  warning('on');
  ETd = Wt.*(abs(Td-TNDRd).^2);
  % Trapezoidal integration of the error
  intEAd = sum(diff(wd).*(EAd(1:(length(EAd)-1))+EAd(2:end))/2);
  intETd = sum(diff(wd).*(ETd(1:(length(ETd)-1))+ETd(2:end))/2);
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
  E = ((1-lambda)*(intEAd+intETd)) + (lambda*EJ);
endfunction

% Initial filter
R=1;
[N0,D0]=butter(12, 0.25*2);
N0=N0(:);
N0=N0/D0(1);
nN=length(N0)-1;
D0=D0(:);
D0=D0/D0(1);
nD=length(D0)-1;
% Truncate Butterworth denominator to order 6
if 1
  D0=D0(1:7);
  nD=length(D0)-1;
endif

% Frequency points
td=9,fap=0.25,fas=0.3,ftp=0.25
dBas=40,Wap=1,Wat=0.02,Was=50,Wtp=0.02
n=200;
wd=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
ntp=ceil(n*ftp/0.5)+1;
Ad=[ones(nap,1); (10^(-dBas/20))*ones(n-nap,1)];
Td=td*ones(n,1);
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas+1,1)];
Td=td*ones(n,1);
Wt=[Wtp*ones(ntp,1); zeros(n-ntp,1)];

% Unconstrained minimisation
WISEJ_ND([],nN,nD,R,wd,Ad,Wa,Td,Wt);
tol=1e-6;
ND0=[N0;D0(2:end)];
[ND,FVEC,INFO,OUTPUT]=fminunc(@WISEJ_ND,ND0,optimset("TolFun",tol,"TolX",tol));
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

% Plot results
nplot=512;
[H,wplot]=freqz(N,D,nplot);
T=grpdelay(N',D',nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
s=sprintf("Tarczynski deczky1 example : nN=%d,nD=%d",nN,nD);
title(s);
subplot(212);
plot(wplot*0.5/pi,T);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 25]);
grid("on");
print("tarczynski_deczky1_response", "-dpdflatex");
close

subplot(111);
zplane(roots(N),roots(D))
title(s);
print("tarczynski_deczky1_pz", "-dpdflatex");
close

% Print results
print_polynomial(N,"N");
print_polynomial(N,"N","tarczynski_deczky1_test_N_coef.m");
print_polynomial(D,"D");
print_polynomial(D,"D","tarczynski_deczky1_test_D_coef.m");
[x,U,V,M,Q]=tf2x(N,D);
print_pole_zero(x,U,V,M,Q,R,"x");
print_pole_zero(x,U,V,M,Q,R,"x","tarczynski_deczky1_test_x_coef.m");

% Save the result
save tarczynski_deczky1_test.mat fap fas Wap Was td n nN nD N0 D0 N D 

% Done
toc
diary off
movefile tarczynski_deczky1_test.diary.tmp tarczynski_deczky1_test.diary;
