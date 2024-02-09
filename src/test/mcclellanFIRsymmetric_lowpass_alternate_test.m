% mcclellanFIRsymmetric_lowpass_alternate_test.m
% Copyright (C) 2021 Robert G. Jenssen
%
% See:
% [1] "Chebyshev Approximation for Nonrecursive Digital Filters with
% Linear Phase", T. W. Parks and J. H. McClellan, IEEE Transactions
% on Circuit Theory, Vol. CT-19, No. 2, March 1972, pp. 189-194
% [2] "Efficient Large-Scale Filter/Filterbank Design via LMI
% Characterization of Trigonometric Curves", H. D. Tuan, T. T. Son,
% B. Vo and T. Q. Nguyen, IEEE Transactions on Signal Processing,
% Vol. 55, No. 9, September 2007, pp. 4393--4404
%
% Compare with: b=remez(2*M,[0 fap fas 0.5]*2,[1 1 0 0],[deltap/deltas,1])

test_common;

delete("mcclellanFIRsymmetric_lowpass_alternate_test.diary");
delete("mcclellanFIRsymmetric_lowpass_alternate_test.diary.tmp");
diary mcclellanFIRsymmetric_lowpass_alternate_test.diary.tmp

strf="mcclellanFIRsymmetric_lowpass_alternate_test";

%
% Filter specification (filter order is 2*M)
%
Tuan_Figure_3=true
if Tuan_Figure_3
  % Filter design from [2,Figure 3] 
  M=200;fap=0.03;fas=0.0358;Wap=2;Was=1;K=50;ngrid=4000;
else
  % Filter design from [2,Figure 4] 
  M=600;fap=0.1;fas=0.105;Wap=1;Was=1;K=5000;ngrid=4000;
endif

% Constants
f=(0:ngrid)*0.5/ngrid;
nap=ceil(fap*ngrid/0.5)+1;
nas=floor(fas*ngrid/0.5)+1;
F=[f(1:(nap-1)),fap,fas,f((nas+1):end)];
F=F(:);
gs=length(F);
D=[ones(nap,1); zeros(gs-nap,1)];
W=[Wap*ones(nap,1)/K; Was*ones(gs-nap,1)];

% Filter design
[hM,rho,fext,fiter,feasible]=mcclellanFIRsymmetric(M,F,D,W);
if feasible==false
  error("hM not feasible");
endif
Aext=directFIRsymmetricA(2*pi*fext,hM);
print_polynomial(fext,"fext","%13.10f");
print_polynomial(Aext,"Aext","%13.10f");

%
% Plot response
%
strt=sprintf("McClellan lowpass FIR: \
M=%d,fap=%g,fas=%g,Wap=%g,Was=%g,K=%g,ngrid=%d,rho=%g",...
             M,fap,fas,Wap,Was,K,ngrid,rho);
nplot=20000;
wa=(0:nplot)'*pi/nplot;
A=directFIRsymmetricA(wa,hM);
plot(wa*0.5/pi,20*log10(abs(A)))
axis([0 0.5 (20*log10(abs(rho))-10) 10]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
pnap=ceil((nplot+1)*fap/0.5)+1;
pnas=floor((nplot+1)*fas/0.5)+1;
ax=plotyy(wa(1:pnap)*0.5/pi,A(1:pnap),wa(pnas:end)*0.5/pi,A(pnas:end));
if Tuan_Figure_3
  axis(ax(1),[0 0.5 1+(0.04*[-1 1])]);
  axis(ax(2),[0 0.5 0.002*[-1 1]]);
else
  axis(ax(1),[0 0.5 1+0.001*[-1 1]]);
  axis(ax(2),[0 0.5 2e-7*[-1 1]]);
endif
title(strt);
ylabel("Amplitude");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_dual"),"-dpdflatex");
close

% Check response at band edges
tol=100*eps;
Ap=directFIRsymmetricA(2*pi*fap,hM);
if abs(abs((Ap-1)*Wap/K)-abs(rho))>tol
  error("abs(abs((Ap-1)*Wap/K)(%g)-abs(rho)(%g))>tol(%g)",
        abs((Ap-1)*Wap/K),abs(rho),tol);
endif
As=directFIRsymmetricA(2*pi*fas,hM);
if abs(abs(As)-abs(rho))>tol
  error("abs(abs(As)(%g)-abs(rho))(%g)>tol(%g)",abs(As),abs(rho),tol);
endif

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"K=%d %% Stop band weight\n",K);
fprintf(fid,"ngrid=%d %% Number of frequency grid points in [0,0.5]\n",ngrid);
fclose(fid);

print_polynomial(hM,"hM");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"));

fid=fopen(strcat(strf,"_rho.tab"),"wt");
fprintf(fid,"%11.8f",rho);
fclose(fid);

save mcclellanFIRsymmetric_lowpass_alternate_test.mat ...
     M fap fas Wap Was K ngrid rho hM fext Aext

%
% Done
%
diary off
movefile mcclellanFIRsymmetric_lowpass_alternate_test.diary.tmp ...
         mcclellanFIRsymmetric_lowpass_alternate_test.diary;

