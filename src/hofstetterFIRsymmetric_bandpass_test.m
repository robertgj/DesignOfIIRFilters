% hofstetterFIRsymmetric_bandpass_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("hofstetterFIRsymmetric_bandpass_test.diary");
unlink("hofstetterFIRsymmetric_bandpass_test.diary.tmp");
diary hofstetterFIRsymmetric_bandpass_test.diary.tmp

strf="hofstetterFIRsymmetric_bandpass_test";

%  
% Initialise
%
nplot=2000;
maxiter=100;
tol=1e-5;

%
% Filter design
%

% Specification: band pass filter order is 2*M
M=30;fasl=0.15;fapl=0.2;fapu=0.25;fasu=0.3;deltap=0.001;deltas=0.001;
strt=sprintf("Hofstetter bandpass FIR: \
fasl=%g,fapl=%g,fapu=%g,fasu=%g,deltap=%g,deltas=%g", ...
             fasl,fapl,fapu,fasu,deltap,deltas);

% Place 1+deltap at fapl,fapu and -deltas at fasl,fasu
sumfbands=fasl+(fapu-fapl)+(0.5-fasu);
nMp=ceil((M+1)*(fapu-fapl)/sumfbands);
if mod(nMp,2)==1
  nMp=nMp+1;
endif
f0p=linspace(fapl,fapu,nMp+1);
a0p=1+(((-1).^(0:nMp))*deltap);
nMsl=ceil((M+1)*fasl/sumfbands);
f0sl=linspace(0,fasl,nMsl);
a0sl=fliplr(((-1).^(1:nMsl))*deltas);
nMsu=M-nMp-nMsl;
f0su=linspace(fasu,0.5,nMsu);
a0su=((-1).^(1:nMsu))*deltas;
f0=[f0sl,f0p,f0su];
a0=[a0sl,a0p,a0su];

% Filter design
[hM,fext,fiter,feasible]=hofstetterFIRsymmetric(f0,a0,nplot,maxiter,tol);
if feasible==false
  error("hM not feasible");
endif
Aext=directFIRsymmetricA(2*pi*fext,hM);
print_polynomial(fext,"fext","%13.10f");
print_polynomial(Aext,"Aext","%13.10f");

%
% Plot solution
%
wa=(0:nplot)'*pi/nplot;
A=directFIRsymmetricA(wa,hM);
plot(wa*0.5/pi,20*log10(abs(A)));
axis([0 0.5 (20*log10(deltas)-10) 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
ax=plotyy(wa*0.5/pi,A,wa*0.5/pi,A);
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 1-(2*deltap) 1+(2*deltap)]);
axis(ax(2),[0 0.5 -2*deltas 2*deltas]);
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_dual"),"-dpdflatex");
close

% Plot zeros
zplane(roots([hM;flipud(hM(1:(end-1)))]));
title(strt);
grid("on");
print(strcat(strf,"_zeros"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"M=%d %% Filter order is 2*M (M+1 distinct coefficients)\n",M);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"deltap=%d %% Amplitude pass band peak-to-peak ripple\n",deltap);
fprintf(fid,"deltas=%d %% Amplitude stop band peak-to-peak ripple\n",deltas);
fprintf(fid,"nplot=%d %% Number of frequencies\n",nplot);
fprintf(fid,"tol=%g %% Tolerance on convergence\n",tol);
fclose(fid);

print_polynomial(hM,"hM");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"));

save hofstetterFIRsymmetric_bandpass_test.mat ...
     maxiter M nplot maxiter tol fasl fapl fapu fasu deltap deltas hM fext Aext

%
% Done
%
diary off
movefile hofstetterFIRsymmetric_bandpass_test.diary.tmp ...
         hofstetterFIRsymmetric_bandpass_test.diary;

