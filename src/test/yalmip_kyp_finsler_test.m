% yalmip_kyp_finsler_test.m
% Copyright (C) 2024 Robert G. Jenssen
%
% Check the generalised KYP lemma after transformation by Finsler's lemma

test_common;

strf="yalmip_kyp_finsler_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

fhandle=fopen(strcat(strf,".results"),"w");

% Low-pass filter specification
fap=0.10;fas=0.20;dBas=40;

for N=[6,7],

  [b,a]=cheby2(N,40,fas*2);
  [A,B,C,D]=tf2Abcd(b,a);

  AB=[[A,B];[eye(N),zeros(N,1)]];
  Phi=[-1,0;0,1]; 
  Psi_s=[0,-1;-1,2*cos(2*pi*fas)];

  %
  % Test generalised KYP with constraint on maximum stop band amplitude
  %
  yalmip("clear");
  Esq_s=sdpvar(1,1,"full","real");
  P_s=sdpvar(N,N,"symmetric","real");
  Q_s=sdpvar(N,N,"symmetric","real");
  L_s=(AB')*(kron(Phi,P_s)+kron(Psi_s,Q_s))*AB;
  G_s=L_s + diag([zeros(1,N),-Esq_s]);
  F_s=[[G_s,[C,D]'];[C,D,-1]];

  % Solve
  sedumi_eps=1e-10;
  Objective=Esq_s;
  Options=sdpsettings("solver","sedumi","sedumi.eps",sedumi_eps);
  Constraints=[ 0<=Esq_s, F_s<=sedumi_eps, Q_s>=0];
  sol=optimize(Constraints,Objective,Options)
  if sol.problem == 0
    fprintf(fhandle,"N=%d, generalised KYP solved!\n",N);
  elseif sol.problem == 4
    error("YALMIP numerical problems : %s",sol.info);
  else 
    error("YALMIP failed : %s",sol.info);
  endif

  % Sanity checks
  check(Constraints)

  if abs(value(Esq_s)-10^(-dBas/10)) > 2*sedumi_eps
    error("abs(value(Esq_s)-10^(-dBas/10)) > 2*sedumi_eps");
  endif
  
  % Check stop band maximum amplitude response constraint matrixes
  eigs(value(Q_s),N)
  if any(eigs(value(Q_s),N) < -sedumi_eps/100)
    error("Q_s not positive semi-definite");
  endif
  if any(eigs(-value(F_s),N) < -2*sedumi_eps)
    error("F_s not negative semi-definite");
  endif

  %
  % Test Finsler generalised KYP with constraint on maximum stop band amplitude
  %
  
  yalmip("clear");
  Esq_s=sdpvar(1,1,"full","real");
  P_s=sdpvar(N,N,"symmetric","real");
  Q_s=sdpvar(N,N,"symmetric","real");
  XYZ_s=sdpvar((2*N)+1,N,"full","real");
  Eta_s=[[-eye(N),A,B,zeros(N,1)];[zeros(1,N),C,D,-1]]';
  Chi_s=[[XYZ_s,zeros((2*N)+1,1)];[zeros(1,N),1]]';
  EtaChi_s=Eta_s*Chi_s;
  L_s=(kron(Phi,P_s)+kron(Psi_s,Q_s));
  F_s=[[L_s,zeros(2*N,2)];[zeros(2,2*N),diag([-Esq_s,1])]]+EtaChi_s+(EtaChi_s');

  % Solve
  sedumi_eps=6.7e-7;
  Objective=Esq_s;
  Options=sdpsettings("solver","sedumi","sedumi.eps",sedumi_eps);
  Constraints=[ 0<=Esq_s, F_s<=sedumi_eps, Q_s>=0];
  sol=optimize(Constraints,Objective,Options)
  if sol.problem == 0
    fprintf(fhandle,"N=%d, Finsler generalised KYP solved!\n",N);
  elseif sol.problem == 4  
    error("YALMIP numerical problems : %s",sol.info);
  else 
    error("YALMIP failed : %s",sol.info);
  endif

  % Sanity checks
  check(Constraints)

  if abs(value(Esq_s)-10^(-dBas/10)) > 2*sedumi_eps
    error("Finsler abs(value(Esq_s)-10^(-dBas/10)) > 2*sedumi_eps");
  endif
  
  % Check stop band maximum amplitude response
  if any(eigs(value(Q_s),N) < -sedumi_eps/100)
    error("Finsler Q_s not positive semi-definite");
  endif
  if any(eigs(-value(F_s),N) < -sedumi_eps/100)
    error("Finsler F_s not negative semi-definite");
  endif

endfor

% Done
fclose(fhandle);
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
