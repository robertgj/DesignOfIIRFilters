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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Low-pass filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=20;fap=0.1;fas=0.2;
h=remez(N,2*[0,fap,fas,0.5],[1,1,0,0]);
h=h(:)';
[H,w]=freqz(h,1,2^16);
H_Esq=(max(abs(H))^2)-1;
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid, "%d'th order symmetric FIR filter & %16.8g & &\\\\\n", N,H_Esq);
% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
C=h(1:end-1);
D=h(end);
CD=[C,D;zeros(1,N),1];
Theta0=(CD')*[[1,0];[0,-1]]*CD;
Theta1=(CD')*[[0,0];[0,-1]]*CD;

% Sanity check
[n,d]=Abcd2tf(A,B,C,D);
if max(abs(n-h)) > eps
  error("max(abs(n-h)) > eps");
endif
if max(abs(d-[1,zeros(1,N)])) > eps
  error("max(abs(d-[1,zeros(1,N)]))(%g*eps) > eps", ...
        max(abs(d-[1,zeros(1,N)]))/eps);
endif

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test the filter maximum amplitude response with the discrete-time KYP lemma
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P=sdpvar(N,N,"symmetric","real");
Esq=sdpvar(1,1,"symmetric","real");
Phi=[-1,0;0,1];
F=((AB')*kron(Phi,P)*AB)+Theta0+(Theta1*Esq);
Constraints=[F<=0,Esq>=0];
Objective=Esq;
% The YALMIP default setting for "dualize" is false
Options=sdpsettings("solver","sedumi", ...
                    "saveduals",true, ...
                    "saveyalmipmodel",true, ...
                    "savesolverinput",true, ...
                    "savesolveroutput",true);
sol=optimize(Constraints,Objective,sdpsettings(Options,"dualize",true));
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
value(Objective)
KYP_Esq=value(Esq);
printf("H_Esq=%10.8f, KYP Esq=%10.8f\n",H_Esq,KYP_Esq);
printf("KYP_Esq-H_Esq=%10.8f\n",KYP_Esq-H_Esq);
if KYP_Esq < H_Esq
  error("(KYP_Esq < H_Esq");
endif
if (KYP_Esq-H_Esq) > 1e4*tol
  error("(KYP_Esq-H_Esq)(%g*tol) > 1e4*tol",(KYP_Esq-H_Esq)/tol);
endif

fprintf(fid,"KYP lemma & %16.8g & %10.6f & %d\\\\\n", ...
        KYP_Esq,sol.solvertime,nnz(sol.solverinput.A)); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test the filter maximum amplitude response with
% the dual of the discrete-time KYP lemma
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Z=sdpvar(N+1,N+1,"symmetric","real");
Z11=Z(1:N,1:N);  
Z12=Z(1:N,N+1);
Z22=Z(N+1,N+1);
dualF=(A*Z11*(A'))+(B*(Z12')*(A'))+(A*Z12*(B'))+(B*Z22*(B'))-Z11;
Constraints=[Z>=0,dualF==0,trace(Theta1*Z)==-1];
Objective=[-trace(Theta0*Z)];
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
value(Objective)
if ~isdefinite(value(Z))
  error("~isdefinite(value(Z))");
endif
printf("max(max(abs(value(dualF))))=%10.4g\n",max(max(abs(value(dualF)))));
if max(max(abs(value(dualF))))>20*tol
  error("max(max(abs(value(dualF))))>20*tol");
endif
Dual_Esq=-value(Objective);
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

fprintf(fid,"Dual of KYP lemma & %16.8g & %10.6f & %d \\\\\n", ...
        Dual_Esq,sol.solvertime,nnz(sol.solverinput.A)); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test the filter maximum amplitude response with
% the reduced complexity dual of the discrete-time KYP lemma
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Find a basis for Z
%
Fk=cell(1,N+1);
for k=1:N
  Ek12=zeros(N,1);
  Ek12(k)=1;
  Ek11=dlyap(A,(B*(Ek12')*(A'))+(A*Ek12*(B')));
  Fk{k}=sparse([[Ek11,Ek12];[Ek12',0]]);
endfor
Ek11=dlyap(A,(B*(B')));
Fk{N+1}=sparse([[Ek11,zeros(N,1)];[zeros(1,N),1]]);

%
% Solve the reduced dual of the discrete-time KYP problem
%
z=sdpvar(1,N+1,"full","real");
ZR=zeros(N+1);
for l=1:(N+1),
  ZR=ZR+(z(l)*Fk{l});
endfor
ZR11=ZR(1:N,1:N);
ZR12=ZR(1:N,N+1);
ZR22=ZR(N+1,N+1);
dualF=(A*ZR11*(A'))+ ...
      (B*(ZR12')*(A'))+(A*ZR12*(B'))+ ...
      (B*ZR22*(B'))-ZR11;
Constraints=[ZR>=0,dualF==0,trace(Theta1*ZR)==-1];
Objective=[-trace(Theta0*ZR)];
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)

Reduced_Dual_Esq=-value(Objective);
if Reduced_Dual_Esq < H_Esq
  error("Reduced_Dual_Esq < H_Esq");
endif

printf("max(max(abs(value(dualF))))=%10.4g\n",max(max(abs(value(dualF)))));
if max(max(abs(value(dualF))))>20*tol
  error("max(max(abs(value(dualF))))>20*tol");
endif

sort(eigs(value(ZR),N+1)',"descend");
if min(eigs(value(ZR),N+1)) < -tol
  error("min(eigs(value(ZR),N+1))(%g*tol) < -tol", ...
        min(eigs(value(ZR),N+1))/tol);
endif

fprintf(fid,"Reduced dual of KYP lemma & %16.8g & %10.6f & %d \\\\\n", ...
        Reduced_Dual_Esq,sol.solvertime,nnz(sol.solverinput.A)); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test the filter maximum amplitude response with the dual of the
% discrete-time KYP lemma after a similarity transformation of the filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Apply a similarity transformation, T, so that CT=ones(size(C))
% 
invT=diag(C);
T=inv(invT);
invT_A_T=invT*A*T;
invT_B=invT*B;
CT=ones(size(C));
% Sanity check
[n,d]=Abcd2tf(invT_A_T,invT_B,CT,D);
if max(abs(n-h)) > eps
  error("max(abs(n-h))(%g*eps) > eps",max(abs(n-h))/eps);
endif
if max(abs(d-[1,zeros(1,N)])) > eps
  error("max(abs(d-[1,zeros(1,N)]))(%g*eps) > eps", ...
        max(abs(d-[1,zeros(1,N)]))/eps);
endif
CTD=[CT,D;zeros(1,N),1];
ThetaT0=(CTD')*[[1,0];[0,-1]]*CTD;
ThetaT1=(CTD')*[[0,0];[0,-1]]*CTD;

%
% Find the basis matrixes of Z
%
Fk=cell(1,N+1);
for k=1:N
  Ek12=zeros(N,1);
  Ek12(k)=1;
  Ek11=dlyap(invT_A_T,(invT_B*(Ek12')*(invT_A_T'))+(invT_A_T*Ek12*(invT_B')));
  Fk{k}=sparse([[Ek11,Ek12];[Ek12',0]]);
endfor
Ek11=dlyap(invT_A_T,invT_B*(invT_B'));
Fk{N+1}=sparse([[Ek11,zeros(N,1)];[zeros(1,N),1]]);

%
% Solve the reduced dual of the discrete-time KYP problem
%
z=sdpvar(1,N+1,"full","real");
ZR=zeros(N+1);
for l=1:(N+1),
  ZR=ZR+(z(l)*Fk{l});
endfor
ZR11=ZR(1:N,1:N);
ZR12=ZR(1:N,N+1);
ZR22=ZR(N+1,N+1);
dualF=(invT_A_T*ZR11*(invT_A_T'))+ ...
      (invT_B*(ZR12')*(invT_A_T'))+(invT_A_T*ZR12*(invT_B'))+ ...
      (invT_B*ZR22*(invT_B'))-ZR11;
Constraints=[ZR>=0,dualF==0,trace(ThetaT1*ZR)==-1];
Objective=[-trace(ThetaT0*ZR)];
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
nnz(sol.solverinput.A)

% Sanity checks
check(Constraints)
Reduced_Dual_Esq=-value(Objective);
if Reduced_Dual_Esq < H_Esq
  error("Reduced_Dual_Esq < H_Esq");
endif

printf("max(max(abs(value(dualF))))=%10.4g\n",max(max(abs(value(dualF)))));
if max(max(abs(value(dualF))))>20*tol
  error("max(max(abs(value(dualF))))>20*tol");
endif

sort(eigs(value(ZR),N+1)',"descend");
if min(eigs(value(ZR),N+1)) < -tol
  error("min(eigs(value(ZR),N+1))(%g*tol) < -tol", ...
        min(eigs(value(ZR),N+1))/tol);
endif

fprintf(fid, ...
        "Reduced dual of KYP lemma (similarity)&%16.8g & %10.6f&%d\\\\\n", ...
        Reduced_Dual_Esq,sol.solvertime,nnz(sol.solverinput.A)); 
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find YALMIP solvertime for dual and reduced dual of an order N FIR filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
solvertime=[];
yalmiptime=[];
nnz_sedumi_A=[];
numel_sedumi_A=[];
NN=[];
sol_problem=false;

reduced_solvertime=[];
reduced_yalmiptime=[];
reduced_nnz_sedumi_A=[];
reduced_numel_sedumi_A=[];
reduced_NN=[];

reduced_Options=Options;
for N=10:10:90
  fap=0.1;fas=0.2;
  h=remez(N,2*[0,fap,fas,0.5],[1,1,0,0],[1,10]);
  h=h(:)';
  [H,w]=freqz(h,1,2^16);
  H_Esq=(max(abs(H))^2)-1;

  % Common constants
  A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
  B=[zeros(N-1,1);1];
  AB=[A,B;eye(N),zeros(N,1)];
  C=h(1:end-1);
  D=h(end);
  CD=[C,D;zeros(1,N),1];
  Theta0=(CD')*[[1,0];[0,-1]]*CD;
  Theta1=(CD')*[[0,0];[0,-1]]*CD;

  %
  % Solve the dual KYP problem
  %
  Z=sdpvar(N+1,N+1,"symmetric","real");
  Z11=Z(1:N,1:N);  
  Z12=Z(1:N,N+1);
  Z22=Z(N+1,N+1);
  dualF=(A*Z11*(A'))+(B*(Z12')*(A'))+(A*Z12*(B'))+(B*Z22*(B'))-Z11;
  Constraints=[Z>=0,dualF==0,trace(Theta1*Z)==-1];
  Objective=[-trace(Theta0*Z)];
  if sol_problem == false
    sol=optimize(Constraints,Objective,Options);
  endif
  if sol.problem
    sol_problem = true;
    warning("YALMIP failed : %s",sol.info);
  else
    % Sanity checks
    check(Constraints)
    printf("max(max(abs(value(dualF))))=%10.4g\n",max(max(abs(value(dualF)))));
    if max(max(abs(value(dualF))))>20*tol
      error("max(max(abs(value(dualF))))>20*tol");
    endif
    sort(eigs(value(Z),N+1)',"descend");
    if min(eigs(value(Z),N+1)) < -tol
      error("min(eigs(value(Z),N+1))(%g*tol) < -tol", ...
            min(eigs(value(Z),N+1))/tol);
    endif
    printf("Dual,N=%d,value(Objective)=%16.10g,expected=%16.10g\n", ...
           N,value(Objective),H_Esq);
    printf("Dual,N=%d,sol.solvertime=%g\n",N,sol.solvertime);
    printf("Dual,N=%d,sol.yalmiptime=%g\n",N,sol.yalmiptime);
    printf("Dual,N=%d,numel(sol.solverinput.A)=%d\n", ...
           N,numel(sol.solverinput.A));
    printf("Dual,N=%d,nnz(sol.solverinput.A)=%d\n", ...
           N,nnz(sol.solverinput.A));
    solvertime=[solvertime, sol.solvertime];
    yalmiptime=[yalmiptime, sol.yalmiptime];
    nnz_sedumi_A=[nnz_sedumi_A,nnz(sol.solverinput.A)]; 
    numel_sedumi_A=[numel_sedumi_A,numel(sol.solverinput.A)];
    NN=[NN,N];
  endif

  %
  % Solve the reduced dual KYP problem
  %
  Fk=cell(1,N+1);
  for k=1:N
    Ek12=zeros(N,1);
    Ek12(k)=1;
    Ek11=dlyap(A,(B*(Ek12')*(A'))+(A*Ek12*(B')));
    Fk{k}=sparse([[Ek11,Ek12];[Ek12',0]]);
  endfor
  Ek11=dlyap(A,(B*(B')));
  Fk{N+1}=sparse([[Ek11,zeros(N,1)];[zeros(1,N),1]]);
  z=sdpvar(1,N+1,"full","real");
  ZR=zeros(N+1);
  for l=1:(N+1),
    ZR=ZR+(z(l)*Fk{l});
  endfor
  ZR11=ZR(1:N,1:N);
  ZR12=ZR(1:N,N+1);
  ZR22=ZR(N+1,N+1);
  dualF=(A*ZR11*(A'))+ ...
        (B*(ZR12')*(A'))+(A*ZR12*(B'))+ ...
        (B*ZR22*(B'))-ZR11;
  Constraints=[ZR>=0,dualF==0,trace(Theta1*ZR)==-1];
  Objective=[-trace(Theta0*ZR)];
  reduced_sol=optimize(Constraints,Objective,reduced_Options);
  if reduced_sol.problem
    error("YALMIP failed : %s",sol.info);
  else
    check(Constraints);
    printf("max(max(abs(value(dualF))))=%10.4g\n",max(max(abs(value(dualF)))));
    if max(max(abs(value(dualF))))>20*tol
      error("max(max(abs(value(dualF))))>20*tol");
    endif
    sort(eigs(value(ZR),N+1)',"descend");
    if min(eigs(value(ZR),N+1)) < -tol
      error("min(eigs(value(ZR),N+1))(%g*tol) < -tol", ...
            min(eigs(value(ZR),N+1))/tol);
    endif
    printf("Dual,reduced,N=%d,value(Objective)=%16.10g,expected=%16.10g\n", ...
           N,value(Objective),H_Esq);
    printf("Dual,reduced,N=%d,sol.solvertime=%g\n",N,reduced_sol.solvertime);
    printf("Dual,reduced,N=%d,sol.yalmiptime=%g\n",N,reduced_sol.yalmiptime);
    printf("Dual,reduced,N=%d,numel(sol.solverinput.A)=%d\n", ...
           N,numel(reduced_sol.solverinput.A));
    printf("Dual,reduced,N=%d,nnz(sol.solverinput.A)=%d\n", ...
           N,nnz(reduced_sol.solverinput.A));
    reduced_solvertime=[reduced_solvertime, reduced_sol.solvertime];
    reduced_yalmiptime=[reduced_yalmiptime, reduced_sol.yalmiptime];
    reduced_nnz_sedumi_A=[reduced_nnz_sedumi_A,nnz(reduced_sol.solverinput.A)]; 
    reduced_numel_sedumi_A=[reduced_numel_sedumi_A, ...
                            numel(reduced_sol.solverinput.A)];
    reduced_NN=[reduced_NN,N];
  endif
endfor

loglog(reduced_NN,reduced_nnz_sedumi_A,"-",NN,nnz_sedumi_A,"--");
legend("Reduced Dual KYP","Dual KYP");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
ylabel("nnz(solverinput.A)");
xlabel("FIR filter order N");
title(sprintf("h=remez(N,2*[0,%4.2f,%4.2f,0.5],[1,1,0,0],[1,10]);",fap,fas));
print(strcat(strf,"_nnz"),"-dpdflatex");
close;

loglog(reduced_NN,reduced_solvertime,"-",NN,solvertime,"--");
legend("Reduced Dual KYP","Dual KYP");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
ylabel("solvertime(s)");
xlabel("FIR filter order N");
title(sprintf("h=remez(N,2*[0,%4.2f,%4.2f,0.5],[1,1,0,0],[1,10]);",fap,fas));
print(strcat(strf,"_solvertime"),"-dpdflatex");
close;

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
