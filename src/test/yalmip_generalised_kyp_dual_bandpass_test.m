% yalmip_generalised_kyp_dual_bandpass_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="yalmip_generalised_kyp_dual_bandpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

fhandle=fopen(strcat(strf,".results"),"w");

tic;

%
% Band-pass filter
%
M=12;N=2*M;fasl=0.15;fapl=0.2;fapu=0.25;fasu=0.3;

h=remez(2*M,2*[0,fasl,fapl,fapu,fasu,0.5],[0,0,1,1,0,0]);
h=h(:)';
nplot=1000;
nasl=ceil(nplot*fasl/0.5)+1;
napl=floor(nplot*fapl/0.5)+1;
napu=ceil(nplot*fapu/0.5)+1;
nasu=floor(nplot*fasu/0.5)+1;

% Amplitude constraints
[H,w]=freqz(h,1,nplot);
H_2=abs(H).^2;
max_H_2=max(H_2);
Esq_sl=ceil(max(H_2(1:nasl))*1e5)/1e5;
Esq_pu=ceil(max(H_2(napl:napu))*1e5)/1e5;
Esq_pl=floor(min(H_2(napl:napu))*1e5)/1e5;
Esq_su=ceil(max(H_2(nasu:end))*1e5)/1e5;

% Frequency constriants
fc=(fapu+fapl)/2;
fm=(fapu-fapl)/2;
alpha_p=e^(i*2*pi*fc);
alpha_sl=1;
alpha_su=-1;
gamma_p=-2*cos(2*pi*fm);
gamma_sl=-2*cos(2*pi*fasl);
gamma_su=2*cos(2*pi*fasu);

Phi=[-1,0;0,1];
Psi_p=[0,1;1,gamma_p];
Psi_sl=[0,1;1,gamma_sl];
Psi_su=[0,1;1,gamma_su];
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB_p=[A,B;alpha_p*eye(N),zeros(N,1)];
AB_sl=[A,B;alpha_sl*eye(N),zeros(N,1)];
AB_su=[A,B;alpha_su*eye(N),zeros(N,1)];
C=h(1:end-1);
D=h(end);
CD=[C,D;zeros(1,N),1];
Theta_pl=(CD')*[-1,0;0, Esq_pl]*CD;
Theta_pu=(CD')*[ 1,0;0,-Esq_pu]*CD;
Theta_sl= (CD')*[ 1,0;0,-Esq_sl ]*CD;
Theta_su= (CD')*[ 1,0;0,-Esq_su ]*CD;
T1=[A,B];
T2_p=[alpha_p*eye(N),zeros(N,1)];
T2_sl=[alpha_sl*eye(N),zeros(N,1)];
T2_su=[alpha_su*eye(N),zeros(N,1)];

% Test failure
% Theta_sl=(CD')*[ 1,0;0,-Esq_sl/2 ]*CD;

%
% Test the filter response with KYP
%
P_pl=sdpvar(N,N,"symmetric","real");
Q_pl=sdpvar(N,N,"symmetric","real");
F_pl=Theta_pl+((AB_p')*(kron(Phi,P_pl)+kron(Psi_p,Q_pl))*AB_p);

P_pu=sdpvar(N,N,"symmetric","real");
Q_pu=sdpvar(N,N,"symmetric","real");
F_pu=Theta_pu+((AB_p')*(kron(Phi,P_pu)+kron(Psi_p,Q_pu))*AB_p);

P_sl=sdpvar(N,N,"symmetric","real");
Q_sl=sdpvar(N,N,"symmetric","real");
F_sl=Theta_sl+((AB_sl')*(kron(Phi,P_sl)+kron(Psi_sl,Q_sl))*AB_sl);

P_su=sdpvar(N,N,"symmetric","real");
Q_su=sdpvar(N,N,"symmetric","real");
F_su=Theta_su+((AB_su')*(kron(Phi,P_su)+kron(Psi_su,Q_su))*AB_su);

% Pass band upper and lower bounds, stop and transition band upper bounds
Constraints=[F_pl<=0,Q_pl>=0,F_pu<=0,Q_pu>=0,F_sl<=0,Q_sl>=0,F_su<=0,Q_su>=0];
Objective=[];
Options=sdpsettings("solver","sdpt3"); 
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed (%d) : %s",sol.problem,sol.info);
endif
% Sanity checks
check(Constraints)
fwrite(fhandle, ...
       sprintf("Primary constraints (sl,pl,pu,su) sol.problem=%d\n", ...
               sol.problem));

%
% Test the filter response with dual KYP
%
yalmip("clear");

W_pl=sdpvar(N+1,N+1,"symmetric","real");
dualF_pl=(T1*W_pl*(T1'))-(T2_p*W_pl*(T2_p'));
dualG_pl=(T1*W_pl*(T2_p'))+((T1*W_pl*(T2_p'))')+(gamma_p*T2_p*W_pl*(T2_p'));

W_pu=sdpvar(N+1,N+1,"symmetric","real");
dualF_pu=(T1*W_pu*(T1'))-(T2_p*W_pu*(T2_p'));
dualG_pu=(T1*W_pu*(T2_p'))+((T1*W_pu*(T2_p'))')+(gamma_p*T2_p*W_pu*(T2_p'));

W_sl=sdpvar(N+1,N+1,"symmetric","real");
dualF_sl=(T1*W_sl*(T1'))-(T2_sl*W_sl*(T2_sl'));
dualG_sl=(T1*W_sl*(T2_sl'))+((T1*W_sl*(T2_sl'))')+(gamma_sl*T2_sl*W_sl*(T2_sl'));

W_su=sdpvar(N+1,N+1,"symmetric","real");
dualF_su=(T1*W_su*(T1'))-(T2_su*W_su*(T2_su'));
dualG_su=(T1*W_su*(T2_su'))+((T1*W_su*(T2_su'))')+(gamma_su*T2_su*W_su*(T2_su'));

% Test failure
% Theta_su=(CD')*[ 1,0;0, -Esq_su/10  ]*CD; % DOES NOT FAIL !?!?!

Constraints=...
[W_pl>=0, 0<=dualG_pl<=0, dualF_pl<=0, ...
 W_pu>=0, 0<=dualG_pu<=0, dualF_pu<=0, ...
 W_sl>=0, 0<=dualG_sl<=0, dualF_sl<=0, ...
 W_su>=0, 0<=dualG_su<=0, dualF_su<=0, ...
 trace(W_pl*Theta_pl)<=0, trace(W_pu*Theta_pu)<=0, ...
 trace(W_sl*Theta_sl)<=0, trace(W_su*Theta_su)<=0];
Objective=-trace(W_pl*Theta_pl)-trace(W_pu*Theta_pu) ...
          -trace(W_sl*Theta_sl)-trace(W_su*Theta_su);
Options=sdpsettings("solver","sdpt3");
try
  sol=optimize(Constraints,Objective,Options);
catch
  err=lasterror();
  err.stack
  error("Caught YALMIP error : %s", err.message);
end_try_catch
if sol.problem
  error("YALMIP failed (%d) : %s", sol.problem, sol.info);
endif
% Sanity checks
check(Constraints)
fwrite(fhandle,
       sprintf("Dual constraints (sl,pl,pu,su) sol.problem=%d\n",sol.problem));

ostr=sprintf("norm(value(W_pl))=%10.3g,trace(value(W_pl)*Theta_pl)=%10.3g\n",
        norm(value(W_pl)),trace(value(W_pl)*Theta_pl));
printf(ostr);
fprintf(fhandle,ostr);

ostr=sprintf("norm(value(W_pu))=%10.3g,trace(value(W_pu)*Theta_pu)=%10.3g\n",
        norm(value(W_pu)),trace(value(W_pu)*Theta_pu));
printf(ostr);
fprintf(fhandle,ostr);

ostr=sprintf("norm(value(W_su))=%10.3g,trace(value(W_su)*Theta_su)=%10.3g\n",
        norm(value(W_su)),trace(value(W_su)*Theta_su));
printf(ostr);
fprintf(fhandle,ostr);

ostr=sprintf("norm(value(W_sl))=%10.3g,trace(value(W_sl)*Theta_sl)=%10.3g\n",
        norm(value(W_sl)),trace(value(W_sl)*Theta_sl));
printf(ostr);
fprintf(fhandle,ostr);

% Done
fclose(fhandle);
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
