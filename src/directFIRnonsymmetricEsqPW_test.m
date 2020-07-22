% directFIRnonsymmetricEsqPW_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

delete("directFIRnonsymmetricEsqPW_test.diary");
delete("directFIRnonsymmetricEsqPW_test.diary.tmp");
diary directFIRnonsymmetricEsqPW_test.diary.tmp

% Filter specification
M=4;fap=0.1;td=M;Wap=1;fas=0.25;Was=10;
f=[0 fap fas 0.5];
h=remez(2*M,f*2,[1 1 0 0],[Wap Was]);
waf=2*pi*f;
Adf=[1 0 0];
Tdf=[td 0 0];
Waf=[Wap 0 Was];

% Desired frequency response
nplot=10^4;
wa=(0:nplot)'*pi/nplot;
nap=ceil(nplot*fap/0.5)+1;
nas=floor(nplot*fas/0.5)+1;
Hd=[exp(-j*wa(1:nap)*td);zeros(nplot-nap+1,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(nplot-nas+2,1)]; 

% Call directFIRnonsymmetricEsqPW
[Esq_p,gradEsq_p,Q_p,q_p]=...
  directFIRnonsymmetricEsqPW(h,waf(1:2),Adf(1),Tdf(1),Waf(1));
[Esq_s,gradEsq_s,Q_s,q_s]= ...
  directFIRnonsymmetricEsqPW(h,waf((end-1):end),Adf(end),Tdf(end),Waf(end));
[Esq,gradEsq,Q,q]= ...
  directFIRnonsymmetricEsqPW(h,waf,Adf,Tdf,Waf);

% Calculate with freqz
H=freqz(h,1,wa);
AErr=Wa.*abs(H-Hd).^2;
AErrSum_p=sum(diff(wa(1:nap)).*(AErr(1:(nap-1))+AErr(2:nap))/2)/pi;
AErrSum_s=sum(diff(wa(nas:end)).*(AErr(nas:(end-1))+AErr((nas+1):end))/2)/pi;
AErrSum=AErrSum_p+AErrSum_s;

% Compare freqz and directFIRnonsymmetricEsqPW
tol=1/(100*nplot);
err_Esq_p=abs(AErrSum_p-Esq_p)/Esq_p;
if err_Esq_p>tol
  error("err_Esq_p(%g)>tol(%g)",err_Esq_p,tol);
endif
err_Esq_s=abs(AErrSum_s-Esq_s)/Esq_s;
if err_Esq_s>tol
  error("err_Esq_s(%g)>tol(%g)",err_Esq_s,tol);
endif
err_Esq=abs(AErrSum-Esq)/Esq;
if err_Esq>tol
  error("err_Esq(%g)>tol(%g)",err_Esq,tol);
endif

% Check the gradients of the squared-error wrt h
del=1e-6;
delh=zeros(size(h));
delh(1)=del/2;
diff_Esq=zeros(1,length(h));
for l=1:length(h)
  EsqPdel2=directFIRnonsymmetricEsqPW(h+delh,waf,Adf,Tdf,Waf);
  EsqMdel2=directFIRnonsymmetricEsqPW(h-delh,waf,Adf,Tdf,Waf);
  delh=shift(delh,1);
  diff_Esq(l)=(EsqPdel2-EsqMdel2)/del;
endfor
max_diff=max(abs(diff_Esq-gradEsq));
if max_diff > del/19000
  error("max(abs(diff_Esq-gradEsq))(del/%g)>del/19000",max_diff);
endif

% Other filters
for k=1:2
  if k==1
    % Low pass filter from iir_sqp_slb_fir_lowpass_test.m
    h  = [   0.0001397686,   0.0018658735,   0.0051260808,   0.0041579421, ... 
            -0.0039031718,  -0.0114237246,  -0.0072809679,   0.0102112971, ... 
             0.0239066656,   0.0108229178,  -0.0285163070,  -0.0549870500, ... 
            -0.0142853783,   0.1100733405,   0.2639162590,   0.3492818878, ... 
             0.3001271185,   0.1420518109,  -0.0220093046,  -0.0932378973, ... 
            -0.0546282780,   0.0251804864,   0.0615593174,   0.0292331418, ... 
            -0.0266997031,  -0.0462306311,  -0.0155364902,   0.0265253122, ... 
             0.0353818907,   0.0068898711,  -0.0240525807,  -0.0249721580, ... 
             0.0008804912,   0.0226722060,   0.0180101062,  -0.0048048071, ... 
            -0.0195459129,  -0.0120254837,   0.0067818273,   0.0157854494, ... 
             0.0072332771,  -0.0072790378,  -0.0119339667,  -0.0037095969, ... 
             0.0066828195,   0.0083247830,   0.0012818364,  -0.0055597966, ... 
            -0.0054049532,   0.0000345881,   0.0041202821,   0.0031653928, ... 
            -0.0005762191,  -0.0027165804,  -0.0016173294,   0.0006302244, ... 
             0.0015490375,   0.0006773666,  -0.0005225084,  -0.0006389092, ... 
            -0.0001819264 ]';
    N=length(h)-1;
    fap=0.15;td=15;Wap=1;fas=0.2;Was=10;
    f=[0 fap fas 0.5];
    % Arguments to directFIRnonsymmetricEsqPW.m
    waf=2*pi*f;
    Adf=[1 0 0];
    Tdf=[td 0 0];
    Waf=[Wap 0 Was];
    % Desired frequency response
    nplot=10^4;
    wa=(0:nplot)'*pi/nplot;
    nap=ceil(nplot*fap/0.5)+1;
    nas=floor(nplot*fas/0.5)+1;
    Hd=[exp(-j*wa(1:nap)*td);zeros(nplot-nap+1,1)];
    Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(nplot-nas+2,1)]; 
  else
    % Band pass filter from iir_sqp_slb_fir_bandpass_test.m
    h  = [   0.0001397686,   0.0018658735,   0.0051260808,   0.0041579421, ... 
            -0.0039031718,  -0.0114237246,  -0.0072809679,   0.0102112971, ... 
             0.0239066656,   0.0108229178,  -0.0285163070,  -0.0549870500, ... 
            -0.0142853783,   0.1100733405,   0.2639162590,   0.3492818878, ... 
             0.3001271185,   0.1420518109,  -0.0220093046,  -0.0932378973, ... 
            -0.0546282780,   0.0251804864,   0.0615593174,   0.0292331418, ... 
            -0.0266997031,  -0.0462306311,  -0.0155364902,   0.0265253122, ... 
             0.0353818907,   0.0068898711,  -0.0240525807,  -0.0249721580, ... 
             0.0008804912,   0.0226722060,   0.0180101062,  -0.0048048071, ... 
            -0.0195459129,  -0.0120254837,   0.0067818273,   0.0157854494, ... 
             0.0072332771,  -0.0072790378,  -0.0119339667,  -0.0037095969, ... 
             0.0066828195,   0.0083247830,   0.0012818364,  -0.0055597966, ... 
            -0.0054049532,   0.0000345881,   0.0041202821,   0.0031653928, ... 
            -0.0005762191,  -0.0027165804,  -0.0016173294,   0.0006302244, ... 
             0.0015490375,   0.0006773666,  -0.0005225084,  -0.0006389092, ... 
            -0.0001819264 ]';
    N=length(h)-1;
    fasl=0.05;Wasl=8;
    fapl=0.1;fapu=0.2;td=8;Wap=1;
    fasu=0.25;Wasu=2;
    f=[0 fasl fapl fapu fasu 0.5];
    waf=2*pi*f;
    Adf=[0 0 1 0 0];
    Tdf=[0 0 td 0 0];
    Waf=[Wasl 0 Wap 0 Wasu];
    % Desired magnitude response
    nplot=10^6;
    wa=(0:nplot)'*pi/nplot;
    nasl=ceil(nplot*fasl/0.5)+1;
    napl=floor(nplot*fapl/0.5)+1;
    napu=ceil(nplot*fapu/0.5)+1;
    nasu=floor(nplot*fasu/0.5)+1;  
    Hd=[zeros(napl-1,1); ...
        exp(-j*wa(napl:napu)*td); ...
        zeros(nplot-napu+1,1)];
    Wa=[Wasl*ones(nasl,1); ...
        zeros(napl-nasl-1,1); ...
        Wap*ones(napu-napl+1,1); ...
        zeros(nasu-napu-1,1); ...
        Wasu*ones(nplot-nasu+2,1)];
  endif

  % Calculate Esq
  [Esq,gradEsq,Q,q]=directFIRnonsymmetricEsqPW(h,waf,Adf,Tdf,Waf);

  % Check the frequency response
  H=freqz(h,1,wa);
  AErr=Wa.*(abs(H-Hd).^2);
  AErrSum=sum(diff(wa).*(AErr(1:(end-1))+AErr(2:end))/2)/pi;
  err_Esq=abs(AErrSum-Esq)/Esq;
  tol=200/nplot;
  if err_Esq > tol
    error("(abs(AErrSum(%17.11g)-Esq(%17.11g))/Esq)(=%17.11g)>tol(%g)", ...
          Esq,AErrSum,err_Esq,tol);
  endif

  % Check the gradients of the squared-error wrt h
  del=1e-6;
  delh=zeros(size(h));
  delh(1)=del/2;
  diff_Esq=zeros(1,length(h));
  for l=1:length(h)
    EsqPdel2=directFIRnonsymmetricEsqPW(h+delh,waf,Adf,Tdf,Waf);
    EsqMdel2=directFIRnonsymmetricEsqPW(h-delh,waf,Adf,Tdf,Waf);
    delh=shift(delh,1);
    diff_Esq(l)=(EsqPdel2-EsqMdel2)/del;
  endfor
  max_diff=max(abs(diff_Esq-gradEsq));
  if max_diff > del/1500
    error("max(abs(diff_Esq-gradEsq))(del/%g)>del/1500",max_diff);
  endif

endfor

% Done
diary off
movefile directFIRnonsymmetricEsqPW_test.diary.tmp ...
         directFIRnonsymmetricEsqPW_test.diary;
