% iirP_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("iirP_test.diary");
unlink("iirP_test.diary.tmp");
diary iirP_test.diary.tmp

format compact

% Define the filter
if 1
  fc=0.10;U=2;V=2;M=20;Q=8;R=3;
  x0=[ -0.0089234, ...
       0.5000000, -0.5000000, ...
       0.5000000, -0.5000000, ...
       -0.5000000, -0.5000000,  0.5000000,  0.5000000,  0.5000000, ...
       0.5000000,  0.5000000,  0.5000000,  0.5000000,  0.8000000, ...
       0.6700726,  0.7205564,  0.8963898,  1.1980053,  1.3738387, ...
       1.4243225,  2.7644677,  2.8149515,  2.9907849,  1.9896753, ...
       -0.9698147, -0.8442244,  0.4511337,  0.4242641,  ...
       1.8917946,  1.7780303,  1.2325954,  0.7853982 ]';
else
  % For testing
  fc=0.10;U=0;V=0;M=0;Q=2;R=3;
  x0=[0.1,-0.5,0.5]';
endif
[B,A]=x2tf(x0,U,V,M,Q,R);
L=512;
w=(0:(L-1))*pi/L;
H=freqz(B,A,w);
H=H(:);
BAP=unwrap(arg(H));

% Check empty frequency
P=iirP([],x0,U,V,M,Q,R);
if !isempty(P)
  error("Expected P=[]");
endif

% Use iirP to find phase
[P,gradP]=iirP(w,x0,U,V,M,Q,R);

% Don't attempt to unwrap P. Just check correctness to multiples of
% 2*pi. Note that arg(K) is included in the result from iirA().
if max(abs(BAP-P-arg(x0(1))))> 1000*eps
  error("max(abs(BAP-P)) > 1000*eps");
endif

% Test first derivatives
Mon2=M/2;
Qon2=Q/2;
wc=2*pi*fc;

% Calculated values
[P,gradP]=iirP(wc,x0,U,V,M,Q,R);
delPdelK=gradP(1);
delPdelR0=gradP((1+1):(1+U));
delPdelRp=gradP((1+U+1):(1+U+V));
delPdelr0=gradP((1+U+V+1):(1+U+V+Mon2));
delPdeltheta0=gradP((1+U+V+Mon2+1):(1+U+V+M));
delPdelrp=gradP((1+U+V+M+1):(1+U+V+M+Qon2));
delPdelthetap=gradP((1+U+V+M+Qon2+1):(1+U+V+M+Q));

% Find approximate values
g=x0(1);
R0=x0((1+1):(1+U))';
Rp=x0((1+U+1):(1+U+V))';
r0=x0((1+U+V+1):(1+U+V+Mon2))';
theta0=x0((1+U+V+Mon2+1):(1+U+V+M))';
rp=x0((1+U+V+M+1):(1+U+V+M+Qon2))';
thetap=x0((1+U+V+M+Qon2+1):(1+U+V+M+Q))';
del=0.00001;

% Initialise approximate Hessian
hessPD=zeros(1+U+V+M+Q,1+U+V+M+Q);

% delPdelK
[PD,gradPD]=iirP(wc,[g+del R0 Rp r0 theta0 rp thetap],U,V,M,Q,R);
hessPD(1,:)=(gradPD-gradP)/del;
printf("delPdelK=%f, approx=%f, diff=%f\n",...
       delPdelK, (PD-P)/del, delPdelK-(PD-P)/del);

% Real zeros
for k=1:U
  printf("Real zero %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(U-k))];

  % delPdelR0
  [PD,gradPD]=iirP(wc,[g R0+delk Rp r0 theta0 rp thetap],U,V,M,Q,R);
  hessPD(1+k,:)=(gradPD-gradP)/del;
  printf("delPdelR0=%f, approx=%f, diff=%f\n",...
         delPdelR0(k), (PD-P)/del, delPdelR0(k)-(PD-P)/del);
endfor

% Real poles
for k=1:V
  printf("Real pole %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(V-k))];

  % delPdelRp
  [PD,gradPD]=iirP(wc,[g R0 Rp+delk r0 theta0 rp thetap],U,V,M,Q,R);
  hessPD(1+U+k,:)=(gradPD-gradP)/del;
  printf("delPdelRp=%f, approx=%f, diff=%f\n",...
         delPdelRp(k), (PD-P)/del, delPdelRp(k)-(PD-P)/del);
endfor

% Conjugate zeros
for k=1:Mon2
  printf("Conjugate zero %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(Mon2-k))];

  % delPdelr0
  [PD,gradPD]=iirP(wc,[g R0 Rp r0+delk theta0 rp thetap],U,V,M,Q,R);
  hessPD(1+U+V+k,:)=(gradPD-gradP)/del;
  printf("delPdelr0=%f, approx=%f, diff=%f\n",...
         delPdelr0(k), (PD-P)/del, delPdelr0(k)-(PD-P)/del);

  % delPdeltheta0
  [PD,gradPD]=iirP(wc,[g R0 Rp r0 theta0+delk rp thetap],U,V,M,Q,R);
  hessPD(1+U+V+Mon2+k,:)=(gradPD-gradP)/del;
  printf("delPdeltheta0=%f, approx=%f, diff=%f\n",...
         delPdeltheta0(k), (PD-P)/del, delPdeltheta0(k)-(PD-P)/del);
endfor

% Conjugate poles
for k=1:Qon2
  printf("Conjugate pole %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(Qon2-k))];

  % delPdelrp
  [PD,gradPD]=iirP(wc,[g R0 Rp r0 theta0 rp+delk thetap],U,V,M,Q,R);
  hessPD(1+U+V+M+k,:)=(gradPD-gradP)/del;
  printf("delPdelrp=%f, approx=%f, diff=%f\n",...
         delPdelrp(k), (PD-P)/del, delPdelrp(k)-(PD-P)/del);

  % delPdelthetap
  [PD,gradPD]=iirP(wc,[g R0 Rp r0 theta0 rp thetap+delk],U,V,M,Q,R);
  hessPD(1+U+V+M+Qon2+k,:)=(gradPD-gradP)/del;
  printf("delPdelthetap=%f, approx=%f, diff=%f\n",...
         delPdelthetap(k), (PD-P)/del, delPdelthetap(k)-(PD-P)/del);
endfor

% Compare the phase hessian and approximation by gradP
hessP=iirP_hessP_DiagonalApprox(wc,x0,U,V,M,Q,R);

diag(hessP((1+1):(1+U),(1+1):(1+U)))';
diag(hessPD((1+1):(1+U),(1+1):(1+U)))';

diag(hessP((1+U+1):(1+U+V),(1+U+1):(1+U+V)))';
diag(hessPD((1+U+1):(1+U+V),(1+U+1):(1+U+V)))';

diag(hessP((1+U+V+1):(1+U+V+Mon2),(1+U+V+1):(1+U+V+Mon2)))';
diag(hessPD((1+U+V+1):(1+U+V+Mon2),(1+U+V+1):(1+U+V+Mon2)))';

diag(hessP((1+U+V+Mon2+1):(1+U+V+M),(1+U+V+1):(1+U+V+Mon2)))';
diag(hessPD((1+U+V+Mon2+1):(1+U+V+M),(1+U+V+1):(1+U+V+Mon2)))';

diag(hessP((1+U+V+Mon2+1):(1+U+V+M),(1+U+V+Mon2+1):(1+U+V+M)))';
diag(hessPD((1+U+V+Mon2+1):(1+U+V+M),(1+U+V+Mon2+1):(1+U+V+M)))';

diag(hessP((1+U+V+M+1):(1+U+V+M+Qon2),(1+U+V+M+1):(1+U+V+M+Qon2)))';
diag(hessPD((1+U+V+M+1):(1+U+V+M+Qon2),(1+U+V+M+1):(1+U+V+M+Qon2)))';

diag(hessP((1+U+V+M+Qon2+1):(1+U+V+M+Q),(1+U+V+M+1):(1+U+V+M+Qon2)))';
diag(hessPD((1+U+V+M+Qon2+1):(1+U+V+M+Q),(1+U+V+M+1):(1+U+V+M+Qon2)))';

diag(hessP((1+U+V+M+Qon2+1):(1+U+V+M+Q),(1+U+V+M+Qon2+1):(1+U+V+M+Q)))';
diag(hessPD((1+U+V+M+Qon2+1):(1+U+V+M+Q),(1+U+V+M+Qon2+1):(1+U+V+M+Q)))';

printf("\nCompare hessP to the approximation (hessPD-hessP)./hessP\n");
hessP_del = (diag(hessPD)-diag(hessP))./diag(hessP);
max(abs(hessP_del(isfinite(hessP_del))))

% Done
diary off
movefile iirP_test.diary.tmp iirP_test.diary;
