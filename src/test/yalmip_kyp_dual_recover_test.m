% yalmip_kyp_dual_recover_test.m
%
% SDP design of a direct-form FIR lowpass filter with the reduced
% complexity dual of the generalised discrete-time KYP lemma.
% See :
%   [1] Section VII.B.2, pp. 53-55 of "Generalised KYP Lemma: Unified
%       Frequency Domain Inequalities With Design Applications",
%       T. Iwasaki and S. Hara, IEEE Transactions on Automatic Control,
%       Vol. 50, No. 1, January 2005, pp. 41–59
%   [2] Wallin et al. at:
%       http://www.control.isy.liu.se/research/reports/2003/2503.pdf

% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="yalmip_kyp_dual_recover_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

fid=fopen(strcat(strf,".results"),"w");

M=15;N=2*M;d=M;
fap=0.15;fas=0.2;
nplot=10000;
nap=ceil(fap*nplot/0.5)+1;
nas=floor(fas*nplot/0.5)+1;

h=remez(N,2*[0,fap,fas,0.5],[1,1,0,0],[1,10]);
h=h(:)';
[H,w]=freqz(h,1,nplot);
Asq=abs(H).^2;
Esq_pass=max(abs(H(1:nap)-e.^(-j*w(1:nap)*d)).^2);

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
C=h(end:-1:2);
D=h(1);
C_pz=C-[zeros(1,N-d),1,zeros(1,d-1)];
Phi=[-1,0;0,1]; 
c_pass=2*cos(2*pi*fap);
Psi_pass=[0,1;1,-c_pass];

% Esq basis
Theta0=sparse([[zeros(N,N+1),C_pz'];[zeros(1,N),0,D'];[C_pz,D,-1]]);
Theta1=sparse([[zeros(N,N+2)];[zeros(2,N),[-1,0;0,0]]]);

%
% Solve the primal problem for the pass-band maximum response error
%
% Primal pass-band constraints
Esq_z=sdpvar(1,1,"full","real");
Theta_pass=Theta0+(Esq_z*Theta1);
P_pass=sdpvar(N,N,"symmetric","real");
Q_pass=sdpvar(N,N,"symmetric","real");
AB=sparse([A,B;eye(N),zeros(N,1)]);
F_pass=[[((AB')*(kron(Phi,P_pass)+kron(Psi_pass,Q_pass))*AB),zeros(N+1,1)]; ...
        [zeros(1,N+2)]] ...
       + Theta_pass;
Constraints=[F_pass<=0,Q_pass>=0];
Objective=[Esq_z];
Options=sdpsettings("solver","sedumi","dualize",true);
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed!");
endif
% Sanity check
% Note that value(Constraints(1)) = -value(F_pass)
check(Constraints)
primal_Esq_z=value(Esq_z);
printf("Pass-band KYP primal maximum response error = %g, (Esq_pass=%g)\n\n", ...
       primal_Esq_z,Esq_pass);
fprintf(fid,["Pass-band KYP primal maximum response error = %10.6g", ...
             "(Esq_pass=%10.6g)\n\n"],primal_Esq_z,Esq_pass);

%
% Solve the reduced dual problem for the pass-band maximum response error
%
printf("\nSolve the dual problem for the pass-band maximum response error:\n")
% Find a basis for Z 
Fk=gkyp_find_z_basis(A,B);
z_pass=sdpvar(1,length(Fk),"full","real");
ZR_pass=kyp_expand_z_basis(Fk,z_pass);
% Adjoint equality constraints
Padj_pass=kyp_P_adjoint(ZR_pass,A,B);
Qadj_pass=kyp_Q_adjoint(ZR_pass,A,B,Psi_pass);
% Run YALMIP
Constraints_dual = ...
  [ZR_pass>=0,trace(Theta1*ZR_pass)==-1,Qadj_pass==0,Padj_pass==0];
Objective_dual=[-trace(Theta0*ZR_pass)];
Options_dual=sdpsettings("solver","sedumi", ...
                         "dualize",false, ...
                         "saveduals",true, ...
                         "saveyalmipmodel",true, ...
                         "savesolverinput",true, ...
                         "savesolveroutput",true);
sol=optimize(Constraints_dual,Objective_dual,Options_dual);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
check(Constraints_dual);
dual_Esq_pass=-value(Objective_dual);
printf("Pass-band KYP dual maximum response error = %g, (Esq_pass=%g)\n", ...
       dual_Esq_pass,Esq_pass);
fprintf(fid,["Pass-band KYP dual maximum response error = %10.6g,", ...
             "(Esq_pass=%10.6g)\n"],dual_Esq_pass,Esq_pass);
printf("Primal duality_gap=%g\n\n", trace(value(ZR_pass)*value(Constraints(1))));
fprintf(fid, "Primal duality_gap=%10.6g\n\n", ...
        trace(value(ZR_pass)*value(Constraints(1))));

%
% Try to recover the primal SDP variable from the dual model
%
printf("\nRecover the primal objective:\n")
clear Constraints_primal Objective_primal
[Constraints_primal,Objective_primal]= ...
  primalize(Constraints_dual,-Objective_dual);
Options_primal=sdpsettings("solver","sedumi", ...
                           "dualize",false, ...
                           "saveduals",true, ...
                           "saveyalmipmodel",true, ...
                           "savesolverinput",true, ...
                           "savesolveroutput",true);
sol=optimize(Constraints_primal,Objective_primal,Options_primal);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
check(Constraints_primal);
primal_Esq_pass=value(Objective_primal);
printf("Recovered primal objective = %g, (Esq_pass=%g)\n", ...
       primal_Esq_pass,Esq_pass);
fprintf(fid, "Recovered primal objective = %10.6g, (Esq_pass=%10.6g)\n", ...
       primal_Esq_pass,Esq_pass);
V_pass=value(Constraints_primal(1));
printf("Recovered primal duality_gap=%g\n", trace(value(ZR_pass)*V_pass));
fprintf(fid,"Recovered primal duality_gap=%10.6g\n", ...
        trace(value(ZR_pass)*V_pass));
printf("Recovered primal norm(V_pass-value(Constraints(1)))=%g\n", ...
       norm(value(V_pass)-value(Constraints(1))));
fprintf(fid,"Recovered primal norm(V_pass-value(Constraints(1)))=%10.6g\n", ...
        norm(value(V_pass)-value(Constraints(1))));

% Attempt to recover the primal variable
printf("\nRecover the primal variable:\n")
% Find g_pass
g_pass=sparse(zeros(length(Fk),1));
for k=1:length(Fk),
  g_pass(k)=trace(Fk{k}*(V_pass-Theta0));
endfor
% Find G_pass
G_pass=sparse(zeros(length(Fk),1));
for k=1:length(Fk),
  G_pass(k,1)=trace(Fk{k}*Theta1);
endfor
printf("Recovered primal variable v_pass=%g\n",G_pass\g_pass);
fprintf(fid,"Recovered primal variable v_pass=%10.6g\n",G_pass\g_pass);

% Done
fclose(fid);
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
