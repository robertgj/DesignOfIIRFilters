% directFIRnonsymmetric_kyp_union_bandpass_test.m
% Copyright (C) 2021-2022 Robert G. Jenssen
%
% SDP design of a direct-form FIR bandpass filter with the KYP
% lemma. The pass band response is set to e^{-j*w*d}. The stop band
% response is specified as the union of the upper and lower stop bands.
%
% See:
% "GENERALIZING THE KYP LEMMA TO MULTIPLE FREQUENCY INTERVALS", G. Pipeleers,
% T. Iwasaki and S. Hara, SIAM Journal on Control and Optimization, 2014,
% Vol. 52, No. 6, pp. 3618--3638

test_common;

strf="directFIRnonsymmetric_kyp_union_bandpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Band-pass filter specification
N=30;
d=10;
fasl=0.10;fapl=0.175;fapu=0.225;fasu=0.30;
Esq_z=4.452e-5;
Esq_s=1e-4;
Esq_max=1;

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
C_d=zeros(1,N);
C_d(N-d+1)=1;
Phi=[-1,0;0,1];
Psi_max=[0,1;1,2];
e_c=e^(j*pi*(fapu+fapl));
c_h=2*cos(pi*(fapu-fapl));
Psi_z=[0,e_c;1/e_c,-c_h];

% Set up constraints
CD=sdpvar(1,N+1);
CD_d=CD-[C_d,0];

% Maximum amplitude constraint
P_max=sdpvar(N,N,"symmetric","real");
Q_max=sdpvar(N,N,"symmetric","real");
F_max=[[((AB')*(kron(Phi,P_max)+kron(Psi_max,Q_max))*AB) + ...
        diag([zeros(1,N),-Esq_max]),CD']; ...
       [CD,-1]];

% Pass band constraint on the error |H(w)-e^(-j*w*d)|
P_z=sdpvar(N,N,"symmetric","real");
Q_z=sdpvar(N,N,"symmetric","real");
F_z=[[((AB')*(kron(Phi,P_z)+kron(Psi_z,Q_z))*AB) + ...
      diag([zeros(1,N),-Esq_z]),CD_d']; ...
     [CD_d,-1]];

% Constants for SDP constraints on the upper and lower stop bands
l=2;
n=rows(A);
m=columns(B);
Jl=[eye(l),zeros(l,1);zeros(l,1),eye(l)];
Phir=[0,i;-i,0];
Psir=[0,1;1,0];
Tr=[1,-1;i,i]/sqrt(2);
% Moebius transform of the unit circle to the real axis
z1=1;z2=i;z3=-i;
lambda=e.^(i*2*pi*[-fasl,fasl,fasu,1-fasu]); %[eta1,zeta1,eta2,zeta2]
alphabeta=((lambda-z1).*(z2-z3))./((lambda-z3).*(z2-z1));
% Sanity checks
if any(~isfinite(alphabeta))
  error("any(~isfinite(alphabeta))");
endif
if any(abs(imag(alphabeta))>10*eps)
  error("any(abs(imag(alphabeta))>10*eps)");
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
if max(max(abs(imag(Phi_slu))))>eps
  error("max(max(abs(imag(Phi_slu))))>eps");
endif
Phi_slu=real(Phi_slu);

Psi_slu=Ml'*PsiH*Ml;
Psi_slu=triu(Psi_slu,1)+diag(real(diag(Psi_slu)))+triu(Psi_slu,1)';
% Sanity checks on Psi_slu
if max(max(abs(imag(Psi_slu))))>100*eps
  error("max(max(abs(imag(Psi_slu))))>100*eps");
endif
Psi_slu=real(Psi_slu);

R_slu=M'*RH*M;
R_slu=triu(R_slu,1)+diag(real(diag(R_slu)))+triu(R_slu,1)';
% Sanity checks on R_slu
if max(max(abs(imag(R_slu))))>eps
  error("max(max(abs(imag(R_slu))))>eps");
endif
R_slu=real(R_slu);
if ~isdefinite(R_slu)
  error("~isdefinite(R_slu)");
endif
% Sanity check on Phi_slu and R_slu
Phi_slu_altR=Jl'*kron(M'*Phir*M,R_slu)*Jl;
if max(max(abs(Phi_slu_altR-Phi_slu)))>100*eps
  error("max(max(abs(Phi_slu_altR-Phi_slu)))>100*eps");
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
P_slu=sdpvar(N,N,"symmetric","real");
Q_slu=sdpvar(N,N,"symmetric","real");
F_slu=[[((F2AB')*(kron(Phi_slu,P_slu)+kron(Psi_slu,Q_slu))*F2AB) + ...
        (G2AB'*kron(R_slu,diag([zeros(1,N),-Esq_s]))*G2AB), ...
        (kron(eye(2),CD)*G2AB)']; ...
       [kron(eye(2),CD)*G2AB,-inv(R_slu)]];

% Solve with YALMIP
Constraints=[F_max<=0,Q_max>=0,F_z<=0,Q_z>=0,F_slu<=0,Q_slu>=0];
Options=sdpsettings('solver','sedumi');
sol=optimize(Constraints,[],Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif

% Sanity checks
check(Constraints)
if ~issymmetric(value(P_max))
  error("P_max not symmetric");
endif
if ~isdefinite(value(Q_max))
  error("Q_max not positive semi-definite");
endif
if ~isdefinite(-value(F_max))
  error("F_max not negative semi-definite");
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
  error("F_slu not negative semi-definite");
endif

% Extract impulse response
h=value(fliplr(CD));

% Plot amplitude response
nplot=1000;
nasl=(fasl*nplot/0.5)+1;
napl=(fapl*nplot/0.5)+1;
napu=(fapu*nplot/0.5)+1;
nasu=(fasu*nplot/0.5)+1;

[H,w]=freqz(h,1,nplot);
plot(w*0.5/pi,20*log10(abs(H)));
axis([0 0.5 -50 5]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
strt=sprintf("KYP non-symmetric FIR filter : \
N=%d,d=%d,fasu=%d,fapl=%g,fapu=%g,fasu=%g",N,d,fasl,fapl,fapu,fasu);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot zeros
z=qroots(h);
zplane(z);
title(strt);
print(strcat(strf,"_zeros"),"-dpdflatex");
close

% Plot pass band amplitude, phase and delay
subplot(311)
plot(w(napl:napu)*0.5/pi,20*log10(abs(H(napl:napu))));
axis([fapl fapu -0.04 0]);
grid("on");
ylabel("Amplitude(dB)");
strt=sprintf("KYP non-symmetric FIR filter pass band : \
N=%d,d=%d,fasu=%d,fapl=%g,fapu=%g,fasu=%g",N,d,fasl,fapl,fapu,fasu);
title(strt);
subplot(312)
plot(w(napl:napu)*0.5/pi, ...
     (((w(napl:napu)*d)+unwrap(arg(H(napl:napu))))/pi)-4);
axis([fapl fapu 0.004*[-1 1]]);
grid("on");
ylabel("Phase error(rad./$\\pi$)");
subplot(313)
[T,w]=grpdelay(h,1,nplot);
plot(w(napl:napu)*0.5/pi,T(napl:napu));
ylabel("Delay(samples)");
axis([fapl fapu d+0.4*[-1 1]]);
grid("on");
xlabel("Frequency");
print(strcat(strf,"_passband"),"-dpdflatex");
close


% Check squared-amplitude response
printf("Esq_max=%8.6f\n",Esq_max);
printf("max(abs(H).^2)=%8.6f\n",max(abs(H).^2));
printf("max(abs(H(1:nasl)).^2)=%13.6g\n",max(abs(H(1:nasl)).^2));
printf("min(abs(H(nasl:napl)).^2)=%13.6g\n",min(abs(H(nasl:napl)).^2));
printf("max(abs(H(nasl:napl)).^2)=%8.6f\n",max(abs(H(nasl:napl)).^2));
printf("min(abs(H(napl:napu)).^2)=%13.6g\n",min(abs(H(napl:napu)).^2));
printf("max(abs(H(napl:napu)).^2)=%8.6f\n",max(abs(H(napl:napu)).^2));
printf("max(abs(H(napu:nasu)).^2)=%8.6f\n",max(abs(H(napu:nasu)).^2));
printf("min(abs(H(napu:nasu)).^2)=%13.6g\n",min(abs(H(napu:nasu)).^2));
printf("max(abs(H(nasu:end)).^2)=%13.6g\n",max(abs(H(nasu:end)).^2));
Esq_z_actual=max(abs(H(napl:napu)-e.^(-j*w(napl:napu)*d)))^2;
printf("max(abs(H(napl:napu)-e.^(-j*w(napl:napu)*d)))^2=%10.8f\n",Esq_z_actual);
fid=fopen(strcat(strf,"_max_passband_squared_error.tab"),"wt");
fprintf(fid,"%10.8f",Esq_z_actual);
fclose(fid);

% Save results
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"N=%d %% FIR filter order\n",N);
fprintf(fid,"d=%d %% Nominal FIR filter delay\n",d);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"Esq_max=%g %% Maximum squared amplitude\n",Esq_max);
fprintf(fid,"Esq_z=%g %% Squared amplitude pass band - delay error\n",Esq_z);
fprintf(fid,"Esq_s=%g %% Squared amplitude stop band error\n",Esq_s);
fclose(fid);

print_polynomial(h,"h","%13.10f");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"),"%13.10f");

save directFIRnonsymmetric_kyp_union_bandpass_test.mat ...
     N d fasl fapl fapu fasu Esq_z Esq_s Esq_max h

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
