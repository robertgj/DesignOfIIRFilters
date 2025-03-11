% sdp_relaxation_directFIRhilbert_bandpass_12_nbits_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

% SDP relaxation optimisation of a direct-form FIR Hilbert filter
% with 12-bit signed-digit coefficients

test_common;

strf="sdp_relaxation_directFIRhilbert_bandpass_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Options
sdp_relaxation_directFIRhilbert_bandpass_12_nbits_test_use_unity_passband=false

tic;

maxiter=2000
ftol=1e-5;
ctol=ftol;
verbose=true;

% Hilbert filter frequency specification
M=8;
fasl=0.1;fapl=0.16325;fapu=0.5-fapl;fasu=0.5-fasl;
dBap=0.1;Wap=2;Wat=0.001;dBas=35;Was=1;
if sdp_relaxation_directFIRhilbert_bandpass_12_nbits_test_use_unity_passband
  Ad_passband=-1;
else
  Ad_passband=-(10^(-dBap/40));
endif
npoints=5000;
wa=(0:((npoints)-1))'*pi/(npoints);
nasl=ceil(npoints*fasl/0.5)+1;
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
nasu=floor(npoints*fasu/0.5)+1;
Ad=[zeros(napl-1,1);Ad_passband*ones(napu-napl+1,1);zeros(npoints-napu,1)];
Adl=-[(10^(-dBas/20))*ones(nasl,1); ...
      ones(nasu-nasl-1,1); ...
      (10^(-dBas/20))*ones(npoints-nasu+1,1)];
Adu=-[zeros(napl-1,1); ...
      (10^(-dBap/20))*ones(napu-napl+1,1); ...
      zeros(npoints-napu,1)];
Wa=[Was*ones(nasl,1); ...
    Wat*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Wat*ones(nasu-napu-1,1); ...
    Was*ones(npoints-nasu+1,1)];

% Sanity check
nch=[1, nasl-1, nasl, nasl+1, napl-1, napl, napl+1, ...
        napu-1, napu, napu+1, nasu-1, nasu, nasu+1, npoints];
printf("fa=[ ");printf("%d ",wa(nch)*0.5/pi);printf("]\n");
printf("Ad=[ ");printf("%d ",Ad(nch));printf("]\n");
printf("Adu=[ ");printf("%d ",Adu(nch));printf("]\n");
printf("Adl=[ ");printf("%d ",Adl(nch));printf("]\n");
printf("Wa=[ ");printf("%d ",Wa(nch));printf("]\n");

% Hilbert band-pass filter from directFIRhilbert_bandpass_slb_test.m
directFIRhilbert_bandpass_slb_test_hM2_coef;

% Find the exact coefficient error
waf=2*pi*[0 fasl fapl fapu fasu 0.5];
Adf=[0 0 Ad_passband 0 0];
Waf=[Was Wat Wap Wat Was];
Esq1=directFIRhilbertEsqPW(hM2,waf,Adf,Waf);
printf("Esq1=%g\n",Esq1);

% Allocate digits
nbits=12;
nscale=2^(nbits-1);
ndigits=2;
ndigits_alloc=directFIRhilbert_allocsd_Ito(nbits,ndigits,hM2,waf,Adf,Waf);
hM_allocsd_digits=int16(ndigits_alloc);
printf("hM_allocsd_digits=[ ");
printf("%2d ",hM_allocsd_digits);printf("]';\n");
print_polynomial(hM_allocsd_digits,"hM_allocsd_digits", ...
                 strcat(strf,"_hM_allocsd_digits.m"),"%2d");

% Find the signed-digit approximations to hM2
[hM2_sd,hM2_sdu,hM2_sdl]=flt2SD(hM2,nbits,ndigits);
[hM2_digits_sd,hM2_adders_sd]=SDadders(hM2_sd,nbits);
print_polynomial(hM2_sd,"hM2_sd",nscale);
print_polynomial(hM2_sd,"hM2_sd",strcat(strf,"_hM2_sd_coef.m"),nscale);
% Find the signed-digit approximations to hM2 with Ito allocation
[hM2_sd_Ito,hM2_sdu_Ito,hM2_sdl_Ito]=flt2SD(hM2,nbits,ndigits_alloc);
[hM2_digits_sd_Ito,hM2_adders_sd_Ito]=SDadders(hM2_sd_Ito,nbits);
print_polynomial(hM2_sd_Ito,"hM2_sd_Ito",nscale);
print_polynomial(hM2_sd_Ito,"hM2_sd_Ito", ...
                 strcat(strf,"_hM2_sd_Ito_coef.m"),nscale);

% Find initial mean-squared errrors
Esq1=directFIRhilbertEsqPW(hM2,waf,Adf,Waf);
Esq1_sd=directFIRhilbertEsqPW(hM2_sd,waf,Adf,Waf);
Esq1_sd_Ito=directFIRhilbertEsqPW(hM2_sd_Ito,waf,Adf,Waf);

% Define filter coefficients
hM2_sd_delta=(hM2_sdu_Ito-hM2_sdl_Ito)/2;
hM2_sd_x=(hM2_sdu_Ito+hM2_sdl_Ito)/2;
[Esq1_sd_x,gradEsq1_sd_x,Q,q]=directFIRhilbertEsqPW(hM2_sd_x,waf,Adf,Waf);

% Run the SeDuMi problem
[hM2_sd_sdp,socp_iter,func_iter,feasible] = ...
sdp_relaxation_directFIRhilbert_mmsePW([],hM2_sd_x,hM2_sd_delta,...
                                       [nasl,napl,napu,nasu], ...
                                       wa,Ad,Adu,Adl,Wa, ...
                                       maxiter,ftol,ctol,verbose);
if feasible==false
  error("sdp_relaxation_directFIRhilbert_mmsePW failed!");
endif
print_polynomial(hM2_sd_sdp,"hM2_sd_sdp",nscale);
print_polynomial(hM2_sd_sdp,"hM2_sd_sdp", ...
                 strcat(strf,"_hM2_sd_sdp_coef.m"),nscale);
[hM2_digits_sd_sdp,hM2_adders_sd_sdp]=SDadders(hM2_sd_sdp,nbits);
Esq1_sd_sdp=directFIRhilbertEsqPW(hM2_sd_sdp,waf,Adf,Waf);

% Calculate response
A_hM2=directFIRhilbertA(wa,hM2);
A_hM2_sd=directFIRhilbertA(wa,hM2_sd);
A_hM2_sd_Ito=directFIRhilbertA(wa,hM2_sd_Ito);
A_hM2_sd_sdp=directFIRhilbertA(wa,hM2_sd_sdp);

% Find maximum pass-band response
psb=[napl:napu];
max_sb_A_hM2=       max(abs(20*log10(abs(A_hM2(psb)))))
max_sb_A_hM2_sd=    max(abs(20*log10(abs(A_hM2_sd(psb)))))
max_sb_A_hM2_sd_Ito=max(abs(20*log10(abs(A_hM2_sd_Ito(psb)))))
max_sb_A_hM2_sd_sdp=max(abs(20*log10(abs(A_hM2_sd_sdp(psb)))))

% Find maximum stop-band response
ssb=[1:nasl,nasu:npoints];
max_sb_A_hM2=       max(20*log10(abs(A_hM2(ssb))))
max_sb_A_hM2_sd=    max(20*log10(abs(A_hM2_sd(ssb))))
max_sb_A_hM2_sd_Ito=max(20*log10(abs(A_hM2_sd_Ito(ssb))))
max_sb_A_hM2_sd_sdp=max(20*log10(abs(A_hM2_sd_sdp(ssb))))

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %10.4g & %10.4g & & \\\\\n",Esq1,max_sb_A_hM2);
fprintf(fid,"%d-bit %d-signed-digit & %10.4g & %10.4g & %d & %d \\\\\n", ...
        nbits,ndigits,Esq1_sd,max_sb_A_hM2_sd,hM2_digits_sd,hM2_adders_sd);
fprintf(fid,"%d-bit %d-signed-digit(Ito) & %10.4g & %10.4g & %d & %d \\\\\n", ...
        nbits,ndigits,Esq1_sd_Ito,max_sb_A_hM2_sd_Ito, ...
        hM2_digits_sd_Ito,hM2_adders_sd_Ito);
fprintf(fid,"%d-bit %d-signed-digit(SDP) & %10.4g & %10.4g & %d & %d \\\\\n", ...
        nbits,ndigits,Esq1_sd_sdp,max_sb_A_hM2_sd_sdp, ...
        hM2_digits_sd_sdp,hM2_adders_sd_sdp);
fclose(fid);

% Plot amplitude response
plot(wa*0.5/pi,20*log10(abs(A_hM2)),"linestyle","-", ...
     wa*0.5/pi,20*log10(abs(A_hM2_sd)),"linestyle",":", ...
     wa*0.5/pi,20*log10(abs(A_hM2_sd_Ito)),"linestyle","--", ...
     wa*0.5/pi,20*log10(abs(A_hM2_sd_sdp)),"linestyle","-.");
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.25 -40 10]);
strt=sprintf(["Direct-form Hilbert filter (nbits=%d,ndigits=%d) : ", ...
 "fapl=%g,fapu=%g"],nbits,ndigits,fapl,fapu);
title(strt);
legend("exact","s-d","s-d(Ito)","s-d(SDP)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot passband amplitude response
plot(wa*0.5/pi,20*log10(abs(A_hM2)),"linestyle","-", ...
     wa*0.5/pi,20*log10(abs(A_hM2_sd)),"linestyle",":", ...
     wa*0.5/pi,20*log10(abs(A_hM2_sd_Ito)),"linestyle","--", ...
     wa*0.5/pi,20*log10(abs(A_hM2_sd_sdp)),"linestyle","-.");
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0.15 0.25 -0.2 0.2]);
strt=sprintf(["Direct-form Hilbert filter (nbits=%d,ndigits=%d) : ", ...
 "fapl=%g,fapu=%g"],nbits,ndigits,fapl,fapu);
title(strt);
legend("exact","s-d","s-d(Ito)","s-d(SDP)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"M=%d %% Number of distinct coefficients\n",M);
fprintf(fid,"nbits=%d %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%d %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"npoints=%d %% Frequency points across the band\n",npoints);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"dBas=%g %% Amplitude stop band peak ripple\n",dBas);
fclose(fid);

% Save results
eval(sprintf(["save %s.mat ", ...
 "sdp_relaxation_directFIRhilbert_bandpass_12_nbits_test_use_unity_passband ", ...
 "ftol ctol nbits nscale ndigits ndigits_alloc ", ...
 "npoints fasl fapl fapu fasu dBap Wap Wat dBas Was hM2 hM2_sd_sdp"],strf));
      
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
