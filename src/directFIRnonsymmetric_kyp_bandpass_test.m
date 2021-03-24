% directFIRnonsymmetric_kyp_bandpass_test.m
% Copyright (C) 2021 Robert G. Jenssen

% SDP design of a direct-form FIR bandpass filter with the KYP lemma.
% See Section VII.B.2, pp. 53-55 of "Generalised KYP Lemma: Unified
% Frequency Domain Inequalities With Design Applications", T. Iwasaki
% and S. Hara, IEEE Transactions on Automatic Control, Vol. 50, No. 1,
% January 2005, pp. 41–59
%
% Note that the YALMIP, Octave, Symbolic Toolbox and SymPy combination
% requires that the KYP constraints have rows enclosed in square brackets.

test_common;

delete("directFIRnonsymmetric_kyp_bandpass_test.diary");
delete("directFIRnonsymmetric_kyp_bandpass_test.diary.tmp");
diary directFIRnonsymmetric_kyp_bandpass_test.diary.tmp

pkg load symbolic optim

tic;

strf="directFIRnonsymmetric_kyp_bandpass_test";

% Band-pass filter specification
N=30;
d=10;
fasl=0.10;fapl=0.175;fapu=0.225;fasu=0.30;
Esq_z=(0.01/sqrt(2))^2;
Esq_s=(0.01)^2;
Esq_max=1;

% Common constants
nplot=1000;
nasl=(fasl*nplot/0.5)+1;
napl=(fapl*nplot/0.5)+1;
napu=(fapu*nplot/0.5)+1;
nasu=(fasu*nplot/0.5)+1;
hz=zeros(1,N+1);
hz(d+1)=1;
A=[zeros(N-1,1),eye(N-1);zeros(1,N)];
B=[zeros(N-1,1);1];
AB=[A,B;eye(N),zeros(N,1)];
C_d=zeros(1,N);
C_d(N-d+1)=1;
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
F_max=[[((AB')*[-P_max,Q_max;Q_max,P_max+(2*Q_max)]*AB) + ...
        diag([zeros(1,N),-Esq_max]),[C,D]']; ...
       [C,D,-1]];
% Lower stop band constraint 
P_sl=sdpvar(N,N,'symmetric');
Q_sl=sdpvar(N,N,'symmetric');
F_sl=sdpvar(N+2,N+2,'symmetric');
F_sl=[[((AB')*[-P_sl,Q_sl;Q_sl,P_sl-(c_sl*Q_sl)]*AB) + ...
       diag([zeros(1,N),-Esq_s]),[C,D]']; ...
      [C,D,-1]];
% Pass band constraint on the error |H(w)-e^(-j*w*d)|
P_z=sdpvar(N,N,'symmetric');
Q_z=sdpvar(N,N,'symmetric');
F_z=sdpvar(N+2,N+2,'hermitian','complex');
F_z=[[((AB')*[-P_z,Q_z/e_c;e_c*Q_z,P_z-(c_h*Q_z)]*AB) + ...
      diag([zeros(1,N),-Esq_z]),[C-C_d,D]']; ...
     [C-C_d,D,-1]];
% Upper stop band constraint 
P_su=sdpvar(N,N,'symmetric');
Q_su=sdpvar(N,N,'symmetric');
F_su=sdpvar(N+2,N+2,'symmetric');
F_su=[[((AB')*[-P_su,-Q_su;-Q_su,P_su+(c_su*Q_su)]*AB) + ...
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
if ~isdefinite(value(Q_sl))
  error("Q_sl not positive semi-definite");
endif
if ~isdefinite(-value(F_sl))
  error("F_sl not negative semi-definite");
endif
if ~isdefinite(value(Q_su))
  error("Q_su not positive semi-definite");
endif
if ~isdefinite(-value(F_su))
  error("F_su not negative semi-definite");
endif

% Plot amplitude response
h=value(fliplr([C,D]));
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
strt=sprintf("KYP non-symmetric FIR filter pass band : \
N=%d,d=%d,fasu=%d,fapl=%g,fapu=%g,fasu=%g",N,d,fasl,fapl,fapu,fasu);
title(strt);
subplot(312)
plot(w(napl:napu)*0.5/pi, ...
     unwrap(mod((w(napl:napu)*d)+unwrap(arg(H(napl:napu))),2*pi))/(pi))
axis([fapl fapu -0.004 0.004]);
grid("on");
ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
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
printf("max(abs(H).^2)=%8.6f\n",max(abs(H).^2));
printf("max(abs(H(1:nasl)).^2)=%13.6g\n",max(abs(H(1:nasl)).^2));
printf("min(abs(H(nasl:napl)).^2)=%13.6g\n",min(abs(H(nasl:napl)).^2));
printf("max(abs(H(nasl:napl)).^2)=%8.6f\n",max(abs(H(nasl:napl)).^2));
printf("min(abs(H(napl:napu)).^2)=%13.6g\n",min(abs(H(napl:napu)).^2));
printf("max(abs(H(napl:napu)).^2)=%8.6f\n",max(abs(H(napl:napu)).^2));
printf("max(abs(H(napu:nasu)).^2)=%8.6f\n",max(abs(H(napu:nasu)).^2));
printf("min(abs(H(napu:nasu)).^2)=%13.6g\n",min(abs(H(napu:nasu)).^2));
printf("max(abs(H(nasu:end)).^2)=%13.6g\n",max(abs(H(nasu:end)).^2));

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

save directFIRnonsymmetric_kyp_bandpass_test.mat ...
     N d fasl fapl fapu fasu Esq_z Esq_s Esq_max h k kc

% Done
toc;
diary off
movefile directFIRnonsymmetric_kyp_bandpass_test.diary.tmp ...
         directFIRnonsymmetric_kyp_bandpass_test.diary;

% Alternative designs:
%{
d=10;N=60;
h = [ -0.0101524800, -0.0045820085,  0.0060020090, -0.0019523710, ... 
       0.0072702106,  0.0560496533,  0.0323690492, -0.1174426199, ... 
      -0.1618336359,  0.0721369956,  0.2750502197,  0.0897053578, ... 
      -0.2272817925, -0.1994834657,  0.0655459819,  0.1353478075, ... 
       0.0165400694, -0.0076938320,  0.0344056996, -0.0223580636, ... 
      -0.0795207406, -0.0174152565,  0.0413549928,  0.0119804918, ... 
      -0.0010236427,  0.0291580248,  0.0120281184, -0.0301877264, ... 
      -0.0178581511,  0.0058716624, -0.0098713103, -0.0097480130, ... 
       0.0227239978,  0.0222657336, -0.0068383637, -0.0065090071, ... 
       0.0038819511, -0.0127394185, -0.0188827595,  0.0066996512, ... 
       0.0176102395,  0.0021048518, -0.0008637890,  0.0065539802, ... 
      -0.0033498717, -0.0138489777, -0.0034234376,  0.0067467907, ... 
       0.0020102282, -0.0000152460,  0.0048100775,  0.0019963243, ... 
      -0.0048063157, -0.0032980779,  0.0009832650,  0.0001794255, ... 
      -0.0005743571,  0.0015155068,  0.0015629505, -0.0005108670, ... 
      -0.0008307858 ];

% Time taken : 536 seconds
% eqs m = 14701, order n = 551, dim = 41309, blocks = 9
% nnz(A) = 60157 + 0, nnz(ADA) = 55372201, nnz(L) = 27693451

d=15;N=60;
h = [ -0.0026948092, -0.0023808381,  0.0083110207,  0.0130500037, ... 
      -0.0055256522, -0.0197229297, -0.0041421387,  0.0014200059, ... 
      -0.0180542126,  0.0146846110,  0.0923320897,  0.0436638802, ... 
      -0.1444702892, -0.1758440751,  0.0759949239,  0.2558231474, ... 
       0.0748962218, -0.1859735338, -0.1530674008,  0.0472869747, ... 
       0.0969308557,  0.0155379865, -0.0107251110,  0.0084170503, ... 
      -0.0100439301, -0.0260265409, -0.0034555804,  0.0072416816, ... 
      -0.0038100103,  0.0035870493,  0.0150390660,  0.0026983385, ... 
      -0.0050426701,  0.0042149354, -0.0030247984, -0.0198676437, ... 
      -0.0073062108,  0.0167809829,  0.0124216206, -0.0026308478, ... 
       0.0001316748,  0.0022495051, -0.0093775548, -0.0108350995, ... 
       0.0039162768,  0.0100023280,  0.0021380374, -0.0021731244, ... 
      -0.0001845161, -0.0008153335, -0.0024520942, -0.0005997109, ... 
       0.0013928422,  0.0008970480, -0.0000122272, -0.0003174551, ... 
      -0.0002639201,  0.0003503883,  0.0005868005, -0.0002241161, ... 
      -0.0006732924 ];
% Time taken : 611 seconds

% d=20;N=80
%}
