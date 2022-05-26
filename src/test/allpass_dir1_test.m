% allpass_dir1_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

delete("allpass_dir1_test.diary");
delete("allpass_dir1_test.diary.tmp");
diary allpass_dir1_test.diary.tmp

del=1e-6;
tol=5*eps;

%
% Real pole
%
r1=-0.13;
b=[-r1, 1];
a=[1, -r1];
[Hf,w]=freqz(b,a,1024);
[Tf,w]=grpdelay(b,a,1024);

b1=allpass_dir1_pole2coef(r1);
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_dir1_coef2Abcd(b1);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
[bb,aa]=Abcd2tf(A,B,C,D);
if max(abs(bb-b)) > tol
  error("max(abs(bb-b)) > tol");
endif
if max(abs(aa-a)) > tol
  error("max(abs(aa-a)) > tol");
endif

[H,dHdw] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
if max(abs(H)-1) > tol
  error("max(abs(H)-1) > tol");
endif
P=H2P(H);
if max(abs(P-unwrap(arg(Hf)))) > tol
  error("max(abs(P-unwrap(arg(Hf)))) > tol");
endif
T=H2T(H,dHdw);
if max(abs(T-Tf)) > tol
  error("max(abs(T-Tf)) > tol");
endif
allpass_filter_check_gradc1(@allpass_dir1_coef2Abcd,w,b1,del,del/1000);

%
% Simulation
%
nbits=10;
nscale=2^(nbits-1);
nsamples=2^12;
rand("seed",0xdeadbeef);
u=(rand(nsamples,1)-0.5);
u=round(nscale*u/(2*std(u)));
r1=0.2;
b=[-r1, 1];
a=[1, -r1];
[Hf,w]=freqz(b,a,1024);
b1=allpass_dir1_pole2coef(r1);
[A,B,C,D]=allpass_dir1_coef2Abcd(b1);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 10*tol
  error("max(abs(H-Hf)) > 10*tol");
endif
[bb,aa]=Abcd2tf(A,B,C,D);
if max(abs(bb-b)) > tol
  error("max(abs(bb-b)) > tol");
endif
if max(abs(aa-a)) > tol
  error("max(abs(aa-a)) > tol");
endif
y=filter(b,a,u);
[yABCD,xxABCD]=svf(A,B,C,D,u,"none");
if max(abs(y-yABCD)) > 500*tol
  error("max(abs(y-yABCD)) > 500*tol");
endif
% Check noise gain
[ydir1,xxdir1]=allpass_dir1(b1,u);
if max(abs(y-ydir1)) > 500*tol
  error("max(abs(y-ydir1)) > 500*tol");
endif
[ydir1f,xxdir1f]=allpass_dir1(b1,u,"round");
ngdir1=allpass_dir1_coef2ng(b1)
est_varyd=(1+ngdir1)/12
varyd=var(ydir1-ydir1f)

% Another filter
r=0.99;
b=[-r1, 1];
a=[1, -r1];
[Hf,w]=freqz(b,a,1024);
b1=allpass_dir1_pole2coef(r1);
[A,B,C,D]=allpass_dir1_coef2Abcd(b1);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 20*tol
  error("max(abs(H-Hf)) > 20*tol");
endif
[ydir1,xxdir1]=allpass_dir1(b1,u);
[ydir1f,xxdir1f]=allpass_dir1(b1,u,"round");
ngdir1=allpass_dir1_coef2ng(b1)
est_varyd=(1+ngdir1)/12
varyd=var(ydir1-ydir1f)

% Check noise gain
for r=9:10:99
  r1=r/100;
  b=[-r1, 1];
  a=[1, -r1];
  [Hf,w]=freqz(b,a,1024);
  b1=allpass_dir1_pole2coef(r1);
  [A,B,C,D]=allpass_dir1_coef2Abcd(b1);
  if rank([A,B])~=rows(A)
    printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
  endif
  H=Abcd2H(w,A,B,C,D);
  if max(abs(Hf-H)) > 30*tol
    error("max(abs(H-Hf)) > 30*tol");
  endif
  [ydir1,xxdir1]=allpass_dir1(b1,u);
  [ydir1f,xxdir1f]=allpass_dir1(b1,u,"round");
  ngdir1=allpass_dir1_coef2ng(b1);
  est_varyd=(1+ngdir1)/12;
  varyd=var(ydir1-ydir1f);
  printf("r1=%f,ngdir1=%f,est_varyd=%f,varyd=%f\n",r1,ngdir1,est_varyd,varyd);
endfor

% Done
diary off
movefile allpass_dir1_test.diary.tmp allpass_dir1_test.diary;
