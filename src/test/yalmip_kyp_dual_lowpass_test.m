% yalmip_kyp_dual_lowpass_test.m
%
% SDP design of a direct-form FIR lowpass filter with the reduced
% complexity dual of the generalised discrete-time KYP lemma.
% See :
%   [1] Section VII.B.2, pp. 53-55 of "Generalised KYP Lemma: Unified
%       Frequency Domain Inequalities With Design Applications",
%       T. Iwasaki and S. Hara, IEEE Transactions on Automatic Control,
%       Vol. 50, No. 1, January 2005, pp. 41–59
%   [2] Wallin et al. at:
%       http://www.control.isy.liu.se/research/reports/2003/2503.pdf

% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="yalmip_kyp_dual_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

M=15;N=2*M;d=M;
fap=0.15;fas=0.2;
nplot=10000;
nap=ceil(fap*nplot/0.5)+1;
nas=floor(fas*nplot/0.5)+1;

h=remez(N,2*[0,fap,fas,0.5],[1,1,0,0],[1,10]);
h=h(:)';
[H,w]=freqz(h,1,nplot);
Asq=abs(H).^2;
Asq_max=max(Asq);
Esq_max=max(Asq)-1;
Esq_max_pass=max(Asq(1:nap))-1;
Esq_pass=max(abs(H(1:nap)-e.^(-j*w(1:nap)*d)).^2);
Asq_max_trans=max(Asq((nap+1):(nas-1)));
Asq_max_stop=max(Asq(nas:end));

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
C=h(end:-1:2);
D=h(1);
C_pz=C-[zeros(1,N-d),1,zeros(1,d-1)];
Phi=[-1,0;0,1]; 
c_pass=2*cos(2*pi*fap);
Psi_pass=[0,1;1,-c_pass];
e_trans=e^(j*pi*(fap+fas));
c_trans=2*cos(pi*(fap-fas));
Psi_trans=[0,e_trans;conj(e_trans),-c_trans]; 
c_stop=2*cos(2*pi*fas);
Psi_stop=[0,-1;-1,c_stop];

% Esq basis
Theta0=sparse([[zeros(N,N+1),C'];[zeros(1,N),-1,D'];[C,D,-1]]);
Theta1=sparse([[zeros(N,N+2)];[zeros(2,N),[-1,0;0,0]]]);
Theta0_pass=sparse([[zeros(N,N+1),C_pz'];[zeros(1,N),0,D'];[C_pz,D,-1]]);
Theta0_stop=sparse([[zeros(N,N+1),C'];[zeros(1,N),0,D'];[C,D,-1]]);

%
% Find a basis for Z 
%
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

%
% Overall maximum response
%
printf("\nOverall maximum response:\n")
z_max=sdpvar(1,length(Fk),"full","real");
ZR_max=zeros(N+2);
for l=1:length(Fk),
  ZR_max=ZR_max+(z_max(l)*Fk{l});
endfor
ZR_max11=ZR_max(1:N,1:N);
ZR_max12=ZR_max(1:N,N+1);
ZR_max22=ZR_max(N+1,N+1);
Padj_max=(A*ZR_max11*(A'))-ZR_max11+ ...
         (B*(ZR_max12')*(A'))+(A*ZR_max12*(B'))+(B*ZR_max22*(B'));
Constraints=[ZR_max>=0,Padj_max==0,trace(Theta1*ZR_max)==-1];
Objective=[-trace(Theta0*ZR_max)];
Options=sdpsettings("solver","sedumi");
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
check(Constraints);
printf("z_max=[");printf(" %g ",value(z_max));printf(" ]\n");
printf("\n");
kyp_Esq_max=-value(Objective);
printf("Overall KYP maximum response = %g, (Esq_max=%g)\n\n", ...
       kyp_Esq_max,Esq_max);

%
% Pass-band maximum response
%
printf("\nPass-band maximum response:\n")
z_max_pass=sdpvar(1,length(Fk),"full","real");
ZR_max_pass=zeros(N+2);
for l=1:length(Fk),
  ZR_max_pass=ZR_max_pass+(z_max_pass(l)*Fk{l});
endfor
ZR_max_pass11=ZR_max_pass(1:N,1:N);
ZR_max_pass12=ZR_max_pass(1:N,N+1);
ZR_max_pass22=ZR_max_pass(N+1,N+1);
Padj_max_pass=(A*ZR_max_pass11*(A'))-ZR_max_pass11+ ...
              (B*(ZR_max_pass12')*(A'))+(A*ZR_max_pass12*(B'))+ ...
              (B*ZR_max_pass22*(B'));
Qadj_max_pass=ZR_max_pass11*(A') + A*ZR_max_pass11 - ...
              c_pass*ZR_max_pass11 + ...
              B*(ZR_max_pass12') + ZR_max_pass12*(B');
Constraints=[ZR_max_pass>=0,Qadj_max_pass==0,Padj_max_pass==0, ...
             trace(Theta1*ZR_max_pass)==-1];
Objective=[-trace(Theta0*ZR_max_pass)];
Options=sdpsettings("solver","sedumi");
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
check(Constraints);
printf("z_max_pass=[");printf(" %g ",value(z_max_pass));printf(" ]\n");
printf("\n");
kyp_Esq_max_pass=value(Objective);
printf("Pass-band KYP maximum response = %g, (Esq_max_pass=%g)\n\n", ...
       kyp_Esq_max_pass,Esq_max_pass);

%
% Pass-band maximum response error
%
printf("\nPass-band maximum response error:\n")
z_pass=sdpvar(1,length(Fk),"full","real");
ZR_pass=zeros(N+2);
for l=1:length(Fk),
  ZR_pass=ZR_pass+(z_pass(l)*Fk{l});
endfor
ZR_pass11=ZR_pass(1:N,1:N);
ZR_pass12=ZR_pass(1:N,N+1);
ZR_pass22=ZR_pass(N+1,N+1);
Padj_pass=(A*ZR_pass11*(A'))-ZR_pass11+ ...
          (B*(ZR_pass12')*(A'))+(A*ZR_pass12*(B'))+ ...
          (B*ZR_pass22*(B'));
Qadj_pass=ZR_pass11*(A') + A*ZR_pass11 - ...
          c_pass*ZR_pass11 + ...
          B*(ZR_pass12') + ZR_pass12*(B');
Constraints=[ZR_pass>=0,Qadj_pass==0,Padj_pass==0,trace(Theta1*ZR_pass)==-1];
Objective=[-trace(Theta0_pass*ZR_pass)];
Options=sdpsettings("solver","sedumi");
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
check(Constraints);
printf("z_pass=[");printf(" %g ",value(z_pass));printf(" ]\n");
printf("\n");
kyp_Esq_pass=-value(Objective);
printf("Pass-band KYP maximum response error = %g, (Esq_pass=%g)\n\n", ...
       kyp_Esq_pass,Esq_pass);

%
% Transition-band maximum response
%
printf("\nTransition-band maximum response:\n")
z_max_trans=sdpvar(1,length(Fk),"full","real");
ZR_max_trans=zeros(N+2);
for l=1:length(Fk),
  ZR_max_trans=ZR_max_trans+(z_max_trans(l)*Fk{l});
endfor
ZR_max_trans11=ZR_max_trans(1:N,1:N);
ZR_max_trans12=ZR_max_trans(1:N,N+1);
ZR_max_trans22=ZR_max_trans(N+1,N+1);
Padj_max_trans=(A*ZR_max_trans11*(A'))-ZR_max_trans11+ ...
               (B*(ZR_max_trans12')*(A'))+(A*ZR_max_trans12*(B'))+ ...
               (B*ZR_max_trans22*(B'));
Qadj_max_trans=(e_trans*ZR_max_trans11*(A')) + ...
               (conj(e_trans)*A*ZR_max_trans11) - ...
               (c_trans*ZR_max_trans11) + ...
               (conj(e_trans)*B*(ZR_max_trans12')) + ...
               (e_trans*ZR_max_trans12*(B'));
Constraints=[ZR_max_trans>=0,Qadj_max_trans==0,Padj_max_trans==0, ...
             trace(Theta1*ZR_max_trans)==-1];
Objective=[-trace(Theta0*ZR_max_trans)];
Options=sdpsettings("solver","sedumi");
sol=optimize(Constraints,Objective,Options);
if sol.problem
  warning("YALMIP failed : %s",sol.info);
else
  check(Constraints);
  printf("z_max_trans=[");printf(" %g ",value(z_max_trans));printf(" ]\n");
  printf("\n");
  kyp_Asq_max_trans=value(Objective);
  printf("Transition-band KYP maximum response = %g, (Asq_max_trans=%g)\n\n", ...
         kyp_Asq_max_trans,Asq_max_trans);
endif

%
% Stop-band maximum response
%
printf("\nStop-band maximum response:\n")
z_stop=sdpvar(1,length(Fk),"full","real");
ZR_stop=zeros(N+2);
for l=1:length(Fk),
  ZR_stop=ZR_stop+(z_stop(l)*Fk{l});
endfor
ZR_stop11=ZR_stop(1:N,1:N);
ZR_stop12=ZR_stop(1:N,N+1);
ZR_stop22=ZR_stop(N+1,N+1);
Padj_stop=(A*ZR_stop11*(A'))-ZR_stop11+ ...
          (B*(ZR_stop12')*(A'))+(A*ZR_stop12*(B'))+ ...
          (B*ZR_stop22*(B'));
Qadj_stop=-ZR_stop11*(A') -A*ZR_stop11 +c_stop*ZR_stop11 ...
          -B*(ZR_stop12') -ZR_stop12*(B');
Constraints=[ZR_stop>=0,Qadj_stop==0,Padj_stop==0,trace(Theta1*ZR_stop)==-1];
Objective=[-trace(Theta0_stop*ZR_stop)];
Options=sdpsettings("solver","sedumi");
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
check(Constraints);
printf("z_stop=[");printf(" %g ",value(z_stop));printf(" ]\n");
printf("\n");
kyp_Asq_stop=-value(Objective);
printf("Stop-band KYP maximum response = %g, (Asq_max_stop=%g)\n\n", ...
       kyp_Asq_stop,Asq_max_stop);

%
% Combine overall, pass-band error and stop-band maximum responses
%
printf("\nCombined pass-band, pass-band error and stop-band maximum response:\n")
Constraints=[ZR_max>=0, Padj_max==0,              trace(Theta1*ZR_max)==-1, ...
             ZR_pass>=0,Qadj_pass==0,Padj_pass==0,trace(Theta1*ZR_pass)==-1, ...
             ZR_stop>=0,Qadj_stop==0,Padj_stop==0,trace(Theta1*ZR_stop)==-1];
Objective=[-trace((Theta0*ZR_max)+(Theta0_pass*ZR_pass)+(Theta0_stop*ZR_stop))];
Options=sdpsettings("solver","sedumi");
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
check(Constraints);
printf("z_max=[");printf(" %g ",value(z_max));printf(" ]\n");
printf("z_pass=[");printf(" %g ",value(z_pass));printf(" ]\n");
printf("z_stop=[");printf(" %g ",value(z_stop));printf(" ]\n");
printf("\n");
kyp_objective=-value(Objective);
kyp_Esq_max=trace(Theta0*value(ZR_max));
kyp_Esq_pass=trace(Theta0_pass*value(ZR_pass));
kyp_Asq_stop=trace(Theta0_stop*value(ZR_stop));
printf("Overall KYP maximum response = %g, (Esq_max=%g)\n\n", ...
       kyp_Esq_max,Esq_max);
printf("Pass-band KYP maximum error response = %g, (Esq_pass=%g)\n\n", ...
       kyp_Esq_pass,Esq_pass);
printf("Stop-band KYP maximum response = %g, (Asq_max_stop=%g)\n\n", ...
       kyp_Asq_stop,Asq_max_stop);


% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
