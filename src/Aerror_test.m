% Aerror_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("Aerror_test.diary");
delete("Aerror_test.diary.tmp");
diary Aerror_test.diary.tmp


% Initial filter
U=2;V=2;M=14;Q=6;R=2;tol=1e-4;
fap=0.1;Wap=1;
fas=0.1;Was=2;
n=1024;
Lap=round(fap*n/0.5);
wa=pi*(0:(n-1))'/n;
Ad=[ones(Lap,1);zeros(n-Lap,1)];
Wa=[Wap*ones(Lap,1); Was*ones(n-Lap,1)];
x0=[  8.1134e-05, ...
      1.2500e+00, -1.0066e+00, ...
      7.4383e-01,  7.4383e-01, ...
      1.0125e+00,  1.0125e+00,  1.0125e+00,  1.0286e+00, ...
      1.0179e+00,  1.0153e+00,  1.0142e+00, ...
      2.9992e+00,  2.9992e+00,  2.9992e+00,  1.5482e+00, ...
      2.0863e+00,  2.3510e+00,  2.5094e+00, ...
      7.3201e-01,  8.3655e-01,  8.3827e-01, ...
      1.9415e+00,  1.0314e+00,  1.6531e+00 ]';

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

% Avoid response singularities by moving poles and zeros off the unit circle
R0=R0/2;
Rp=Rp/2;
r0=r0/2;
rp=rp/2;

% Initialise response
[ErrorA, gradErrorA, hessErrorA] = ...
  Aerror([K;R0;Rp;r0;theta0;rp;thetap],U,V,M,Q,R,wa,Ad,Wa);

% Calculated values
delEdelK=gradErrorA(1);
delEdelR0=gradErrorA((1+1):(1+U));
delEdelRp=gradErrorA((1+U+1):(1+UV));
delEdelr0=gradErrorA((1+UV+1):(1+UVMon2));
delEdeltheta0=gradErrorA((1+UVMon2+1):(1+UVM));
delEdelrp=gradErrorA((1+UVM+1):(1+UVMQon2));
delEdelthetap=gradErrorA((1+UVMQon2+1):(1+UVMQ));

% Small number for simpleminded gradient computation
del=tol;

% delEdelK
printf("Scale factor\n");
[ErrorAD, gradErrorAD] = ...
  Aerror([K+del;R0;Rp;r0;theta0;rp;thetap],U,V,M,Q,R,wa,Ad,Wa);
printf("delEdelK=%f, approx=%f, diff=%f\n", ...
       delEdelK, (ErrorAD-ErrorA)/del, ...
       delEdelK-(ErrorAD-ErrorA)/del);
hessErrorAD=zeros(size(hessErrorA));
hessErrorAD(1,:)=(gradErrorAD-gradErrorA)/del;

% Real zeros
for k=1:U
  printf("Real zero %d\n", k);
  delk=[zeros(1,k-1), del, zeros(1,(U-k))]';

  % delEdelR0
  [ErrorAD, gradErrorAD] = ...
    Aerror([K;R0+delk;Rp;r0;theta0;rp;thetap],U,V,M,Q,R,wa,Ad,Wa);
  printf("delEdelR0=%f, approx=%f, diff=%f\n", ...
         delEdelR0(k), (ErrorAD-ErrorA)/del, ...
         delEdelR0(k)-(ErrorAD-ErrorA)/del);
  hessErrorAD(1+k,:)=(gradErrorAD-gradErrorA)/del;
endfor

% Real poles
for k=1:V
  printf("Real pole %d\n", k);
  delk=[zeros(1,k-1), del, zeros(1,(V-k))]';

  % delEdelrp
  [ErrorAD, gradErrorAD] = ...
    Aerror([K;R0;Rp+delk;r0;theta0;rp;thetap],U,V,M,Q,R,wa,Ad,Wa);
  printf("delEdelRp=%f, approx=%f, diff=%f\n", ...
         delEdelRp(k), (ErrorAD-ErrorA)/del, ...
         delEdelRp(k)-(ErrorAD-ErrorA)/del);
  hessErrorAD(1+U+k,:)=(gradErrorAD-gradErrorA)/del;
endfor

% Conjugate zeros
for k=1:Mon2
  printf("Conjugate zero %d\n", k);
  delk=[zeros(1,k-1), del, zeros(1,(Mon2-k))]';

  % delEdelr0
  [ErrorAD, gradErrorAD] = ...
    Aerror([K;R0;Rp;r0+delk;theta0;rp;thetap],U,V,M,Q,R,wa,Ad,Wa);
  printf("delEdelr0=%f, approx=%f, diff=%f\n", ...
         delEdelr0(k), (ErrorAD-ErrorA)/del, ...
         delEdelr0(k)-(ErrorAD-ErrorA)/del);
  hessErrorAD(1+U+V+k,:)=(gradErrorAD-gradErrorA)/del;

  % delEdeltheta0
  [ErrorAD, gradErrorAD] = ...
    Aerror([K;R0;Rp;r0;theta0+delk;rp;thetap],U,V,M,Q,R,wa,Ad,Wa);
  printf("delEdeltheta0=%f, approx=%f, diff=%f\n", ...
         delEdeltheta0(k), (ErrorAD-ErrorA)/del, ...
         delEdeltheta0(k)-(ErrorAD-ErrorA)/del);
  hessErrorAD(1+U+V+Mon2+k,:)=(gradErrorAD-gradErrorA)/del;
endfor

% Conjugate poles
for k=1:Qon2
  printf("Conjugate pole %d\n", k);
  delk=[zeros(1,k-1), del, zeros(1,(Qon2-k))]';

  % delEdelrp
  [ErrorAD, gradErrorAD] = ...
    Aerror([K;R0;Rp;r0;theta0;rp+delk;thetap],U,V,M,Q,R,wa,Ad,Wa);
  printf("delEdelrp=%f, approx=%f, diff=%f\n", ...
         delEdelrp(k), (ErrorAD-ErrorA)/del, ...
         delEdelrp(k)-(ErrorAD-ErrorA)/del);
  hessErrorAD(1+U+V+M+k,:)=(gradErrorAD-gradErrorA)/del;

  % delEdelthetap
  [ErrorAD, gradErrorAD] = ...
    Aerror([K;R0;Rp;r0;theta0;rp;thetap+delk],U,V,M,Q,R,wa,Ad,Wa);
  printf("delEdelthetap=%f, approx=%f, diff=%f\n", ...
         delEdelthetap(k), (ErrorAD-ErrorA)/del, ...
         delEdelthetap(k)-(ErrorAD-ErrorA)/del);
  hessErrorAD(1+U+V+M+Qon2+k,:)=(gradErrorAD-gradErrorA)/del;
endfor

% Compare the hessian and approximation by gradErrorA
printf("\nCompare hessErrorA to the approximation \
(hessErrorAD-hessErrorA)./hessErrorA\n");
hessErrorA_del=(hessErrorAD-hessErrorA)./hessErrorA;
max(abs(hessErrorA_del(isfinite(hessErrorA_del))))

% Extra check 
del=del/10;
delk=[del, zeros(1,N-1)]';
hessErrorAD10=zeros(size(hessErrorA));
x=[K;R0;Rp;r0;theta0;rp;thetap];
for k=1:length(delk)
  [ErrorAD, gradErrorAD] = Aerror(x+delk,U,V,M,Q,R,wa,Ad,Wa);
  hessErrorAD10(k,:)=(gradErrorAD-gradErrorA)/del;
  delk=shift(delk,1);
endfor

% Compare the hessian and approximation by gradErrorA
printf("\nCompare hessErrorA to the approximation \
(hessErrorAD10-hessErrorA)./hessErrorA\n");
hessErrorA10_del = (hessErrorAD10-hessErrorA)./hessErrorA;
max(abs(hessErrorA10_del(isfinite(hessErrorA10_del))))

diary off
movefile Aerror_test.diary.tmp Aerror_test.diary;
