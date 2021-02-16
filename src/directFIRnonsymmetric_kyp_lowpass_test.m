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

test_common;

delete("directFIRnonsymmetric_kyp_lowpass_test.diary");
delete("directFIRnonsymmetric_kyp_lowpass_test.diary.tmp");
diary directFIRnonsymmetric_kyp_lowpass_test.diary.tmp

pkg load symbolic optim

tic;

strf="directFIRnonsymmetric_kyp_lowpass_test";

% Low-pass filter specification
N=30;fap=0.1;d=10;Esq_z=1e-6;fas=0.2;Esq_s=1e-4;Esq_max=1;

% Common constants
nplot=1000;
nap=(fap*nplot/0.5)+1;
nas=(fas*nplot/0.5)+1;
hz=zeros(1,N+1);
hz(d+1)=1;
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
C_d=zeros(1,N);
C_d(N-d+1)=1;
c_p=2*cos(2*pi*fap);
c_s=2*cos(2*pi*fas);

% Set up constraints
C=sdpvar(1,N);
D=sdpvar(1,1);
% Maximum amplitude constraint
P_max=sdpvar(N,N,"symmetric");
Q_max=sdpvar(N,N,"symmetric");
F_max=sdpvar(N+2,N+2,"symmetric");
F_max=[[((AB')*[-P_max,Q_max;Q_max,P_max+(2*Q_max)]*AB)+ ...
        [zeros(N,N+1);[zeros(1,N),-Esq_max]],[C,D]']; ...
       [C,D,-1]];
% Pass band constraint on the error |H(w)-e^(-j*w*d)|
P_z=sdpvar(N,N,'symmetric');
Q_z=sdpvar(N,N,'symmetric');
F_z=sdpvar(N+2,N+2,'symmetric');
F_z=[[((AB')*[-P_z, Q_z; Q_z,P_z-(c_p*Q_z)]*AB)+ ...
      [zeros(N,N+1);[zeros(1,N),-Esq_z]],[C-C_d,D]']; ...
     [C-C_d,D,-1]];
% Stop band constraint 
P_s=sdpvar(N,N,'symmetric');
Q_s=sdpvar(N,N,'symmetric');
F_s=sdpvar(N+2,N+2,'symmetric');
F_s=[[((AB')*[-P_s,-Q_s;-Q_s,P_s+(c_s*Q_s)]*AB)+ ...
      [zeros(N,N+1);[zeros(1,N),-Esq_s]],[C,D]']; ...
     [C,D,-1]];

% Solve with YALMIP
Constraints=[F_max<=0,Q_max>=0,F_z<=0,Q_z>=0,F_s<=0,Q_s>=0];
Options=sdpsettings('solver','sedumi');
sol=optimize(Constraints,[],Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif

% Sanity checks
check(Constraints)
if ~isdefinite(value(Q_max))
  error("Q_max not positive semi-definite");
endif
if ~isdefinite(-value(F_max))
  error("F_max not negative semi-definite");
endif
if ~isdefinite(value(Q_z))
  error("Q_z not positive semi-definite");
endif
if ~isdefinite(-value(F_z))
  error("F_z not negative semi-definite");
endif
if ~isdefinite(value(Q_s))
  error("Q_s not positive semi-definite");
endif
if ~isdefinite(-value(F_s))
  error("F_s not negative semi-definite");
endif

% Plot amplitude response
h=value(fliplr([C,D]));
[H,w]=freqz(h,1,nplot);
[T,w]=grpdelay(h,1,nplot);
plot(w*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.5 -60 5]);
grid("on");
strt=sprintf("KYP non-symmetric FIR filter : \
N=%d,d=%d,fap=%g,Esq\\_z=%g,fas=%g,Esq\\_s=%g",N,d,fap,Esq_z,fas,Esq_s);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot pass band amplitude, phase and delay
subplot(311)
plot(w*0.5/pi,20*log10(abs(H)));
axis([0 fap -0.01 0]);
grid("on");
ylabel("Amplitude(dB)");
strt=sprintf("KYP non-symmetric FIR filter pass band : \
N=%d,d=%d,fap=%g,Esq\\_z=%g",N,d,fap,Esq_z);
title(strt);
subplot(312)
plot(w(1:nap)*0.5/pi, ...
     unwrap(mod((w(1:nap)*d)+unwrap(arg(H(1:nap))),2*pi))/(pi))
axis([0 fap -0.0002 0.0002]);
grid("on");
ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
subplot(313)
[T,w]=grpdelay(h,1,nplot);
plot(w*0.5/pi,T);
ylabel("Delay(samples)");
axis([0 fap d-0.1 d+0.1]);
grid("on");
xlabel("Frequency");
print(strcat(strf,"_passband"),"-dpdflatex");
close

% Check maximum squared-amplitude response
printf("Esq_max=%8.6f\n",Esq_max);
printf("max(abs(H).^2)=%8.6f\n",max(abs(H).^2));
printf("max(abs(H(1:nap)).^2)=%8.6f\n",max(abs(H(1:nap)).^2));
printf("min(abs(H(1:nap)).^2)=%8.6f\n",min(abs(H(1:nap)).^2));
printf("max(abs(H(nap:nas)).^2)=%8.6f\n",max(abs(H(nap:nas)).^2));
printf("min(abs(H(nap:nas)).^2)=%8.6f\n",min(abs(H(nap:nas)).^2));
printf("max(abs(H(nas:end)).^2)=%13.6g\n",max(abs(H(nas:end)).^2));

% Save results
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"N=%d %% FIR filter order\n",N);
fprintf(fid,"d=%d %% Nominal FIR filter delay\n",d);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"Esq_z=%g %% Squared amplitude pass band - delay error\n",Esq_z);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Esq_s=%g %% Squared amplitude stop band error\n",Esq_s);
fprintf(fid,"Esq_max=%g %% Overall maximum squared amplitude\n",Esq_max);
fclose(fid);

print_polynomial(h,"h","%13.10f");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"),"%13.10f");

save directFIRnonsymmetric_kyp_lowpass_test.mat ...
     N d fap fas Esq_z Esq_s Esq_max h

% Done
toc;
diary off
movefile directFIRnonsymmetric_kyp_lowpass_test.diary.tmp ...
         directFIRnonsymmetric_kyp_lowpass_test.diary;
