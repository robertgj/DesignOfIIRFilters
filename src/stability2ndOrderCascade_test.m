% stability2ndOrderCascade_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("stability2ndOrderCascade_test.diary");
unlink("stability2ndOrderCascade_test.diary.tmp");
diary stability2ndOrderCascade_test.diary.tmp

format compact

[Ce,ee]=stability2ndOrderCascade(4)
[Co,eo]=stability2ndOrderCascade(5)

% Done
diary off
movefile stability2ndOrderCascade_test.diary.tmp ...
         stability2ndOrderCascade_test.diary;
