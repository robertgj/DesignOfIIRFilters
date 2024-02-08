% directFIRnonsymmetric_kyp_finsler_lowpass_test.m
% Copyright (C) 2024 Robert G. Jenssen

% SDP design of a direct-form FIR lowpass filter with the Finsler transform
% of the generalised KYP lemma. See: Section VII.B.2, pp. 53-55 of "Generalised
% KYP Lemma: Unified Frequency Domain Inequalities With Design Applications",
% T. Iwasaki and S. Hara, IEEE Transactions on Automatic Control,
% Vol. 50, No. 1, January 2005, pp. 41–59

test_common;

strf="directFIRnonsymmetric_kyp_finsler_lowpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Low-pass filter specification
d=10;M=15;N=2*M;fap=0.15;Esq_z=5.9e-3;fas=0.2;Esq_s=1e-4;
AdB_est=konopacki(N,(fas-fap)*2*pi,d)

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
C_d=zeros(1,N);
C_d(N-d+1)=1;
Phi=[-1,0;0,1];
Psi_z=[0,1;1,-2*cos(2*pi*fap)];
Psi_s=[0,-1;-1,2*cos(2*pi*fas)];

% Filter impulse response SDP variable
CD=sdpvar(1,N+1);
CD_d=CD-[C_d,0];
              
% Pass band constraint on the error |H(w)-e^(-j*w*d)|^2
P_z=sdpvar(N,N,"symmetric","real");
Q_z=sdpvar(N,N,"symmetric","real");
XYZ_z=sdpvar((2*N)+1,N,"full","real");
U_z=[[-eye(N),A,B,zeros(N,1)];[zeros(1,N),CD_d,-1]]';
V_z=[[XYZ_z,zeros((2*N)+1,1)];[zeros(1,N),1]]';
UV_z=U_z*V_z;
L_z=(kron(Phi,P_z)+kron(Psi_z,Q_z));
F_z=[[L_z,zeros(2*N,2)];[zeros(2,2*N),diag([-Esq_z,1])]]+UV_z+(UV_z');

% Constraint on maximum stop band amplitude
P_s=sdpvar(N,N,"symmetric","real");
Q_s=sdpvar(N,N,"symmetric","real");
XYZ_s=sdpvar((2*N)+1,N,"full","real");
U_s=[[-eye(N),A,B,zeros(N,1)];[zeros(1,N),CD,-1]]';
V_s=[[XYZ_s,zeros((2*N)+1,1)];[zeros(1,N),1]]';
UV_s=U_s*V_s;
L_s=(kron(Phi,P_s)+kron(Psi_s,Q_s));
F_s=[[L_s,zeros(2*N,2)];[zeros(2,2*N),diag([-Esq_s,1])]]+UV_s+(UV_s');

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

% Extract results
h=value(fliplr(CD));

% Plot response
nplot=1000;
nap=(fap*nplot/0.5)+1;
nas=(fas*nplot/0.5)+1;
w=(0:(nplot-1))'*pi/nplot;
H=freqz(h,1,w);
T=delayz(h,1,w);
subplot(211);
ax=plotyy(w(1:nap)*0.5/pi,20*log10(abs(H(1:nap))), ...
          w(nas:end)*0.5/pi,20*log10(abs(H(nas:end))));
set(ax(1),"ycolor","black");
set(ax(2),"ycolor","black");
axis(ax(1),[0 0.5 -1 1]);
axis(ax(2),[0 0.5 -60 -20]);
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf("N=%d,d=%d,fap=%4.2f,fas=%4.2f,Esq\\_z=%6.4f,Esq\\_s=%6.4f",
             N,d,fap,fas,Esq_z,Esq_s);
title(strt);
subplot(212);
plot(w(1:nap)*0.5/pi,T(1:nap));
axis([0 0.5 d+[-1,1]]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Check amplitude response
max_Esq_z=max(abs(H(1:nap)-e.^(-j*w(1:nap)*d)))^2;
printf("max_Esq_z=%10.8f\n",max_Esq_z);
fid=fopen(strcat(strf,"_max_passband_squared_error.tab"),"wt");
fprintf(fid,"%10.8f",max_Esq_z);
fclose(fid);
max_Esq_s=max(abs(H(nas:end)))^2;
printf("max_Esq_s=%10.8f\n",max_Esq_s);
fid=fopen(strcat(strf,"_max_stopband_squared_error.tab"),"wt");
fprintf(fid,"%10.8f",max_Esq_s);
fclose(fid);
printf("max_A_p=%10.8f\n",max(abs(H(1:nap))));
printf("max_A_t=%10.8f\n",max(abs(H(nap:nas))));
printf("max_A_s=%10.8f\n",max(abs(H(nas:end))));
% Check delay response
printf("max_T_p=%7.4f\n",max(abs(T(1:nap))));
printf("min_T_p=%7.4f\n",min(abs(T(1:nap))));
% Overall squared-error
Esq=directFIRnonsymmetricEsqPW(h,[0,fap,fas,0.5]*2*pi,[1,0,0],[d,0,0],[1,1,1]);
printf("Esq=%10.8f\n",Esq);

% Save results
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"N=%d %% FIR filter order\n",N);
fprintf(fid,"d=%d %% Nominal FIR filter delay\n",d);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",Esq_s);
fprintf(fid,"Esq_z=%g %% Squared amplitude pass band error\n",Esq_z);
fprintf(fid,"Esq_s=%g %% Squared amplitude stop band error\n",Esq_s);
fclose(fid);

print_polynomial(h,"h","%13.10f");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"),"%13.10f");

eval(sprintf("save %s.mat N d fap fas h Esq_z Esq_s",strf));

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"),"f");
