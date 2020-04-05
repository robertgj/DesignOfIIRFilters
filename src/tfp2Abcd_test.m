% tfp2Abcd_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Script for testing frequency transformations by tfp2Abcd.m

test_common;

delete("tfp2Abcd_test.diary");
delete("tfp2Abcd_test.diary.tmp");
diary tfp2Abcd_test.diary.tmp


function plot_response(n,d,fname)
  [h,w]=freqz(n,d,1024);
  subplot(211);
  plot(0.5*w/pi,20*log10(abs(h)));
  axis([0 0.5 -50 5]);
  grid("on");
  ylabel("Amplitude(dB)")
  subplot(212);
  plot(0.5*w/pi,20*log10(abs(h)));
  axis([0 0.5 -1 0.5]);
  grid("on");
  ylabel("Amplitude(dB)");
  xlabel("Normalised Frequency");
  print(fname,"-dpdflatex");
  close
endfunction

tol=160*eps;

% Prototype lowpass (fp=0.5 corresponds to 0.5*Fs/2)
printf("Prototype lowpass (phi=0.5)\n");
[n0,d0]=ellip(5,0.5,40,0.5);
plot_response(n0,d0,"tfp2Abcd_test_lpproto");

% Lowpass-lowpass
printf("Lowpass-to-lowpass (phi=0.05)\n");
phi=0.05;
p=phi2p(phi)
[A,B,C,D]=tfp2Abcd(n0,d0,p,1)
[n,d]=Abcd2tf(A,B,C,D);
plot_response(n,d,"tfp2Abcd_test_lp");
[nn,dd]=tfp2g(n0,d0,p,1);
if norm(nn-n) > tol
  error("norm(nn-n) > tol");
endif
if norm(dd-d) > tol
  error("norm(dd-d) > tol");
endif

% Lowpass-highpass
printf("Lowpass-to-highpass (phi=0.35)\n");
phi=0.35;
p=phi2p(phi)
[A,B,C,D]=tfp2Abcd(n0,d0,p,-1)
[n,d]=Abcd2tf(A,B,C,D);
plot_response(n,d,"tfp2Abcd_test_hp");
[nn,dd]=tfp2g(n0,d0,p,-1);
if norm(nn-n) > tol
  error("norm(nn-n) > tol");
endif
if norm(dd-d) > tol
  error("norm(dd-d) > tol");
endif

% Lowpass-Bandpass 
printf("Lowpass-to-bandpass (phi=[0.2, 0.3])\n");
phi=[0.2 0.25];
p=phi2p(phi)
[A,B,C,D]=tfp2Abcd(n0,d0,p,-1)
[n,d]=Abcd2tf(A,B,C,D);
plot_response(n,d,"tfp2Abcd_test_bp");
[nn,dd]=tfp2g(n0,d0,p,-1);
if norm(nn-n) > tol
  error("norm(nn-n) > tol");
endif
if norm(dd-d) > tol
  error("norm(dd-d) > tol");
endif

% Lowpass-Triple Bandstop 
printf("Lowpass-to-triple-bandstop (phi=[0.1 0.15 0.2 0.25 0.3 0.35])\n");
phi=[0.1 0.15 0.2 0.25 0.3 0.35];
p=phi2p(phi)
[A,B,C,D]=tfp2Abcd(n0,d0,p,1)
[n,d]=Abcd2tf(A,B,C,D);
plot_response(n,d,"tfp2Abcd_test_bs");
[nn,dd]=tfp2g(n0,d0,p,1);
if norm(nn-n) > 5e4*tol
  error("norm(nn-n) > 5e4*tol");
endif
if norm(dd-d) > 5e4*tol
  error("norm(dd-d) > 5e4*tol");
endif

% Done
diary off
movefile tfp2Abcd_test.diary.tmp tfp2Abcd_test.diary;
