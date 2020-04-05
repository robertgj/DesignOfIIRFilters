% KW_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("KW_test.diary");
delete("KW_test.diary.tmp");
diary KW_test.diary.tmp


if !(exist("dlyap","builtin")||exist("dlyap","file"))
  error("dlyap() not found!");
endif

% Test filter
n = [ 0.0078045 -0.0021708 -0.0240139 -0.0166554 ...
      0.0211310  0.0434214  0.0227791 -0.0155667 ...
     -0.0345467 -0.0609251 -0.1197368 -0.1326113 ...
     -0.0609891 ];
d = [ 1.00000    0         -1.42123    0 ...
      1.46430    0         -1.06541    0 ...
      0.55526    0         -0.19843    0 ...
      0.03778 ];

% Recursive implementation fails for ellip(N=6), butter(N=10)
% N=9;fc=0.05;[n,d]=butter(N,2*fc);
% N=6;fc=0.05;dbap=0.1;dbas=40;[n,d]=ellip(N,dbap,dbas,2*fc);

[A,B,C,D]=tf2Abcd(n,d);
[K,W]=KW(A,B,C,D);
K(find(abs(K)<100*eps))=0
[Kdlyap,Wdlyap]=KW(A,B,C,D,"dlyap");
Kdlyap(find(abs(Kdlyap)<100*eps))=0
if max(max(abs(K-Kdlyap))) > eps
  error("max(max(abs(K-Kdlyap))) > eps");
endif
if max(max(abs(W-Wdlyap))) > eps
  error("max(max(abs(W-Wdlyap))) > eps");
endif

[Klev,Wlev]=KW(A,B,C,D,"levinson");
if max(max(abs(K-Klev)))/max(max(abs(K))) > 100*eps
  error("max(max(abs(K-Klev)))/max(max(abs(K))) > 100*eps");
endif
if max(max(abs(W-Wlev)))/max(max(abs(W))) > 100*eps
  error("max(max(abs(W-Wlev)))/max(max(abs(W))) > 100*eps");
endif

[Krec,Wrec]=KW(A,B,C,D,"recursive");
if max(max(abs(K-Krec)))/max(max(abs(K))) > 100*eps
  error("max(max(abs(K-Krec)))/max(max(abs(K))) > 100*eps");
endif
if max(max(abs(W-Wrec)))/max(max(abs(W))) > 100*eps
  error("max(max(abs(W-Wrec)))/max(max(abs(W))) > 100*eps");
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
if max(max(abs((A*K*A')+(B*B')-K))) > 1e4*eps
  error("max(max(abs((A*K*A')+(B*B')-K))) > 1e4*eps");
endif
if max(max(abs((A'*W*A)+(C'*C)-W))) > eps
  error("max(max(abs((A'*W*A)+(C'*C)-W))) > eps");
endif

% First order filter
[n,d]=butter(1,0.1*2)
[A,B,C,D]=tf2Abcd(n,d)
[K,W]=KW(A,B,C,D,"dlyap")
if max(max(abs((A*K*A')+(B*B')-K))) > 1e4*eps
  error("max(max(abs((A*K*A')+(B*B')-K))) > 1e4*eps");
endif
if max(max(abs((A'*W*A)+(C'*C)-W))) > eps
  error("max(max(abs((A'*W*A)+(C'*C)-W))) > eps");
endif

diary off
movefile KW_test.diary.tmp KW_test.diary;
