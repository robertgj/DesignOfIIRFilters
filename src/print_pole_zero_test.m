% print_pole_zero_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("print_pole_zero_test.diary");
unlink("print_pole_zero_test.diary.tmp");
diary print_pole_zero_test.diary.tmp

[N1,D1]=butter(8,0.1*2);
[x1,U,V,Q,M]=tf2x(N1,D1);
R=1;

print_pole_zero(x1,U,V,M,Q,R,"x1");
print_pole_zero(x1,U,V,M,Q,R,"x1","print_pole_zero_test.coef.1");
print_pole_zero(x1,U,V,M,Q,R,"x1","print_pole_zero_test.coef.2","%12.5e");

Ux2=2,Vx2=2,Mx2=22,Qx2=0,Rx2=2
x2 = [   0.0055318501 ...
        -2.5170628267  -1.3160752171 ...
        -0.9079560306  -0.2702693669 ...
         1.3053646150   1.2801395738   1.2456947672   1.3543532252 ... 
         1.3403287270   1.3017511081   1.1940391431   1.0576999798 ... 
         0.8556865803   0.6295823844   0.5427361878 ...
         2.8130739332   2.4936224647   2.1815962607   0.2206288358 ... 
         0.6636910430   1.1146343826   1.8756693941   1.6003195241 ... 
         1.5609093563   1.0945324853   0.3906957551 ]';
print_pole_zero(x2,Ux2,Vx2,Mx2,Qx2,Rx2,"x2");
print_pole_zero(x2,Ux2,Vx2,Mx2,Qx2,Rx2,"x2","print_pole_zero_test.coef.3");

diary off
movefile print_pole_zero_test.diary.tmp print_pole_zero_test.diary;
