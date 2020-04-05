% allpass_dir2_retimed_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

delete("allpass_dir2_retimed_test.diary");
delete("allpass_dir2_retimed_test.diary.tmp");
diary allpass_dir2_retimed_test.diary.tmp

del=1e-6;
tol=10*eps;

%
% Real poles
%
r1=-0.13;
r2=-0.42;
b=conv([r1, 0, -1],[r2, 0, -1]);
a=conv([1, 0, -r1],[1, 0, -r2]);
[Hf,w]=freqz(b,a,1024);
[Tf,w]=grpdelay(b,a,1024);

[b1,b2]=allpass_dir2_retimed_pole2coef(r1,r2,"real");
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_dir2_retimed_coef2Abcd(b1,b2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
[bb,aa]=Abcd2tf(A,B,C,D);
bb=bb(1:length(b));
if max(abs(bb-b)) > tol
  error("max(abs(bb-b)) > tol");
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
if max(abs(T-Tf)) > 10*tol
  error("max(abs(T-Tf)) > 10*tol");
endif
allpass_filter_check_gradc1c2(@allpass_dir2_retimed_coef2Abcd, ...
                              w,b1,b2,del,del/100);

%
% Complex poles
%
r=0.95;
theta=-9*pi/10;
b=conv([r*e^(-j*theta), 0, -1],[r*e^(j*theta), 0, -1]);
a=conv([1, 0, -r*e^(-j*theta)],[1, 0, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[Tf,w]=grpdelay(b,a,1024);

[b1,b2]=allpass_dir2_retimed_pole2coef(r,theta,"complex");
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_dir2_retimed_coef2Abcd(b1,b2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
[bb,aa]=Abcd2tf(A,B,C,D);
bb=bb(1:length(b));
if max(abs(bb-b)) > tol
  error("max(abs(bb-b)) > tol");
endif
aa=aa(1:length(a));
if max(abs(aa-a)) > tol
  error("max(abs(aa-a)) > tol");
endif

[H,dHdw] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
if max(abs(H)-1) > 10*tol
  error("max(abs(H)-1) > 10*tol");
endif
P=H2P(H);
if max(abs(P-unwrap(arg(Hf)))) > 20*tol
  error("max(abs(P-unwrap(arg(Hf)))) > 20*tol");
endif
T=H2T(H,dHdw);
if max(abs(T-Tf)) > 70000*tol
  error("max(abs(T-Tf)) > 70000*tol");
endif
allpass_filter_check_gradc1c2(@allpass_dir2_retimed_coef2Abcd, ...
                              w,b1,b2,del,2*del);

%
% Simulation
%
nbits=10;
nscale=2^(nbits-1);
nsamples=2^12;
rand("seed",0xdeadbeef);
u=(rand(nsamples,1)-0.5);
u=round(nscale*u/(2*std(u)));
r=0.9;
theta=pi/5;
b=conv([r*e^(-j*theta), 0, -1],[r*e^(j*theta), 0, -1]);
a=conv([1, 0, -r*e^(-j*theta)],[1, 0, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[b1,b2]=allpass_dir2_retimed_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_dir2_retimed_coef2Abcd(b1,b2);
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
aa=aa(1:length(a));
if max(abs(aa-a)) > tol
  error("max(abs(aa-a)) > tol");
endif
y=filter(b,a,u);
[yABCD,xxABCD]=svf(A,B,C,D,u,"none");
if max(abs(y-yABCD)) > 500*tol
  error("max(abs(y-yABCD)) > 500*tol");
endif
% Check noise gain
[ydir2_retimed,xxdir2_retimed]=allpass_dir2_retimed(b1,b2,u);
if max(abs(y-ydir2_retimed)) > 500*tol
  error("max(abs(y-ydir2_retimed)) > 500*tol");
endif
[ydir2_retimedf,xxdir2_retimedf]=allpass_dir2_retimed(b1,b2,u,"round");
ngdir2_retimed=allpass_dir2_retimed_coef2ng(b1,b2)
est_varyd=(1+ngdir2_retimed)/12
varyd=var(ydir2_retimed-ydir2_retimedf)

% Another filter
r=0.99;
theta=pi/2;
b=conv([r*e^(-j*theta), 0, -1],[r*e^(j*theta), 0, -1]);
a=conv([1, 0, -r*e^(-j*theta)],[1, 0, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[b1,b2]=allpass_dir2_retimed_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_dir2_retimed_coef2Abcd(b1,b2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 50*tol
  error("max(abs(H-Hf)) > 50*tol");
endif
[ydir2_retimed,xxdir2_retimed]=allpass_dir2_retimed(b1,b2,u);
[ydir2_retimedf,xxdir2_retimedf]=allpass_dir2_retimed(b1,b2,u,"round");
ngdir2_retimed=allpass_dir2_retimed_coef2ng(b1,b2)
est_varyd=(1+ngdir2_retimed)/12
varyd=var(ydir2_retimed-ydir2_retimedf)


% Done
diary off
movefile allpass_dir2_retimed_test.diary.tmp allpass_dir2_retimed_test.diary;
