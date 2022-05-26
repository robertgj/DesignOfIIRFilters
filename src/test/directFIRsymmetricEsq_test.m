% directFIRsymmetricEsq_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("directFIRsymmetricEsq_test.diary");
delete("directFIRsymmetricEsq_test.diary.tmp");
diary directFIRsymmetricEsq_test.diary.tmp

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

% Exact calculation
waPW=2*pi*[0 fasl fapl fapu fasu 0.5];
AdPW=[0 0 1 0 0];
WaPW=[Wasl 0 Wap 0 Wasu];
[EsqPW,gradEsqPW,QPW,qPW]=directFIRsymmetricEsqPW(hM,waPW,AdPW,WaPW);

% Approximate calculation using integration
[Esq,gradEsq,Q,q]=directFIRsymmetricEsq(hM,wa,Ad,Wa);

% Check relative errors
tol=1e-5

EsqErr=abs(Esq-EsqPW)/abs(EsqPW);
if EsqErr > 10*tol
  error("EsqErr(%g) > 10*tol(%g)",EsqErr,10*tol);
endif

gradEsqErr=max(abs(gradEsq-gradEsqPW))/max(abs(gradEsqPW));
if gradEsqErr > 20*tol
  error("gradEsqErr(%g) > 20*tol(%g)",gradEsqErr,20*tol);
endif

gradqErr=max(abs(q-qPW))/max(abs(qPW));
if gradqErr > 7*tol
  error("gradqErr(%g) > 7*tol(%g)",gradqErr,7*tol);
endif

gradQErr=max(max(abs(Q-QPW)))/max(max(abs(QPW)));
if gradQErr > 3*tol
  error("gradQErr(%g) > 3*tol(%g)",gradQErr,3*tol);
endif

% Done
diary off
movefile directFIRsymmetricEsq_test.diary.tmp directFIRsymmetricEsq_test.diary;
