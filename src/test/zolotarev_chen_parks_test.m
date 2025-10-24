% zolotarev_chen_parks_test.m
%
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("zolotarev_chen_parks_test.diary");
delete("zolotarev_chen_parks_test.diary.tmp");
diary zolotarev_chen_parks_test.diary.tmp

strf="zolotarev_chen_parks_test";

% Calculate u-to-x mapping and Zolotarev function value
k=0.8;N=32;L=6;nf=1000;
[u,x,f,um,xm,fm,a,fa,b,fb]=zolotarev_chen_parks(k,N,L,nf);
printf(["N=%2d,L=%1d,k=%3.1f,xm=%13.10f,fm=%13.10f\n", ...
 "a=%13.10f,fa=%13.10f,b=%13.10f,fb=%13.10f\n"],N,L,k,xm,fm,a,fa,b,fb);
if 0
  plot(x,f,xm,fm,"*",a,fa,"+",b,fb,"x");
else
  plot(x,f);
endif
strt=sprintf("Zolotarev function (Parks and Chen) : N=%d, L=%d k=%3.1f",N,L,k);
title(strt);
ylabel("f");
xlabel("x");
grid("on");
zticks([]);
print(sprintf("%s_x_%d_%d",strf,N,L),"-dpdflatex");
close

% Calculate u-to-x mapping and Zolotarev function value
k=0.999;N=32;L=1;
[u,x,f,um,xm,fm,a,fa,b,fb]=zolotarev_chen_parks(k,N,L,nf);
printf(["N=%2d,L=%1d,k=%5.3f,xm=%13.10f,fm=%13.10f\n", ...
 "a=%13.10f,fa=%13.10f,b=%13.10f,fb=%13.10f\n"],N,L,k,xm,fm,a,fa,b,fb);
plot(x,f);
strt=sprintf("Zolotarev function (Parks and Chen) : N=%d, L=%d k=%5.3f",N,L,k);
title(strt);
ylabel("f");
xlabel("x");
grid("on");
zticks([]);
print(sprintf("%s_x_%d_%d",strf,N,L),"-dpdflatex");
close

% Done
diary off
movefile zolotarev_chen_parks_test.diary.tmp zolotarev_chen_parks_test.diary;
