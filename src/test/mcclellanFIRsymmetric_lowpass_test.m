% mcclellanFIRsymmetric_lowpass_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen
%
% Compare with: b=remez(2*M,[0 fap fas 0.5]*2,[1 1 0 0],[1/K,1],16)
% See: "Chebyshev Approximation for Nonrecursive Digital Filters with
% Linear Phase", T. W. Parks and J. H. McClellan, IEEE Transactions
% on Circuit Theory, Vol. CT-19, No. 2, March 1972, pp. 189-194

test_common;

delete("mcclellanFIRsymmetric_lowpass_test.diary");
delete("mcclellanFIRsymmetric_lowpass_test.diary.tmp");
diary mcclellanFIRsymmetric_lowpass_test.diary.tmp

strf="mcclellanFIRsymmetric_lowpass_test";

%  
% Initialise
%
nplot=1000;
tol=1e-12;

%
% Filter design from Table I
%

% Specification: low pass filter order is 2*M, length is 2*M+1
M=14;fap=0.17265;fas=0.26265;K=5;
% Alternative : M=48;fap=0.15;fas=0.175;K=20;

% Constants 
f=(0:nplot)*0.5/nplot;
nap=ceil(fap*nplot/0.5)+1;
nas=floor(fas*nplot/0.5)+1;
F=[f(1:(nap-1)),fap,fas,f((nas+1):end)];
F=F(:);
gs=length(F);
D=[ones(nap,1); zeros(gs-nap,1)];
W=[ones(nap,1)/K; ones(gs-nap,1)];

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
strt=sprintf("McClellan lowpass FIR: M=%d,fap=%g,fas=%g,K=%g,nplot=%d,rho=%g",...
             M,fap,fas,K,nplot,rho);
nplot=10000;
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
pnap=ceil((nplot+1)*fap/0.5)+1;
pnas=floor((nplot+1)*fas/0.5)+1;
ax=plotyy(wa(1:pnap)*0.5/pi,A(1:pnap),wa(pnas:end)*0.5/pi,A(pnas:end));
axis(ax(1),[0 0.5 1-(2*K*abs(rho)) 1+(2*K*abs(rho))]);
axis(ax(2),[0 0.5 -2*abs(rho) 2*abs(rho)]);
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

% Check response at band edges
Ap=directFIRsymmetricA(2*pi*fap,hM);
if abs(abs((Ap-1)/K)-abs(rho))>tol
  error("abs(abs((Ap-1)/K)-abs(rho))>tol");
endif
As=directFIRsymmetricA(2*pi*fas,hM);
if abs(abs(As)-abs(rho))>tol
  error("abs(abs(As)-abs(rho))>tol");
endif

% Check response at extremal frequencies
maxA=local_max(A);
minA=local_max(-A);
extA=unique([pnap;pnas;maxA(:);minA(:)]);
extx=cos(wa(extA));
extf=wa(extA)*0.5/pi;
[intA,inta,p]=lagrange_interp(extx,A(extA),[],cos(wa));
dp=polyder(p);
subplot(211),plot(cos(wa),polyval(p,cos(wa)),extx,A(extA),"o");
title(strt);
ylabel("p(x)");
grid("on");
subplot(212),plot(cos(wa),polyval(dp,cos(wa)),extx,polyval(dp,extx),"o");
ylabel("p'(x)");
xlabel("x");
grid("on");
zticks([]);
print(strcat(strf,"_extremal"),"-dpdflatex");
close

%
% Filter design with left-division
%
[hM_LD,rho_LD,fext_LD,fiter,feasible]=mcclellanFIRsymmetric(M,F,D,W,"left");
if feasible==false
  error("hM_LD not feasible");
endif
Aext_LD=directFIRsymmetricA(2*pi*fext_LD,hM_LD);
if norm(Aext-Aext_LD)>tol
  error("norm(Aext-Aext_LD)>tol");
endif
print_polynomial(fext_LD,"fext_LD","%13.10f");
print_polynomial(Aext_LD,"Aext_LD","%13.10f");

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"K=%d %% Stop band weight\n",K);
fprintf(fid,"nplot=%d %% Number of frequency grid points in [0,0.5]\n",nplot);
fprintf(fid,"tol=%g %% Tolerance on convergence\n",tol);
fclose(fid);

print_polynomial(hM,"hM");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"));

print_polynomial(hM_LD,"hM_LD");
print_polynomial(hM_LD,"hM_LD",strcat(strf,"_hM_LD_coef.m"));

fid=fopen(strcat(strf,"_rho.tab"),"wt");
fprintf(fid,"%11.8f",rho);
fclose(fid);

save mcclellanFIRsymmetric_lowpass_test.mat ...
     M fap fas K nplot tol nplot rho hM fext Aext

%
% Done
%
diary off
movefile mcclellanFIRsymmetric_lowpass_test.diary.tmp ...
         mcclellanFIRsymmetric_lowpass_test.diary;

