% yalmip_kyp_dual_test.m
% Copyright (C) 2023 Robert G. Jenssen

test_common;

strf="yalmip_kyp_dual_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

pkg load symbolic optim

tic;

% Low-pass filter
M=15;N=2*M;fap=0.1;fas=0.2;
h=remez(2*M,2*[0,fap,fas,0.5],[1,1,0,0]);
h=h(:)';
[H,w]=freqz(h,1,1024);
printf("max(abs(H))^2)=%10.8f\n",max(abs(H))^2) % 1.00305929
Esq=1.0030595;
tol=1e-12;

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
C=h(1:end-1);
D=h(end);
CD=[C,D;zeros(1,N),1];
Theta=(CD')*[1,0;0,-Esq]*CD;
Phi=[-1,0;0,1];
Psi=[0,1;1,2];

%
% Test the filter response with KYP
%
P=sdpvar(N,N,"symmetric","real");
F=Theta+((AB')*kron(Phi,P)*AB);
Constraints=[F<=tol];
Objective=[];
Options=sdpsettings("solver","sdpt3");
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
if trace(Theta*value(Z))>tol
  error("trace(Theta*value(Z))>tol");
endif

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
