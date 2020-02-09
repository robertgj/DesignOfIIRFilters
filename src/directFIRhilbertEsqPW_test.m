% directFIRhilbertEsqPW_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

unlink("directFIRhilbertEsqPW_test.diary");
unlink("directFIRhilbertEsqPW_test.diary.tmp");
diary directFIRhilbertEsqPW_test.diary.tmp

% Hilbert filter frequency specification
M=8;fapl=0.05;fapu=0.45;Wap=2;Wasl=0.1;Wasu=0.2;
nplot=1e4;
wa=(0:(nplot-1))'*pi/nplot;
napl=ceil(nplot*fapl/0.5)+1;
napu=floor(nplot*fapu/0.5)+1;
Ad=-[zeros(napl-1,1);ones(napu-napl+1,1);zeros(nplot-napu,1)];
Wa=[Wasl*ones(napl-1,1);Wap*ones(napu-napl+1,1);Wasu*ones(nplot-napu,1)];
waf=2*pi*[0 fapl fapu 0.5];
Adf=[0 -1 0];
Waf=[Wasl Wap Wasu];

% Make a Hilbert filter
n4M1=((-2*M)+1):2:((2*M)-1)';
h0=zeros((4*M)-1,1);
h0(n4M1+(2*M))=2*(sin(pi*n4M1/2).^2)./(pi*n4M1);
h0=h0.*hamming((4*M)-1);
hM0=h0(1:2:((2*M)-1));

% Calculate A
A0=directFIRhilbertA(wa,hM0);
% Check the amplitude response
H0=freqz(h0,1,wa);
max_abs_err=max(abs(A0+abs(H0)));
if  max_abs_err > 20*eps
  error("max(abs(A0+abs(H0)))(%g*eps) > 20*eps",max_abs_err/eps);
endif
max_phase_err= ...
  max(mod((unwrap(arg(H0(napl:napu)))+(wa(napl:napu)*((2*M)-1)))/pi,2)-1.5);
if  max_phase_err > 10*eps
  error("max_phase_err(%g*eps) > 10*eps",max_phase_err/eps);
endif

% Calculate Esq with waf
[Esq,gradEsq,Q,q]=directFIRhilbertEsqPW(hM0,waf(2:3));
% Check the squared-error response
AsqErr=(A0-Ad).^2;
AsqErrSum=sum(diff(wa(napl:napu)).* ...
              (AsqErr(napl:(napu-1))+AsqErr((napl+1):napu))/2)/pi;
err_Esq=abs(AsqErrSum-Esq)/Esq;
tol=2e-5;
if err_Esq > tol
  error("abs((AsqErrSum(%g)-Esq(%g))/Esq)(=%g)>tol(%g)", ...
        AsqErrSum,Esq,err_Esq,tol);
endif

% Calculate Esq with waf and Adf
[Esq,gradEsq,Q,q]=directFIRhilbertEsqPW(hM0,waf,Adf);
% Check the squared-error response
AsqErrSum=sum(diff(wa).*(AsqErr(1:(end-1))+AsqErr(2:end))/2)/pi;
err_Esq=abs(AsqErrSum-Esq)/Esq;
tol=1e-3;
if err_Esq > tol
  error("abs((AsqErrSum(%g)-Esq(%g))/Esq)(=%g)>tol(%g)", ...
        AsqErrSum,Esq,err_Esq,tol);
endif

% Calculate Esq with waf and Adf and Waf
[Esq,gradEsq,Q,q]=directFIRhilbertEsqPW(hM0,waf,Adf,Waf);
% Check the squared-error response
AsqErr=Wa.*((A0-Ad).^2);
AsqErrSum=sum(diff(wa).*(AsqErr(1:(end-1))+AsqErr(2:end))/2)/pi;
err_Esq=abs(AsqErrSum-Esq)/Esq;
tol=1e-3;
if err_Esq > tol
  error("abs((AsqErrSum(%g)-Esq(%g))/Esq)(=%g)>tol(%g)", ...
        AsqErrSum,Esq,err_Esq,tol);
endif

% Check the gradients of the squared-error wrt h
[~,gradEsq]=directFIRhilbertEsqPW(hM0,waf,Adf,Waf);
del=1e-6;
delhM0=zeros(size(hM0));
delhM0(1)=del/2;
diff_Esq=zeros(1,length(hM0));
for l=1:length(hM0)
  EsqPdel2=directFIRhilbertEsqPW(hM0+delhM0,waf,Adf,Waf);
  EsqMdel2=directFIRhilbertEsqPW(hM0-delhM0,waf,Adf,Waf);
  delhM0=shift(delhM0,1);
  diff_Esq(l)=(EsqPdel2-EsqMdel2)/del;
endfor
max_diff=max(abs(diff_Esq-gradEsq));
if max_diff > del/1000
  error("max(abs(diff_Esq-gradEsq))(%g)>del/1000",max_diff);
endif

% Alternate test
% Hilbert band-pass filter from directFIRhilbert_bandpass_slb_test.m
hM1 = [   0.0057429552,   0.0446936351,  -0.0153998324,  -0.0693183665, ... 
         -0.0045099006,   0.1230534484,   0.0942725241,  -0.4963204752 ]';

% Hilbert filter frequency specification
fapl=0.15;fapu=0.5-fapl;
fasl=0.1;fasu=0.5-fasl;
Wap=20;Wat=0;Was=1;
waf=2*pi*[0 fasl fapl fapu fasu 0.5];
Adf=[0 0 -1 0 0];
Waf=[Was Wat Wap Wat Was];
Esq=directFIRhilbertEsqPW(hM1,waf,Adf,Waf);
wa=(0:((nplot)-1))'*pi/(nplot);
nasl=ceil(nplot*fasl/0.5)+1;
napl=floor(nplot*fapl/0.5)+1;
napu=ceil(nplot*fapu/0.5)+1;
nasu=floor(nplot*fasu/0.5)+1;
Ad=-[zeros(napl-1,1);ones(napu-napl+1,1);zeros(nplot-napu,1)];
Wa=[Was*ones(nasl,1); ...
    Wat*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Wat*ones(nasu-napu-1,1); ...
    Was*ones(nplot-nasu+1,1)];
A1=directFIRhilbertA(wa,hM1);
AsqErr=Wa.*((A1-Ad).^2);
AsqErrSum=sum(diff(wa).*(AsqErr(1:(end-1))+AsqErr(2:end))/2)/pi;
err_Esq=abs(AsqErrSum-Esq)/Esq;
tol=1e-2;
if err_Esq > tol
  error("abs((AsqErrSum(%g)-Esq(%g))/Esq)(=%g)>tol(%g)", ...
        AsqErrSum,Esq,err_Esq,tol);
endif
H1=freqz(kron([hM1(:);-flipud(hM1(:))],[1;0])(1:(end-1)),1,wa);
max_phase_err= ...
  max(mod((unwrap(angle(H1(napl:napu)))+(wa(napl:napu)*((2*M)-1)))/pi,2)-1.5);
if  max_phase_err > 10*eps
  error("max_phase_err(%g*eps) > 10*eps",max_phase_err/eps);
endif

% Done
diary off
movefile directFIRhilbertEsqPW_test.diary.tmp directFIRhilbertEsqPW_test.diary;
