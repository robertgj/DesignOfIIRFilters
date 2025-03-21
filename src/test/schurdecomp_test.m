% schurdecomp_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("schurdecomp_test.diary");
delete("schurdecomp_test.diary.tmp");
diary schurdecomp_test.diary.tmp

check_octave_file("schurdecomp");

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

% One output argument
k = schurdecomp(1);

% Two output arguments
[k,S]=schurdecomp(1)

% Short filter
fp=0.2;
norder=1;
[n0,d0]=butter(norder,fp*2);
printf("kk=schurdecomp(d0):\n")
kk=schurdecomp(d0)
printf("[k,S]=schurdecomp(d0):\n")
[k,S]=schurdecomp(d0)
printf("[km,Sm]=schurdecomp(-d0):\n")
[km,Sm]=schurdecomp(-d0)
norm(kk-km)
norm(k-km)
norm(S+Sm)

% Low-pass 1
fp=0.1;
norder=7;
[n0,d0]=ellip(norder,1,40,fp*2);
printf("kk=schurdecomp(d0):\n")
kk=schurdecomp(d0)
printf("[k,S]=schurdecomp(d0):\n")
[k,S]=schurdecomp(d0)
printf("[km,Sm]=schurdecomp(-d0):\n")
[km,Sm]=schurdecomp(-d0)
norm(kk-km)
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
