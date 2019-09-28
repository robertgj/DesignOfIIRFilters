% iirA_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

unlink("iirA_test.diary");
unlink("iirA_test.diary.tmp");
diary iirA_test.diary.tmp


% Simple case 
[A,gradA]=iirA(0.1,0,0,0,0,0,1);
if (A ~= 0) || (gradA ~= 0)
  error("Expected A==0 and gradA==0");
endif

% Check with zero poles
try
  [A,gradA]=iirA(0.1,[1, 0],0,1,0,0,2);
catch err
  printf("Caught error : %s\n",err.message);
end_try_catch
try
  [A,gradA,hessA]=iirA(0.1,[1, 0, pi],0,0,0,2,2);
catch err
  printf("Caught error : %s\n",err.message);
end_try_catch

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
     -0.9698147, -0.8442244,  0.4511337,  0.4242641, ...
      1.8917946,  1.7780303,  1.2325954,  0.7853982 ]';

%
% Test amplitude
%
% Check empty frequency
A=iirA([],x0,U,V,M,Q,R);
if !isempty(A)
  error("Expected A=[]");
endif

% Use iirA
L=512;
w=(0:(L-1))'*pi/L;
[A,gradA]=iirA(w,x0,U,V,M,Q,R);
% Compare A with freqz
[N,D]=x2tf(x0,U,V,M,Q,R);
H=freqz(N,D,w);
if mean(abs(abs(H)-A)) > 25*eps
  error("mean(abs(abs(H)-A)) > 25*eps");
endif

%
% Test gradients of amplitude
%
Mon2=M/2;
Qon2=Q/2;
wc=2*pi*fc;

% Calculated values
[A,gradA,hessA]=iirA(wc,x0,U,V,M,Q,R);
delAdelK=gradA(1);
delAdelR0=gradA((1+1):(1+U));
delAdelRp=gradA((1+U+1):(1+U+V));
delAdelr0=gradA((1+U+V+1):(1+U+V+Mon2));
delAdeltheta0=gradA((1+U+V+Mon2+1):(1+U+V+M));
delAdelrp=gradA((1+U+V+M+1):(1+U+V+M+Qon2));
delAdelthetap=gradA((1+U+V+M+Qon2+1):(1+U+V+M+Q));

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
hessAD=zeros(size(hessA));

% delAdelK
[AD,gradAD]=iirA(wc,[g+del R0 Rp r0 theta0 rp thetap],U,V,M,Q,R);
hessAD(1,:)=(gradAD-gradA)/del;
printf("delAdelK=%f, approx=%f, diff=%f\n",...
       delAdelK, (AD-A)/del, delAdelK-(AD-A)/del);

% Real zeros
for k=1:U
  printf("Real zero %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(U-k))];

  % delAdelR0
  [AD,gradAD]=iirA(wc,[g R0+delk Rp r0 theta0 rp thetap],U,V,M,Q,R);
  hessAD(1+k,:)=(gradAD-gradA)/del;
  printf("delAdelR0=%f, approx=%f, diff=%f\n",...
         delAdelR0(k), (AD-A)/del, delAdelR0(k)-(AD-A)/del);
endfor

% Real poles
for k=1:V
  printf("Real pole %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(V-k))];

  % delAdelRp
  [AD,gradAD]=iirA(wc,[g R0 Rp+delk r0 theta0 rp thetap],U,V,M,Q,R);
  hessAD(1+U+k,:)=(gradAD-gradA)/del;
  printf("delAdelRp=%f, approx=%f, diff=%f\n",...
         delAdelRp(k), (AD-A)/del, delAdelRp(k)-(AD-A)/del);
endfor

% Conjugate zeros
for k=1:Mon2
  printf("Conjugate zero %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(Mon2-k))];

  % delAdelr0
  [AD,gradAD]=iirA(wc,[g R0 Rp r0+delk theta0 rp thetap],U,V,M,Q,R);
  hessAD(1+U+V+k,:)=(gradAD-gradA)/del;
  printf("delAdelr0=%f, approx=%f, diff=%f\n",...
         delAdelr0(k), (AD-A)/del, delAdelr0(k)-(AD-A)/del);

  % delAdeltheta0
  [AD,gradAD]=iirA(wc,[g R0 Rp r0 theta0+delk rp thetap],U,V,M,Q,R);
  hessAD(1+U+V+Mon2+k,:)=(gradAD-gradA)/del;
  printf("delAdeltheta0=%f, approx=%f, diff=%f\n",...
         delAdeltheta0(k), (AD-A)/del, delAdeltheta0(k)-(AD-A)/del);
endfor

% Conjugate poles
for k=1:Qon2
  printf("Conjugate pole %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(Qon2-k))];

  % delAdelrp
  [AD,gradAD]=iirA(wc,[g R0 Rp r0 theta0 rp+delk thetap],U,V,M,Q,R);
  hessAD(1+U+V+M+k,:)=(gradAD-gradA)/del;
  printf("delAdelrp=%f, approx=%f, diff=%f\n",...
         delAdelrp(k), (AD-A)/del, delAdelrp(k)-(AD-A)/del);

  % delAdelthetap
  [AD,gradAD]=iirA(wc,[g R0 Rp r0 theta0 rp thetap+delk],U,V,M,Q,R);
  hessAD(1+U+V+M+Qon2+k,:)=(gradAD-gradA)/del;
  printf("delAdelthetap=%f, approx=%f, diff=%f\n",...
         delAdelthetap(k), (AD-A)/del, delAdelthetap(k)-(AD-A)/del);
endfor

%
% Test hessian of amplitude
%
diag(hessA((1+1):(1+U),(1+1):(1+U)))';
diag(hessAD((1+1):(1+U),(1+1):(1+U)))';

diag(hessA((1+U+1):(1+U+V),(1+U+1):(1+U+V)))';
diag(hessAD((1+U+1):(1+U+V),(1+U+1):(1+U+V)))';

diag(hessA((1+U+V+1):(1+U+V+Mon2),(1+U+V+1):(1+U+V+Mon2)))';
diag(hessAD((1+U+V+1):(1+U+V+Mon2),(1+U+V+1):(1+U+V+Mon2)))';

diag(hessA((1+U+V+Mon2+1):(1+U+V+M),(1+U+V+1):(1+U+V+Mon2)))';
diag(hessAD((1+U+V+Mon2+1):(1+U+V+M),(1+U+V+1):(1+U+V+Mon2)))';

diag(hessA((1+U+V+Mon2+1):(1+U+V+M),(1+U+V+Mon2+1):(1+U+V+M)))';
diag(hessAD((1+U+V+Mon2+1):(1+U+V+M),(1+U+V+Mon2+1):(1+U+V+M)))';

diag(hessA((1+U+V+M+1):(1+U+V+M+Qon2),(1+U+V+M+1):(1+U+V+M+Qon2)))';
diag(hessAD((1+U+V+M+1):(1+U+V+M+Qon2),(1+U+V+M+1):(1+U+V+M+Qon2)))';

diag(hessA((1+U+V+M+Qon2+1):(1+U+V+M+Q),(1+U+V+M+1):(1+U+V+M+Qon2)))';
diag(hessAD((1+U+V+M+Qon2+1):(1+U+V+M+Q),(1+U+V+M+1):(1+U+V+M+Qon2)))';

diag(hessA((1+U+V+M+Qon2+1):(1+U+V+M+Q),(1+U+V+M+Qon2+1):(1+U+V+M+Q)))';
diag(hessAD((1+U+V+M+Qon2+1):(1+U+V+M+Q),(1+U+V+M+Qon2+1):(1+U+V+M+Q)))';

printf("\nCompare hessA to the approximation (hessAD-hessA)./hessA\n");
hessA_del = (hessAD-hessA)./hessA;
max(abs(hessA_del(isfinite(hessA_del))))

diary off
movefile iirA_test.diary.tmp iirA_test.diary;
