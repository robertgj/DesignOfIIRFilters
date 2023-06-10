% allpass_AL7c_retimed_test.m
% Copyright (C) 2018-2023 Robert G. Jenssen

test_common;

delete("allpass_AL7c_retimed_test.diary");
delete("allpass_AL7c_retimed_test.diary.tmp");
diary allpass_AL7c_retimed_test.diary.tmp

del=1e-6;
tol=10*eps;

%
% Real poles
%
r1=-0.3;
r2=0.4;
b=conv([r1, 0, -1],[r2, 0, -1]);
a=conv([1, 0, -r1],[1, 0, -r2]);
[Hf,w]=freqz(b,a,1024);
[Tf,w]=delayz(b,a,1024);

[k1,k2]=allpass_AL7c_retimed_pole2coef(r1,r2,"real");
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_AL7c_retimed_coef2Abcd(k1,k2);
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
if max(abs(P-unwrap(arg(Hf)))) > tol
  error("max(abs(P-unwrap(arg(Hf)))) > tol");
endif
T=H2T(H,dHdw);
if max(abs(T-Tf)) > 2*tol
  error("max(abs(T-Tf)) > 2*tol");
endif
allpass_filter_check_gradc1c2(@allpass_AL7c_retimed_coef2Abcd, ...
                              w,k1,k2,del,del/100);

%
% Complex poles
%
r=-0.7;
theta=-pi/1.5;
b=conv([r*e^(-j*theta), 0, -1],[r*e^(j*theta), 0, -1]);
a=conv([1, 0, -r*e^(-j*theta)],[1, 0, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[Tf,w]=delayz(b,a,1024);
[k1,k2]=allpass_AL7c_retimed_pole2coef(r,theta,"complex");
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_AL7c_retimed_coef2Abcd(k1,k2);
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
  error("max(abs(H-1)) > tol");
endif
P=H2P(H);
if max(abs(P-unwrap(arg(Hf)))) > 10*tol
  error("max(abs(P-unwrap(arg(Hf)))) > 10*tol");
endif
T=H2T(H,dHdw);
if max(abs(T-Tf)) > 20*tol
  error("max(abs(T-Tf)) > 20*tol");
endif
allpass_filter_check_gradc1c2(@allpass_AL7c_retimed_coef2Abcd, ...
                              w,k1,k2,del,del/50);

%
% Simulation
%
nbits=10;
nscale=2^(nbits-1);
nsamples=2^12;
rand("seed",0xdeadbeef);
u=(rand(nsamples,1)-0.5);
u=round(nscale*u/(2*std(u)));
% Complex pole
r=0.9;
theta=pi/5;
b=conv([r*e^(-j*theta), 0, -1],[r*e^(j*theta), 0, -1]);
a=conv([1, 0, -r*e^(-j*theta)],[1, 0, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[k1,k2]=allpass_AL7c_retimed_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_AL7c_retimed_coef2Abcd(k1,k2);
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
[yAL7c_retimed,xxAL7c_retimed]=allpass_AL7c_retimed(k1,k2,u);
if max(abs(y-yAL7c_retimed)) > 500*tol
  error("max(abs(y-yAL7c_retimed)) > 500*tol");
endif
[yAL7c_retimedf,xxAL7c_retimedf]=allpass_AL7c_retimed(k1,k2,u,"round");
ngAL7c_retimed=allpass_AL7c_retimed_coef2ng(k1,k2)
est_varyd=(1+ngAL7c_retimed)/12
varyd=var(yAL7c_retimed-yAL7c_retimedf)
% Check SVF simulation
[K,W]=KW(A,B,C,D);
T=diag(sqrt(diag(K)));
[yABCDf,xxABCDf]=svf(inv(T)*A*T,inv(T)*B,C*T,D,u,"round");
if max(abs(yABCDf-yAL7c_retimedf)) > tol
  error("max(abs(yABCDf-yAL7c_retimedf)) > tol");
endif

% Another filter
r=0.99;
theta=pi/2;
b=conv([r*e^(-j*theta), 0, -1],[r*e^(j*theta), 0, -1]);
a=conv([1, 0, -r*e^(-j*theta)],[1, 0, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[k1,k2]=allpass_AL7c_retimed_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_AL7c_retimed_coef2Abcd(k1,k2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 50*tol
  error("max(abs(H-Hf)) > 50*tol");
endif
[yAL7c_retimed,xxAL7c_retimed]=allpass_AL7c_retimed(k1,k2,u);
[yAL7c_retimedf,xxAL7c_retimedf]=allpass_AL7c_retimed(k1,k2,u,"round");
ngAL7c_retimed=allpass_AL7c_retimed_coef2ng(k1,k2)
est_varyd=(1+ngAL7c_retimed)/12
varyd=var(yAL7c_retimed-yAL7c_retimedf)
% Check SVF simulation
[K,W]=KW(A,B,C,D);
T=diag(sqrt(diag(K)));
[yABCDf,xxABCDf]=svf(inv(T)*A*T,inv(T)*B,C*T,D,u,"round");
if max(abs(yABCDf-yAL7c_retimedf)) > tol
  error("max(abs(yABCDf-yAL7c_retimedf)) > tol");
endif

% Another filter
r=0.95;
theta=pi/3;
b=conv([r*e^(-j*theta), 0, -1],[r*e^(j*theta), 0, -1]);
a=conv([1, 0, -r*e^(-j*theta)],[1, 0, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[k1,k2]=allpass_AL7c_retimed_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_AL7c_retimed_coef2Abcd(k1,k2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 50*tol
  error("max(abs(H-Hf)) > 50*tol");
endif
[yAL7c_retimed,xxAL7c_retimed]=allpass_AL7c_retimed(k1,k2,u);
[yAL7c_retimedf,xxAL7c_retimedf]=allpass_AL7c_retimed(k1,k2,u,"round");
ngAL7c_retimed=allpass_AL7c_retimed_coef2ng(k1,k2)
est_varyd=(1+ngAL7c_retimed)/12
varyd=var(yAL7c_retimed-yAL7c_retimedf)
% Check SVF simulation
[K,W]=KW(A,B,C,D);
T=diag(sqrt(diag(K)));
[yABCDf,xxABCDf]=svf(inv(T)*A*T,inv(T)*B,C*T,D,u,"round");
if max(abs(yABCDf-yAL7c_retimedf)) > tol
  error("max(abs(yABCDf-yAL7c_retimedf)) > tol");
endif


% Another filter
r=0.99;
theta=0;
b=conv([r*e^(-j*theta), 0, -1],[r*e^(j*theta), 0, -1]);
a=conv([1, 0, -r*e^(-j*theta)],[1, 0, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[k1,k2]=allpass_AL7c_retimed_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_AL7c_retimed_coef2Abcd(k1,k2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 6000*tol
  error("max(abs(H-Hf)) > 6000*tol");
endif
[yAL7c_retimed,xxAL7c_retimed]=allpass_AL7c_retimed(k1,k2,u);
[yAL7c_retimedf,xxAL7c_retimedf]=allpass_AL7c_retimed(k1,k2,u,"round");
ngAL7c_retimed=allpass_AL7c_retimed_coef2ng(k1,k2)
est_varyd=(1+ngAL7c_retimed)/12
varyd=var(yAL7c_retimed-yAL7c_retimedf)
% Check SVF simulation
[K,W]=KW(A,B,C,D);
T=diag(sqrt(diag(K)));
[yABCDf,xxABCDf]=svf(inv(T)*A*T,inv(T)*B,C*T,D,u,"round");
if max(abs(yABCDf-yAL7c_retimedf)) > tol
  error("max(abs(yABCDf-yAL7c_retimedf)) > tol");
endif


% Done
diary off
movefile allpass_AL7c_retimed_test.diary.tmp allpass_AL7c_retimed_test.diary;
