% saramakiFAvLogNewton_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

unlink("saramakiFAvLogNewton_test.diary");
unlink("saramakiFAvLogNewton_test.diary.tmp");
diary saramakiFAvLogNewton_test.diary.tmp

% Filter specification
n=11,m=6,fp=0.1,fs=0.125,dBap=0.002,dBas=75
nplot=4000;
nfp=ceil(fp*nplot/0.5)+1;
nfs=floor(fs*nplot/0.5)+1;

% Find filter
if 1
  [z,p,K,iter]=saramakiFAvLogNewton(n,m,fp,fs,[],dBas)
else
  [z,p,K,iter]=saramakiFAvLogNewton(n,m,fp,fs,dBap)
endif
if any(abs(p))>1
  error("any(abs(p))>1");
endif
[b,a]=zp2tf(z,p,K);

% Calculate response
[h,w]=freqz(b,a,nplot);

% Check dBap, dBas
max_dBap=max(20*log10(abs(h(1:nfp))));
min_dBap=min(20*log10(abs(h(1:nfp))));
max_dBas=0-max(20*log10(abs(h(nfs:end))));
printf("n=%2d,m=%d,max_dBap=%8.6f,min_dBap=%8.6f,max_dBas=%6.2f\n", ...
       n,m,max_dBap,min_dBap,max_dBas);

% Plot response
ax=plotyy(w(1:nfp)*0.5/pi,20*log10(abs(h(1:nfp))), ...
          w(nfs:end)*0.5/pi,20*log10(abs(h(nfs:end))));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -0.002 0]);
axis(ax(2),[0 0.5 10*ceil(-max_dBas/10)+[-20 0]]);
strt="Saramaki n>=m filter response";
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
strf="saramakiFAvLogNewton_test";
print(strcat(strf,"_resp"),"-dpdflatex");
close

% Show zplane
zplane(z,p);
strt="Saramaki n>=m filter";
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Check dBap and dBas
printf("Setting dBap=%8.6f\n",dBap);
for m=3:8,
  for n=m+(0:6),
    [z,p,K,iter]=saramakiFAvLogNewton(n,m,fp,fs,dBap);
    if any(abs(p))>1
      error("any(abs(p))>1");
    endif
    [b,a]=zp2tf(z,p,K);
    [h,w]=freqz(b,a,nplot);
    max_dBap=max(20*log10(abs(h(1:nfp))))-min(20*log10(abs(h(1:nfp))));
    max_dBas=0-max(20*log10(abs(h(nfs:end))));
    printf("n=%2d,m=%d,max_dBap=%8.6f,max_dBas=%6.2f\n",n,m,max_dBap,max_dBas);
  endfor
endfor
printf("Setting dBas=%6.2f\n",dBas);
for m=3:8,
  for n=m+(0:6),
    [z,p,K,iter]=saramakiFAvLogNewton(n,m,fp,fs,[],dBas); 
    if any(abs(p))>1
      error("any(abs(p))>1");
    endif
    [b,a]=zp2tf(z,p,K);
    [h,w]=freqz(b,a,nplot);
    max_dBap=max(20*log10(abs(h(1:nfp))))-min(20*log10(abs(h(1:nfp))));
    max_dBas=0-max(20*log10(abs(h(nfs:end))));
    printf("n=%2d,m=%d,max_dBap=%8.6f,max_dBas=%6.2f\n",n,m,max_dBap,max_dBas);
  endfor
endfor

% Done
diary off
movefile saramakiFAvLogNewton_test.diary.tmp saramakiFAvLogNewton_test.diary;
