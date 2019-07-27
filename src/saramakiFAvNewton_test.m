% saramakiFAvNewton_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

unlink("saramakiFAvNewton_test.diary");
unlink("saramakiFAvNewton_test.diary.tmp");
diary saramakiFAvNewton_test.diary.tmp

% Filter specification
n=6,m=5,fp=0.1,fs=0.2,dBap=0.01
[z,p,K,dBas,iter]=saramakiFAvNewton(n,m,fp,fs,dBap)

% Show response
[b,a]=zp2tf(z,p,K)
nplot=1024;
nfp=ceil(fp*nplot/0.5)+1;
na=nfp+1;
[h,w]=freqz(b,a,nplot);
ax=plotyy(w(1:nfp)*0.5/pi,20*log10(abs(h(1:nfp))), ...
          w(na:end)*0.5/pi,20*log10(abs(h(na:end))));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -2*dBap 2*dBap]);
axis(ax(2),[0 0.5 -80 -60]);
strt="Saram\\\"{a}ki n>=m filter response";
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
strf="saramakiFAvNewton_test";
print(strcat(strf,"_resp"),"-dpdflatex");
close

% Show zplane
zplane(z,p);
strt="Saram\\\"{a}ki n>=m filter";
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Done
diary off
movefile saramakiFAvNewton_test.diary.tmp saramakiFAvNewton_test.diary;
