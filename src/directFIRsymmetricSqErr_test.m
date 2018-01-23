% directFIRsymmetricSqErr_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("directFIRsymmetricSqErr_test.diary");
unlink("directFIRsymmetricSqErr_test.diary.tmp");
diary directFIRsymmetricSqErr_test.diary.tmp

format short e

% Specify desired response
npoints=10^4
fapl=0.1;fapu=0.2;fasl=0.05;fasu=0.25;
Wasl=30;Wap=1;Wasu=30;
nasl=ceil(npoints*fasl/0.5)+1;
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
nasu=floor(npoints*fasu/0.5)+1;
wa=(0:npoints)'*pi/npoints;
Ad=[zeros(napl-1,1); ...
    ones(napu-napl+1,1); ...
    zeros(npoints-napu+1,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(npoints-nasu+2,1)];

% Sanity check on frequencies
nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];
printf("nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];\n");
printf("nchk=[ ");printf("%d ",nchk);printf("];\n");
printf("wa(nchk)*0.5/pi=[");printf("%6.4g ",0.5*wa(nchk)'/pi);printf("];\n");
printf("Ad(nchk)=[ ");printf("%6.4g ",Ad(nchk)');printf("];\n");
printf("Wa(nchk)=[ ");printf("%6.4g ",Wa(nchk)');printf("];\n");

% Design the bandpass filter
M=20;
h=remez(2*M,2*[0, fasl, fapl, fapu, fasu, 0.5], ...
        [0, 0, 1, 1, 0, 0],[Wasl, Wap, Wasu]);
hM=h(1:(M+1));

% Initialise 
tol=1e-8
directFIRsymmetricSqErr(0,hM,Ad,Wa);

% Calculate the mean-squared-error

% Exact integration
waPW=2*pi*[0 fasl fapl fapu fasu 0.5];
AdPW=[0 0 1 0 0];
WaPW=[Wasl 0 Wap 0 Wasu];
EsqPW=directFIRsymmetricEsqPW(hM,waPW,AdPW,WaPW)

% Trapezoidal integration
Esq=directFIRsymmetricEsq(hM,wa,Ad,Wa)
Esq_T=trapz(wa,arrayfun(@directFIRsymmetricSqErr,wa))
if abs(Esq-Esq_T)>eps
  error("abs(Esq-Esq_T)>eps");
endif

% Octave quadrature variants
[Esq_Q, IER_Q,NFUN_Q,ERR_Q] = quad  (@directFIRsymmetricSqErr,0,pi,tol)
[Esq_V, NFUN_V] =             quadv (@directFIRsymmetricSqErr,0,pi,tol)
[Esq_CC,ERR_CC,NR_CC] =       quadcc(@directFIRsymmetricSqErr,0,pi,tol)
[Esq_GK,ERR_GK] =             quadgk(@directFIRsymmetricSqErr,0,pi,tol)
[Esq_L, NFUN_L] =             quadl (@directFIRsymmetricSqErr,0,pi,tol)

% Done
diary off
movefile directFIRsymmetricSqErr_test.diary.tmp ...
         directFIRsymmetricSqErr_test.diary;
