% directFIRnonsymmetric_kyp_union_bandpass_test.m
% Copyright (C) 2021 Robert G. Jenssen
%
% SDP design of a direct-form FIR bandpass filter with the KYP
% lemma. The pass band response is set to e^{-j*w*d}. The stop band
% response is specified as the union of the upper and lower stop bands.
% See:
% [1] "Generalised KYP Lemma: Unified Frequency Domain Inequalities With
% Design Applications", T. Iwasaki and S. Hara, IEEE Transactions on
% Automatic Control, Vol. 50, No. 1, January 2005, pp. 41–59.
% [2] GENERALIZING THE KYP LEMMA TO MULTIPLE FREQUENCY INTERVALS, G. Pipeleers,
% T. Iwasaki and S. Hara, SIAM Journal on Control and Optimization, 2014,
% Vol. 52, No. 6, pp. 3618--3638
%
% Note that the YALMIP, Octave, Symbolic Toolbox and SymPy combination
% requires that the KYP constraints have rows enclosed in square brackets.

test_common;

delete("directFIRnonsymmetric_kyp_union_bandpass_test.diary");
delete("directFIRnonsymmetric_kyp_union_bandpass_test.diary.tmp");
diary directFIRnonsymmetric_kyp_union_bandpass_test.diary.tmp

pkg load symbolic optim

tic;

strf="directFIRnonsymmetric_kyp_union_bandpass_test";

% Band-pass filter specification
N=30;
d=15;
fasl=0.05;fapl=0.15;fapu=0.25;fasu=0.35;
Esq_z=(1e-1)^2;
Esq_s=(1e-3)^2;
Esq_max=1.1;

% Common constants
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];

% Set up constraints
C=sdpvar(1,N);
D=sdpvar(1,1);

% Maximum amplitude constraint
P_max=sdpvar(N,N,"symmetric");
Q_max=sdpvar(N,N,"symmetric");
F_max=sdpvar(N+2,N+2,"symmetric");
F_max=[[((AB')*(kron(P_max,[-1,0;0,1])+kron(Q_max,[0,1;1,2]))*AB) + ...
        diag([zeros(1,N),-Esq_max]),[C,D]']; ...
       [C,D,-1]];

% Pass band constraint on the error |H(w)-e^(-j*w*d)|
e_c=e^(j*pi*(fapu+fapl));
c_h=2*cos(pi*(fapu-fapl));
C_d=zeros(1,N);
C_d(N-d+1)=1;
P_z=sdpvar(N,N,'hermitian','complex');
Q_z=sdpvar(N,N,'hermitian','complex');
F_z=sdpvar(N+2,N+2,'hermitian','complex');
F_z=[[((AB')*(kron(P_z,[-1,0;0,1])+kron(Q_z,[0,1/e_c;e_c,-c_h]))*AB) + ...
      diag([zeros(1,N),-Esq_z]),[C-C_d,D]']; ...
     [C-C_d,D,-1]];

% Constants for SDP constraints on the stop band
n=rows(A);m=columns(B);l=2;
Phir=[0,j;-j,0];
Psir=[0,1;1,0];
beta1=tan(pi*fasl);
alpha2=tan(pi*fasu);
a= [1 -alpha2  0]';
b=-[0  1      -beta1]';
T=[-a,b]';
Phi=T'*Phir*T;
Psi=T'*Psir*T;
R=[1,-beta1;-beta1,alpha2*beta1];
% Sanity check on R
Jl=[eye(l),zeros(l,1); ...
    zeros(l,1),eye(l)];
if max(max(abs(Phi-(Jl'*kron(Phir,R)*Jl))))~=0
  error("max(max(abs(Phi-(Jl'*kron(Phir,R)*Jl))))~=0");
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
% Sanity check on G3AB (see p.3622 of [1]
F2AB=[A*A,A*B,B; ...
      A,B,zeros(size(B)); ...
      eye(size(A)),zeros(size(B)),zeros(size(B))];
F20I=[0,0,1;0,1,0;1,0,0];
G3AB=(kron(eye(3),[eye(n);zeros(m,n)])*[F2AB,zeros(n*3,m)]) + ...
     (kron(eye(3),[zeros(n,m);eye(m)])*[zeros(m*3,n),F20I]);
G3AB_alt=[A*A,A*B,B,zeros(n,m); ...
          zeros(m,n+((3-1)*m)),eye(m); ...
          A,B,zeros(n,(3-1)*m); ...
          zeros(m,n+m),eye(m),zeros(m); ...
          eye(n),zeros(n,3*m); ...
          zeros(m,n),eye(m),zeros(m,(3-1)*m)];
if max(max(abs(G3AB-G3AB_alt)))~=0
  error("max(max(abs(G3AB-G3AB_alt)))~=0")
endif
    
% Union of upper and lower stop band constraints
P_slu=sdpvar(N,N,'hermitian','complex');
Q_slu=sdpvar(N,N,'symmetric');
F_slu=sdpvar(N+4,N+4,'symmetric');
F_slu=[[((F2AB')*(kron(P_slu,Phi)+kron(Q_slu,Psi))*F2AB) + ...
        (G2AB'*kron(R,diag([zeros(1,N),-Esq_s]))*G2AB), ...
        (kron(eye(2),[C,D])*G2AB)']; ...
       [kron(eye(2),[C,D])*G2AB,kron(R,-1)]];

% Solve with YALMIP
Constraints=[F_max<=0,Q_max>=0,F_z<=0,Q_z>=0,F_slu<=0,Q_slu>=0];
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
axis([0 0.5 -30 5]);
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
axis([fapl fapu -0.8 0]);
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

save directFIRnonsymmetric_kyp_union_bandpass_test.mat ...
     N d fasl fapl fapu fasu Esq_z Esq_s Esq_max h

% Done
toc;
diary off
movefile directFIRnonsymmetric_kyp_union_bandpass_test.diary.tmp ...
         directFIRnonsymmetric_kyp_union_bandpass_test.diary;
