% sedumi_profiler_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

delete("sedumi_profiler_test.diary");
delete("sedumi_profiler_test.diary.tmp");
diary sedumi_profiler_test.diary.tmp

% Profile the SeDuMi examples 
profile on;
test_sedumi;
profile off;
profshow(profile("info"),8);

% Done
diary off
movefile sedumi_profiler_test.diary.tmp sedumi_profiler_test.diary;
