% direct_form_scale_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

delete("direct_form_scale_test.diary");
delete("direct_form_scale_test.diary.tmp");
diary direct_form_scale_test.diary.tmp

strf="direct_form_scale_test";

N=20;fap=0.1;fas=0.3;
b=remez(N,2*[0 fap fas 0.5],[1 1 0 0]);
scaled_b = direct_form_scale(b);
[scaled_H,w]=freqz(scaled_b,1,8192);
tol=5e-10;
if abs(max(abs(scaled_H))-1)>tol
  error("abs(max(abs(scaled_H))-1)(%g)>tol(%g)",abs(max(abs(scaled_H))-1),tol);
endif

N=10;fap=0.1;dBap=0.1;dBas=60;
[b,a]=ellip(N,dBap,dBas,2*fap);
bscale=1.05;
b=b*bscale;

scaled_b = direct_form_scale(b,a);
[H,w]=freqz(scaled_b,a,4096);
tol=2e-7;
if abs(max(abs(H))-1)>tol
  error("abs(max(abs(H))-1)(%g)>tol(%g)",abs(max(abs(H))-1),tol);
endif

[scaled_b,scaled_w] = direct_form_scale(b,a);
H=freqz(scaled_b,a,scaled_w);
tol=2e-9;
if abs(max(abs(H))-1)>tol
  error("abs(max(abs(H))-1)(%g)>tol(%g)",abs(max(abs(H))-1),tol);
endif

Nw=2^15;
[scaled_b,scaled_w,scaled_H] = direct_form_scale(b,a,Nw);
tol=2e-9;
if abs(max(abs(scaled_H))-1)>tol
  error("abs(max(abs(scaled_H))-1)(%g)>tol(%g)",abs(max(abs(scaled_H))-1),tol);
endif

% Done
diary off
movefile direct_form_scale_test.diary.tmp direct_form_scale_test.diary;
