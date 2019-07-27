% vaidyanathan_trick_test.m
% Copyright (C) 2019 Robert G. Jenssen
%
% See: "A “TRICK” for the Design of FIR Half-Band Filters
% P. P. Vaidyanathan and Truong Q. Nguyen, IEEE Transactions on
% Circuits and Systems, Vol. 34, No. 3, March 1987, pp. 297-300

test_common;

unlink("vaidyanathan_trick_test.diary");
unlink("vaidyanathan_trick_test.diary.tmp");
diary vaidyanathan_trick_test.diary.tmp

strf="vaidyanathan_trick_test";

%
% Vaidyanathan's trick (remez has numerical problems if M>81)
%
fp=0.24;
M=80;
g=remez((2*M)+1,[0 2*fp 0.499 0.5]*2,[1 1 0 0]);
h=zeros((4*M)+3,1);
h(1:2:end)=g/2;
h((2*M)+2)=0.5;
print_polynomial(h,"h",strcat(strf,"_coef.m"));

nplot=8000;
[H,w]=freqz(h,1,nplot);
np=ceil(nplot*fp/0.5)+1;
ns=ceil(nplot*(0.5-fp)/0.5)+1;
ax=plotyy(w(1:np)*0.5/pi,20*log10(abs(H(1:np))), ...
          w(ns:end)*0.5/pi,20*log10(abs(H(ns:end))));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -0.004 0.004]);
axis(ax(2),[0 0.5 -78 -70]);
strt=sprintf("Vaidyanathan TRICK half-band filter: M=%d, N=%d, fp=%4.2f", ...
             M,(4*M)+3,fp);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Done
diary off
movefile vaidyanathan_trick_test.diary.tmp vaidyanathan_trick_test.diary;

