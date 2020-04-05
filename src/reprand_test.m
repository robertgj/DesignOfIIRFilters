% reprand_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

test_common;

delete("reprand_test.diary");
delete("reprand_test.diary.tmp");
diary reprand_test.diary.tmp

check_octave_file("reprand");

try
  reprand()
catch
  printf("Caught reprand exception for no arguments!\n");
end_try_catch

try
  reprand(1,2,3)
catch
  printf("Caught reprand exception for 3 arguments!\n");
end_try_catch

isempty(reprand(-1))

isempty(reprand(0))

isempty(reprand(0,0))

reprand(1)

reprand(1,1)

reprand(1,4)

reprand(4,1)

reprand(4)

n1=reprand(1,2^14);
size(n1)
printf("max(n1)=%20.12e\n",max(n1));
printf("min(n1)=%20.12e\n",min(n1));
printf("mean(n1)=%20.12e\n",mean(n1));
printf("var(n1)=%20.12e\n",var(n1));
printf("std(n1)=%20.12e\n",std(n1));

n2=reprand(2^14,1);
size(n2)
printf("max(n2)=%20.12e\n",max(n2));
printf("min(n2)=%20.12e\n",min(n2));
printf("mean(n2)=%20.12e\n",mean(n2));
printf("var(n2)=%20.12e\n",var(n2));
printf("std(n2)=%20.12e\n",std(n2));

printf("norm(n1(:)-n2(:))=%20.12e\n",norm(n1(:)-n2(:)));

diary off
movefile reprand_test.diary.tmp reprand_test.diary;
