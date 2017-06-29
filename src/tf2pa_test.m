% tf2pa_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% Test case for conversion of a transfer function to parallel allpass form

test_common;

unlink("tf2pa_test.diary");
unlink("tf2pa_test.diary.tmp");
diary tf2pa_test.diary.tmp

format short e

fc=0.05;
[n,d]=ellip(5,1,40,2*fc);
[a1,a2]=tf2pa(n,d);
numpa=(conv(a1(:),flipud(a2(:)))+conv(a2(:),flipud(a1(:))))/2;
denpa=conv(a1,a2);

Nw=1024;
w=((0:(Nw-1))'*pi/Nw)*(fc/0.5);
hpa=freqz(numpa,denpa,w);
h=freqz(n,d,w);
if max(abs(h-hpa)) > 1e5*eps
  error("max(abs(h-hpa)) = %g*eps > 1e5*eps",max(abs(h-hpa))/eps);
endif

diary off
movefile tf2pa_test.diary.tmp tf2pa_test.diary;
