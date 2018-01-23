% directFIRhilbertEsqPW_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("directFIRhilbertEsqPW_test.diary");
unlink("directFIRhilbertEsqPW_test.diary.tmp");
diary directFIRhilbertEsqPW_test.diary.tmp

% Hilbert filter frequency specification
M=8;fapl=0.05;fapu=0.45;Wap=2;Wasl=0.1;Wasu=0.1;
nplot=1e3;
wa=(0:(nplot-1))'*pi/nplot;
napl=ceil(nplot*fapl/0.5)+1;
napu=floor(nplot*fapu/0.5)+1;
Ad=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(nplot-napu,1)];
Wa=[Wasl*ones(napl-1,1);Wap*ones(napu-napl+1,1);Wasu*ones(nplot-napu,1)];
waf=2*pi*[0 fapl fapu 0.5];
Adf=[0 1 0];
Waf=[Wasl Wap Wasu];

% Make a Hilbert filter
n4M1=((-2*M)+1):2:((2*M)-1)';
h0=zeros((4*M)+1,1);
h0(n4M1+(2*M)+1)=2*(sin(pi*n4M1/2).^2)./(pi*n4M1);
h0=h0.*hamming((4*M)+1);
hM0=h0(((2*M)+2):2:(end-1));

% Calculate A
A0=directFIRhilbertA(wa,hM0);
% Check the amplitude response
H0=freqz(h0,1,wa);
max_abs_err=max(abs(abs(A0)-abs(H0)));
if  max_abs_err > 20*eps
  error("max(abs(abs(A0)-abs(H0)))(%g*eps) > 20*eps",max_abs_err/eps);
endif
max_phase_err=max(abs((((unwrap(arg(H0(2:end)))+(wa(2:end)*M*2))/pi)+0.5)));
if  max_phase_err > 200*eps
  error("max_phase_err(%g*eps) > 200*eps",max_phase_err/eps);
endif

% Calculate Esq
[Esq,gradEsq,Q,q]=directFIRhilbertEsqPW(hM0,waf);
% Check the squared-error response
nplot=1e6;
wa=(0:(nplot-1))'*pi/nplot;
napl=ceil(nplot*fapl/0.5)+1;
napu=floor(nplot*fapu/0.5)+1;
A0=directFIRhilbertA(wa,hM0);
AsqErr=(A0-1).^2;
AsqErrSum=sum(diff(wa).*(AsqErr(1:(end-1))+AsqErr(2:end))/2)/pi;
err_Esq=abs(AsqErrSum-Esq)/Esq;
tol=25/nplot;
if err_Esq > tol
  warning("(abs(AsqErrSum(%17.11g)-Esq(%17.11g))/Esq)(=%17.11g)>tol(%g)", ...
        AsqErrSum,Esq,err_Esq,tol);
endif
% Calculate Esq for Adf
[Esq,gradEsq,Q,q]=directFIRhilbertEsqPW(hM0,waf,Adf);
% Check the squared-error response
nplot=1e6;
wa=(0:(nplot-1))'*pi/nplot;
napl=ceil(nplot*fapl/0.5)+1;
napu=floor(nplot*fapu/0.5)+1;
Ad=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(nplot-napu,1)];
A0=directFIRhilbertA(wa,hM0);
AsqErr=(A0-Ad).^2;
AsqErrSum=sum(diff(wa).*(AsqErr(1:(end-1))+AsqErr(2:end))/2)/pi;
err_Esq=abs(AsqErrSum-Esq)/Esq;
tol=10/nplot;
if err_Esq > tol
  warning("(abs(AsqErrSum(%17.11g)-Esq(%17.11g))/Esq)(=%17.11g)>tol(%g)", ...
        AsqErrSum,Esq,err_Esq,tol);
endif
% Calculate Esq for Adf, Waf
Adf=[0 2 0];
Esq=directFIRhilbertEsqPW(hM0*2,waf,Adf,Waf);
% Check the squared-error response
Ad=[zeros(napl-1,1);2*ones(napu-napl+1,1);zeros(nplot-napu,1)];
Wa=[Wasl*ones(napl-1,1);Wap*ones(napu-napl+1,1);Wasu*ones(nplot-napu,1)];
A0=directFIRhilbertA(wa,hM0*2);
AsqErr=Wa.*((A0-Ad).^2);
AsqErrSum=sum(diff(wa).*(AsqErr(1:(end-1))+AsqErr(2:end))/2)/pi;
err_Esq=abs(AsqErrSum-Esq)/Esq;
tol=10/nplot;
if err_Esq > tol
  warning("(abs(AsqErrSum(%17.11g)-Esq(%17.11g))/Esq)(=%17.11g)>tol(%g)", ...
        AsqErrSum,Esq,err_Esq,tol);
endif

% Check the gradients of the squared-error wrt h
Adf=ones(size(Waf));
[Esq,gradEsq]=directFIRhilbertEsqPW(hM0,waf,Adf,Waf);
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

% Done
diary off
movefile directFIRhilbertEsqPW_test.diary.tmp directFIRhilbertEsqPW_test.diary;
