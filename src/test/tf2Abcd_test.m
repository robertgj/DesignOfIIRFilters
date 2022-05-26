% tf2Abcd_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("tf2Abcd_test.diary");
delete("tf2Abcd_test.diary.tmp");
diary tf2Abcd_test.diary.tmp


fc=0.05
[n,d]=butter(3,2*fc)
[Aa,ba,ca,da]=tf2Abcd(n,d)
[Ab,bb,cb,db]=tf2Abcd(n,1)
[Ac,bc,cc,dc]=tf2Abcd(1,d)

diary off
movefile tf2Abcd_test.diary.tmp tf2Abcd_test.diary;
