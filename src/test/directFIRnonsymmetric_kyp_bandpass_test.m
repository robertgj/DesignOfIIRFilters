% directFIRnonsymmetric_kyp_bandpass_test.m
% Copyright (C) 2021-2022 Robert G. Jenssen

% SDP design of a direct-form FIR bandpass filter with the KYP lemma.
% See Section VII.B.2, pp. 53-55 of "Generalised KYP Lemma: Unified
% Frequency Domain Inequalities With Design Applications", T. Iwasaki
% and S. Hara, IEEE Transactions on Automatic Control, Vol. 50, No. 1,
% January 2005, pp. 41–59
%
% Note that the YALMIP, Octave, Symbolic Toolbox and SymPy combination
% requires that the KYP constraints have rows enclosed in square brackets.

test_common;

strf="directFIRnonsymmetric_kyp_bandpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

% Band-pass filter specification
N=30;
d=10;
fasl=0.10;fapl=0.175;fapu=0.225;fasu=0.30;
Esq_z=4.66e-5;
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
c_sl=2*cos(2*pi*fasl);
Psi_sl=[0,1;1,-c_sl];
e_c=e^(j*pi*(fapu+fapl));
c_h=2*cos(pi*(fapu-fapl));
Psi_z=[0,e_c;1/e_c,-c_h];
c_su=2*cos(2*pi*fasu);
Psi_su=[0,-1;-1,c_su];

% Set up constraints
CD=sdpvar(1,N+1);
CD_d=CD-[C_d,0];

% Maximum amplitude constraint
P_max=sdpvar(N,N,"symmetric","real");
Q_max=sdpvar(N,N,"symmetric","real");
F_max=sdpvar(N+2,N+2,"symmetric","real");
F_max=[[((AB')*(kron(Phi,P_max)+kron(Psi_max,Q_max))*AB) + ...
        diag([zeros(1,N),-Esq_max]),CD']; ...
       [CD,-1]];
% Lower stop band constraint 
P_sl=sdpvar(N,N,"symmetric","real");
Q_sl=sdpvar(N,N,"symmetric","real");
F_sl=sdpvar(N+2,N+2,"symmetric","real");
F_sl=[[((AB')*(kron(Phi,P_sl)+kron(Psi_sl,Q_sl))*AB) + ...
       diag([zeros(1,N),-Esq_s]),CD']; ...
      [CD,-1]];
% Pass band constraint on the error |H(w)-e^(-j*w*d)|
P_z=sdpvar(N,N,"symmetric","real");
Q_z=sdpvar(N,N,"symmetric","real");
F_z=sdpvar(N+2,N+2,"symmetric","real");
F_z=[[((AB')*(kron(Phi,P_z)+kron(Psi_z,Q_z))*AB) + ...
      diag([zeros(1,N),-Esq_z]),CD_d']; ...
     [CD_d,-1]];
% Upper stop band constraint 
P_su=sdpvar(N,N,"symmetric","real");
Q_su=sdpvar(N,N,"symmetric","real");
F_su=sdpvar(N+2,N+2,"symmetric","real");
F_su=[[((AB')*(kron(Phi,P_su)+kron(Psi_su,Q_su))*AB) + ...
       diag([zeros(1,N),-Esq_s]),CD']; ...
      [CD,-1]];

% Solve with YALMIP
Constraints=[F_max<=0,Q_max>=0,F_z<=0,Q_z>=0,F_sl<=0,Q_sl>=0,F_su<=0,Q_su>=0];
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
if ~issymmetric(value(P_sl))
  error("P_sl not symmetric");
endif
if ~isdefinite(value(Q_sl))
  error("Q_sl not positive semi-definite");
endif
if ~isdefinite(-value(F_sl))
  error("F_sl not negative semi-definite");
endif
if ~issymmetric(value(P_su))
  error("P_su not symmetric");
endif
if ~isdefinite(value(Q_su))
  error("Q_su not positive semi-definite");
endif
if ~isdefinite(-value(F_su))
  error("F_su not negative semi-definite");
endif

% Plot amplitude response
nplot=1000;
nasl=(fasl*nplot/0.5)+1;
napl=(fapl*nplot/0.5)+1;
napu=(fapu*nplot/0.5)+1;
nasu=(fasu*nplot/0.5)+1;
h=value(fliplr(CD));
[H,w]=freqz(h,1,nplot);
if 0
ax=plotyy(w*0.5/pi,20*log10(abs(H)),w*0.5/pi,20*log10(abs(H)));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
ylabel(ax(1),"Amplitude(dB)");
axis(ax(1),[0 0.5 -0.5 0]);
axis(ax(2),[0 0.5 -50 -40]);
else
plot(w*0.5/pi,20*log10(abs(H)));
axis([0 0.5 -60 5]);
ylabel("Amplitude(dB)");
endif
xlabel("Frequency");
grid("on");
strt=sprintf("KYP non-symmetric FIR filter : \
N=%d,d=%d,fasu=%d,fapl=%g,fapu=%g,fasu=%g",N,d,fasl,fapl,fapu,fasu);
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot pass band amplitude, phase and delay
subplot(311)
plot(w*0.5/pi,20*log10(abs(H)));
axis([fapl fapu -0.05 0]);
grid("on");
ylabel("Amplitude(dB)");
strt=sprintf("N=%d,d=%d,fasu=%4.2f,fapl=%4.2f,fapu=%4.2f,fasu=%4.2f,\
Esq\\_z=%10.8f,Esq\\_s=%6.4f",N,d,fasl,fapl,fapu,fasu,Esq_z,Esq_s);
title(strt);
subplot(312)
plot(w(napl:napu)*0.5/pi, ...
     unwrap(mod((w(napl:napu)*d)+unwrap(arg(H(napl:napu))),2*pi))/(pi))
axis([fapl fapu -0.004 0.004]);
grid("on");
ylabel("Phase error(rad./$\\pi$)");
subplot(313)
[T,w]=grpdelay(h,1,nplot);
plot(w*0.5/pi,T);
ylabel("Delay(samples)");
axis([fapl fapu d-0.2 d+0.6]);
grid("on");
xlabel("Frequency");
print(strcat(strf,"_passband"),"-dpdflatex");
close

% Check squared-amplitude response
printf("Esq_max=%8.6f\n",Esq_max);
printf("max(abs(H))^2=%8.6f\n",max(abs(H))^2);
printf("max(abs(H(1:nasl)))^2=%13.6g\n",max(abs(H(1:nasl)))^2);
printf("min(abs(H(nasl:napl)))^2=%13.6g\n",min(abs(H(nasl:napl)))^2);
printf("max(abs(H(nasl:napl)))^2=%8.6f\n",max(abs(H(nasl:napl)))^2);
printf("min(abs(H(napl:napu)))^2=%13.6g\n",min(abs(H(napl:napu)))^2);
printf("max(abs(H(napl:napu)))^2=%8.6f\n",max(abs(H(napl:napu)))^2);
Asq_z=max(abs(H(napl:napu)-e.^(-j*w(napl:napu)*d)))^2;
printf("max(abs(H(napl:napu)-e.^(-j*w(napl:napu)*d)))^2=%10.8f\n",Asq_z);
fid=fopen(strcat(strf,"_max_passband_squared_error.tab"),"wt");
fprintf(fid,"%10.8f",Asq_z);
fclose(fid);
printf("max(abs(H(napu:nasu)))^2=%8.6f\n",max(abs(H(napu:nasu)))^2);
printf("min(abs(H(napu:nasu)))^2=%13.6g\n",min(abs(H(napu:nasu)))^2);
printf("max(abs(H(nasu:end)))^2=%13.6g\n",max(abs(H(nasu:end)))^2);

% Find complementary FIR lattice coefficients
hs=direct_form_scale(h(:),1,nplot);
[Hs,w]=freqz(hs,1,nplot);
[hm,g,k,kc]=complementaryFIRlattice(hs);
Asqc=complementaryFIRlatticeAsq(w,k,kc);
max_Asqc_err=max(abs(Asqc(:)-(abs(Hs(:).^2))));
if max_Asqc_err>5000*eps
  error("max(abs(Asqc-(abs(Hs.^2))))(%g)>5000*eps",max_Asqc_err);
endif
Tc=complementaryFIRlatticeT(w,k,kc);
max_Tc_err=max(abs(Tc(napl:napu)-T(napl:napu)));
if max_Tc_err>100*eps
  error("Passband max(abs(Tc-T))(%g)>100*eps",max_Tc_err);
endif

% Make a quantised noise signal with standard deviation 0.25
nsamples=2^16;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u); 

% Filter
[y yc xxk]=complementaryFIRlatticeFilter(k,kc,u);
nfpts=2048;
nppts=(0:1023);
H=crossWelch(u,y,nfpts);
Hc=crossWelch(u,yc,nfpts);
subplot(211);
plot(nppts/nfpts,20*log10(abs(H)),"linestyle","-", ...
     nppts/nfpts,20*log10(abs(Hc)),"linestyle","-.");
axis([0 0.5 -50 10])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
legend("H","Hc");
legend("location","east");
legend("boxoff");
legend("left");
strt=sprintf("KYP FIR lattice filter simulated response : \
N=%d,d=%d,fasu=%d,fapl=%g,fapu=%g,fasu=%g",N,d,fasl,fapl,fapu,fasu);
title(strt);
subplot(212);
plot(nppts/nfpts,abs(abs(H).^2+abs(Hc).^2));
axis([0 0.5 0.99 1.01])
grid("on");
xlabel("Frequency")
ylabel("|H|^2+|Hc|^2");
print(strcat(strf,"_k_kc_response"),"-dpdflatex");
close

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
print_polynomial(k,"k","%11.8f");
print_polynomial(k,"k",strcat(strf,"_k_coef.m"),"%11.8f");
print_polynomial(kc,"kc","%11.8f");
print_polynomial(kc,"kc",strcat(strf,"_kc_coef.m"),"%11.8f");

eval(sprintf("save %s.mat N d fasl fapl fapu fasu Esq_z Esq_s Esq_max h k kc",strf));

% Done
toc;
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));
