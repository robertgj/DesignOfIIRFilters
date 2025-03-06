% directFIRsymmetricEsqPW_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("directFIRsymmetricEsqPW_test.diary");
delete("directFIRsymmetricEsqPW_test.diary.tmp");
diary directFIRsymmetricEsqPW_test.diary.tmp

for k=1:2
  if k==1
    % Low pass filter
    M=20;fap=0.1;fas=0.2;Wap=1;Was=10;
    f=[0 fap fas 0.5];
    waf=2*pi*f;
    Adf=[1 0 0];
    Waf=[Wap 0 Was];

    % Make a low pass filter
    h=remez(2*M,f*2,[1 1 0 0],[Wap Was]);

    % Desired magnitude response
    nplot=10^6;
    wa=(0:nplot)'*pi/nplot;
    nap=ceil(nplot*fap/0.5)+1;
    nas=floor(nplot*fas/0.5)+1;
    Ad=[ones(nap,1);zeros(nplot-nap+1,1)];
    Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(nplot-nas+2,1)]; 
  else
    % Band pass filter
    M=15;fapl=0.1;fapu=0.2;Wap=1;
    fasl=0.05;fasu=0.25;Wasl=20;Wasu=10;
    f=[0 fasl fapl fapu fasu 0.5];
    waf=2*pi*f;
    Adf=[0 0 1 0 0];
    Waf=[Wasl 0 Wap 0 Wasu];

    % Make a band pass filter
    h=remez(2*M,f*2,[0 0 1 1 0 0],[Wasl Wap Wasu],"bandpass");

    % Desired magnitude response
    nplot=10^6;
    wa=(0:nplot)'*pi/nplot;
    nasl=ceil(nplot*fasl/0.5)+1;
    napl=floor(nplot*fapl/0.5)+1;
    napu=ceil(nplot*fapu/0.5)+1;
    nasu=floor(nplot*fasu/0.5)+1;  
    Ad=[zeros(napl-1,1); ...
        ones(napu-napl+1,1); ...
        zeros(nplot-napu+1,1)];
    Wa=[Wasl*ones(nasl,1); ...
        zeros(napl-nasl-1,1); ...
        Wap*ones(napu-napl+1,1); ...
        zeros(nasu-napu-1,1); ...
        Wasu*ones(nplot-nasu+2,1)];
  endif

  % Calculate Esq
  hM=h(1:(M+1));
  [Esq,gradEsq,Q,q]=directFIRsymmetricEsqPW(hM,waf,Adf,Waf);

  % Check the squared-error response
  A=directFIRsymmetricA(wa,hM);
  H=freqz(h,1,wa);
  max_abs_err=max(abs(abs(A)-abs(H)));
  if  max_abs_err > 20*eps
    error("max(abs(abs(A)-abs(H)))(%g*eps) > 20*eps",max_abs_err/eps);
  endif
  AErr=Wa.*((A-Ad).^2);
  AErrSum=sum(diff(wa).*(AErr(1:(end-1))+AErr(2:end))/2)/pi;
  err_Esq=abs(AErrSum-Esq)/Esq;
  tol=10/nplot;
  if err_Esq > tol
    error("(abs(AErrSum(%17.11g)-Esq(%17.11g))/Esq)(=%17.11g)>tol(%g)", ...
          Esq,AErrSum,err_Esq,tol);
  endif

  % Check the gradients of the squared-error wrt h
  del=1e-6;
  delhM=zeros(size(hM));
  delhM(1)=del/2;
  diff_Esq=zeros(1,length(hM));
  for l=1:length(hM)
    EsqPdel2=directFIRsymmetricEsqPW(hM+delhM,waf,Adf,Waf);
    EsqMdel2=directFIRsymmetricEsqPW(hM-delhM,waf,Adf,Waf);
    delhM=circshift(delhM,1);
    diff_Esq(l)=(EsqPdel2-EsqMdel2)/del;
  endfor
  max_diff=max(abs(diff_Esq-gradEsq));
  if max_diff > del/5000
    error("max(abs(diff_Esq-gradEsq))(del/%g)>del/5000",max_diff);
  endif

endfor

% Done
diary off
movefile directFIRsymmetricEsqPW_test.diary.tmp ...
         directFIRsymmetricEsqPW_test.diary;
