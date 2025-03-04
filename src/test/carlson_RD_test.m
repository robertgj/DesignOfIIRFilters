% carlson_RD_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

test_common;

delete("carlson_RD_test.diary");
delete("carlson_RD_test.diary.tmp");
diary carlson_RD_test.diary.tmp

% Compare with examples of Section 3 in "Computing Elliptic Integrals
% by Duplication", B.C. Carlson, Numerische Mathematik, 33, pp. 1-16,(1979)
B=3*0.5990701173;
tol=1e-9;
[B1,err1]=carlson_RD(0,2,1);
if abs(B1-B)>tol
  error("abs(B1-B)>tol");
endif
if err1>eps
  error("err1>eps");
endif

B=3*0.5990701173;
tol=1e-9;
[B2,err2]=carlson_RD(0,2,1,1e-9);
if abs(B2-B)>tol
  error("abs(B2-B)>tol");
endif
if err2>100*eps
  error("err2>100*eps");
endif

B=34.09325948;
tol=2e-8;
[B3,err3]=carlson_RD(5e-11,1e-10,1);
if abs(B3-B)>tol
  error("abs(B3-B)>tol");
endif
if err3>eps
  error("err3>100*eps");
endif

B=34.09325948;
tol=2e-8;
[B4,err4]=carlson_RD(5e-11,1e-10,1,1e-6);
if abs(B4-B)>tol
  error("abs(B4-B)>tol");
endif
if err4>tol/1000
  error("err4>tol/1000");
endif

k1=0.1;
[~,E]=ellipke(k1^2);
tol=10*eps;
E1=carlson_RF(0,1-(k1^2),1)-((k1^2)*carlson_RD(0,1-(k1^2),1)/3);
if abs(E-E1)>tol
  error("abs(E-E1)>tol");
endif

% Compare with Octave built-in ellipke
k2=0.9;
[~,E]=ellipke(k2^2);
tol=10*eps;
E2=carlson_RF(0,1-(k2^2),1)-((k2^2)*carlson_RD(0,1-(k2^2),1)/3);
if abs(E-E2)>tol
  error("abs(E-E2)>tol");
endif

k3=0.99;
[~,E]=ellipke(k3^2);
tol=10*eps;
E3=carlson_RF(0,1-(k3^2),1)-((k3^2)*carlson_RD(0,1-(k3^2),1)/3);
if abs(E-E3)>tol
  error("abs(E-E3)>tol");
endif

% Done
diary off
movefile carlson_RD_test.diary.tmp carlson_RD_test.diary;
