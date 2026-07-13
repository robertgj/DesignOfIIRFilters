% yalmip_kyp_dual_continuous_test.m
%
% See Wallin et al.:
%   http://www.control.isy.liu.se/research/reports/2003/2503.pdf
% and Lofberg:
%   https://yalmip.github.io/command/export

% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="yalmip_kyp_dual_continuous_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

tol=1e-11;

% Low-pass Butterworth filter
n=3;
fc=0.5;
wc=2*pi*fc;
[N,D]=butter(n,2*pi*fc,"s");
N=N*2;
f=0:0.001:1;
w=2*pi*f;
nc=((length(w)-1)*fc/max(f))+1;
H=freqs(N,D,w);
max_abs_Asq=max(abs(H).^2);
if abs(abs(H(nc))-sqrt(2)) > 10*eps
  error("abs(abs(H(nc))-sqrt(2))(%g*eps) > 10*eps",abs(abs(H(nc)-sqrt(2)))/eps);
endif
[a,b,c,d]=tf2ss(N,D);

%
% Test the filter response with continuous time KYP
%
P=sdpvar(n,n,"symmetric","real");
Asq=sdpvar(1,1,"full","real");
ab=[a,b;eye(n),zeros(n,1)];
cd=[c,d;zeros(1,n),1];
Theta0=(cd')*[[1,0];[0,0]]*cd;
Theta1=(cd')*[[0,0];[0,-1]]*cd;
Theta=Theta0+(Theta1*Asq);
Phi=[0,1;1,0];
F=((ab')*kron(Phi,P)*ab)+Theta;
Constraints=[F<=tol,Asq>=0];
Objective=[Asq];
Options=sdpsettings("solver","sedumi"); 
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
KYP_Asq=value(Asq);
if (KYP_Asq-max_abs_Asq)>10*tol
  error("(KYP_Asq-max_abs_Asq)(%g*tol)>10*tol", ...
        (KYP_Asq-max_abs_Asq)/tol);
endif

%
% Test the filter response with dual KYP
%
Asq=sdpvar(1,1,"full","real");
Z11=sdpvar(n,n,"symmetric","real");
Z12=sdpvar(n,1,"full","real");
Z22=sdpvar(1,1,"full","real");
Z=[[Z11,Z12];[Z12',Z22]];
dualF=(a*Z11)+(Z11*(a'))+(b*(Z12'))+(Z12*(b'));
Constraints=[Z>=0,0<=dualF<=0,-1<=trace(Theta1*Z)<=-1];
Objective=[-trace(Theta0*Z)];
Options=sdpsettings("solver","sedumi");
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
if any(eigs(value(Z),rows(Z)) < -100*tol)
  error("any(eigs(value(Z),rows(Z)) < -100*tol)");
endif
printf("max(max(abs(value(dualF))))=%g\n",max(max(abs(value(dualF)))));
if max(max(abs(value(dualF))))>10*tol
  error("max(max(abs(value(dualF))))(%g*tol)>10*tol",
        max(max(abs(value(dualF))))/tol);
endif
trace_Theta0_Z=trace(value(Theta0*Z));
printf("trace(value(Theta0*Z))=%10.4g\n",trace_Theta0_Z);
if (trace(value(Theta0*Z))-max_abs_Asq) > 1000*tol
  error("(trace(value(Theta0*Z))-max_abs_Asq)(%g*tol) > 1000*tol", ...
        (trace(value(Theta0*Z))-max_abs_Asq)/tol);
endif

% Find primal and dual solutions
DualConstraints=[Z>=0,0<=dualF<=0,-1<=-Z(n+1,n+1)<=-1];
DualObjective=-Z(n,n);
[DualModel,RecoveryModel]=export(DualConstraints,DualObjective,Options);
[x,y,info]=sedumi(DualModel.A,DualModel.b,DualModel.C,DualModel.K);

% Show objectives
printf("Primal objective: DualModel.C'*x=%g\n",DualModel.C'*x);
printf("Dual objective: DualModel.b'*y=%g\n",DualModel.b'*y);
if abs(((DualModel.C)'*x)-((DualModel.b)'*y)) > 1e4*tol
  error("abs(DualModel.C'*x-DualModel.b'*y)(%g*tol) > 1e4*tol", ...
        abs(((DualModel.C)'*x)-((DualModel.b)'*y)));
endif

Y=triu(ones(n+1,n+1));Y(Y==1)=y;Y=Y+triu(Y,1)';
printf("Dual objective: trace(Y*Theta0)=%g\n",trace(Y*Theta0));
if abs(((DualModel.C)'*x)-trace(Y*Theta0)) > 1e4*tol
  error("abs(DualModel.C'*x-trace(Y*Theta0))(%g*tol) > 1e4*tol", ...
        abs(((DualModel.C)'*x)-trace(Y*Theta0)));
endif

if ((DualModel.C'*x)-max_abs_Asq) > 1e4*tol
  error("((DualModel.C'*x)-max_abs_Asq)(%g*tol) > 1e4*tol", ...
        ((DualModel.C'*x)-max_abs_Asq)/tol);
endif

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
