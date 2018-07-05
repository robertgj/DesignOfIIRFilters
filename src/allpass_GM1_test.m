% allpass_GM1_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

unlink("allpass_GM1_test.diary");
unlink("allpass_GM1_test.diary.tmp");
diary allpass_GM1_test.diary.tmp

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

k1=allpass_GM1_pole2coef(r1);
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_GM1_coef2Abcd(k1);
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
allpass_filter_check_gradc1(@allpass_GM1_coef2Abcd,w,k1,del,del/900);

% Check e1
for e1=-1:2:1
    [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_GM1_coef2Abcd(k1,e1);
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

    [H,dHdw,dHdx,d2Hdwdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
    if max(abs(H)-1) > tol
      error("max(abs(H)-1) > tol");
    endif
    P=H2P(H,dHdx);
    if max(abs(P-unwrap(arg(Hf)))) > tol
      error("max(abs(P-unwrap(arg(Hf)))) > tol");
    endif
    T=H2T(H,dHdw,dHdx,d2Hdwdx);
    if max(abs(T-Tf)) > tol
      error("max(abs(T-Tf)) > tol");
    endif
    allpass_filter_check_gradc1(@allpass_GM1_coef2Abcd,w,k1,del,del/900);
endfor

%
% Simulation
%
nbits=10;
nscale=2^(nbits-1);
nsamples=2^15;
rand("seed",0xdeadbeef);
u=(rand(nsamples,1)-0.5);
u=round(nscale*u/(2*std(u)));
% Real pole
r1=0.9;
b=[-r1, 1];
a=[1, -r1];
[Hf,w]=freqz(b,a,1024);
k1=allpass_GM1_pole2coef(r1);
[A,B,C,D]=allpass_GM1_coef2Abcd(k1);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 10*tol
  error("max(abs(H-Hf)) > 10*tol");
endif
[bb,aa]=Abcd2tf(A,B,C,D);
bb=bb(1:length(b));
if max(abs(bb-b)) > tol
  error("max(abs(bb-b)) > tol");
endif
aa=a(1:length(a));
if max(abs(aa-a)) > tol
  error("max(abs(aa-a)) > tol");
endif
y=filter(b,a,u);
[yABCD,xxABCD]=svf(A,B,C,D,u,"none");
if max(abs(y-yABCD)) > 500*tol
  error("max(abs(y-yABCD)) > 500*tol");
endif
[yGM1,xxGM1]=allpass_GM1(k1,u);
if max(abs(y-yGM1)) > 500*tol
  error("max(abs(y-yGM1)) > 500*tol");
endif

% Check noise gain
[yGM1f,xxGM1f]=allpass_GM1(k1,u,"round");
ngGM1=allpass_GM1_coef2ng(k1)
est_varyd=(1+ngGM1)/12
varyd=var(yGM1-yGM1f)

% Try a different filter
r1=0.98;
b=[-r1, 1];
a=[1, -r1];
[Hf,w]=freqz(b,a,1024);
k1=allpass_GM1_pole2coef(r1);
e1=-1;
[A,B,C,D]=allpass_GM1_coef2Abcd(k1,e1);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 10*tol
  error("max(abs(H-Hf)) > 10*tol");
endif
% Check noise gain
[yGM1,xxGM1]=allpass_GM1(k1,e1,u,"none");
[yGM1f,xxGM1f]=allpass_GM1(k1,e1,u,"round");
ngGM1=allpass_GM1_coef2ng(k1,e1)
est_varyd=(1+ngGM1)/12
varyd=var(yGM1-yGM1f)

% Done
diary off
movefile allpass_GM1_test.diary.tmp allpass_GM1_test.diary;
