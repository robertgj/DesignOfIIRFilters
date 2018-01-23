% sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

% SDP relaxation optimisation of a symmetric direct-form FIR
% bandpass filter with 12-bit signed-digit coefficients

test_common;

unlink("sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.diary");
unlink("sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.diary.tmp");
diary sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.diary.tmp

tic;

maxiter=2000
verbose=false;
tol=1e-6;
ctol=tol;
strf="sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test";

% Band pass filter
M=15;
fapl=0.1;fapu=0.2;Wap=1;dBap=2;
fasl=0.05;fasu=0.25;Wasl=40;Wasu=40;dBas=47;

% Desired magnitude response
npoints=1000;
wa=(0:npoints)'*pi/npoints;
nasl=ceil(npoints*fasl/0.5)+1;
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
nasu=floor(npoints*fasu/0.5)+1;  
na=[1 nasl napl napu nasu length(wa)];
Ad=[zeros(napl-1,1); ...
    ones(napu-napl+1,1); ...
    zeros(npoints-napu+1,1)];
Adu=[(10^(-dBas/20))*ones(nasl,1); ...
     ones(nasu-nasl-1,1); ...
     (10^(-dBas/20))*ones(npoints-nasu+2,1)];
Adl=[-(10^(-dBas/20))*ones(napl-1,1); ...
      (10^(-dBap/20))*ones(napu-napl+1,1); ...
     -(10^(-dBas/20))*ones(npoints-napu+1,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(npoints-nasu+2,1)];

% Sanity checks
nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu,nasu+1];
printf ...
  ("nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu,nasu+1];\n");
printf("nchka=[ ");printf("%d ",nchka);printf("];\n");
printf("f(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)'/(2*pi));printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Make an initial band pass filter
h0=remez(2*M,[0 fasl fapl fapu fasu 0.5]*2,[0 0 1 1 0 0],[10 1 10],'bandpass');
hM0=h0(1:(M+1));
hM0_active=1:length(hM0);
[hM1,slb_iter,socp_iter,func_iter,feasible]= ...
directFIRsymmetric_slb(@directFIRsymmetric_socp_mmsePW, ...
                       hM0,hM0_active,na,wa,Ad,Adu,Adl,Wa, ...
                       maxiter,tol,ctol,verbose);
if feasible==false
  error("directFIRsymmetric_slb failed for initial filter!");
endif

% Allocate digits
nbits=12;
nscale=2^(nbits-1);
ndigits=2;
waf=wa([1 nasl napl napu nasu end]);
Adf=[0 0 1 0 0];
Waf=[Wasl 0 Wap 0 Wasu];
ndigits_alloc=directFIRsymmetric_allocsd_Ito(nbits,ndigits,hM1,waf,Adf,Waf);
% Find the signed-digit approximations to hM1
[hM1_sd,hM1_sdu,hM1_sdl]=flt2SD(hM1,nbits,ndigits);
[hM1_digits_sd,hM1_adders_sd]=SDadders(hM1_sd,nbits);
[hM1_sd_Ito,hM1_sdu_Ito,hM1_sdl_Ito]=flt2SD(hM1,nbits,ndigits_alloc);
[hM1_digits_sd_Ito,hM1_adders_sd_Ito]=SDadders(hM1_sd_Ito,nbits);
print_polynomial(hM1_sd_Ito,"hM1_sd_Ito",nscale);
print_polynomial(hM1_sd_Ito,"hM1_sd_Ito", ...
                 strcat(strf,"_hM1_sd_Ito_coef.m"),nscale);
% Find initial mean-squared errrors
Esq1=directFIRsymmetricEsqPW(hM1,waf,Adf,Waf);
Esq1_sd=directFIRsymmetricEsqPW(hM1_sd,waf,Adf,Waf);
Esq1_sd_Ito=directFIRsymmetricEsqPW(hM1_sd_Ito,waf,Adf,Waf);

% Define filter coefficients
if 0
hM1_sd_delta=(hM1_sdu-hM1_sdl)/2;
hM1_sd_x=(hM1_sdu+hM1_sdl)/2;
else
hM1_sd_delta=(hM1_sdu_Ito-hM1_sdl_Ito)/2;
hM1_sd_x=(hM1_sdu_Ito+hM1_sdl_Ito)/2;
endif
[Esq1_sd_x,gradEsq1_sd_x,Q,q]=directFIRsymmetricEsqPW(hM1_sd_x,waf,Adf,Waf);

% Run the SeDuMi problem
if 1
  [hM1_sd_sdp,socp_iter,func_iter,feasible] = ...
    directFIRsymmetric_sdp_mmsePW([],hM1_sd_x,hM1_sd_delta,na, ...
                                  wa,Ad,Adu,Adl,Wa,maxiter,tol,verbose);
  if feasible==false
    error("directFIRsymmetric_sdp_mmsePW failed!");
  endif
else
  dBap_sdp=2;dBas_sdp=40;
  Adu_sdp=[(10^(-dBas_sdp/20))*ones(nasl,1); ...
            ones(nasu-nasl-1,1); ...
           (10^(-dBas_sdp/20))*ones(npoints-nasu+2,1)];
  Adl_sdp=[-(10^(-dBas_sdp/20))*ones(napl-1,1); ...
            (10^(-dBap_sdp/20))*ones(napu-napl+1,1); ...
           -(10^(-dBas_sdp/20))*ones(npoints-napu+1,1)];
  [hM,slb_iter,socp_iter,func_iter,feasible] = ...
    directFIRsymmetric_slb(@directFIRsymmetric_sdp_mmsePW, ...
                           hM1_sd_x,hM1_sd_delta,na, ...
                           wa,Ad,Adu_sdp,Adl_sdp,Wa, ...
                           maxiter,tol,ctol,verbose);
  if feasible==false
    error("directFIRsymmetric_slb failed!");
  endif
endif
print_polynomial(hM1_sd_sdp,"hM1_sd_sdp",nscale);
print_polynomial(hM1_sd_sdp,"hM1_sd_sdp", ...
                 strcat(strf,"_hM1_sd_sdp_coef.m"),nscale);
[hM1_digits_sd_sdp,hM1_adders_sd_sdp]=SDadders(hM1_sd_sdp,nbits);
Esq1_sd_sdp=directFIRsymmetricEsqPW(hM1_sd_sdp,waf,Adf,Waf);

% Calculate response
A_hM1=directFIRsymmetricA(wa,hM1);
A_hM1_sd=directFIRsymmetricA(wa,hM1_sd);
A_hM1_sd_Ito=directFIRsymmetricA(wa,hM1_sd_Ito);
A_hM1_sd_sdp=directFIRsymmetricA(wa,hM1_sd_sdp);

% Find maximum stop band response
rsb=[1:nasl,nasu:npoints];
max_sb_A_hM1=20*log10(max(abs(A_hM1(rsb))))
max_sb_A_hM1_sd=20*log10(max(abs(A_hM1_sd(rsb))))
max_sb_A_hM1_sd_Ito=20*log10(max(abs(A_hM1_sd_Ito(rsb))))
max_sb_A_hM1_sd_sdp=20*log10(max(abs(A_hM1_sd_sdp(rsb))))

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & %4.1f & & \\\\\n",Esq1,max_sb_A_hM1);
fprintf(fid,"%d-bit %d-signed-digit & %8.6f & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq1_sd,max_sb_A_hM1_sd,hM1_digits_sd,hM1_adders_sd);
fprintf(fid,"%d-bit %d-signed-digit(Ito) & %8.6f & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq1_sd_Ito,max_sb_A_hM1_sd_Ito, ...
        hM1_digits_sd_Ito,hM1_adders_sd_Ito);
fprintf(fid,"%d-bit %d-signed-digit(SDP) & %8.6f & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq1_sd_sdp,max_sb_A_hM1_sd_sdp, ...
        hM1_digits_sd_sdp,hM1_adders_sd_sdp);
fclose(fid);

% Plot amplitude response
subplot(211)
plot(wa*0.5/pi,20*log10(abs(A_hM1)),"linestyle","-", ...
     wa*0.5/pi,20*log10(abs(A_hM1_sd)),"linestyle",":", ...
     wa*0.5/pi,20*log10(abs(A_hM1_sd_Ito)),"linestyle","--", ...
     wa*0.5/pi,20*log10(abs(A_hM1_sd_sdp)),"linestyle","-.");
ylabel("Amplitude(dB)");
axis([0 0.5 -2 1]);
strt=sprintf("Direct-form symmetric bandpass filter pass-band \
(nbits=%d,ndigits=%d) : fapl=%g,fapu=%g,dBap=%g",nbits,ndigits,fapl,fapu,dBap);
title(strt);
legend("exact","s-d","s-d(Ito)","s-d(SDP)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
subplot(212)
plot(wa*0.5/pi,20*log10(abs(A_hM1)),"linestyle","-", ...
     wa*0.5/pi,20*log10(abs(A_hM1_sd)),"linestyle",":", ...
     wa*0.5/pi,20*log10(abs(A_hM1_sd_Ito)),"linestyle","--", ...
     wa*0.5/pi,20*log10(abs(A_hM1_sd_sdp)),"linestyle","-.", ...
     wa*0.5/pi,20*log10(abs(Adu)),"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 -30]);
strt=sprintf("Direct-form symmetric bandpass filter stop-band \
(nbits=%d,ndigits=%d) : fasl=%g,fasu=%g,dBas=%g",nbits,ndigits,fasl,fasu,dBas);
title(strt);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"npoints=%g %% Frequency points across the band\n",npoints);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fasl=%g %% Amplitude stop band(1) lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band(1) upper edge\n",fasu);
fprintf(fid,"dBas=%d %% Amplitude stop band(1) peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%d %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Amplitude upper stop band weight\n",Wasu);
fclose(fid);

% Save results
save sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.mat ...
     tol ctol nbits nscale ndigits ndigits_alloc npoints ...
     fapl fapu dBap Wap fasl fasu dBas Wasl Wasu hM1_sd_sdp
       
% Done
toc;
diary off
movefile sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.diary.tmp ...
         sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.diary;
