% yalmip_kyp_bmibnb_lowpass_test.m
% Copyright (C) 2022 Robert G. Jenssen
%
% Add a constraint on the minimum pass-band amplitude using the bmibnb solver.
% For the frequency domain constraint Pi=[-I,0;0,+Esq*I] gives |H|^2>=Esq_pl.
% When this script is run, YALMIP bails out after 15000 seconds.

test_common;

strf="yalmip_kyp_bmibnb_lowpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Low-pass filter specification
M=10;N=2*M;
fap=0.10;fas=0.20;
Asq_max=1.1;
Asq_pl=0.8;
Esq_s=2e-2;

  % Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];

% Filter impulse response SDP variables
CM1=sdpvar(1,M+1);
C=[CM1,CM1(M:-1:2)];
D=CM1(1);
CD=[C,D];
hsdp=fliplr(CD);
Phi=[-1,0;0,1]; 
Psi_max=[0,1;1,2];
c_p=2*cos(2*pi*fap);
Psi_p=[0,1;1,-c_p];
c_s=2*cos(2*pi*fas);
Psi_s=[0,-1;-1,c_s];

% Constraint on maximum overall amplitude
P_max=sdpvar(N,N,"symmetric","real");
Q_max=sdpvar(N,N,"symmetric","real");
F_max=sdpvar(N+2,N+2,"symmetric","real");
G_max=((AB')*(kron(Phi,P_max)+kron(Psi_max,Q_max))*AB) + ...
      diag([zeros(1,N),-Asq_max]);
F_max=[[G_max,CD'];[CD,-1]];

% Constraint on minimum pass band amplitude
P_pl=sdpvar(N,N,"symmetric","real");
Q_pl=sdpvar(N,N,"symmetric","real");
F_pl=sdpvar(2*N,2*N,"symmetric","real");
Theta_pl=[CD',[zeros(N,1);1]]*[-1,0;0,Asq_pl]*[CD;[zeros(1,N),1]];
F_pl=((AB')*(kron(Phi,P_pl)+kron(Psi_p,Q_pl))*AB)+Theta_pl;

% Constraint on maximum stop band amplitude
P_s=sdpvar(N,N,"symmetric","real");
Q_s=sdpvar(N,N,"symmetric","real");
F_s=sdpvar(N+2,N+2,"symmetric","real");
G_s=((AB')*(kron(Phi,P_s)+kron(Psi_s,Q_s))*AB) + ...
    diag([zeros(1,N),-Esq_s]);
F_s=[[G_s,CD'];[CD,-1]];

% Solve
Objective=[];
Constraints=[F_max<=0, Q_max>=0, F_pl<=0, Q_pl>=0, F_s<=0, Q_s>=0];
Options=sdpsettings("solver","bmibnb");
sol=optimize(Constraints,Objective,Options)
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif

% Sanity checks
check(Constraints)
if ~issymmetric(value(P_max)) || ~isreal(value(P_max))
  error("P_max not real and symmetric");
endif
if ~isdefinite(value(Q_max))
  error("Q_max not positive semi-definite");
endif
if ~isdefinite(-value(F_max))
  error("F_max not negative semi-definite");
endif
if ~issymmetric(value(P_pl)) || ~isreal(value(P_pl))
  error("P_pl not real and symmetric");
endif
if ~isdefinite(value(Q_pl))
  error("Q_pl not positive semi-definite");
endif
if ~isdefinite(value(F_pl))
  error("F_pl not positive semi-definite");
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

% Plot response
nplot=1000;
nap=(fap*nplot/0.5)+1;
nas=(fas*nplot/0.5)+1;
if d==M,
  strs=sprintf("KYP symmetric FIR")
else
  subplot(211);
  strs=sprintf("KYP non-symmetric FIR")
endif
strt=sprintf ...
       ("%s : N=%d,d=%d,fap=%4.2f,fas=%4.2f,Asq\\_pl=%4.2f,Esq\\_s=%6.4f",
        strs,N,d,fap,fas,Asq_pl,Esq_s);

h=value(hsdp);
[H,w]=freqz(h,1,nplot);
[T,w]=grpdelay(h,1,nplot);
f=w*0.5/pi;
ax=plotyy(f(1:nap),20*log10(abs(H(1:nap))), ...
          f(nas:end),20*log10(abs(H(nas:end))));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -3 3]);
axis(ax(2),[0 0.5 -70 -30]);
ylabel(ax(1),"Amplitude(dB)");
grid("on");
title(strt);
if d~=M,
  subplot(212)
  plot(f(1:nap),T(1:nap));
  axis([0 0.5 d-2 d+2]);
  grid("on");
  ylabel("Delay(samples)");
endif
xlabel("Frequency");
print(sprintf("%s_d_%2d_response",strf,d),"-dpdflatex");
close

 % Check amplitude response
[A_max,n_max]=max(abs(H));
printf("max(A)=%11.6g(%6.4f) at f=%6.4f\n",
       A_max,sqrt(Asq_max),f(n_max));

[A_p_min,n_p_min]=min(abs(H(1:nap)));
printf("min(A_p)=%11.6g(%6.4f) at f=%6.4f\n",
       A_p_min,sqrt(Asq_pl),f(n_p_min));

[A_s_max,n_s_max]=max(abs(H(nas:end)));
printf("max(A_s)=%11.6g(%6.4f) at f=%6.4f\n",
       A_s_max,sqrt(Esq_s),f(nas-1+n_s_max));

% Save
print_polynomial(h,"h","%13.10f");
print_polynomial(h,"h",sprintf("%s_h_coef.m",strf),"%13.10f");

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
