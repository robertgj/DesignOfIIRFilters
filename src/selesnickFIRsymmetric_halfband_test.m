% selesnickFIRsymmetric_halfband_test.m
% Copyright (C) 2020-2021 Robert G. Jenssen

test_common;

delete("selesnickFIRsymmetric_halfband_test.diary");
delete("selesnickFIRsymmetric_halfband_test.diary.tmp");
diary selesnickFIRsymmetric_halfband_test.diary.tmp

strf="selesnickFIRsymmetric_halfband_test";

%  
% Initialise
%
nplot=4000;
maxiter=100;
tol=1e-10;
verbose=true;

%
% Filter design
%

% Specification
nf=2000;M=199;delta=1e-6;ft=0.25;At=0.5;
strt=sprintf("Selesnick-Burrus Hofstetter half-band : nf=%d,M=%d,delta=%g",
             nf,M,delta);

% Filter design
[hM,fext,fiter,feasible]= ...
selesnickFIRsymmetric_lowpass(M,delta,delta,ft,At,nf,maxiter,tol,verbose);
if feasible==false
  error("hM not feasible");
endif

% Check even coefficients are 0
if norm(hM(2:2:M))>tol
  error("norm(hM(2:2:M))>tol");
endif
hM(2:2:M)=0;

% Show extrema
Aext=directFIRsymmetricA(2*pi*fext,hM);
print_polynomial(fext,"fext","%13.10f");
print_polynomial(Aext,"Aext","%13.10f");

% Check transition amplitude
wt=2*pi*ft;
Atrans=directFIRsymmetricA(wt,hM);
if abs(Atrans-At)>tol
  error("abs(Atrans-At)>tol");
endif

%
% Plot solution
%
F=0.5*(0:nplot)'/nplot;
wa=(2*pi*F);
A=directFIRsymmetricA(wa,hM);
plot(F,20*log10(abs(A)))
axis([0 0.5 (20*log10(delta)-10) 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
nat=ceil(nplot*ft/0.5)+1;
ax=plotyy(F(1:nat),20*log10(abs(A(1:nat))), ...
          F(nat:end),20*log10(abs(A(nat:end))));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
ylabel(ax(1),"Amplitude(dB)");
xlabel("Frequency");
axis(ax(1),[0 0.5 -1e-5 1e-5]);
axis(ax(2),[0 0.5 -130 -110]);
title(strt);
grid("on");
print(strcat(strf,"_dual"),"-dpdflatex");
close

% Plot zeros
zplane(roots([hM;flipud(hM(1:(end-1)))]));
title(strt);
grid("on");
print(strcat(strf,"_zeros"),"-dpdflatex");
close

%
% Design corresponding Hilbert filter
% Compare with : b=remez(400,2*[0.01 0.49], [1 1],[1],"hilbert");
%
% Filter design
if mod(M,2)==0
  error("Expected M odd!");
endif
if any(abs(hM(2:2:M))>tol)
  error("Expected hM to be a half-band filter!");
endif
altm1=zeros((2*M)+1,1);
altm1(1:2:end)=((-1).^(0:M))';
hhilbert=2*[hM(1:M);0;hM(M:-1:1)].*altm1;
Hhilbert=freqz(hhilbert,1,wa);
if norm(real(Hhilbert.*exp(j*wa*M)))>tol
  error("norm(real(Hhilbert.*exp(j*wa*M)))>tol");
endif
subplot(211)
plot(F,20*log10(imag(Hhilbert.*exp(j*wa*M))));
axis([0 0.5 -2e-5 2e-5]);
ylabel("Amplitude(dB)");
grid("on");
strt=sprintf("Selesnick-Burrus Hofstetter Hilbert : M=%d,delta=%g",M,delta);
title(strt);
subplot(212)
plot(F,mod((unwrap(angle(Hhilbert))+(wa*(M)))/pi,2));
axis([0 0.5 1.49 1.51]);
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_hilbert_response"),"-dpdflatex");
close

% Plot zeros
zplane(roots(hhilbert));
title(strt);
grid("on");
print(strcat(strf,"_hilbert_zeros"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
fprintf(fid,"delta=%d %% Amplitude peak-to-peak ripple\n",delta);
fprintf(fid,"ft=%g %% Amplitude transition band frequency\n",ft);
fprintf(fid,"At=%g %% Amplitude at transition band frequency\n",At);
fprintf(fid,"nf=%d %% Number of frequencies\n",nf);
fprintf(fid,"tol=%g %% Tolerance on convergence\n",tol);
fclose(fid);

print_polynomial(hM,"hM","%15.12f");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"),"%15.12f");

save selesnickFIRsymmetric_halfband_test.mat ...
     M delta ft At nf hM maxiter tol 
%
% Done
%
diary off
movefile selesnickFIRsymmetric_halfband_test.diary.tmp ...
         selesnickFIRsymmetric_halfband_test.diary;

