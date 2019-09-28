% schurFIRlatticeFilter_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Script for testing schurFIRlatticeFilter.m

test_common;

unlink("schurFIRlatticeFilter_test.diary");
unlink("schurFIRlatticeFilter_test.diary.tmp");
diary schurFIRlatticeFilter_test.diary.tmp


% PCLS FIR band pass filter (from iir_sqp_slb_fir_bandpass_test.m)
b0 = [  0.0117087207,   0.0499190257,   0.0726142627,   0.0034935525, ... 
       -0.1370726657,  -0.2084921356,  -0.0941826374,   0.1368034359, ... 
        0.2643360423,   0.1643559587,  -0.0452879126,  -0.1503312314, ... 
       -0.0921221409,  -0.0030577158,   0.0009958992,  -0.0416360279, ... 
       -0.0318523987,   0.0336353024,   0.0713450244,   0.0420790902, ... 
       -0.0063006565,  -0.0177145874,  -0.0007720164,   0.0031907077, ... 
       -0.0133747112,  -0.0249118517,  -0.0133464266,   0.0070748940, ... 
        0.0129710100,   0.0063419843,   0.0010919862 ]';

% Find lattice coefficients
k=schurFIRdecomp(b0/b0(1));

% Quantise lattice coefficients
nbits=6;
scale=2^(nbits-1);
kf=round(k*scale)/scale;

% Make a quantised noise signal with standard deviation 0.25
nsamples=2^12;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u); 
u=round(u*scale);

% Filter
[yf xxf]=schurFIRlatticeFilter(kf,u,"round");

% Show the state variance
disp(std(xxf)')

% Plot frequency response
nfpts=1024;
nppts=(0:511);
Hf=crossWelch(u,yf,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(Hf)));
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -20 40]);
print("schurFIRlatticeFilter_test_6bits_rounding","-dpdflatex");
close

diary off
movefile schurFIRlatticeFilter_test.diary.tmp schurFIRlatticeFilter_test.diary;
