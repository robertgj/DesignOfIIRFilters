% yalmip_kyp_dual_bandpass_test.m
% Test the reduced complexity dual of the generalised discrete time
% linearised KYP lemma with the amplitude response of a symmetric FIR bandpass
% filter.

% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="yalmip_kyp_dual_bandpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tol=1e-5;
use_theta=false;
fid=fopen(sprintf("%s.results",strf),"wt");

N=26; if rem(N,2), error("Expect N even!");endif; d=(N/2);
fasl=0.05;fapl=0.10;fapu=0.2;fasu=0.25;
nplot=10000;
nasl=ceil(fasl*nplot/0.5)+1;
napl=floor(fapl*nplot/0.5)+1;
napu=ceil(fapu*nplot/0.5)+1;
nasu=floor(fasu*nplot/0.5)+1;

h=remez(N,2*[0,fasl,fapl,fapu,fasu,0.5],[0,0,1,1,0,0],[10,1,20],"bandpass");
h=h(:)';
h_pz=h-[zeros(1,N/2),1,zeros(1,N/2)];
[H,w]=freqz(h,1,nplot);
Asq=abs(H).^2;
Asq_max=max(Asq);
Asq_max_p=max(Asq(napl:napu));
Esq_max_pz=max(abs(abs(H(napl:napu))-1).^2);

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
C=h(end:-1:2);
D=h(1);
CD=[C,D;zeros(1,N),1];
C_pz=h_pz(end:-1:2);
CD_pz=[C_pz,D;zeros(1,N),1];
Phi=[-1,0;0,1];
wc=2*pi*(fapu+fapl)/2;
cwc=cos(wc);
swc=sin(wc);
e_p=e^(j*wc);
wm=2*pi*(fapu-fapl)/2;
cwm=cos(wm);
swm=sin(wm);
c_p=2*cwm;
Psi_p=[0,e_p;conj(e_p),-c_p]; 

% Esq basis
if use_theta
  Theta0=(CD')*[[1,0];[0,-1]]*CD;
  Theta0_pz=(CD_pz')*[[1,0];[0,0]]*CD_pz;
  Theta1=(CD')*[[0,0];[0,-1]]*CD;
else
  Theta0=[[zeros(N,N+1),C'];[zeros(1,N),-1,D'];[C,D,-1]];
  Theta0_pz=([[zeros(N,N+1),C_pz'];[zeros(1,N),0,D'];[C_pz,D,-1]]);
  Theta1=[[zeros(N,N+2)];[zeros(2,N),[-1,0;0,0]]];
endif

%
% Check KYP lemma response for maximum pass-band response
%
printf("\nChecking KYP lemma:\n");

% Check KYP lemma response for maximum pass-band response
Esq_p=sdpvar(1,1,"full","real");
P_p=sdpvar(N,N,"symmetric","real");
Q_p=sdpvar(N,N,"symmetric","real");
if use_theta
  F_p=(AB')*[kron(Phi,P_p)+kron(Psi_p,Q_p)]*AB + Theta0 + (Esq_p*Theta1);
else
  % Linearised KYP lemma
  F_p=[[((AB')*(kron(Phi,P_p)+kron(Psi_p,Q_p))*AB),zeros(N+1,1)]; ...
       [zeros(1,N+2)]] + Theta0 + (Esq_p*Theta1);
endif
Objective=[Esq_p];
Constraints=[F_p<=0,Q_p>=0,Esq_p>=0];
Options=sdpsettings("solver","sedumi","sedumi.eps",tol);
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
if abs(1+value(Esq_p)-Asq_max_p) > 2*tol
  error("abs(1+value(Esq_p)-Asq_max_p)(%g*tol) > 2*tol", ...
        abs(1+value(Esq_p)-Asq_max_p)/tol);
endif
printf("\nvalue(Esq_p)=%g,Asq_max_p=%g\n\n",value(Esq_p),Asq_max_p);
fprintf(fid,"\nvalue(Esq_p)=%g,Asq_max_p=%g\n\n",value(Esq_p),Asq_max_p);

% Check KYP lemma response for pass-band response error
Esq_pz=sdpvar(1,1,"full","real");
P_pz=sdpvar(N,N,"symmetric","real");
Q_pz=sdpvar(N,N,"symmetric","real");
if use_theta
   F_pz=(AB')*[kron(Phi,P_pz)+kron(Psi_p,Q_pz)]*AB + Theta0_pz + (Esq_pz*Theta1);
else
  % Linearised KYP lemma
  F_pz=[[((AB')*(kron(Phi,P_pz)+kron(Psi_p,Q_pz))*AB),zeros(N+1,1)]; ...
       [zeros(1,N+2)]] + Theta0_pz + (Esq_pz*Theta1);
endif
Objective=[Esq_pz];
Constraints=[F_pz<=0,Q_pz>=0,Esq_pz>=0];
Options=sdpsettings("solver","sedumi","sedumi.eps",tol);
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
if (value(Esq_pz)-Esq_max_pz) > tol
  error("(value(Esq_pz)-Esq_max_pz)(%g*tol) > tol", ...
        (value(Esq_pz)-Esq_max_pz)/tol);
endif
printf("\nvalue(Esq_pz)=%g,Esq_max_pz=%g\n\n",value(Esq_pz),Esq_max_pz);
fprintf(fid,"\nvalue(Esq_pz)=%g,Esq_max_pz=%g\n\n",value(Esq_pz),Esq_max_pz);

%
% Check dual of KYP lemma
%
printf("\nChecking dual of KYP lemma:\n");

Z=sdpvar(rows(Theta0),columns(Theta0),"symmetric","real");
Z11=Z(1:N,1:N);
Z12=Z(1:N,N+1);
Z22=Z(N+1,N+1);

Padj=(A*Z11*(A'))-Z11+(B*(Z12')*(A'))+(A*Z12*(B'))+(B*Z22*(B'));
if 1
  Qadj_real=(cwc*((Z11*(A'))+(A*(Z11'))+(B*(Z12'))+(Z12*(B'))) ...
             -(2*cwm*Z11));
  Qadj_imag=(swc*((Z11*(A'))-(A*(Z11'))-(B*(Z12'))+(Z12*(B'))));
  Qadj_constraints=[Qadj_real==0,Qadj_imag==0];
else
  Qadj_complex=(e_p*Z11*(A'))+(conj(e_p)*A*Z11)-(c_p*Z11) + ...
               (conj(e_p)*B*(Z12'))+(e_p*Z12*(B'));
  Qadj_constraints=[Qadj_complex==0];
endif

%
% Pass-band maximum response
%
Constraints=[Z>=0,Qadj_constraints,Padj==0,trace(Theta1*Z)==-1];
Objective=[-trace(Theta0*Z)];
Options=sdpsettings("solver","sedumi");
sol=optimize(Constraints,Objective,Options);
if sol.problem
  warning("YALMIP failed for dual of KYP lemma : %s",sol.info);
  fprintf(fid,"YALMIP failed for pass-band maximum response : %s\n",sol.info);
else
  kyp_Asq_p=1-value(Objective);
  printf("Pass-band maximum response = %g, (Asq_max_p=%g)\n\n", ...
         kyp_Asq_p,Asq_max_p);
  fprintf(fid,"Pass-band maximum response = %g, (Asq_max_p=%g)\n\n", ...
          kyp_Asq_p,Asq_max_p);
  % Sanity checks
  if abs(kyp_Asq_max-Asq_max) > tol
    error("abs(kyp_Asq_max-Asq_max)(%g*tol) > tol", ...
          abs(kyp_Asq_max-Asq_max)/tol);
  endif
  if max(max(abs(value(Padj)))) > tol/1e4
    error("max(max(abs(value(Padj))))(%g*tol) > tol/1e4", ...
          max(max(abs(value(Padj))))/tol);
  endif
endif

%
% Check reduced dual of KYP lemma response 
%
if use_theta
  error("Reduced dual of KYP lemma expects use_theta==false!");
endif

printf("\nChecking reduced dual of KYP lemma:\n");

% Find a basis for Z 
Fk=cell(1,N+2+N+2);
for k=1:N
  Ek12=zeros(N,1);
  Ek12(k)=1;
  Ek11=dlyap(A,(B*(Ek12')*(A'))+(A*Ek12*(B')));
  Fk{k}=sparse([[Ek11,Ek12,zeros(N,1)];[Ek12',0,0];[zeros(1,N+2)]]);
endfor
Ek11=dlyap(A,(B*(B')));
Fk{N+1}=sparse([[Ek11,zeros(N,2)];[zeros(2,N+2)]]);
Fk{N+2}=sparse([[zeros(N,N+2)];[zeros(2,N),[1,0;0,0]]]);
for k=1:(N+2)
  Ek13=zeros(N+2);
  Ek13(N+2,k)=1;
  Ek13(k,N+2)=1;
  Fk{N+2+k}=sparse(Ek13);
endfor

z=sdpvar(1,length(Fk),"full","real");
ZR=zeros(size(Theta0));
for l=1:length(z),
  ZR=ZR+(z(l)*Fk{l});
endfor
ZR11=ZR(1:N,1:N);
ZR12=ZR(1:N,N+1);
ZR22=ZR(N+1,N+1);

Padj=(A*ZR11*(A'))-ZR11+(B*(ZR12')*(A'))+(A*ZR12*(B'))+(B*ZR22*(B'));
if 1
  Qadj_real=(cwc*((ZR11*(A'))+(A*(ZR11'))+(B*(ZR12'))+(ZR12*(B'))) ...
             -(2*cwm*ZR11));
  Qadj_imag=(swc*((ZR11*(A'))-(A*ZR11)-(B*(ZR12'))+(ZR12*(B'))));
  Qadj_constraints=[Qadj_real==0,Qadj_imag==0];
else
  Qadj_complex=(e_p*ZR11*(A'))+(conj(e_p)*A*ZR11)-(c_p*ZR11) + ...
       (conj(e_p)*B*(ZR12'))+(e_p*ZR12*(B'));
  Qadj_constraints=[Qadj_complex==0];
endif

%
% Pass-band maximum response error
%
Constraints=[ZR>=0,Qadj_real==0,Padj==0,trace(Theta1*ZR)==-1];
Objective=[-trace(Theta0_pz*ZR)];
Options=sdpsettings("solver","sedumi");
sol=optimize(Constraints,Objective,Options);
if sol.problem
  warning("YALMIP failed : %s",sol.info);
  fprintf(fid,"YALMIP failed for pass-band maximum response error : %s\n",sol.info);
else
  printf("z=[");printf(" %g ",value(z));printf(" ]\n");
  kyp_Esq_pz=1-value(Objective);
  printf("Pass-band maximum response error = %g, (Esq_max_pz=%g)\n\n", ...
         kyp_Esq_pz,Esq_max_pz);
  fprintf(fid,"Pass-band maximum response error = %g, (Esq_max_pz=%g)\n\n", ...
          kyp_Esq_pz,Esq_max_pz);
endif

%
% Done
%
fclose(fid);
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
