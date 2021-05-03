% selesnickFIRsymmetric_lowpass_alternate_test.m
% Copyright (C) 2021 Robert G. Jenssen
% Use the Selesnick-Burrus modification to Hofsteter's algorithm to design
% a linear-phase FIR filter with the stop band specifications of Tuan et al.
% Figure 4 in "Efficient Large-Scale Filter/Filterbank Design via LMI
% Characterization of Trigonometric Curves", H. D. Tuan, T. T. Son,
% B. Vo and T. Q. Nguyen, IEEE Transactions on Signal Processing,
% Vol. 55, No. 9, September 2007, pp. 4393--4404
%
% Compare with: b=remez(2*M,[0 fap fas 0.5]*2,[1 1 0 0],[deltap/deltas,1])

test_common;

delete("selesnickFIRsymmetric_lowpass_alternate_test.diary");
delete("selesnickFIRsymmetric_lowpass_alternate_test.diary.tmp");
diary selesnickFIRsymmetric_lowpass_alternate_test.diary.tmp

strf="selesnickFIRsymmetric_lowpass_alternate_test";

% Specification: low passfilter order is 2*M, length is 2*M+1
if 0
  % Filter design from [1,Figure 3]
  M=200;fap=0.03;fas=0.0358;deltap=2.6725e-2;deltas=1e-3;ft=fas;At=deltas;
elseif 1
  % Filter design from [1,Figure 4]
  M=600;fap=0.1;fas=0.105;deltap=4e-4;deltas=2e-7;ft=fas;At=deltas;
elseif 0
  % Filter design from [1,Figure 4] with M=750
  M=750;fap=0.1;fas=0.105;deltap=2e-4;deltas=2e-7;ft=fas;At=deltas;
endif

% Filter design
ngrid=7250;maxiter=200;tol=1e-12;
[hM,fext,fiter,feasible]= ...
  selesnickFIRsymmetric_lowpass(M,deltap,deltas,ft,At,ngrid,maxiter,tol);
if feasible==false
  error("hM not feasible");
endif
Aext=directFIRsymmetricA(2*pi*fext,hM);
print_polynomial(fext,"fext","%13.10f");
print_polynomial(Aext,"Aext","%13.10f");

% Check response at band edges
Ap=directFIRsymmetricA(2*pi*fap,hM)
As=directFIRsymmetricA(2*pi*fas,hM)

%
% Plot response
%
strt=sprintf("Selesnick-Burrus lowpass FIR : \
M=%d,fap=%g,deltap=%g,fas=%g,deltas=%g,ngrid=%d", M,fap,deltap,fas,deltas,ngrid);
nplot=10000;
fa=(0:nplot)'*0.5/nplot;
wa=2*pi*fa;
A=directFIRsymmetricA(wa,hM);
plot(fa,20*log10(abs(A)))
axis([0 0.5 round(20*log10(deltas))-10 10]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
pnap=ceil(nplot*fap/0.5)+1;
pnas=floor(nplot*fas/0.5)+1;
ax=plotyy(fa(1:pnap),A(1:pnap),fa(pnas:end),A(pnas:end));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
%axis(ax(1),[0 0.5 1-2*deltap 1+2*deltap]);
axis(ax(1),[0 0.5 1+0.001*[-1,1]]);
axis(ax(2),[0 0.5 -2*deltas 2*deltas]);
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_dual"),"-dpdflatex");
close

% Find pass band edge frequency by linear interpolation
k=min(find(A<(1-deltap)));
fapx=(((1-deltap)-A(k-1))*(fa(k)-fa(k-1))/(A(k)-A(k-1)))+fa(k-1);
fid=fopen(strcat(strf,"_fapx.tab"),"wt");
fprintf(fid,"%8.6f",fapx);
fclose(fid);

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"deltap=%g %% Amplitude pass band ripple\n",deltap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"deltas=%g %% Amplitude stop band ripple\n",deltas);
fprintf(fid,"ngrid=%d %% Number of frequency grid points in [0,0.5]\n",ngrid);
fprintf(fid,"maxiter=%g %% Maximum number of iterations\n",maxiter);
fprintf(fid,"tol=%g %% Tolerance on convergence\n",tol);
fclose(fid);

print_polynomial(hM,"hM");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"));

save selesnickFIRsymmetric_lowpass_alternate_test.mat ...
     M fap fas deltap deltas ngrid tol maxiter hM fext Aext

%
% Done
%
diary off
movefile selesnickFIRsymmetric_lowpass_alternate_test.diary.tmp ...
         selesnickFIRsymmetric_lowpass_alternate_test.diary;

