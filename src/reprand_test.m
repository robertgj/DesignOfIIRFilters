% reprand_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("reprand_test.diary");
unlink("reprand_test.diary.tmp");
diary reprand_test.diary.tmp

format short e

n1=reprand(2^14);
n2=reprand(2^14);
max(n1)
min(n1)
mean(n1)
var(n1)
std(n1)
max(abs(n1-n2))

diary off
movefile reprand_test.diary.tmp reprand_test.diary;
