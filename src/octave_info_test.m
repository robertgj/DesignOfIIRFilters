% octave_info_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("octave_info_test.diary");
unlink("octave_info_test.diary.tmp");
diary octave_info_test.diary.tmp
printf("computer=%s\n",computer);
if isunix 
  printf("kernel=");
  fflush(stdout);
  system("uname -r");
  fflush(stdout);
  system("grep -m1 -A7 vendor_id /proc/cpuinfo | egrep -v MHz");
  fflush(stdout);
endif
printf("octave version=%s\n",version);
pkg list;
diary off
movefile octave_info_test.diary.tmp octave_info_test.diary;
