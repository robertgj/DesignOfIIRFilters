% schurFIRlattice2Abcd_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Script for testing schurFIRlattice2Abcd.m

test_common;

delete("schurFIRlattice2Abcd_test.diary");
delete("schurFIRlattice2Abcd_test.diary.tmp");
diary schurFIRlattice2Abcd_test.diary.tmp


% PCLS FIR band pass filter (from iir_sqp_slb_fir_bandpass_test.m)
b0 = [  0.0117087207,   0.0499190257,   0.0726142627,   0.0034935525, ... 
       -0.1370726657,  -0.2084921356,  -0.0941826374,   0.1368034359, ... 
        0.2643360423,   0.1643559587,  -0.0452879126,  -0.1503312314, ... 
       -0.0921221409,  -0.0030577158,   0.0009958992,  -0.0416360279, ... 
       -0.0318523987,   0.0336353024,   0.0713450244,   0.0420790902, ... 
       -0.0063006565,  -0.0177145874,  -0.0007720164,   0.0031907077, ... 
       -0.0133747112,  -0.0249118517,  -0.0133464266,   0.0070748940, ... 
        0.0129710100,   0.0063419843,   0.0010919862 ]';
b0=b0'/b0(1);

% Find lattice coefficients
k=schurFIRdecomp(b0);

% Find state variable description
[A,B,C,D]=schurFIRlattice2Abcd(k);

% Convert back to polynomial
[b1,a]=Abcd2tf(A,B,C,D);

% Check
if max(abs(b1-b0)) > 48*eps
  printf("max(abs(b1-b0)) > 48*eps\n");
endif

diary off
movefile schurFIRlattice2Abcd_test.diary.tmp schurFIRlattice2Abcd_test.diary;
