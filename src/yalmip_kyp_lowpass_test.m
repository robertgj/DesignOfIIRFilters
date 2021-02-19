% yalmip_kyp_lowpass_test.m
% Copyright (C) 2021 Robert G. Jenssen

test_common;

delete("yalmip_kyp_lowpass_test.diary");
delete("yalmip_kyp_lowpass_test.diary.tmp");
diary yalmip_kyp_lowpass_test.diary.tmp

pkg load symbolic optim

tic;

strf="yalmip_kyp_lowpass_test";

% Low-pass filter specification
N=30;d=10;fap=0.1;Wap=1;Wat=0.0001;fas=0.2;Was=1000;

% Common constants
nplot=1000;
nap=(fap*nplot/0.5)+1;
nas=(fas*nplot/0.5)+1;
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
[~,~,G,g]=directFIRnonsymmetricEsqPW ...
            (zeros(N+1,1),[0,fap,fas,0.5]*2*pi,[1,0,0],[d,0,0],[Wap,Wat,Was]);
L=chol(G)';
l=(g*inv(L'));

del=1e-2;
Esq_max=(1+del)^2;
Esq_pu=(1+del)^2;
Esq_t=(1+del)^2;
Esq_s=(del/5)^2;
c_p=2*cos(2*pi*fap);
c_s=2*cos(2*pi*fas);
e_c=e^(j*pi*(fap+fas));
c_h=2*cos(j*pi*(fap-fas));

% Filter impulse response variables
C=sdpvar(1,N);
D=sdpvar(1,1);

% Constraint on maximum amplitude
P_max=sdpvar(N,N,"symmetric");
Q_max=sdpvar(N,N,"symmetric");
F_max=sdpvar(N+2,N+2,"symmetric");
G_max=((AB')*[-P_max,Q_max;Q_max,P_max+(2*Q_max)]*AB)+ ...
     [zeros(N,N+1);[zeros(1,N),-Esq_max]];
F_max=[[G_max,[C,D]'];[[C,D],-1]];

% Constraint on maximum pass band amplitude
P_pu=sdpvar(N,N,"symmetric");
Q_pu=sdpvar(N,N,"symmetric");
F_pu=sdpvar(N+2,N+2,"symmetric");
G_pu=((AB')*[-P_pu,Q_pu;Q_pu,P_pu-(c_p*Q_pu)]*AB)+ ...
     [zeros(N,N+1);[zeros(1,N),-Esq_pu]];
F_pu=[[G_pu,[C,D]'];[[C,D],-1]];

% Constraint on maximum transition band amplitude
P_t=sdpvar(N,N,"symmetric");
Q_t=sdpvar(N,N,"symmetric");
F_t=sdpvar(N+2,N+2,"hermitian","complex");
G_t=((AB')*[-P_t,Q_t/e_c;e_c*Q_t,P_t-(c_h*Q_t)]*AB)+ ...
     [zeros(N,N+1);[zeros(1,N),-Esq_t]];
F_t=[[G_t,[C,D]'];[[C,D],-1]];

% Constraint on maximum stop band amplitude
P_s=sdpvar(N,N,'symmetric');
Q_s=sdpvar(N,N,'symmetric');
F_s=sdpvar(N+2,N+2,'symmetric');
G_s=((AB')*[-P_s,-Q_s;-Q_s,P_s+(c_s*Q_s)]*AB)+ ...
    [zeros(N,N+1);[zeros(1,N),-Esq_s]];
F_s=[[G_s,[C,D]'];[[C,D],-1]];

% Solve
Constraints=[F_max<=0,Q_max>=0,F_pu<=0,Q_pu>=0,F_t<=0,Q_t>=0,F_s<=0,Q_s>=0];
Objective=norm((fliplr([C,D])*L)+l);
Options=sdpsettings('solver','sedumi');
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
if ~isdefinite(value(Q_max))
  error("Q_max not positive semi-definite");
endif
if ~isdefinite(-value(F_max))
  error("F_max not negative semi-definite");
endif
if ~isdefinite(value(Q_pu))
  error("Q_pu not positive semi-definite");
endif
if ~isdefinite(-value(F_pu))
  error("F_pu not negative semi-definite");
endif
if ~isdefinite(value(Q_t))
  error("Q_t not positive semi-definite");
endif
if ~isdefinite(-value(F_t))
  error("F_t not negative semi-definite");
endif
if ~isdefinite(value(Q_s))
  error("Q_s not positive semi-definite");
endif
if ~isdefinite(-value(F_s))
  error("F_s not negative semi-definite");
endif
% Plot ha response
h=value(fliplr([C,D]));
[H,w]=freqz(h,1,nplot);
[T,w]=grpdelay(h,1,nplot);
subplot(211)
ax=plotyy(w(1:nap)*0.5/pi,abs(H(1:nap)), ...
          w(nas:end)*0.5/pi,abs(H(nas:end)));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 1-del 1+del]);
axis(ax(2),[0 0.5 0 sqrt(Esq_s)]);
ylabel(ax(1),"Amplitude");
grid("on");
strt=sprintf("KYP non-symmetric FIR low pass filter : N=%d,d=%d,fap=%g,fas=%g",
             N,d,fap,fas);
title(strt);
subplot(212)
plot(w(1:nap)*0.5/pi,T(1:nap));
axis([0 0.5 9.8 10.8]);
grid("on");
ylabel("Delay(samples)");
xlabel("Frequency");
print(strcat(strf,"_h_response"),"-dpdflatex");
close

% Save
print_polynomial(h,"h","%13.10f");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"),"%13.10f");

% Done
diary off
movefile yalmip_kyp_lowpass_test.diary.tmp yalmip_kyp_lowpass_test.diary;
