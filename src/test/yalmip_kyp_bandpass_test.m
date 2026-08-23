% yalmip_kyp_bandpass_test.m
%
% Test the generalised discrete time KYP lemma with the amplitude
% response of a symmetric FIR bandpass filter

% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="yalmip_kyp_bandpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tol=1e-7;

N=26; if rem(N,2), error("Expect N even!");endif; d=(N/2);
fasl=0.05;fapl=0.10;fapu=0.2;fasu=0.25;
nplot=10000;
nasl=ceil(fasl*nplot/0.5)+1;
napl=floor(fapl*nplot/0.5)+1;
napu=ceil(fapu*nplot/0.5)+1;
nasu=floor(fasu*nplot/0.5)+1;

h=remez(N,2*[0,fasl,fapl,fapu,fasu,0.5],[0,0,1,1,0,0],[10,1,20],"bandpass");
h=h(:)';
h_pz=h-[zeros(1,N/2),1,zeros(1,N/2)];
[H,w]=freqz(h,1,nplot);
Asq=abs(H).^2;
Asq_max=max(Asq);
Asq_max_sl=max(Asq(1:nasl));
Asq_max_plu=max(Asq(napl:napu));
Esq_max_pz=max(abs(abs(H(napl:napu))-1).^2);
Asq_max_su=max(Asq(nasu:end));

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
CD=[h;zeros(1,N),1];
CD_pz=[h_pz;zeros(1,N),1];
Phi=[-1,0;0,1]; 
c_sl=2*cos(2*pi*fasl);
Psi_sl=[0,1;1,-c_sl];
e_plu=e^(j*pi*(fapu+fapl));
c_plu=2*cos(pi*(fapu-fapl));
Psi_plu=[0,e_plu;conj(e_plu),-c_plu]; 
c_su=2*cos(2*pi*fasu);
Psi_su=[0,-1;-1,c_su];

% !! Reduced accuracy with use_theta=false !!
for use_theta=[true],
  
  %
  % Overall maximum response
  %
  % Optimisation variables
  Esq_max=sdpvar(1,1,"full","real");
  P_max=sdpvar(N,N,"symmetric","real");

  % Constraints
  if use_theta
    Pi_max=[[1,0];[0,-Esq_max-1]];
    Theta_max=(CD')*Pi_max*CD;
    F_max=(AB')*kron(Phi,P_max)*AB + Theta_max;
  else
    F_max=[[((AB')*kron(Phi,P_max)*AB) + ...
            diag([zeros(1,N),-Esq_max-1]),h']; ...
           [h,-1]];  
  endif
  Constraints=[F_max<=0,Esq_max>=0];

  % Find Asq_max
  Objective=Esq_max;
  Options=sdpsettings("solver","sedumi","sedumi.eps",tol/10);
  sol=optimize(Constraints,Objective,Options)
  if sol.problem
    error("YALMIP failed : %s",sol.info);
  endif
  kyp_Asq_max=value(Objective)+1;
  printf("Overall maximum response = %g, (Asq_max=%g)\n\n", ...
         kyp_Asq_max,Asq_max);
  if abs(kyp_Asq_max-Asq_max) > tol
    error("abs(kyp_Asq_max-Asq_max)(%g*tol) > tol", ...
          abs(kyp_Asq_max-Asq_max)/tol);
  endif

  %
  % Pass-band maximum response
  %
  % Optimisation variables
  Esq_plu=sdpvar(1,1,"full","real");
  P_plu=sdpvar(N,N,"symmetric","real");
  Q_plu=sdpvar(N,N,"symmetric","real");

  % Constraints
  if use_theta
    Pi_plu=[[1,0];[0,-Esq_plu-1]];
    Theta_plu=(CD')*Pi_plu*CD;
    F_plu=(AB')*[kron(Phi,P_plu)+kron(Psi_plu,Q_plu)]*AB + Theta_plu;
  else
    F_plu=[[((AB')*(kron(Phi,P_plu)+kron(Psi_plu,Q_plu))*AB) + ...
            diag([zeros(1,N),-Esq_plu-1]),h']; ...
           [h,-1]];
  endif
  Constraints=[Q_plu>=0,F_plu<=0,Esq_plu>=0];

  % Find Esq_plu
  Objective=Esq_plu;
  Options=sdpsettings("solver","sedumi","sedumi.eps",tol);
  sol=optimize(Constraints,Objective,Options)
  if sol.problem
    error("YALMIP failed : %s",sol.info);
  endif
  kyp_Asq_plu=value(Objective)+1;
  printf("Pass-band maximum response = %g, (Asq_max_plu=%g)\n\n", ...
         kyp_Asq_plu,Asq_max_plu);
  if abs(kyp_Asq_plu-Asq_max_plu) > 2*tol
    error("abs(kyp_Asq_plu-Asq_max_plu)(%g*tol) > 2*tol", ...
          abs(kyp_Asq_plu-Asq_max_plu)/tol);
  endif
  
  %
  % Pass-band maximum response error
  %
  % Optimisation variables
  Esq_pz=sdpvar(1,1,"full","real");
  P_pz=sdpvar(N,N,"symmetric","real");
  Q_pz=sdpvar(N,N,"symmetric","real");

  % Constraints
  if use_theta
    Pi_pz=[[1,0];[0,-Esq_pz]];
    Theta_pz=(CD_pz')*Pi_pz*CD_pz;
    F_pz=(AB')*[kron(Phi,P_pz)+kron(Psi_plu,Q_pz)]*AB + Theta_pz;
  else
    F_pz=[[((AB')*(kron(Phi,P_pz)+kron(Psi_plu,Q_pz))*AB) + ...
           diag([zeros(1,N),-Esq_pz]),h_pz']; ...
          [h_pz,-1]];
  endif
  Constraints=[Q_pz>=0,F_pz<=0,Esq_pz>=0];

  % Find Esq_pz
  Objective=Esq_pz;
  Options=sdpsettings("solver","sedumi","sedumi.eps",5*tol);
  sol=optimize(Constraints,Objective,Options)
  if sol.problem
    error("YALMIP failed : %s",sol.info);
  endif
  kyp_Esq_pz=value(Objective);
  printf("Pass-band maximum response error = %g, (Esq_max_pz=%g)\n\n", ...
         kyp_Esq_pz,Esq_max_pz);
  if abs(kyp_Esq_pz-Esq_max_pz) > 10*tol
    error("abs(kyp_Esq_pz-Esq_max_pz)(%g*tol) > 10*tol", ...
          abs(kyp_Esq_pz-Esq_max_pz)/tol);
  endif

  %
  % Lower stop-band maximum response error
  %
  % Optimisation variables
  Esq_sl=sdpvar(1,1,"full","real");
  P_sl=sdpvar(N,N,"symmetric","real");
  Q_sl=sdpvar(N,N,"symmetric","real");

  % Constraints
  if use_theta
    Pi_sl=[[1,0];[0,-Esq_sl]];
    Theta_sl=(CD')*Pi_sl*(CD);
    F_sl=(AB')*[kron(Phi,P_sl)+kron(Psi_sl,Q_sl)]*AB + Theta_sl;
  else
    F_sl=[[((AB')*(kron(Phi,P_sl)+kron(Psi_sl,Q_sl))*AB) + ...
           diag([zeros(1,N),-Esq_sl]),h']; ...
          [h,-1]];
  endif
  Constraints=[Q_sl>=0,F_sl<=0,Esq_sl>=0];

  % Find Esq_sl
  Objective=Esq_sl;
  Options=sdpsettings("solver","sedumi","sedumi.eps",tol);
  sol=optimize(Constraints,Objective,Options)
  if sol.problem
    error("YALMIP failed : %s",sol.info);
  endif
  kyp_Asq_sl=value(Objective);
  printf("Lower stop-band maximum response = %g, (Asq_max_sl=%g)\n\n", ...
         kyp_Asq_sl,Asq_max_sl);
  if abs(kyp_Asq_sl-Asq_max_sl) > 10*tol
    error("abs(kyp_Asq_sl-Asq_max_sl)(%g*tol) > 10*tol", ...
          abs(kyp_Asq_sl-Asq_max_sl)/tol);
  endif

  %
  % Upper stop-band maximum response error
  %
  % Optimisation variables
  Esq_su=sdpvar(1,1,"full","real");
  P_su=sdpvar(N,N,"symmetric","real");
  Q_su=sdpvar(N,N,"symmetric","real");

  % Constraints
  if use_theta
    Pi_su=[[1,0];[0,-Esq_su]];
    Theta_su=(CD')*Pi_su*(CD);
    F_su=(AB')*[kron(Phi,P_su)+kron(Psi_su,Q_su)]*AB + Theta_su;
  else
    F_su=[[((AB')*(kron(Phi,P_su)+kron(Psi_su,Q_su))*AB) + ...
           diag([zeros(1,N),-Esq_su]),h']; ...
          [h,-1]];
  endif
  Constraints=[Q_su>=0,F_su<=0,Esq_su>=0];

  % Find Esq_su
  Objective=Esq_su;
  Options=sdpsettings("solver","sedumi","sedumi.eps",200*tol);
  sol=optimize(Constraints,Objective,Options)
  if sol.problem
    error("YALMIP failed : %s",sol.info);
  endif
  kyp_Asq_su=value(Objective);
  printf("Upper stop-band maximum response = %g, (Asq_max_su=%g)\n\n", ...
         kyp_Asq_su,Asq_max_su);
  if abs(kyp_Asq_su-Asq_max_su) > 20*tol
    error("abs(kyp_Asq_su-Asq_max_su)(%g*tol) > 20*tol", ...
          abs(kyp_Asq_su-Asq_max_su)/tol);
  endif

endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
