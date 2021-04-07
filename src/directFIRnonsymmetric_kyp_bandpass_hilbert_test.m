% directFIRnonsymmetric_kyp_bandpass_hilbert_test.m
% Copyright (C) 2021 Robert G. Jenssen
%
% SDP design of a direct-form FIR bandpass Hilbert filter with the KYP
% lemma. The pass band response is set to -je^{-j*w*d}.
% See Section VII.B.2, pp. 53-55 of "Generalised KYP Lemma: Unified
% Frequency Domain Inequalities With Design Applications", T. Iwasaki
% and S. Hara, IEEE Transactions on Automatic Control, Vol. 50, No. 1,
% January 2005, pp. 41–59.
%
% Note that the YALMIP, Octave, Symbolic Toolbox and SymPy combination
% requires that the KYP constraints have rows enclosed in square brackets.

test_common;

delete("directFIRnonsymmetric_kyp_bandpass_hilbert_test.diary");
delete("directFIRnonsymmetric_kyp_bandpass_hilbert_test.diary.tmp");
diary directFIRnonsymmetric_kyp_bandpass_hilbert_test.diary.tmp

pkg load symbolic optim

tic;

strf="directFIRnonsymmetric_kyp_bandpass_hilbert_test";

% Band-pass filter specification
N=40;
d=10;
fasl=0.10;fapl=0.175;fapu=0.225;fasu=0.30;
Esq_z=2.27e-5;
Esq_s=1e-4;
Esq_max=1;

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
Phi=[-1,0;0,1];
C_d=zeros(1,N);
C_d(N-d+1)=-j;
c_sl=2*cos(2*pi*fasl);
e_c=e^(j*pi*(fapu+fapl));
c_h=2*cos(pi*(fapu-fapl));
c_su=2*cos(2*pi*fasu);

% Set up constraints
C=sdpvar(1,N);
D=sdpvar(1,1);
% Maximum amplitude constraint
P_max=sdpvar(N,N,"symmetric");
Q_max=sdpvar(N,N,"symmetric");
F_max=sdpvar(N+2,N+2,"symmetric");
F_max=[[((AB')*(kron(P_max,Phi)+kron(Q_max,[0,1;1,2]))*AB) + ...
        diag([zeros(1,N),-Esq_max]),[C,D]']; ...
       [C,D,-1]];
% Lower stop band constraint 
P_sl=sdpvar(N,N,'symmetric');
Q_sl=sdpvar(N,N,'symmetric');
F_sl=sdpvar(N+2,N+2,'symmetric');
F_sl=[[((AB')*(kron(P_sl,Phi)+kron(Q_sl,[0,1;1,-c_sl]))*AB) + ...
       diag([zeros(1,N),-Esq_s]),[C,D]']; ...
      [C,D,-1]];
% Pass band constraint on the error |H(w)-e^(-j*w*d)|
P_z=sdpvar(N,N,'hermitian','complex');
Q_z=sdpvar(N,N,'hermitian','complex');
F_z=sdpvar(N+2,N+2,'hermitian','complex');
F_z=[[((AB')*(kron(P_z,Phi)+kron(Q_z,[0,1/e_c;e_c,-c_h]))*AB) + ...
      diag([zeros(1,N),-Esq_z]),[C-C_d,D]']; ...
     [C-C_d,D,-1]];
% Upper stop band constraint 
P_su=sdpvar(N,N,'symmetric');
Q_su=sdpvar(N,N,'symmetric');
F_su=sdpvar(N+2,N+2,'symmetric');
F_su=[[((AB')*(kron(P_su,Phi)+kron(Q_su,[0,-1;-1,c_su]))*AB) + ...
       diag([zeros(1,N),-Esq_s]),[C,D]']; ...
      [C,D,-1]];

% Solve with YALMIP
Constraints=[F_max<=0,Q_max>=0,F_z<=0,Q_z>=0,F_sl<=0,Q_sl>=0,F_su<=0,Q_su>=0];
Options=sdpsettings('solver','sedumi');
sol=optimize(Constraints,[],Options);
if sol.problem
  error("YALMIP failed : %s",sol.info);
endif

% Sanity checks
check(Constraints)

% Extract impulse response
h=value(fliplr([C,D]));

% Plot amplitude response
nplot=1000;
nasl=(fasl*nplot/0.5)+1;
napl=(fapl*nplot/0.5)+1;
napu=(fapu*nplot/0.5)+1;
nasu=(fasu*nplot/0.5)+1;

[H,w]=freqz(h,1,nplot);
plot(w*0.5/pi,20*log10(abs(H)));
axis([0 0.5 -60 5]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
grid("on");
strt=sprintf("KYP non-symmetric FIR filter : \
N=%d,d=%d,fasu=%d,fapl=%g,fapu=%g,fasu=%g",N,d,fasl,fapl,fapu,fasu);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
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
     mod(((w(napl:napu)*d)+unwrap(arg(H(napl:napu)))),2*pi)/pi)
axis([fapl fapu 1.5+0.002*[-1 1]]);
grid("on");
ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
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

% Save results
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"N=%d %% FIR filter order\n",N);
fprintf(fid,"d=%d %% Nominal FIR filter delay\n",d);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"Esq_z=%g %% Squared amplitude pass band - delay error\n",Esq_z);
fprintf(fid,"Esq_s=%g %% Squared amplitude stop band error\n",Esq_s);
fclose(fid);

print_polynomial(h,"h","%13.10f");
print_polynomial(h,"h",strcat(strf,"_h_coef.m"),"%13.10f");

save directFIRnonsymmetric_kyp_bandpass_hilbert_test.mat ...
     N d fasl fapl fapu fasu Esq_z Esq_s Esq_max h

% Done
toc;
diary off
movefile directFIRnonsymmetric_kyp_bandpass_hilbert_test.diary.tmp ...
         directFIRnonsymmetric_kyp_bandpass_hilbert_test.diary;
