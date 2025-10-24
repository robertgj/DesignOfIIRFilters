% tarczynski_deczky1_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

pkg load optim;

delete("tarczynski_deczky1_test.diary");
delete("tarczynski_deczky1_test.diary.tmp");
diary tarczynski_deczky1_test.diary.tmp

tic;

% Initial filter
R=1;
[Ni,Di]=butter(12, 0.25*2);
Ni=Ni(:);
Ni=Ni/Di(1);
nN=length(Ni)-1;
Di=Di(:);
Di=Di/Di(1);
nD=length(Di)-1;
% Truncate Butterworth denominator to order 6
Di=Di(1:7);
nD=length(Di)-1;

% Frequency points
tp=8,fap=0.25,fas=0.3,ftp=0.25
dBas=40,Wap=1,Wat=0,Was=10,Wtp=0.1
n=200;
wd=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
ntp=ceil(n*ftp/0.5)+1;
Ad=[ones(nap,1); (10^(-dBas/20))*ones(n-nap,1)];
Td=tp*ones(n,1);
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas+1,1)];
Td=tp*ones(n,1);
Wt=[Wtp*ones(ntp,1); zeros(n-ntp,1)];

% Unconstrained minimisation
tol=1e-6;
maxiter=10000;
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
NDi=[Ni;Di(2:end)];
% Desired frequency response
Hd=[exp(-j*tp*wd(1:nap));zeros(n-nap,1)];
Wd=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];
% WISE optimisation
WISEJ([],nN,nD,R,wd,Hd,Wd);
[ND0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ,NDi);
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
D0=[1; ND0((nN+2):end)];

% Plot results
nplot=512;
[H0,wplot]=freqz(N0,D0,nplot);
T0=delayz(N0',D0',nplot);
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(H0)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
s=sprintf("Tarczynski deczky1 example : nN=%d,nD=%d",nN,nD);
title(s);
subplot(212);
plot(wplot*0.5/pi,T0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 0 25]);
grid("on");
zticks([]);
print("tarczynski_deczky1_test_response", "-dpdflatex");
close

subplot(111);
zplane(qroots(N0),qroots(D0))
title(s);
zticks([]);
print("tarczynski_deczky1_test_pz", "-dpdflatex");
close

% Print results
print_polynomial(N0,"N0");
print_polynomial(N0,"N0","tarczynski_deczky1_test_N0_coef.m");
print_polynomial(D0,"D0");
print_polynomial(D0,"D0","tarczynski_deczky1_test_D0_coef.m");
[x0,U,V,M,Q]=tf2x(N0,D0);
print_pole_zero(x0,U,V,M,Q,R,"x0");
print_pole_zero(x0,U,V,M,Q,R,"x0","tarczynski_deczky1_test_x0_coef.m")
                                                      
% Save the result
save tarczynski_deczky1_test.mat fap fas Wap Was tp n nN nD Ni Di N0 D0 

% Done
toc
diary off
movefile tarczynski_deczky1_test.diary.tmp tarczynski_deczky1_test.diary;
