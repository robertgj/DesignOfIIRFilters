% sdp_relaxation_directFIRhilbert_12_nbits_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

% SDP relaxation optimisation of a direct-form FIR Hilbert filter
% with 12-bit signed-digit coefficients

test_common;

delete("sdp_relaxation_directFIRhilbert_12_nbits_test.diary");
delete("sdp_relaxation_directFIRhilbert_12_nbits_test.diary.tmp");
diary sdp_relaxation_directFIRhilbert_12_nbits_test.diary.tmp

tic;

maxiter=2000
verbose=true;
tol=1e-5;
ctol=tol;
strf="sdp_relaxation_directFIRhilbert_12_nbits_test";

% Hilbert filter frequency specification
% dBap=0.1 gives poorer results ?!?
M=40;fapl=0.01;fapu=0.5-fapl;dBap=0.135;Wap=1;Was=0;
npoints=500;
wa=(0:((npoints)-1))'*pi/(npoints);
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
Ad=-ones(npoints,1);
if 1
  Adl=-(10^(dBap/40))*ones(npoints,1);
  Adu=-[zeros(napl-1,1); ...
        (10^(-dBap/40))*ones(napu-napl+1,1); ...
        zeros(npoints-napu,1)];
else
  dBap=0.07
  Adl=Ad;
  Adu=-[zeros(napl-1,1); ...
        (10^(-dBap/20))*ones(napu-napl+1,1); ...
        zeros(npoints-napu,1)];
endif
Wa=[Was*ones(napl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Was*ones(npoints-napu,1)];

% Sanity checks
nchka=[napl-1,napl,napl+1,napu-1,napu,napu+1];
printf("nchka=[napl-1,napl,napl+1,napu-1,napu,napu+1];\n");
printf("nchka=[ ");printf("%d ",nchka);printf("];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)'/(2*pi));printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Make a Hilbert filter
n4M1=((-2*M)+1):2:((2*M)-1)';
h0=zeros((4*M)-1,1);
h0(n4M1+(2*M))=2*(sin(pi*n4M1/2).^2)./(pi*n4M1);
h0=h0.*hamming((4*M)-1);
hM0=h0(1:2:((2*M)-1));
printf("hM0=[ ");printf("%g ",hM0');printf("]';\n");
print_polynomial(hM0,"hM0",strcat(strf,"_hM0_coef.m"),"%12.8g");

% Find the exact coefficient error
na=[napl (npoints/2)];
waf=wa(na);
Adf=-1;
Waf=Wap;
Esq0=directFIRhilbertEsqPW(hM0,waf,Adf,Waf);
printf("Esq0=%g\n",Esq0);

% Find the SOCP PCLS solution for the exact filter
war=1:(npoints/2);
hM_active=1:length(hM0);
[hM1,slb_iter,socp_iter,func_iter,feasible]= ...
  directFIRhilbert_slb(@directFIRhilbert_socp_mmsePW, ...
                       hM0,hM_active,na, ...
                       wa(war),Ad(war),Adu(war),Adl(war),Wa(war), ...
                       maxiter,tol,ctol,verbose);
if ~feasible
  error("SOCP PCLS problem for exact filter is infeasible!");
endif

% Allocate digits
nbits=12;
nscale=2^(nbits-1);
ndigits=2;
ndigits_alloc=directFIRhilbert_allocsd_Ito(nbits,ndigits,hM1,waf,Adf,Waf);
% Find the signed-digit approximations to hM1
[hM1_sd,hM1_sdu,hM1_sdl]=flt2SD(hM1,nbits,ndigits);
[hM1_digits_sd,hM1_adders_sd]=SDadders(hM1_sd,nbits);
print_polynomial(hM1_sd,"hM1_sd",nscale);
print_polynomial(hM1_sd,"hM1_sd",strcat(strf,"_hM1_sd_coef.m"),nscale);
% Find the signed-digit approximations to hM1 with Ito allocation
[hM1_sd_Ito,hM1_sdu_Ito,hM1_sdl_Ito]=flt2SD(hM1,nbits,ndigits_alloc);
[hM1_digits_sd_Ito,hM1_adders_sd_Ito]=SDadders(hM1_sd_Ito,nbits);
print_polynomial(hM1_sd_Ito,"hM1_sd_Ito",nscale);
print_polynomial(hM1_sd_Ito,"hM1_sd_Ito", ...
                 strcat(strf,"_hM1_sd_Ito_coef.m"),nscale);

% Find initial mean-squared errrors
Esq1=directFIRhilbertEsqPW(hM1,waf,Adf,Waf);
Esq1_sd=directFIRhilbertEsqPW(hM1_sd,waf,Adf,Waf);
Esq1_sd_Ito=directFIRhilbertEsqPW(hM1_sd_Ito,waf,Adf,Waf);

% Define filter coefficients
hM1_sd_delta=(hM1_sdu_Ito-hM1_sdl_Ito)/2;
hM1_sd_x=(hM1_sdu_Ito+hM1_sdl_Ito)/2;
[Esq1_sd_x,gradEsq1_sd_x,Q,q]=directFIRhilbertEsqPW(hM1_sd_x,waf,Adf,Waf);

% Run the SeDuMi problem
if 1
  [hM1_sd_sdp,socp_iter,func_iter,feasible] = ...
  sdp_relaxation_directFIRhilbert_mmsePW([],hM1_sd_x,hM1_sd_delta, ...
                              na,wa,Ad,Adu,Adl,Wa,maxiter,tol,verbose);
  if feasible==false
    error("sdp_relaxation_directFIRhilbert_mmsePW failed!");
  endif
else
  dBap_slb=0.2;
  Adu_slb=(10^(dBap_slb/40))*ones(npoints,1);
  Adl_slb=[zeros(napl-1,1); ...
       (10^(-dBap_slb/40))*ones(napu-napl+1,1); ...
       zeros(npoints-napu,1)];
  [hM1,slb_iter,socp_iter,func_iter,feasible]= ...
  directFIRhilbert_slb(@sdp_relaxation_directFIRhilbert_mmsePW, ...
                       hM1_sd_x,hM1_sd_delta,na, ...
                       wa(war),Ad(war),Adu_slb(war),Adl_slb(war),Wa(war), ...
                       maxiter,tol,ctol,verbose);
  if ~feasible
    error("SDP PCLS problem for exact filter is infeasible!");
  endif
endif
print_polynomial(hM1_sd_sdp,"hM1_sd_sdp",nscale);
print_polynomial(hM1_sd_sdp,"hM1_sd_sdp", ...
                 strcat(strf,"_hM1_sd_sdp_coef.m"),nscale);
[hM1_digits_sd_sdp,hM1_adders_sd_sdp]=SDadders(hM1_sd_sdp,nbits);
Esq1_sd_sdp=directFIRhilbertEsqPW(hM1_sd_sdp,waf,Adf,Waf);

% Calculate response
A_hM1=directFIRhilbertA(wa,hM1);
A_hM1_sd=directFIRhilbertA(wa,hM1_sd);
A_hM1_sd_Ito=directFIRhilbertA(wa,hM1_sd_Ito);
A_hM1_sd_sdp=directFIRhilbertA(wa,hM1_sd_sdp);

% Find maximum pass-band response
rsb=[napl:napu];
max_sb_A_hM1=       max(abs(20*log10(abs(A_hM1(rsb)))))
max_sb_A_hM1_sd=    max(abs(20*log10(abs(A_hM1_sd(rsb)))))
max_sb_A_hM1_sd_Ito=max(abs(20*log10(abs(A_hM1_sd_Ito(rsb)))))
max_sb_A_hM1_sd_sdp=max(abs(20*log10(abs(A_hM1_sd_sdp(rsb)))))

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %10.4g & %10.4g & & \\\\\n",Esq1,max_sb_A_hM1);
fprintf(fid,"%d-bit %d-signed-digit & %10.4g & %10.4g & %d & %d \\\\\n",
        nbits,ndigits,Esq1_sd,max_sb_A_hM1_sd,hM1_digits_sd,hM1_adders_sd);
fprintf(fid,"%d-bit %d-signed-digit(Ito) & %10.4g & %10.4g & %d & %d \\\\\n",
        nbits,ndigits,Esq1_sd_Ito,max_sb_A_hM1_sd_Ito, ...
        hM1_digits_sd_Ito,hM1_adders_sd_Ito);
fprintf(fid,"%d-bit %d-signed-digit(SDP) & %10.4g & %10.4g & %d & %d \\\\\n",
        nbits,ndigits,Esq1_sd_sdp,max_sb_A_hM1_sd_sdp, ...
        hM1_digits_sd_sdp,hM1_adders_sd_sdp);
fclose(fid);

% Plot amplitude response
plot(wa*0.5/pi,20*log10(abs(A_hM1)),"linestyle","-", ...
     wa*0.5/pi,20*log10(abs(A_hM1_sd)),"linestyle",":", ...
     wa*0.5/pi,20*log10(abs(A_hM1_sd_Ito)),"linestyle","--", ...
     wa*0.5/pi,20*log10(abs(A_hM1_sd_sdp)),"linestyle","-.");
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.25 -0.2 0.2]);
strt=sprintf("Direct-form Hilbert filter (nbits=%d,ndigits=%d) : \
fapl=%g,fapu=%g,dBap=%g",nbits,ndigits,fapl,fapu,dBap);
title(strt);
legend("exact","s-d","s-d(Ito)","s-d(SDP)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"M=%d %% Number of distinct coefficients\n",M);
fprintf(fid,"nbits=%d %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%d %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"npoints=%d %% Frequency points across the band\n",npoints);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fclose(fid);

% Save results
save sdp_relaxation_directFIRhilbert_12_nbits_test.mat ...
     tol ctol nbits nscale ndigits ndigits_alloc npoints ...
     fapl fapu dBap Wap Was hM1_sd_sdp
       
% Done
toc;
diary off
movefile sdp_relaxation_directFIRhilbert_12_nbits_test.diary.tmp ...
         sdp_relaxation_directFIRhilbert_12_nbits_test.diary;
