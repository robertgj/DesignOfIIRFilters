% allpass_LS2a_test.m
% Copyright (C) 2018-2023 Robert G. Jenssen

test_common;

delete("allpass_LS2a_test.diary");
delete("allpass_LS2a_test.diary.tmp");
diary allpass_LS2a_test.diary.tmp

del=1e-6;
tol=10*eps;

%
% Real poles
%
r1=0.3;
r2=-0.4;
b=conv([r1, -1],[r2, -1]);
a=conv([1, -r1],[1, -r2]);
[Hf,w]=freqz(b,a,1024);
[Tf,w]=delayz(b,a,1024);

[c1,c2]=allpass_LS2a_pole2coef(r1,r2,"real");
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_LS2a_coef2Abcd(c1,c2);
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
  error("max(P-abs(unwrap(arg(Hf)))) > tol");
endif
T=H2T(H,dHdw);
if max(abs(T-Tf)) > 2*tol
  error("max(abs(T-Tf)) > 2*tol");
endif
allpass_filter_check_gradc1c2(@allpass_LS2a_coef2Abcd,w,c1,c2,del,del/300);

%
% Complex poles
%
r=0.3;
theta=pi/5;
c2=1-(r*r);
c1=(2-(2*r*cos(theta))-c2)/2;
b=conv([r*e^(-j*theta), -1],[r*e^(j*theta), -1]);
a=conv([1, -r*e^(-j*theta)],[1, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[Tf,w]=delayz(b,a,1024);

[c1,c2]=allpass_LS2a_pole2coef(r,theta,"complex");
[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_LS2a_coef2Abcd(c1,c2);
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
allpass_filter_check_gradc1c2(@allpass_LS2a_coef2Abcd,w,c1,c2,del,del/200);


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
[c1,c2]=allpass_LS2a_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_LS2a_coef2Abcd(c1,c2);
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
[yLS2a,xxLS2a]=allpass_LS2a(c1,c2,u);
if max(abs(y-yLS2a)) > 500*tol
  error("max(abs(y-yLS2a)) > 500*tol");
endif
[yLS2af,xxLS2af]=allpass_LS2a(c1,c2,u,"round");
ngLS2a=allpass_LS2a_coef2ng(c1,c2)
est_varyd=(1+ngLS2a)/12
varyd=var(yLS2a-yLS2af)
% Check SVF simulation
[K,W]=KW(A,B,C,D);
T=diag(sqrt(diag(K)));
[yABCDf,xxABCDf]=svf(inv(T)*A*T,inv(T)*B,C*T,D,u,"round");
if max(abs(yABCDf-yLS2af)) > tol
  error("max(abs(yABCDf-yLS2af)) > tol");
endif

% Another filter
r=0.99;
theta=pi/2;
b=conv([r*e^(-j*theta), -1],[r*e^(j*theta), -1]);
a=conv([1, -r*e^(-j*theta)],[1, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[c1,c2]=allpass_LS2a_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_LS2a_coef2Abcd(c1,c2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 10*tol
  error("max(abs(H-Hf)) > 10*tol");
endif
[yLS2a,xxLS2a]=allpass_LS2a(c1,c2,u);
[yLS2af,xxLS2af]=allpass_LS2a(c1,c2,u,"round");
ngLS2a=allpass_LS2a_coef2ng(c1,c2)
est_varyd=(1+ngLS2a)/12
varyd=var(yLS2a-yLS2af)
% Check SVF simulation
[K,W]=KW(A,B,C,D);
T=diag(sqrt(diag(K)));
[yABCDf,xxABCDf]=svf(inv(T)*A*T,inv(T)*B,C*T,D,u,"round");
if max(abs(yABCDf-yLS2af)) > tol
  error("max(abs(yABCDf-yLS2af)) > tol");
endif

% Another filter
r=0.999;
theta=0.01;
b=conv([r*e^(-j*theta), -1],[r*e^(j*theta), -1]);
a=conv([1, -r*e^(-j*theta)],[1, -r*e^(j*theta)]);
[Hf,w]=freqz(b,a,1024);
[c1,c2]=allpass_LS2a_pole2coef(r,theta,"complex");
[A,B,C,D]=allpass_LS2a_coef2Abcd(c1,c2);
if rank([A,B])~=rows(A)
  printf("rank([A,B])~=rows(A) (%d)\n",rank([A,B]));
endif
H=Abcd2H(w,A,B,C,D);
if max(abs(Hf-H)) > 5000*tol
  error("max(abs(H-Hf)) > 5000*tol");
endif
[yLS2a,xxLS2a]=allpass_LS2a(c1,c2,u);
[yLS2af,xxLS2af]=allpass_LS2a(c1,c2,u,"round");
ngLS2a=allpass_LS2a_coef2ng(c1,c2)
est_varyd=(1+ngLS2a)/12
varyd=var(yLS2a-yLS2af)
% Check SVF simulation
[K,W]=KW(A,B,C,D);
T=diag(sqrt(diag(K)));
[yABCDf,xxABCDf]=svf(inv(T)*A*T,inv(T)*B,C*T,D,u,"round");
if max(abs(yABCDf-yLS2af)) > tol
  error("max(abs(yABCDf-yLS2af)) > tol");
endif

% Done
diary off
movefile allpass_LS2a_test.diary.tmp allpass_LS2a_test.diary;
