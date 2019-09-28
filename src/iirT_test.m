% iirT_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen
% Script to test group delay 

test_common;

unlink("iirT_test.diary");
unlink("iirT_test.diary.tmp");
diary iirT_test.diary.tmp


% Define the filter
fc=0.10;U=2;V=2;M=20;Q=8;R=3;
x0=[  0.0089234, ...
      0.5000000,  ...
     -0.5000000,  ...
      0.5000000,  ...
     -0.5000000,  ...
     -0.5000000, -0.5000000,  0.5000000,  0.5000000,  0.5000000, ...
      0.5000000,  0.5000000,  0.5000000,  0.5000000,  0.8000000, ...
      0.6700726,  0.7205564,  0.8963898,  1.1980053,  1.3738387, ...
      1.4243225,  2.7644677,  2.8149515,  2.9907849,  1.9896753, ...
     -0.9698147, -0.8442244,  0.4511337,  0.4242641,  ...
      1.8917946,  1.7780303,  1.2325954,  0.7853982 ]';

% Check empty frequency
T=iirT([],x0,U,V,M,Q,R);
if !isempty(T)
  error("Expected T=[]");
endif

% Use iirT
L=512;
w=(0:(L-1))*pi/L;
[T,gradT]=iirT(w,x0,U,V,M,Q,R);

% Compare with grpdelay
[B,A]=x2tf(x0,U,V,M,Q,R);
Tgd=grpdelay(B,A,L);
Tgd=Tgd(1:50);
T=T(1:50);
if max(abs(Tgd-T))>200*eps
  error("max(abs(Tgd-T))>200*eps");
endif

% Test first derivatives
Mon2=M/2;
Qon2=Q/2;
wc=2*pi*fc;

% Calculated values
[T,gradT,hessT]=iirT(wc,x0,U,V,M,Q,R);
delTdelK=gradT(1);
delTdelR0=gradT((1+1):(1+U));
delTdelRp=gradT((1+U+1):(1+U+V));
delTdelr0=gradT((1+U+V+1):(1+U+V+Mon2));
delTdeltheta0=gradT((1+U+V+Mon2+1):(1+U+V+M));
delTdelrp=gradT((1+U+V+M+1):(1+U+V+M+Qon2));
delTdelthetap=gradT((1+U+V+M+Qon2+1):(1+U+V+M+Q));

% Approximate values
g=x0(1);
R0=x0((1+1):(1+U))';
Rp=x0((1+U+1):(1+U+V))';
r0=x0((1+U+V+1):(1+U+V+Mon2))';
theta0=x0((1+U+V+Mon2+1):(1+U+V+M))';
rp=x0((1+U+V+M+1):(1+U+V+M+Qon2))';
thetap=x0((1+U+V+M+Qon2+1):(1+U+V+M+Q))';
del=0.00001;

% Initialise approximate Hessian
hessTD=zeros(size(hessT));

% delTdelK
[TD,gradTD]=iirT(wc,[g+del R0 Rp r0 theta0 rp thetap],U,V,M,Q,R);
hessTD(1,:)=(gradTD-gradT)/del;
printf("delTdelK=%f, approx=%f, diff=%f\n",...
       delTdelK, (TD-T)/del, delTdelK-(TD-T)/del);

% Real zeros
for k=1:U
  printf("Real zero %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(U-k))];

  % delTdelR0
  [TD,gradTD]=iirT(wc,[g R0+delk Rp r0 theta0 rp thetap],U,V,M,Q,R);
  hessTD(1+k,:)=(gradTD-gradT)/del;
  printf("delTdelR0=%f, approx=%f, diff=%f\n",...
         delTdelR0(k), (TD-T)/del, delTdelR0(k)-(TD-T)/del);
endfor

% Real poles
for k=1:V
  printf("Real pole %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(V-k))];

  % delTdelRp
  [TD,gradTD]=iirT(wc,[g R0 Rp+delk r0 theta0 rp thetap],U,V,M,Q,R);
  hessTD(1+U+k,:)=(gradTD-gradT)/del;
  printf("delTdelRp=%f, approx=%f, diff=%f\n",...
         delTdelRp(k), (TD-T)/del, delTdelRp(k)-(TD-T)/del);
endfor

% Conjugate zeros
for k=1:Mon2
  printf("Conjugate zero %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(Mon2-k))];

  % delTdelr0
  [TD,gradTD]=iirT(wc,[g R0 Rp r0+delk theta0 rp thetap],U,V,M,Q,R);
  hessTD(1+U+V+k,:)=(gradTD-gradT)/del;
  printf("delTdelr0=%f, approx=%f, diff=%f\n",...
         delTdelr0(k), (TD-T)/del, delTdelr0(k)-(TD-T)/del);

  % delTdeltheta0
  [TD,gradTD]=iirT(wc,[g R0 Rp r0 theta0+delk rp thetap],U,V,M,Q,R);
  hessTD(1+U+V+Mon2+k,:)=(gradTD-gradT)/del;
  printf("delTdeltheta0=%f, approx=%f, diff=%f\n",...
         delTdeltheta0(k), (TD-T)/del, delTdeltheta0(k)-(TD-T)/del);
endfor

% Conjugate poles
for k=1:Qon2
  printf("Conjugate pole %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(Qon2-k))];

  % delTdelrp
  [TD,gradTD]=iirT(wc,[g R0 Rp r0 theta0 rp+delk thetap],U,V,M,Q,R);
  hessTD(1+U+V+M+k,:)=(gradTD-gradT)/del;
  printf("delTdelrp=%f, approx=%f, diff=%f\n",...
         delTdelrp(k), (TD-T)/del, delTdelrp(k)-(TD-T)/del);

  % delTdelthetap
  [TD,gradTD]=iirT(wc,[g R0 Rp r0 theta0 rp thetap+delk],U,V,M,Q,R);
  hessTD(1+U+V+M+Qon2+k,:)=(gradTD-gradT)/del;
  printf("delTdelthetap=%f, approx=%f, diff=%f\n",...
         delTdelthetap(k), (TD-T)/del, delTdelthetap(k)-(TD-T)/del);
endfor

% Compare the delay hessian and approximation by gradT
diag(hessT((1+1):(1+U),(1+1):(1+U)))';
diag(hessTD((1+1):(1+U),(1+1):(1+U)))';

diag(hessT((1+U+1):(1+U+V),(1+U+1):(1+U+V)))';
diag(hessTD((1+U+1):(1+U+V),(1+U+1):(1+U+V)))';

diag(hessT((1+U+V+1):(1+U+V+Mon2),(1+U+V+1):(1+U+V+Mon2)))';
diag(hessTD((1+U+V+1):(1+U+V+Mon2),(1+U+V+1):(1+U+V+Mon2)))';

diag(hessT((1+U+V+Mon2+1):(1+U+V+M),(1+U+V+1):(1+U+V+Mon2)))';
diag(hessTD((1+U+V+Mon2+1):(1+U+V+M),(1+U+V+1):(1+U+V+Mon2)))';

diag(hessT((1+U+V+Mon2+1):(1+U+V+M),(1+U+V+Mon2+1):(1+U+V+M)))';
diag(hessTD((1+U+V+Mon2+1):(1+U+V+M),(1+U+V+Mon2+1):(1+U+V+M)))';

diag(hessT((1+U+V+M+1):(1+U+V+M+Qon2),(1+U+V+M+1):(1+U+V+M+Qon2)))';
diag(hessTD((1+U+V+M+1):(1+U+V+M+Qon2),(1+U+V+M+1):(1+U+V+M+Qon2)))';

diag(hessT((1+U+V+M+Qon2+1):(1+U+V+M+Q),(1+U+V+M+1):(1+U+V+M+Qon2)))';
diag(hessTD((1+U+V+M+Qon2+1):(1+U+V+M+Q),(1+U+V+M+1):(1+U+V+M+Qon2)))';

diag(hessT((1+U+V+M+Qon2+1):(1+U+V+M+Q),(1+U+V+M+Qon2+1):(1+U+V+M+Q)))';
diag(hessTD((1+U+V+M+Qon2+1):(1+U+V+M+Q),(1+U+V+M+Qon2+1):(1+U+V+M+Q)))';

printf("\nCompare hessT to the approximation (hessTD-hessT)./hessT\n");
hessT_del = (hessTD-hessT)./hessT;
max(abs(hessT_del(isfinite(hessT_del))))

% Done
diary off
movefile iirT_test.diary.tmp iirT_test.diary;
