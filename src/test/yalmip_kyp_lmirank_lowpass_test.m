% yalmip_kyp_lmirank_lowpass_test.m
% Copyright (C) 2022-2025 Robert G. Jenssen
%
% Try using LMIRank to solve the KYP lemma problem without
% using the Schur complement using the constraint : rank(X)<=1
% for X intended to be the solution [C,D]'*[C,D].

test_common;

strf="yalmip_kyp_lmirank_lowpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Low-pass filter specification
M=15;
N=2*M;
fap=0.10;
fas=0.20;
Asq_pl=0.8^2;
d=M; 
Asq_pu=1.02;
Asq_pu=0.64;
Esq_s=0.002^2;
  
% Demonstrate properties of a rank 1 matrix
b=remez(N,[0 fap fas 0.5]*2,[1 1 0 0]);
b=b(:)/sum(b);
B=b*b';
[U,S,V]=svd(B);
if sum(any(abs(diag(S))>eps)) > 1
  error("B has more than one non-zero eigenvalue!");
endif
if max(abs(1-(b./(U(:,1)/sum(U(:,1)))))) > 50*eps
  error("Did not recover b from U!");
endif

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
X=sdpvar(N+1,N+1,"symmetric","real");

% Constraint on maximum pass band amplitude
P_pu=sdpvar(N,N,"symmetric","real");
Q_pu=sdpvar(N,N,"symmetric","real");
K_pu=(AB')*(kron(Phi,P_pu)+kron(Psi_p,Q_pu))*AB;
G_pu=K_pu + diag([zeros(1,N),-Asq_pu]) + X;

% Constraint on minimum pass band amplitude
P_pl=sdpvar(N,N,"symmetric","real");
Q_pl=sdpvar(N,N,"symmetric","real");
K_pl=(AB')*(kron(Phi,P_pl)+kron(Psi_p,Q_pl))*AB;
G_pl=K_pl + diag([zeros(1,N),Asq_pl]) - X;

% Constraint on maximum stop band amplitude
P_s=sdpvar(N,N,"symmetric","real");
Q_s=sdpvar(N,N,"symmetric","real");
K_s=(AB')*(kron(Phi,P_s)+kron(Psi_s,Q_s))*AB;
G_s=K_s + diag([zeros(1,N),-Esq_s]) + X;

% Solve
Constraints=[ rank(X) <= 1, ...
              G_pu<=0,  Q_pu>=0, ...
              G_pl<=0,  Q_pl>=0, ...
              G_s<=0,   Q_s>=0 ];
Objective=[];
Options=sdpsettings("solver","lmirank");    
sol=optimize(Constraints,Objective,Options)
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif

% Sanity checks
check(Constraints)
if rank(value(X)) ~= 1
  error("rank(value(X)) ~= 1");
endif
if ~issymmetric(value(P_pu)) || ~isreal(value(P_pu))
  error("P_pu not real and symmetric");
endif
if ~isdefinite(value(Q_pu))
  error("Q_pu not positive semi-definite");
endif
if ~isdefinite(-value(G_pu))
  error("G_pu not negative semi-definite");
endif 
if ~issymmetric(value(P_pl)) || ~isreal(value(P_pl))
  error("P_pl not real and symmetric");
endif
if ~isdefinite(value(Q_pl))
  error("Q_pl not positive semi-definite");
endif
if ~isdefinite(value(G_pl))
  error("G_pl not positive semi-definite");
endif
if ~issymmetric(value(P_s)) || ~isreal(value(P_s))
  error("P_s not real and symmetric");
endif
if ~isdefinite(value(Q_s))
  error("Q_s not positive semi-definite");
endif
if ~isdefinite(-value(G_s))
  error("G_s not negative semi-definite");
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
strt=sprintf("%s : N=%d,d=%d,fap=%4.2f,fas=%4.2f,Esq\\_z=%7.1g,Esq\\_s=%7.1g", ...
             strs,N,d,fap,fas,Esq_z,Esq_s);
[H,w]=freqz(h,1,nplot);
[T,w]=delayz(h,1,nplot);
f=w*0.5/pi;
ax=plotyy(f(1:nap),20*log10(abs(H(1:nap))), ...
          f(nas:end),20*log10(abs(H(nas:end))));
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
zticks([]);
print(sprintf("%s_d_%2d_response",strf,d),"-dpdflatex");
close

% Check amplitude response
if use_objective
  printf("Objective=%11.6g\n",value(Objective));
endif
[A_max,n_max]=max(abs(H));
printf("max(A)=%11.6g(%6.4f) at f=%6.4f\n", ...
       A_max,sqrt(Asq_max),f(n_max));

[A_p_max,n_p_max]=max(abs(H(1:nap)));
printf("max(A_p)=%11.6g(%6.4f) at f=%6.4f\n", ...
       A_p_max,sqrt(Asq_pu),f(n_p_max));

[A_p_min,n_p_min]=min(abs(H(1:nap)));
if use_constraint_on_pass_min==true
  printf("min(A_p)=%11.6g(%6.4f) at f=%6.4f\n", ...
         A_p_min,sqrt(Asq_pl),f(n_p_min));
else
  printf("min(A_p)=%11.6g at f=%6.4f\n", A_p_min,f(n_p_min));
endif

[A_z,n_z_max]=max(abs(H(1:nap)-e.^(-j*w(1:nap)*d)));
printf("max(A_z)=%11.6g(%6.4f) at f=%6.4f\n", ...
       A_z,sqrt(Esq_z),f(n_z_max));

[A_t_max,n_t_max]=max(abs(H((nap+1):(nas-1))));
printf("max(A_t)=%11.6g(%6.4f) at f=%6.4f\n", ...
       A_t_max,sqrt(Asq_t),f(nap+n_t_max));

[A_t_min,n_t_min]=min(abs(H((nap+1):(nas-1))));
printf("min(A_t)=%11.6g at f=%6.4f\n", ...
       A_t_min,f(nap+n_t_min));

[A_s_max,n_s_max]=max(abs(H(nas:end)));
printf("max(A_s)=%11.6g(%6.4f) at f=%6.4f\n", ...
       A_s_max,sqrt(Esq_s),f(nas-1+n_s_max));

% Save
print_polynomial(h,sprintf("h%2d",d),"%13.10f");
print_polynomial(h,sprintf("h%2d",d), ...
                 sprintf("%s_d_%2d_coef.m",strf,d),"%13.10f");

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
