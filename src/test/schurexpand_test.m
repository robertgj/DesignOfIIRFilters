% schurexpand_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("schurexpand_test.diary");
delete("schurexpand_test.diary.tmp");
diary schurexpand_test.diary.tmp

check_octave_file("schurexpand");

% Low-pass 1
fp=0.1;
norder=7;
[n0,d0]=ellip(norder,1,40,fp*2);
[k,S]=schurdecomp(d0)
c=schurexpand(n0,S)
dc=schurexpand(fliplr(d0),S)
[km,Sm,]=schurdecomp(-d0)
cm=schurexpand(n0,Sm)
dcm=schurexpand(fliplr(d0),Sm)
dcmm=schurexpand(fliplr(-d0),Sm)
norm(k-km)
norm(S+Sm)
norm(dc+dcm)
norm(dc-dcmm)

% High-pass 1
[n0,d0]=ellip(norder,1,40,fp*2,"high");
[k,S]=schurdecomp(d0)
c=schurexpand(n0,S)
dc=schurexpand(fliplr(d0),S)
[km,Sm]=schurdecomp(-d0)
cm=schurexpand(n0,S)
dcm=schurexpand(fliplr(d0),Sm)
dcmm=schurexpand(fliplr(-d0),Sm)
norm(k-km)
norm(S+Sm)
norm(dc+dcm)
norm(dc-dcmm)

% Low-pass 2
fp=0.2;
norder=5;
[n0,d0]=ellip(norder,1,40,fp*2);
[k,S]=schurdecomp(d0)
c=schurexpand(n0,S)
dc=schurexpand(fliplr(d0),S)
[km,Sm]=schurdecomp(-d0)
cm=schurexpand(n0,S)
dcm=schurexpand(fliplr(d0),Sm)
dcmm=schurexpand(fliplr(-d0),Sm)
norm(k-km)
norm(S+Sm)
norm(dc+dcm)
norm(dc-dcmm)

% High-pass 2
[n0,d0]=ellip(norder,1,40,fp*2,"high");
[k,S]=schurdecomp(d0)
c=schurexpand(n0,S)
dc=schurexpand(fliplr(d0),S)
[km,Sm]=schurdecomp(-d0)
cm=schurexpand(n0,S)
dcm=schurexpand(fliplr(d0),Sm)
dcmm=schurexpand(fliplr(-d0),Sm)
norm(k-km)
norm(S+Sm)
norm(dc+dcm)
norm(dc-dcmm)

% Done
diary off
movefile schurexpand_test.diary.tmp schurexpand_test.diary;
