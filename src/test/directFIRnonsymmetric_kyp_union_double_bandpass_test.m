% directFIRnonsymmetric_kyp_union_double_bandpass_test.m
% Copyright (C) 2023 Robert G. Jenssen
%
% SDP design of a non-symmetric FIR double bandpass filter with the KYP
% lemma. The pass band responses are set to e^{-j*w*d}. The stop band
% response is specified as the union of the lower, middle and upper stop bands.
%
% See:
% "GENERALIZING THE KYP LEMMA TO MULTIPLE FREQUENCY INTERVALS", G. Pipeleers,
% T. Iwasaki and S. Hara, SIAM Journal on Control and Optimization, 2014,
% Vol. 52, No. 6, pp. 3618--3638

test_common;

strf="directFIRnonsymmetric_kyp_union_double_bandpass_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Increase from the default SeDuMi eps
sedumi_eps=1e-8;

% Band-pass filter specification
% Fails with numerical problems for sedumi.eps=1e-9,(N=60,d=20),(N=50,d=20) !
N=48;
d=20;

% Amplitude constraints
Esq_z=5e-5;
Esq_s=8e-5;
% First stop band
fasu1=0.10;
% First pass band
fapl1=0.15;fapu1=0.20;
% Second stop band
fasl2=0.25;fasu2=0.30;
% Second pass band
fapl2=0.35;fapu2=0.40;
% Third stop band
fasl3=0.45;

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
n=rows(A);
m=columns(B);
AB=[A,B;eye(N),zeros(N,1)];
C_d=zeros(1,N);
C_d(N-d+1)=1;
Phi=[-1,0;0,1];

% Fl and Gl
F1AB=[A,B; ...
      eye(size(A)),zeros(size(B))];
F2AB=[A*A,A*B,B; ...
      A,B,zeros(size(B)); ...
      eye(size(A)),zeros(size(B)),zeros(size(B))];
F3AB=[A*A*A,A*A*B,A*B,B; ...
      A*A,A*B,B,zeros(size(B)); ...
      A,B,zeros(size(B)),zeros(size(B)); ...
      eye(size(A)),zeros(size(B)),zeros(size(B)),zeros(size(B))];
% G2AB
F10I=[0,1;1,0];
G2AB=(kron(eye(2),[eye(n);zeros(m,n)])*[F1AB,zeros(n*2,m)]) + ...
     (kron(eye(2),[zeros(n,m);eye(m)])*[zeros(m*2,n),F10I]);
% Sanity check on G2AB
G2AB_alt=[A,B,zeros(n,1);zeros(1,n+1),1;eye(n),zeros(n,2);zeros(1,n),1,0];
if max(max(abs(G2AB-G2AB_alt)))~=0
  error("max(max(abs(G2AB-G2AB_alt)))~=0")
endif
% G3AB
F20I=[0,0,1;0,1,0;1,0,0];
G3AB=(kron(eye(3),[eye(n);zeros(m,n)])*[F2AB,zeros(n*3,m)]) + ...
     (kron(eye(3),[zeros(n,m);eye(m)])*[zeros(m*3,n),F20I]);
% Sanity check on G3AB (see p.3622 of [1])
G3AB_alt=[A*A,A*B,B,zeros(n,m); ...
          zeros(m,n+((3-1)*m)),eye(m); ...
          A,B,zeros(n,(3-1)*m); ...
          zeros(m,n+m),eye(m),zeros(m); ...
          eye(n),zeros(n,3*m); ...
          zeros(m,n),eye(m),zeros(m,(3-1)*m)];
if max(max(abs(G3AB-G3AB_alt)))~=0
  error("max(max(abs(G3AB-G3AB_alt)))~=0")
endif
    
% Set up constraints
CD=sdpvar(1,N+1,"full","real");
CD_d=CD-[C_d,0];

% Constants for SDP constraints on the upper and lower pass bands
l=2;
n=rows(A);
m=columns(B);
Jl=[eye(l),zeros(l,1);zeros(l,1),eye(l)];
Phir=[0,i;-i,0];
Psir=[0,1;1,0];
Tr=[1,-1;i,i]/sqrt(2);
% Moebius transform of the unit circle to the real axis
z1=1;z2=i;z3=-i;
lambda=e.^(i*2*pi*[fapl1,fapu1,fapl2,fapu2]);
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

Phi_plu=Ml'*PhiH*Ml;
Phi_plu=triu(Phi_plu,1)+diag(real(diag(Phi_plu)))+triu(Phi_plu,1)';

Psi_plu=Ml'*PsiH*Ml;
Psi_plu=triu(Psi_plu,1)+diag(real(diag(Psi_plu)))+triu(Psi_plu,1)';

R_plu=M'*RH*M;
R_plu=triu(R_plu,1)+diag(real(diag(R_plu)))+triu(R_plu,1)';
if ~isdefinite(R_plu)
  error("~isdefinite(R_plu)");
endif
% Sanity check on Phi_plu and R_plu
Phi_plu_altR=Jl'*kron(M'*Phir*M,R_plu)*Jl;
if max(max(abs(Phi_plu_altR-Phi_plu)))>100*eps
  error("max(max(abs(Phi_plu_altR-Phi_plu)))>100*eps");
endif

% Union of lower and upper pass band constraints
P_plu=sdpvar(N,N,"symmetric","real");
Q_plu=sdpvar(N,N,"hermitian","complex");
F_plu=[[((F2AB')*(kron(Phi_plu,P_plu)+kron(Psi_plu,Q_plu))*F2AB) + ...
        (G2AB'*kron(R_plu,diag([zeros(1,N),-Esq_z]))*G2AB), ...
        (kron(eye(2),CD_d)*G2AB)']; ...
        [kron(eye(2),CD_d)*G2AB,-inv(R_plu)]];

% Constants for SDP constraints on the upper, middle and lower stop bands
l=3;
Jl=[eye(l),zeros(l,1);zeros(l,1),eye(l)];
Phir=[0,i;-i,0];
Psir=[0,1;1,0];
Tr=[1,-1;i,i]/sqrt(2);
% Moebius transform of the unit circle to the real axis
% (Rotate so that z3 is not in the pass or stop bands)
efm=e^(i*2*pi*(fasl2-fapu1)/2);
z1=efm;z2=i*efm;z3=-i*efm;
lambda=e.^(i*2*pi*[-fasu1,fasu1,fasl2,fasu2,fasl3,1-fasl3]);
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
alpha3=alphabeta(5);
beta1=alphabeta(2);
beta2=alphabeta(4);
beta3=alphabeta(6);
% Sanity checks
if ~((alpha1<beta1) && (beta1<alpha2) && (alpha2<beta2) && ...
     (beta2<alpha3) && (alpha3<beta3))
  error("~((alpha1<beta1) && (beta1<alpha2) && (alpha2<beta2) etc)");
endif
% Transform the image from the real axis to s in i*[-1,1]
a=[ 1; ...
   -alpha1 - alpha2 - alpha3; ...
    alpha1*alpha2 + alpha1*alpha3 + alpha2*alpha3; ...
   -alpha1*alpha2*alpha3];
b=[ 1; ...
   -beta1 - beta2 - beta3; ...
    beta1*beta2 + beta1*beta3 + beta2*beta3; ...
   -beta1*beta2*beta3];
TtH=[-a,b].';
PhiH=TtH'*Phir*TtH;
PsiH=TtH'*Psir*TtH;
RH_11=imag(PhiH(1,2));
RH_12=imag(PhiH(1,3));
RH_13=imag(PhiH(1,4));
RH_22=imag(PhiH(2,3))+RH_13;
RH_23=imag(PhiH(2,4));
RH_33=imag(PhiH(3,4));
RH=[RH_11,RH_12,RH_13; ...
    RH_12,RH_22,RH_23; ...
    RH_13,RH_23,RH_33];
% Apply the Moebius transform to (PhiH,PsiH) and force a Hermitian result
M=[z2-z3,-z1*(z2-z3); ...
   z2-z1,-z3*(z2-z1)];
M1=M(1,:);
M2=M(2,:);
Mlm1=[conv(M1,M1); ...
      conv(M1,M2); ...
      conv(M2,M2)];
Ml=[conv(M1,conv(M1,M1)); ...
    conv(M1,conv(M1,M2)); ...
    conv(M1,conv(M2,M2)); ...
    conv(M2,conv(M2,M2))];

Phi_slmu=Ml'*PhiH*Ml;
Phi_slmu=triu(Phi_slmu,1)+diag(real(diag(Phi_slmu)))+triu(Phi_slmu,1)';

Psi_slmu=Ml'*PsiH*Ml;
Psi_slmu=triu(Psi_slmu,1)+diag(real(diag(Psi_slmu)))+triu(Psi_slmu,1)';

R_slmu=Mlm1'*RH*Mlm1;
R_slmu=triu(R_slmu,1)+diag(real(diag(R_slmu)))+triu(R_slmu,1)';
if ~isdefinite(R_slmu)
  error("~isdefinite(R_slmu)");
endif
% Sanity check on Phi_slmu and R_slmu
Phi_slmu_altR=Jl'*kron(M'*Phir*M,R_slmu)*Jl;
if max(max(abs(Phi_slmu_altR-Phi_slmu)))>2500*eps
  error("max(max(abs(Phi_slmu_altR-Phi_slmu)))>2500*eps");
endif

% Union of lower, middle and upper stop band constraints
P_slmu=sdpvar(N,N,"symmetric","real");
Q_slmu=sdpvar(N,N,"hermitian","complex");
F_slmu=[[((F3AB')*(kron(Phi_slmu,P_slmu)+kron(Psi_slmu,Q_slmu))*F3AB) + ...
        (G3AB'*kron(R_slmu,diag([zeros(1,N),-Esq_s]))*G3AB), ...
        (kron(eye(3),CD)*G3AB)']; ...
       [kron(eye(3),CD)*G3AB,-inv(R_slmu)]];

% Solve with YALMIP
Constraints=[F_plu<=-sedumi_eps,Q_plu>=0,F_slmu<=-sedumi_eps,Q_slmu>=0];
Options=sdpsettings("solver","sedumi","sedumi.eps",sedumi_eps);
sol=optimize(Constraints,[],Options);
if (sol.problem ~= 0)
  error("YALMIP failed : %s",sol.info);
endif

% Sanity checks
check(Constraints)
if ~issymmetric(value(P_plu))
  error("P_plu not symmetric");
endif
if ~ishermitian(value(Q_plu))
  error("Q_plu not hermitian");
endif
if ~isdefinite(value(Q_plu))
  error("Q_plu not positive semi-definite");
endif
if ~ishermitian(value(F_plu))
  error("F_plu not hermitian");
endif
if ~isdefinite(-value(F_plu))
  error("F_plu not negative semi-definite");
endif
if ~issymmetric(value(P_slmu))
  error("P_slmu not symmetric");
endif
if ~ishermitian(value(Q_slmu))
  error("Q_slmu not hermitian");
endif
if ~isdefinite(value(Q_slmu))
  error("Q_slmu not positive semi-definite");
endif
if ~ishermitian(value(F_slmu))
  error("F_slmu not hermitian");
endif
if ~isdefinite(-value(F_slmu))
  error("F_slmu not negative semi-definite");
endif

% Extract impulse response
h=value(fliplr(CD));

% Plot amplitude, phase and delay
nplot=1000;
nasu1=(fasu1*nplot/0.5)+1;
napl1=(fapl1*nplot/0.5)+1;
napu1=(fapu1*nplot/0.5)+1;
nasl2=(fasl2*nplot/0.5)+1;
nasu2=(fasu2*nplot/0.5)+1;
napl2=(fapl2*nplot/0.5)+1;
napu2=(fapu2*nplot/0.5)+1;
nasl3=(fasl3*nplot/0.5)+1;

[H,w]=freqz(h,1,nplot);
Asq=abs(H).^2;
P=(w*d)+unwrap(arg(H));
[T,w]=delayz(h,1,nplot);

subplot(311)
ax=plotyy(w*0.5/pi,10*log10(Asq),w*0.5/pi,10*log10(Asq));
axis(ax(1),[0 0.5 -60 -40]);
axis(ax(2),[0 0.5 -0.04 0.04]);
grid("on");
ylabel("Amplitude(dB)");
strt=sprintf("KYP non-symmetric double pass-band FIR filter : \
N=%d,d=%d,fapl1=%g,fapu1=%g,fapl2=%g,fapu2=%g",N,d,fapl1,fapu1,fapl2,fapu2);
title(strt);
subplot(312)
ax=plotyy(w(napl1:napu1)*0.5/pi,(P(napl1:napu1)/pi)+2, ...
                  w(napl2:napu2)*0.5/pi,(P(napl2:napu2)/pi)+8);
axis(ax(1),[0 0.5 0.002*[-1 1]]);
axis(ax(2),[0 0.5 0.002*[-1 1]]);
grid("on");
ylabel("Phase error(rad./$\\pi$)");
subplot(313)
ax=plotyy(w(napl1:napu1)*0.5/pi,T(napl1:napu1), ...
                  w(napl2:napu2)*0.5/pi,T(napl2:napu2));
axis(ax(1),[0 0.5 d+0.2*[-1 1]]);
axis(ax(2),[0 0.5 d+0.2*[-1 1]]);
grid("on");
ylabel("Delay(samples)");
xlabel("Frequency");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Check squared-amplitude response
printf("max(10*log10(Asq))           =%11.4g\n",
       max(10*log10(Asq)));
printf("max(10*log10(Asq)),su1       =%11.4g\n",
       max(10*log10(Asq)(    1:nasu1)));
printf("min(10*log10(Asq)),su1 to pl1=%11.4g\n",
       min(10*log10(Asq)(nasu1:napl1)));
printf("max(10*log10(Asq)),su1 to pl1=%11.4g\n",
       max(10*log10(Asq)(nasu1:napl1)));
printf("min(10*log10(Asq)),pl1 to pu1=%11.4g\n",
       min(10*log10(Asq)(napl1:napu1)));
printf("max(10*log10(Asq)),pl1 to pu1=%11.4g\n",
       max(10*log10(Asq)(napl1:napu1)));
printf("max(10*log10(Asq)),pu1 to sl2=%11.4g\n",
       max(10*log10(Asq)(napu1:nasl2)));
printf("min(10*log10(Asq)),pu1 to sl2=%11.4g\n",
       min(10*log10(Asq)(napu1:nasl2)));
printf("max(10*log10(Asq)),sl2 to su2=%11.4g\n",
       max(10*log10(Asq)(nasl2:nasu2)));
printf("min(10*log10(Asq)),su2 to pl2=%11.4g\n",
       min(10*log10(Asq)(nasu2:napl2)));
printf("max(10*log10(Asq)),su2 to pl2=%11.4g\n",
       max(10*log10(Asq)(nasu2:napl2)));
printf("min(10*log10(Asq)),pl2 to pu2=%11.4g\n",
       min(10*log10(Asq)(napl2:napu2)));
printf("max(10*log10(Asq)),pl2 to pu2=%11.4g\n",
       max(10*log10(Asq)(napl2:napu2)));
printf("min(10*log10(Asq)),pu2 to sl3=%11.4g\n",
       min(10*log10(Asq)(napu2:nasl3)));
printf("max(10*log10(Asq)),pu2 to sl3=%11.4g\n",
       max(10*log10(Asq)(napu2:nasl3)));
printf("max(10*log10(Asq)),sl3 to end=%11.4g\n",
       max(10*log10(Asq)(nasl3:end  )));
Esq_z_actual=max([abs(H(napl1:napu1)-e.^(-j*w(napl1:napu1)*d)); ...
                  abs(H(napl2:napu2)-e.^(-j*w(napl2:napu2)*d))])^2;
printf("max. passbands squared-error=%10.8f\n",Esq_z_actual);
fid=fopen(strcat(strf,"_max_passband_squared_error.tab"),"wt");
fprintf(fid,"%10.8f",Esq_z_actual);
fclose(fid);

% Check phase response
printf("min phase error(rad./pi), pl1 to pu1=%11.4g\n",
       min((P(napl1:napu1)/pi)+2));
printf("max phase error(rad./pi), pl1 to pu1=%11.4g\n",
       max((P(napl1:napu1)/pi)+2));
printf("min phase error(rad./pi), pl2 to pu2=%11.4g\n",
       min((P(napl2:napu2)/pi)+8));
printf("max phase error(rad./pi), pl2 to pu2=%11.4g\n",
       max((P(napl2:napu2)/pi)+8));

% Check delay
printf("min delay, pl1 to pu1=%11.4g\n", min(T(napl1:napu1)));
printf("max delay, pl1 to pu1=%11.4g\n", max(T(napl1:napu1)));
printf("min delay, pl2 to pu2=%11.4g\n", min(T(napl2:napu2)));
printf("max delay, pl2 to pu2=%11.4g\n", max(T(napl2:napu2)));

% Save results
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"eps=%g %% SeDuMi eps\n",sedumi_eps);
fprintf(fid,"N=%d %% FIR filter order\n",N);
fprintf(fid,"d=%d %% Nominal FIR filter delay\n",d);
fprintf(fid,"fasu1=%g %% Amplitude first stop band upper edge\n",fasu1);
fprintf(fid,"fapl1=%g %% Amplitude first pass band lower edge\n",fapl1);
fprintf(fid,"fapu1=%g %% Amplitude first pass band upper edge\n",fapu1);
fprintf(fid,"fasl2=%g %% Amplitude second stop band lower edge\n",fasl2);
fprintf(fid,"fasu2=%g %% Amplitude second stop band upper edge\n",fasu2);
fprintf(fid,"fapl2=%g %% Amplitude second pass band lower edge\n",fapl2);
fprintf(fid,"fapu2=%g %% Amplitude second pass band upper edge\n",fapu2);
fprintf(fid,"fasl3=%g %% Amplitude third stop band lower edge\n",fasl3);
fprintf(fid,"Esq_z=%g %% Squared amplitude pass band - delay error\n",Esq_z);
fprintf(fid,"Esq_s=%g %% Squared amplitude stop band error\n",Esq_s);
fclose(fid);

print_polynomial(h,"h","%13.10f");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"),"%13.10f");

save directFIRnonsymmetric_kyp_union_double_bandpass_test.mat ...
     sedumi_eps N d Esq_z Esq_s fasu1 fapl1 fapu2 fasl2 fasu2 fapl2 fapu2 fasl3 h

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
