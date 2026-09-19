% directFIRsymmetric_kyp_dual_lowpass_test.m
%
% SDP design of a direct-form symmetric FIR lowpass filter with the
% reduced complexity dual of the generalised discrete-time KYP lemma.
% The stop-band maximum amplitude is fixed and the maximum pass-band
% error from a delay is optimised.
% See :
%   [1] Section VII.B.2, pp. 53-55 of "Generalised KYP Lemma: Unified
%       Frequency Domain Inequalities With Design Applications",
%       T. Iwasaki and S. Hara, IEEE Transactions on Automatic Control,
%       Vol. 50, No. 1, January 2005, pp. 41–59
%   [2] Wallin et al.:
%       http://www.control.isy.liu.se/research/reports/2003/2503.pdf
%   [3] Lofberg:
%       https://yalmip.github.io/tutorial/automaticdualization

% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="directFIRsymmetric_kyp_dual_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

fid=fopen(strcat(strf,".results"),"w");

%
% Low-pass filter specification
%
M=15;N=2*M;d=M;fap=0.15;fas=0.2;Asq_s=1e-04;Esq_z=32.167e-4;

use_Theta=true;
tol=1e-7;

nplot=1000;
nap=(fap*nplot/0.5)+1;
nas=(fas*nplot/0.5)+1;
w=(0:(nplot-1))'*pi/nplot;

% Common constants
A=sparse([zeros(N-1,1),eye(N-1);zeros(1,N)]);
B=sparse([zeros(N-1,1);1]);
AB=sparse([A,B;eye(N),zeros(N,1)]);
C_d=sparse([zeros(1,N-d),1,zeros(1,d-1)]);
c_pass=2*cos(2*pi*fap);
c_stop=2*cos(2*pi*fas);
Phi=[-1,0;0,1];
Psi_pass=[0,1;1,-c_pass];
Psi_stop=[0,-1;-1,c_stop];

% Common Theta basis matrixes
Theta0_stop=sparse([[zeros(N,N+2)];[zeros(2,N),[-Asq_s,0;0,-1]]]);
% Basis for Esq
Theta_Esq=sparse(zeros(N+2,N+2));
Theta_Esq(N+1,N+1)=-1;
% Basis for [C,D]
Theta=cell(1,M+1+1);
for k=1:(M+1), 
  Theta{k}=sparse(zeros(N+2,N+2));
  Theta{k}(N+2,k)=1;
  Theta{k}(N+2,N+2-k)=1;
  Theta{k}(k,N+2)=1;
  Theta{k}(N+2-k,N+2)=1;
endfor
Theta_Esq=sparse(zeros(N+2,N+2));
Theta_Esq(N+1,N+1)=-1;
Theta{M+1+1}=Theta_Esq;

% Objective=c'*v
c=[zeros(M+1,1);1];

% Common options
Options=sdpsettings("solver","sedumi", ...
                    "saveduals",true, ...
                    "saveyalmipmodel",true, ...
                    "savesolverinput",true, ...
                    "savesolveroutput",true);

% Common basis for Z
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
% Basis for h and Z(N+2,N+2)
for k=1:(N+2),
  Ek13=zeros(N+2);
  Ek13(N+2,k)=1;
  Ek13(k,N+2)=1;
  Fk{N+2+k}=sparse(Ek13);
endfor
% Sanity checks
sum_Fk=zeros(N+2); for k=1:length(Fk), sum_Fk=sum_Fk+Fk{k}; endfor;
if any(any(sum_Fk==0))
  error("any(any(sum_Fk==0))");
endif
for k=1:length(Fk)
  if ~issymmetric(Fk{k})
    error("~issymmetric(Fk{%d})",k);
  endif
endfor
for k=1:length(Fk)
  for l=(k+1):length(Fk)
    if Fk{k} == Fk{l}
      error("Fk{%d} == Fk{%d}",k,l);
    endif
  endfor
endfor
% Find  G
G=sparse(zeros(length(Fk),M+1));
for l=1:(M+1+1),
  for k=1:length(Fk),
    G(k,l)=trace(Fk{k}*Theta{l});
  endfor
endfor

%
% Primal solution with empty objective
%
printf("\nFind primal solution with empty objective:\n\n");
fprintf(fid,"\nFind primal solution with empty objective:\n");

% Filter impulse response
hM=sdpvar(1,M+1,"full","real");
CD=[hM,hM((end-1):-1:1)];
CD_d=CD-[C_d,0];
Theta0_pass=sparse([[zeros(N,N+1),-C_d'];[zeros(1,N),-Esq_z,0];[-C_d,0,-1]]);
Theta_stop=Theta0_stop;
Theta_pass=Theta0_pass;
for k=1:(M+1),
  Theta_stop=Theta_stop+(CD(k)*Theta{k});
  Theta_pass=Theta_pass+(CD(k)*Theta{k});
endfor
% Primal pass-band constraints
P_pass=sdpvar(N,N,"symmetric","real");
Q_pass=sdpvar(N,N,"symmetric","real");
if use_Theta
  F_pass=[[((AB')*(kron(Phi,P_pass)+kron(Psi_pass,Q_pass))*AB),zeros(N+1,1)]; ...
          [zeros(1,N+2)]] ...
         + Theta_pass;
else
  F_pass=[[((AB')*(kron(Phi,P_pass)+kron(Psi_pass,Q_pass))*AB) + ...
           diag([zeros(1,N),-Esq_z]),CD_d']; ...
          [CD_d,-1]];
endif

% Primal stop band constraints
P_stop=sdpvar(N,N,"symmetric","real");
Q_stop=sdpvar(N,N,"symmetric","real");
if use_Theta
  F_stop=[[((AB')*(kron(Phi,P_stop)+kron(Psi_stop,Q_stop))*AB),zeros(N+1,1)]; ...
          [zeros(1,N+2)]] ...
         + Theta_stop;
else
  F_stop=[[((AB')*(kron(Phi,P_stop)+kron(Psi_stop,Q_stop))*AB) + ...
           diag([zeros(1,N),-Asq_s]),CD']; ...
          [CD,-1]];
endif

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
h_empty=value(CD);
H=freqz(h_empty,1,w);
T=delayz(h_empty,1,w);
max_Esq_z=max(abs(H(1:nap)-e.^(-j*w(1:nap)*d)).^2);
printf("max_Esq_z=%10.8f,Esq_z=%10.8f\n",max_Esq_z,Esq_z);
fprintf(fid,"max_Esq_z=%10.8f,Esq_z=%10.8f\n",max_Esq_z,Esq_z);
max_Asq_p=max(abs(H(1:nap)).^2);
min_Asq_p=min(abs(H(1:nap)).^2);
printf("max_Asq_p=%10.8f (%g dB),min_Asq_p=%10.8f (%g dB)\n", ...
       max_Asq_p,10*log10(max_Asq_p),min_Asq_p,10*log10(min_Asq_p));
fprintf(fid,"max_Asq_p=%10.8f (%10.4g dB),min_Asq_p=%10.8f (%10.4g dB)\n", ...
       max_Asq_p,10*log10(max_Asq_p),min_Asq_p,10*log10(min_Asq_p));
max_Asq_s=max(abs(H(nas:end)).^2);
printf("max_Asq_s=%10.8f (%g dB),Asq_s=%10.8f\n", ...
       max_Asq_s,10*log10(max_Asq_s),Asq_s);
fprintf(fid, "max_Asq_s=%10.8f (%10.4g dB),Asq_s=%10.8f\n", ...
       max_Asq_s,10*log10(max_Asq_s),Asq_s);
if max_Esq_z > Esq_z
  error("max_Esq_z > Esq_z");
endif
if max_Asq_s > Asq_s
  error("max_Asq_s > Asq_s");
endif
printf("\n");

% Check G*v=g with the primal solution on the pass-band
f_pass=value(F_pass);
% Find pass-band g
g_pass=sparse(zeros(length(Fk),1));
for k=1:length(Fk),
  g_pass(k)=trace(Fk{k}*(f_pass-Theta0_pass));
endfor
% Solve for the primal variables h
v_pass=G(:,1:(M+1))\g_pass;
if max(abs(v_pass(1:(M+1))'-value(hM))) > eps
  error("max(abs(v_pass(1_M+1)'-value(hM))) > eps", ...
        max(abs(v_pass(1:(M+1))'-value(hM))));
endif

% Check G*v=g with the primal solution on the stop-band
f_stop=value(F_stop);
% Find pass-band g
g_stop=sparse(zeros(length(Fk),1));
for k=1:length(Fk),
  g_stop(k)=trace(Fk{k}*(f_stop-Theta0_stop));
endfor
% Solve for the primal variables h
v_stop=G(:,1:(M+1))\g_stop;
if max(abs(v_stop(1:16)'-value(hM))) > eps
  error("max(abs(v_stop(1_16)'-value(hM))) > eps", ...
        max(abs(v_stop(1:16)'-value(hM))));
endif

%
% Primal solution with objective pass-band Esq_z
%
printf("\nFind primal solution with pass-band Esq_z:\n\n");
fprintf(fid,"\nFind primal solution with pass-band Esq_z:\n");

% Filter impulse response
clear Esq_z Theta0_pass hM;
hM=sdpvar(1,M+1,"full","real");
Esq_z=sdpvar(1,1,"full","real");
CD=[hM,hM((end-1):-1:1)];
CD_d=CD-[C_d,0];
Theta_stop=Theta0_stop;
Theta0_pass=[[zeros(N,N+1),-C_d'];[zeros(1,N+2)];[-C_d,0,-1]];
Theta_pass=Theta0_pass;
for k=1:(M+1),
  Theta_stop=Theta_stop+(CD(k)*Theta{k});
  Theta_pass=Theta_pass+(CD(k)*Theta{k});
endfor
Theta_pass=Theta_pass+(Esq_z*Theta{M+1+1});
% Primal pass-band constraints
P_pass=sdpvar(N,N,"symmetric","real");
Q_pass=sdpvar(N,N,"symmetric","real");
if use_Theta
  F_pass=[[((AB')*(kron(Phi,P_pass)+kron(Psi_pass,Q_pass))*AB),zeros(N+1,1)]; ...
          [zeros(1,N+2)]] ...
         + Theta_pass;
else
  F_pass=[[((AB')*(kron(Phi,P_pass)+kron(Psi_pass,Q_pass))*AB) + ...
           diag([zeros(1,N),-Esq_z]),CD_d']; ...
          [CD_d,-1]];
endif

% Primal stop band constraints
P_stop=sdpvar(N,N,"symmetric","real");
Q_stop=sdpvar(N,N,"symmetric","real");
if use_Theta
  F_stop=[[((AB')*(kron(Phi,P_stop)+kron(Psi_stop,Q_stop))*AB),zeros(N+1,1)]; ...
          [zeros(1,N+2)]] ...
         + Theta_stop;
else
  F_stop=[[((AB')*(kron(Phi,P_stop)+kron(Psi_stop,Q_stop))*AB) + ...
           diag([zeros(1,N),-Asq_s]),CD']; ...
          [CD,-1]];
endif

% Solve with YALMIP
Constraints_primal=[F_pass<=0,Q_pass>=0,F_stop<=0,Q_stop>=0];
Objective_primal=[Esq_z];
Options_primal=sdpsettings(Options,"dualize",true,"sedumi.eps",tol);
sol=optimize(Constraints_primal,Objective_primal,Options_primal);
if sol.problem
  error("YALMIP failed!");
endif
% Sanity check
check(Constraints_primal)
h_Esq_z=value(CD);
H=freqz(h_Esq_z,1,w);
T=delayz(h_Esq_z,1,w);
max_Esq_z=max(abs(H(1:nap)-e.^(-j*w(1:nap)*d)).^2);
printf("max_Esq_z=%10.8f,Esq_z=%10.8f\n",max_Esq_z,value(Esq_z));
fprintf(fid,"max_Esq_z=%10.8f,Esq_z=%10.8f\n",max_Esq_z,value(Esq_z));
max_Asq_p=max(abs(H(1:nap)).^2);
min_Asq_p=min(abs(H(1:nap)).^2);
printf("max_Asq_p=%10.8f (%g dB),min_Asq_p=%10.8f (%g dB)\n", ...
       max_Asq_p,10*log10(max_Asq_p),min_Asq_p,10*log10(min_Asq_p));
fprintf(fid, "max_Asq_p=%10.8f (%10.4g dB),min_Asq_p=%10.8f (%10.4g dB)\n", ...
        max_Asq_p,10*log10(max_Asq_p),min_Asq_p,10*log10(min_Asq_p));
max_Asq_s=max(abs(H(nas:end)).^2);
printf("max_Asq_s=%10.8f (%g dB),Asq_s=%10.8f\n", ...
       max_Asq_s,10*log10(max_Asq_s),Asq_s);
fprintf(fid,"max_Asq_s=%10.8f (%10.4g dB),Asq_s=%10.8f\n", ...
        max_Asq_s,10*log10(max_Asq_s),Asq_s);
if max_Esq_z > value(Esq_z)
  error("max_Esq_z > Esq_z");
endif
if max_Asq_s > Asq_s + (2*tol)
  error("max_Asq_s > Asq_s + (2*tol)");
endif
printf("\n");

% Check G*v=g with the primal solution on the pass-band
f_pass=value(F_pass);
% Find pass-band g
g_pass=sparse(zeros(length(Fk),1));
for k=1:length(Fk),
  g_pass(k)=trace(Fk{k}*(f_pass-Theta0_pass));
endfor
% Solve for the primal variables h
v_pass=G(:,1:(M+1))\g_pass;
if max(abs(v_pass(1:(M+1))'-value(hM))) > eps
  error("max(abs(v_pass(1_Mp1)'-value(hM))) > eps", ...
        max(abs(v_pass(1:(M+1))'-value(hM))));
endif

% Check G*v=g with the primal solution on the stop-band
f_stop=value(F_stop);
% Find pass-band g
g_stop=sparse(zeros(length(Fk),1));
for k=1:length(Fk),
  g_stop(k)=trace(Fk{k}*(f_stop-Theta0_stop));
endfor
% Solve for the primal variables h
v_stop=G(:,1:(M+1))\g_stop;
if max(abs(v_stop(1:(M+1))'-value(hM))) > eps
  error("max(abs(v_stop(1_M+1)'-value(hM))) > eps", ...
        max(abs(v_stop(1:(M+1))'-value(hM))));
endif

%
% Reduced complexity dual solution
%
printf("\nFind reduced complexity dual solution:\n\n");
fprintf(fid,"\nFind reduced complexity dual solution:\n");

% Esq_z is the objective
Theta0_pass=sparse([[zeros(N,N+1),-C_d'];[zeros(1,N+2)];[-C_d,0,-1]]);

% Construct ZR_stop
zr_stop=sdpvar(1,length(Fk),"full","real");
ZR_stop=zeros(N+2);
for k=1:length(Fk),
  ZR_stop=ZR_stop+(zr_stop(k)*Fk{k});
endfor
ZR_stop11=ZR_stop(1:N,1:N);
ZR_stop12=ZR_stop(1:N,N+1);
ZR_stop22=ZR_stop(N+1,N+1);

% Construct ZR_pass
zr_pass=sdpvar(1,length(Fk),"full","real");
ZR_pass=zeros(N+2);
for k=1:length(Fk),
  ZR_pass=ZR_pass+(zr_pass(k)*Fk{k});
endfor
ZR_pass11=ZR_pass(1:N,1:N);
ZR_pass12=ZR_pass(1:N,N+1);
ZR_pass22=ZR_pass(N+1,N+1);

% Construct adjoint matrix mappings
Padj_stop=(A*ZR_stop11*(A')) -ZR_stop11 ...
          +(B*(ZR_stop12')*(A')) +(A*ZR_stop12*(B')) +(B*ZR_stop22*(B'));
Padj_pass=(A*ZR_pass11*(A')) -ZR_pass11 ...
          +(B*(ZR_pass12')*(A')) +(A*ZR_pass12*(B')) +(B*ZR_pass22*(B'));
Qadj_stop=-ZR_stop11*(A') -A*(ZR_stop11') +c_stop*ZR_stop11 ...
          -(B*(ZR_stop12')) -(ZR_stop12*(B'));
Qadj_pass=ZR_pass11*(A') + A*(ZR_pass11') -c_pass*ZR_pass11 ...
          +(B*(ZR_pass12')) +(ZR_pass12*(B'));

% Constraints
Constraints_dual_R=[ZR_pass>=0,ZR_stop>=0, ...
                    Padj_pass==0,Padj_stop==0, ...
                    Qadj_pass==0,Qadj_stop==0];
for k=1:(M+1),
  Constraints_dual_R= ...
      [Constraints_dual_R,trace(Theta{k}*ZR_stop)+trace(Theta{k}*ZR_pass)==0];
endfor
Constraints_dual_R=[Constraints_dual_R,trace(Theta_Esq*ZR_pass)==-1];

% Call solver. Objective function = Esq_pass+Esq_stop
Objective_dual_R=[-trace((Theta0_stop*ZR_stop)+(Theta0_pass*ZR_pass))];
Options_dual_R=sdpsettings(Options,"dualize",false,"sedumi.eps",tol);
sol=optimize(Constraints_dual_R,Objective_dual_R,Options_dual_R);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints_dual_R);
for k=7:length(Constraints_dual_R)
  Constraints_7_end(k-7+1)=value(Constraints_dual_R(k));
endfor

% Extract primal matrixes
[Constraints_Primal,Objective_Primal,Primals,Free,Err]= ...
  dualize(Constraints_dual_R,Objective_dual_R);
for k = 1:length(Primals), assign(Primals{k},dual(Constraints_dual_R(k)));endfor;
V_pass=value(Primals{1});

% Find pass-band g
g_pass=sparse(zeros(length(Fk),1));
for k=1:length(Fk),
  g_pass(k)=trace(Fk{k}*(V_pass-Theta0_pass));
endfor
% Find G_pass
G_pass=sparse(zeros(length(Fk)),length(Theta)+1);
for k=1:length(Fk),
  for l=1:length(Theta),
    G_pass(k,l)=trace(Fk{k}*Theta{l});
  endfor
endfor
for k=1:length(Fk),
  G_pass(k,length(Theta)+1)=trace(Fk{k}*Theta_Esq);
endfor
v_pass=G_pass\g_pass;
printf("Recovered primal variable v_pass (Esq_s) =%g\n",v_pass(end));
fprintf(fid,"Recovered primal variable v_pass (Esq_s) =%10.4g\n",v_pass(end));

% Done
fclose(fid);
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"),"f");
