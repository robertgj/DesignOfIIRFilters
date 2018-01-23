% sqp_gi_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("sqp_gi_test.diary");
unlink("sqp_gi_test.diary.tmp");
diary sqp_gi_test.diary.tmp

sqp_common;

x0=[30; -20; 10];
tol=1e-6;
verbose=true;
maxiter=100;
fiter=0;

[x,W,invW,iter,feasible]=goldfarb_idnani(x0,@sqp_fx,@sqp_gx,tol,maxiter,verbose);
[fx,gxf,hxxf]=sqp_fx(x);
[gx,gxg]=sqp_gx(x);

printf("x=[");printf(" %f",x);printf("] fx=%f %d iterations\n",fx,iter);

diary off
movefile sqp_gi_test.diary.tmp sqp_gi_test.diary;
