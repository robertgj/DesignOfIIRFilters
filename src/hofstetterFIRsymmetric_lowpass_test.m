% hofstetterFIRsymmetric_lowpass_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("hofstetterFIRsymmetric_lowpass_test.diary");
unlink("hofstetterFIRsymmetric_lowpass_test.diary.tmp");
diary hofstetterFIRsymmetric_lowpass_test.diary.tmp

strf="hofstetterFIRsymmetric_lowpass_test";

%  
% Initialise
%
nplot=2000;
maxiter=100;
tol=1e-5;

%
% Filter design
%

% Specification: low pass filter order is 2*M
M=41;fap=0.1;deltap=1e-4;fas=0.2;deltas=1e-6;
%M=750;fap=0.125;deltap=1e-5;fas=0.135;deltas=1e-7;
strt=sprintf("Hofstetter lowpass FIR: M=%d,fap=%g,deltap=%g,fas=%g,deltas=%g",...
             M,fap,deltap,fas,deltas);

% Place 1+deltap at fap and -deltas at fas
f0=linspace(0,0.5,M+1);
nMp=ceil((M+1)*fap/0.5);
nMs=M-nMp-1;
a0p=fliplr(1+(((-1).^(0:nMp))*deltap));
a0s=(-((-1).^(0:nMs))*deltas);
a0=[a0p,a0s];

% Filter design
[hM,fiter,feasible]=hofstetterFIRsymmetric(f0,a0,nplot,maxiter,tol);
if feasible==false
  error("hM not feasible");
endif
wa=(0:nplot)'*pi/nplot;
A=directFIRsymmetricA(wa,hM);
plot(wa*0.5/pi,20*log10(abs(A)));

%
% Plot solution
%
wa=(0:(nplot-1))'*pi/nplot;
A=directFIRsymmetricA(wa,hM);
plot(wa*0.5/pi,20*log10(abs(A)))
axis([0 0.5 (20*log10(deltas)-10) 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
fap_actual=0.13;
fas_actual=0.13;
nap=ceil(nplot*fap_actual/0.5)+1;
nas=ceil(nplot*fas_actual/0.5)+1;
ax=plotyy(wa(1:nap)*0.5/pi,A(1:nap),wa(nas:end)*0.5/pi,A(nas:end));
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
fprintf(fid,"M=%d %% Filter order is 2*M+1 (M+1 extremal frequencies)\n",M);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"deltap=%d %% Amplitude pass band peak-to-peak ripple\n",deltap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"deltas=%d %% Amplitude stop band peak-to-peak ripple\n",deltas);
fclose(fid);

print_polynomial(hM,"hM");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"));

save hofstetterFIRsymmetric_lowpass_test.mat ...
     maxiter M nplot fap deltap fas deltas hM

%
% Done
%
diary off
movefile hofstetterFIRsymmetric_lowpass_test.diary.tmp ...
         hofstetterFIRsymmetric_lowpass_test.diary;
