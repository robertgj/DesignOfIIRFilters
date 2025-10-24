% yalmip_kyp_lowpass_Esq_s_test.m
% Copyright (C) 2022-2025 Robert G. Jenssen
%
% Use YALMIP to design low-pass FIR filters optimising (W_z*Esq_z)+(W_s*Esq_s)
test_common;

strf="yalmip_kyp_lowpass_Esq_s_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Avoid numerical problems messages
sedumi_eps=2e-6;

% Low-pass filter specification
M=15;N=2*M;
fap=0.10;fas=0.20;
Asq_max=Asq_pu=Asq_t=1.03^2;W_z=10;W_s=1;

for d=[10,12,M],

  yalmip("clear");
  
  % Common constants
  A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
  B=[zeros(N-1,1);1];
  AB=[A,B;eye(N),zeros(N,1)];
  C_d=zeros(1,N);
  C_d(N-d+1)=1;

  % Filter impulse response SDP variables
  if d==M,
    CM1=sdpvar(1,M+1,"full","real");
    CD=[CM1,CM1(M:-1:1)];
  else
    CD=sdpvar(1,N+1,"full","real");
  endif
  hsdp=fliplr(CD);
  CD_d=CD-[C_d,0];
  Phi=[-1,0;0,1]; 
  Psi_max=[0,1;1,2];
  c_p=2*cos(2*pi*fap);
  Psi_p=[0,1;1,-c_p];
  e_c=e^(j*pi*(fap+fas));
  c_h=2*cos(j*pi*(fap-fas));
  Psi_t=[0,e_c;1/e_c,-c_h]; 
  c_s=2*cos(2*pi*fas);
  Psi_s=[0,-1;-1,c_s];
  
  % Pass band constraint on the error |H(w)-e^(-j*w*d)|^2
  Esq_z=sdpvar(1,1,"symmetric","real");
  P_z=sdpvar(N,N,"symmetric","real");
  Q_z=sdpvar(N,N,"symmetric","real");
  Theta_z=[CD_d',[zeros(N,1);1]]*[[1,0];[0,-Esq_z]]*[CD_d;[zeros(1,N),1]];
  K_z=(AB')*(kron(Phi,P_z)+kron(Psi_p,Q_z))*AB;
  G_z=K_z + diag([zeros(1,N),-Esq_z]);
  F_z=[[G_z,CD_d'];[CD_d,-1]];
  
  % Constraint on maximum overall amplitude
  P_max=sdpvar(N,N,"symmetric","real");
  Q_max=sdpvar(N,N,"symmetric","real");
  Theta_max=[CD',[zeros(N,1);1]]*[1,0;0,-Asq_max]*[CD;[zeros(1,N),1]];
  K_max=(AB')*(kron(Phi,P_max)+kron(Psi_max,Q_max))*AB;
  K_max=(AB')*kron(Phi,P_max)*AB;
  G_max=K_max + diag([zeros(1,N),-Asq_max]);
  F_max=[[G_max,CD'];[CD,-1]];

  % Constraint on maximum pass band amplitude
  P_pu=sdpvar(N,N,"symmetric","real");
  Q_pu=sdpvar(N,N,"symmetric","real");
  Theta_pu=[CD',[zeros(N,1);1]]*[1,0;0,-Asq_pu]*[CD;[zeros(1,N),1]];
  K_pu=(AB')*(kron(Phi,P_pu)+kron(Psi_p,Q_pu))*AB;
  G_pu=K_pu + diag([zeros(1,N),-Asq_pu]);
  F_pu=[[G_pu,CD'];[CD,-1]];

  % Constraint on maximum transition band amplitude
  P_t=sdpvar(N,N,"symmetric","real");
  Q_t=sdpvar(N,N,"symmetric","real");
  Theta_t=[CD',[zeros(N,1);1]]*[1,0;0,-Asq_t]*[CD;[zeros(1,N),1]];
  K_t=(AB')*(kron(Phi,P_t)+kron(Psi_p,Q_t))*AB;
  G_t=K_t + diag([zeros(1,N),-Asq_t]);
  F_t=[[G_t,CD'];[CD,-1]];

  % Constraint on maximum stop band amplitude
  Esq_s=sdpvar(1,1,"symmetric","real");
  P_s=sdpvar(N,N,"symmetric","real");
  Q_s=sdpvar(N,N,"symmetric","real");
  Theta_s=[CD',[zeros(N,1);1]]*[[1,0];[0,-Esq_s]]*[CD;[zeros(1,N),1]];
  K_s=(AB')*(kron(Phi,P_s)+kron(Psi_s,Q_s))*AB;
  G_s=K_s + diag([zeros(1,N),-Esq_s]);
  F_s=[[G_s,CD'];[CD,-1]];

  % Solve
  Objective=(W_z*Esq_s)+(W_s*Esq_z);
  Options=sdpsettings("solver","sedumi","sedumi.eps",sedumi_eps);
  Constraints=[ F_z<=sedumi_eps,   Q_z>=0, ...
                F_max<=sedumi_eps, Q_max>=0, ...
                F_pu<=sedumi_eps,  Q_pu>=0, ...
                F_t<=sedumi_eps,   Q_t>=0, ...
                F_s<=sedumi_eps,   Q_s>=0, ...
                Esq_s>=sedumi_eps, ...
                Esq_z>=sedumi_eps ];

  sol=optimize(Constraints,Objective,Options)
  if sol.problem
    error("YALMIP failed : %s",sol.info);
  endif

  %
  % Sanity checks
  %
  
  check(Constraints)

  %
  % Plot response
  %
  
  h=value(hsdp);
  nplot=1000;
  nap=(fap*nplot/0.5)+1;
  nas=(fas*nplot/0.5)+1;
  if d==M,
    strs="KYP symmetric FIR";
  else
    subplot(211);
    strs="KYP non-symmetric FIR";
  endif
  strt=sprintf("%s : N=%d,d=%d,fap=%4.2f,fas=%4.2f,Esq\\_z=%6.1g,Esq\\_s=%6.1g", ...
               strs,N,d,fap,fas,value(Esq_z),value(Esq_s));
  [H,w]=freqz(h,1,nplot);
  [T,w]=delayz(h,1,nplot);
  f=w*0.5/pi;
  ax=plotyy(f(1:nap),20*log10(abs(H(1:nap))), ...
            f(nas:end),20*log10(abs(H(nas:end))));
  axis(ax(1),[0 0.5 -0.4 0.4]);
  axis(ax(2),[0 0.5 -80 -40]);
  ylabel(ax(1),"Amplitude(dB)");
  grid("on");
  title(strt);
  if d~=M,
    subplot(212)
    plot(f(1:nap),T(1:nap));
    axis([0 0.5 (d+0.2*[-1,1])]);
    grid("on");
    ylabel("Delay(samples)");
  endif
  xlabel("Frequency");
zticks([]);
  print(sprintf("%s_d_%2d_response",strf,d),"-dpdflatex");
  close

  % Check amplitude response
  [A_max,n_max]=max(abs(H));
  printf("max(A)=%11.6g(%6.4f) at f=%6.4f\n", ...
         A_max,sqrt(Asq_max),f(n_max));

  [A_p_max,n_p_max]=max(abs(H(1:nap)));
  printf("max(A_p)=%11.6g(%6.4f) at f=%6.4f\n", ...
         A_p_max,sqrt(Asq_pu),f(n_p_max));

  [A_p_min,n_p_min]=min(abs(H(1:nap)));
  printf("min(A_p)=%11.6g at f=%6.4f\n", ...
         A_p_min,f(n_p_min));

  [A_z,n_z_max]=max(abs(H(1:nap)-e.^(-j*w(1:nap)*d)));
  printf("max(A_z)=%11.6g(%6.4f) at f=%6.4f\n", ...
         A_z,sqrt(value(Esq_z)),f(n_z_max));

  [A_t_max,n_t_max]=max(abs(H((nap+1):(nas-1))));
  printf("max(A_t)=%11.6g(%6.4f) at f=%6.4f\n", ...
         A_t_max,sqrt(Asq_t),f(nap+n_t_max));

  [A_t_min,n_t_min]=min(abs(H((nap+1):(nas-1))));
  printf("min(A_t)=%11.6g at f=%6.4f\n", ...
         A_t_min,f(nap+n_t_min));

  [A_s_max,n_s_max]=max(abs(H(nas:end)));
  printf("max(A_s)=%11.6g(%6.4f) at f=%6.4f\n", ...
         A_s_max,sqrt(value(Esq_s)),f(nas-1+n_s_max));

  % Save
  print_polynomial(h,sprintf("h%2d",d),"%13.10f");
  print_polynomial(h,sprintf("h%2d",d), ...
                   sprintf("%s_d_%2d_coef.m",strf,d),"%13.10f");
endfor

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
