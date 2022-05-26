% spectralfactor_octfile_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for the spectral factor with the octfile

test_common;

delete("spectralfactor_octfile_test.diary");
delete("spectralfactor_octfile_test.diary.tmp");
diary spectralfactor_octfile_test.diary.tmp


[n,d]=ellip(13,0.0005,40,2*0.05);
q=spectralfactor(n,d)

diary off
movefile spectralfactor_octfile_test.diary.tmp spectralfactor_octfile_test.diary;
