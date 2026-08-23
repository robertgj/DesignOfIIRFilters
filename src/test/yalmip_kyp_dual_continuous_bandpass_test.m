% yalmip_kyp_dual_continuous_bandpass_test.m
%
% See Wallin et al.:
%   http://www.control.isy.liu.se/research/reports/2003/2503.pdf
% and Lofberg:
%   https://yalmip.github.io/command/export

% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="yalmip_kyp_dual_continuous_bandpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Bandpass Butterworth filter
N=3;
fpl=0.5;
wpl=2*pi*fpl;
fpu=0.75;
wpu=2*pi*fpu;
wm=(wpu-wpl)/2;
wc=(wpu+wpl)/2;
[n,d]=butter(N,[wpl,wpu],"bandpass","s");
scale=2;
scaleSq=scale^2;
n=n*scale;
f=0:0.001:1.5;
w=2*pi*f;
H=freqs(n,d,w);
max_abs_Asq=max(abs(H).^2);
[A,B,C,D]=tf2ss(n,d);
NN=rows(A);

%
% Test the filter response with continuous time KYP
%
printf("\n\nTest continuous time KYP:\n")
P=sdpvar(NN,NN,"symmetric","real");
Q=sdpvar(NN,NN,"symmetric","real");
Esq=sdpvar(1,1,"full","real");
AB=[A,B;eye(NN),zeros(NN,1)];
CD=[C,D;zeros(1,columns(A)),1];
Theta0=(CD')*[[1,0];[0,-scaleSq]]*CD;
Theta1=(CD')*[[0,0];[0,-1]]*CD;
Theta=Theta0+(Theta1*Esq);
Phi=[0,1;1,0];
Psi=[[-1,j*wc];[-j*wc,-wpl*wpu]];
F=((AB')*(kron(Phi,P)+kron(Psi,Q))*AB)+Theta;
Constraints=[F<=0,Q>=0,Esq>=0];
Objective=[Esq];
Options=sdpsettings("solver","sedumi"); 
sol=optimize(Constraints,Objective,Options);
if sol.problem
  warning("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
KYP_Esq=value(Esq);
printf("KYP_Esq=%g\n",KYP_Esq);
tol=1e-5;
if KYP_Esq>tol
  error("abs(KYP_Esq)(%g*tol)>tol", KYP_Esq/tol);
endif
if abs(KYP_Esq)>tol
  error("abs(KYP_Esq)(%g*tol)>tol",abs(KYP_Esq)/tol);
endif

%
% Test the filter response with dual KYP
%
printf("\n\nTest continuous time dual KYP:\n")
Z11=sdpvar(NN,NN,"symmetric","real");
Z12=sdpvar(NN,1,"full","real");
Z22=sdpvar(1,1,"full","real");
Z=[[Z11,Z12];[Z12',Z22]];
Padj=(A*Z11)+(Z11*(A'))+(B*(Z12'))+(Z12*(B'));
Qadj=-(A*Z11*(A'))-(wpl*wpu*Z11)-(B*(Z12')*(A'))-(A*Z12*(B')) ...
     -j*wc*((A*Z11)-(Z11*(A'))-(B*(Z12'))-(Z12*(B')));
Constraints=[Z>=0,Qadj==0,Padj==0,trace(Theta1*Z)==-1];
Objective=[-trace(Theta0*Z)];
Options=sdpsettings("solver","sedumi");
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
tol=1e-8;
dual_KYP_Asq=value(Objective);
printf("\ndual_KYP_Asq=%10.4g\n",dual_KYP_Asq);
if (dual_KYP_Asq - max_abs_Asq) > tol
  error("(dual_KYP_Asq - max_abs_Asq)(%g*tol) > tol", ...
        (dual_KYP_Asq - max_abs_Asq)/tol);
endif
if abs(dual_KYP_Asq - max_abs_Asq) > tol
  error("abs(dual_KYP_Asq - max_abs_Asq)(%g*tol) > tol", ...
        abs(dual_KYP_Asq - max_abs_Asq)/tol);
endif
if any(eigs(value(Z),rows(Z)) < -tol)
  error("any(eigs(value(Z),rows(Z)) < -tol)");
endif
printf("max(max(abs(value(Padj))))=%g\n",max(max(abs(value(Padj)))));
if max(max(abs(value(Padj))))>tol
  error("max(max(abs(value(Padj))))(%g*tol)>tol", ...
        max(max(abs(value(Padj))))/tol);
endif
printf("max(max(abs(value(Qadj))))=%g\n",max(max(abs(value(Qadj)))));
if max(max(abs(value(Qadj))))>tol
  error("max(max(abs(value(Qadj))))(%g*tol)>tol", ...
        max(max(abs(value(Qadj))))/tol);
endif
trace_Theta0_Z=trace(value(Theta0*Z));
printf("trace(value(Theta0*Z))=%10.4g\n",trace_Theta0_Z);
if trace(value(Theta0*Z)) > 10*tol
  error("trace(value(Theta0*Z))(%g*tol) > 10*tol", ...
        trace(value(Theta0*Z))/tol);
endif

% Find primal and dual solutions
printf("\n\nTest continuous time YALMIP recovered dual KYP:\n")

DualConstraints=[Z>=0,Padj==0,Z(NN+1,NN+1)==1];
DualObjective=-Z(NN,NN);
[DualModel,RecoveryModel]=export(DualConstraints,DualObjective,Options);
[x,y,info]=sedumi(DualModel.A,DualModel.b,DualModel.C,DualModel.K);
% Show objectives
tol=1e-5;
printf("\nPrimal objective: DualModel.C'*x=%g\n",DualModel.C'*x);
printf("Dual objective: DualModel.b'*y=%g\n",DualModel.b'*y);
if abs(((DualModel.C)'*x)-((DualModel.b)'*y)) > tol
  error("abs(DualModel.C'*x-DualModel.b'*y)(%g*tol) > tol", ...
        abs(((DualModel.C)'*x)-((DualModel.b)'*y))/tol);
endif

Y=triu(ones(NN+1,NN+1));Y(Y==1)=y;Y=Y+triu(Y,1)';
printf("Dual objective: trace(Y*Theta0)=%g\n",trace(Y*Theta0));
if abs(((DualModel.C)'*x)-trace(Y*Theta0)-scaleSq) > tol
  error("abs(DualModel.C'*x-trace(Y*Theta0)-scaleSq)(%g*tol) > tol", ...
        abs(((DualModel.C)'*x)-trace(Y*Theta0)-scaleSq)/tol);
endif

if ((DualModel.C'*x)-max_abs_Asq) > 10*tol
  error("((DualModel.C'*x)-max_abs_Asq)(%g*tol) > 10*tol", ...
        ((DualModel.C'*x)-max_abs_Asq)/tol);
endif

%
% Test the filter response with the reduced complexity dual KYP
%
printf("\n\nTest continuous time dual reduced complexity KYP:\n")
Fk=cell(1,NN+1);
for k=1:NN
  Ek12=zeros(NN,1);
  Ek12(k)=1;
  Ek11=lyap(A,(Ek12*(B'))+(B*(Ek12')));
  Fk{k}=sparse([[Ek11,Ek12];[Ek12',0]]);
endfor
Fk{NN+1}=sparse([zeros(NN,NN+1);[zeros(1,NN),1]]);
z=sdpvar(1,NN+1,"full","real");
ZR=zeros(NN+1);
for l=1:(NN+1),
  ZR=ZR+(z(l)*Fk{l});
endfor
ZR11=ZR(1:NN,1:NN);
ZR12=ZR(1:NN,NN+1);
ZR22=ZR(NN+1,NN+1);
Padj=(A*ZR11)+(ZR11*(A'))+(B*(ZR12'))+(ZR12*(B'));
Qadj=-((A*ZR11*(A'))+(wpl*wpu*ZR11)+(B*(ZR12')*(A'))+(A*ZR12*(B'))) ...
     +j*wc*((B*(ZR12'))+(ZR12*(B'))) -j*wc*((A*ZR11)-(ZR11*(A')));
Constraints=[ZR>=0,Qadj==0,Padj==0,trace(Theta1*ZR)==-1];
Objective=[-trace(Theta0*ZR)];
Options=sdpsettings("solver","sedumi"); 
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
reduced_dual_KYP_Asq=value(Objective);
printf("\nreduced_dual_KYP_Asq=%g\n",reduced_dual_KYP_Asq);

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
