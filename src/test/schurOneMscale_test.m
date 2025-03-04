% schurOneMscale_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("schurOneMscale_test.diary");
delete("schurOneMscale_test.diary.tmp");
diary schurOneMscale_test.diary.tmp


% epsilon only
k =[ 0.5530909  -0.1250394   0.0415215  -0.0135149   0.0023471];
epsilon=schurOneMscale(k)
[epsilon,p]=schurOneMscale(k)

% Low-pass 1
clear all
fp=0.1;
norder=7;
[n0,d0]=ellip(norder,1,40,fp*2);
[k,S]=schurdecomp(d0)
[epsilon,p,S1M]=schurOneMscale(k,S)
c=schurexpand(n0,S1M)
[km,Sm]=schurdecomp(-d0)
[epsilonm,pm,S1Mm]=schurOneMscale(km,Sm)
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
[epsilon,p,S1M]=schurOneMscale(k,S)
c=schurexpand(n0,S1M)
[km,Sm]=schurdecomp(-d0)
[epsilonm,pm,S1Mm]=schurOneMscale(km,Sm)
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
[epsilon,p,S1M]=schurOneMscale(k,S)
c=schurexpand(n0,S1M)
[km,Sm]=schurdecomp(-d0)
[epsilonm,pm,S1Mm]=schurOneMscale(km,Sm)
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
[epsilon,p,S1M]=schurOneMscale(k,S)
c=schurexpand(n0,S1M)
[km,Sm]=schurdecomp(-d0)
[epsilonm,pm,S1Mm]=schurOneMscale(km,Sm)
cm=schurexpand(n0,S1Mm)
norm(k-km)
norm(S+Sm)
norm(c+cm)
norm(S1M+S1Mm)
norm(epsilon-epsilonm)
norm(p-pm)

% Low-pass 3
fp=0.05;
norder=6;
[n0,d0]=ellip(norder,1,40,fp*2);
[k,S]=schurdecomp(d0)
[epsilon,p,S1M]=schurOneMscale(k,S)
c=schurexpand(n0,S1M)
[n1,d1]=schurOneMlattice2tf(k,epsilon,p,c);
if max(abs(n0-n1))>eps
  error("max(abs(n0-n1))>eps");
endif
if max(abs(d0-d1))>10*eps
  error("max(abs(d0-d1))>10*eps");
endif
[epsilonf,pf,S1Mf]=schurOneMscale(k,S,ones(size(k)))
cf=schurexpand(n0,S1Mf)
[n1f,d1f]=schurOneMlattice2tf(k,epsilonf,pf,cf);
if max(abs(n0-n1f))>eps
  error("max(abs(n0-n1f))>eps");
endif
if max(abs(d0-d1f))>10*eps
  error("max(abs(d0-d1f))>10*eps");
endif

% Done
diary off
movefile schurOneMscale_test.diary.tmp schurOneMscale_test.diary;
