% tf2x_x2tf_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("tf2x_x2tf_test.diary");
delete("tf2x_x2tf_test.diary.tmp");
diary tf2x_x2tf_test.diary.tmp


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x,U,V,M,Q]=tf2x(0,1);
if (x~= 0) || (U ~= 0) || (V ~= 0)|| (M ~= 0) || (Q ~= 0)
  error("Expected x=U=V=M=Q=0");
endif
[n,d]=x2tf(0,0,0,0,0,1);
if (n~= 0) || (d ~= 1) 
  error("Expected n=0 and d=1");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
N=7;
fc=0.1;
epstol=32;
R=1;

[n1,d1]=butter(N,2*fc);
n1=n1(:);
d1=d1(:);
[a,U,V,M,Q]=tf2x(n1,d1);
[n2,d2]=x2tf(a,U,V,M,Q,R);
if max(abs(n1-n2)) > epstol*eps
  error("max(abs(n1-n2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(n1-n2))/eps));
endif
if max(abs(d1-d2)) > epstol*eps
  error("max(abs(d1-d2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d2))/eps));
endif

[a,U,V,M,Q]=tf2x(n1,d1,0.00008);
[n2a,d2a]=x2tf(a,U,V,M,Q,R);
if max(abs(n1-n2a)) > epstol*eps
  error("max(abs(n1-n2a)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(n1-n2a))/eps));
endif
if max(abs(d1-d2a)) > epstol*eps
  error("max(abs(d1-d2a)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d2a))/eps));
endif

R=3;
[n3,d3]=x2tf(a,U,V,M,Q,R);
n3=n3(:);
d3=d3(:);
if max(abs(n1-n3)) > epstol*eps
  error("max(abs(n1-n3)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(n1-n3))/eps));
endif
if max(abs(d1-d3(1:R:end))) > epstol*eps
  error("max(abs(d1-d3(1:R:end))) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d3(1:R:end)))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
N=6;
fc=0.1;
tol=1e-12;
epstol=25;
R=1;

[n1,d1]=butter(N,2*fc);
n1=n1(:);
d1=d1(:);
[a,U,V,M,Q]=tf2x(n1,d1,tol);
[n2,d2]=x2tf(a,U,V,M,Q,R);
if max(abs(n1-n2)) > epstol*eps
  error("max(abs(n1-n2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(n1-n2))/eps));
endif
if max(abs(d1-d2)) > epstol*eps
  error("max(abs(d1-d2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d2))/eps));
endif

R=3;
[n3,d3]=x2tf(a,U,V,M,Q,R);
n3=n3(:);
d3=d3(:);
if max(abs(n1-n3)) > epstol*eps
  error("max(abs(n1-n3)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(n1-n3))/eps));
endif
if max(abs(d1-d3(1:R:end))) > epstol*eps
  error("max(abs(d1-d3(1:R:end))) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d3(1:R:end)))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
N=20;
fc=0.1;
tol=1e-12;
epstol=25;
R=1;

n1=remez(N,2*[0 0.1 0.2 0.5],[1 1 0 0]);
n1=n1(:);
d1=1;
[a,U,V,M,Q]=tf2x(n1,d1,tol);
[n2,d2]=x2tf(a,U,V,M,Q,R);
if max(abs(n1-n2)) > epstol*eps
  error("max(abs(n1-n2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(n1-n2))/eps));
endif
if max(abs(d1-d2)) > epstol*eps
  error("max(abs(d1-d2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d2))/eps));
endif

R=3;
[n3,d3]=x2tf(a,U,V,M,Q,R);
n3=n3(:);
d3=d3(:);
if max(abs(n1-n3)) > epstol*eps
  error("max(abs(n1-n3)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(n1-n3))/eps));
endif
if max(abs(d1-d3(1:R:end))) > epstol*eps
  error("max(abs(d1-d3(1:R:end))) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d3(1:R:end)))/eps));
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
[a,U,V,M,Q]=tf2x(n1,d1,tol);
[n2,d2]=x2tf(a,U,V,M,Q,R);
if max(abs(n1-n2)) > epstol*eps
  error("max(abs(n1-n2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(n1-n2))/eps));
endif
if max(abs(d1-d2)) > epstol*eps
  error("max(abs(d1-d2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d2))/eps));
endif

R=3;
[n3,d3]=x2tf(a,U,V,M,Q,R);
n3=n3(:);
d3=d3(:);
if max(abs(n1-n3)) > epstol*eps
  error("max(abs(n1-n3)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(n1-n3))/eps));
endif
if max(abs(d1-d3(1:R:end))) > epstol*eps
  error("max(abs(d1-d3(1:R:end))) > epstol*eps (%f*eps)", ...
        ceil(max(abs(d1-d3(1:R:end)))/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diary off
movefile tf2x_x2tf_test.diary.tmp tf2x_x2tf_test.diary;
