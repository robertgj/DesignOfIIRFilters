% yalmip_kyp_dual_continuous_lowpass_test.m
%
% See Wallin et al.:
%  http://www.control.isy.liu.se/research/reports/2003/2503.pdf

% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="yalmip_kyp_dual_continuous_lowpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

tol=1e-8;

% Similar to yalmip_kyp_dual_continuous_test.m
N=3;M=1;p=1;
fc=0.5;
wc=2*pi*fc;
[n,d]=butter(N,2*pi*fc,"s");
n=n*2;
f=0:0.001:1;
w=2*pi*f;
nc=((length(w)-1)*fc/max(f))+1;
Hl=freqs(n,d,w);
max_abs_Asq=max(abs(Hl).^2);
if abs(abs(Hl(nc))-sqrt(2)) > 100*eps
  error("abs(abs(Hl(nc))-sqrt(2))(%g*eps) > 100*eps", ...
        abs(abs(Hl(nc))-sqrt(2))/eps);
endif
Argl=unwrap(arg(Hl));
[A,B,C,D]=tf2ss(n,d);
subplot(211)
plot(f,abs(Hl));
ylabel("Amplitude(dB)");
grid("on");
title("s-plane responses of Abcd")
subplot(212)
plot(f,Argl/pi);
ylabel("arg(H)/\\pi");
grid("on");
xlabel("Frequency (\\omega/2\\pi)")
print(strcat(strf,"_s_response"),"-dpdflatex");
close;

%
% Solve the continuous time KYP
%

P=sdpvar(N,N,"symmetric","real");
Esq=sdpvar(p,1,"full","real");
AB=[A,B;eye(N,N),zeros(N,M)];
CD=sparse([C,D;zeros(M,N),eye(M,M)]);
Phi=[0,1;1,0];
Theta0=sparse((CD')*[[eye(M,M),zeros(M,M)];[zeros(M,M),zeros(M,M)]]*CD);
Thetal=cell(p,1);
for l=1:p,
  Thetal{l}=sparse([zeros(N,N),zeros(N,M);zeros(M,N),-eye(M,M)]);
endfor
Theta=Theta0;
for l=1:p,
  Theta=Theta+(Thetal{l}*Esq(l));
endfor
F=((AB')*kron(Phi,P)*AB)+Theta;
cc=ones(size(Esq));
Objective=[(cc')*Esq];
Constraints=[F<=0,Esq>=0];
Options=sdpsettings("solver","sedumi","sedumi.eps",tol); 
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
value(Objective)
sort(eigs(value(F),N+M)',"descend")

%
% Solve the dual of the continuous time KYP
%
Z11=sdpvar(N,N,"symmetric","real");
Z12=sdpvar(N,M,"full","real");
Z22=sdpvar(M,M,"symmetric","real");
Z=[[Z11,Z12];[Z12',Z22]];
dualF=(A*Z11)+(Z11*(A'))+(B*(Z12'))+(Z12*(B'));
Constraints=[dualF==0,Z>=0];
for l=1:p,
  Constraints=[Constraints,trace(Thetal{l}*Z)==-cc(l)];
endfor
Objective=[-trace(Theta0*Z)];
Options=sdpsettings("solver","sedumi"); 
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
value(Objective)
value(trace(Theta0*Z))
max(max(abs(value(dualF))))
sort(eigs(value(Z),N+M)',"descend")

%
% Solve the Lyapunov equation for Fdual to find the basis matrixes of Z
%
MN=M*N;
kmax=(MN)+(M*(M+1)/2);
Fk=cell(1,kmax);
for k=1:MN
  Ek12=zeros(1,MN);
  Ek12(k)=1;
  Ek12=reshape(Ek12,N,M);
  Ek11=lyap(A,(B*(Ek12'))+(Ek12*(B')));
  Fk{k}=sparse([[Ek11,Ek12];[Ek12',zeros(M,M)]]);
endfor

k=MN;
for r=1:M,
  for s=1:r,
    Ek22=zeros(M,M);
    Ek22(r,s)=1;
    Ek22(s,r)=1;
    k=k+1;
    Fk{k}=sparse([zeros(N,N+M);[zeros(M,N),Ek22]]);
  endfor
endfor

%
% Solve the reduced dual of the continuous-time KYP problem
%
z=sdpvar(1,kmax,"full","real");
ZR=(z(1)*Fk{1});
for l=2:kmax,
  ZR=ZR+(z(l)*Fk{l});
endfor
Constraints=[ZR>=0];
for l=1:p,
  Constraints=[Constraints,-cc(l)<=trace(Thetal{l}*ZR)<=-cc(l)];
endfor
Objective=[-trace(Theta0*ZR)];
Options=sdpsettings("solver","sedumi"); 
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)

value(Objective)
if abs(value(Objective)+max_abs_Asq) > tol
  error("abs(value(Objective)+max_abs_Asq)(%g) > tol", ...
        abs(value(Objective)+max_abs_Asq)/tol);
endif

sort(eigs(value(ZR),N+M)',"descend")
if min(eigs(value(ZR),N+M)) < -tol
  error("min(eigs(value(ZR),N+M))(%g*tol) < -tol", ...
        min(eigs(value(ZR),N+M))/tol);
endif

ZR11=ZR(1:N,1:N);
ZR12=ZR(1:N,N+1);
ZR22=ZR(N+1:N+M,N+1:N+M);
Fadj=value((A*ZR11)+(ZR11*A')+(B*ZR12')+(ZR12*B'));
if max(max(abs(Fadj))) > 1000*eps
  error("max(max(abs(Fadj)))(%g*eps) > 1000*eps", ...
        max(max(abs(Fadj)))/eps);
endif

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
