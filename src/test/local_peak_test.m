% local_peak_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("local_peak_test.diary");
delete("local_peak_test.diary.tmp");
diary local_peak_test.diary.tmp

x=2*pi*linspace(0,1,1024);
y=sin(3.14*x)+0.5*cos(6.09*x)+0.1*sin(10.11*x+1/6)+0.1*sin(15.3*x+1/3);

% Simple test
yflat=ones(1024,1);
[xpeak,ypeak] = local_peak(yflat);
print_polynomial(xpeak,"xpeak");
print_polynomial(ypeak,"ypeak");
[xpeak,ypeak,ipeak] = local_peak(yflat);
print_polynomial(xpeak,"xpeak");
print_polynomial(ypeak,"ypeak");
print_polynomial(ipeak,"ipeak","%4d");

% From local_max
idxpeak = local_max(y);
print_polynomial(idxpeak,"idxpeak","%4d");
idxtrough = local_max(-y);
print_polynomial(idxtrough,"idxtrough","%4d");

% From local_peak using index
[xpeak,ypeak] = local_peak(y);
print_polynomial(xpeak,"xpeak");
print_polynomial(ypeak,"ypeak");
[xpeak,ypeak,ipeak] = local_peak(y);
print_polynomial(xpeak,"xpeak");
print_polynomial(ypeak,"ypeak");
print_polynomial(ipeak,"ipeak","%4d");
[xtrough,ytrough,itrough] = local_peak(-y');
print_polynomial(xtrough,"xtrough");
print_polynomial(ytrough,"ytrough");
print_polynomial(itrough,"itrough","%4d");

% From local_peak using x
[xpeak,ypeak,ipeak] = local_peak(x,y);
print_polynomial(xpeak,"xpeak");
print_polynomial(ypeak,"ypeak");
print_polynomial(ipeak,"ipeak","%4d");
[xtrough,ytrough,itrough] = local_peak(x',-y');
print_polynomial(xtrough,"xtrough");
print_polynomial(ytrough,"ytrough");
print_polynomial(itrough,"itrough","%4d");

% Plot
plot(x,y);
title("Test local\\_peak.m");
hold on
plot(x(idxpeak),y(idxpeak),"*")
plot(x(idxtrough),y(idxtrough),"x")
zticks([]);
print("local_peak_test","-dpdflatex");
close

% Another test. 
% Problem at wAl=0.93727 due to overshoot in parabolic approximation
x=[ 0.014171 ...
    1.018650 -0.324818  1.003773  0.991183  2.067284 ...
    1.940650  3.111149  2.293573  2.835202  0.458968 ...
    0.599490  0.416602 -0.519686  ...
    1.628317  0.006140  2.098588 ]';
U=0;V=0;Q=6;M=10;R=1;tol=1e-3;
n=1000;wa=(0:(n-1))'*pi/n;
A=iirA(wa,x,U,V,M,Q,R,tol);
fap=0.15;nap=ceil(n*fap/0.5)+1;dBap=1;
Adl=[(10^(-dBap/20))*ones(nap,1);zeros(n-nap,1)+tol/10];
[wAl, dAl]=local_peak(wa,Adl-A);
print_polynomial(wAl,"wAl");
print_polynomial(dAl,"dAl");

diary off
movefile local_peak_test.diary.tmp local_peak_test.diary;
