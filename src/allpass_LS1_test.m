% allpass_LS1_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

unlink("allpass_LS1_test.diary");
unlink("allpass_LS1_test.diary.tmp");
diary allpass_LS1_test.diary.tmp

del=1e-6;
tol=10*eps;

%
% Real pole
%
r1=0.99;
b=[-r1, 1];
a=[1, -r1];
[Hf,w]=freqz(b,a,1024);
[Tf,w]=grpdelay(b,a,1024);

c1=allpass_LS1_pole2coef(r1);
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_LS1_coef2Abcd(c1);
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
if max(abs(H)-1) > 3*tol
  error("max(abs(H)-1) > 3*tol");
endif
P=H2P(H);
if max(abs(P-unwrap(arg(Hf)))) > 2*tol
  error("max(abs(P-unwrap(arg(Hf)))) > 2*tol");
endif
T=H2T(H,dHdw);
if max(abs(T-Tf)) > 70000*tol
  error("max(abs(T-Tf)) > 70000*tol");
endif
allpass_filter_check_gradc1(@allpass_LS1_coef2Abcd,w,c1,del,60*del);


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
c1=allpass_LS1_pole2coef(r1);
[A,B,C,D]=allpass_LS1_coef2Abcd(c1);
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
[yLS1,xxLS1]=allpass_LS1(c1,u);
if max(abs(y-yLS1)) > 500*tol
  error("max(abs(y-yLS1)) > 500*tol");
endif
[yLS1f,xxLS1f]=allpass_LS1(c1,u,"round");
ngLS1=allpass_LS1_coef2ng(c1)
est_varyd=(1+ngLS1)/12
varyd=var(yLS1-yLS1f)

% Another filter
r=0.99;
b=[-r1, 1];
a=[1, -r1];
[Hf,w]=freqz(b,a,1024);
c1=allpass_LS1_pole2coef(r1);
[A,B,C,D]=allpass_LS1_coef2Abcd(c1);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 20*tol
  error("max(abs(H-Hf)) > 20*tol");
endif
[yLS1,xxLS1]=allpass_LS1(c1,u);
[yLS1f,xxLS1f]=allpass_LS1(c1,u,"round");
ngLS1=allpass_LS1_coef2ng(c1)
est_varyd=(1+ngLS1)/12
varyd=var(yLS1-yLS1f)

% Check noise gain
for r=9:10:99
  r1=r/100;
  b=[-r1, 1];
  a=[1, -r1];
  [Hf,w]=freqz(b,a,1024);
  b1=allpass_LS1_pole2coef(r1);
  [A,B,C,D]=allpass_LS1_coef2Abcd(b1);
  if rank([A,B])~=rows(A)
    printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
  endif
  H=Abcd2H(w,A,B,C,D);
  if max(abs(Hf-H)) > 30*tol
    error("max(abs(H-Hf)) > 30*tol");
  endif
  [yLS1,xxLS1]=allpass_LS1(b1,u);
  [yLS1f,xxLS1f]=allpass_LS1(b1,u,"round");
  ngLS1=allpass_LS1_coef2ng(b1);
  est_varyd=(1+ngLS1)/12;
  varyd=var(yLS1-yLS1f);
  printf("r1=%f,ngLS1=%f,est_varyd=%f,varyd=%f\n",r1,ngLS1,est_varyd,varyd);
endfor

% Done
diary off
movefile allpass_LS1_test.diary.tmp allpass_LS1_test.diary;
