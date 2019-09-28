% spectralfactor_mfile_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for the spectral factor 

test_common;

unlink("spectralfactor_mfile_test.diary");
unlink("spectralfactor_mfile_test.diary.tmp");
diary spectralfactor_mfile_test.diary.tmp


[n,d]=ellip(5,0.5,40,2*0.05);
q=spectralfactor(n,d)

diary off
movefile spectralfactor_mfile_test.diary.tmp spectralfactor_mfile_test.diary;
