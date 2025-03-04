% yalmip_kyp_check_iir_bandpass_test.m
% Copyright (C) 2022-2025 Robert G. Jenssen
%
% Use the KYP lemma to check the response of a parallel all-pass one-multiplier
% Schur lattice bandpass filter for which the phase at the phase pass-band lower
% edge is w*tp plus a multiple of pi. This filter can then be used to confirm
% the KYP lemma for the filter in parallel with a tp sample delay.
%
% See:
% "GENERALIZING THE KYP LEMMA TO MULTIPLE FREQUENCY INTERVALS", G. Pipeleers,
% T. Iwasaki and S. Hara, SIAM Journal on Control and Optimization, 2014,
% Vol. 52, No. 6, pp. 3618--3638

test_common;

strf="yalmip_kyp_check_iir_bandpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

fhandle=fopen(strcat(strf,".results"),"w");

use_doubly_pipelined_lattice=false
tol=1e-6
sedumi_eps=1e-8

% Initial parallel all-pass band-pass filter from
% schurOneMPAlattice_socp_slb_bandpass_delay_test.m
A1k = [  -0.4409255007,   0.7705229271,   0.4268047578,  -0.6670269959, ... 
          0.8725396047,  -0.3080364298,  -0.1903027859,   0.7726198927, ... 
         -0.5510021939,   0.3899853389 ];
A1epsilon = [  -1,  -1,   1,   1,  1,   1,   1,   1,  1,  -1 ];
A1p = [   0.9325532744,   0.5808817464,   1.6134995780,   1.0226755432, ... 
          2.2882563404,   0.5970033924,   0.8208146580,   0.9952049007, ... 
          0.3564354820,   0.6624681859 ];
A1c=zeros(1,length(A1k)+1);
A2k = [  -0.8637528214,   0.7436190772,   0.5899685375,  -0.5771662128, ... 
          0.8679058564,  -0.2975731738,  -0.1635674791,   0.7760840128, ... 
         -0.5599422818,   0.3820722205 ];
A2epsilon = [   1,   1,  -1,   1,  1,   1,   1,   1,  1,  -1 ];
A2p = [   0.4350069861,   1.6088910280,   0.6169410624,   1.2148687228, ... 
          2.3462983867,   0.6239467571,   0.8480333200,   1.0002147359, ... 
          0.3551436447,   0.6686571470 ];
A2c=zeros(1,length(A2k)+1);

% Filter specification
fasl=0.05,fapl=0.10,fapu=0.15,fasu=0.20,dBap=0.08,dBas=51
ftpl=fapl,ftpu=fapu,tp=16,tpr=0.16
fppl=fapl,fppu=fapu,pd=3,pdr=0.006
fend=0.5;

% Pass band maximum squared error compared to a delay and stop band maximum
% squared amplitude found by schurOneMPAlattice_socp_slb_bandpass_delay_test.m
max_dB_error_tp_sample_delay=-39.439781;
max_dB_error_stop_band=-50.962861;
Esq_z=(10^(max_dB_error_tp_sample_delay/10))+tol;
Asq_p=(10^(-dBap/10))-tol;
Asq_s=(10^(max_dB_error_stop_band/10))+tol;

% Convert to state-variable form
if use_doubly_pipelined_lattice
  % SeDuMi fails. Problem is too large?!?
  [~,~,~,~,A1,B1,C1,D1]=schurOneMlatticeDoublyPipelined2Abcd(A1k,A1epsilon,A1c);
  [~,~,~,~,A2,B2,C2,D2]=schurOneMlatticeDoublyPipelined2Abcd(A2k,A2epsilon,A2c);
  % Scale frequencies by 1/2
  fasl=fasl/2;fapl=fapl/2;fapu=fapu/2;fasu=fasu/2;
  ftpl=ftpl/2;ftpu=ftpu/2;fppl=fppl/2;fppu=fppu/2;
  fend=fend/2;
  tpPADP=(2*tp)+2;
else
  [A1,B1,~,~,C1,D1]=schurOneMlattice2Abcd(A1k,A1epsilon,A1p,A1c);
  [A2,B2,~,~,C2,D2]=schurOneMlattice2Abcd(A2k,A2epsilon,A2p,A2c);
  tpPADP=tp;
endif

% Frequency vectors
n=1000;
nasl=ceil(n*fasl/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;

% For stop-bands
A=zeros(rows(A1)+rows(A2));
A(1:rows(A1),1:columns(A1))=A1;
A(rows(A1)+(1:rows(A2)),columns(A1)+(1:columns(A2)))=A2;
B=[B1;B2];
C=0.5*[C1,-C2];
D=0.5*(D1-D2);
NA=rows(A);
AB=[A,B;eye(NA),zeros(NA,1)];
CD=[C,D;zeros(1,NA),1];

% Sanity check on stop bands
[nS,dS]=Abcd2tf(A,B,C,D);
[HS,w]=freqz(nS,dS,n);
max_Asq_stop=max([max(abs(HS(1:nasl))),max(abs(HS(nasu:(n-nasu))))]).^2;
if max_Asq_stop > Asq_s
  error("max_Asq_stop > Asq_s")
endif

% Sanity check on pass band minimum
min_Asq_pass=min(abs(HS(napl:napu))).^2;
if min_Asq_pass < Asq_p
  error("min_Asq_pass < Asq_p")
endif

% For pass-band compare with a delay of tpPADP samples
% (Note that pd shows that the filter nominal gain is -1!)
Z=[zeros(1,tpPADP),1];
[A3,B3,C3,D3]=tf2Abcd(Z,1);
AZ=zeros(rows(A)+rows(A3));
AZ(1:rows(A),1:columns(A))=A;
AZ(rows(A)+(1:rows(A3)),columns(A)+(1:columns(A3)))=A3;
BZ=[B;B3];
CZ=[C,C3];
DZ=[D+D3];
NZ=rows(AZ);
ABZ=[AZ,BZ;eye(NZ),zeros(NZ,1)];
CDZ=[CZ,DZ;zeros(1,NZ),1];

% Sanity check on pass band
[nZ,dZ]=Abcd2tf(AZ,BZ,CZ,DZ);
[HZ,w]=freqz(nZ,dZ,n);
max_Esq_pass=max(abs(HZ(napl:napu))).^2;
if max_Esq_pass > Esq_z
  error("max_Esq_pass > Esq_z");
endif

% Common constants
Pi_p=diag([ -1, Asq_p]); % |H(pass_band)|^2 > Asq_p
Pi_z=diag([ 1, -Esq_z]); % |H(pass_band)-e^(-j*w*tpPADP)|^2 < Esq_z
Pi_slu=diag([ 1, -Asq_s]); % |H(stop_bands)|^2 < Asq_s
Phi=[-1,0;0,1];

% Lower stop-band
c_sl=2*cos(2*pi*fasl);
Psi_sl=[0,1;1,-c_sl];
% Pass-band
e_z=e^(j*pi*(fapu+fapl));
c_z=2*cos(pi*(fapu-fapl));
Psi_z=[0,e_z;1/e_z,-c_z];
Psi_p=Psi_z;
% Upper stop-band
e_su=e^(j*pi*(fend+fasu));
c_su=2*cos(pi*(fend-fasu));
Psi_su=[0,e_su;1/e_su,-c_su]; 

% Pass band constraint on the minimum response, |H(w)|^2 > Asq_p
Theta_p=(CD')*Pi_p*CD;
P_p=sdpvar(NA,NA,"symmetric","real");
Q_p=sdpvar(NA,NA,"symmetric","real");
F_p=((AB')*(kron(Phi,P_p)+kron(Psi_p,Q_p))*AB) + Theta_p;

% Pass band constraint on the error, |H(w)-e^(-j*w*tdPADP)|^2 < Esq_z
Theta_z=(CDZ')*Pi_z*CDZ;
P_z=sdpvar(NZ,NZ,"symmetric","real");
Q_z=sdpvar(NZ,NZ,"symmetric","real");
F_z=((ABZ')*(kron(Phi,P_z)+kron(Psi_z,Q_z))*ABZ) + Theta_z;

% SDP constraints on the upper and lower stop bands, |H(w)|^2 < Asq_s
l=2;
n=rows(A);
m=columns(B);
Jl=[eye(l),zeros(l,1);zeros(l,1),eye(l)];
Phir=[0,i;-i,0];
Psir=[0,1;1,0];
Tr=[1,-1;i,i]/sqrt(2);
% Moebius transform of the unit circle to the real axis.
% Select z3 not in the pass or stop bands
z1=e^(-2*pi*i*(fasu+fppu)/2);
z2=e^( 2*pi*i*(fasl+fppl)/2);
z3=e^( 2*pi*i*(fasu+fppu)/2);
lambda=e.^(i*2*pi*[fasu,(2*fend)-(fasu),-fasl,fasl]); %[eta1,zeta1,eta2,zeta2]
alphabeta=((lambda-z1).*(z2-z3))./((lambda-z3).*(z2-z1));
% Sanity checks
if any(~isfinite(alphabeta))
  error("any(~isfinite(alphabeta))");
endif
if any(abs(imag(alphabeta))>100*eps)
  error("any(abs(imag(alphabeta))>100*eps)");
endif
alphabeta=real(alphabeta);
alpha1=alphabeta(1);
alpha2=alphabeta(3);
beta1=alphabeta(2);
beta2=alphabeta(4);
% Sanity checks
if ~((alpha1<beta1) && (beta1<alpha2) && (alpha2<beta2))
  error("~((alpha1<beta1) && (beta1<alpha2) && (alpha2<beta2))");
endif
% Transform the image from the real axis to s in i*[-1,1]
a=[1; -alpha1-alpha2; alpha1*alpha2];
b=[1; -beta1-beta2; beta1*beta2];
TtH=[-a,b].';
PhiH=TtH'*Phir*TtH;
PsiH=TtH'*Psir*TtH;
RH=[-i*PhiH(1,2), -i*PhiH(1,3); i*PhiH(3,1), i*PhiH(3,2)];
% Apply the Moebius transform to (PhiH,PsiH) and force a Hermitian result
M=[z2-z3,-z1*(z2-z3); ...
   z2-z1,-z3*(z2-z1)];
M1=M(1,:);
M2=M(2,:);
Ml=[conv(M1,M1);conv(M1,M2);conv(M2,M2)];

Phi_slu=Ml'*PhiH*Ml;
Phi_slu=triu(Phi_slu,1)+diag(real(diag(Phi_slu)))+triu(Phi_slu,1)';
% Sanity checks on Phi_slu
if max(max(abs(imag(Phi_slu))))>10*eps
  error("max(max(abs(imag(Phi_slu))))>10*eps");
endif
Phi_slu=real(Phi_slu);

Psi_slu=Ml'*PsiH*Ml;
Psi_slu=triu(Psi_slu,1)+diag(real(diag(Psi_slu)))+triu(Psi_slu,1)';
% Sanity checks on Psi_slu
if max(max(abs(imag(Psi_slu))))>20*eps
  error("max(max(abs(imag(Psi_slu))))>20*eps");
endif
Psi_slu=real(Psi_slu);

R_slu=M'*RH*M;
R_slu=triu(R_slu,1)+diag(real(diag(R_slu)))+triu(R_slu,1)';
% Sanity checks on R_slu
if max(max(abs(imag(R_slu))))>eps
  error("max(max(abs(imag(R_slu))))>eps");
endif
R_slu=real(R_slu);

% Sanity check on Phi_slu and R_slu
Phi_slu_altR=Jl'*kron(M'*Phir*M,R_slu)*Jl;
if max(max(abs(Phi_slu_altR-Phi_slu)))>20*eps
  error("max(max(abs(Phi_slu_altR-Phi_slu)))>20*eps");
endif

% Fl and Gl
F2AB=[A*A,A*B,B; ...
      A,B,zeros(size(B)); ...
      eye(size(A)),zeros(size(B)),zeros(size(B))];
F1AB=[A,B; ...
      eye(size(A)),zeros(size(B))];
F10I=[0,1;1,0];
G2AB=(kron(eye(l),[eye(n);zeros(m,n)])*[F1AB,zeros(n*l,m)]) + ...
     (kron(eye(l),[zeros(n,m);eye(m)])*[zeros(m*l,n),F10I]);
% Sanity check on G2AB
G2AB_alt=[A,B,zeros(n,1);zeros(1,n+1),1;eye(n),zeros(n,2);zeros(1,n),1,0];
if max(max(abs(G2AB-G2AB_alt)))~=0
  error("max(max(abs(G2AB-G2AB_alt)))~=0")
endif
F2AB=[A*A,A*B,B; ...
      A,B,zeros(size(B)); ...
      eye(size(A)),zeros(size(B)),zeros(size(B))];
    
% Union of upper and lower stop band constraints
Theta_slu=(CD')*Pi_slu*CD;
P_slu=sdpvar(NA,NA,"symmetric","real");
Q_slu=sdpvar(NA,NA,"symmetric","real");
F_slu=((F2AB')*(kron(Phi_slu,P_slu)+kron(Psi_slu,Q_slu))*F2AB) + ...
      ((G2AB')*kron(R_slu,Theta_slu)*G2AB);

% Check pass band lower amplitude with YALMIP
Constraints=[F_p<=0,Q_p>=0];
Options=sdpsettings('solver','sedumi');
sol=optimize(Constraints,[],Options);
if (sol.problem==0)
elseif (sol.problem==4)
  printf("\nYALMIP numerical problems!\n\n");
  fprintf(fhandle,"\nYALMIP numerical problems!\n\n");
else  
  error("YALMIP problem %s",sol.info);
endif
check(Constraints)

% Check pass band error from delay with YALMIP
Constraints=[F_z<=0,Q_z>=0];
Options=sdpsettings('solver','sedumi');
sol=optimize(Constraints,[],Options);
if (sol.problem==0)
elseif (sol.problem==4)
  printf("\nYALMIP numerical problems!\n\n");
  fprintf(fhandle,"\nYALMIP numerical problems!\n\n");
else  
  error("YALMIP problem %s",sol.info);
endif
check(Constraints)

% Check stop band upper amplitude from delay with YALMIP
Constraints=[F_slu<=-sedumi_eps,Q_slu>=0];
Options=sdpsettings('solver','sedumi','sedumi.eps',sedumi_eps);
sol=optimize(Constraints,[],Options);
if (sol.problem==0)
elseif (sol.problem==4)
  printf("\nYALMIP numerical problems!\n\n");
  fprintf(fhandle,"\nYALMIP numerical problems!\n\n");
else  
  error("YALMIP problem %s",sol.info);
endif
check(Constraints)

% Sanity checks
if ~issymmetric(value(P_p))
  error("P_p not symmetric");
endif
if ~isdefinite(value(Q_p))
  error("Q_p not positive semi-definite");
endif
if ~isdefinite(-value(F_p))
  error("F_p not negative semi-definite");
endif
if ~issymmetric(value(P_z))
  error("P_z not symmetric");
endif
if ~isdefinite(value(Q_z))
  error("Q_z not positive semi-definite");
endif
if ~isdefinite(-value(F_z))
  error("F_z not negative semi-definite");
endif
if ~issymmetric(value(P_slu))
  error("P_slu not symmetric");
endif
if ~issymmetric(value(Q_slu))
  error("Q_slu not symmetric");
endif
if ~isdefinite(value(Q_slu))
  error("Q_slu not positive semi-definite");
endif
if ~isdefinite(-value(F_slu))
  min_eigs_Fslu=min(eigs(-value(F_slu),rows(F_slu)));
  if min_eigs_Fslu < -sedumi_eps
    error("-F_slu not positive semi-definite (Min. eigenvalue=%10.4g)",
          min_eigs_Fslu);
  else
    fprintf(fhandle, ...
            "isdefinite() finds -F_slu<0 but min. eigenvalue >= -sedumi_eps\n");
  endif
endif

% Done
fclose(fhandle);
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
