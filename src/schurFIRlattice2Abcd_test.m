% schurFIRlattice2Abcd_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% Script for testing schurFIRlattice2Abcd.m

test_common;

unlink("schurFIRlattice2Abcd_test.diary");
unlink("schurFIRlattice2Abcd_test.diary.tmp");
diary schurFIRlattice2Abcd_test.diary.tmp

format short e

% PCLS FIR band pass filter (from iir_sqp_slb_fir_bandpass_test.m)
b0 = [  0.0118204911,   0.0499523290,   0.0722229638,   0.0030388556, ... 
       -0.1373128406,  -0.2081326768,  -0.0931656062,   0.1375112133, ... 
        0.2643512300,   0.1636447194,  -0.0461317685,  -0.1507106757, ... 
       -0.0922372369,  -0.0029285497,   0.0012233951,  -0.0411924040, ... 
       -0.0313085300,   0.0339738863,   0.0714178198,   0.0416859642, ... 
       -0.0068611011,  -0.0181451409,  -0.0008958506,   0.0034838656, ... 
       -0.0130236880,  -0.0246988421,  -0.0133028092,   0.0069431806, ... 
        0.0128540726,   0.0063194220,   0.0010946266 ]';b0=b0'/b0(1);

% Find lattice coefficients
k=schurFIRdecomp(b0);

% Find state variable description
[A,B,C,D]=schurFIRlattice2Abcd(k);

% Convert back to polynomial
[b1,a]=Abcd2tf(A,B,C,D);

% Check
if max(abs(b1-b0)) > 156*eps
  printf("max(abs(b1-b0)) > 156*eps\n");
endif

diary off
movefile schurFIRlattice2Abcd_test.diary.tmp schurFIRlattice2Abcd_test.diary;
