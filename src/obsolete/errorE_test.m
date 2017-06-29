% errorE_test.m
% Script to test IIR response error

test_common;

unlink("errorE_test.diary");
diary errorE_test.diary;

format compact

% Design parameters
fap=0.1;Wap=1;
fas=0.1;Was=2;
ftp=0.1;Wtp=0.2;
td=16;
n=1024;
wa=pi*(0:(n-1))'/n;
Lap=round(fap*n/0.5);
Las=round((1-fas)*n/0.5);
Ltp=round(ftp*n/0.5);
Apass=ones(Lap,1);
Ad=[Apass;zeros(n-Lap,1)];
Wa=[Wap*ones(Lap,1); Was*ones(n-Lap,1)];
wt=pi*(0:(Ltp-1))'/n;
Tpass=td*ones(Ltp,1);
Wt=Wtp*ones(Ltp,1);

% Initial filter
U=2;V=2;M=14;Q=6;R=2;tol=1e-5;
if 0
  xi=[1e-4, ...
      1.25,-1, ...
      0.8,0.8, ...
      1,1,1,1,1,1,1,3,3,3,pi/2,2*pi/3,3*pi/4,4*pi/5, ...
      0.8,0.8,0.8,5*pi/8,3*pi/8,pi/2]';
  [x0,FVEC]=xInitHd(wa,Ad,Wa,wt,Tpass,Wt,xi,U,V,M,Q,R,tol);
else
  x0=[  8.1134e-05, ...
        1.2500e+00, -1.0066e+00, ...
        7.4383e-01,  7.4383e-01, ...
        1.0125e+00,  1.0125e+00,  1.0125e+00,  1.0286e+00, ...
                     1.0179e+00,  1.0153e+00,  1.0142e+00, ...
        2.9992e+00,  2.9992e+00,  2.9992e+00,  1.5482e+00, ...
                     2.0863e+00,  2.3510e+00,  2.5094e+00, ...
        7.3201e-01,  8.3655e-01,  8.3827e-01, ...
        1.9415e+00,  1.0314e+00,  1.6531e+00 ]';
endif

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
[wap,Ap,gradAp,wtp,Tp,gradTp,was,As,gradAs,E,gradE,hessE] = ...
    errorE([K;R0;Rp;r0;theta0;rp;thetap], ...
           U,V,M,Q,R,Apass,fap,Wap,Lap,Tpass,ftp,Wtp,Ltp,fas,Was,Las,tol);

% Calculated values
delEdelK=gradE(1);
delEdelR0=gradE((1+1):(1+U));
delEdelRp=gradE((1+U+1):(1+UV));
delEdelr0=gradE((1+UV+1):(1+UVMon2));
delEdeltheta0=gradE((1+UVMon2+1):(1+UVM));
delEdelrp=gradE((1+UVM+1):(1+UVMQon2));
delEdelthetap=gradE((1+UVMQon2+1):(1+UVMQ));

% Small number for simpleminded gradient computation
del=tol;

% delEdelK
[wap Apd gradApd wtp Tpd gradTpd was Asd gradAsd Ed gradEd] = ...
    errorE([K+del;R0;Rp;r0;theta0;rp;thetap], ...
           U,V,M,Q,R,Apass,fap,Wap,Lap,Tpass,ftp,Wtp,Ltp,fas,Was,Las,tol);
hessED=zeros(size(hessE));
hessED(1,:)=(gradEd-gradE)/del;
printf("delEdelK=%f, approx=%f, diff=%f\n",...
       delEdelK, (Ed-E)/del, delEdelK-(Ed-E)/del);

% Real zeros
for k=1:U
  printf("Real zero %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(U-k))]';

  % delEdelR0
  [wap Apd gradApd wtp Tpd gradTpd was Asd gradAsd Ed gradEd] = ...
         errorE([K;R0+delk;Rp;r0;theta0;rp;thetap], ...
                U,V,M,Q,R,Apass,fap,Wap,Lap,Tpass,ftp,Wtp,Ltp,fas,Was,Las,tol);
  hessED(1+k,:)=(gradEd-gradE)/del;
  printf("delEdelR0=%f, approx=%f, diff=%f\n",...
         delEdelR0(k), (Ed-E)/del, delEdelR0(k)-(Ed-E)/del);
endfor

% Real poles
for k=1:V
  printf("Real pole %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(V-k))]';

  % delEdelrp
  [wap Apd gradApd wtp Tpd gradTpd was Asd gradAsd Ed gradEd] = ...
         errorE([K;R0;Rp+delk;r0;theta0;rp;thetap], ...
                U,V,M,Q,R,Apass,fap,Wap,Lap,Tpass,ftp,Wtp,Ltp,fas,Was,Las,tol);
  hessED(1+U+k,:)=(gradEd-gradE)/del;
  printf("delEdelRp=%f, approx=%f, diff=%f\n",...
         delEdelRp(k), (Ed-E)/del, delEdelRp(k)-(Ed-E)/del);
endfor

% Conjugate zeros
for k=1:Mon2
  printf("Conjugate zero %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(Mon2-k))]';

  % delEdelr0
  [wap Apd gradApd wtp Tpd gradTpd was Asd gradAsd Ed gradEd] = ...
         errorE([K;R0;Rp;r0+delk;theta0;rp;thetap], ...
                U,V,M,Q,R,Apass,fap,Wap,Lap,Tpass,ftp,Wtp,Ltp,fas,Was,Las,tol);
  hessED(1+U+V+k,:)=(gradEd-gradE)/del;
  printf("delEdelr0=%f, approx=%f, diff=%f\n",...
         delEdelr0(k), (Ed-E)/del, delEdelr0(k)-(Ed-E)/del);

  % delEdeltheta0
  [wap Apd gradApd wtp Tpd gradTpd was Asd gradAsd Ed gradEd] = ...
         errorE([K;R0;Rp;r0;theta0+delk;rp;thetap], ...
                U,V,M,Q,R,Apass,fap,Wap,Lap,Tpass,ftp,Wtp,Ltp,fas,Was,Las,tol);
  hessED(1+U+V+Mon2+k,:)=(gradEd-gradE)/del;
  printf("delEdeltheta0=%f, approx=%f, diff=%f\n",...
         delEdeltheta0(k), (Ed-E)/del, delEdeltheta0(k)-(Ed-E)/del);
endfor

% Conjugate poles
for k=1:Qon2
  printf("Conjugate pole %d\n", k);
  delk=[zeros(1,k-1) del zeros(1,(Qon2-k))]';

  % delEdelrp
  [wap Apd gradApd wtp Tpd gradTpd was Asd gradAsd Ed gradEd] = ...
         errorE([K;R0;Rp;r0;theta0;rp+delk;thetap], ...
                U,V,M,Q,R,Apass,fap,Wap,Lap,Tpass,ftp,Wtp,Ltp,fas,Was,Las,tol);
  hessED(1+U+V+M+k,:)=(gradEd-gradE)/del;
  printf("delEdelrp=%f, approx=%f, diff=%f\n",...
         delEdelrp(k), (Ed-E)/del, delEdelrp(k)-(Ed-E)/del);

  % delEdelthetap
  [wap Apd gradApd wtp Tpd gradTpd was Asd gradAsd Ed gradEd] = ...
         errorE([K;R0;Rp;r0;theta0;rp;thetap+delk], ...
                U,V,M,Q,R,Apass,fap,Wap,Lap,Tpass,ftp,Wtp,Ltp,fas,Was,Las,tol);
  hessED(1+U+V+M+Qon2+k,:)=(gradEd-gradE)/del;
  printf("delEdelthetap=%f, approx=%f, diff=%f\n",...
         delEdelthetap(k), (Ed-E)/del, delEdelthetap(k)-(Ed-E)/del);
endfor

% Compare the hessian and approximation by gradE
printf("\nCompare hessE to the approximation \
(hessED-hessE)./hessE\n");
hessE_del=(hessED-hessE)./hessE;
max(abs(hessE_del(isfinite(hessE_del))))


%% Extra check 
del=del/10;
delk=[del zeros(1,N-1)]';
hessED10=zeros(size(hessE));
x=[K;R0;Rp;r0;theta0;rp;thetap];
for k=1:length(delk)
  [wap Apd gradApd wtp Tpd gradTpd was Asd gradAsd Ed gradEd] = ...
      errorE(x+delk,U,V,M,Q,R, ...
             Apass,fap,Wap,Lap,Tpass,ftp,Wtp,Ltp,fas,Was,Las,tol);
  hessED10(k,:)=(gradEd-gradE)/del;
  delk=shift(delk,1);
endfor

% Compare the hessian and approximation by gradE
printf("\nCompare hessE to the approximation (hessED10-hessE)./hessE\n");
hessE10_del = (hessED10-hessE)./hessE;
max(abs(hessE10_del(isfinite(hessE10_del))))

% Compare del and del/10
hessEDComp10=(hessED-hessE)./(hessED10-hessE);
max(abs(hessEDComp10(isfinite(hessEDComp10))-10))

diary off
