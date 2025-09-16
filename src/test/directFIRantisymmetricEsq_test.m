% directFIRantisymmetricEsq_test.m
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="directFIRantisymmetricEsq_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

% From selesnickFIRantisymmetric_linear_differentiator_test_hN31K25_coef.m
hM = [  0.0000000867, -0.0000020406,  0.0000226249, -0.0001563176, ... 
        0.0007481877, -0.0025963913,  0.0065722137, -0.0115252141, ... 
        0.0106152887,  0.0093459510, -0.0573316423,  0.1145482184, ... 
       -0.1127602358, -0.0720992873,  0.7329564858 ];

% Specify desired response
tol=10*eps;
nplot=1024;
M=length(hM);
fap=0.25;fas=0.4; Wap=1;Was=10;
wa=(0:nplot)'*pi/nplot;
nap=ceil(nplot*fap/0.5)+1;
nas=floor(nplot*fas/0.5)+1;
Ad=[wa(1:nap);zeros(nplot-nap+1,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(nplot-nas+2,1)]; 

[Esq,gradEsq]=directFIRantisymmetricEsq(hM,wa,Ad,Wa);

% Approximate calculation of Esq using integration
A=directFIRantisymmetricA(wa,hM);
AErr=Wa.*((A-Ad).^2);
AErrSum=sum(diff(wa).*(AErr(1:(end-1))+AErr(2:end))/2)/pi;
err_Esq=abs(AErrSum-Esq);
if err_Esq > tol
  error("(abs(AErrSum(%17.11g)-Esq(%17.11g))(=%17.11g*tol)>tol(%g)", ...
        AErrSum,Esq,err_Esq/tol,tol);
endif

% Check the gradients of the squared-error response wrt h
del=10^(floor(log10(min(abs(hM))))-1);
delh=zeros(size(hM));
delh(1)=del/2;
diff_Esqh=zeros(size(gradEsq));
for k=1:M
  EsqhPdelh=directFIRantisymmetricEsq(hM+delh,wa,Ad,Wa);
  EsqhMdelh=directFIRantisymmetricEsq(hM-delh,wa,Ad,Wa);
  diff_Esq(k)=(EsqhPdelh-EsqhMdelh)/del;
  delh=circshift(delh,1);
endfor
if max(abs(diff_Esq-gradEsq)) > 200*del
        error("max(abs(diff_Esq-gradEsq))(%g*del) > 200*del", ...
              max(abs(diff_Esq-gradEsq))/del);
endif


% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
