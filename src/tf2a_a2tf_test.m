% tf2a_a2tf_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("tf2a_a2tf_test.diary");
unlink("tf2a_a2tf_test.diary.tmp");
diary tf2a_a2tf_test.diary.tmp


N=7;
fc=0.1;
tol=1e-6;
epstol=32;
R=1;

[n1,d1]=butter(N,2*fc);
d1=d1(:);
[a,V,Q]=tf2a(d1,tol);
[n2,d2]=a2tf(a,V,Q,R);
if max(abs(d1-d2)) > epstol*eps
  error("max(abs(d1-d2))(%f*eps) > epstol*eps ", ...
        ceil(max(abs(d1-d2))/eps));
endif

R=3;
[n3,d3]=a2tf(a,V,Q,R);
if max(abs(d1-d3(1:R:end))) > epstol*eps
  error("max(abs(d1-d3(1:R:end))) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d3(1:R:end)))/eps));
endif

[n4,d4]=a2tf([],0,0,1);
if (n4 ~= 1) || (d4 ~= 1)
  error("Expected n4==1 and d4==1");
endif

diary off
movefile tf2a_a2tf_test.diary.tmp tf2a_a2tf_test.diary;
