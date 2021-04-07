% directFIRnonsymmetric_kyp_lowpass_test.m
% Copyright (C) 2021 Robert G. Jenssen

% SDP design of a direct-form FIR lowpass filter with the KYP lemma.
% See Section VII.B.2, pp. 53-55 of "Generalised KYP Lemma: Unified
% Frequency Domain Inequalities With Design Applications", T. Iwasaki
% and S. Hara, IEEE Transactions on Automatic Control, Vol. 50, No. 1,
% January 2005, pp. 41–59
%
% Note that the YALMIP, Octave, Symbolic Toolbox and SymPy combination
% requires that the KYP constraints have rows enclosed in square brackets.
%
% This script does not achieve the results found by Iwasaki and Hara

test_common;

delete("directFIRnonsymmetric_kyp_lowpass_test.diary");
delete("directFIRnonsymmetric_kyp_lowpass_test.diary.tmp");
diary directFIRnonsymmetric_kyp_lowpass_test.diary.tmp

pkg load symbolic optim

tic;

strf="directFIRnonsymmetric_kyp_lowpass_test";

% Filter specification from the example of Iwasaki and Hara
N=30,d=10,fap=0.15,fas=0.2,Esq_s=1e-4,Esq_max=1.1

% Common constants
nplot=1000;
nap=(fap*nplot/0.5)+1;
nas=(fas*nplot/0.5)+1;
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
Phi=[-1,0;0,1];
C_d=zeros(1,N);
C_d(N-d+1)=1;
c_p=2*cos(2*pi*fap);
c_s=2*cos(2*pi*fas);

% Set up constraints
Esq_z=sdpvar(1,1);
C=sdpvar(1,N);
D=sdpvar(1,1);
% Maximum amplitude constraint
P_max=sdpvar(N,N,"symmetric");
Q_max=sdpvar(N,N,"symmetric");
F_max=sdpvar(N+2,N+2,"symmetric");
F_max=[[((AB')*(kron(P_max,Phi)+kron(Q_max,[0,1;1,2]))*AB) + ...
        diag([zeros(1,N),-Esq_max]),[C,D]']; ...
       [C,D,-1]];
% Pass band constraint on the error |H(w)-e^(-j*w*d)|
P_z=sdpvar(N,N,'symmetric');
Q_z=sdpvar(N,N,'symmetric');
F_z=sdpvar(N+2,N+2,'symmetric');
F_z=[[((AB')*(kron(P_z,Phi)+kron(Q_z,[0,1;1,-c_p]))*AB) + ...
      diag([zeros(1,N),-Esq_z]),[C-C_d,D]']; ...
     [C-C_d,D,-1]];
% Stop band constraint 
P_s=sdpvar(N,N,'symmetric');
Q_s=sdpvar(N,N,'symmetric');
F_s=sdpvar(N+2,N+2,'symmetric');
F_s=[[((AB')*(kron(P_s,Phi)+kron(Q_s,[0,-1;-1,c_s]))*AB) + ...
      diag([zeros(1,N),-Esq_s]),[C,D]']; ...
     [C,D,-1]];

% Solve with YALMIP
Constraints=[F_max<=0,Q_max>=0,F_z<=0,Q_z>=0,F_s<=0,Q_s>=0];
Objective=Esq_z;
Options=sdpsettings('solver','sedumi');
[pConstraints,pObjective]=primalize(Constraints,-Objective);
Options=sdpsettings(Options,'removeequalities',1);
sol=optimize(pConstraints,pObjective,Options);
if sol.problem==4
  warning("YALMIP warning : %s",sol.info);
elseif sol.problem
  error("YALMIP failed : %s",sol.info);
endif

% Sanity checks
check(Constraints)

% Plot amplitude response
h=value(fliplr([C,D]));
[H,w]=freqz(h,1,nplot);
[T,w]=grpdelay(h,1,nplot);
plot(w*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.5 -60 5]);
grid("on");
strt=sprintf("KYP nonsymmetric FIR filter : \
N=%d,d=%d,fap=%g,fas=%g,Esq\\_s=%g",N,d,fap,fas,Esq_s);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot pass band amplitude, phase and delay
subplot(311)
plot(w*0.5/pi,20*log10(abs(H)));
axis([0 fap -1 1]);
grid("on");
ylabel("Amplitude(dB)");
strt=sprintf("KYP nonsymmetric FIR filter pass band : N=%d,d=%d,fap=%g",N,d,fap);
title(strt);
subplot(312)
plot(w(1:nap)*0.5/pi, ...
     unwrap(mod((w(1:nap)*d)+unwrap(arg(H(1:nap))),2*pi))/(pi))
axis([0 fap]);
grid("on");
ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
subplot(313)
[T,w]=grpdelay(h,1,nplot);
plot(w*0.5/pi,T);
ylabel("Delay(samples)");
axis([0 fap d-1 d+2]);
grid("on");
xlabel("Frequency");
print(strcat(strf,"_passband"),"-dpdflatex");
close

% Check maximum amplitude response
printf("max(abs(H(1:nap)))=%8.6f\n",max(abs(H(1:nap))));
printf("min(abs(H(1:nap)))=%8.6f\n",min(abs(H(1:nap))));
printf("max(abs(H(nap:nas)))=%8.6f\n",max(abs(H(nap:nas))));
printf("min(abs(H(nap:nas)))=%11.6g\n",min(abs(H(nap:nas))));
printf("max(abs(H(nas:end)))=%11.6g\n",max(abs(H(nas:end))));

printf("max(abs(H))=%8.6f\n",max(abs(H)));
fid=fopen(strcat(strf,"_max_abs_H.tab"),"wt");
fprintf(fid,"%6.4f",max(abs(H)));
fclose(fid);

Asq_z=max(abs(H(1:nap)-e.^(-j*w(1:nap)*d)));
printf("sqrt(max(Asq_z))=%11.6g\n",Asq_z);
fid=fopen(strcat(strf,"_max_passband_error.tab"),"wt");
fprintf(fid,"%6.4f",Asq_z);
fclose(fid);

Asq_s=max(abs(H(nas:end)));
printf("sqrt(max(Asq_s))=%11.6g\n",Asq_s);
fid=fopen(strcat(strf,"_max_stopband_error.tab"),"wt");
fprintf(fid,"%6.4f",Asq_s);
fclose(fid);

% Save results
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"N=%d %% FIR filter order\n",N);
fprintf(fid,"d=%d %% Nominal FIR filter delay\n",d);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Esq_s=%g %% Squared amplitude stop band error\n",Esq_s);
fprintf(fid,"Esq_max=%g %% Maximum overall squared amplitude\n",Esq_max);
fclose(fid);

print_polynomial(h,"h","%13.10f");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"),"%13.10f");

% Done
toc;
diary off
movefile directFIRnonsymmetric_kyp_lowpass_test.diary.tmp ...
         directFIRnonsymmetric_kyp_lowpass_test.diary;
