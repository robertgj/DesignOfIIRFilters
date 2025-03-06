% x2zp_test.m
% Copyright (C) 2018-2025 Robert G. Jenssen

test_common;

show_zplane=false;
if show_zplane
  set(0,"defaultlinelinewidth",1.5);
  set(0,"DefaultFigureVisible","on");
endif

delete("x2zp_test.diary");
delete("x2zp_test.diary.tmp");
diary x2zp_test.diary.tmp


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[z,p,K]=x2zp([1],0,0,0,0);
if ~isempty(z)
  error("~isempty(z)");
endif
if ~isempty(p)
  error("~isempty(p)");
endif
if K~=1
  error("K~=1");
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=2;
fc=0.1;
dBas=40;
epstol=10;
R=1;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
z1=sort(z1(:));
p1=sort(p1(:));
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
[z2,p2,K2]=x2zp(x1,U,V,M,Q,R);
if max(abs(z1-z2)) > epstol*eps
  error("max(abs(z1-z2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(z1-z2))/eps));
endif
if max(abs(p1-p2)) > epstol*eps
  error("max(abs(p1-p2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(p1-p2))/eps));
endif
if abs(K1-K2) > epstol*eps
  error("abs(K1-K2) > epstol*eps (%f*eps)", ...
        ceil(abs(K1-K2)/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=2;
fc=0.1;
dBas=40;
epstol=10;
R=2;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
z1=sort(z1(:));
p1=sort(p1(:));
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
[z2,p2,K2]=x2zp(x1,U,V,M,Q,R);
if max(abs(z1-z2)) > epstol*eps
  error("max(abs(z1-z2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(z1-z2))/eps));
endif
if abs(K1-K2) > epstol*eps
  error("abs(K1-K2) > epstol*eps (%f*eps)", ...
        ceil(abs(K1-K2)/eps));
endif
print_polynomial(abs(p2),"abs_p2");
print_polynomial(abs(p2),"abs_p2","x2zp_test_N2R2abs_coef.m");
print_polynomial(angle(p2),"angle_p2");  
print_polynomial(angle(p2),"angle_p2","x2zp_test_N2R2angle_coef.m");

if show_zplane
  figure 1
  zplane(z1,p1);
  title("N2R2");
  figure 2
  zplane(z2,p2);
  title("N2R2");
  input("")
endif
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=2;
fc=0.1;
dBas=40;
epstol=10;
R=3;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
z1=sort(z1(:));
p1=sort(p1(:));
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
[z2,p2,K2]=x2zp(x1,U,V,M,Q,R);
if max(abs(z1-z2)) > epstol*eps
  error("max(abs(z1-z2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(z1-z2))/eps));
endif
if abs(K1-K2) > epstol*eps
  error("abs(K1-K2) > epstol*eps (%f*eps)", ...
        ceil(abs(K1-K2)/eps));
endif
print_polynomial(abs(p2),"abs_p2");
print_polynomial(abs(p2),"abs_p2","x2zp_test_N2R3abs_coef.m");
print_polynomial(angle(p2),"angle_p2");
print_polynomial(angle(p2),"angle_p2","x2zp_test_N2R3angle_coef.m");

if show_zplane
  figure 1
  zplane(z1,p1);
  title("N2R3");
  figure 2
  zplane(z2,p2);
  title("N2R3");
  input("")
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=3;
fc=0.1;
dBas=40;
epstol=10;
R=1;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
z1=sort(z1(:));
p1=sort(p1(:));
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
[z2,p2,K2]=x2zp(x1,U,V,M,Q,R);
if max(abs(z1-z2)) > epstol*eps
  error("max(abs(z1-z2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(z1-z2))/eps));
endif
if max(abs(p1-p2)) > epstol*eps
  error("max(abs(p1-p2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(p1-p2))/eps));
endif
if abs(K1-K2) > epstol*eps
  error("abs(K1-K2) > epstol*eps (%f*eps)", ...
        ceil(abs(K1-K2)/eps));
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=3;
fc=0.4;
epstol=10;
R=2;
[z1,p1,K1]=butter(N,2*fc,"high");
z1=sort(z1(:));
p1=sort(p1(:));
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
[z2,p2,K2]=x2zp(x1,U,V,M,Q,R);
if max(abs(z1-z2)) > epstol*eps
  error("max(abs(z1-z2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(z1-z2))/eps));
endif
if abs(K1-K2) > epstol*eps
  error("abs(K1-K2) > epstol*eps (%f*eps)", ...
        ceil(abs(K1-K2)/eps));
endif
print_polynomial(abs(p2),"abs_p2");
print_polynomial(abs(p2),"abs_p2","x2zp_test_N3R2abs_coef.m");
print_polynomial(angle(p2),"angle_p2");  
print_polynomial(angle(p2),"angle_p2","x2zp_test_N3R2angle_coef.m");
               
if show_zplane
  figure 1
  zplane(z1,p1);
  title("N3R2");
  figure 2
  zplane(z2,p2);
  title("N3R2");
  input("")
endif
              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=3;
fc=0.4;
epstol=10;
R=3;
[z1,p1,K1]=butter(N,2*fc,"high");
z1=sort(z1(:));
p1=sort(p1(:));
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
[z2,p2,K2]=x2zp(x1,U,V,M,Q,R);
if max(abs(z1-z2)) > epstol*eps
  error("max(abs(z1-z2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(z1-z2))/eps));
endif
if abs(K1-K2) > epstol*eps
  error("abs(K1-K2) > epstol*eps (%f*eps)", ...
        ceil(abs(K1-K2)/eps));
endif
print_polynomial(abs(p2),"abs_p2");
print_polynomial(abs(p2),"abs_p2","x2zp_test_N3R3abs_coef.m");
print_polynomial(angle(p2),"angle_p2");  
print_polynomial(angle(p2),"angle_p2","x2zp_test_N3R3angle_coef.m");
               
if show_zplane
  figure 1
  zplane(z1,p1);
  title("N3R3");
  figure 2
  zplane(z2,p2);
  title("N3R3");
  input("")
endif
              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=5;
fc=0.1;
dBas=40;
epstol=10;
R=1;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
z1=sort(z1(:));
p1=sort(p1(:));
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
[z2,p2,K2]=x2zp(x1,U,V,M,Q,R);
if max(abs(z1-z2)) > epstol*eps
  error("max(abs(z1-z2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(z1-z2))/eps));
endif
if max(abs(p1-p2)) > epstol*eps
  error("max(abs(p1-p2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(p1-p2))/eps));
endif
if abs(K1-K2) > epstol*eps
  error("abs(K1-K2) > epstol*eps (%f*eps)", ...
        ceil(abs(K1-K2)/eps));
endif
                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=5;
fc=0.1;
dBas=40;
epstol=10;
R=2;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
z1=sort(z1(:));
p1=sort(p1(:));
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
[z2,p2,K2]=x2zp(x1,U,V,M,Q,R);
if max(abs(z1-z2)) > epstol*eps
  error("max(abs(z1-z2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(z1-z2))/eps));
endif
if abs(K1-K2) > epstol*eps
  error("abs(K1-K2) > epstol*eps (%f*eps)", ...
        ceil(abs(K1-K2)/eps));
endif
print_polynomial(abs(p2),"abs_p2");
print_polynomial(abs(p2),"abs_p2","x2zp_test_N5R2abs_coef.m");
print_polynomial(angle(p2),"angle_p2");
print_polynomial(angle(p2),"angle_p2","x2zp_test_N5R2angle_coef.m");
                 
if show_zplane
  figure 1
  zplane(z1,p1);
  title("N5R2");
  figure 2
  zplane(z2,p2);
  title("N5R2");
  input("")
endif
              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=5;
fc=0.1;
dBas=40;
epstol=10;
R=3;
[z1,p1,K1]=cheby2(N,dBas,2*fc);
z1=sort(z1(:));
p1=sort(p1(:));
[x1,U,V,M,Q]=zp2x(z1,p1,K1);
[z2,p2,K2]=x2zp(x1,U,V,M,Q,R);
if max(abs(z1-z2)) > epstol*eps
  error("max(abs(z1-z2)) > epstol*eps (%f*eps)", ...
        ceil(max(abs(z1-z2))/eps));
endif
if abs(K1-K2) > epstol*eps
  error("abs(K1-K2) > epstol*eps (%f*eps)", ...
        ceil(abs(K1-K2)/eps));
endif
print_polynomial(abs(p2),"abs_p2");
print_polynomial(abs(p2),"abs_p2","x2zp_test_N5R3abs_coef.m");
print_polynomial(angle(p2),"angle_p2"); 
print_polynomial(angle(p2),"angle_p2","x2zp_test_N5R3angle_coef.m");
                
if show_zplane
  figure 1
  zplane(z1,p1);
  title("N5R3");
  figure 2
  zplane(z2,p2);
  title("N5R3");
  input("")
endif
              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
diary off
movefile x2zp_test.diary.tmp x2zp_test.diary;
