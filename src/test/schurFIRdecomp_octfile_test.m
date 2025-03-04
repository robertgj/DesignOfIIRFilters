% schurFIRdecomp_octfile_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("schurFIRdecomp_octfile_test.diary");
delete("schurFIRdecomp_octfile_test.diary.tmp");
diary schurFIRdecomp_octfile_test.diary.tmp


[n,d]=ellip(13,0.0005,40,2*0.05);
k=schurFIRdecomp(d)

diary off
movefile schurFIRdecomp_octfile_test.diary.tmp schurFIRdecomp_octfile_test.diary;
