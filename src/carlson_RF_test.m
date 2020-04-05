% carlson_RF_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

delete("carlson_RF_test.diary");
delete("carlson_RF_test.diary.tmp");
diary carlson_RF_test.diary.tmp

% Compare with examples of Section 3 in "Computing Elliptic Integrals
% by Duplication", B.C. Carlson, Numerische Mathematik, 33, pp. 1-16,(1979)
A=1.311028778;
tol=1e-9;
A1=carlson_RF(0,1,2);
if abs(A-A1)>tol
  error("abs(A-A1)>tol");
endif

A=1.311028778;
tol=1e-9;
[A2,err2]=carlson_RF(0,1,2);
if abs(A-A2)>tol
  error("abs(A-A2)>tol");
endif
if err2>tol
  error("err2>tol");
endif

A=1.311028778;
tol=1e-9;
[A3,err3]=carlson_RF(0,2,1);
if abs(A-A3)>tol
  error("abs(A-A3)>tol");
endif
if err3>tol
  error("err3>tol");
endif

A=1.311028778;
tol=1e-7;
[A4,err4]=carlson_RF(0,2,1,1e-6);
if abs(A-A4)>tol
  error("abs(A-A4)>tol");
endif
if err4>tol
  error("err4>tol");
endif

A=12.36441982;
tol=1e-8;
[A5,err5]=carlson_RF(5e-11,1e-10,1);
if abs(A-A5)>tol
  error("abs(A-A5)>tol");
endif
if err5>tol
  error("err5>tol");
endif

A=12.36441982;
tol=2e-7;
[A6,err6]=carlson_RF(5e-11,1e-10,1,1e-6);
if abs(A-A6)>tol
  error("abs(A-A6)>tol");
endif
if err6>tol
  error("err6>tol");
endif

tol=10*eps;
[A7,err7]=carlson_RF(1,2,2);
if abs((pi/4)-A7)>tol
  error("abs((pi/4)-A7)>tol");
endif
if err7>tol
  error("err7>tol");
endif

tol=1e-7;
[A8,err8]=carlson_RF(1,2,2,1e-6);
if abs((pi/4)-A8)>tol
  error("abs((pi/4)-A8)>tol");
endif
if err8>tol
  error("err8>tol");
endif

tol=10*eps;
if abs(pi-(2*carlson_RF(0,1,1)))>tol
  error("abs(pi-(2*carlson_RF(0,1,1)))>tol");
endif

if abs(pi-(4*carlson_RF(1,2,2)))>tol
  error("abs(pi-(4*carlson_RF(1,2,2)))>tol");
endif

if abs(pi-(6*carlson_RF(3,4,4)))>tol
  error("abs(pi-(6*carlson_RF(3,4,4)))>tol");
endif

if abs(log(2)-(2*carlson_RF(9,8,8)))>tol
  error("abs(log(2)-(2*carlson_RF(9,8,8)))>tol");
endif

if abs(log(2)-(3*carlson_RF(25,16,16)))>tol
  error("abs(log(2)-(3*carlson_RF(25,16,16)))>tol");
endif

if abs(log(10)-(18*carlson_RF(121,40,40)))>tol
  error("abs(log(10)-(18*carlson_RF(121,40,40)))>tol");
endif

% Compare with Octave built-in ellipke
k1=0.1;
K1=ellipke(k1^2);
tol=10*eps;
if abs(K1-carlson_RF(0,1-(k1^2),1))>tol
  error("abs(K1-carlson_RF(0,1-(k1^2),1))>tol");
endif

k2=0.9;
K2=ellipke(k2^2);
tol=10*eps;
if abs(K2-carlson_RF(0,1-(k2^2),1))>tol
  error("abs(K2-carlson_RF(0,1-(k2^2),1))>tol");
endif

k3=0.99;
K3=ellipke(k3^2);
tol=10*eps;
if abs(K3-carlson_RF(0,1-(k3^2),1))>tol
  error("abs(K3-carlson_RF(0,1-(k3^2),1))>tol");
endif

% Check DLMF Equation 19.25.31
k=0.1:0.1:0.9;
u=(0.05:0.05:0.95);
tol=2*eps;
for n=1:length(k),
  [snu,cnu,dnu]=ellipj(u,k(n).^2);
  csu=cnu./snu;
  dsu=dnu./snu;
  nsu=1./snu;
  uc=zeros(size(u));
  for l=1:length(u),
    uc(l)=carlson_RF(csu(l)^2,dsu(l)^2,nsu(l)^2);
  endfor
  if max(abs(uc-u))>tol
    error("max(abs(uc-u))>tol");
  endif
endfor

% Done
diary off
movefile carlson_RF_test.diary.tmp carlson_RF_test.diary;
