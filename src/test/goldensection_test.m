% goldensection_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("goldensection_test.diary");
delete("goldensection_test.diary.tmp");
diary goldensection_test.diary.tmp


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

searchTypes={"armijo","goldstein","goldensection"};
x=[-4.1,-1.5,-2];
d=[1,2,10];
for k=1:length(searchTypes)
  printf("\nTesting %s:\n", searchTypes{k});
  for l=1:length(x)
    [tau iter]=goldensection(@f,x(l),d(l),f(x(l)),gradxf(x(l)),W,tol,maxiter);
    printf("tau=%g,f(%g+tau)=%g,iter=%d,fiter=%d\n", ...
           tau,x(l),f(x(l)+tau),iter,fiter);
  endfor
endfor

diary off
movefile goldensection_test.diary.tmp goldensection_test.diary;
