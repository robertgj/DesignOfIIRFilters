% tarczynski_bandpass_hilbert_test.m
% Copyright (C) 2025 Robert G. Jenssen

test_common;

pkg load optim;

strf="tarczynski_bandpass_hilbert_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Filter parameters
N=16;
tp=12;
pp=1.5;
fapl=0.1;fapu=0.2;fasl=0.05;fasu=0.25;
Wasl=100;Watl=0.1;Wap=1;Watu=0.1;Wasu=100;
fppl=fapl;fppu=fapu;Wpp=1;
ftpl=fapl;ftpu=fapu;Wtp=1;

n=500;
w=(0:(n-1))'*pi/n;

% Amplitude constraints
wa=w;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Ad=[zeros(napl-1,1); ...
    ones(napu-napl+1,1); ...
    zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];
% Sanity check
nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];
printf("nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];\n");
printf("nchk=[ ");printf("%d ",nchk);printf("];\n");
printf("wa(nchk)*0.5/pi=[ ");printf("%6.4g ",wa(nchk)'*0.5/pi);printf("];\n");
printf("Ad(nchk)=[ ");printf("%6.4g ",Ad(nchk)');printf("];\n");
printf("Wa(nchk)=[ ");printf("%6.4g ",Wa(nchk)');printf("];\n");

% Stop-band amplitude response constraints
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=w;
Pd=(pp*pi)-(wp*tp);
Wp=[zeros(nppl-1,1); ...
    Wpp*ones(nppu-nppl+1,1); ...
    zeros(n-nppu,1)];

% Group delay constraints
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
wt=w(ntpl:ntpu);
ntp=length(wt);
Td=tp*ones(ntp,1);
Wt=Wtp*ones(size(wt));

% Initial filter
[Zi,Pi,Gi]=cheby2(N/2,20,2*[0.1,0.2]);
[Xi,U,V,M,Q]=zp2x(Zi,Pi,Gi);
R=1;
maxiter=20000;
tol=1e-6;
[X0,f0]=xInitHd(Xi,U,V,M,Q,R,wa,Ad,Wa,[],[],[],wt,Td,Wt,wp,Pd,Wp,maxiter,tol);

% Create the output polynomials
[N0,D0]=x2tf(X0,U,V,M,Q,R);
[Z0,P0,G0]=x2zp(X0,U,V,M,Q,R);

% Plot results
A=iirA(w,X0,U,V,M,Q,R);
P=iirP(w,X0,U,V,M,Q,R);
T=iirT(w,X0,U,V,M,Q,R);
subplot(311);
plot(w*0.5/pi,20*log10(abs(A)));
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
s=sprintf("Tarczynski bandpass example : N=%d,R=%d",N,R);
title(s);
subplot(312);
plot(w*0.5/pi,(unwrap(P)+(w*tp))/pi);
axis([0 0.5 pp+(0.01*[-1,1])]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
subplot(313);
plot(w*0.5/pi,T);
axis([0 0.5 0 25]);
grid("on");
ylabel("Delay(samples)");
xlabel("Frequency");
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
close
subplot(111);
zplane(Z0(:),P0(:))
title(s);
zticks([]);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Print results
print_pole_zero(X0,U,V,M,Q,R,"x0");
print_pole_zero(X0,U,V,M,Q,R,"x0",strcat(strf,"_x0_coef.m"));
print_polynomial(N0,"N0");
print_polynomial(N0,"N0",strcat(strf,"_N0_coef.m"));
print_polynomial(D0,"D0");
print_polynomial(D0,"D0",strcat(strf,"_D0_coef.m"));

% Save the result
eval(sprintf(["save %s.mat U V M Q R Xi fapl fapu fasl fasu ", ...
 "Wap Watl Watu Wasl Wasu tp pp n R X0 Z0 P0 G0 N0 D0"],strf));

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
