% carlson_RJ_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

delete("carlson_RJ_test.diary");
delete("carlson_RJ_test.diary.tmp");
diary carlson_RJ_test.diary.tmp

% Compare with example of Section 3 in "Computing Elliptic Integrals
% by Duplication", B.C. Carlson, Numerische Mathematik, 33, pp. 1-16,(1979)
tol=3e-11;
A=0.1429757967;
if abs(A-carlson_RJ(2,3,4,5))>tol
  error("abs(A-carlson_RJ(2,3,4,5))>tol");
endif

% Compare with special cases listed in Section 19.20(iii) of "Digital
% Library of Mathematical Functions": https://dlmf.nist.gov/19.20
%

% 19.20.6
tol=2*eps;
x=1;
if abs(1-carlson_RJ(x,x,x,x,tol))>tol
  error("abs(1-carlson_RJ(x,x,x,x,tol))>tol");
endif
x=2;
if abs((2^(-3/2))-carlson_RJ(x,x,x,x))>tol
  error("abs((2^(-3/2))-carlson_RJ(x,x,x,x))>tol");
endif

x=2;y=3;z=4;p=5;l=1.5;
if abs(((l^(-3/2))*carlson_RJ(x,y,z,p))-carlson_RJ(l*x,l*y,l*z,l*p))>tol
  error("abs(((l^(-3/2))*carlson_RJ(x,y,z,p))-carlson_RJ(l*x,l*y,l*z,l*p))>tol");
endif

x=4;y=3;z=2;
if abs(carlson_RD(x,y,z)-carlson_RJ(x,y,z,z))>tol
  error("abs(carlson_RD(x,y,z)-carlson_RJ(x,y,z,z))>tol");
endif

x=3;p=2;
if abs(carlson_RD(p,p,x)-carlson_RJ(x,x,x,p))>tol
  error("abs(carlson_RD(p,p,x)-carlson_RJ(x,x,x,p))>tol");
endif
if abs((3/(x-p))*(carlson_RC(x,p)-(1/sqrt(x)))-carlson_RJ(x,x,x,p))>tol
  error("abs((3/(x-p))*(carlson_RC(x,p)-(1/sqrt(x)))-carlson_RJ(x,x,x,p))>tol");
endif

tol=10*eps;
y=0.1;p=pi/4;
if abs((3*pi/(2*((y*sqrt(p))+(sqrt(y)*p))))-carlson_RJ(0,y,y,p))>tol
  error("abs((3*pi/(2*((y*sqrt(p))+(sqrt(y)*p))))-carlson_RJ(0,y,y,p))>tol");
endif

tol=10*eps;
x=3;y=0.3;p=0.2;
if abs(((3/(p-y))*(carlson_RC(x,y)-carlson_RC(x,p)))-carlson_RJ(x,y,y,p))>tol
  error("abs(((3/(p-y))*(carlson_RC(x,y)-carlson_RC(x,p)))-\
carlson_RJ(x,y,y,p))>tol");
endif

tol=eps;
y=0.3;z=5;
if abs(((3/(2*sqrt(y*z)))*carlson_RF(0,y,z))-carlson_RJ(0,y,z,sqrt(y*z)))>tol
  error("abs(((3/(2*sqrt(y*z)))*carlson_RF(0,y,z))-\
carlson_RJ(0,y,z,sqrt(y*z)))>tol");
endif

% Done
diary off
movefile carlson_RJ_test.diary.tmp carlson_RJ_test.diary;
