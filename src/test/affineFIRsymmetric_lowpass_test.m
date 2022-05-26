% affineFIRsymmetric_lowpass_test.m
% Copyright (C) 2020 Robert G. Jenssen
%
% See:
% [1] "Exchange Algorithms that Complement the Parks-McClellan Algorithm for
% Linear-Phase FIR Filter Design", Ivan W. Selesnick and C. Sidney Burrus,
% IEEE TRANSACTIONS ON CIRCUITS AND SYSTEMS—II: ANALOG AND DIGITAL SIGNAL
% PROCESSING, VOL. 44, NO. 2, FEBRUARY 1997, pp.137-143
% [2] "Chebyshev Approximation for Nonrecursive Digital Filters with
% Linear Phase", T. W. Parks and J. H. McClellan, IEEE Transactions
% on Circuit Theory, Vol. CT-19, No. 2, March 1972, pp. 189-194

test_common;

delete("affineFIRsymmetric_lowpass_test.diary");
delete("affineFIRsymmetric_lowpass_test.diary.tmp");
diary affineFIRsymmetric_lowpass_test.diary.tmp

strf="affineFIRsymmetric_lowpass_test";

%  
% Initialise
%
nplot=2000;
maxiter=100;
tol=1e-12;

%
% Filter design from Table I
%

% Specification: low pass filter order is 2*M, length is 2*M+1
%M=9;fp=0.2;fs=0.25;kappap=1;kappas=0;etap=0;etas=0.05;
%M=9;fp=0.2;fs=0.3;kappap=0;kappas=1;etap=0.05;etas=0;
%M=25;fp=0.2;fs=0.25;kappap=1;kappas=2;etap=0;etas=0;
M=27;fp=0.2;fs=0.25;kappap=1;kappas=0;etap=0;etas=0.001;

% Filter design
[hM,deltap,deltas,fext,fiter,feasible] = ...
affineFIRsymmetric_lowpass(M,fp,fs,kappap,etap,kappas,etas,nplot,maxiter,tol);
if feasible==false
  error("hM not feasible");
endif
Aext=directFIRsymmetricA(2*pi*fext,hM);
print_polynomial(fext,"fext","%13.10f");
print_polynomial(Aext,"Aext","%13.10f");

%
% Plot response
%
strt=sprintf("Affine lowpass FIR : M=%d,fp=%g,fs=%g,kappap=%g,kappas=%g, \
etap=%g,etas=%g,nplot=%d,deltap=%g,deltas=%g", ...
             M,fp,fs,kappap,kappas,etap,etas,nplot,deltap,deltas);
wa=(0:nplot)'*pi/nplot;
A=directFIRsymmetricA(wa,hM);
plot(wa*0.5/pi,20*log10(abs(A)))
axis([0 0.5 (20*log10(abs(deltas))-10) 5]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
grid("on");
title(strt);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Dual plot
pnp=ceil((nplot+1)*fp/0.5)+1;
pns=floor((nplot+1)*fs/0.5)+1;
ax=plotyy(wa(1:pnp)*0.5/pi,A(1:pnp),wa(pns:end)*0.5/pi,A(pns:end));
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
axis(ax(1),[0 0.5 0.99 1.01]);
axis(ax(2),[0 0.5 -2*deltas 2*deltas]);
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
fprintf(fid,"fp=%g %% Amplitude pass band edge\n",fp);
fprintf(fid,"fs=%g %% Amplitude stop band edge\n",fs);
fprintf(fid,"kappap=%d %% Pass-band kappa\n",kappap);
fprintf(fid,"kappas=%d %% Stop-band kappa\n",kappas);
fprintf(fid,"etap=%d %% Pass-band eta\n",etap);
fprintf(fid,"etas=%d %% Stop-band eta\n",etas);
fprintf(fid,"nplot=%d %% Number of frequency points\n",nplot);
fprintf(fid,"maxiter=%d %% Maximum iterations\n",maxiter);
fprintf(fid,"tol=%g %% Tolerance on convergence\n",tol);
fclose(fid);

print_polynomial(hM,"hM");
print_polynomial(hM,"hM",strcat(strf,"_hM_coef.m"));

fid=fopen(strcat(strf,"_deltap.tab"),"wt");
fprintf(fid,"%11.8f",deltap);
fclose(fid);

fid=fopen(strcat(strf,"_deltas.tab"),"wt");
fprintf(fid,"%11.8f",deltas);
fclose(fid);

save affineFIRsymmetric_lowpass_test.mat ...
     M fp fs kappap kappas etap etas nplot maxiter tol hM fext Aext deltap deltas

%
% Done
%
diary off
movefile affineFIRsymmetric_lowpass_test.diary.tmp ...
         affineFIRsymmetric_lowpass_test.diary;

