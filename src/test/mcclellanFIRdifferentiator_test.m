% mcclellanFIRdifferentiator_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen
%
% See: "Chebyshev Approximation for Nonrecursive Digital Filters with
% Linear Phase", T. W. Parks and J. H. McClellan, IEEE Transactions
% on Circuit Theory, Vol. CT-19, No. 2, March 1972, pp. 189-194
%
% Compare with b=remez(150,[0.01 0.49]*2,[0 1],[1],"differentiator");

test_common;

delete("mcclellanFIRdifferentiator_test.diary");
delete("mcclellanFIRdifferentiator_test.diary.tmp");
diary mcclellanFIRdifferentiator_test.diary.tmp

strf="mcclellanFIRdifferentiator_test";

%  
% Initialise
%
maxiter=100;
tol=1e-10;
nplot=10000;
nf=5000;

%
% Filter design from Table I
%

% Specification: low pass filter order is 2*M, length is 2*M+1
M=500;fap=0.247;fas=0.25;Kp=0.75;Kt=10;

% Constants 
f=(0:nf)'*0.5/nf;
nap=ceil(fap*nf/0.5)+1;
nas=floor(fas*nf/0.5)+1;
F=[f(1:(nap-1));fap;fas;f((nas+1):end)];
gs=length(F);
D=[2*pi*f(1:nap); zeros(gs-nap,1)];
W=[ones(nap,1)/Kp; ones(nas-nap,1)/Kt; ones(gs-nas,1)];

% Filter design
[hM,rho,fext,fiter,feasible]= ...
  mcclellanFIRdifferentiator(M,F,D,W,maxiter,tol);
if feasible==false
  error("hM not feasible");
endif
Aext=sin((2*pi*fext).*(M:-1:1))*hM;
print_polynomial(fext,"fext","%13.10f");
print_polynomial(Aext,"Aext","%13.10f");

%
% Plot response
%
strt=sprintf(["McClellan differentiator FIR: ", ...
 "M=%d,fap=%g,fas=%g,Kp=%g,Kt=%g,nplot=%d,rho=%g"],M,fap,fas,Kp,Kt,nplot,rho);
wa=(0:nplot)'*pi/nplot;
b=[-hM;0;flipud(hM)];
H=freqz(b,1,wa);
A=abs(H);
P=unwrap(angle(H)); 
subplot(211)
plot(wa*0.5/pi,A)
axis([0 0.5 -0.1 1.6]);
ylabel("Amplitude");
grid("on");
title(strt);
subplot(212)
plot(wa*0.5/pi,mod((P+(wa*M))/pi,2))
axis([0 0.5 1.499 1.501]);
ylabel("Phase/$\\pi$ (Adjusted for delay)");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot error response
A=2*sin(wa.*(M:-1:1))*hM;
pnap=ceil((nplot+1)*fap/0.5)+1;
pnas=floor((nplot+1)*fas/0.5)+1;
ax=plotyy(wa(1:pnap)*0.5/pi,wa(1:pnap)-A(1:pnap), ...
          wa(pnas:end)*0.5/pi,A(pnas:end));
axis(ax(1),[0 0.5 -2*abs(rho) 2*abs(rho)]);
axis(ax(2),[0 0.5 -2*abs(rho) 2*abs(rho)]);
title(strt);
ylabel("Amplitude error");
xlabel("Frequency");
grid("on");
print(strcat(strf,"_dual"),"-dpdflatex");
close

% Plot zeros
zplane(qroots(b));
title(strt);
grid("on");
print(strcat(strf,"_zeros"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"M=%d %% Filter order is 2*M\n",M);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Kp=%g %% Pass band weight\n",Kp);
fprintf(fid,"Kt=%g %% Transition band weight\n",Kt);
fprintf(fid,"nplot=%d %% Number of frequency grid points in [0,0.5]\n",nplot);
fprintf(fid,"maxiter=%d %% Maximum iterations\n",maxiter);
fprintf(fid,"tol=%g %% Tolerance on convergence\n",tol);
fclose(fid);

print_polynomial(hM,"hM","%15.12f");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"),"%15.12f");

fid=fopen(strcat(strf,"_rho.tab"),"wt");
fprintf(fid,"%11.8f",rho);
fclose(fid);

save mcclellanFIRdifferentiator_test.mat ...
     M fap fas Kp Kt nplot maxiter tol nplot rho hM fext Aext

%
% Done
%
diary off
movefile mcclellanFIRdifferentiator_test.diary.tmp ...
         mcclellanFIRdifferentiator_test.diary;

