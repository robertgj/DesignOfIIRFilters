% mcclellanFIRsymmetric_bandpass_test.m
% Copyright (C) 2019 Robert G. Jenssen
%
% Compare with:
% b=remez(2*M,[0 fasl fapl fapu fasu 0.5]*2,[0 0 1 1 0 0],[1,1/K,1],'bandpass')
%
% See: "Chebyshev Approximation for Nonrecursive Digital Filters with
% Linear Phase", T. W. Parks and J. H. McClellan, IEEE Transactions
% on Circuit Theory, Vol. CT-19, No. 2, March 1972, pp. 189-194

test_common;

unlink("mcclellanFIRsymmetric_bandpass_test.diary");
unlink("mcclellanFIRsymmetric_bandpass_test.diary.tmp");
diary mcclellanFIRsymmetric_bandpass_test.diary.tmp

strf="mcclellanFIRsymmetric_bandpass_test";

%  
% Initialise
%
maxiter=100;
tol=1e-12;

%
% Filter design from Table I
%

% Specification: low pass filter order is 2*M, length is 2*M+1
M=40;fasl=0.15;fapl=0.2;fapu=0.25;fasu=0.3;K=20;

% Constants 
nf=2000;
f=(0:nf)*0.5/nf;
nasl=ceil(fasl*nf/0.5)+1;
napl=floor(fapl*nf/0.5)+1;
napu=ceil(fapu*nf/0.5)+1;
nasu=floor(fasu*nf/0.5)+1;
bands=[1,napl,nasu];
F=[f(1:(nasl-1)),fasl,fapl,f((napl+1):(napu-1)),fapu,fasu,f((nasu+1):end)];
F=F(:);
gs=length(F);
D=[zeros(nasl,1); ones(napu-napl+1,1); zeros(nf+1-nasu+1,1)];
W=[ones(nasl,1); ones(napu-napl+1,1)/K; ones(nf+1-nasu+1,1)];

% Filter design
[hM,rho,fiter,feasible]=mcclellanFIRsymmetric(M,F,D,W,"bandpass",maxiter,tol);
if feasible==false
  error("hM not feasible");
endif

% Check response at band edges
Asl=directFIRsymmetricA(2*pi*fasl,hM);
if abs(abs(Asl)-abs(rho))>tol
  error("abs(abs(Asl)-abs(rho))>tol");
endif
Apl=directFIRsymmetricA(2*pi*fapl,hM);
if abs(abs((Apl-1)/K)-abs(rho))>tol
  error("abs(abs((Apl-1)/K)-abs(rho))>tol");
endif
Apu=directFIRsymmetricA(2*pi*fapu,hM);
if abs(abs((Apu-1)/K)-abs(rho))>tol
  error("abs(abs((Apu-1)/K)-abs(rho))>tol");
endif
Asu=directFIRsymmetricA(2*pi*fasu,hM);
if abs(abs(Asu)-abs(rho))>tol
  error("abs(abs(Asu)-abs(rho))>tol");
endif

%
% Plot response
%
strt=sprintf("McClellan bandpass FIR: \
M=%d,fasl=%g,fapl=%g,fapu=%g,fasu=%g,K=%g,nf=%d,rho=%g", ...
             M,fasl,fapl,fapu,fasu,K,nf,rho);
nplot=2000;
wa=(0:(nplot-1))'*pi/nplot;
A=directFIRsymmetricA(wa,hM);
plot(wa*0.5/pi,20*log10(abs(A)))
axis([0 0.5 (20*log10(abs(rho))-10) 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
ax=plotyy(wa*0.5/pi,A,wa*0.5/pi,A);
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 1-(2*K*abs(rho)) 1+(2*K*abs(rho))]);
axis(ax(2),[0 0.5 -2*abs(rho) 2*abs(rho)]);
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
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
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"K=%d %% Stop band weight\n",K);
fprintf(fid,"nf=%d %% Number of frequency grid points in [0,0.5]\n",nf);
fprintf(fid,"maxiter=%d %% Maximum iterations\n",maxiter);
fprintf(fid,"tol=%g %% Tolerance on convergence of rho\n",tol);
fclose(fid);

print_polynomial(hM,"hM");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"));

fid=fopen(strcat(strf,"_rho.tab"),"wt");
fprintf(fid,"%11.8f",rho);
fclose(fid);

save mcclellanFIRsymmetric_bandpass_test.mat ...
     M fasl fapl fapu fasu K nf maxiter tol nplot rho hM 

%
% Done
%
diary off
movefile mcclellanFIRsymmetric_bandpass_test.diary.tmp ...
         mcclellanFIRsymmetric_bandpass_test.diary;
