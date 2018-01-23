% goldensection_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("goldensection_test.diary");
unlink("goldensection_test.diary.tmp");
diary goldensection_test.diary.tmp

format compact

global fiter=0

function fx=f(x)
  global fiter
  fiter=fiter+1;
  fx=sumsq(x+1);
endfunction

function gxf=gradxf(x)
  gxf=2*(x+1);
endfunction

tol=1e-3;
maxiter=100;
W=[];

printf("\nWith goldstein()\n");
[tau iter]=goldstein(@f, -4.1,  1, f(-4.1), gradxf(-4.1), W, tol, maxiter)
f(-4.1+tau)
fiter
[tau iter]=goldstein(@f, -1.5,  2, f(-1.5), gradxf(-1.5), W, tol, maxiter)
f(-1.5+(2*tau))
fiter
[tau iter]=goldstein(@f, -2.0, 10, f(-2.0), gradxf(-2.0), W, tol, maxiter)
f(-2.0+(10*tau))
fiter

printf("\nWith armijo()\n");
[tau iter]=armijo(@f, -4.1,  1, f(-4.1), gradxf(-4.1), W, tol, maxiter)
f(-4.1+tau)
fiter
[tau iter]=armijo(@f, -1.5,  2, f(-1.5), gradxf(-1.5), W, tol, maxiter)
f(-1.5+(2*tau))
fiter
[tau iter]=armijo(@f, -2.0, 10, f(-2.0), gradxf(-2.0), W, tol, maxiter)
f(-2.0+(10*tau))
fiter

printf("\nWith goldensection()\n");
[tau iter]=goldensection(@f, -4.1,  1, f(-4.1), gradxf(-4.1), W, tol, maxiter,true)
f(-4.1+tau)
fiter
[tau iter]=goldensection(@f, -1.5,  2, f(-1.5), gradxf(-1.5), W, tol, maxiter,true)
f(-1.5+(2*tau))
fiter
[tau iter]=goldensection(@f, -2.0, 10, f(-2.0), gradxf(-2.0), W, tol, maxiter,true)
f(-2.0+(10*tau))
fiter

diary off
movefile goldensection_test.diary.tmp goldensection_test.diary;
