% directFIRnonsymmetric_kyp_lowpass_alternate_test.m
% Copyright (C) 2021 Robert G. Jenssen
%
% SDP design of a direct-form FIR lowpass filter with the KYP lemma.
% See Section VII.B.2, pp. 53-55 of "Generalised KYP Lemma: Unified
% Frequency Domain Inequalities With Design Applications", T. Iwasaki
% and S. Hara, IEEE Transactions on Automatic Control, Vol. 50, No. 1,
% January 2005, pp. 41–59
%
% Note that the YALMIP, Octave, Symbolic Toolbox and SymPy combination
% requires that the KYP constraints have rows enclosed in square brackets.
%
% I was not able to reproduce the example of Iwasaki and Hara
%
% Optimising Esq_z causes numerical problems and failure to complete.

test_common;

delete("directFIRnonsymmetric_kyp_lowpass_alternate_test.diary");
delete("directFIRnonsymmetric_kyp_lowpass_alternate_test.diary.tmp");
diary directFIRnonsymmetric_kyp_lowpass_alternate_test.diary.tmp

pkg load symbolic optim

tic;

strf="directFIRnonsymmetric_kyp_lowpass_alternate_test";

% Low-pass filter specification
N=30;fap=0.15;d=10;fas=0.20;
optimise_Esq_z=false;
if optimise_Esq_z
  Esq_z=sdpvar(1,1);
  Esq_s=1e-4;
elseif 0
  % Gives epsilon_p=0.056869 (as in I+W example), epsilon_s=0.01342
  Esq_z=0.0569^2;
  Esq_s=1.8e-4;
else
  % Gives epsilon_p=0.08776, epsilon_s=0.010
  Esq_z=0.09^2;
  Esq_s=1.16725e-4;
endif

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
% Pass band constraint on the error |H(w)-e^(-j*w*d)|
P_z=sdpvar(N,N,'symmetric');
Q_z=sdpvar(N,N,'symmetric');
F_z=sdpvar(N+2,N+2,'symmetric');
if 1
  F_z=[[((AB')*[-P_z, Q_z; Q_z,P_z-(c_p*Q_z)]*AB)+ ...
        diag([zeros(1,N),-Esq_z]),[C-C_d,D]']; ...
       [C-C_d,D,-1]];
else
  F_z=[[-A'*P_z*A+A'*Q_z+Q_z*A+P_z-c_p*Q_z, -A'*P_z*B+Q_z*B; ...
        -B'*P_z*A+B'*Q_z,                   -B'*P_z*B-Esq_z],[C-C_d,D]'; ...
       [C-C_d,D,-1]];
endif
% Stop band constraint 
P_s=sdpvar(N,N,'symmetric');
Q_s=sdpvar(N,N,'symmetric');
F_s=sdpvar(N+2,N+2,'symmetric');
F_s=[[((AB')*[-P_s,-Q_s;-Q_s,P_s+(c_s*Q_s)]*AB)+ ...
      diag([zeros(1,N),-Esq_s]),[C,D]']; ...
     [C,D,-1]];

% Solve with YALMIP
Constraints=[Esq_z>=0,F_z<=0,Q_z>=0,F_s<=0,Q_s>=0];
if optimise_Esq_z
  Objective=Esq_z;
else
  Objective=[];
endif
Options=sdpsettings('solver','sedumi');
sol=optimize(Constraints,Objective,Options);
if sol.problem
  warning("YALMIP failed : %s",sol.info);
endif

% Sanity checks
check(Constraints)
if ~optimise_Esq_z
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
endif

% Plot amplitude response
vEsq_z=value(Esq_z)
h=value(fliplr([C,D]));
[H,w]=freqz(h,1,nplot);
plot(w*0.5/pi,20*log10(abs(H)));
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.5 -60 5]);
grid("on");
strt=sprintf("KYP non-symmetric FIR filter : \
N=%d,d=%d,fap=%g,Esq\\_z=%g,fas=%g,Esq\\_s=%g",N,d,fap,value(Esq_z),fas,Esq_s);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot phase
plot(w*0.5/pi, unwrap(mod((w*d)+unwrap(arg(H)),2*pi))/(pi))
grid("on");
ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
xlabel("Frequency");
print(strcat(strf,"_phase"),"-dpdflatex");
close

% Check maximum squared-amplitude response
printf("sqrt(Esq_s)=%8.6g\n",sqrt(Esq_s));
if optimise_Esq_z
  printf("sqrt(Esq_z)=%8.6g\n",sqrt(value(Esq_z)));
else
  printf("sqrt(Esq_z)=%8.6g\n",sqrt(Esq_z));
endif
printf("max(sqrt(Asq_z))=%11.6g\n",max(abs(H(1:nap)-e.^(-j*w(1:nap)*d))));
printf("max(abs(H).^2)=%8.6f\n",max(abs(H).^2));
printf("max(abs(H(1:nap)).^2)=%8.6f\n",max(abs(H(1:nap)).^2));
printf("min(abs(H(1:nap)).^2)=%8.6f\n",min(abs(H(1:nap)).^2));
printf("max(abs(H(nap:nas)).^2)=%8.6f\n",max(abs(H(nap:nas)).^2));
printf("min(abs(H(nap:nas)).^2)=%11.6g\n",min(abs(H(nap:nas)).^2));
printf("max(abs(H(nas:end)).^2)=%11.6g\n",max(abs(H(nas:end)).^2));

if ~optimise_Esq_z
  % Sanity check on pass band minus delay squared-amplitude response using KYP
  vP_z=value(P_z);
  vQ_z=value(Q_z);
  vF_z_a=[[((AB')*[-vP_z,vQ_z;vQ_z,vP_z-(c_p*vQ_z)]*AB)+ ...
           [zeros(N,N+1);[zeros(1,N),-value(Esq_z)]],(fliplr(h-hz))']; ...
          [fliplr(h-hz),-1]];
  if ~isdefinite(-vF_z_a)
    error("vF_z_a not negative semi-definite");
  endif
  if norm(vF_z_a-value(F_z))>eps
    error("norm(vF_z_a-value(F_z))>eps");
  endif
  CDd=[fliplr(h-hz);zeros(1,N),1];
  vF_z_b=[((AB')*[-vP_z,vQ_z;vQ_z,vP_z-(c_p*vQ_z)]*AB)]+ ...
         [(CDd')*[1 0;0 -value(Esq_z)]*CDd];
  if ~isdefinite(-vF_z_b)
    error("vF_z_b not negative semi-definite");
  endif
endif

% Save results
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"N=%d %% FIR filter order\n",N);
fprintf(fid,"d=%d %% Nominal FIR filter delay\n",d);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
if ~optimise_Esq_z
  fprintf(fid,"Esq_z=%g %% Squared response-delay pass band error\n",Esq_z);
endif
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Esq_s=%g %% Squared amplitude stop band error\n",Esq_s);
fclose(fid);

print_polynomial(h,"h","%13.10f");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"),"%13.10f");

save directFIRnonsymmetric_kyp_lowpass_alternate_test.mat ...
     N d fap fas Esq_s h

% Done
toc;
diary off
movefile directFIRnonsymmetric_kyp_lowpass_alternate_test.diary.tmp ...
         directFIRnonsymmetric_kyp_lowpass_alternate_test.diary;
