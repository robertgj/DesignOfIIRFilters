% saramakiFBvNewton_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

unlink("saramakiFBvNewton_test.diary");
unlink("saramakiFBvNewton_test.diary.tmp");
diary saramakiFBvNewton_test.diary.tmp

maxiter=1000;
tol=1e-5;
nplot=1000;

% Filter specification
n=6,m=9,fp=0.2,fs=0.35,dBap=0.1
nfp=ceil(fp*nplot/0.5)+1;
nfs=floor(fs*nplot/0.5)+1;
strf="saramakiFBvNewton_test";

% Design filter
[Z,P,K,dBas,iter]=saramakiFBvNewton(n,m,fp,fs,dBap);

% Calculate response
[num,den]=zp2tf(Z,P,K);
print_polynomial(num,"n",strcat(strf,"_n_coef.m"),"%15.10f");
print_polynomial(den,"d",strcat(strf,"_d_coef.m"),"%15.10f");

% Plot response
[h,w]=freqz(num,den,nplot);
max_dBas=max(20*log10(abs(h(nfs:end))));
ax=plotyy(w(1:nfp)*0.5/pi,20*log10(abs(h(1:nfp))), ...
          w(nfs:end)*0.5/pi,20*log10(abs(h(nfs:end))));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -0.15 0.05]);
axis(ax(2),[0 0.5 10*ceil(max_dBas/10)+[-20 0]]);
strt="Saramaki n<m filter response";
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_resp"),"-dpdflatex");
close

% Plot zeros and poles
zplane(Z,P);
strt="Saramaki n<m filter";
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Check dBas
for n=6:7
  for m=n+(1:4)
    [Z,P,K,iter]=saramakiFBvNewton(n,m,fp,fs,dBap);
    if any(abs(P))>1
      error("any(abs(P))>1");
    endif
    [b,a]=zp2tf(Z,P,K);
    [h,w]=freqz(b,a,nplot);
    max_dBap=max(20*log10(abs(h(1:nfp))));
    min_dBap=min(20*log10(abs(h(1:nfp))));
    max_dBas=max(20*log10(abs(h(nfs:end))));
    printf("n=%2d,m=%d,max_dBap=%8.6f,min_dBap=%8.6f,max_dBas=%6.2f\n",
           n,m,max_dBap,min_dBap,max_dBas);
  endfor
endfor

% Done
diary off
movefile saramakiFBvNewton_test.diary.tmp saramakiFBvNewton_test.diary;
