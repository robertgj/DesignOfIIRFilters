% tfp2g_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Script for testing frequency transformations

test_common;

delete("tfp2g_test.diary");
delete("tfp2g_test.diary.tmp");
diary tfp2g_test.diary.tmp


function plot_response(B,A,fname)
  [h,w]=freqz(B,A,1024);
  subplot(211);
  plot(0.5*w/pi,20*log10(abs(h)))
  axis([0 0.5 -50 10]);
  grid("on");
  ylabel("Amplitude(dB)")
  subplot(212);
  plot(0.5*w/pi,20*log10(abs(h)))
  axis([0 0.5 -0.5 0.1]);
  grid("on");
  ylabel("Amplitude(dB)")
  xlabel("Frequency")
  print(fname,"-dpdflatex");
  close
endfunction

% Prototype lowpass (fp=0.5 corresponds to 0.5*Fs/2)
printf("Prototype lowpass (phi=0.5)\n");
[b,a]=ellip(5,0.4,40,0.5)
plot_response(b,a,"tfp2g_test_lpproto");

% Lowpass-lowpass
printf("Lowpass-to-lowpass (phi=0.05)\n");
phi=0.05
p=phi2p(phi)
[B,A]=tfp2g(b,a,p,1)
plot_response(B,A,"tfp2g_test_lp");

% Lowpass-highpass
printf("Lowpass-to-highpass (phi=0.35)\n");
phi=0.35
p=phi2p(phi)
[B,A]=tfp2g(b,a,p,-1)
plot_response(B,A,"tfp2g_test_hp");

% Lowpass-Bandpass 
printf("Lowpass-to-bandpass (phi=[0.2, 0.3])\n");
phi=[0.2 0.3]
p=phi2p(phi)
[B,A]=tfp2g(b,a,p,-1)
plot_response(B,A,"tfp2g_test_bp");

% Lowpass-Triple Bandstop 
printf("Lowpass-to-triple-bandstop (phi=[0.1 0.15 0.2 0.25 0.3 0.35])\n");
phi=[0.1 0.15 0.2 0.25 0.3 0.35]
p=phi2p(phi)
[B,A]=tfp2g(b,a,p,1)
plot_response(B,A,"tfp2g_test_bs");

%Done
diary off
movefile tfp2g_test.diary.tmp tfp2g_test.diary;
