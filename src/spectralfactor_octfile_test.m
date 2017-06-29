% spectralfactor_octfile_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% Test case for the spectral factor with the octfile

test_common;

unlink("spectralfactor_octfile_test.diary");
unlink("spectralfactor_octfile_test.diary.tmp");
diary spectralfactor_octfile_test.diary.tmp

format short e

[n,d]=ellip(13,0.0005,40,2*0.05);
q=spectralfactor(n,d)

diary off
movefile spectralfactor_octfile_test.diary.tmp spectralfactor_octfile_test.diary;
