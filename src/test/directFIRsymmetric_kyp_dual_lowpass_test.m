% directFIRsymmetric_kyp_dual_lowpass_test.m
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

strf="directFIRsymmetric_kyp_dual_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

%
% Low-pass filter specification
%
M=15;N=2*M;fap=0.15;fas=0.2;d=M;Asq_s=1e-4;Esq_z=5.67e-3;
nplot=1000;
nap=(fap*nplot/0.5)+1;
nas=(fas*nplot/0.5)+1;
w=(0:(nplot-1))'*pi/nplot;

%
% Common constants
%
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
Phi=[-1,0;0,1];
c_pass=2*cos(2*pi*fap);
Psi_pass=[0,1;1,-c_pass];
c_stop=2*cos(2*pi*fas);
Psi_stop=[0,-1;-1,c_stop];

%
% Common SeDuMi options
%
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
h=sdpvar(1,M+1,"full","real");
AB=[A,B;eye(N),zeros(N,1)];
CD=[h(1:end),h((end-1):-1:1)];
C_d=[zeros(1,N-d),1,zeros(1,d-1)];
CD_d=CD-[C_d,0];
% Primal pass-band constraints
P_pass_p=sdpvar(N,N,"symmetric","real");
Q_pass_p=sdpvar(N,N,"symmetric","real");
F_pass_p=[[((AB')*(kron(Phi,P_pass_p)+kron(Psi_pass,Q_pass_p))*AB) + ...
           diag([zeros(1,N),-Esq_z]),CD_d']; ...
          [CD_d,-1]];
% Primal stop band constraints
P_stop_p=sdpvar(N,N,"symmetric","real");
Q_stop_p=sdpvar(N,N,"symmetric","real");
F_stop_p=[[((AB')*(kron(Phi,P_stop_p)+kron(Psi_stop,Q_stop_p))*AB) + ...
           diag([zeros(1,N),-Asq_s]),CD']; ...
          [CD,-1]];

% Solve with YALMIP
Constraints_p=[F_pass_p<=0,Q_pass_p>=0,F_stop_p<=0,Q_stop_p>=0];
Objective_p=[];
sol=optimize(Constraints_p,Objective_p,Options);
if sol.problem
  error("YALMIP failed!");
endif
check(Constraints_p)
hopt=value(h);
hopt=[hopt,hopt((end-1):-1:1)];
H=freqz(hopt,1,w);
max_Esq_z=max(abs(H(1:nap)-e.^(-j*w(1:nap)*d)).^2);
printf("max_Esq_z=%10.8f,Esq_z=%10.8f\n",max_Esq_z,Esq_z);
if max_Esq_z > Esq_z
  error("max_Esq_z > Esq_z");
endif
max_Asq_s=max(abs(H(nas:end)).^2);
printf("max_Asq_s=%10.8f,Asq_s=%10.8f\n", max_Asq_s,Asq_s);
if max_Asq_s > Asq_s
  error("max_Asq_s > Asq_s");
endif
printf("\n");

%
% Dual Solution
%
printf("\nFind dual solution:\n\n");

%
% Common basis functions for the pass-band and stop-band
%
Theta0_stop=sparse([[zeros(N,N+2)];[zeros(1,N+2)];[zeros(1,N+1),-1]]);
Theta0_pass=sparse([[zeros(N,N+1),-C_d'];[zeros(1,N),-Esq_z,0];[-C_d,0,-1]]);
Theta=cell(1,M+1);
% Basis for [C,D]
Theta=cell(1,M+1);
for k=1:(M+1), 
  Theta{k}=sparse(zeros(N+2,N+2));
  Theta{k}(N+2,k)=1;
  Theta{k}(N+2,N+2-k)=1;
  Theta{k}(k,N+2)=1;
  Theta{k}(N+2-k,N+2)=1;
endfor
% Basis for Esq
Theta_Esq=sparse(zeros(N+2,N+2));
Theta_Esq(N+1,N+1)=-1;

% Common basis for ZR
barA=(A+
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

% Construct ZR_stop
if use_Z_basis
  Fk_stop=cell(1,N+2+N+2+N+1);
  % Basis for adjoint matrixes
  for k=1:length(Fk)
    Fk_stop{k}=Fk{k};
  endfor
  % Add Qadj_stop basis matrixes
  for k=1:N,
    Ek12=zeros(N,1);
    Ek12(k)=1;
    Ek11=lyap(A-(eye(size(A))*c_stop/2),(B*(Ek12'))+(Ek12*(B')));
    Fk_stop{N+2+N+2+k}= ...
      sparse([[Ek11,Ek12,zeros(N,1)];[Ek12',0,0];[zeros(1,N+2)]]);
  endfor
  Ek11=lyap(A-(eye(size(A))*c_stop/2),(B*(B')));
  Fk_stop{N+2+N+2+N+1}=sparse([[Ek11,zeros(N,2)];[zeros(2,N+2)]]);
  % Sanity check
  Fk_stop_check=zeros((N+2)^2,length(Fk_stop));
  for k=1:length(Fk_stop),
    Fk_stop_check(:,k)=vec(Fk_stop{k});
  endfor
  if rank(Fk_stop_check') ~= length(Fk_stop)
    error("rank(Fk_stop_check') ~= length(Fk_stop)");
  endif
  
  z_stop=sdpvar(1,length(Fk_stop),"full","real");
  ZR_stop=zeros(N+2);
  for k=1:length(Fk_stop),
    ZR_stop=ZR_stop+(z_stop(k)*Fk_stop{k});
  endfor
else
  ZR_stop=sdpvar(N+2,N+2,"symmetric","real");
endif
ZR_stop11=ZR_stop(1:N,1:N);
ZR_stop12=ZR_stop(1:N,N+1);
ZR_stop22=ZR_stop(N+1,N+1);

% Construct ZR_pass
if use_Z_basis
  Fk_pass=cell(1,N+2+N+2+N+1);
  % Basis for adjoint matrixes
  for k=1:length(Fk)
    Fk_pass{k}=Fk{k};
  endfor
  % Add Qadj_pass basis matrixes
  for k=1:N,
    Ek12=zeros(N,1);
    Ek12(k)=1;
    Ek11=lyap(A-(eye(size(A))*c_pass/2),(B*(Ek12'))+(Ek12*(B')));
    Fk_pass{N+2+N+2+k}= ...
      sparse([[Ek11,Ek12,zeros(N,1)];[Ek12',0,0];[zeros(1,N+2)]]);
  endfor
  Ek11=lyap(A-(eye(size(A))*c_pass/2),(B*(B')));
  Fk_pass{N+2+N+2+N+1}=sparse([[Ek11,zeros(N,2)];[zeros(2,N+2)]]);
  % Sanity check
  Fk_pass_check=zeros((N+2)^2,length(Fk_pass));
  for k=1:length(Fk_pass),
    Fk_pass_check(:,k)=vec(Fk_pass{k});
  endfor
  if rank(Fk_pass_check') ~= length(Fk_pass)
    error("rank(Fk_pass_check') ~= length(Fk_pass)");
  endif
  
  z_pass=sdpvar(1,length(Fk_pass),"full","real");
  ZR_pass=zeros(N+2);
  for k=1:length(Fk_pass),
    ZR_pass=ZR_pass+(z_pass(k)*Fk_pass{k});
  endfor
else
  ZR_pass=sdpvar(N+2,N+2,"symmetric","real");
endif
ZR_pass11=ZR_pass(1:N,1:N);
ZR_pass12=ZR_pass(1:N,N+1);
ZR_pass22=ZR_pass(N+1,N+1);

% Construct adjoint matrix mappings
Padj_stop=(A*ZR_stop11*(A')) -ZR_stop11 ...
          +(B*(ZR_stop12')*(A')) +(A*ZR_stop12*(B')) +(B*ZR_stop22*(B'));
Qadj_stop=-ZR_stop11*(A') -A*(ZR_stop11') +c_stop*ZR_stop11 ...
          -(B*(ZR_stop12')) -(ZR_stop12*(B'));
Padj_pass=(A*ZR_pass11*(A')) -ZR_pass11 ...
          +(B*(ZR_pass12')*(A')) +(A*ZR_pass12*(B')) +(B*ZR_pass22*(B'));
Qadj_pass=ZR_pass11*(A') + A*(ZR_pass11') -c_pass*ZR_pass11 ...
          +(B*(ZR_pass12')) +(ZR_pass12*(B'));

%
% Constraints
%
% Stop band constraints
Constraints_stop=[];
for k=1:length(Theta),
  Constraints_stop=[Constraints_stop,trace(Theta{k}*ZR_stop)==0];
endfor
Constraints_stop=[Constraints_stop, ...
                  trace(Theta_Esq)*ZR_stop==-1, ...
                  ZR_stop>=0,Padj_stop==0,Qadj_stop==0];

% Pass band constraints
Constraints_pass=[];
for k=1:length(Theta),
  Constraints_pass=[Constraints_pass,trace(Theta{k}*ZR_pass)==0];
endfor
Constraints_pass=[Constraints_pass,ZR_pass>=0,Padj_pass==0,Qadj_pass==0];

%
% Call solver. Objective function = Esq_stop+Esq_pass
%
Constraints=[Constraints_stop,Constraints_pass];
Objective=[-trace((Theta0_stop*ZR_stop)+(Theta0_pass*ZR_pass))];
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"),"f");
