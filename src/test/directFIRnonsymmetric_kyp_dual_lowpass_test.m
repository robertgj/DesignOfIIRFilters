% directFIRnonsymmetric_kyp_dual_lowpass_test.m
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

strf="directFIRnonsymmetric_kyp_dual_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

fid=fopen(strcat(strf,".results"),"w");

%
% Low-pass filter specification
%
% The reduced dual problem converged in 340 seconds for M=200.
%
M=28;N=2*M;fap=0.15;fas=0.2;d=24;Asq_s=1e-6;Esq_z=1e-4;

% Frequencies
nplot=1000;
nap=(fap*nplot/0.5)+1;
nas=(fas*nplot/0.5)+1;
w=(0:(nplot-1))'*pi/nplot;

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
C_d=[zeros(1,N-d),1,zeros(1,d-1)];
Phi=[-1,0;0,1];
c_pass=2*cos(2*pi*fap);
Psi_pass=[0,1;1,-c_pass];
c_stop=2*cos(2*pi*fas);
Psi_stop=[0,-1;-1,c_stop];

% Common SeDuMi options
Options=sdpsettings("solver","sedumi", ...
                    "saveduals",true, ...
                    "saveyalmipmodel",true, ...
                    "savesolverinput",true, ...
                    "savesolveroutput",true);

%
% Primal solution
%
printf("\nFind primal solution:\n\n");

% Filter impulse response
h=sdpvar(1,N+1,"full","real");
CD=[h(end:-1:1)];
CD_d=CD-[C_d,0];
% Primal pass-band constraints
P_pass=sdpvar(N,N,"symmetric","real");
Q_pass=sdpvar(N,N,"symmetric","real");
F_pass=[[((AB')*(kron(Phi,P_pass)+kron(Psi_pass,Q_pass))*AB) + ...
         diag([zeros(1,N),-Esq_z]),CD_d']; ...
        [CD_d,-1]];
% Primal stop band constraints
P_stop=sdpvar(N,N,"symmetric","real");
Q_stop=sdpvar(N,N,"symmetric","real");
F_stop=[[((AB')*(kron(Phi,P_stop)+kron(Psi_stop,Q_stop))*AB) + ...
           diag([zeros(1,N),-Asq_s]),CD']; ...
          [CD,-1]];

% Solve with YALMIP
Constraints_primal=[F_pass<=0,Q_pass>=0,F_stop<=0,Q_stop>=0];
Objective_primal=[];
Options_primal=sdpsettings(Options,"dualize",true);

sol=optimize(Constraints_primal,Objective_primal,Options_primal);
if sol.problem
  error("YALMIP failed!");
endif

% Sanity check
check(Constraints_primal)
hopt=value(h);
H=freqz(hopt,1,w);
T=delayz(hopt,1,w);

max_Esq_z=max(abs(H(1:nap)-e.^(-j*w(1:nap)*d)).^2);
printf("max_Esq_z=%10.8f,Esq_z=%10.8f\n",max_Esq_z,Esq_z);
fprintf(fid,"max_Esq_z=%10.8f,Esq_z=%10.8f\n",max_Esq_z,Esq_z);
max_Asq_s=max(abs(H(nas:end)).^2);
printf("max_Asq_s=%10.8f,Asq_s=%10.8f\n", max_Asq_s,Asq_s);
fprintf(fid,"max_Asq_s=%10.8f,Asq_s=%10.8f\n", max_Asq_s,Asq_s);

if max_Esq_z > Esq_z
  error("max_Esq_z > Esq_z");
endif
if max_Asq_s > Asq_s
  error("max_Asq_s > Asq_s");
endif
printf("\n");

%
% Reduced complexity dual Solution
%
printf("\nFind reduced complexity dual solution:\n\n");

% Common basis functions for the pass-band and stop-band
Theta0_stop=sparse([[zeros(N,N+2)];[zeros(1,N+2)];[zeros(1,N+1),-1]]);
Theta0_pass=sparse([[zeros(N,N+1),-C_d'];[zeros(1,N),-Esq_z,0];[-C_d,0,-1]]);
% Basis for Esq
Theta_Esq=sparse(zeros(N+2,N+2));
Theta_Esq(N+1,N+1)=-1;
% Basis for [C,D]
Theta=cell(1,N+1);
Theta=cell(1,N+1);
for k=1:(N+1), 
  Theta{k}=sparse(zeros(N+2,N+2));
  Theta{k}(N+2,k)=1;
  Theta{k}(k,N+2)=1;
endfor

% Common basis for ZR
Fk=cell(1,N+2+N+2);
% Basis for adjoint matrixes
for k=1:N
  Ek12=zeros(N,1);
  Ek12(k)=1;
  Ek11=dlyap(A,(B*(Ek12')*(A'))+(A*Ek12*(B')));
  Fk{k}=sparse([[Ek11,Ek12,zeros(N,1)];[Ek12',0,0];[zeros(1,N+2)]]);
endfor
Ek11=dlyap(A,(B*(B')));
Fk{N+1}=sparse([[Ek11,zeros(N,2)];[zeros(2,N+2)]]);
Fk{N+2}=sparse([[zeros(N,N+2)];[zeros(2,N),[1,0;0,0]]]);
% Basis for h and ZR(N+2,N+2)
for k=1:(N+2),
  Ek13=zeros(N+2);
  Ek13(N+2,k)=1;
  Ek13(k,N+2)=1;
  Fk{N+2+k}=sparse(Ek13);
endfor

% Construct Z_stop
z_stop=sdpvar(1,length(Fk),"full","real");
Z_stop=zeros(N+2);
for k=1:length(Fk),
  Z_stop=Z_stop+(z_stop(k)*Fk{k});
endfor
Z_stop11=Z_stop(1:N,1:N);
Z_stop12=Z_stop(1:N,N+1);
Z_stop22=Z_stop(N+1,N+1);

% Construct Z_pass
z_pass=sdpvar(1,length(Fk),"full","real");
Z_pass=zeros(N+2);
for k=1:length(Fk),
  Z_pass=Z_pass+(z_pass(k)*Fk{k});
endfor
Z_pass11=Z_pass(1:N,1:N);
Z_pass12=Z_pass(1:N,N+1);
Z_pass22=Z_pass(N+1,N+1);

% Construct adjoint matrix mappings
Padj_stop=(A*Z_stop11*(A')) -Z_stop11 ...
          +(B*(Z_stop12')*(A')) +(A*Z_stop12*(B')) +(B*Z_stop22*(B'));
Padj_pass=(A*Z_pass11*(A')) -Z_pass11 ...
          +(B*(Z_pass12')*(A')) +(A*Z_pass12*(B')) +(B*Z_pass22*(B'));
Qadj_stop=-Z_stop11*(A') -A*(Z_stop11') +c_stop*Z_stop11 ...
          -(B*(Z_stop12')) -(Z_stop12*(B'));
Qadj_pass=Z_pass11*(A') + A*(Z_pass11') -c_pass*Z_pass11 ...
          +(B*(Z_pass12')) +(Z_pass12*(B'));

% Dual constraints
Constraints_dual=[Z_stop>=0,Z_pass>=0, ...
                  Padj_stop==0,Padj_pass==0, ...
                  Qadj_stop==0,Qadj_pass==0];
for k=1:length(Theta),
  Constraints_dual=[Constraints_dual, ...
                    trace(Theta{k}*Z_stop)+trace(Theta{k}*Z_pass)==0];
endfor
Constraints_dual=[Constraints_dual,trace(Theta_Esq*Z_stop)==-1];

% Call solver. Objective function = Esq_stop
Objective_dual=[-trace(Theta0_stop*Z_stop)];
Options_dual=sdpsettings(Options,"sedumi.eps",1e-7,"dualize",false);
sol=optimize(Constraints_dual,Objective_dual,Options_dual);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints_dual)
V_stop=dual(Constraints_dual(1));
printf("Recovered primal duality gap=%g\n",trace(value(V_stop)*value(Z_stop)));
fprintf(fid,"Recovered primal duality gap=%g\n", ...
        trace(value(V_stop)*value(Z_stop)));

% Find g_stop
g_stop=sparse(zeros(length(Fk),1));
for k=1:length(Fk),
  g_stop(k)=trace(Fk{k}*(V_stop-Theta0_stop));
endfor
% Find G_stop
G_stop=sparse(zeros(length(Fk)),length(Theta)+1);
for k=1:length(Fk),
  for l=1:length(Theta),
    G_stop(k,l)=trace(Fk{k}*Theta{l});
  endfor
endfor
for k=1:length(Fk),
  G_stop(k,length(Theta)+1)=trace(Fk{k}*Theta_Esq);
endfor
v_stop=G_stop\g_stop;
printf("Recovered primal variable v_stop (Esq_s) =%g\n",v_stop(end));
fprintf(fid,"Recovered primal variable v_stop (Esq_s) =%g\n",v_stop(end));

% Done
fclose(fid);
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"),"f");
