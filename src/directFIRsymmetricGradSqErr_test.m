% directFIRsymmetricEsq_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("directFIRsymmetricGradSqErr_test.diary");
unlink("directFIRsymmetricGradSqErr_test.diary.tmp");
diary directFIRsymmetricGradSqErr_test.diary.tmp

% Specify desired response
npoints=10^5;
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
% Sanity check
nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];
printf("nchk=[nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu];\n");
printf("nchk=[ ");printf("%d ",nchk);printf("];\n");
printf("wa(nchk)*0.5/pi=[");printf("%g ",0.5*wa(nchk)'/pi);printf("];\n");
printf("Ad(nchk)=[ ");printf("%g ",Ad(nchk)');printf("];\n");
printf("Wa(nchk)=[ ");printf("%g ",Wa(nchk)');printf("];\n");

% Design a bandpass filter
M=20;
h=remez(2*M,2*[0, fasl, fapl, fapu, fasu, 0.5], ...
        [0, 0, 1, 1, 0, 0],[Wasl, Wap, Wasu]);
hM=h(1:(M+1));

% Exact gradient of Esq
waPW=2*pi*[0 fasl fapl fapu fasu 0.5];
AdPW=[0 0 1 0 0];
WaPW=[Wasl 0 Wap 0 Wasu];
[~,gradEsqPW]=directFIRsymmetricEsqPW(hM,waPW,AdPW,WaPW);

% Approximate gradient using integration
tol=1e-8
directFIRsymmetricGradSqErr(0,hM,Ad,Wa);
[gradEsq_V, NFUN_V]=quadv(@directFIRsymmetricGradSqErr,0,pi,tol);

% Check
gradEsqErr=max(abs(gradEsq_V-gradEsqPW))/max(abs(gradEsqPW));
if gradEsqErr > 2e-4
  error("gradEsqErr(%g) > 2e-4",gradEsqErr);
endif

% Done
diary off
movefile directFIRsymmetricGradSqErr_test.diary.tmp ...
         directFIRsymmetricGradSqErr_test.diary;
