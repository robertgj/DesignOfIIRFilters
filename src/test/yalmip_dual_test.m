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

tol=1e-14;
Options=sdpsettings("solver","sedumi","sedumi.eps",tol);

% Primal
fprintf(fid,"\nPrimal problem:\n");
X=sdpvar(2,2,"symmetric");
Constraints=[X>=0,abs(X(1,1)-1)<=0,abs(X(2,2)-2)<=0];
Objective=trace(X*[0,1;1,0]);
sol=optimize(Constraints,Objective,Options)
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
if abs(value(Objective)+sqrt(8))>tol
  error("abs(value(Objective)+sqrt(8))(%g*tol)>tol", ...
        abs(value(Objective)+sqrt(8))/tol);
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
fprintf(fid,"Objective=%8.5f\n",value(Objective));
fprintf(fid,"X=");fdisp(fid,value(X));fprintf(fid,"\n");

% Dual
tol=1e-12;
Options=sdpsettings("solver","sedumi","sedumi.eps",tol);
fprintf(fid,"\nDual problem:\n");
y=sdpvar(1,2);
S=sdpvar(2,2,"symmetric");
Constraints=[S>=0,norm(S-[-y(1),1;1,-y(2)])<=0];
Objective=-(y(1)+(2*y(2)));
sol=optimize(Constraints,Objective,Options)
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
if abs(value(Objective)-sqrt(8))>tol
  error("abs(value(Objective)-sqrt(8))(%g*tol)>tol", ...
        abs(value(Objective)-sqrt(8))/tol);
endif
if abs((value(y)*[1;2])+sqrt(8))>tol
  error("abs((value(y)*[1;2])+sqrt(8))(%g*tol)>tol",
        abs((value(y)*[1;2])+sqrt(8))/tol);
endif
if max(abs(value(y)+sqrt([2,1/2])))>sqrt(tol)
  error("max(abs(value(y)+sqrt([2,1/2])))(%g*sqrt(tol))>sqrt(tol)",
        max(abs(value(y)+sqrt([2.1/2])))/sqrt(tol));
endif
fprintf(fid,"Objective=%8.5f\n",value(Objective));
fprintf(fid,"y=");fdisp(fid,value(y));fprintf(fid,"\n");

%
% Done
%
fclose(fid);
diary off
movefile yalmip_dual_test.diary.tmp yalmip_dual_test.diary;
