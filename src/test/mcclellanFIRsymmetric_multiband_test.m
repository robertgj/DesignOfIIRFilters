% mcclellanFIRsymmetric_multiband_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen
%
% Compare with:
%{
   b=remez(2*M,[0 fasu1 fapl1 fapu1 fasl2 fasu2 fapl2 fapu2 fasl3 0.5]*2, ...
           [0 0 1 1 0 0 1 1 0 0],[1/K1,1,1/K2,1,1/K3],"bandpass");
%}
% See: "Chebyshev Approximation for Nonrecursive Digital Filters with
% Linear Phase", T. W. Parks and J. H. McClellan, IEEE Transactions
% on Circuit Theory, Vol. CT-19, No. 2, March 1972, pp. 189-194

test_common;

delete("mcclellanFIRsymmetric_multiband_test.diary");
delete("mcclellanFIRsymmetric_multiband_test.diary.tmp");
diary mcclellanFIRsymmetric_multiband_test.diary.tmp

strf="mcclellanFIRsymmetric_multiband_test";

%  
% Initialise
%
nplot=2000;
tol=1e-12;

%
% Filter design from Table I
%

% Specification: low pass filter order is 2*M, length is 2*M+1
M=30;K1=2;K2=4;K3=8;
fasu1=0.1;
fapl1=0.15;fapu1=0.2;
fasl2=0.25;fasu2=0.3;
fapl2=0.35;fapu2=0.4;
fasl3=0.45;

% Constants 
f=(0:nplot)'*0.5/nplot;
nasu1=ceil(fasu1*nplot/0.5)+1;
napl1=floor(fapl1*nplot/0.5)+1;
napu1=ceil(fapu1*nplot/0.5)+1;
nasl2=floor(fasl2*nplot/0.5)+1;
nasu2=ceil(fasu2*nplot/0.5)+1;
napl2=floor(fapl2*nplot/0.5)+1;
napu2=ceil(fapu2*nplot/0.5)+1;
nasl3=floor(fasl3*nplot/0.5)+1;
F=[f(1:(nasu1-1));fasu1; ...
   fapl1;f((napl1+1):(napu1-1));fapu1; ...
   fasl2;f((nasl2+1):(nasu2-1));fasu2; ...
   fapl2;f((napl2+1):(napu2-1));fapu2; ...
   fasl3;f(nasl3+1:end)];
D=[zeros(nasu1,1); ...
   ones(napu1-napl1+1,1); ...
   zeros(nasu2-nasl2+1,1); ...
   ones(napu2-napl2+1,1); ...
   zeros(nplot-nasl3+2,1)];
W=[ones(nasu1,1)/K1; ...
   ones(napu1-napl1+1,1); ...
   ones(nasu2-nasl2+1,1)/K2; ...
   ones(napu2-napl2+1,1); ...
   ones(nplot-nasl3+2,1)/K3];

% Sanity check
nchk=[1, ...
      nasu1-1,nasu1,nasu1+1,...
      napl1-1,napl1,napl1+1,...
      napu1-1,napu1,napu1+1,...
      nasl2-1,nasl2,nasl2+1,...
      nasu2-1,nasu2,nasu2+1,...
      napl2-1,napl2,napl2+1,...
      napu2-1,napu2,napu2+1,...
      nasl3-1,nasl3,nasl3+1, ...
      nplot,(nplot+1)];
printf("nchk=[ ");printf("%d ",nchk(:)');printf("]=\n");
printf("f(nchk)=[ ");printf("%d ",f(nchk)(:)');printf("]\n");
Fchk=[...
       % First stop-band
       1, ...
       2, ...
       nasu1-1, ...
       nasu1, ...  
       % First pass-band
       nasu1+1, ...
       nasu1+2, ...
       nasu1+napu1-napl1, ...
       nasu1+napu1-napl1+1, ... 
       % Second stop-band
       nasu1+napu1-napl1+2, ...
       nasu1+napu1-napl1+3,...
       nasu1+napu1-napl1+2+nasu2-nasl2-1, ...
       nasu1+napu1-napl1+2+nasu2-nasl2, ...
       % Second pass-band
       nasu1+napu1-napl1+2+nasu2-nasl2+1, ...
       nasu1+napu1-napl1+2+nasu2-nasl2+2, ...
       nasu1+napu1-napl1+2+nasu2-nasl2+1+napu2-napl2-1, ...
       nasu1+napu1-napl1+2+nasu2-nasl2+1+napu2-napl2, ...
       % Third stop-band
       nasu1+napu1-napl1+2+nasu2-nasl2+1+napu2-napl2+1, ...
       nasu1+napu1-napl1+2+nasu2-nasl2+1+napu2-napl2+2, ...
       nasu1+napu1-napl1+2+nasu2-nasl2+1+napu2-napl2+nplot-nasl3+1, ...
       nasu1+napu1-napl1+2+nasu2-nasl2+1+napu2-napl2+nplot-nasl3+2 ...
     ];
printf("Fchk=[ ");printf("%7d ",Fchk);printf("]\n");
printf("F(Fchk)=[ ");printf("%7.5f ",F(Fchk)');printf("]\n");
printf("D(Fchk)=[ ");printf("%7.5f ",D(Fchk)');printf("]\n");
printf("W(Fchk)=[ ");printf("%7.5f ",W(Fchk)');printf("]\n");

% Filter design
[hM,rho,fext,fiter,feasible]=mcclellanFIRsymmetric(M,F,D,W);
if feasible==false
  error("hM not feasible");
endif
Aext=directFIRsymmetricA(2*pi*fext,hM);
print_polynomial(fext,"fext","%13.10f");
print_polynomial(Aext,"Aext","%13.10f");

% Check response at band edges
% First stop-band
Asu1=directFIRsymmetricA(2*pi*fasu1,hM);
if abs(abs(Asu1)-abs(rho*K1))>tol
  error("abs(abs(Asu1)-abs(rho*K1))>tol");
endif
% First pass-band
Apl1=directFIRsymmetricA(2*pi*fapl1,hM);
if abs(abs(Apl1-1)-abs(rho))>tol
  error("abs(abs(Apl1-1)-abs(rho))>tol");
endif
Apu1=directFIRsymmetricA(2*pi*fapu1,hM);
if abs(abs(Apu1-1)-abs(rho))>tol
  error("abs(abs(Apu1-1)-abs(rho))>tol");
endif
% Second stop-band
Asl2=directFIRsymmetricA(2*pi*fasl2,hM);
if abs(abs(Asl2)-abs(rho*K2))>tol
  error("abs(abs(Asl2)-abs(rho*K2))>tol");
endif
Asu2=directFIRsymmetricA(2*pi*fasu2,hM);
if abs(abs(Asu2)-abs(rho*K2))>tol
  error("abs(abs(Asu2)-abs(rho*K2))>tol");
endif
% Second pass-band
Apl2=directFIRsymmetricA(2*pi*fapl2,hM);
if abs(abs(Apl2-1)-abs(rho))>tol
  error("abs(abs(Apl2-1)-abs(rho))>tol");
endif
Apu2=directFIRsymmetricA(2*pi*fapu2,hM);
if abs(abs(Apu2-1)-abs(rho))>tol
  error("abs(abs(Apu2-1)-abs(rho))>tol");
endif
% Third stop-band
Asl3=directFIRsymmetricA(2*pi*fasl3,hM);
if abs(abs(Asl3)-abs(rho*K3))>tol
  error("abs(abs(Asl3)-abs(rho*K3))>tol");
endif

%
% Plot response
%
strt=sprintf(["McClellan multi-band FIR: ", ...
 "M=%d,fasu1=%g,fapl1=%g,fapu1=%g,fasl2=%g,fasu2=%g,fapl2=%g,fapu2=%g,fasl3=%g"],...
M,fasu1,fapl1,fapu1,fasl2,fasu2,fapl2,fapu2,fasl3);
nplot=2000;
wa=(0:nplot)'*pi/nplot;
A=directFIRsymmetricA(wa,hM);
plot(wa*0.5/pi,20*log10(abs(A)))
axis([0 0.5 (20*log10(abs(rho))-10) 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title(strt);
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
ax=plotyy(wa*0.5/pi,A,wa*0.5/pi,A);
axis(ax(1),[0 0.5 1-(2*abs(rho)) 1+(2*abs(rho))]);
axis(ax(2),[0 0.5 -abs(rho) 2*max([K1,K2,K3])*abs(rho)]);
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
zticks([]);
print(strcat(strf,"_dual"),"-dpdflatex");
close

% Plot zeros
zplane(qroots([hM;flipud(hM(1:(end-1)))]));
title(strt);
grid("on");
zticks([]);
print(strcat(strf,"_zeros"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
fprintf(fid,"fasu1=%g %% Amplitude first stop-band upper edge\n",fasu1);
fprintf(fid,"fapl1=%g %% Amplitude first pass band lower edge\n",fapl1);
fprintf(fid,"fapu1=%g %% Amplitude first pass band upper edge\n",fapu1);
fprintf(fid,"fasl2=%g %% Amplitude second stop band lower edge\n",fasl2);
fprintf(fid,"fasu2=%g %% Amplitude second stop band upper edge\n",fasu2);
fprintf(fid,"fapl2=%g %% Amplitude second pass band lower edge\n",fapl2);
fprintf(fid,"fapu2=%g %% Amplitude second pass band upper edge\n",fapu2);
fprintf(fid,"fasl3=%g %% Amplitude third stop band lower edge\n",fasl3);
fprintf(fid,"K1=%g %% First stop band weight\n",K1);
fprintf(fid,"K2=%g %% Second stop band weight\n",K2);
fprintf(fid,"K3=%g %% Third stop band weight\n",K3);
fprintf(fid,"nplot=%d %% Number of frequency grid points in [0,0.5]\n",nplot);
fprintf(fid,"tol=%g %% Tolerance on convergence\n",tol);
fclose(fid);

print_polynomial(hM,"hM");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"));

fid=fopen(strcat(strf,"_rho.tab"),"wt");
fprintf(fid,"%11.8f",rho);
fclose(fid);

save mcclellanFIRsymmetric_multiband_test.mat ...
     M fasu1 fapl1 fapu1 fasl2 fasu2 fapl2 fapu2 fasl3 K1 K2 K3 ...
     nplot tol rho hM fext Aext

%
% Done
%
diary off
movefile mcclellanFIRsymmetric_multiband_test.diary.tmp ...
         mcclellanFIRsymmetric_multiband_test.diary;

