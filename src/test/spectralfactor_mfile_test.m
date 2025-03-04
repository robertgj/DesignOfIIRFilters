% spectralfactor_mfile_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the spectral factor 

test_common;

delete("spectralfactor_mfile_test.diary");
delete("spectralfactor_mfile_test.diary.tmp");
diary spectralfactor_mfile_test.diary.tmp


[n,d]=ellip(5,0.5,40,2*0.05);
q=spectralfactor(n,d)

diary off
movefile spectralfactor_mfile_test.diary.tmp spectralfactor_mfile_test.diary;
