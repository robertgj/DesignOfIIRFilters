% selesnickFIRsymmetric_lowpass_test.m
% Copyright (C) 2019,2020 Robert G. Jenssen

test_common;

unlink("selesnickFIRsymmetric_lowpass_test.diary");
unlink("selesnickFIRsymmetric_lowpass_test.diary.tmp");
diary selesnickFIRsymmetric_lowpass_test.diary.tmp

strf="selesnickFIRsymmetric_lowpass_test";

%  
% Initialise
%
nplot=4000;
maxiter=100;
tol=1e-5;

%
% Filter design
%

% Failing specification: M=11 is successful
M=10;deltap=1e-3;deltas=1e-4;ft=0.15;at=deltas;
strt=sprintf("Failing Selesnick-Burrus Hofstetter lowpass FIR: \
M=%d,deltap=%g,deltas=%g,ft=%g,at=%g",M,deltap,deltas,ft,at);

% Failing filter design
[hM,fiter,feasible]=selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,at, ...
                                                  nplot,maxiter,tol);
if feasible==false
  warning("hM not feasible");
endif

% Successful specification: low pass filter order is 2*M
M=85;deltap=1e-6;deltas=1e-8;ft=0.15;at=1-deltap;
strt=sprintf("Selesnick-Burrus Hofstetter lowpass FIR: \
M=%d,deltap=%g,deltas=%g,ft=%g,at=%g",M,deltap,deltas,ft,at);

% Filter design
[hM,fiter,feasible]=selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,at, ...
                                                  nplot,maxiter,tol);
if feasible==false
  error("hM not feasible");
endif

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
nap=ceil(nplot*ft/0.5)+1;
nas=ceil(nplot*ft/0.5)+1;
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
fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
fprintf(fid,"deltap=%d %% Amplitude pass band peak-to-peak ripple\n",deltap);
fprintf(fid,"deltas=%d %% Amplitude stop band peak-to-peak ripple\n",deltas);
fprintf(fid,"ft=%g %% Amplitude transition band frequency\n",ft);
fprintf(fid,"at=%d %% Amplitude at transition band frequency\n",at);
fclose(fid);

print_polynomial(hM,"hM","%15.12f");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"),"%15.12f");

save selesnickFIRsymmetric_lowpass_test.mat  ...
     M deltap deltas ft at nplot maxiter tol hM

%
% Done
%
diary off
movefile selesnickFIRsymmetric_lowpass_test.diary.tmp ...
         selesnickFIRsymmetric_lowpass_test.diary;

