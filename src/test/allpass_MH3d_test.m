% allpass_MH3d_test.m
% Copyright (C) 2018-2025 Robert G. Jenssen

test_common;

delete("allpass_MH3d_test.diary");
delete("allpass_MH3d_test.diary.tmp");
diary allpass_MH3d_test.diary.tmp

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
[Tf,w]=delayz(b,a,1024);

[b1,b2]=allpass_MH3d_pole2coef(r1,r2,"real");
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_MH3d_coef2Abcd(b1,b2);
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
allpass_filter_check_gradc1c2(@allpass_MH3d_coef2Abcd,w,b1,b2,del,del/200);

%
% Complex poles
%
r=0.5;
theta=-3*pi/10;
b1=2*r*cos(theta);
b2=r*r;
b=conv([r*e^(-j*theta), -1],[r*e^(j*theta), -1]);
a=conv([1, -r*e^(-j*theta)],[1, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[Tf,w]=delayz(b,a,1024);

[b1,b2]=allpass_MH3d_pole2coef(r,theta,"complex");
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_MH3d_coef2Abcd(b1,b2);
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
if max(abs(P-unwrap(arg(Hf)))) > 2*tol
  error("max(abs(P-unwrap(arg(Hf)))) > 2*tol");
endif
T=H2T(H,dHdw);
if max(abs(T-Tf)) > 3*tol
  error("max(abs(T-Tf)) > 3*tol");
endif
allpass_filter_check_gradc1c2(@allpass_MH3d_coef2Abcd,w,b1,b2,del,del/400);

%
% Simulation
%
nbits=10;
nscale=2^(nbits-1);
nsamples=2^15;
rand("seed",0xdeadbeef);
u=(rand(nsamples,1)-0.5);
u=round(nscale*u/(2*std(u)));
r=0.9;
theta=pi/5;
b=conv([r*e^(-j*theta), -1],[r*e^(j*theta), -1]);
a=conv([1, -r*e^(-j*theta)],[1, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[b1,b2]=allpass_MH3d_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_MH3d_coef2Abcd(b1,b2);
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
[yMH3d,xxMH3d]=allpass_MH3d(b1,b2,u);
if max(abs(y-yMH3d)) > 500*tol
  error("max(abs(y-yMH3d)) > 500*tol");
endif

% Check noise gain
[yMH3df,xxMH3df]=allpass_MH3d(b1,b2,u,"round");
ngMH3d=allpass_MH3d_coef2ng(b1,b2)
est_varyd=(1+ngMH3d)/12
varyd=var(yMH3d-yMH3df)

% Try a different filter
r=0.98;
theta=pi/2;
b=conv([r*e^(-j*theta), -1],[r*e^(j*theta), -1]);
a=conv([1, -r*e^(-j*theta)],[1, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[b1,b2]=allpass_MH3d_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_MH3d_coef2Abcd(b1,b2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 10*tol
  error("max(abs(H-Hf)) > 10*tol");
endif
% Check noise gain
[yMH3d,xxMH3d]=allpass_MH3d(b1,b2,u,"none");
[yMH3df,xxMH3df]=allpass_MH3d(b1,b2,u,"round");
ngMH3d=allpass_MH3d_coef2ng(b1,b2)
est_varyd=(1+ngMH3d)/12
varyd=var(yMH3d-yMH3df)

% Done
diary off
movefile allpass_MH3d_test.diary.tmp allpass_MH3d_test.diary;
