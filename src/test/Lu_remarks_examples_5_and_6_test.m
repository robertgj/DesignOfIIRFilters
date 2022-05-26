% Lu_remarks_examples_5_and_6_test.m
% See: http://www.ece.uvic.ca/~wslu/Talk/SeDuMi-Remarks.pdf
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("Lu_remarks_examples_5_and_6_test.diary");
delete("Lu_remarks_examples_5_and_6_test.diary.tmp");
diary Lu_remarks_examples_5_and_6_test.diary.tmp

% Example 5
A0 = [2 -0.5 -0.6; -0.5 2 0.4; -0.6 0.4 3];
A1 = [0 1 0; 1 0 0; 0 0 0];
A2 = [0 0 1; 0 0 0; 1 0 0];
A3 = [0 0 0; 0 0 1; 0 1 0];
F0 = -A0;
F1 = -A1;
F2 = -A2;
F3 = -A3;
F4 = eye(3);
At = -[vec(F1) vec(F2) vec(F3) vec(F4)];
bt = -[0 0 0 1]';
ct = vec(F0);
K.s = size(F0,1);
[x5,y5,info5] = sedumi(At,bt,ct,K);
print_polynomial(x5,"x5");
print_polynomial(x5,"x5","Lu_remarks_examples_5_and_6_test_x5_coef.m","%10.6f");
print_polynomial(y5,"y5");
print_polynomial(y5,"y5","Lu_remarks_examples_5_and_6_test_y5_coef.m","%10.6f");

% Example 6
A = [1 0 0 0; -1 0 0 0; 0 1 0 0; 0 -1 0 0; 0 0 1 0];
b = [0.7 -1 0 -0.3 0]';
Att=[-A;At];
btt=bt;
ctt=[-b;ct];     
K.l=size(A,1);
[x6,y6,info6] = sedumi(Att,btt,ctt,K);
print_polynomial(x6,"x6");
print_polynomial(x6,"x6","Lu_remarks_examples_5_and_6_test_x6_coef.m","%10.6f");
print_polynomial(y6,"y6");
print_polynomial(y6,"y6","Lu_remarks_examples_5_and_6_test_y6_coef.m","%10.6f");

% Done
diary off
movefile Lu_remarks_examples_5_and_6_test.diary.tmp ...
         Lu_remarks_examples_5_and_6_test.diary;
