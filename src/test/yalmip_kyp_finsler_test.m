% yalmip_kyp_finsler_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen
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
  if any(eigs(value(F_s),N+2) > 10*sedumi_eps)
    error("F_s not negative semi-definite");
  endif

  %
  % Test Finsler generalised KYP with constraint on maximum stop band amplitude
  %
  
  yalmip("clear");
  finsler_eps=1e-6;
  Esq_s=sdpvar(1,1,"full","real");
  P_s=sdpvar(N,N,"symmetric","real");
  Q_s=sdpvar(N,N,"symmetric","real");
  XYZ_s=sdpvar((2*N)+1,N,"full","real");
  U_s=[[-eye(N),A,B,zeros(N,1)];[zeros(1,N),C,D,-1]]';
  V_s=[[XYZ_s,zeros((2*N)+1,1)];[zeros(1,N),1]]';
  UV_s=U_s*V_s;
  L_s=(kron(Phi,P_s)+kron(Psi_s,Q_s));
  F_s=[[L_s,zeros(2*N,2)];[zeros(2,2*N),diag([-Esq_s,1])]]+UV_s+(UV_s');

  % Solve
  Objective=Esq_s;
  Options=sdpsettings("solver","sedumi","sedumi.eps",finsler_eps);
  Constraints=[ 0<=Esq_s, F_s<=finsler_eps, Q_s>=0];
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

  if abs(value(Esq_s)-10^(-dBas/10)) > 2e-6
    error("Finsler abs(value(Esq_s)-10^(-dBas/10)) > 2e-6");
  endif
  
  % Check stop band maximum amplitude response
  if any(eigs(value(Q_s),N) < -1e-9)
    error("Finsler Q_s not positive semi-definite");
  endif

  % Check Finsler lemma part 2
  if any(eigs(value(F_s),N+2) > finsler_eps)
    error("Finsler F_s not negative semi-definite");
  endif

  % Check Finsler lemma part 1
  Ut_s=[-eye(N),A,B]';
  cUt_s=[A,B;eye(N),zeros(N,1);zeros(1,N),1]';
  if max(max(abs(cUt_s*Ut_s))) > eps
    error("max(max(abs(cUt_s*Ut_s))) > eps");
  endif
  vUFP_s=value([[L_s,zeros(2*N,1)];[zeros(1,2*N),0]]);
  if any(eigs(cUt_s*vUFP_s*cUt_s',N+1) > 1e-4)
    error("Finsler UFP_s not negative semi-definite");
  endif
  % Alternatively
  vV_s=value(V_s);
  cvV_s=null(vV_s);
  if max(max(abs(vV_s*cvV_s))) > 10*eps
    error("max(max(abs(vV_s*cvV_s))) > 10*eps");
  endif
  vVFP_s=value([[L_s,zeros(2*N,2)];[zeros(2,2*N),diag([-Esq_s,1])]]);
  if any(eigs(cvV_s'*vVFP_s*cvV_s,N+1) > 1e-6)
    error("Finsler VFP_s not negative semi-definite");
  endif

endfor

% Done
fclose(fhandle);
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
