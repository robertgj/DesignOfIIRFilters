% optKW_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("optKW_test.diary");
unlink("optKW_test.diary.tmp");
diary optKW_test.diary.tmp


if !(exist("dlyap","builtin")||exist("dlyap","file"))
  error("dlyap() not found!");
endif

% From Roberts and Mullis Section 9.15
A = [ ...
  0.0000e+00  1.0000e+00  0.0000e+00  0.0000e+00  0.0000e+00  0.0000e+00;
 -8.8563e-01  1.8819e+00  8.0340e-05  3.6960e-03  2.9600e-08  3.6700e-06;
  0.0000e+00  0.0000e+00  0.0000e+00  1.0000e+00  0.0000e+00  0.0000e+00;
  0.0000e+00  0.0000e+00 -9.1498e-01  1.9112e+00  3.1340e-05  3.8850e-03;
  0.0000e+00  0.0000e+00  0.0000e+00  0.0000e+00  0.0000e+00  1.0000e+00;
  0.0000e+00  0.0000e+00  0.0000e+00  0.0000e+00 -9.6802e-01  1.9641e+00];
B = [ 0 9.2610e-07 0 9.8100e-04 0 1]';
C = [ 1.0665e-04 3.6200e-03 7.4900e-08 3.4500e-06 2.7600e-11 3.4200e-09 ];
D = 8.6360e-10;

[K,W]=KW(A,B,C,D,"dlyap")
delta=4;
[Topt,Kopt,Wopt]=optKW(K,W,delta);
Aopt=inv(Topt)*A*Topt;
Bopt=inv(Topt)*B;
Copt=C*Topt;
Dopt=D;
if max(max(abs((Aopt*Kopt*Aopt')+(Bopt*Bopt')-Kopt))) > 10*eps
  error("max(max(abs((Aopt*Kopt*Aopt')+(Bopt*Bopt')-Kopt))) > 100*eps");
endif

if max(max(abs((Aopt'*Wopt*Aopt)+(Copt'*Copt)-Wopt))) > 120*eps
  error("max(max(abs((Aopt'*Wopt*Aopt)+(Copt'*Copt)-Wopt))) > 120*eps");
endif
diary off
movefile optKW_test.diary.tmp optKW_test.diary;
