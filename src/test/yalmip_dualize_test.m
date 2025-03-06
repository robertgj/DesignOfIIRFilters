% yalmip_dualize_test.m
% Copyright (C) 2021-2025 Robert G. Jenssen
%
% See  https://yalmip.github.io/command/dualize/ and
% "Dualize it: software for automatic primal and dual conversions of
% conic programs", J. Lofberg, Optimization Methods and Software, Vol. 24,
% No. 3, 2009, pp. 313-325

test_common;

delete("yalmip_dualize_test.diary");
delete("yalmip_dualize_test.diary.tmp");
diary yalmip_dualize_test.diary.tmp

tic;

strf="yalmip_dualize_test";

fid=fopen(strcat(strf,".results"),"w");

%
% Simple example
%
X = sdpvar(3,3);
Y = sdpvar(3,3);
F = [X>=0, Y>=0];
F = [F, X(1,3)==9, Y(1,1)==X(2,2)];
F = [F,sum(sum(X))+sum(sum(Y)) == 20];
obj = trace(X)+trace(Y);
% Primal
sol=optimize(F,obj);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
Xa=value(X);
Ya=value(Y);
fdisp(fid,"Xa=");fdisp(fid,Xa);
fprintf(fid,"isdefinite(Xa)=%d\n",isdefinite(Xa));
fdisp(fid,"Ya=");fdisp(fid,Ya);
fprintf(fid,"isdefinite(Ya)=%d\n",isdefinite(Ya));

% Alternatively
sol=optimize(F,obj,sdpsettings("dualize",1));
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
Xb=value(X);
Yb=value(Y);
fdisp(fid,"Xb=");fdisp(fid,Xb);
fprintf(fid,"isdefinite(Xb)=%d\n",isdefinite(Xb));
fdisp(fid,"Yb=");fdisp(fid,Yb);
fprintf(fid,"isdefinite(Yb)=%d\n",isdefinite(Yb));
fprintf(fid,"norm(Xa-Xb)=%9.4g\n",norm(Xa-Xb));
fprintf(fid,"norm(Ya-Yb)=%9.4g\n",norm(Ya-Yb));

%
% Control theory example
%
n = 50;
randn("seed",0xDEADC0DE)
A = randn(n);A = A - max(real(eig(A)))*eye(n)*1.5; % Stable dynamics
B = randn(n,1);
C = randn(1,n);
t = sdpvar(1,1);
P = sdpvar(n,n);
obj = t;
F = [kyp(A,B,P,blkdiag(C'*C,-t)) <= 0]

sol=optimize(F,obj)
ta=value(t)
fprintf(fid,"ta=%9.4g\n",ta);

[Fp,objp] = primalize(F,-obj);Fp
sol=optimize(Fp,objp)
tb=value(t)
fprintf(fid,"tb=%9.4g\n",tb);

sol=optimize(Fp,objp,sdpsettings("removeequalities",1))
tc=value(t)
fprintf(fid,"tc=%9.4g\n",tc);

fprintf(fid,"norm(ta-tb)=%9.4g\n",norm(ta-tb));
fprintf(fid,"norm(ta-tc)=%9.4g\n",norm(ta-tc));
fprintf(fid,"norm(tb-tc)=%9.4g\n",norm(tb-tc));

%
% Done
%
fclose(fid);
diary off
movefile yalmip_dualize_test.diary.tmp yalmip_dualize_test.diary;
