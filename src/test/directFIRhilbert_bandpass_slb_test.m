% directFIRhilbert_bandpass_slb_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

pkg load optim;

delete("directFIRhilbert_bandpass_slb_test.diary");
delete("directFIRhilbert_bandpass_slb_test.diary.tmp");
diary directFIRhilbert_bandpass_slb_test.diary.tmp

%
% Initialise
%
maxiter=500;
verbose=true;
tol=1e-4;
ctol=tol;

% Hilbert filter frequency specification
npoints=1000;
M=8;
fasl=0.1;fapl=0.16325;fapu=0.5-fapl;fasu=0.5-fasl;
dBap=0.31375;Wap=1;Wat=0.001;dBas=35;Was=10;

wa=(0:((npoints)-1))'*pi/(npoints);
nasl=ceil(npoints*fasl/0.5)+1;
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
nasu=floor(npoints*fasu/0.5)+1;
Ad=-[zeros(napl-1,1);ones(napu-napl+1,1);zeros(npoints-napu,1)];
Adl=-[(10^(-dBas/20))*ones(nasl,1); ...
      ones(nasu-nasl-1,1); ...
      (10^(-dBas/20))*ones(npoints-nasu+1,1)];
Adu=-[zeros(napl-1,1); ...
      (10^(-dBap/20))*ones(napu-napl+1,1); ...
      zeros(npoints-napu,1)];
Wa=[Was*ones(nasl,1); ...
    Wat*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Wat*ones(nasu-napu-1,1); ...
    Was*ones(npoints-nasu+1,1)];

% Sanity check
nch=[1, nasl-1, nasl, nasl+1, napl-1, napl, napl+1, ...
        napu-1, napu, napu+1, nasu-1, nasu, nasu+1, npoints];
printf("fa=[ ");printf("%d ",wa(nch)*0.5/pi);printf("]\n");
printf("Ad=[ ");printf("%d ",Ad(nch));printf("]\n");
printf("Adu=[ ");printf("%d ",Adu(nch));printf("]\n");
printf("Adl=[ ");printf("%d ",Adl(nch));printf("]\n");
printf("Wa=[ ");printf("%d ",Wa(nch));printf("]\n");

%
% Make an initial Hilbert filter
%
n4M1=((-2*M)+1):2:((2*M)-1)';
h0=zeros((4*M)-1,1);
h0(n4M1+(2*M))=2*(sin(pi*n4M1/2).^2)./(pi*n4M1);
h0=h0.*hamming((4*M)-1);
hM0=h0(1:2:((2*M)-1));
hM_active=1:length(hM0);

%
% fminunc solution
%
waf=2*pi*[0 fasl fasu 0.5];
Adf=[0 -1 0];
Waf=[Was Wap Was];
function Esq=directFIRhilbert_bandpassEsq(hM,_waf,_Adf,_Waf)
  persistent waf Adf Waf
  persistent init_done=false
  if nargin==4
    waf=_waf;Adf=_Adf;Waf=_Waf;
    init_done=true;
  elseif nargin~=1
    print_usage(["directFIRhilbert_bandpassEsq(hM)\n", ...
 "directFIRhilbert_bandpassEsq(hM,_waf,_Adf,_Waf)"]);
  endif
  if init_done==false
    error("init_done==false");
  endif
  Esq=directFIRhilbertEsqPW(hM,waf,Adf,Waf);
endfunction
directFIRhilbert_bandpassEsq(hM0,waf,Adf,Waf);
opt=optimset("TolFun",tol,"TolX",tol,"MaxIter",maxiter,"MaxFunEvals",maxiter);
[hM1,Esq1,INFO,OUTPUT]=fminunc(@directFIRhilbert_bandpassEsq,hM0,opt);
if (INFO == 1)
  printf("Converged to a solution point.\n");
elseif (INFO == 2)
  printf("Last relative step size was less that TolX.\n");
elseif (INFO == 3)
  printf("Last relative decrease in function value was less than TolF.\n");
elseif (INFO == 0)
  error("Iteration limit exceeded.\n");
elseif (INFO == -3)
  error("The trust region radius became excessively small.\n");
else
  error("Unknown INFO value.\n");
endif
printf("Esq=%f\n", Esq1);
printf("fminunc iterations=%d\n", OUTPUT.iterations);
printf("fminunc successful=%d??\n", OUTPUT.successful);
printf("fminunc funcCount=%d\n", OUTPUT.funcCount);

%
% SLB solution
%
war=1:(npoints/2);
[hM2,slb_iter,socp_iter,func_iter,feasible]=directFIRhilbert_slb ...
  (@directFIRhilbert_mmsePW,hM1,hM_active,[napl,(npoints/2)], ...
   wa(war),Ad(war),Adu(war),Adl(war),Wa(war),maxiter,tol,ctol,verbose);
if feasible==false
  error("directFIRhilbert_bandpass_slb failed!");
endif

%
% Plot solutions
%
nplot=1000;
wplot=(0:(nplot-1))'*pi/nplot;
A1p=directFIRhilbertA(wplot,hM1);
A2p=directFIRhilbertA(wplot,hM2);
% Response
plot(wplot*0.5/pi,20*log10(abs(A1p)),"--", ...
     wplot*0.5/pi,20*log10(abs(A2p)),"-");
axis([0 0.25 -40 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("Initial","PCLS","location","southeast");
legend("boxoff");
legend("left");
grid("on");
strM=sprintf ...
  ("FIR Hilbert : fasl=%g,fapl=%g,fapu=%g,fasu=%g,dBap=%g,dBas=%g", ...
   fasl,fapl,fapu,fasu,dBap,dBas);
title(strM);
zticks([]);
print("directFIRhilbert_bandpass_slb_test_response","-dpdflatex");
close
% Passband response
plot(wplot*0.5/pi,20*log10(abs(A1p)),"--", ...
     wplot*0.5/pi,20*log10(abs(A2p)),"-");
axis([0.15 0.25 -1 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("Initial","PCLS","location","southeast");
legend("boxoff");
legend("left");
grid("on");
strM=sprintf ...
  ("FIR Hilbert : fasl=%g,fapl=%g,fapu=%g,fasu=%g,dBap=%g,dBas=%g", ...
   fasl,fapl,fapu,fasu,dBap,dBas);
title(strM);
zticks([]);
print("directFIRhilbert_bandpass_slb_test_passband_response","-dpdflatex");
close

%
% Save the results
%
fid=fopen("directFIRhilbert_bandpass_slb_test_spec.m","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"npoints=%d %% Frequency points across the band\n",npoints);
fprintf(fid,"M=%d %% M distinct coefficients\n",M);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wat=%d %% Amplitude transition band weight\n",Wat);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fprintf(fid,"dBas=%g %% Amplitude stop band peak ripple\n",dBas);
fclose(fid);

print_polynomial(hM1,"hM1");
print_polynomial(hM1,"hM1","directFIRhilbert_bandpass_slb_test_hM1_coef.m");
print_polynomial(hM2,"hM2");
print_polynomial(hM2,"hM2","directFIRhilbert_bandpass_slb_test_hM2_coef.m");

save directFIRhilbert_bandpass_slb_test.mat tol ctol maxiter M npoints ...
     fasl fapl fapu fasu Wap dBap Wat Was dBas wa Ad Adu Adl Wa hM0 hM1 hM2

% Done
diary off
movefile directFIRhilbert_bandpass_slb_test.diary.tmp ...
         directFIRhilbert_bandpass_slb_test.diary;

