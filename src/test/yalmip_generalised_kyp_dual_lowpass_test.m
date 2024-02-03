% yalmip_generalised_kyp_dual_lowpass_test.m
% Copyright (C) 2024 Robert G. Jenssen

test_common;

strf="yalmip_generalised_kyp_dual_lowpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

fhandle=fopen(strcat(strf,".results"),"w");

tic;

%
% Low-pass filter
%
M=7;N=2*M;fap=0.1;fas=0.2;

h=remez(2*M,2*[0,fap,fas,0.5],[1,1,0,0]);
h=h(:)';
nplot=1000;
nap=ceil(nplot*fap/0.5)+1;
nas=floor(nplot*fas/0.5)+1;

% Amplitude constraints
[H,w]=freqz(h,1,nplot);
H_2=abs(H).^2;
max_H_2=max(H_2);
Esq_pl=floor(min(H_2(1:nap))*1e5)/1e5;
Esq_pu=ceil(max(H_2(1:nap))*1e5)/1e5;
Esq_s=ceil(max(H_2(nas:end))*1e5)/1e5;
Esq_tu=ceil(max(H_2(nap:nas))*1e5)/1e5;
Esq_tl=floor(min(H_2(nap:nas))*1e5)/1e5;

% Frequency constriants
fc=(fap+fas)/2;
fm=(fas-fap)/2;
alpha_p=1;
alpha_s=-1;
alpha_t=e^(i*2*pi*fc);
gamma_p=-2*cos(2*pi*fap);
gamma_s= 2*cos(2*pi*fas);
gamma_t=-2*cos(2*pi*fm);

Phi=[-1,0;0,1];
Psi_p=[0,1;1,gamma_p];
Psi_s=[0,1;1,gamma_s];
Psi_t=[0,1;1,gamma_t];
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB_p=[A,B;alpha_p*eye(N),zeros(N,1)];
AB_s=[A,B;alpha_s*eye(N),zeros(N,1)];
AB_t=[A,B;alpha_t*eye(N),zeros(N,1)];
C=h(1:end-1);
D=h(end);
CD=[C,D;zeros(1,N),1];
Theta_pl=(CD')*[-1,0;0, Esq_pl]*CD;
Theta_pu=(CD')*[ 1,0;0,-Esq_pu]*CD;
Theta_s= (CD')*[ 1,0;0,-Esq_s ]*CD;
Theta_tl=(CD')*[-1,0;0, Esq_tl]*CD;
Theta_tu=(CD')*[ 1,0;0,-Esq_tu]*CD;
T1=[A,B];
T2_p=[alpha_p*eye(N),zeros(N,1)];
T2_s=[alpha_s*eye(N),zeros(N,1)];
T2_t=[alpha_t*eye(N),zeros(N,1)];

% Test failure
% Theta_s=(CD')*[ 1,0;0,-Esq_s/2 ]*CD;

%
% Test the filter response with KYP
%
P_pl=sdpvar(N,N,"symmetric","real");
Q_pl=sdpvar(N,N,"symmetric","real");
F_pl=Theta_pl+((AB_p')*(kron(Phi,P_pl)+kron(Psi_p,Q_pl))*AB_p);

P_pu=sdpvar(N,N,"symmetric","real");
Q_pu=sdpvar(N,N,"symmetric","real");
F_pu=Theta_pu+((AB_p')*(kron(Phi,P_pu)+kron(Psi_p,Q_pu))*AB_p);

P_s=sdpvar(N,N,"symmetric","real");
Q_s=sdpvar(N,N,"symmetric","real");
F_s=Theta_s+((AB_s')*(kron(Phi,P_s)+kron(Psi_s,Q_s))*AB_s);

P_tl=sdpvar(N,N,"symmetric","real");
Q_tl=sdpvar(N,N,"symmetric","real");
F_tl=Theta_tl+((AB_t')*(kron(Phi,P_tl)+kron(Psi_t,Q_tl))*AB_t);

P_tu=sdpvar(N,N,"symmetric","real");
Q_tu=sdpvar(N,N,"symmetric","real");
F_tu=Theta_tu+((AB_t')*(kron(Phi,P_tu)+kron(Psi_t,Q_tu))*AB_t);

% Pass band upper and lower bounds, stop and transition band upper bounds
Constraints=[F_pl<=0,Q_pl>=0,F_pu<=0,Q_pu>=0,F_s<=0,Q_s>=0,F_tu<=0,Q_tu>=0];
Objective=[];
Options=sdpsettings("solver","sedumi"); 
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed (%d) : %s",sol.problem,sol.info);
endif
% Sanity checks
check(Constraints)
fwrite(fhandle,
       sprintf("Primary constraints (pl,pu,s,tu) sol.problem=%d\n",sol.problem));

% Transition band lower bound. When I add this to the previous problem:
%    "SeDuMi had unexplained problems, maybe due to linear dependence?"
Constraints=[F_tl<=0,Q_tl>=0];
Options=sdpsettings("solver","sedumi"); 
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed (%d) : %s",sol.problem,sol.info);
endif
% Sanity checks
check(Constraints)
fwrite(fhandle, ...
       sprintf("Primary constraints (tu) sol.problem=%d\n",sol.problem));

%
% Test the filter response with dual KYP
%
yalmip("clear");
use_W=true;
sedumi_eps=1e-6;

W_pl=sdpvar(N+1,N+1,"symmetric","real");
if use_W
  W_pl11=W_pl(1:N,1:N);  
  W_pl12=W_pl(1:N,N+1);
  W_pl22=W_pl(N+1,N+1);
  dualF_pl=...
    (A*W_pl11*(A'))+(B*(W_pl12')*(A'))+(A*W_pl12*(B'))+(B*W_pl22*(B'))-W_pl11;
  dualG_pl=(conj(alpha_p)*((A*W_pl11)+(B*(W_pl12'))))+ ...
           (alpha_p*(W_pl11*(A'))+(W_pl12*(B'))) + ...
           (gamma_p*W_pl11);
else
  dualF_pl=(T1*W_pl*(T1'))-(T2_p*W_pl*(T2_p'));
  dualG_pl=(T1*W_pl*(T2_p'))+((T1*W_pl*(T2_p'))')+(gamma_p*T2_p*W_pl*(T2_p'));
endif

W_pu=sdpvar(N+1,N+1,"symmetric","real");
if use_W
  W_pu11=W_pu(1:N,1:N);  
  W_pu12=W_pu(1:N,N+1);
  W_pu22=W_pu(N+1,N+1);
  dualF_pu=...
    (A*W_pu11*(A'))+(B*(W_pu12')*(A'))+(A*W_pu12*(B'))+(B*W_pu22*(B'))-W_pu11;
  dualG_pu=(conj(alpha_p)*((A*W_pu11)+(B*(W_pu12'))))+ ...
           (alpha_p*(W_pu11*(A'))+(W_pu12*(B'))) + ...
           (gamma_p*W_pu11);
else
  dualF_pu=(T1*W_pu*(T1'))-(T2_p*W_pu*(T2_p'));
  dualG_pu=(T1*W_pu*(T2_p'))+((T1*W_pu*(T2_p'))')+(gamma_p*T2_p*W_pu*(T2_p'));
endif

W_s=sdpvar(N+1,N+1,"symmetric","real");
if use_W
  W_s11=W_s(1:N,1:N);  
  W_s12=W_s(1:N,N+1);
  W_s22=W_s(N+1,N+1);
  dualF_s=...
    (A*W_s11*(A'))+(B*(W_s12')*(A'))+(A*W_s12*(B'))+(B*W_s22*(B'))-W_s11;
  dualG_s=(conj(alpha_s)*((A*W_s11)+(B*(W_s12'))))+ ...
          (alpha_s*((W_s11*(A'))+(W_s12*(B')))) + ...
          (gamma_s*W_s11);
else
  dualF_s=(T1*W_s*(T1'))-(T2_s*W_s*(T2_s'));
  dualG_s=(T1*W_s*(T2_s'))+((T1*W_s*(T2_s'))')+(gamma_s*T2_s*W_s*(T2_s'));
endif

% Test failure
% Theta_pl=(CD')*[ -1,0;0, 0.99 ]*CD; % DOES NOT FAIL !?!?!
% Theta_pu=(CD')*[ 1,0;0, -1 ]*CD;
% Theta_s=(CD')*[ 1,0; 0, -Esq_s/2]*CD;

Constraints=...
[W_pl>=-sedumi_eps, -sedumi_eps<=dualG_pl<=sedumi_eps, dualF_pl<=sedumi_eps, ...
 W_pu>=-sedumi_eps, -sedumi_eps<=dualG_pu<=sedumi_eps, dualF_pu<=sedumi_eps, ...
 W_s>=-sedumi_eps,  -sedumi_eps<=dualG_s<=sedumi_eps,  dualF_s<=sedumi_eps,  ...
 trace(W_pl*Theta_pl)<=0, trace(W_pu*Theta_pu)<=0, trace(W_s*Theta_s)<=0];
Objective=-trace(W_pl*Theta_pl)-trace(W_pu*Theta_pu)-trace(W_s*Theta_s);
Options=sdpsettings("solver","sedumi","sedumi.eps",sedumi_eps);
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
       sprintf("Dual constraints (pl,pu,s) sol.problem=%d\n",sol.problem));

% SeDuMi fails for complex alpha.
% dualG_tu and dualG_tl give "warning: Suspect non-symmetry in square constaint"
W_tu=sdpvar(N+1,N+1,"symmetric","real");
dualF_tu=(T1*W_tu*(T1'))-(T2_t*W_tu*(T2_t'));
dualG_tu=(T1*W_tu*(T2_t'))+((T1*W_tu*(T2_t'))')+gamma_t*T2_t*W_tu*(T2_t');
W_tl=sdpvar(N+1,N+1,"symmetric","real");
dualF_tl=(T1*W_tl*(T1'))-(T2_t*W_tl*(T2_t'));
dualG_tl=(T1*W_tl*(T2_t'))+((T1*W_tl*(T2_t'))')+gamma_t*T2_t*W_tl*(T2_t');
if 0 
sedumi_eps=1e-10;
Constraints=[-sedumi_eps<=W_tu, ...
             dualF_tu<=sedumi_eps, ...
             -sedumi_eps<=dualG_tu<=sedumi_eps, ...
             trace(W_tu*Theta_tu)<=0, ...
             -sedumi_eps<=W_tl, ...
             dualF_tl<=sedumi_eps, ...
             -sedumi_eps<=dualG_tl<=sedumi_eps, ...
             trace(W_tl*Theta_tl)<=0];
 sstr="SeDuMi"; Options=sdpsettings("solver","sedumi","sedumi.eps",sedumi_eps);
else
Constraints=[0<=W_tu, ...
             dualF_tu<=0, ...
             0<=dualG_tu<=0, ...
             trace(W_tu*Theta_tu)<=0, ...
             0<=W_tl, ...
             dualF_tl<=0, ...
             0<=dualG_tl<=0, ...
             trace(W_tl*Theta_tl)<=0];
  sstr="SDPT3"; Options=sdpsettings("solver","sdpt3");
endif
Objective=-trace(W_tu*Theta_tu)-trace(W_tl*Theta_tl);
%Objective=[];
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
       sprintf("Dual constraints (%s,tl,tu) sol.problem=%d\n",sstr,sol.problem));

ostr=sprintf("norm(value(W_pl))=%10.3g,trace(value(W_pl)*Theta_pl)=%10.3g\n",
        norm(value(W_pl)),trace(value(W_pl)*Theta_pl));
printf(ostr);
fprintf(fhandle,ostr);

ostr=sprintf("norm(value(W_pu))=%10.3g,trace(value(W_pu)*Theta_pu)=%10.3g\n",
        norm(value(W_pu)),trace(value(W_pu)*Theta_pu));
printf(ostr);
fprintf(fhandle,ostr);

ostr=sprintf("norm(value(W_s))= %10.3g,trace(value(W_s)*Theta_s)=  %10.3g\n",
        norm(value(W_s)), trace(value(W_s)*Theta_s));
printf(ostr);
fprintf(fhandle,ostr);

ostr=sprintf("norm(value(W_tu))=%10.3g,trace(value(W_tu)*Theta_tu)=%10.3g\n",
        norm(value(W_tu)),trace(value(W_tu)*Theta_tu));
printf(ostr);
fprintf(fhandle,ostr);

ostr=sprintf("norm(value(W_tl))=%10.3g,trace(value(W_tl)*Theta_tl)=%10.3g\n",
        norm(value(W_tl)),trace(value(W_tl)*Theta_tl));
printf(ostr);
fprintf(fhandle,ostr);

% Done
fclose(fhandle);
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
