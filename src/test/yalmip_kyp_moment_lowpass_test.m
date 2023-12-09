% yalmip_kyp_moment_lowpass_test.m
% Copyright (C) 2022-2023 Robert G. Jenssen
%
% Design of a direct-form symmetric FIR lowpass filter with the KYP lemma.
%
% See Section VII.B.2, pp. 53-55 of "Generalised KYP Lemma: Unified
% Frequency Domain Inequalities With Design Applications", T. Iwasaki
% and S. Hara, IEEE Transactions on Automatic Control, Vol. 50, No. 1,
% January 2005, pp. 41–59
%
% The frequency constraint Pi=[-1,0;0,Asq_pl] gives |H(passband)|^2>=Asq_pl
% and adds a quadratic constraint on the minimum pass-band amplitude
% requiring the use of the YALMIP moment solver.
%
% This script requires a LOT of memory and CPU time to solve for M=3!! Over
% 90% of CPU time is spent in the SeDuMi blkchol.c mex file.

test_common;

strf="yalmip_kyp_moment_lowpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

pkg load signal optim

% Low-pass filter specification
sedumi_eps=1e-6;
M=3;N=2*M;d=M;
fap=0.10;fas=0.25;
Asq_max=1;
Asq_pl=0.5;
Esq_s=0.0225;
Wap=1;Wat=1;Was=1;
[~,~,G,g]= directFIRsymmetricEsqPW ...
             (zeros(N+1,1),[0,fap,fas,0.5]*2*pi,[1,0,0],[Wap,Wat,Was]);

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];

% Filter impulse response SDP variables
CM1=sdpvar(1,M+1);
CD=[CM1,CM1(M:-1:1)];
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
G_max=((AB')*(kron(Phi,P_max)+kron(Psi_max,Q_max))*AB) + ...
      diag([zeros(1,N),-Asq_max]);
F_max=[[G_max,CD'];[CD,-1]];

% Constraint on minimum pass band amplitude
P_pl=sdpvar(N,N,"symmetric","real");
Q_pl=sdpvar(N,N,"symmetric","real");
Theta_pl=[CD',[zeros(N,1);1]]*[[-1,0];[0,Asq_pl]]*[CD;[zeros(1,N),1]];
F_pl=((AB')*(kron(Phi,P_pl)+kron(Psi_p,Q_pl))*AB)+Theta_pl;

% Constraint on maximum stop band amplitude
P_s=sdpvar(N,N,"symmetric","real");
Q_s=sdpvar(N,N,"symmetric","real");
G_s=((AB')*(kron(Phi,P_s)+kron(Psi_s,Q_s))*AB) + ...
    diag([zeros(1,N),-Esq_s]);
F_s=[[G_s,CD'];[CD,-1]];

% Solve
Constraints=[F_max<=-sedumi_eps, Q_max>=0, F_pl<=0, Q_pl>=0, F_s<=0, Q_s>=0];
Objective=(hsdp*G*hsdp')+(2*hsdp*g')+(2*fap);
Options=sdpsettings("solver","moment","sedumi.eps",sedumi_eps);
profile("on");
try
  sol=optimize(Constraints,Objective,Options);
catch
  fprintf(stderr,lasterror().message);
end_try_catch
profile("off");
T=profile("info");
profshow(T);

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
if ~isdefinite(-value(F_pl))
  eigs_F_pl=eigs(-value(F_pl));
  if max(abs(imag(eigs_F_pl))) > eps
    error("max(abs(imag(eigs(-value(F_pl))))) > eps");
  endif
  if min(real(eigs_F_pl)) < -sedumi_eps
    warning("\n min(real(eigs(-value(F_pl))))(%g) < -sedumi_eps(%g)\n\n",
            min(real(eigs_F_pl)),sedumi_eps);
  endif
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

h=value(hsdp);
[H,w]=freqz(h,1,nplot);
[T,w]=delayz(h,1,nplot);
f=w*0.5/pi;

if d~=M,
  subplot(211);
  strs=sprintf("KYP non-symmetric FIR");
else
  strs=sprintf("KYP symmetric FIR");
endif
strt=sprintf("%s : N=%d,d=%d,fap=%4.2f,fas=%4.2f,Asq\\_pl=%4.2f,Esq\\_s=%6.4f",
             strs,N,d,fap,fas,Asq_pl,Esq_s);

ax=plotyy(f(1:nap),20*log10(abs(H(1:nap))), ...
          f(nas:end),20*log10(abs(H(nas:end))));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 -4 0]);
axis(ax(2),[0 0.5 -40 0]);
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
print(sprintf("%s_d_%02d_response",strf,d),"-dpdflatex");
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
eval(sprintf("save %s.mat \
h sedumi_eps fap fas M N d g G Asq_max Asq_pl Esq_s Wap Wat Was",strf));

% Done
toc
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
