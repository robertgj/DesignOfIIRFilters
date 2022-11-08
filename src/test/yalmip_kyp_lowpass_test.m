% yalmip_kyp_lowpass_test.m
% Copyright (C) 2021-2022 Robert G. Jenssen
%
% Somewhat better numerical performance with (kron(P,Phi)+kron(Q,Psi)) !?!?
%
% TODO: Add a constraint on the minimum pass-band amplitude. For the
% frequency domain constraint Pi=[-I,0;0,+Esq*I] gives |H|^2>=Esq_pl.
% Is it possible to convert this to an LMI KYP constraint?

test_common;

strf="yalmip_kyp_lowpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

use_kron=true
use_constraint_on_pass_min=false

% Low-pass filter specification
M=15;N=2*M;
fap=0.10;fas=0.20;
Asq_pl=0.8^2;

for d=[10,M],
  if d==M, 
    Asq_max=1.0;
    Asq_pu=Asq_max;
    Asq_t=Asq_max;
    Esq_z=0.002^2;
    Esq_s=Esq_z;
    Wap=0;Wat=0;Was=0;
    use_objective=false;
  else 
    Asq_max=1.02^2;
    Asq_pu=Asq_max;
    Asq_t=Asq_max;
    Esq_z=0.1^2;
    Esq_s=0.005^2; 
    Wap=1;Wat=0.01;Was=100;
    use_objective=true;
  endif
  printf("Testing d=%2d, use_objective=%d\n",d,use_objective);
  
  % Common constants
  A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
  B=[zeros(N-1,1);1];
  AB=[A,B;eye(N),zeros(N,1)];
  C_d=zeros(1,N);
  C_d(N-d+1)=1;

  % Filter impulse response SDP variables
  if d==M,
    CM1=sdpvar(1,M+1);
    C=[CM1,CM1(M:-1:2)];
    D=CM1(1);
  else
    C=sdpvar(1,N);
    D=sdpvar(1,1);
  endif
  CD=[C,D];
  CD_d=CD-[C_d,0];
  hsdp=fliplr(CD);
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
  P_z=sdpvar(N,N,"symmetric","real");
  Q_z=sdpvar(N,N,"symmetric","real");
  F_z=sdpvar(N+2,N+2,"symmetric","real");
  if use_kron
    K_z=(AB')*(kron(Phi,P_z)+kron(Psi_p,Q_z))*AB;
    G_z=K_z + diag([zeros(1,N),-Esq_z]);
  else
    G_z=((AB')*[-P_z,Q_z;Q_z,P_z-(c_p*Q_z)]*AB) + ...
        diag([zeros(1,N),-Esq_z]);
  endif
  F_z=[[G_z,CD_d'];[CD_d,-1]];
  Theta_z=[CD_d',[zeros(N,1);1]]*[1,0;0,-Esq_z]*[CD_d;[zeros(1,N),1]];
  
  % Constraint on maximum overall amplitude
  P_max=sdpvar(N,N,"symmetric","real");
  Q_max=sdpvar(N,N,"symmetric","real");
  F_max=sdpvar(N+2,N+2,"symmetric","real");
  if use_kron
    K_max=(AB')*(kron(Phi,P_max)+kron(Psi_max,Q_max))*AB;
    G_max=K_max + diag([zeros(1,N),-Asq_max]);
  else
    G_max=((AB')*[-P_max,Q_max;Q_max,P_max+(2*Q_max)]*AB) + ...
          diag([zeros(1,N),-Asq_max]);
  endif
  F_max=[[G_max,CD'];[CD,-1]];
  Theta_max=[CD',[zeros(N,1);1]]*[1,0;0,-Asq_max]*[CD;[zeros(1,N),1]];

  % Constraint on maximum pass band amplitude
  P_pu=sdpvar(N,N,"symmetric","real");
  Q_pu=sdpvar(N,N,"symmetric","real");
  F_pu=sdpvar(N+2,N+2,"symmetric","real");
  if use_kron
    K_pu=(AB')*(kron(Phi,P_pu)+kron(Psi_p,Q_pu))*AB;
    G_pu=K_pu + diag([zeros(1,N),-Asq_pu]);
  else
    G_pu=((AB')*[-P_pu,Q_pu;Q_pu,P_pu-(c_p*Q_pu)]*AB) + ...
         diag([zeros(1,N),-Asq_pu]);
  endif
  F_pu=[[G_pu,CD'];[CD,-1]];
  Theta_pu=[CD',[zeros(N,1);1]]*[1,0;0,-Asq_pu]*[CD;[zeros(1,N),1]];

  % Constraint on minimum pass band amplitude
  if use_constraint_on_pass_min==true
    P_pl=sdpvar(N,N,"symmetric","real");
    Q_pl=sdpvar(N,N,"symmetric","real");
    F_pl=sdpvar(N,N,"symmetric","real");
    Theta_pl=[CD',[zeros(N,1);1]]*[-1,0;0,Asq_pl]*[CD;[zeros(1,N),1]];
    F_pl=((AB')*(kron(Phi,P_pl)+kron(Psi_p,Q_pl))*AB) + Theta_pl;
  endif
  
  % Constraint on maximum transition band amplitude
  P_t=sdpvar(N,N,"symmetric","real");
  Q_t=sdpvar(N,N,"symmetric","real");
  F_t=sdpvar(N+2,N+2,"symmetric","real");
  if use_kron
    K_t=(AB')*(kron(Phi,P_t)+kron(Psi_p,Q_t))*AB;
    G_t=K_t + diag([zeros(1,N),-Asq_t]);
  else
    G_t=((AB')*[-P_t,e_c*Q_t;Q_t/e_c,P_t-(c_h*Q_t)]*AB) + ...
        diag([zeros(1,N),-Asq_t]);
  endif
  F_t=[[G_t,CD'];[CD,-1]];
  Theta_t=[CD',[zeros(N,1);1]]*[1,0;0,-Asq_t]*[CD;[zeros(1,N),1]];

  % Constraint on maximum stop band amplitude
  P_s=sdpvar(N,N,"symmetric","real");
  Q_s=sdpvar(N,N,"symmetric","real");
  F_s=sdpvar(N+2,N+2,"symmetric","real");
  if use_kron
    K_s=(AB')*(kron(Phi,P_s)+kron(Psi_s,Q_s))*AB;
    G_s=K_s + diag([zeros(1,N),-Esq_s]);
  else
    G_s=((AB')*[-P_s,-Q_s;-Q_s,P_s+(c_s*Q_s)]*AB) + ...
        diag([zeros(1,N),-Esq_s]);
  endif
  F_s=[[G_s,CD'];[CD,-1]];
  Theta_s=[CD',[zeros(N,1);1]]*[1,0;0,-Esq_s]*[CD;[zeros(1,N),1]];

  % Solve
  if use_objective
    [~,~,G,g]=directFIRnonsymmetricEsqPW ...
      (zeros(N+1,1),[0,fap,fas,0.5]*2*pi,[1,0,0],[d,0,0],[Wap,Wat,Was]);
    Objective=(hsdp*G*hsdp')+(2*hsdp*g')+(2*fap);
  else
    Objective=[];
  endif

  Constraints=[ F_z<=0,   Q_z>=0, ...
                F_max<=0, Q_max>=0, ...
                F_pu<=0,  Q_pu>=0, ...
                F_t<=0,   Q_t>=0, ...
                F_s<=0,   Q_s>=0 ];
  if use_constraint_on_pass_min==true
    Constraints=[Constraints, F_pl<=0, Q_pl>=0];
  endif
  
  if use_constraint_on_pass_min
    Options=sdpsettings("solver","bmibnb");
  else
    Options=sdpsettings("solver","sedumi");    
  endif
  
  sol=optimize(Constraints,Objective,Options)
  if sol.problem
    error("YALMIP failed : %s",sol.info);
  endif
  
  % Sanity checks
  check(Constraints)
  if ~ishermitian(value(P_z))
    error("P_z not hermitian");
  endif
  if ~isdefinite(value(Q_z))
    error("Q_z not positive semi-definite");
  endif
  if ~isdefinite(-value(F_z))
    error("F_z not negative semi-definite");
  endif
  if any(any(abs(imag(value(K_z+Theta_z)))>eps))
    error("any(any(abs(imag(value(K_z+Theta_z)))>eps))");
  endif
  if ~isdefinite(-value(K_z+Theta_z))
    error("K_z+Theta_z not negative semi-definite");
  endif
  if ~issymmetric(value(P_max)) || ~isreal(value(P_max))
    error("P_max not real and symmetric");
  endif
  if ~isdefinite(value(Q_max))
    error("Q_max not positive semi-definite");
  endif
  if ~isdefinite(-value(F_max))
    error("F_max not negative semi-definite");
  endif
  if any(any(abs(imag(value(K_max+Theta_max)))>eps))
    error("any(any(abs(imag(value(K_max+Theta_max)))>eps))");
  endif
  if ~isdefinite(-value(K_max+Theta_max))
    error("K_max+Theta_max not negative semi-definite");
  endif
  if ~issymmetric(value(P_pu)) || ~isreal(value(P_pu))
    error("P_pu not real and symmetric");
  endif
  if ~isdefinite(value(Q_pu))
    error("Q_pu not positive semi-definite");
  endif
  if ~isdefinite(-value(F_pu))
    error("F_pu not negative semi-definite");
  endif 
  if any(any(abs(imag(value(K_pu+Theta_pu)))>eps))
    error("any(any(abs(imag(value(K_pu+Theta_pu)))>eps))");
  endif
  if ~isdefinite(-value(K_pu+Theta_pu))
    error("K_pu+Theta_pu not negative semi-definite");
  endif
  if use_constraint_on_pass_min==true
    if ~issymmetric(value(P_pl)) || ~isreal(value(P_pl))
      error("P_pl not real and symmetric");
    endif
    if ~isdefinite(value(Q_pl))
      error("Q_pl not positive semi-definite");
    endif
    if ~isdefinite(value(F_pl))
      error("F_pl not positive semi-definite");
    endif
  endif
  if ~issymmetric(value(P_t)) || ~isreal(value(P_t))
    error("P_t not real and symmetric");
  endif
  if ~isdefinite(value(Q_t))
    error("Q_t not positive semi-definite");
  endif
  if ~isdefinite(-value(F_t))
    error("F_t not negative semi-definite");
  endif
  if any(any(abs(imag(value(K_t+Theta_t)))>eps))
    error("any(any(abs(imag(value(K_t+Theta_t)))>eps))");
  endif
  if ~isdefinite(-value(K_t+Theta_t))
    error("K_t+Theta_t not negative semi-definite");
  endif
  if ~issymmetric(value(P_s)) || ~isreal(value(P_s))
    error("P_s not real and symmetric");
  endif
  if ~isdefinite(value(Q_s))
    error("Q_s not positive semi-definite");
  endif
  if ~isdefinite(-value(F_s))
    error("F_s not negative semi-definite");
  endif
  if any(any(abs(imag(value(K_s+Theta_s)))>eps))
    error("any(any(abs(imag(value(K_s+Theta_s)))>eps))");
  endif
  if ~isdefinite(-value(K_s+Theta_s))
    error("K_s+Theta_s not negative semi-definite");
  endif

  % Plot response
  h=value(hsdp);
  nplot=1000;
  nap=(fap*nplot/0.5)+1;
  nas=(fas*nplot/0.5)+1;
  if d==M,
    strs=sprintf("KYP symmetric FIR")
  else
    subplot(211);
    strs=sprintf("KYP non-symmetric FIR")
  endif
  strt=sprintf("%s : N=%d,d=%d,fap=%4.2f,fas=%4.2f,Esq\\_z=%7.1g,Esq\\_s=%7.1g",
               strs,N,d,fap,fas,Esq_z,Esq_s);
  [H,w]=freqz(h,1,nplot);
  [T,w]=grpdelay(h,1,nplot);
  f=w*0.5/pi;
  ax=plotyy(f(1:nap),20*log10(abs(H(1:nap))), ...
            f(nas:end),20*log10(abs(H(nas:end))));
  set(ax(1),'ycolor','black');
  set(ax(2),'ycolor','black');
  if d==M, 
    axis(ax(1),[0 0.5 0.02*[-1 1]]);
  else
    axis(ax(1),[0 0.5 [-1 1]]);
  endif
  axis(ax(2),[0 0.5 -80 -40]);
  ylabel(ax(1),"Amplitude(dB)");
  grid("on");
  title(strt);
  if d~=M,
    subplot(212)
    plot(f(1:nap),T(1:nap));
    axis([0 0.5 d-1 d+1]);
    grid("on");
    ylabel("Delay(samples)");
  endif
  xlabel("Frequency");
  print(sprintf("%s_d_%2d_response",strf,d),"-dpdflatex");
  close

  % Check amplitude response
  if use_objective
    printf("Objective=%11.6g\n",value(Objective));
  endif
  [A_max,n_max]=max(abs(H));
  printf("max(A)=%11.6g(%6.4f) at f=%6.4f\n",
         A_max,sqrt(Asq_max),f(n_max));

  [A_p_max,n_p_max]=max(abs(H(1:nap)));
  printf("max(A_p)=%11.6g(%6.4f) at f=%6.4f\n",
         A_p_max,sqrt(Asq_pu),f(n_p_max));

  [A_p_min,n_p_min]=min(abs(H(1:nap)));
  if use_constraint_on_pass_min==true
    printf("min(A_p)=%11.6g(%6.4f) at f=%6.4f\n",
           A_p_min,sqrt(Asq_pl),f(n_p_min));
  else
    printf("min(A_p)=%11.6g at f=%6.4f\n", A_p_min,f(n_p_min));
  endif

  [A_z,n_z_max]=max(abs(H(1:nap)-e.^(-j*w(1:nap)*d)));
  printf("max(A_z)=%11.6g(%6.4f) at f=%6.4f\n",
         A_z,sqrt(Esq_z),f(n_z_max));

  [A_t_max,n_t_max]=max(abs(H((nap+1):(nas-1))));
  printf("max(A_t)=%11.6g(%6.4f) at f=%6.4f\n",
         A_t_max,sqrt(Asq_t),f(nap+n_t_max));

  [A_t_min,n_t_min]=min(abs(H((nap+1):(nas-1))));
  printf("min(A_t)=%11.6g at f=%6.4f\n",
         A_t_min,f(nap+n_t_min));

  [A_s_max,n_s_max]=max(abs(H(nas:end)));
  printf("max(A_s)=%11.6g(%6.4f) at f=%6.4f\n",
         A_s_max,sqrt(Esq_s),f(nas-1+n_s_max));

  % Save
  print_polynomial(h,sprintf("h%2d",d),"%13.10f");
  print_polynomial(h,sprintf("h%2d",d), ...
                   sprintf("%s_d_%2d_coef.m",strf,d),"%13.10f");
endfor

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
