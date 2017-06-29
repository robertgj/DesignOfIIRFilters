% schurdecomp_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurdecomp_test.diary");
unlink("schurdecomp_test.diary.tmp");
diary schurdecomp_test.diary.tmp

format short e

% Check error conditions
try
  [k,S] = schurdecomp([]);
catch
  printf("Caught schurdecomp([])!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch
try
  [k,S] = schurdecomp(0);
catch
  printf("Caught schurdecomp(0)!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch

[k,S]=schurdecomp(1)

% Short filter
fp=0.2;
norder=1;
[n0,d0]=butter(norder,fp*2);
printf("schurdecomp(d0):\n")
[k,S]=schurdecomp(d0)
printf("schurdecomp(-d0):\n")
[km,Sm]=schurdecomp(-d0)
norm(k-km)
norm(S+Sm)

% Low-pass 1
fp=0.1;
norder=7;
[n0,d0]=ellip(norder,1,40,fp*2);
printf("schurdecomp(d0):\n")
[k,S]=schurdecomp(d0)
printf("schurdecomp(-d0):\n")
[km,Sm]=schurdecomp(-d0)
norm(k-km)
norm(S+Sm)

% High-pass 1
[n0,d0]=ellip(norder,1,40,fp*2,"high");
printf("schurdecomp(d0):\n")
[k,S]=schurdecomp(d0)
printf("schurdecomp(-d0):\n")
[km,Sm]=schurdecomp(-d0)
norm(k-km)
norm(S+Sm)

% Low-pass 2
fp=0.2;
norder=5;
[n0,d0]=ellip(norder,1,40,fp*2);
printf("schurdecomp(d0):\n")
[k,S]=schurdecomp(d0)
printf("schurdecomp(-d0):\n")
[km,Sm]=schurdecomp(-d0)
norm(k-km)
norm(S+Sm)

% High-pass 2
[n0,d0]=ellip(norder,1,40,fp*2,"high");
printf("schurdecomp(d0):\n")
[k,S]=schurdecomp(d0)
printf("schurdecomp(-d0):\n")
[km,Sm]=schurdecomp(-d0)
norm(k-km)
norm(S+Sm)

% Done
diary off
movefile schurdecomp_test.diary.tmp schurdecomp_test.diary;
