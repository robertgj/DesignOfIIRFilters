% octave_format_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

[f,t]=format
0

test_common;

delete("octave_format_test.diary");
delete("octave_format_test.diary.tmp");
diary octave_format_test.diary.tmp

[f,t]=format
0

format
[f,t]=format
0

format short e
[f,t]=format
0

format
format compact
[f,t]=format
0

format
format compact short e
[f,t]=format
0

format
format compact 
format short e
[f,t]=format
0

format
format short e 
format compact
[f,t]=format
0

format short
[f,t]=format
0

format
format compact
[f,t]=format
0

format
format compact short
[f,t]=format
0

format
format compact 
format short
[f,t]=format
0

format
format short 
format compact
[f,t]=format
0

diary off
movefile octave_format_test.diary.tmp octave_format_test.diary;
