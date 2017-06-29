% schurNSscale_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("schurNSscale_test.diary");
unlink("schurNSscale_test.diary.tmp");
diary schurNSscale_test.diary.tmp

format short e

% Catch errors
try
  [s10,s11,s20,s00,s02,s22] = schurNSscale(1,[])
catch
  printf("Caught schurNSscale([],1)!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch
try
  [s10,s11,s20,s00,s02,s22] = schurNSscale(1,[1]);
catch
  printf("Caught schurNSscale([1 1],[1 1])!\n");
  err=lasterror();
  printf("%s\n", err.message);
end_try_catch

% No filter
[s10,s11,s20,s00,s02,s22] = schurNSscale([],1)

% Low-pass order 1
norder=1;
fpass=0.2;
[n0,d0]=butter(norder,fpass*2);
[k,S]=schurdecomp(d0)
c=schurexpand(n0,S)
[s10,s11,s20,s00,s02,s22] = schurNSscale(k,c)

% Low-pass fpass=0.2
norder=7;
fpass=0.2;
dBpass=0.5;
dBstop=60;
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2);
[k,S]=schurdecomp(d0)
c=schurexpand(n0,S)
[s10,s11,s20,s00,s02,s22] = schurNSscale(k,c)
[km,Sm]=schurdecomp(-d0)
cm=schurexpand(n0,Sm)
[s10m,s11m,s20m,s00m,s02m,s22m] = schurNSscale(km,cm)
norm(k-km)
norm(S+Sm)
norm(c+cm)
norm(s10+s10m)
norm(s11-s11m)+(2*s11(1))
norm(s20-s20m)
norm(s00-s00m)
norm(s02-s02m)
norm(s22-s22m)
% Make a quantised noise signal with standard deviation 0.25
nbits=10;
scale=2^(nbits-1);
nsamples=2^12;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u); 
u=round(u*scale);
% Filter
[yapf,yf,xxf]=schurNSlatticeFilter(s10,s11,s20,s00,s02,s22,u,"round");
% Check state variable std. deviation
stdxf=std(xxf)

% High-pass fpass=0.2
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2,"high");
[k,S]=schurdecomp(d0)
[k,S]=schurdecomp(d0)
c=schurexpand(n0,S)
[s10,s11,s20,s00,s02,s22] = schurNSscale(k,c)
[km,Sm]=schurdecomp(-d0)
cm=schurexpand(n0,Sm)
[s10m,s11m,s20m,s00m,s02m,s22m] = schurNSscale(km,cm)
norm(k-km)
norm(S+Sm)
norm(c+cm)
norm(s10+s10m)
norm(s11-s11m)+(2*s11(1))
norm(s20-s20m)
norm(s00-s00m)
norm(s02-s02m)
norm(s22-s22m)

% Low-pass fpass=0.1
fpass=0.1;
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2);
[k,S]=schurdecomp(d0)
c=schurexpand(n0,S)
[s10,s11,s20,s00,s02,s22] = schurNSscale(k,c)
[km,Sm]=schurdecomp(-d0)
cm=schurexpand(n0,Sm)
[s10m,s11m,s20m,s00m,s02m,s22m] = schurNSscale(km,cm)
norm(k-km)
norm(S+Sm)
norm(c+cm)
norm(s10+s10m)
norm(s11-s11m)+(2*s11(1))
norm(s20-s20m)
norm(s00-s00m)
norm(s02-s02m)
norm(s22-s22m)

% High-pass fpass=0.1
[n0,d0]=ellip(norder,dBpass,dBstop,fpass*2,"high");
[k,S]=schurdecomp(d0)
c=schurexpand(n0,S)
[s10,s11,s20,s00,s02,s22] = schurNSscale(k,c)
[km,Sm]=schurdecomp(-d0)
cm=schurexpand(n0,Sm)
[s10m,s11m,s20m,s00m,s02m,s22m] = schurNSscale(km,cm)
norm(k-km)
norm(S+Sm)
norm(c+cm)
norm(s10+s10m)
norm(s11-s11m)-(2*s11(1))
norm(s20-s20m)
norm(s00-s00m)
norm(s02-s02m)
norm(s22-s22m)

% Done
diary off
movefile schurNSscale_test.diary.tmp schurNSscale_test.diary;
