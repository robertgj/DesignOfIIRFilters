% yalmip_kyp_dual_test.m
%
% Check the dual of the discrete-time KYP lemma

% Copyright (C) 2022-2026 Robert G. Jenssen

test_common;

strf="yalmip_kyp_dual_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

tol=1e-10;

% Low-pass filter
M=10;N=2*M;fap=0.1;fas=0.2;
h=remez(2*M,2*[0,fap,fas,0.5],[1,1,0,0]);
h=h(:)';
[H,w]=freqz(h,1,1024);
max_H_2=max(abs(H))^2;
H_Esq=(ceil(max_H_2/1e-8)*1e-8)-1;

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
C=h(1:end-1);
D=h(end);
CD=[C,D;zeros(1,N),1];

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
Esq=sdpvar(1,1,"symmetric","real");
Theta0=(CD')*[[1,0];[0,-1]]*CD;
Theta1=(CD')*[[0,0];[0,-1]]*CD;
Phi=[-1,0;0,1];
F=((AB')*kron(Phi,P)*AB)+Theta0+(Theta1*Esq);
Constraints=[F<=0,Esq>=0];
Objective=Esq;
% The YALMIP default setting for "dualize" is false
Options=sdpsettings("solver","sedumi", ...
                    "dualize",true, ...
                    "saveduals",true, ...
                    "saveyalmipmodel",true, ...
                    "savesolverinput",true, ...
                    "savesolveroutput",true);
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
KYP_Esq=value(Esq);
printf("H_Esq=%10.8f, KYP Esq=%10.8f\n",H_Esq,KYP_Esq);
printf("KYP_Esq-H_Esq=%10.8f\n",KYP_Esq-H_Esq);
if KYP_Esq < H_Esq
  error("(KYP_Esq < H_Esq");
endif
if (KYP_Esq-H_Esq) > 1e4*tol
  error("(KYP_Esq-H_Esq)(%g*tol) > 1e4*tol",(KYP_Esq-H_Esq)/tol);
endif


%
% Test the filter response with dual KYP
%
Theta0=(CD')*[[1,0];[0,0]]*CD;
Theta1=(CD')*[[0,0];[0,-1]]*CD;
Z=sdpvar(N+1,N+1,"symmetric","real");
Z11=Z(1:N,1:N);  
Z12=Z(1:N,N+1);
Z22=Z(N+1,N+1);
dualF=(A*Z11*(A'))+(B*(Z12')*(A'))+(A*Z12*(B'))+(B*Z22*(B'))-Z11;
Constraints=[Z>=0,0<=dualF<=0,-1<=trace(Theta1*Z)<=-1];
Objective=[-trace(Theta0*Z)];
Options=sdpsettings("solver","sedumi","dualize",false);
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
if ~isdefinite(value(Z))
  error("~isdefinite(value(Z))");
endif
printf("max(max(abs(value(dualF))))=%10.4g\n",max(max(abs(value(dualF)))));
if max(max(abs(value(dualF))))>20*tol
  error("max(max(abs(value(dualF))))>20*tol");
endif
Dual_Esq=-value(Objective)-1;
printf("Dual_Esq=%10.8f\n",Dual_Esq);
printf("Dual_Esq-H_Esq=%10.8f\n",Dual_Esq-H_Esq);
trace_Theta0_Z=trace(Theta0*value(Z));
printf("trace(Theta0*value(Z))-1=%10.4g\n",trace_Theta0_Z-1);
if Dual_Esq < H_Esq
  error("(Dual_Esq < H_Esq");
endif
if abs(Dual_Esq-KYP_Esq) > 200*tol
  error("abs(Dual_Esq-KYP_Esq)(%g*tol) > 200*tol",abs(Dual_Esq-KYP_Esq)/tol);
endif

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
