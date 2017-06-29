% svcasc2cc_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("svcasc2cc_test.diary");
unlink("svcasc2cc_test.diary.tmp");
diary svcasc2cc_test.diary.tmp

format short e

% Some housekeeping
N=21;
fc=0.1;
bits=8;
scale=2^(bits-1);
delta=4;
nfpts=1024;
nppts=(0:511);
name=sprintf("butt%d",N);

% Find the state variable equations of a 20th order Butterworth
% filter implemented as a cascade of second order sections.
% butter2pq() finds the second order sections in d-p-q format
% directly from the Butterworth poles. 
[dd,p1,p2,q1,q2]=butter2pq(N,fc);

% Find the state variable equations of the example filter
% implemented as a cascade of direct form second order sections.
[a11,a12,a21,a22,b1,b2,c1,c2]=pq2svcasc(p1,p2,q1,q2,"dir");

% Round the coefficients
a11f=round(a11*scale)/scale;
a12f=round(a12*scale)/scale;
a21f=round(a21*scale)/scale;
a22f=round(a22*scale)/scale;
b1f=round(b1*scale)/scale;
b2f=round(b2*scale)/scale;
c1f=round(c1*scale)/scale;
c2f=round(c2*scale)/scale;
ddf=round(dd*scale)/scale;

% Make C++ code
svcasc2cc(a11f,a12f,a21f,a22f,b1f,b2f,c1f,c2f,ddf,bits,name);
[output,status]=mkoctfile(sprintf("%s.cc",name),"-D USING_OCTAVE -Wall");
if status
  error("mkoctfile() failed for %s! : (%s)", name, output);
endif

%
% Run the block optimised cascade filter for floating and fixed point
% registers

% Input waveform
rand("seed",0xdeadbeef)
u=rand(2^10,1)-0.5;
u=0.25*u/std(u);
u=round(u*scale);

% Run svf with floating point arithmetic and rounding
[Af,Bf,Cf,Df] = svcasc2Abcd(a11f,a12f,a21f,a22f, b1f,b2f,c1f,c2f,ddf);
[svf_y,svf_xx] = svf(Af,Bf,Cf,Df,u,"none");
[svf_yf,svf_xxf] = svf(Af,Bf,Cf,Df,u,"round");

% Run svcascf with floating point and rounding
[y,xx1,xx2] = svcascf(a11f,a12f,a21f,a22f,b1f,b2f,c1f,c2f,ddf,u,"none");
[yf,xx1f,xx2f] = svcascf(a11f,a12f,a21f,a22f,b1f,b2f,c1f,c2f,ddf,u,"round");

% Run C++ code
[cc_yf,cc_xx1f,cc_xx2f] = feval(name,u);

% Compare svf to svcascf
if std(svf_y-y(:,end)) > 140*eps
  error("std(svf_y-y(:,end)) > 140*eps");
endif

% Compare svcascf to C++
if max(abs(yf(:,end)-cc_yf)) ~= 0
  error("max(abs(yf-cc_yf)) ~= 0");
endif
if max(max(abs(xx1f-cc_xx1f))) ~= 0
  error("max(max(abs(xx1f-cc_xx1f))) ~= 0");
endif
if max(max(abs(xx2f-cc_xx2f))) ~= 0
  error("max(max(abs(xx2f-cc_xx2f))) ~= 0");
endif

diary off
movefile svcasc2cc_test.diary.tmp svcasc2cc_test.diary;
