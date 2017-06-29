% lanczos_tridiag_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("lanczos_tridiag_test.diary");
unlink("lanczos_tridiag_test.diary.tmp");
diary lanczos_tridiag_test.diary.tmp

format short e

rand("seed",0xdeadbeef);
A=rand(9,9);
tol=1e-10;
[T,Ap]=lanczos_tridiag(A,tol);
if max(max(abs((inv(T)*A*T)-Ap)))>tol
  error("max(max(abs((inv(T)*A*T)-Ap)))>tol");
endif

N=5;
fc=0.05;
[n,d]=butter(N,2*fc);
[A,B,C,D]=tf2Abcd(n,d);
T=lanczos_tridiag(A,tol);
Ap=inv(T)*A*T;
Bp=inv(T)*B;
Cp=C*T;
Dp=D;
[np,dp]=Abcd2tf(Ap,Bp,Cp,Dp);
if max(abs(np-n))>eps
  error("max(abs(np-n))>eps");
endif
if max(abs(dp-d))>100*eps
  error("max(abs(dp-d))>100*eps");
endif

diary off
movefile lanczos_tridiag_test.diary.tmp lanczos_tridiag_test.diary;
