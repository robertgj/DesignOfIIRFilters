% x2pa_test.m
% Copyright (C) 2018,2024 Robert G. Jenssen

test_common;

delete("x2pa_test.diary");
delete("x2pa_test.diary.tmp");
diary x2pa_test.diary.tmp

tol=100*eps;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[a1,V1,Q1,a2,V2,Q2]=x2pa([1 -1.1 -0.9],1,1,0,0,1,0.001);
try
  [V1,Q1,a2,V2,Q2]=x2pa([1 -1.1 -0.9],1,1,0,0,1,0.001);
catch
  printf("Caught %s\n",lasterror.message);
end_try_catch
try
  [a1,V1,Q1,a2,V2,Q2]=x2pa([1 -1.1 -0.9],1,1,0,0,1,0.001,0);
catch
  printf("Caught %s\n",lasterror.message);
end_try_catch
try
  [a1,V1,Q1,a2,V2,Q2]=x2pa([1 -1.1 -0.9],1,1,0,0);
catch
  printf("Caught %s\n",lasterror.message);
end_try_catch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[a1,V1,Q1,a2,V2,Q2]=x2pa([1 -1.1 -0.9],1,1,0,0,1);
R1=1;
R2=1;
if ~isempty(a1)
  error("~isempty(a1)");
endif
if V1~=0
  error("V1~=0");
endif
if Q1~=0
  error("Q1~=0");
endif
if isempty(a2)
  error("isempty(a2)");
endif
if V2~=1
  error("V2~=1");
endif
if Q2~=0
  error("Q2~=0");
endif
print_allpass_pole(a1,V1,Q1,R1,"a1","x2pa_test_N1_a1_coef.m");
print_allpass_pole(a2,V2,Q2,R2,"a2","x2pa_test_N1_a2_coef.m");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=2;
fc=0.1;
dBas=40;
R=1;
R1=1;
R2=1;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
try
  [a1,V1,Q1,a2,V2,Q2]=x2pa(x1,U,V,M,Q,R);
catch err
  printf("Expected failure : %s\n",err.message);
end_try_catch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=3;
fc=0.1;
dBas=40;
R=1;
R1=1;
R2=1;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
print_pole_zero(x1,U,V,M,Q,R,"x1");

[a1,V1,Q1,a2,V2,Q2]=x2pa(x1,U,V,M,Q,R);
pa1=a2p(a1,V1,Q1);
pa2=a2p(a2,V2,Q2);
max_diff_p=max(abs(cplxpair([pa1(:);pa2(:)],tol)-cplxpair(p1(:),tol)));
if max_diff_p > 100*eps
  error("max_diff_p(%g*eps) > 100*eps",max_diff_p/eps);
endif

print_allpass_pole(a1,V1,Q1,R1,"a1");
print_allpass_pole(a1,V1,Q1,R1,"a1","x2pa_test_N3_a1_coef.m");
print_allpass_pole(a2,V2,Q2,R2,"a2");
print_allpass_pole(a2,V2,Q2,R2,"a2","x2pa_test_N3_a2_coef.m");
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=5;
fc=0.1;
dBas=40;
R=1;
R1=1;
R2=1;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
print_pole_zero(x1,U,V,M,Q,R,"x1");

[a1,V1,Q1,a2,V2,Q2]=x2pa(x1,U,V,M,Q,R);
pa1=a2p(a1,V1,Q1);
pa2=a2p(a2,V2,Q2);
max_diff_p=max(abs(cplxpair([pa1(:);pa2(:)],tol)-cplxpair(p1(:),tol)));
if max_diff_p > 100*eps
  error("max_diff_p(%g*eps) > 100*eps",max_diff_p/eps);
endif

print_allpass_pole(a1,V1,Q1,R1,"a1");
print_allpass_pole(a1,V1,Q1,R1,"a1","x2pa_test_N5_a1_coef.m");
print_allpass_pole(a2,V2,Q2,R2,"a2");
print_allpass_pole(a2,V2,Q2,R2,"a2","x2pa_test_N5_a2_coef.m");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=7;
fc=0.1;
dBas=40;
R=1;
R1=1;
R2=1;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
print_pole_zero(x1,U,V,M,Q,R,"x1");

[a1,V1,Q1,a2,V2,Q2]=x2pa(x1,U,V,M,Q,R);
pa1=a2p(a1,V1,Q1);
pa2=a2p(a2,V2,Q2);
pa=cplxpair([pa1(:);pa2(:)],tol);
max_diff_p=max(abs(pa-cplxpair(p1(:),tol)));
if max_diff_p > 100*eps
  error("max_diff_p(%g*eps) > 100*eps",max_diff_p/eps);
endif

print_allpass_pole(a1,V1,Q1,R1,"a1");
print_allpass_pole(a1,V1,Q1,R1,"a1","x2pa_test_N7_a1_coef.m");
print_allpass_pole(a2,V2,Q2,R2,"a2");
print_allpass_pole(a2,V2,Q2,R2,"a2","x2pa_test_N7_a2_coef.m");

% Check sorting
nCNpa=find(imag(pa) < -tol);
nCPpa=find(imag(pa) >  tol);
if any(nCPpa-nCNpa-1)
  error("any(nCPpa-nCNpa-1)");
endif
if max(abs(pa(nCPpa)-conj(pa(nCNpa)))) > eps
  error("max(abs(pa(nCPpa)-conj(pa(nCNpa)))) > eps");
endif

% Check two ways of finding the parallel allpass denominator polynomials
[Nd,Dd]=cheby2(N,dBas,2*fc);
Nd=Nd(:);Dd=Dd(:);
[Dd1p,Dd2p]=tf2pa(Nd,Dd);
Dd1p=Dd1p(:);Dd2p=Dd2p(:);
if max(abs(conv(Dd1p,Dd2p)-Dd)) > 2000*eps
  error("max(abs(conv(Dd1p,Dd2p)-Dd)) > 2000*eps");
endif
[x1,U,V,M,Q]=tf2x(Nd,Dd);R=1;
[a1,V1,Q1,a2,V2,Q2]=x2pa(x1,U,V,M,Q,R);
[~,Dd1]=a2tf(a1,V1,Q1);
[~,Dd2]=a2tf(a2,V2,Q2);
Dd1=Dd1(:);Dd2=Dd2(:);
if max(abs(conv(Dd1,Dd2)-Dd)) > 2000*eps
  error("max(abs(conv(Dd1,Dd2)-Dd)) > 2000*eps");
endif

% Check qroots(NQd)
Qd=spectralfactor(Nd,Dd);
NQd=(Nd(:)+Qd(:));
NQd=NQd/NQd(1);
Zd=cplxpair(qroots(NQd),tol);
NQdp=1;
for k=1:length(Zd)
  NQdp=conv(NQdp,[1;-Zd(k)]);
endfor
if max(abs(imag(NQdp)))>100*eps
  error("max(abs(imag(NQdp)))>100*eps");
endif
NQdp=real(NQdp);
if max(abs(NQdp-NQd)) > 200*eps
  error("max(abs(NQdp-NQd)) > 200*eps");
endif

nReZd=find(abs(imag(Zd))<tol);
ReZd=real(Zd(nReZd));
nCxZd=find(imag(Zd)>tol);
CxZd=Zd(nCxZd);          
NQdp=1;
for k=1:length(nReZd)
  NQdp=conv(NQdp,[1;-ReZd(k)]);
endfor
for k=1:length(nCxZd)
  NQdp=conv(NQdp, conv([1;-CxZd(k)],[1;-conj(CxZd(k))]));
endfor
if max(abs(imag(NQdp)))>eps
  error("max(abs(imag(NQdp)))>eps");
endif
NQdp=real(NQdp);
if max(abs(NQd-NQdp))>eps
  error("max(abs(NQd-NQdp))>eps");
endif

% Check roots of Dd
zDd=cplxpair(qroots(Dd),tol);
[dx,U,V,M,Q]=tf2x(1,Dd);
dxp=cplxpair(a2p(dx(2:end),V,Q,1),tol);
if max(abs(zDd-dxp)) > eps
  error("max(abs(cplxpair(zDd,tol)-cplxpair(dxp,tol))) > eps");
endif

% Check roots of spectralfactor
Qd=spectralfactor(Nd,Dd);
NQd=(Nd(:)+Qd(:));
NQd=NQd/NQd(1);
Zd=qroots(NQd);
NQdp=1;
for k=1:length(Zd)
  NQdp=conv(NQdp,[1;-Zd(k)]);
endfor
if max(abs(NQdp-NQd)) > 10*eps
  error("max(abs(NQdp-NQd)) > 10*eps");
endif

% Check spectralfactor combined frequency response for Nd,Dd and Qd,Dd
Qd=spectralfactor(Nd,Dd);
HF=freqz(Nd,Dd,1024);
HG=freqz(Qd,Dd,1024);
if max(abs((abs(HF).^2)+(abs(HG).^2)-1)) > 10000*eps
  error("max(abs((abs(HF).^2)+(abs(HG).^2)-1)) > 10000*eps");
endif
HD1=freqz(flipud(Dd1),Dd1,1024);
HD2=freqz(flipud(Dd2),Dd2,1024);
HF=(HD1+HD2)/2;
HG=(HD1-HD2)/2;
if max(abs(abs(abs(HF).^2+abs(HG).^2)-1)) > 200*eps
  error("max(abs(abs(abs(HF).^2+abs(HG).^2)-1)) > 200*eps");
endif
if max(abs(abs(HF+HG)-1)) > 200*eps
  error("max(abs(abs(HF+HG)-1)) > 200*eps");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=13;
fc=0.1;
dBas=40;
R=1;
R1=1;
R2=1;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
print_pole_zero(x1,U,V,M,Q,R,"x1");
[a1,V1,Q1,a2,V2,Q2]=x2pa(x1,U,V,M,Q,R);
print_allpass_pole(a1,V1,Q1,R1,"a1");
print_allpass_pole(a1,V1,Q1,R1,"a1","x2pa_test_N13_a1_coef.m","%11.8f");
print_allpass_pole(a2,V2,Q2,R2,"a2");
print_allpass_pole(a2,V2,Q2,R2,"a2","x2pa_test_N13_a2_coef.m","%11.8f");

[Nd,Dd]=cheby2(N,dBas,2*fc);
[Dd1p,Dd2p]=tf2pa(Nd,Dd);
if max(abs(conv(Dd1p,Dd2p)-Dd)) > 5e7*eps
  error("max(abs(conv(Dd1p,Dd2p)-Dd)) > 5e7 *eps");
endif

% Check sorting
pa1=cplxpair(a2p(a1,V1,Q1),tol);
pa2=cplxpair(a2p(a2,V2,Q2),tol);
pa=[pa1(:);pa2(:)];
nCNpa=find(imag(pa) < -tol);
nCPpa=find(imag(pa) >  tol);
if max(abs(pa(nCPpa)-conj(pa(nCNpa)))) > eps
  error("max(abs(pa(nCPpa)-conj(pa(nCNpa)))) > eps");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diary off
movefile x2pa_test.diary.tmp x2pa_test.diary;
