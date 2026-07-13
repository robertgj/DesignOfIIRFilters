% yalmip_kyp_dual_continuous_reduced_test.m
%
% See Wallin et al.:
%  http://www.control.isy.liu.se/research/reports/2003/2503.pdf

% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="yalmip_kyp_dual_continuous_reduced_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

tol=1e-8;

% Similar to yalmip_kyp_dual_continuous_test.m
n=3;m=1;p=1;
fc=0.5;
wc=2*pi*fc;
[N,D]=butter(n,2*pi*fc,"s");
N=N*2;
f=0:0.001:1;
w=2*pi*f;
nc=((length(w)-1)*fc/max(f))+1;
Hl=freqs(N,D,w);
max_abs_Asq=max(abs(Hl).^2);
if abs(abs(Hl(nc))-sqrt(2)) > 100*eps
  error("abs(abs(Hl(nc))-sqrt(2))(%g*eps) > 100*eps", ...
        abs(abs(Hl(nc))-sqrt(2))/eps);
endif
Argl=unwrap(arg(Hl));
[a,b,c,d]=tf2ss(N,D);
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

P=sdpvar(n,n,"symmetric","real");
Esq=sdpvar(p,1,"full","real");
ab=[a,b;eye(n,n),zeros(n,m)];
cd=sparse([c,d;zeros(m,n),eye(m,m)]);
Phi=[0,1;1,0];
M0=sparse((cd')*[[eye(m,m),zeros(m,m)];[zeros(m,m),zeros(m,m)]]*cd);
Ml=cell(p,1);
for l=1:p,
  Ml{l}=sparse([zeros(n,n),zeros(n,m);zeros(m,n),-eye(m,m)]);
endfor
M=M0;
for l=1:p,
  M=M+(Ml{l}*Esq(l));
endfor
F=((ab')*kron(Phi,P)*ab)+M;
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
sort(eigs(value(F),n+m)',"descend")

%
% Solve the dual of the continuous time KYP
%
Z11=sdpvar(n,n,"symmetric","real");
Z12=sdpvar(n,m,"full","real");
Z22=sdpvar(m,m,"symmetric","real");
Z=[[Z11,Z12];[Z12',Z22]];
dualF=(a*Z11)+(Z11*(a'))+(b*(Z12'))+(Z12*(b'));
Constraints=[0<=dualF<=0,Z>=0];
for l=1:p,
  Constraints=[Constraints,-cc(l)<=trace(Ml{l}*Z)<=-cc(l)];
endfor
Objective=[-trace(M0*Z)];
Options=sdpsettings("solver","sedumi"); 
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
value(Objective)
value(trace(M0*Z))
max(max(abs(value(dualF))))
sort(eigs(value(Z),n+m)',"descend")

%
% Solve the Lyapunov equation for Fdual to find the basis matrixes of Z
%
mn=m*n;
kmax=(mn)+(m*(m+1)/2);
Fk=cell(1,kmax);
for k=1:mn
  Ek12=zeros(1,mn);
  Ek12(k)=1;
  Ek12=reshape(Ek12,n,m);
  Ek11=lyap(a,(b*(Ek12'))+(Ek12*(b')));
  Fk{k}=sparse([[Ek11,Ek12];[Ek12',zeros(m,m)]]);
endfor

k=mn;
for r=1:m,
  for s=1:r,
    Ek22=zeros(m,m);
    Ek22(r,s)=1;
    Ek22(s,r)=1;
    k=k+1;
    Fk{k}=sparse([zeros(n,n+m);[zeros(m,n),Ek22]]);
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
  Constraints=[Constraints,-cc(l)<=trace(Ml{l}*ZR)<=-cc(l)];
endfor
Objective=[-trace(M0*ZR)];
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

sort(eigs(value(ZR),n+m)',"descend")
if min(eigs(value(ZR),n+m)) < -tol
  error("min(eigs(value(ZR),n+m))(%g*tol) < -tol", ...
        min(eigs(value(ZR),n+m))/tol);
endif

ZR11=ZR(1:n,1:n);
ZR12=ZR(1:n,n+1);
ZR22=ZR(n+1:n+m,n+1:n+m);
Fadj=value((a*ZR11)+(ZR11*a')+(b*ZR12')+(ZR12*b'));
if max(max(abs(Fadj))) > 1000*eps
  error("max(max(abs(Fadj)))(%g*eps) > 1000*eps",
        max(max(abs(Fadj)))/eps);
endif

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
