% mcclellanFIRsymmetric_lowpass_test.m
% Copyright (C) 2019 Robert G. Jenssen
%
% Compare with: b=remez(2*M,[0 fap fas 0.5]*2,[1 1 0 0],[1/K,1],16)
% See: "Chebyshev Approximation for Nonrecursive Digital Filters with
% Linear Phase", T. W. Parks and J. H. McClellan, IEEE Transactions
% on Circuit Theory, Vol. CT-19, No. 2, March 1972, pp. 189-194

test_common;

unlink("mcclellanFIRsymmetric_lowpass_test.diary");
unlink("mcclellanFIRsymmetric_lowpass_test.diary.tmp");
diary mcclellanFIRsymmetric_lowpass_test.diary.tmp

strf="mcclellanFIRsymmetric_lowpass_test";

%  
% Initialise
%
maxiter=100;
tol=1e-12;

%
% Filter design from Table I
%

% Specification: low pass filter order is 2*M, length is 2*M+1
M=14;fap=0.17265;fas=0.26265;K=10;gd=100;

% Constants 
nf=(gd*(M+1))+1;
f=(0:nf)*0.5/nf;
nap=ceil(fap*nf/0.5)+1;
nas=ceil(fas*nf/0.5)+1;
bands=[1,(nap+1)];
F=[f(1:(nap-1)),fap,fas,f((nas+1):end)];
F=F(:);
gs=length(F);
D=[ones(nap,1); zeros(gs-nap,1)];
W=[ones(nap,1)/K; ones(gs-nap,1)];

% Filter design
[hM,rho,fiter,feasible]=mcclellanFIRsymmetric(M,F,D,W,maxiter,tol);
if feasible==false
  error("hM not feasible");
endif

%
% Plot response
%
strt=sprintf("McClellan lowpass FIR: M=%d,fap=%g,fas=%g,K=%g,gd=%d,rho=%g", ...
             M,fap,fas,K,gd,rho);
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
pnap=ceil(nplot*fap/0.5)+1;
pnas=floor(nplot*fas/0.5)+1;
ax=plotyy(wa(1:pnap)*0.5/pi,A(1:pnap),wa(pnas:end)*0.5/pi,A(pnas:end));
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
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"K=%d %% Stop band weight\n",K);
fprintf(fid,"gd=%d %% Grid density\n",gd);
fprintf(fid,"maxiter=%d %% Maximum iterations\n",maxiter);
fprintf(fid,"tol=%g %% Tolerance on convergence of rho\n",tol);
fclose(fid);

print_polynomial(hM,"hM");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"));

fid=fopen(strcat(strf,"_rho.tab"),"wt");
fprintf(fid,"%11.8f",rho);
fclose(fid);

save mcclellanFIRsymmetric_lowpass_test.mat ...
     M fap fas K gd maxiter tol nplot rho hM 

%
% Done
%
diary off
movefile mcclellanFIRsymmetric_lowpass_test.diary.tmp ...
         mcclellanFIRsymmetric_lowpass_test.diary;

