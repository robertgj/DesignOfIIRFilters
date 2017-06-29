% schurOneMscale_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurOneMscale_test.diary");
unlink("schurOneMscale_test.diary.tmp");
diary schurOneMscale_test.diary.tmp

format short e

% Low-pass 1
fp=0.1;
norder=7;
[n0,d0]=ellip(norder,1,40,fp*2);
[k,S]=schurdecomp(d0)
[S1M,epsilon,p]=schurOneMscale(k,S)
c=schurexpand(n0,S1M)
[km,Sm]=schurdecomp(-d0)
[S1Mm,epsilonm,pm]=schurOneMscale(km,Sm)
cm=schurexpand(n0,S1Mm)
norm(k-km)
norm(S+Sm)
norm(c+cm)
norm(S1M+S1Mm)
norm(epsilon-epsilonm)
norm(p-pm)

% Make a quantised noise signal with standard deviation 0.25
nbits=10;
scale=2^(nbits-1);
nsamples=2^12;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u); 
u=round(u*scale);
% Filter
[yapf,yf,xxf]=schurOneMlatticeFilter(k,epsilon,p,c,u,"round");
% Check state variable std. deviation
stdxf=std(xxf)
% Repeat
rindex=[1 4 3 2 7 6 5];
[yapfr,yfr,xxfr]=schurOneMlatticeFilter(k,epsilon(rindex),p,c,u,"round");
stdxfr=std(xxfr)
% Repeat
ex43=[1 2 4 3 5 6 7];
[yapfr43,yfr43,xxfr43]=schurOneMlatticeFilter(k,epsilon(ex43),p,c,u,"round");
stdxfr43=std(xxfr43)
% Repeat
[yapfm,yfm,xxfm]=schurOneMlatticeFilter(k,-epsilon,p,c,u,"round");
stdxfm=std(xxfm)

% High-pass 1
[n0,d0]=ellip(norder,1,40,fp*2,"high");
[k,S]=schurdecomp(d0)
[S1M,epsilon,p]=schurOneMscale(k,S)
c=schurexpand(n0,S1M)
[km,Sm]=schurdecomp(-d0)
[S1Mm,epsilonm,pm]=schurOneMscale(km,Sm)
cm=schurexpand(n0,S1Mm)
norm(k-km)
norm(S+Sm)
norm(c+cm)
norm(S1M+S1Mm)
norm(epsilon-epsilonm)
norm(p-pm)

% Low-pass 2
fp=0.2;
norder=5;
[n0,d0]=ellip(norder,1,40,fp*2);
[k,S]=schurdecomp(d0)
[S1M,epsilon,p]=schurOneMscale(k,S)
c=schurexpand(n0,S1M)
[km,Sm]=schurdecomp(-d0)
[S1Mm,epsilonm,pm]=schurOneMscale(km,Sm)
cm=schurexpand(n0,S1Mm)
norm(k-km)
norm(S+Sm)
norm(c+cm)
norm(S1M+S1Mm)
norm(epsilon-epsilonm)
norm(p-pm)

% High-pass 2
[n0,d0]=ellip(norder,1,40,fp*2,"high");
[k,S]=schurdecomp(d0)
[S1M,epsilon,p]=schurOneMscale(k,S)
c=schurexpand(n0,S1M)
[km,Sm]=schurdecomp(-d0)
[S1Mm,epsilonm,pm]=schurOneMscale(km,Sm)
cm=schurexpand(n0,S1Mm)
norm(k-km)
norm(S+Sm)
norm(c+cm)
norm(S1M+S1Mm)
norm(epsilon-epsilonm)
norm(p-pm)



% Done
diary off
movefile schurOneMscale_test.diary.tmp schurOneMscale_test.diary;
