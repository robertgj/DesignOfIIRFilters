% tarczynski_bandpass_hilbert_test.m
% Copyright (C) 2025 Robert G. Jenssen

test_common;

pkg load optim;

strf="tarczynski_bandpass_hilbert_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Initial filter (found by trial-and-error)
U=2,V=0,M=18,Q=10,R=2
xi=[ 0.00005, ...
     1, -1, ...
     0.9*ones(1,6), [1 1 1], (11:16)*pi/20, (7:9)*pi/10, ...
     0.81*ones(1,5), (4:8)*pi/10 ]';
[Ni,Di]=x2tf(xi,U,V,M,Q,R);
Ni=Ni/Di(1);
Di=Di/Di(1);
DiR=Di(3:2:end);
NDi=[Ni(:);DiR];
nN=length(Ni)-1;
nD=length(DiR);

% Frequency points
tp=16;
pp=1.5;
dBas=30;
fapl=0.1;fapu=0.2;fasl=0.05;fasu=0.25;
Wasl=1;Watl=0.001;Wap=1;Watu=0.001;Wasu=1;
n=500;
wd=(0:(n-1))'*pi/n;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Hd=[(10^(-dBas/20))*ones(napl-1,1); ...
    ones(napu-napl+1,1); ...
    (10^(-dBas/20))*ones(n-napu,1)].*exp(j*(-(wd*tp)+(pp*pi)));
Wd=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];

% Unconstrained minimisation
WISEJ([],nN,nD,R,wd,Hd,Wd);
tol=1e-6;
maxiter=10000;
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[ND0,FVEC,INFO,OUTPUT]=fminunc(@WISEJ,NDi,opt);
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
nplot=512;
[H,wplot]=freqz(N0,D0R,nplot);
T=delayz(N0',D0R',nplot);
subplot(311);
plot(wplot*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
s=sprintf("Tarczynski bandpass example : nN=%d,nD=%d,R=%d",nN,nD,R);
title(s);
subplot(312);
plot(wplot*0.5/pi,(unwrap(arg(H))+(wplot*tp))/pi);
axis([0 0.5 pp+(0.01*[-1,1])]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
subplot(313);
plot(wplot*0.5/pi,T);
axis([0 0.5 0 25]);
grid("on");
ylabel("Delay(samples)");
xlabel("Frequency");
print(strcat(strf,"_response"),"-dpdflatex");
close

subplot(111);
zplane(qroots(N0),qroots(D0R))
title(s);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Print results
print_polynomial(N0,"N0");
print_polynomial(N0,"N0",strcat(strf,"_N0_coef.m"));
print_polynomial(D0,"D0");
print_polynomial(D0,"D0",strcat(strf,"_D0_coef.m"));
[x0,U,V,M,Q]=tf2x(N0,D0);
print_pole_zero(x0,U,V,M,Q,R,"x0");
print_pole_zero(x0,U,V,M,Q,R,"x0",strcat(strf,"_x0_coef.m"));

% Save the result
eval(sprintf(["save %s.mat U V M Q R x0 fapl fapu fasl fasu ", ...
 "Wap Watl Watu Wasl Wasu tp pp dBas n nN nD R ND0 N0 D0 D0R"],strf));

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
