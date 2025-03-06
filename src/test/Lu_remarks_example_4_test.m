% Lu_remarks_example_4_test.m
% See:
% [1] Section III of: http://www.ece.uvic.ca/~wslu/Talk/SeDuMi-Remarks.pdf
% [2] Section 14.7.3(i) of:
%     "PRACTICAL OPTIMIZATION : Algorithms and Engineering Applications" by
%     Andreas Antoniou and Wu-Sheng Lu ISBN-10: 0-387-71106-6
%
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

delete("Lu_remarks_example_4_test.diary");
delete("Lu_remarks_example_4_test.diary.tmp");
diary Lu_remarks_example_4_test.diary.tmp

% The statement of Example 14.5 of [2] in Section III of [1] as Example 4 is:
% minimise delta
% subject to linear constraints:
%      -x3+2.4 >= 0
%      x4-2.4 >= 0
%      1.5*x3-x4+2.4 >= 0 
% and quadratic constraints:
%      [(x1-x3)^2+(x2-x4)^2]^0.5 <= delta
%      [x1,x2][1/4,0;0,1][x1;x2]-[x1,x2][1/2;0] -3/4 <= 0
%      [x3,x4][5/8,3/8;3/8,5/8][x3;x4]-[x3,x4][11/2;13/2] +35/2 <= 0

% If the parameter vector is [delta,x1,x2,x3,x4] then, in SeDuMi form:
b=[1 0 0 0 0]';

% The linear constraints are, in SeDuMi form:
D=[0 0 0 -1 0; 0 0 0 0 1; 0 0 0 1.5 -1]';
f=[2.4 -2.4 2.4]';

% The first quadratic constraint can be written:
%      ([x1-x3 x2-x4 -x1+x3 -x2+x4][x1;x2;x3;x4])^0.5 <= delta
%      ([x1,x2,x3,x4][ 1, 0,-1, 0][x1;x2;x3;x4])^0.5 <= delta
%                    [ 0, 1, 0,-1]
%                    [-1, 0, 1, 0]
%                    [ 0,-1, 0, 1]
%      ([x1,x2,x3,x4][-1, 0][-1, 0, 1, 0][x1;x2;x3;x4])^0.5 <= delta
%                    [ 0, 1][ 0, 1, 0,-1]
%                    [ 1, 0]
%                    [ 0,-1]
%
% In SeDuMi form:
A1=[0 -1 0 1 0; 0 0 1 0 -1]';
b1=b;
c1=[0 0]';
d1=0;

% Similarly, the second quadratic constraint can be written:
% [x1,x2,x3,x4][  0,0][0 0.5 0 0 0][x1;x2;x3;x4]-[x1,x2][1/2;0] -3/4 <= 0
%              [0.5,0][0   0 1 0 0]
%              [  0,1]
%              [  0,0]
%              [  0,0]
% In SeDuMi form:
A2=[0 0.5 0 0 0; 0 0 1 0 0]';
b2=zeros(5,1);
c2=pinv(A2)*([0;-1/2;0;0;0]/2);
d2=sqrt(([-1/4,0]*inv([1/4,0;0,1])*[-1/4;0])+(3/4));

% For the third constraint, if
%  H = [-1/sqrt(2) -1/(2*sqrt(2));-1/sqrt(2) 1/(2*sqrt(2))];
% then:
%  H*H' = [5/8,3/8;3/8,5/8]
% In SeDuMi form the third quadratic constraint is:
A3 = [0 0 0 -1/sqrt(2) -1/sqrt(2); 0 0 0 -1/(2*sqrt(2)) 1/(2*sqrt(2))]';
b3 = b2;
c3=pinv(A3)*([0;0;0;-11/2;-13/2]/2);
d3=sqrt(([-11/4,-13/4]*inv([5/8,3/8;3/8,5/8])*[-11/4;-13/4])-(35/2));

% Set up the parameters to SeDuMi
At1 = -[b1 A1];
At2 = -[b2 A2];
At3 = -[b3 A3];
At = [-D At1 At2 At3];
bt = -b;
ct1 = [d1; c1];
ct2 = [d2; c2];
ct3 = [d3; c3];
ct = [f;ct1; ct2; ct3];
K.l = size(D,2);             
K.q = [size(At1,2) size(At2,2) size(At3,2)];

% Run SeDuMi
[xs, ys, info] = sedumi(At,bt,ct,K);
x = ys;
r_s = x(2:3);
s_s = x(4:5);
disp("solution points in regions R and S are:")
[r_s s_s]
disp("minimum distance:")
norm(r_s - s_s)
info

print_polynomial(r_s,"r_s");
print_polynomial(r_s,"r_s","Lu_remarks_example_4_test_r_s_coef.m","%10.6f");
print_polynomial(s_s,"s_s");
print_polynomial(s_s,"s_s","Lu_remarks_example_4_test_s_s_coef.m","%10.6f");

% Done
diary off
movefile Lu_remarks_example_4_test.diary.tmp ...
         Lu_remarks_example_4_test.diary;
