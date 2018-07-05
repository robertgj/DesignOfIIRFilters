% allpass_MH3dtp_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

unlink("allpass_MH3dtp_test.diary");
unlink("allpass_MH3dtp_test.diary.tmp");
diary allpass_MH3dtp_test.diary.tmp

del=1e-6;
tol=10*eps;

%
% Real poles
%
r1=-0.43;
r2=0.62;
b=conv([r1, -1],[r2, -1]);
a=conv([1, -r1],[1, -r2]);
[Hf,w]=freqz(b,a,1024);
[Tf,w]=grpdelay(b,a,1024);

[b1,b2]=allpass_MH3dtp_pole2coef(r1,r2,"real");
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_MH3dtp_coef2Abcd(b1,b2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
[bb,aa]=Abcd2tf(A,B,C,D);
if max(abs(bb((length(b)+1):end))) > tol
  error("max(abs(bb((length(b)+1):end))) > tol");
endif
bb=bb(1:length(b));
if max(abs(bb-b)) > tol
  error("max(abs(bb-b)) > tol");
endif
if max(abs(aa((length(a)+1):end))) > tol
  error("max(abs(aa((length(a)+1):end))) > tol");
endif
aa=aa(1:length(a));
if max(abs(aa-a)) > tol
  error("max(abs(aa-a)) > tol");
endif

[H,dHdw] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
if max(abs(H)-1) > tol
  error("max(abs(H)-1) > tol");
endif
P=H2P(H);
if max(abs(P-unwrap(arg(Hf)))) > tol
  error("max(P-abs(unwrap(arg(Hf)))) > tol");
endif
T=H2T(H,dHdw);
if max(abs(T-Tf)) > 3*tol
  error("max(abs(T-Tf)) > 3*tol");
endif
allpass_filter_check_gradc1c2(@allpass_MH3dtp_coef2Abcd,w,b1,b2,del,del/100);

%
% Complex poles
%
r=0.5;
theta=-3*pi/10;
b=conv([r*e^(-j*theta), -1],[r*e^(j*theta), -1]);
a=conv([1, -r*e^(-j*theta)],[1, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[Tf,w]=grpdelay(b,a,1024);

[b1,b2]=allpass_MH3dtp_pole2coef(r,theta,"complex");
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_MH3dtp_coef2Abcd(b1,b2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
[bb,aa]=Abcd2tf(A,B,C,D);
if max(abs(bb((length(b)+1):end))) > tol
  error("max(abs(bb((length(b)+1):end))) > tol");
endif
bb=bb(1:length(b));
if max(abs(bb-b)) > tol
  error("max(abs(bb-b)) > tol");
endif
if max(abs(aa((length(a)+1):end))) > tol
  error("max(abs(aa((length(a)+1):end))) > tol");
endif
aa=aa(1:length(a));
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
if max(abs(T-Tf)) > 3*tol
  error("max(abs(T-Tf)) > 3*tol");
endif
allpass_filter_check_gradc1c2(@allpass_MH3dtp_coef2Abcd,w,b1,b2,del,del/100);

%
% Simulation
%
nbits=10;
nscale=2^(nbits-1);
nsamples=2^15;
rand("seed",0xdeadbeef);
u=(rand(nsamples,1)-0.5)*nscale;
r=0.9;
theta=pi/3;
b=conv([r*e^(-j*theta), -1],[r*e^(j*theta), -1]);
a=conv([1, -r*e^(-j*theta)],[1, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[b1,b2]=allpass_MH3dtp_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_MH3dtp_coef2Abcd(b1,b2);
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
if max(abs(y-yABCD)) > 300*tol
  error("max(abs(y-yABCD)) > 300*tol");
endif
[yMH3dtp,xxMH3dtp]=allpass_MH3dtp(b1,b2,u);
if max(abs(y-yMH3dtp)) > 300*tol
  error("max(abs(y-yMH3dtp)) > 300*tol");
endif
% Check noise gain
[yMH3dtpf,xxMH3dtpf]=allpass_MH3dtp(b1,b2,u,"round");
ngMH3dtp=allpass_MH3dtp_coef2ng(b1,b2)
est_varyd=(1+ngMH3dtp)/12
varyd=var(yMH3dtp-yMH3dtpf)

% Another filter
r=0.95;
theta=pi/2;
b=conv([r*e^(-j*theta), -1],[r*e^(j*theta), -1]);
a=conv([1, -r*e^(-j*theta)],[1, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[b1,b2]=allpass_MH3dtp_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_MH3dtp_coef2Abcd(b1,b2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 10*tol
  error("max(abs(H-Hf)) > 10*tol");
endif
% Check noise gain. States 1 and 3 are multiples.
[yMH3dtp,xxMH3dtp]=allpass_MH3dtp(b1,b2,u);
[yMH3dtpf,xxMH3dtpf]=allpass_MH3dtp(b1,b2,u,"round");
ngMH3dtp=allpass_MH3dtp_coef2ng(b1,b2)
est_varyd=(1+ngMH3dtp)/12
varyd=var(yMH3dtp-yMH3dtpf)

% Done
diary off
movefile allpass_MH3dtp_test.diary.tmp allpass_MH3dtp_test.diary;
