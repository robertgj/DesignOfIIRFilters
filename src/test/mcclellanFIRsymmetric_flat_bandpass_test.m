% mcclellanFIRsymmetric_flat_bandpass_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

delete("mcclellanFIRsymmetric_flat_bandpass_test.diary");
delete("mcclellanFIRsymmetric_flat_bandpass_test.diary.tmp");
diary mcclellanFIRsymmetric_flat_bandpass_test.diary.tmp

strf="mcclellanFIRsymmetric_flat_bandpass_test";

%  
% Initialise
%
nplot=4000;
tol=1e-10;

%
% Filter specification
%
N=55;L=8;fp=0.2;ft=0.05;K=2;
M=(N-1-L)/2;
strt=sprintf("Selesnick-Burrus flat band-pass FIR : \
N=%d,L=%d,$f_{p}$=%g,$f_{t}$=%g,K=%g",N,L,fp,ft,K);

% Weighting function for the high-pass filter
F=0.5*(0:nplot)'/nplot;
W=((-1)^L)*((sin(pi*(fp+F)).*sin(pi*(fp-F))).^(L/2));

% Find hM
fsl=fp-ft;
fsu=fp+ft;
nsl=floor(fsl*nplot/0.5)+1;
nsu=ceil(fsu*nplot/0.5)+1;
Flu=[F(1:(nsl-1));fsl;fsu;F((nsu+1):end)];
Wlu=((-1)^L)*((sin(pi*(fp+Flu)).*sin(pi*(fp-Flu))).^(L/2));
Dlu=-1./Wlu;
[hM,rho,fMext,fiter,feasible]= ...
  mcclellanFIRsymmetric(M,Flu,Dlu,[K*Wlu(1:nsl);Wlu((nsl+1):end)]);
if feasible==false
  error("hM not feasible");
endif
AMext=directFIRsymmetricA(2*pi*fMext,hM);
print_polynomial(fMext,"fMext","%13.10f");
print_polynomial(AMext,"AMext","%13.7f");

% Plot solution
AM=directFIRsymmetricA(2*pi*F,hM);
A=1+(AM(:).*W);
plot(F,20*log10(abs(A)))
axis([0 0.5 -60 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
ax=plotyy(F,A,F,A);
axis(ax(1),[0 0.5 0.98 1.02]);
axis(ax(2),[0 0.5 -0.02 0.02]);
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_dual"),"-dpdflatex");
close

% Check response at extremal frequencies
maxA=local_max(A);
minA=local_max(-A);
[mm,imm]=unique([maxA;minA]);
[Fmm,imm]=unique(F([maxA;minA]));
Amm=[A(maxA);A(minA)];
Amm=Amm(imm);
print_polynomial(Fmm,"Fmm","%13.10f");
print_polynomial(Amm,"Amm","%13.10f");

%
% Construct the overall impulse response
%
hL=1;
for k=1:(L/2),
  hL=conv(hL,[1;-2*cos(2*pi*fp);1]/4);
endfor
HL=freqz(hL,1,2*pi*F);
if max(abs(abs(W)-abs(HL)))>tol
  error("max(abs(abs(W)-abs(HL)))>tol");
endif
hA=[zeros((N-1)/2,1);1;zeros((N-1)/2,1)]+conv(hL,[hM;hM((end-1):-1:1)]);
hA=hA(1:((N+1)/2));
AA=directFIRsymmetricA(2*pi*F,hA);
if max(abs(A-AA))>tol
  error("max(abs(A-AA))>tol");
endif

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"N=%d %% Filter length\n",N);
fprintf(fid,"L=%d %% Filter flat-ness\n",L);
fprintf(fid,"fp=%g %% Amplitude pass-band centre frequency\n",fp);
fprintf(fid,"ft=%g %% Amplitude pass-band half-width frequency\n",ft);
fprintf(fid,"K=%g %% Amplitude stop-band ripple ratio\n",K);
fprintf(fid,"nplot=%d %% Number of frequency points\n",nplot);
fprintf(fid,"tol=%g %% Tolerance on convergence\n",tol);
fclose(fid);

print_polynomial(hM,"hM","%14.8f");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"),"%14.8f");

print_polynomial(hA,"hA","%15.12f");
print_polynomial(hA,"hA",strcat(strf,"_hA_coef.m"),"%15.12f");

fid=fopen(strcat(strf,"_rho.tab"),"wt");
fprintf(fid,"%11.8f",rho);
fclose(fid);

save mcclellanFIRsymmetric_flat_bandpass_test.mat ...
     N L fp ft K nplot tol hM fMext AMext hA

%
% Done
%
diary off
movefile mcclellanFIRsymmetric_flat_bandpass_test.diary.tmp ...
         mcclellanFIRsymmetric_flat_bandpass_test.diary;

