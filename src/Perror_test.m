% Perror_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("Perror_test.diary");
unlink("Perror_test.diary.tmp");
diary Perror_test.diary.tmp


% Initial filter
U=2;V=2;M=14;Q=6;R=2;tol=1e-4;
x0=[  8.1134e-05, ...
      1.2500e+00, -1.0066e+00, ...
      7.4383e-01,  7.4383e-01, ...
      1.0125e+00,  1.0125e+00,  1.0125e+00,  1.0286e+00, ...
      1.0179e+00,  1.0153e+00,  1.0142e+00, ...
      2.9992e+00,  2.9992e+00,  2.9992e+00,  1.5482e+00, ...
      2.0863e+00,  2.3510e+00,  2.5094e+00, ...
      7.3201e-01,  8.3655e-01,  8.3827e-01, ...
      1.9415e+00,  1.0314e+00,  1.6531e+00 ]';

% Design parameters
fap=0.1;
td=(U+M)/2;
n=1000;
Lpp=ceil(fap*n/0.5)+1;
wp=pi*(0:(Lpp-1))'/n;
Pd=pi-wp*td;
Wp=ones(Lpp,1);

% Internal initialisation
Mon2=M/2;                  % Number of zero pairs
Qon2=Q/2;                  % Number of pole pairs
N=1+U+V+M+Q;
UV=U+V;
UVMon2=UV+Mon2;
UVM=UV+M;
UVMQon2=UVM+Qon2;
UVMQ=UVM+Q;
K=x0(1);
R0=x0((1+1):(1+U));
Rp=x0((1+U+1):(1+UV));
r0=x0((1+UV+1):(1+UVMon2));
theta0=x0((1+UVMon2+1):(1+UVM));
rp=x0((1+UVM+1):(1+UVMQon2));
thetap=x0((1+UVMQon2+1):(1+UVMQ));

% Pvoid response singularities by moving poles and zeros off the unit circle
R0=R0/2;
Rp=Rp/2;
r0=r0/2;
rp=rp/2;

% Initialise response
[ErrorP, gradErrorP, hessErrorP] = ...
  Perror([K;R0,;Rp;r0;theta0;rp;thetap],U,V,M,Q,R,wp,Pd,Wp);

% Calculated values
delEdelK=gradErrorP(1);
delEdelR0=gradErrorP((1+1):(1+U));
delEdelRp=gradErrorP((1+U+1):(1+UV));
delEdelr0=gradErrorP((1+UV+1):(1+UVMon2));
delEdeltheta0=gradErrorP((1+UVMon2+1):(1+UVM));
delEdelrp=gradErrorP((1+UVM+1):(1+UVMQon2));
delEdelthetap=gradErrorP((1+UVMQon2+1):(1+UVMQ));

% Small number for simpleminded gradient computation
del=tol;

% delEdelK
printf("Scale factor\n");
[ErrorPD, gradErrorPD] = ...
  Perror([K+del;R0;Rp;r0;theta0;rp;thetap],U,V,M,Q,R,wp,Pd,Wp);
printf("delEdelK=%f, approx=%f, diff=%f\n", ...
       delEdelK, (ErrorPD-ErrorP)/del, ...
       delEdelK-(ErrorPD-ErrorP)/del);
hessErrorPD=zeros(size(hessErrorP));
hessErrorPD(1,:)=(gradErrorPD-gradErrorP)/del;

% Real zeros
for k=1:U
  printf("Real zero %d\n", k);
  delk=[zeros(1,k-1), del, zeros(1,(U-k))]';

  % delEdelR0
  [ErrorPD, gradErrorPD] = ...
    Perror([K;R0+delk;Rp;r0;theta0;rp;thetap],U,V,M,Q,R,wp,Pd,Wp);
  printf("delEdelR0=%f, approx=%f, diff=%f\n", ...
         delEdelR0(k), (ErrorPD-ErrorP)/del, ...
         delEdelR0(k)-(ErrorPD-ErrorP)/del);
  hessErrorPD(1+k,:)=(gradErrorPD-gradErrorP)/del;
endfor

% Real poles
for k=1:V
  printf("Real pole %d\n", k);
  delk=[zeros(1,k-1), del, zeros(1,(V-k))]';

  % delEdelrp
  [ErrorPD, gradErrorPD] = ...
    Perror([K;R0;Rp+delk;r0;theta0;rp;thetap],U,V,M,Q,R,wp,Pd,Wp);
  printf("delEdelRp=%f, approx=%f, diff=%f\n", ...
         delEdelRp(k), (ErrorPD-ErrorP)/del, ...
         delEdelRp(k)-(ErrorPD-ErrorP)/del);
  hessErrorPD(1+U+k,:)=(gradErrorPD-gradErrorP)/del;
endfor

% Conjugate zeros
for k=1:Mon2
  printf("Conjugate zero %d\n", k);
  delk=[zeros(1,k-1), del, zeros(1,(Mon2-k))]';

  % delEdelr0
  [ErrorPD, gradErrorPD] = ...
    Perror([K;R0;Rp;r0+delk;theta0;rp;thetap],U,V,M,Q,R,wp,Pd,Wp);
  printf("delEdelr0=%f, approx=%f, diff=%f\n", ...
         delEdelr0(k), (ErrorPD-ErrorP)/del, ...
         delEdelr0(k)-(ErrorPD-ErrorP)/del);
  hessErrorPD(1+U+V+k,:)=(gradErrorPD-gradErrorP)/del;

  % delEdeltheta0
  [ErrorPD, gradErrorPD] = ...
    Perror([K;R0;Rp;r0;theta0+delk;rp;thetap],U,V,M,Q,R,wp,Pd,Wp);
  printf("delEdeltheta0=%f, approx=%f, diff=%f\n", ...
         delEdeltheta0(k), (ErrorPD-ErrorP)/del, ...
         delEdeltheta0(k)-(ErrorPD-ErrorP)/del);
  hessErrorPD(1+U+V+Mon2+k,:)=(gradErrorPD-gradErrorP)/del;
endfor

% Conjugate poles
for k=1:Qon2
  printf("Conjugate pole %d\n", k);
  delk=[zeros(1,k-1), del, zeros(1,(Qon2-k))]';

  % delEdelrp
  [ErrorPD, gradErrorPD] = ...
    Perror([K;R0;Rp;r0;theta0;rp+delk;thetap],U,V,M,Q,R,wp,Pd,Wp);
  printf("delEdelrp=%f, approx=%f, diff=%f\n", ...
         delEdelrp(k), (ErrorPD-ErrorP)/del, ...
         delEdelrp(k)-(ErrorPD-ErrorP)/del);
  hessErrorPD(1+U+V+M+k,:)=(gradErrorPD-gradErrorP)/del;

  % delEdelthetap
  [ErrorPD, gradErrorPD] = ...
    Perror([K;R0;Rp;r0;theta0;rp;thetap+delk],U,V,M,Q,R,wp,Pd,Wp);
  printf("delEdelthetap=%f, approx=%f, diff=%f\n", ...
         delEdelthetap(k), (ErrorPD-ErrorP)/del, ...
         delEdelthetap(k)-(ErrorPD-ErrorP)/del);
  hessErrorPD(1+U+V+M+Qon2+k,:)=(gradErrorPD-gradErrorP)/del;
endfor

% Compare the hessian and approximation by gradErrorP
printf("\nCompare hessErrorP to the approximation \
(hessErrorPD-hessErrorP)./hessErrorP\n");
hessErrorP_del=(hessErrorPD-hessErrorP)./hessErrorP;
max(abs(hessErrorP_del(isfinite(hessErrorP_del))))

% Extra check 
del=del/10;
delk=[del, zeros(1,N-1)]';
hessErrorPD10=zeros(size(hessErrorP));
x=[K;R0;Rp;r0;theta0;rp;thetap];
for k=1:length(delk)
  [ErrorPD, gradErrorPD] = Perror(x+delk,U,V,M,Q,R,wp,Pd,Wp);
  hessErrorPD10(k,:)=(gradErrorPD-gradErrorP)/del;
  delk=shift(delk,1);
endfor

% Compare the hessian and approximation by gradErrorP
printf("\nCompare hessErrorP to the approximation \
(hessErrorPD10-hessErrorP)./hessErrorP\n");
diag(hessErrorP)
hessErrorP10_del = (diag(hessErrorPD10)-diag(hessErrorP))./diag(hessErrorP)
max(abs(hessErrorP10_del(isfinite(hessErrorP10_del))))


diary off
movefile Perror_test.diary.tmp Perror_test.diary;
