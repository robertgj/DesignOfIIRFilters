% xfr2tf_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

  set(0,'DefaultFigureVisible','on');
  set(0,"defaultlinelinewidth",2);

delete("xfr2tf_test.diary");
delete("xfr2tf_test.diary.tmp");
diary xfr2tf_test.diary.tmp

strf="xfr2tf_test";

%  
% Initialise
%
nplot=4000;
tol=1e-6;

%
% Even order, odd length FIR filter
%
M=12; N=(2*M);
b=remez(N,[0 0.1 0.2 0.5]*2,[1 1 0 0]);
b=b(:)';
bM=b(1:(M+1));
f=(0:nplot)'*0.5/nplot;
w=2*pi*f;
A=directFIRsymmetricA(w,bM);
maxA=local_max(A);
minA=local_max(-A);
extA=unique([maxA;minA]);
hM=xfr2tf(M,cos(w(extA)),A(extA),eps);
if max(abs(hM'-bM))>eps
  error("max(abs(hM'-bM))>eps");
endif

print_polynomial(hM,"hM");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"));

%
% Done
%
diary off
movefile xfr2tf_test.diary.tmp xfr2tf_test.diary;

