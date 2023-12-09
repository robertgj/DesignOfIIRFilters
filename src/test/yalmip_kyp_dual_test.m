% yalmip_kyp_dual_test.m
% Copyright (C) 2023 Robert G. Jenssen

test_common;

strf="yalmip_kyp_dual_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

tol=1e-11;

% Low-pass filter
M=3;N=2*M;fap=0.1;fas=0.2;
h=remez(2*M,2*[0,fap,fas,0.5],[1,1,0,0]);
h=h(:)';
[H,w]=freqz(h,1,1024);
max_H_2=max(abs(H))^2;
printf("max(abs(H))^2=%12.10f\n",max_H_2);
Esq=ceil(max_H_2*1e4)/1e4;

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
C=h(1:end-1);
D=h(end);
CD=[C,D;zeros(1,N),1];
Theta=(CD')*[1,0;0,-Esq]*CD;
Phi=[-1,0;0,1];

% Sanity check
[n,d]=Abcd2tf(A,B,C,D);
if abs(d(1)-1) > eps
  error("abs(d(1)-1) > eps");
endif
if max(abs(d(2:end)-zeros(1,N))) > eps
  error("max(abs(d(2:end)-zeros(1,N))) > eps");
endif
if max(abs(n-h)) > eps
  error("max(abs(n-h)) > eps");
endif

%
% Test the filter response with KYP
%
P=sdpvar(N,N,"symmetric","real");
F=Theta+((AB')*kron(Phi,P)*AB);
Constraints=[F<=0];
Objective=[];
Options=sdpsettings("solver","sedumi","dualize",1); 
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)

%
% Test the filter response with dual KYP
%
Z=sdpvar(N+1,N+1,"symmetric","real");
Z11=Z(1:N,1:N);  
Z12=Z(1:N,N+1);
Z22=Z(N+1,N+1);
dualF=(A*Z11*(A'))+(B*(Z12')*(A'))+(A*Z12*(B'))+(B*Z22*(B'))-Z11;
Constraints=[(-Z)>=0,dualF>=-tol,dualF<=tol,trace(Theta*Z)<=0];
Objective=[];
Options=sdpsettings("solver","sedumi");
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
if ~isdefinite(-value(Z))
  error("~isdefinite(-value(Z))");
endif
if max(max(abs(value(dualF))))>10*tol
  error("max(max(abs(value(dualF))))>10*tol");
endif
trace_Theta_Z=trace(Theta*value(Z));
printf("trace(Theta*value(Z))=%10.4g\n",trace_Theta_Z);
if trace_Theta_Z>tol
  error("trace(Theta*value(Z))>tol");
endif

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
