% zp2x_test.m
% Copyright (C) 2018-2025 Robert G. Jenssen

test_common;

delete("zp2x_test.diary");
delete("zp2x_test.diary.tmp");
diary zp2x_test.diary.tmp


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x0,U,V,M,Q]=zp2x([],[],1);
if (x0~= 1) || (U ~= 0) || (V ~= 0)|| (M ~= 0) || (Q ~= 0)
  error("Expected x=U=V=M=Q=0");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
N=7;
fc=0.1;
dBas=40;
epstol=10;
R=1;

[z1,p1,k1]=cheby2(N,dBas,2*fc);
[n1,d1]=zp2tf(z1,cplxpair(p1),k1); % Workaround for poly.m in octave-5.1.0
n1=n1(:);
d1=d1(:);
[x1,U,V,M,Q]=zp2x(z1,p1,k1);
[n2,d2]=x2tf(x1,U,V,M,Q,R);
if max(abs(n1-n2)) > epstol*eps
  error("max(abs(n1-n2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(n1-n2))/eps));
endif
if max(abs(d1-d2)) > epstol*eps
  error("max(abs(d1-d2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d2))/eps));
endif

[a,U,V,M,Q]=zp2x(z1,p1,k1,0.00008);
[n2a,d2a]=x2tf(a,U,V,M,Q,R);
if max(abs(n1-n2a)) > epstol*eps
  error("max(abs(n1-n2a)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(n1-n2a))/eps));
endif
if max(abs(d1-d2a)) > epstol*eps
  error("max(abs(d1-d2a)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d2a))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
N=6;
fc=0.1;
dBas=40;
tol=1e-12;
epstol=25;
R=1;

[z1,p1,k1]=cheby2(N,dBas,2*fc);
[n1,d1]=zp2tf(z1,p1,k1);
n1=n1(:);
d1=d1(:);
[x1,U,V,M,Q]=zp2x(z1,p1,k1,tol);
[n2,d2]=x2tf(x1,U,V,M,Q,R);
if max(abs(n1-n2)) > epstol*eps
  error("max(abs(n1-n2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(n1-n2))/eps));
endif
if max(abs(d1-d2)) > epstol*eps
  error("max(abs(d1-d2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d2))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
N=20;
fc=0.1;
tol=1e-12;
epstol=20;
R=1;

n1=remez(N,2*[0 0.1 0.2 0.5],[1 1 0 0]);
n1=n1(:);
d1=1;
[z1,p1,k1]=tf2zp(n1,d1);
[x1,U,V,M,Q]=zp2x(z1,p1,k1,tol);
[n2,d2]=x2tf(x1,U,V,M,Q,R);
if max(abs(n1-n2)) > epstol*eps
  error("max(abs(n1-n2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(n1-n2))/eps));
endif
if max(abs(d1-d2)) > epstol*eps
  error("max(abs(d1-d2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d2))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
N=8;
fc=0.1;
tol=1e-12;
epstol=50;
R=1;

[n1,d1]=butter(N,2*fc);
n1=1;
d1=d1(:);
[z1,p1,k1]=tf2zp(n1,d1);
[x1,U,V,M,Q]=zp2x(z1,p1,k1,tol);
[n2,d2]=x2tf(x1,U,V,M,Q,R);
if max(abs(n1-n2)) > epstol*eps
  error("max(abs(n1-n2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(n1-n2))/eps));
endif
if max(abs(d1-d2)) > epstol*eps
  error("max(abs(d1-d2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d2))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diary off
movefile zp2x_test.diary.tmp zp2x_test.diary;
