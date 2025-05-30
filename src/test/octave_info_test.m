% octave_info_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("octave_info_test.diary");
delete("octave_info_test.diary.tmp");
diary octave_info_test.diary.tmp

printf("computer=%s\n",computer);
printf("octave version=%s (HG-ID=%s)\n",version,__octave_config_info__.hg_id);
pkg list;

diary off
movefile octave_info_test.diary.tmp octave_info_test.diary;
