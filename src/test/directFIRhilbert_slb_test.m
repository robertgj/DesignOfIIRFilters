% directFIRhilbert_slb_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("directFIRhilbert_slb_test.diary");
delete("directFIRhilbert_slb_test.diary.tmp");
diary directFIRhilbert_slb_test.diary.tmp

%
% Initialise
%
maxiter=500;
verbose=true;
tol=1e-4;
ctol=tol;

% Hilbert filter frequency specification
%M=10;fapl=0.05;fapu=0.5-fapl;dBap=0.015;Wap=1;Was=0;
M=10;fapl=0.025;fapu=0.5-fapl;dBap=0.5;Wap=1;Was=0;
npoints=1000;

wa=(0:((npoints)-1))'*pi/(npoints);
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
Ad=-ones(npoints,1);
Adl=-ones(npoints,1);
Adu=-[zeros(napl-1,1); ...
      (10^(-dBap/20))*ones(napu-napl+1,1); ...
      zeros(npoints-napu,1)];
Wa=[Was*ones(napl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Was*ones(npoints-napu,1)];
% Sanity check
nch=[1 napl-1 napl napl+1 napu-1 napu napu+1 npoints];
printf("fa=[ ");printf("%d ",wa(nch)*0.5/pi);printf("]\n");
printf("Adl=[ ");printf("%d ",Adl(nch));printf("]\n");
printf("Wa=[ ");printf("%d ",Wa(nch));printf("]\n");

% Make a Hilbert filter
n4M1=((-2*M)+1):2:((2*M)-1)';
h0=zeros((4*M)-11,1);
h0(n4M1+(2*M))=2*(sin(pi*n4M1/2).^2)./(pi*n4M1);
h0=h0.*hamming((4*M)-1);
hM0=h0(1:2:((2*M)-1));
hM_active=1:length(hM0);

%
% MMSE solution
%
war=1:(npoints/2);
A0=directFIRhilbertA(wa,hM0);
vS=directFIRhilbert_slb_update_constraints(A0(war),Adu(war),Adl(war),tol);
[hM1,socp_iter,func_iter,feasible]=directFIRhilbert_mmsePW ...
  (vS,hM0,hM_active,[napl,(npoints/2)], ...
   wa(war),Ad(war),Adu(war),Adl(war),Wa(war),maxiter,tol,verbose);

%
% SLB solution
%
[hM2,slb_iter,socp_iter,func_iter,feasible]=directFIRhilbert_slb ...
  (@directFIRhilbert_mmsePW,hM1,hM_active,[napl,(npoints/2)], ...
   wa(war),Ad(war),Adu(war),Adl(war),Wa(war),maxiter,tol,ctol,verbose);
if feasible==false
  error("directFIRhilbert_slb failed!");
endif

%
% Plot exact solution
%
nplot=1000;
wplot=(0:(nplot-1))'*pi/nplot;
A0p=directFIRhilbertA(wplot,hM0);
A1p=directFIRhilbertA(wplot,hM1);
A2p=directFIRhilbertA(wplot,hM2);
plot(wplot*0.5/pi,20*log10(abs(A0p)),"-", ...
     wplot*0.5/pi,20*log10(abs(A1p)),"-.", ...
     wplot*0.5/pi,20*log10(abs(A2p)),"--");
axis([0 0.25 -1 1]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("Initial","MMSE","PCLS","location","northeast");
legend("boxoff");
legend("left");
grid("on");
strM=sprintf("FIR Hilbert : fapl=%g,fapu=%g,dBap=%g,Was=%g",fapl,fapu,dBap,Was);
title(strM);
print("directFIRhilbert_slb_test_response","-dpdflatex");
close

% Check phase response, group delay should be 2M-1
H2=freqz(kron([hM2(:);-flipud(hM2(:))],[1;0])(1:(end-1)),1,wa);
max_phase_err= ...
  max(mod((unwrap(angle(H2(napl:napu)))+(wa(napl:napu)*((2*M)-1)))/pi,2)-1.5);
if  max_phase_err > 10*eps
  error("max_phase_err(%g*eps) > 10*eps",max_phase_err/eps);
endif

%
% Save the results
%
fid=fopen("directFIRhilbert_slb_test_spec.m","wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"npoints=%d %% Frequency points across the band\n",npoints);
fprintf(fid,"M=%d %% M distinct coefficients\n",M);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);

print_polynomial(hM0,"hM0");
print_polynomial(hM0,"hM0","directFIRhilbert_slb_test_hM0_coef.m");
print_polynomial(hM1,"hM1");
print_polynomial(hM1,"hM1","directFIRhilbert_slb_test_hM1_coef.m");
print_polynomial(hM2,"hM2");
print_polynomial(hM2,"hM2","directFIRhilbert_slb_test_hM2_coef.m");

save directFIRhilbert_slb_test.mat tol ctol maxiter M npoints ...
     fapl fapu Wap dBap Was wa Ad Adu Adl Wa hM0 hM1 hM2

% Done
diary off
movefile directFIRhilbert_slb_test.diary.tmp directFIRhilbert_slb_test.diary;

