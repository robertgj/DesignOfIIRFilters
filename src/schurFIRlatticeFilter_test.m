% schurFIRlatticeFilter_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% Script for testing schurFIRlatticeFilter.m

test_common;

unlink("schurFIRlatticeFilter_test.diary");
unlink("schurFIRlatticeFilter_test.diary.tmp");
diary schurFIRlatticeFilter_test.diary.tmp

format short e

% PCLS FIR band pass filter (from iir_sqp_slb_fir_bandpass_test.m)
b0 = [  0.0118204911,   0.0499523290,   0.0722229638,   0.0030388556, ... 
       -0.1373128406,  -0.2081326768,  -0.0931656062,   0.1375112133, ... 
        0.2643512300,   0.1636447194,  -0.0461317685,  -0.1507106757, ... 
       -0.0922372369,  -0.0029285497,   0.0012233951,  -0.0411924040, ... 
       -0.0313085300,   0.0339738863,   0.0714178198,   0.0416859642, ... 
       -0.0068611011,  -0.0181451409,  -0.0008958506,   0.0034838656, ... 
       -0.0130236880,  -0.0246988421,  -0.0133028092,   0.0069431806, ... 
        0.0128540726,   0.0063194220,   0.0010946266 ]';

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
