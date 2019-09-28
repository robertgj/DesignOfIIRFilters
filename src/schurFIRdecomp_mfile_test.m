% schurFIRdecomp_mfile_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("schurFIRdecomp_mfile_test.diary");
unlink("schurFIRdecomp_mfile_test.diary.tmp");
diary schurFIRdecomp_mfile_test.diary.tmp


[n,d]=ellip(5,0.0005,40,2*0.05);
k=schurFIRdecomp(d)

diary off
movefile schurFIRdecomp_mfile_test.diary.tmp schurFIRdecomp_mfile_test.diary;
