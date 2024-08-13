% scs_yalmip_test.m
% Experiment with YALMIP examples from yalmiptest.m to work out how to call SCS
% Copyright (C) 2024 Robert G. Jenssen

test_common;

strf="scs_yalmip_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

fhandle=fopen("test.results","wt");

Options_scs=sdpsettings("solver","scs-direct", ...
                        "scs.max_iters",1e4, ...
                        "scs.eps_abs",1e-9, ...
                        "scs.eps_rel",1e-9, ...
                        "savesolveroutput",1);

%
% function sol = test_quadratic_programming(ops)
%
printf("\n\n\n--------------------------------------\n")
printf("  Test Quadratic Programming (SCS)\n");
printf("--------------------------------------\n\n")
x = sdpvar(10,1);
Constraints=[sum(x)==2, -1 <=x<= 1];
Objective=(x')*x;
Model=export(Constraints,Objective,Options_scs);
sol = optimize(Constraints,Objective,Options_scs);
check(Constraints);
disp("x'="),disp(value(x'))
sol.solveroutput
A=full(Model.data.A)
b=Model.data.b
c=Model.data.c
Model.cones

% YALMIP sets up this problem as minimise c'[x;v], s in K.
% c=[zeros(10,1);1], x(1:10) is the QP variable above and v is an auxilliary
% variable. In other words, minimise v subject to the constraints on x.
% z=1 and the first row of A and b corresponds to the equality constraint on x
% l=20 and rows  2:11 of A and b correspond to -Ix+s( 2:11)=1,s( 2:11)>=0,x>=-1
%      and rows 12:21 of A and b correspond to  Ix+s(12:21)=1,s(12:21)>=0,x<= 1
% q=12 and rows 22:33 of A and b correspond to {t=s(22),s(23:33)} so that
%      -v+t=1. In addition, -2x+s(23:32)=0 and v+s(33)=1]. In other words, 
%       norm(s(23:33))^2=(4*norm(x)^2+(1-v)^2)<=(t^2=(1+v)^2) or norm(x)^2<=v
% In the solution variable, s:
% For z, s(1)=0
% For l, s(2:11)=1.2 (or -x+1.2=1) and s(12:21)=0.8 (or x+0.8=1)
% For q, t=s(22)=1.4 and s(23:32)=0.4 and s(33)=0.6 (or norm(s(23:33)^2<=t=s(22))
%
% The solver output is x(1:10)=0.2, x'*x=0.4, v=0.4, t=1.4, norm(s(23:33))=1.4

% It appears that YALMIP does not use a box cone for this test.
% In order to understand the box cone API, see these comments:
%  https://github.com/bodono/scs-python/issues/63#issue-1284015935
%  https://github.com/bodono/scs-python/issues/36#issuecomment-831179306
% From the latter:
%{
 The box cone API is as follows:

The cone is determined by two vectors (bl, bu) and defined as
K_box = {(t, s): t* bl <= s <= t * bu, t >= 0} (note that the the variable
vector is stacked as [t;s], ie, t comes first then s). In most cases the user
will also want to add the constraint that t == 1 to the linear equality
constraints, which adds a single additional row of all zeros to A and an entry
of 1 to b in the appropriate locations. If t=1 then this boils down to the usual
constraint that bl <= s <= bu, but without the t variable that set is not a cone
and being a cone is required for the math to work.

Recall that the constraints are Ax + s == b with s in K, so depending on your
input formulation you might also have to negate A.

The order of cones assumed in the A matrix is now:

    primal zero / dual free cone
    linear cone
    box cone
    second order cone
    sd cone
    primal exponential cone
    dual exponential cone
    primal power cone
    dual power cone
%}
% To convert the linear cone constraints into a box constraint for [x;v]:
% Zero cone s=[x;v]:
A=[ones(1,10),0];
b=[2];
cones.z=1; 
% Linear cone:
cones.l=0;
% Box cone s=[r;x;v], -r*bl<=x<=r*bu with r=1:
A=[A; [zeros(1,11);-eye(10),zeros(10,1)]];
b=[b; [1;zeros(10,1)]];
cones.bu= ones(10,1);
cones.bl=-ones(10,1);
% Second order cone [t;x;v]:
A=[A; [zeros(1,10),-1; -2*eye(10),zeros(10,1); zeros(1,10),1]];
b=[b; [1;zeros(10,1);1]];
cones.q=12;
% Call SCS
data=struct("A",sparse(A),"b",b,"c",[zeros(10,1);1]);
settings = struct("max_iters",1e4,"eps_abs",1e-9,"eps_rel",1e-9);
[x,y,s,info_scs]=scs_direct(data,cones,settings);
disp("x'="),disp(value(x'))
fprintf(fhandle,"QP: x'=[");fprintf(fhandle," %f",x'); fprintf(fhandle,"];\n");
% SCS returns x(1:10)=0.2 and v=x(11)=0.4, s(1)=0, r=s(2)=1, s(3:12)=0.2,
% t=s(13)=1.4, s(14:23)=0.4 and s(24)=0.6, agreeing with YALMIP

%
% function sol = test_socp_programming(ops)
%
printf("\n\n\n--------------------------------------\n")
printf("  Test Second Order Cone Programming (SCS)\n");
printf("--------------------------------------\n\n")
x = sdpvar(2,1);
a = [0;1];
b = [1;1];
Constraints = [norm(x-a)<=1, norm(x-b)<=1];
Objective=sum(x)
Model = export(Constraints,Objective,Options_scs);
sol = optimize(Constraints,Objective,Options_scs);
check(Constraints);
disp("x'="),disp(value(x'))
sol.solveroutput
A=full(Model.data.A)
b=Model.data.b
c=Model.data.c
Model.cones
% In this case there are two SOCP cones and YALMIP adds an auxilliary variable
% for each cone, [x;r,t], and sets up the problem as "minimise c'*x", where:
ck=[ones(2,1);zeros(2,1)];
% z=0, no equality constraints
% l=2 and row 1 of A and b corresponds to r+s(1)=1, s(1)>=0, or r<=1
Ak=[0,0,1,0];bk=[1];
%  and row 2 of A and b corresponds to t+s(2)=1, s(2)>=0, or t<=1
Ak=[Ak; [0,0,0,1]];bk=[bk;1];
% q(1)=3 and row 3 of A and b corresponds to -r+s(3)=0, s(3)>=0 or s(3)=r>=0
Ak=[Ak; [0,0,-1,0]];bk=[bk;0];
%  and rows (4:5) of A and b correspond to -x+s(4:5)=[0;-1] or norm(x-a)<=r<=1
Ak=[Ak; [-1,0,0,0];[0,-1,0,0]];bk=[bk;0;-1];
% q(2)=3 and row 6 of A and b corresponds to -t+s(6)=0, s(6)>=0 or s(6)=t>=0
Ak=[Ak; [0,0,0,-1]];bk=[bk;0];
%  and rows (7:8) of A and b correspond to -x+s(7:8)=[-1;-1] or norm(x-b)<=t<=1
Ak=[Ak; [-1,0,0,0];[0,-1,0,0]];bk=[bk;-1;-1];
% Call SCS
data=struct("A",sparse(Ak),"b",bk,"c",ck);
cones=struct("z",0,"l",2,"q",[3,3]);
settings=struct("max_iters",1e4,"eps_abs",1e-9,"eps_rel",1e-9);
[x,y,s,info_scs]=scs_direct(data,cones,settings);
disp("x'="),disp(value(x'))
fprintf(fhandle,"SOCP: x'=[");fprintf(fhandle," %f",x'); fprintf(fhandle,"];\n");
% SCS results agree with YALMIP

%
% function sol = test_semidefinite_programming(ops)
%
printf("\n\n\n--------------------------------------\n")
printf("  Test Semi-Definite Programming  (SCS)\n");
printf("--------------------------------------\n\n")
t = sdpvar(1,1);
Y = sdpvar(2,2,'symmetric');
Objective = t;
Constraints = [Y<=t*eye(2), Y>=[1 0.2;0.2 1]];
Model = export(Constraints,Objective,Options_scs);
sol = optimize(Constraints,Objective,Options_scs);
check(Constraints);
disp("t="),disp(value(t))
disp("Y="),disp(value(Y))
sol.solveroutput
A=full(Model.data.A)
b=Model.data.b
c=Model.data.c
Model.cones
% In this case there are two SDP cones, each of size k=2 with (2*(2+1)/2)=3
% distinct elements. There are 4 variables, x=[t;y11,y12,y22].
% For the first cone, S=tI-Y>=0 so that, if B-sum(Ai*xi)>=0, where Ai
% are symmetric 2x2 matrixes:
%   B=[0,0; , A1=[1,0; , A2=[1,0; , A3=[0,1; , A4=[0,0;
%      0,0]       0,1]       0,0]       1,0]       0,1]
% After vectorising, setting A=[vec(A1),vec(A2),vec(A3),vec(A4)] and scaling
% by sqrt(2):
b1=[0;0;0];
A1=[-1,1,0      ,0; ...
     0,0,sqrt(2),0; ...
    -1,0,0,      1]/sqrt(2);
% For the second cone, S=-[1,0.2;0.2,1]+Y>=0 so that:
%   B=[-1,-0.2; , A1=[0,0; , A2=[1,0; , A3=[0,1; , A4=[0,0;
%      -0.2,-1]       0,0]       0,0]       1,0]       0,1]
% After vectorising, setting A=[vec(A1),vec(A2),vec(A3),vec(A4)] and scaling
% off-diagonal elements by sqrt(2):
b2=[-1/sqrt(2);-0.2;-1/sqrt(2)];
A2=[0,-1, 0,       0;
    0, 0,-sqrt(2), 0;
    0, 0, 0,      -1]/sqrt(2);
% The SCS arguments are:
data=struct("A",sparse([A1;A2]),"b",[b1;b2],"c",[1;0;0;0]);
cones=struct("z",0,"l",0,"q",0,"s",[2,2])
settings = struct("max_iters",1e4,"eps_abs",1e-9,"eps_rel",1e-9);
[x,y,s,info_scs]=scs_direct(data,cones,settings);
disp("x'="),disp(value(x'))
fprintf(fhandle,"SDP: x'=[");fprintf(fhandle," %f",x');fprintf(fhandle," ];\n");
% SCS results agree with YALMIP with scs_direct:
% t=1.2000 and Y=[ 1.0879, 0.1121; 0.1121, 1.0879 ];

% Note: convert vector to lower triangular (hollow, ie: diagonal filled with 0):
%  tril(squareform([1,2,3,4,5,6]),-1)(2:end,1:end-1)
% and back:
%  squareform(tril(squareform([1,2,3,4,5,6]),-1),"tovector")


%
% Repeat running YALMIP with SeDuMi gives:
%

Options_sedumi=sdpsettings("solver","sedumi", ...
                           "scs.max_iters",1e4, ...
                           "scs.eps_abs",1e-9, ...
                           "scs.eps_rel",1e-9, ...
                           "savesolveroutput",1);

%
% function sol = test_quadratic_programming(ops)
%
printf("\n\n\n--------------------------------------\n")
printf("  Test Quadratic Programming  (SeDuMi)\n");
printf("--------------------------------------\n\n")
x = sdpvar(10,1);
Constraints=[sum(x)==2, -1 <=x<= 1];
Objective=(x')*x;
sol = optimize(Constraints,Objective,Options_sedumi);
check(Constraints);
disp("x'="),disp(value(x'))

%
% function sol = test_socp_programming(ops)
%
printf("\n\n\n--------------------------------------\n")
printf("  Test Second Order Cone Programming  (SeDuMi)\n");
printf("--------------------------------------\n\n")
x = sdpvar(2,1);
a = [0;1];
b = [1;1];
Constraints = [norm(x-a)<=1, norm(x-b)<=1];
Objective=sum(x)
Model = export(Constraints,Objective,Options_sedumi);
sol = optimize(Constraints,Objective,Options_sedumi);
check(Constraints);
disp("x'="),disp(value(x'))

%
% function sol = test_semidefinite_programming(ops)
%
printf("\n\n\n--------------------------------------\n")
printf("  Test Semi-Definite Programming  (SeDuMi)\n");
printf("--------------------------------------\n\n")
t = sdpvar(1,1);
Y = sdpvar(2,2,'symmetric');
Objective = t;
Constraints = [Y<=t*eye(2), Y>=[1 0.2;0.2 1]];
sol = optimize(Constraints,Objective,Options_sedumi);
check(Constraints);
% In this case, value(t)=1.2000 and value(Y)=[ 1.1000, 0.1000; 0.1000, 1.1000 ]
disp("t="),disp(value(t))
disp("Y="),disp(value(Y))

% Done
fclose(fhandle);
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
