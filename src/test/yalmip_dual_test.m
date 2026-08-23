% yalmip_dual_test.m
% Copyright (C) 2021-2026 Robert G. Jenssen
%
% Primal:
%  minimise    X(1,2)+X(2,1)
%  subject to  X>=0, X(1,1)=1, X(2,2)=2, 
%
% X=[1, -sqrt(2); -sqrt(2), 2]
%
% Dual:
%  maximise    y(1)+2*y(2)
%  subject to  S>=0, S=[-y1, 1; 1, -y2]
%
% y=[-sqrt(2),-sqrt(1/2)]

test_common;

delete("yalmip_dual_test.diary");
delete("yalmip_dual_test.diary.tmp");
diary yalmip_dual_test.diary.tmp

strf="yalmip_dual_test";

fid=fopen(strcat(strf,".results"),"w");

CommonOptions=sdpsettings("solver","sedumi", ...
                          "saveduals",true, ...
                          "saveyalmipmodel",true, ...
                          "savesolverinput",true, ...
                          "savesolveroutput",true);

% Primal
tol=1e-14;
fprintf(fid,"\nPrimal problem:\n");
X=sdpvar(2,2,"symmetric");
Constraints_primal=[X>=0,abs(X(1,1)-1)<=0,abs(X(2,2)-2)<=0];
Objective_primal=trace(X*[0,1;1,0]);
Options_primal=sdpsettings(CommonOptions,"sedumi.eps",tol);
sol_primal=optimize(Constraints_primal,Objective_primal,Options_primal);
if sol_primal.problem
  error("YALMIP failed : %s",sol.info);
endif
if abs(value(Objective_primal)+sqrt(8))>tol
  error("abs(value(Objective_primal)+sqrt(8))(%g*tol)>tol", ...
        abs(value(Objective_primal)+sqrt(8))/tol);
endif
if abs(value(X(1,1)-1))>tol
  error("abs(value(X(1,1)-1))(%g*tol)>tol",abs(value(X(1,1)-1))/tol);
endif
if abs(value(X(2,2)-2))>tol
  error("abs(value(X(2,2)-2))(%g*tol)>tol",abs(value(X(2,2)-2))/tol);
endif
if abs(value(X(1,2)-X(2,1)))>tol
  error("abs(value(X(1,2)-X(2,1)))(%g*tol)>tol",
        abs(value(X(1,2)-X(2,1)))/tol);
endif
if abs(value(X(1,2))+sqrt(2))>tol
  error("abs(value(X(1,2)+sqrt(2)))(%g*tol)>tol",
        abs(value(X(1,2))-sqrt(2))/tol);
endif
fprintf(fid,"Objective_primal=%8.5f\n",value(Objective_primal));
fprintf(fid,"X=");fdisp(fid,value(X));fprintf(fid,"\n");

% Dual
tol=1e-12;
fprintf(fid,"\nDual problem:\n");
y=sdpvar(1,2);
S=sdpvar(2,2,"symmetric");
Constraints_dual=[S>=0,norm(S-[-y(1),1;1,-y(2)])<=0];
Objective_dual=-(y(1)+(2*y(2)));
Options_dual=sdpsettings(CommonOptions,"sedumi.eps",tol);
sol_dual=optimize(Constraints_dual,Objective_dual,Options_dual);
if sol_dual.problem
  error("YALMIP failed : %s",sol.info);
endif
if abs(value(Objective_dual)-sqrt(8))>tol
  error("abs(value(Objective_dual)-sqrt(8))(%g*tol)>tol", ...
        abs(value(Objective_dual)-sqrt(8))/tol);
endif
if abs((value(y)*[1;2])+sqrt(8))>tol
  error("abs((value(y)*[1;2])+sqrt(8))(%g*tol)>tol",
        abs((value(y)*[1;2])+sqrt(8))/tol);
endif
if max(abs(value(y)+sqrt([2,1/2])))>sqrt(tol)
  error("max(abs(value(y)+sqrt([2,1/2])))(%g*sqrt(tol))>sqrt(tol)",
        max(abs(value(y)+sqrt([2.1/2])))/sqrt(tol));
endif
fprintf(fid,"Objective_dual=%8.5f\n",value(Objective_dual));

if max(max(abs(dual(Constraints_dual(1))-value(X))))>tol
  error("max(max(abs(dual(Constraints_dual(1))-value(X))))(%g*tol) > tol", ...
        max(max(abs(dual(Constraints_dual(1))-value(X))))/tol);
endif

fprintf(fid,"y=");fdisp(fid,value(y));fprintf(fid,"\n");

%
% Done
%
fclose(fid);
diary off
movefile yalmip_dual_test.diary.tmp yalmip_dual_test.diary;
