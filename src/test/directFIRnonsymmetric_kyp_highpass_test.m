% directFIRnonsymmetric_kyp_highpass_test.m
% Copyright (C) 2021-2023 Robert G. Jenssen

% SDP design of a direct-form FIR highpass filter with the KYP lemma.
% See Section VII.B.2, pp. 53-55 of "Generalised KYP Lemma: Unified
% Frequency Domain Inequalities With Design Applications", T. Iwasaki
% and S. Hara, IEEE Transactions on Automatic Control, Vol. 50, No. 1,
% January 2005, pp. 41–59
%
% Note that the YALMIP, Octave, Symbolic Toolbox and SymPy combination
% requires that the KYP constraints have rows enclosed in square brackets.

test_common;

strf="directFIRnonsymmetric_kyp_highpass_test";

tmpdiaryfile=strcat(strf,".diary.tmp");
diaryfile=strcat(strf,".diary");
delete(diaryfile);
delete(tmpdiaryfile);
eval(sprintf("diary %s",tmpdiaryfile));

tic;

% Filter specification
N=30,d=10,fas=0.15,fap=0.2,Esq_max=1,Esq_z=5.58e-3,Esq_s=1e-4

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
C_d=zeros(1,N);
C_d(N-d+1)=1;
Phi=[-1,0;0,1];
Psi_max=[0,1;1,2];
c_p=2*cos(2*pi*fap);
Psi_z=[0,-1;-1,c_p];
c_s=2*cos(2*pi*fas);
Psi_s=[0,1;1,-c_s];

% Filter SDP variable
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
% Stop band constraint 
P_s=sdpvar(N,N,"symmetric","real");
Q_s=sdpvar(N,N,"symmetric","real");
F_s=[[((AB')*(kron(Phi,P_s)+kron(Psi_s,Q_s))*AB) + ...
      diag([zeros(1,N),-Esq_s]),CD']; ...
     [CD,-1]];

% Solve with YALMIP
Constraints=[F_max<=0,Q_max>=0,F_z<=0,Q_z>=0,F_s<=0,Q_s>=0];
Objective=[];
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
w=(0:(nplot-1))'*pi/nplot;
H=freqz(h,1,w);
T=delayz(h,1,w);
subplot(211);
ax=plotyy(w(1:nas)*0.5/pi,20*log10(abs(H(1:nas))),...
                  w(nap:end)*0.5/pi,20*log10(abs(H(nap:end))));
axis(ax(1),[0 0.5 -60 -20]);
axis(ax(2),[0 0.5 -1 1]);
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf("N=%d,d=%d,fap=%4.2f,fas=%4.2f,Esq\\_z=%10.8f,Esq\\_s=%6.4f",
             N,d,fap,fas,Esq_z,Esq_s);
title(strt);
subplot(212);
plot(w(nap:end)*0.5/pi,T(nap:end));
axis([0 0.5 d+2*[-1,1]]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Check maximum amplitude response
printf("max(abs(H(1:nas)))=%g\n",max(abs(H(1:nas))));
printf("min(abs(H(1:nas)))=%g\n",min(abs(H(1:nas))));
printf("max(abs(H(nas:nap)))=%g\n",max(abs(H(nas:nap))));
printf("min(abs(H(nas:nap)))=%g\n",min(abs(H(nas:nap))));
printf("max(abs(H(nap:end)))=%g\n",max(abs(H(nap:end))));

Asq_z=max(abs(H(nap:end)-e.^(-j*w(nap:end)*d)))^2;
printf("max(Asq_z)=%g\n",Asq_z);
fid=fopen(strcat(strf,"_max_passband_squared_error.tab"),"wt");
fprintf(fid,"%10.8f",Asq_z);
fclose(fid);

Asq_s=max(abs(H(1:nas)))^2;
printf("max(Asq_s)=%12.4g\n",Asq_s);
fid=fopen(strcat(strf,"_max_stopband_squared_error.tab"),"wt");
fprintf(fid,"%8.4g",Asq_s);
fclose(fid);

% Save results
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"N=%d %% FIR filter order\n",N);
fprintf(fid,"d=%d %% Nominal FIR filter delay\n",d);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"Esq_max=%g %% Maximum overall squared amplitude\n",Esq_max);
fprintf(fid,"Esq_z=%g %% Squared amplitude pass band error from delay\n",Esq_z);
fprintf(fid,"Esq_s=%g %% Squared amplitude stop band error\n",Esq_s);
fclose(fid);

print_polynomial(h,"h","%13.10f");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"),"%13.10f");

eval(sprintf("save %s.mat N d fas fap Esq_max Esq_z Esq_s",strf));

% Done
toc;
diary off
movefile(tmpdiaryfile,diaryfile);
