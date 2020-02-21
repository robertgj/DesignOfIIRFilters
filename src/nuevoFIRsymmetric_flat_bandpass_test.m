% nuevoFIRsymmetric_flat_bandpass_test.m
% Design an interpolated FIR filter by the method of Nuevo et al. with
% a maximally-flat model filter.
%
% Copyright (C) 2020 Robert G. Jenssen

test_common;

unlink("nuevoFIRsymmetric_flat_bandpass_test.diary");
unlink("nuevoFIRsymmetric_flat_bandpass_test.diary.tmp");
diary nuevoFIRsymmetric_flat_bandpass_test.diary.tmp

strf="nuevoFIRsymmetric_flat_bandpass_test";

nplot=4000;
w=pi*(0:nplot)'/nplot;

% Model filter specification
P=8;M=19;
fc=0.2;
xc=0.5*(1-cos(2*pi*fc));
K=M-floor((M*xc)+0.5);

% Interpolated model filter
hM=herrmannFIRsymmetric_flat_lowpass(M,K);
hM=hM(:);
hPM=zeros((2*M*P)+1,1);
hPM(1:P:end)=[hM;hM(M:-1:1)];

% Interpolator filter section with no multipliers
hza=conv(conv([-1;2;-1],[-1;-2;-1]),[-1;0;-1]);

% Interpolator filter section with multipliers
hzb=1;
kz=[0.75,7.25,8.75,11.75,12,12.5,15.5];
for k=kz,
  hzb=conv(hzb,[-1;2*cos(2*pi*k/(4*P));-1]);
endfor
Hzab=freqz(conv(hza,hzb),1,w);
hzb=hzb/max(abs(Hzab));

% Overall filter impulse response
hPMzab=conv(hPM,conv(hza,hzb));

% Plot responses
AM=directFIRsymmetricA(w,hM(1:(M+1)));
APM=directFIRsymmetricA(w,hPM(1:(P*M)+1));
Aza=directFIRsymmetricA(w,hza(1:(length(hza)+1)/2));
Azb=directFIRsymmetricA(w,hzb(1:(length(hzb)+1)/2));
APMzab=directFIRsymmetricA(w,hPMzab(1:(length(hPMzab)+1)/2));
plot(w*0.5/pi,20*log10(APM.*Aza.*Azb));
axis([0 0.5 -100 10])
grid("on");
xlabel("Frequency");
ylabel("Amplitude (dB)");
title(sprintf("Interpolated maximally flat FIR filter : P=%d,M=%d,fc=%g,K=%d",...
              P,M,fc,K));
print(strcat(strf,"_response"),"-dpdflatex");
close

subplot(211)
plot(w*0.5/pi,20*log10(APM));
axis([0 0.5 -100 10])
grid("on");
ylabel("Amplitude (dB)");
title(sprintf("Interpolated model filter : P=%d,M=%d,fc=%g,K=%d",P,M,fc,K));
subplot(212)
plot(w*0.5/pi,20*log10(Aza.*Azb));
axis([0 0.5 -100 10])
grid("on");
xlabel("Frequency");
ylabel("Amplitude (dB)");
title("Interpolator filter")
print(strcat(strf,"_interpolator"),"-dpdflatex");
close

%
% Round to +/- 15 bits
%
nbits=16;
nscale=2^(nbits-1);
hMf=round(hM*nscale)/nscale;
find(hMf(1:(length(hMf)+1)/2)==0)'
hMf=hMf(5:end);
hPMf=zeros((2*(length(hMf)-1)*P)+1,1);
hPMf(1:P:end)=[hMf;hMf((end-1):-1:1)];

hzbf=round(hzb*nscale)/nscale;
find(hzbf(1:(length(hzbf)+1)/2)==0)

hPMzabf=conv(hPMf,conv(hza,hzbf));
APMzabf=directFIRsymmetricA(w,hPMzabf(1:(length(hPMzabf)+1)/2));

plot(w*0.5/pi,20*log10(abs(APMzabf)));
axis([0 0.5 -100 10])
grid("on");
xlabel("Frequency");
ylabel("Amplitude (dB)");
title(sprintf("Interpolated maximally flat FIR filter amplitude response with \
%d-bit rounded coefficients: P=%d,M=%d,fc=%g,K=%d",nbits,P,M,fc,K));
print(strcat(strf,"_16bit_response"),"-dpdflatex");
close

plot(w*0.5/pi,20*log10(abs(APMzabf-APMzab)));
axis([0 0.5 -140 -60])
grid("on");
xlabel("Frequency");
ylabel("Amplitude error (dB)");
title(sprintf("Interpolated maximally flat FIR filter amplitude response \
error with %d-bit rounded coefficients: P=%d,M=%d,fc=%g,K=%d",nbits,P,M,fc,K));
print(strcat(strf,"_16bit_error"),"-dpdflatex");
close

%
% Save filter specification
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"P=%d %% Interpolation factor",P);
fprintf(fid,"M=%d %% Model filter has M+1 distinct coefficients, length 2M+1",M);
fprintf(fid,"fc=%g %% Model filter nominal cutoff frequency",fc);
fprintf(fid,"nplot=%d %% Points across frequency band\n",nplot);
fclose(fid);

%
% Save results
%
print_polynomial(hM,"hM","%15.12f");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"),"%15.12f");

print_polynomial(hza,"hza","%15.12f");
print_polynomial(hza,"hza",strcat(strf,"_hza_coef.m"),"%15.12f");

print_polynomial(hzb,"hzb","%15.12f");
print_polynomial(hzb,"hzb",strcat(strf,"_hzb_coef.m"),"%15.12f");

print_polynomial(hMf,"hMf",nscale);
print_polynomial(hMf,"hMf",strcat(strf,"_hMf_coef.m"),nscale);

print_polynomial(hzbf,"hzbf",nscale);
print_polynomial(hzbf,"hzbf",strcat(strf,"_hzbf_coef.m"),nscale);

save nuevoFIRsymmetric_flat_bandpass_test.mat ...
     nplot w P M fc xc K hM hza kz hzb hPMzab nbits hMf hPMf hzbf hPMzabf

%
% Done
%
diary off
movefile nuevoFIRsymmetric_flat_bandpass_test.diary.tmp ...
         nuevoFIRsymmetric_flat_bandpass_test.diary;

