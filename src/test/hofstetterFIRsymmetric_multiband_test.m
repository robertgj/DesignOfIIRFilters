% hofstetterFIRsymmetric_multiband_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

delete("hofstetterFIRsymmetric_multiband_test.diary");
delete("hofstetterFIRsymmetric_multiband_test.diary.tmp");
diary hofstetterFIRsymmetric_multiband_test.diary.tmp

strf="hofstetterFIRsymmetric_multiband_test";

%  
% Initialise
%
nplot=2000;
maxiter=100;
tol=1e-12;

%
% Filter design from Table I
%

% Specification: low pass filter order is 2*M, length is 2*M+1
M=30;
fasu1=0.1;
fapl1=0.15;fapu1=0.2;
fasl2=0.25;fasu2=0.3;
fapl2=0.35;fapu2=0.4;
fasl3=0.45;
deltas1=0.001;
deltap1=0.001;
deltas2=0.005;
deltap2=0.002;
deltas3=0.01;

% Place 1+deltap at fapl,fapu and -deltas at fasl,fasu
sumfbands=(0+fasu1)+(fapu2-fapl2)+(fasu2-fasl2)+(fapu2-fapl2)+(0.5-fasl3);

nMs1=floor((M+1)*fasu1/sumfbands);
nMs1=nMs1-1;
f0s1=linspace(0,fasu1,nMs1);
A0s1=fliplr(((-1).^(1:nMs1))*deltas1);

nMp1=floor((M+1)*(fapu1-fapl1)/sumfbands);
if mod(nMp1,2)==1
  nMp1=nMp1-1;
endif
f0p1=linspace(fapl1,fapu1,nMp1+1);
A0p1=1+(((-1).^(0:nMp1))*deltap1);

nMs2=ceil((M+1)*(fasu2-fasl2)/sumfbands);
if mod(nMs2,2)==0
  nMs2=nMs2+1;
endif
f0s2=linspace(fasl2,fasu2,nMs2);
A0s2=((-1).^(1:nMs2))*deltas2;

nMp2=floor((M+1)*(fapu2-fapl2)/sumfbands);
if mod(nMp2,2)==1
  nMp2=nMp2-1;
endif
f0p2=linspace(fapl2,fapu2,nMp2+1);
A0p2=1+(((-1).^(0:nMp2))*deltap2);

nMs3=M-1-nMp2-nMs2-nMp1-nMs1;
if nMs3<2
  error("nMs3<2");
endif
f0s3=linspace(fasl3,0.5,nMs3);
A0s3=((-1).^(1:nMs3))*deltas3;

f0=[f0s1,f0p1,f0s2,f0p2,f0s3];
A0=[A0s1,A0p1,A0s2,A0p2,A0s3];
printf("f0=[ ");printf("%8.5f ",f0);printf("]\n");
printf("A0=[ ");printf("%8.5f ",A0);printf("]\n");

  % Filter design
[hM,fext,fiter,feasible]=hofstetterFIRsymmetric(f0,A0,nplot,maxiter,tol);
if feasible==false
  error("hM not feasible");
endif
Aext=directFIRsymmetricA(2*pi*fext,hM);
print_polynomial(fext,"fext","%13.10f");
print_polynomial(Aext,"Aext","%13.10f");

%
% Plot response
%
strt=sprintf("Hofstetter multi-band FIR: \
M=%d,fasu1=%g,fapl1=%g,fapu1=%g,fasl2=%g,fasu2=%g,fapl2=%g,fapu2=%g,fasl3=%g",
M,fasu1,fapl1,fapu1,fasl2,fasu2,fapl2,fapu2,fasl3);
nplot=2000;
wa=(0:nplot)'*pi/nplot;
A=directFIRsymmetricA(wa,hM);
plot(wa*0.5/pi,20*log10(abs(A)))
axis([0 0.5 -70 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
[ax,h1,h2]=plotyy(wa*0.5/pi,A,wa*0.5/pi,A);
set(h1,"linestyle","-");
set(h2,"linestyle","-");
axis(ax(1),[0 0.5 1+1.1*[-1,1]*max([deltap1,deltap2])]);
axis(ax(2),[0 0.5 1.1*[-1,1]*max([deltas1,deltas2,deltas3])]);
title(strt);
ylabel(ax(1),"Amplitude");
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
fprintf(fid,"fasu1=%g %% Amplitude first stop-band upper edge\n",fasu1);
fprintf(fid,"fapl1=%g %% Amplitude first pass band lower edge\n",fapl1);
fprintf(fid,"fapu1=%g %% Amplitude first pass band upper edge\n",fapu1);
fprintf(fid,"fasl2=%g %% Amplitude second stop band lower edge\n",fasl2);
fprintf(fid,"fasu2=%g %% Amplitude second stop band upper edge\n",fasu2);
fprintf(fid,"fapl2=%g %% Amplitude second pass band lower edge\n",fapl2);
fprintf(fid,"fapu2=%g %% Amplitude second pass band upper edge\n",fapu2);
fprintf(fid,"fasl3=%g %% Amplitude third stop band lower edge\n",fasl3);
fprintf(fid,"nplot=%d %% Number of frequency grid points in [0,0.5]\n",nplot);
fprintf(fid,"maxiter=%d %% Maximum iterations\n",maxiter);
fprintf(fid,"tol=%g %% Tolerance on convergence\n",tol);
fclose(fid);

print_polynomial(hM,"hM");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"));

save hofstetterFIRsymmetric_multiband_test.mat ...
     M fasu1 fapl1 fapu1 fasl2 fasu2 fapl2 fapu2 fasl3 ...
     nplot maxiter tol hM fext Aext

%
% Done
%
diary off
movefile hofstetterFIRsymmetric_multiband_test.diary.tmp ...
         hofstetterFIRsymmetric_multiband_test.diary;

