% directFIRsymmetric_kyp_lowpass_test.m
%
% Copyright (C) 2022-2025 Robert G. Jenssen

% SDP design of a symmetric direct-form FIR lowpass filter with the
% KYP lemma. See Section VII.B.2, pp. 53-55 of "Generalised KYP Lemma:
% Unified Frequency Domain Inequalities With Design Applications",
% T. Iwasaki and S. Hara, IEEE Transactions on Automatic Control,
% Vol. 50, No. 1, January 2005, pp. 41–59

test_common;

strf="directFIRsymmetric_kyp_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

%
% Low-pass filter
%
M=27;N=2*M;d=M;
fap=0.15;Esq_z=0.81241e-5;
fas=0.2;Esq_s=1e-5;

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
C_d=zeros(1,N);
C_d(N-d+1)=1;
Phi=[-1,0;0,1];
c_p=2*cos(2*pi*fap);
Psi_z=[0,1;1,-c_p];
c_s=2*cos(2*pi*fas);
Psi_s=[0,-1;-1,c_s];

% Filter impulse response SDP variable
CM1=sdpvar(1,M+1);
CD=[CM1,CM1(M:-1:1)];
CD_d=CD-[C_d,0];
              
% Pass band constraint on the error |H(w)-e^(-j*w*d)|^2
P_z=sdpvar(N,N,"symmetric","real");
Q_z=sdpvar(N,N,"symmetric","real");
F_z=[[((AB')*(kron(Phi,P_z)+kron(Psi_z,Q_z))*AB) + ...
      diag([zeros(1,N),-Esq_z]),CD_d']; ...
     [CD_d,-1]];

% Constraint on maximum stop band amplitude
P_s=sdpvar(N,N,"symmetric","real");
Q_s=sdpvar(N,N,"symmetric","real");
F_s=[[((AB')*(kron(Phi,P_s)+kron(Psi_s,Q_s))*AB) + ...
      diag([zeros(1,N),-Esq_s]),CD']; ...
     [CD,-1]];

% Satisfy constraints on zero-phase pass-band error and stop-band error
Objective=[];
Constraints=[F_z<=0,Q_z>=0,F_s<=0,Q_s>=0];
Options=sdpsettings("solver","sedumi");
sol=optimize(Constraints,Objective,Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif
% Sanity checks
check(Constraints)
if ~issymmetric(value(P_z))
  error("P_z not symmetric");
endif
if ~isdefinite(value(Q_z))
  error("Q_z not positive semi-definite");
endif
if ~isdefinite(-value(F_z))
  error("F_z not negative semi-definite");
endif
if ~issymmetric(value(P_s))
  error("P_s not symmetric");
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
h=value(fliplr(CD));
f=(0:(nplot-1))'*0.5/nplot;
w=f*2*pi;
H=freqz(h,1,w);
ax=plotyy(w(1:nap)*0.5/pi,20*log10(abs(H(1:nap))), ...
          w(nas:end)*0.5/pi,20*log10(abs(H(nas:end))));
axis(ax(1),[0 0.5 -0.04 0.04]);
axis(ax(2),[0 0.5 -60 -40]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
strt=sprintf("N=%d,d=%d,fap=%4.2f,Esq\\_z=%g,fas=%4.2f,Esq\\_s=%g", ...
             N,d,fap,Esq_z,fas,Esq_s);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Check amplitude response
max_Esq_z=max(abs(H(1:nap)-e.^(-j*w(1:nap)*d)))^2;
printf("max_Esq_z=%g\n",max_Esq_z);
fid=fopen(strcat(strf,"_max_passband_squared_error.tab"),"wt");
fprintf(fid,"%10.5g",max_Esq_z);
fclose(fid);
max_Esq_s=max(abs(H(nas:end)))^2;
printf("max_Esq_s=%g\n",max_Esq_s);
fid=fopen(strcat(strf,"_max_stopband_squared_error.tab"),"wt");
fprintf(fid,"%10.5g",max_Esq_s);
fclose(fid);
printf("max_A_p=%10.8f, %5.3fdB\n", ...
       max(abs(H(1:nap))),20*log10(max(abs(H(1:nap)))));
printf("min_A_p=%10.8f, %5.3fdB\n", ...
       min(abs(H(1:nap))),20*log10(max(abs(H(1:nap)))));
printf("max_A_t=%10.8f, %5.3fdB\n", ...
       max(abs(H(nap:nas))),20*log10(max(abs(H(nap:nas)))));
printf("max_A_s=%10.8f, %5.3fdB\n", ...
       max(abs(H(nas:end))),20*log10(max(abs(H(nas:end)))));
% Overall squared-error
Esq=directFIRsymmetricEsqPW(h(1:(M+1)),[0,fap,fas,0.5]*2*pi,[1,0,0],[1,1,1]);
printf("Esq=%10.8f\n",Esq);

% Save results
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Esq_z=%g %% Squared pass band error from delay\n",Esq_z);
fprintf(fid,"Esq_s=%g %% Squared amplitude stop band error\n",Esq_s);
fclose(fid);
print_polynomial(h,"h","%13.10f");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"),"%13.10f");
eval(sprintf("save %s.mat N d fap fas Esq_z Esq_s h",strf));

%
% Comparison with mcclellanFIRsymmetric
%
F=[f(1:(nap-1));fap;fas;f((nas+1):end)];
D=[ones(nap,1); zeros(length(F)-nap,1)];
K=1;
W=[ones(nap,1)/K; ones(length(F)-nap,1)];
[hM,rho,fext,fiter,feasible]=mcclellanFIRsymmetric(M,F,D,W);
if feasible==false
  error("hM not feasible");
endif
wa=(0:nplot)'*pi/nplot;
A=directFIRsymmetricA(wa,hM);
ax=plotyy(wa(1:nap)*0.5/pi,20*log10(abs(A(1:nap))), ...
          wa(nas:end)*0.5/pi,20*log10(abs(A(nas:end))));
axis(ax(1),[0 0.5 -0.04 0.04]);
axis(ax(2),[0 0.5 -60 -40]);
strt=sprintf("McClellan lowpass FIR: M=%d,fap=%g,fas=%g,K=%g,rho=%g", ...
             M,fap,fas,K,rho);
title(strt);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_mcclellan"),"-dpdflatex");
close
fid=fopen(strcat(strf,"_mcclellan_spec.m"),"wt");
fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"K=%d %% Stop band weight\n",K);
fprintf(fid,"nplot=%d %% Number of frequency grid points in [0,0.5]\n",nplot);
fclose(fid);
print_polynomial(hM,"hM","%13.10f");
print_polynomial(hM,"hM",strcat(strf,"_mcclellan_hM_coef.m"),"%13.10f");


%
% Done
%
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"),"f");
