% allpass_IS_test.m
% Copyright (C) 2018 Robert G. Jenssen

test_common;

unlink("allpass_IS_test.diary");
unlink("allpass_IS_test.diary.tmp");
diary allpass_IS_test.diary.tmp

del=1e-6;
tol=10*eps;

%
% Real poles
%
r1=0.13;
r2=-0.42;
b=conv([r1, -1],[r2, -1]);
a=conv([1, -r1],[1, -r2]);
[Hf,w]=freqz(b,a,1024);
[Tf,w]=grpdelay(b,a,1024);

[d1,d2]=allpass_IS_pole2coef(r1,r2,"real");
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_IS_coef2Abcd(d1,d2);
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
if max(abs(T-Tf)) > 2*tol
  error("max(abs(T-Tf)) > 2*tol");
endif
allpass_filter_check_gradc1c2(@allpass_IS_coef2Abcd,w,d1,d2,del,del/200);

%
% Complex poles
%
r=0.1;
theta=-pi/5;
b=conv([r*e^(-j*theta), -1],[r*e^(j*theta), -1]);
a=conv([1, -r*e^(-j*theta)],[1, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[Tf,w]=grpdelay(b,a,1024);

[d1,d2]=allpass_IS_pole2coef(r,theta,"complex");
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_IS_coef2Abcd(d1,d2);
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
if max(abs(T-Tf)) > 3*tol
  error("max(abs(T-Tf)) > 3*tol");
endif
allpass_filter_check_gradc1c2(@allpass_IS_coef2Abcd,w,d1,d2,del,del/300);

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
b=conv([r*e^(-j*theta), -1],[r*e^(j*theta), -1]);
a=conv([1, -r*e^(-j*theta)],[1, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[d1,d2]=allpass_IS_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_IS_coef2Abcd(d1,d2);
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
[yIS,xxIS]=allpass_IS(d1,d2,u);
if max(abs(y-yIS)) > 500*tol
  error("max(abs(y-yIS)) > 500*tol");
endif
[yISf,xxISf]=allpass_IS(d1,d2,u,"round");
ngIS=allpass_IS_coef2ng(d1,d2)
est_varyd=(1+ngIS)/12
varyd=var(yIS-yISf)

% Another filter
r=0.1;
theta=pi/2;
b=conv([r*e^(-j*theta), -1],[r*e^(j*theta), -1]);
a=conv([1, -r*e^(-j*theta)],[1, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[d1,d2]=allpass_IS_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_IS_coef2Abcd(d1,d2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 30*tol
  error("max(abs(H-Hf)) > 30*tol");
endif
[yIS,xxIS]=allpass_IS(d1,d2,u);
[yISf,xxISf]=allpass_IS(d1,d2,u,"round");
ngIS=allpass_IS_coef2ng(d1,d2)
est_varyd=(1+ngIS)/12
varyd=var(yIS-yISf)

% Done
diary off
movefile allpass_IS_test.diary.tmp allpass_IS_test.diary;
