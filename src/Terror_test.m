% Terror_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("Terror_test.diary");
delete("Terror_test.diary.tmp");
diary Terror_test.diary.tmp


% Initial filter
U=2;V=2;M=14;Q=6;R=2;tol=1e-4;
ftp=0.1;Wtp=0.2;td=16;
n=1000;
Ltp=ceil(ftp*n/0.5)+1;
wt=pi*(0:(Ltp-1))'/n;
Td=td*ones(Ltp,1);
Wt=Wtp*ones(Ltp,1);
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
[ErrorT, gradErrorT, hessErrorT] = ...
  Terror([K;R0,;Rp;r0;theta0;rp;thetap],U,V,M,Q,R,wt,Td,Wt);

% Calculated values
delEdelK=gradErrorT(1);
delEdelR0=gradErrorT((1+1):(1+U));
delEdelRp=gradErrorT((1+U+1):(1+UV));
delEdelr0=gradErrorT((1+UV+1):(1+UVMon2));
delEdeltheta0=gradErrorT((1+UVMon2+1):(1+UVM));
delEdelrp=gradErrorT((1+UVM+1):(1+UVMQon2));
delEdelthetap=gradErrorT((1+UVMQon2+1):(1+UVMQ));

% Small number for simpleminded gradient computation
del=tol;

% delEdelK
printf("Scale factor\n");
[ErrorTD, gradErrorTD] = ...
  Terror([K+del;R0;Rp;r0;theta0;rp;thetap],U,V,M,Q,R,wt,Td,Wt);
printf("delEdelK=%f, approx=%f, diff=%f\n", ...
       delEdelK, (ErrorTD-ErrorT)/del, ...
       delEdelK-(ErrorTD-ErrorT)/del);
hessErrorTD=zeros(size(hessErrorT));
hessErrorTD(1,:)=(gradErrorTD-gradErrorT)/del;

% Real zeros
for k=1:U
  printf("Real zero %d\n", k);
  delk=[zeros(1,k-1), del, zeros(1,(U-k))]';

  % delEdelR0
  [ErrorTD, gradErrorTD] = ...
    Terror([K;R0+delk;Rp;r0;theta0;rp;thetap],U,V,M,Q,R,wt,Td,Wt);
  printf("delEdelR0=%f, approx=%f, diff=%f\n", ...
         delEdelR0(k), (ErrorTD-ErrorT)/del, ...
         delEdelR0(k)-(ErrorTD-ErrorT)/del);
  hessErrorTD(1+k,:)=(gradErrorTD-gradErrorT)/del;
endfor

% Real poles
for k=1:V
  printf("Real pole %d\n", k);
  delk=[zeros(1,k-1), del, zeros(1,(V-k))]';

  % delEdelrp
  [ErrorTD, gradErrorTD] = ...
    Terror([K;R0;Rp+delk;r0;theta0;rp;thetap],U,V,M,Q,R,wt,Td,Wt);
  printf("delEdelRp=%f, approx=%f, diff=%f\n", ...
         delEdelRp(k), (ErrorTD-ErrorT)/del, ...
         delEdelRp(k)-(ErrorTD-ErrorT)/del);
  hessErrorTD(1+U+k,:)=(gradErrorTD-gradErrorT)/del;
endfor

% Conjugate zeros
for k=1:Mon2
  printf("Conjugate zero %d\n", k);
  delk=[zeros(1,k-1), del, zeros(1,(Mon2-k))]';

  % delEdelr0
  [ErrorTD, gradErrorTD] = ...
    Terror([K;R0;Rp;r0+delk;theta0;rp;thetap],U,V,M,Q,R,wt,Td,Wt);
  printf("delEdelr0=%f, approx=%f, diff=%f\n", ...
         delEdelr0(k), (ErrorTD-ErrorT)/del, ...
         delEdelr0(k)-(ErrorTD-ErrorT)/del);
  hessErrorTD(1+U+V+k,:)=(gradErrorTD-gradErrorT)/del;

  % delEdeltheta0
  [ErrorTD, gradErrorTD] = ...
    Terror([K;R0;Rp;r0;theta0+delk;rp;thetap],U,V,M,Q,R,wt,Td,Wt);
  printf("delEdeltheta0=%f, approx=%f, diff=%f\n", ...
         delEdeltheta0(k), (ErrorTD-ErrorT)/del, ...
         delEdeltheta0(k)-(ErrorTD-ErrorT)/del);
  hessErrorTD(1+U+V+Mon2+k,:)=(gradErrorTD-gradErrorT)/del;
endfor

% Conjugate poles
for k=1:Qon2
  printf("Conjugate pole %d\n", k);
  delk=[zeros(1,k-1), del, zeros(1,(Qon2-k))]';

  % delEdelrp
  [ErrorTD, gradErrorTD] = ...
    Terror([K;R0;Rp;r0;theta0;rp+delk;thetap],U,V,M,Q,R,wt,Td,Wt);
  printf("delEdelrp=%f, approx=%f, diff=%f\n", ...
         delEdelrp(k), (ErrorTD-ErrorT)/del, ...
         delEdelrp(k)-(ErrorTD-ErrorT)/del);
  hessErrorTD(1+U+V+M+k,:)=(gradErrorTD-gradErrorT)/del;

  % delEdelthetap
  [ErrorTD, gradErrorTD] = ...
    Terror([K;R0;Rp;r0;theta0;rp;thetap+delk],U,V,M,Q,R,wt,Td,Wt);
  printf("delEdelthetap=%f, approx=%f, diff=%f\n", ...
         delEdelthetap(k), (ErrorTD-ErrorT)/del, ...
         delEdelthetap(k)-(ErrorTD-ErrorT)/del);
  hessErrorTD(1+U+V+M+Qon2+k,:)=(gradErrorTD-gradErrorT)/del;
endfor

% Compare the hessian and approximation by gradErrorT
printf("\nCompare hessErrorT to the approximation \
(hessErrorTD-hessErrorT)./hessErrorT\n");
hessErrorT_del=(hessErrorTD-hessErrorT)./hessErrorT;
max(abs(hessErrorT_del(isfinite(hessErrorT_del))))

% Extra check 
del=del/10;
delk=[del, zeros(1,N-1)]';
hessErrorTD10=zeros(size(hessErrorT));
x=[K;R0;Rp;r0;theta0;rp;thetap];
for k=1:length(delk)
  [ErrorTD, gradErrorTD] = Terror(x+delk,U,V,M,Q,R,wt,Td,Wt);
  hessErrorTD10(k,:)=(gradErrorTD-gradErrorT)/del;
  delk=shift(delk,1);
endfor

% Compare the hessian and approximation by gradErrorT
printf("\nCompare hessErrorT to the approximation \
(hessErrorTD10-hessErrorT)./hessErrorT\n");
hessErrorT10_del = (hessErrorTD10-hessErrorT)./hessErrorT;
max(abs(hessErrorT10_del(isfinite(hessErrorT10_del))))

diary off
movefile Terror_test.diary.tmp Terror_test.diary;
