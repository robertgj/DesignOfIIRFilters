% comparison_schurOneMPAlatticeDoublyPipelinedAntiAliased ...
% ... _bandpass_hilbert_12_nbits_test.m 
%
% Compare branch-and-bound and SOCP-relaxation search for the
% 12-bit, average of 3-signed-digit, coefficients of a band-pass Hilbert
% filter implemented as parallel Schur one-multiplier doubly pipelined
% allpass lattice filters in series with a Butterworth half-band
% anti-aliasing filter.

% Copyright (C) 2026 Robert G. Jenssen

test_common;

strs=["schurOneMPAlatticeDoublyPipelinedAntiAliased", ...
      "_bandpass_hilbert_12_nbits_test"];
strf=strcat("comparison_",strs);

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

tol=1e-12;
nbits=12;
nscale=2^(nbits-1);
nbits_fir=12;
nscale_fir=2^(nbits_fir-1);
ndigits=3;

% Filter specification
R=2;difference=true;polyphase=false;
fasl=0.05;fapl=0.1;fapu=0.2;fasu=0.25;fasuu=0.3;
Wasl=20;Watl=0.001;Wap=1;Watu=0.001;Wasu=0.01;
fppl=0.12;fppu=0.18;pp=3.5;ppr=0.008;Wpp=2;
ftpl=0.12;ftpu=0.18;tp=16;tpr=0.08;Wtp=1;
fdpl=fapl;fdpu=fapu;dp=0;Wdp=0;
% Additional z^-2 delay introduced by doubly-pipelined implementation
Tz2=2;
% Butterworth half-band anti-aliasing filter
maa=11;
faap=0.25;

% Load filter coefficients
parallel_allpass_socp_slb_bandpass_hilbert_R2_test_Da1_coef;
parallel_allpass_socp_slb_bandpass_hilbert_R2_test_Db1_coef;
% Convert the R=2 band-pass Hilbert filter to parallel Schur lattice filters
Da0=Da1(:)';clear Da1;
Db0=Db1(:)';clear Db1;
[A1k0,~,~,~]=tf2schurOneMlattice(fliplr(Da0),Da0);
[A2k0,~,~,~]=tf2schurOneMlattice(fliplr(Db0),Db0);
print_polynomial(A1k0,"A1k0",strcat(strf,"_A1k0_coef.m"));
print_polynomial(A2k0,"A2k0",strcat(strf,"_A2k0_coef.m"));

% Convert the anti-aliasing filter to parallel Schur lattice filters
[Naa,Daa]=butter(maa,2*faap);
[Aaa1_0,Aaa2_0]=tf2pa(Naa,Daa);
Aaa1_0(find(abs(Aaa1_0)<tol))=0;
Aaa2_0(find(abs(Aaa2_0)<tol))=0;
print_polynomial(Aaa1_0,"Aaa1_0",strcat(strf,"_Aaa1_0_coef.m"));
print_polynomial(Aaa2_0,"Aaa2_0",strcat(strf,"_Aaa2_0_coef.m"));
[Aaa1k0,~,~,~]=tf2schurOneMlattice(fliplr(Aaa1_0),Aaa1_0);
[Aaa2k0,~,~,~]=tf2schurOneMlattice(fliplr(Aaa2_0),Aaa2_0);
% The anti-aliasing filter is assumed to be Butterworth half-band (ie:R=2)!
Aaa1k0(1:2:end)=0;
Aaa2k0(1:2:end)=0;
print_polynomial(Aaa1k0,"Aaa1k0",strcat(strf,"_Aaa1k0_coef.m"));
print_polynomial(Aaa2k0,"Aaa2k0",strcat(strf,"_Aaa2k0_coef.m"));

% Coefficients found by SOCP-relaxation search
eval(strcat("socp_relaxation_",strs,"_A1k0_sd_coef;"));
eval(strcat("socp_relaxation_",strs,"_A2k0_sd_coef;"));
eval(strcat("socp_relaxation_",strs,"_Aaa1k0_sd_coef;"));
eval(strcat("socp_relaxation_",strs,"_Aaa2k0_sd_coef;"));
socp_sd=[A1k0_sd(:);A2k0_sd(:);Aaa1k0_sd(:);Aaa2k0_sd(:)];
[socp_sd_digits,socp_sd_adders]=SDadders(socp_sd,nbits);
eval(strcat("socp_relaxation_",strs,"_A1k_allocsd_digits;"));
eval(strcat("socp_relaxation_",strs,"_A2k_allocsd_digits;"));
eval(strcat("socp_relaxation_",strs,"_Aaa1k_allocsd_digits;"));
eval(strcat("socp_relaxation_",strs,"_Aaa2k_allocsd_digits;"));
socp_allocsd=[A1k_allocsd_digits(:);A2k_allocsd_digits(:); ...
              Aaa1k_allocsd_digits(:);Aaa2k_allocsd_digits(:)];
eval(strcat("socp_relaxation_",strs,"_A1k_Lim_sd_coef;"));
eval(strcat("socp_relaxation_",strs,"_A2k_Lim_sd_coef;"));
eval(strcat("socp_relaxation_",strs,"_Aaa1k_Lim_sd_coef;"));
eval(strcat("socp_relaxation_",strs,"_Aaa2k_Lim_sd_coef;"));
socp_Lim_sd=[A1k_Lim_sd(:);A2k_Lim_sd(:);Aaa1k_Lim_sd(:);Aaa2k_Lim_sd(:)];
[socp_Lim_sd_digits,socp_Lim_sd_adders]=SDadders(socp_Lim_sd,nbits);
eval(strcat("socp_relaxation_",strs,"_A1k_min_coef;"));
eval(strcat("socp_relaxation_",strs,"_A2k_min_coef;"));
eval(strcat("socp_relaxation_",strs,"_Aaa1k_min_coef;"));
eval(strcat("socp_relaxation_",strs,"_Aaa2k_min_coef;"));
socp_A1k_min=A1k_min(:);
socp_A2k_min=A2k_min(:);
socp_Aaa1k_min=Aaa1k_min(:);
socp_Aaa2k_min=Aaa2k_min(:);
socp_min=[A1k_min(:);A2k_min(:);Aaa1k_min(:);Aaa2k_min(:)];
[socp_min_digits,socp_min_adders]=SDadders(socp_min,nbits);

% Coefficients found by branch-and-bound search
eval(strcat("branch_bound_",strs,"_A1k0_sd_coef;"));
eval(strcat("branch_bound_",strs,"_A2k0_sd_coef;"));
eval(strcat("branch_bound_",strs,"_Aaa1k0_sd_coef;"));
eval(strcat("branch_bound_",strs,"_Aaa2k0_sd_coef;"));
bandb_sd=[A1k0_sd(:);A2k0_sd(:);Aaa1k0_sd(:);Aaa2k0_sd(:)];
eval(strcat("branch_bound_",strs,"_A1k_allocsd_digits;"));
eval(strcat("branch_bound_",strs,"_A2k_allocsd_digits;"));
eval(strcat("branch_bound_",strs,"_Aaa1k_allocsd_digits;"));
eval(strcat("branch_bound_",strs,"_Aaa2k_allocsd_digits;"));
bandb_allocsd=[A1k_allocsd_digits(:);A2k_allocsd_digits(:); ...
               Aaa1k_allocsd_digits(:);Aaa2k_allocsd_digits(:)];
eval(strcat("branch_bound_",strs,"_A2k_min_coef;"));
eval(strcat("branch_bound_",strs,"_Aaa1k_min_coef;"));
eval(strcat("branch_bound_",strs,"_Aaa2k_min_coef;"));
eval(strcat("branch_bound_",strs,"_A1k_Lim_sd_coef;"));
eval(strcat("branch_bound_",strs,"_A2k_Lim_sd_coef;"));
eval(strcat("branch_bound_",strs,"_Aaa1k_Lim_sd_coef;"));
eval(strcat("branch_bound_",strs,"_Aaa2k_Lim_sd_coef;"));
bandb_Lim_sd=[A1k_Lim_sd(:);A2k_Lim_sd(:);Aaa1k_Lim_sd(:);Aaa2k_Lim_sd(:)];
eval(strcat("branch_bound_",strs,"_A1k_min_coef;"));
eval(strcat("branch_bound_",strs,"_A2k_min_coef;"));
eval(strcat("branch_bound_",strs,"_Aaa1k_min_coef;"));
eval(strcat("branch_bound_",strs,"_Aaa2k_min_coef;"));
bandb_A1k_min=A1k_min(:);
bandb_A2k_min=A2k_min(:);
bandb_Aaa1k_min=Aaa1k_min(:);
bandb_Aaa2k_min=Aaa2k_min(:);
bandb_min=[A1k_min(:);A2k_min(:);Aaa1k_min(:);Aaa2k_min(:)];
[bandb_min_digits,bandb_min_adders]=SDadders(bandb_min,nbits);

% Sanity checks
if any(bandb_sd ~= socp_sd)
  error("any(bandb_sd ~= socp_sd)");
endif
if any(bandb_allocsd ~= socp_allocsd)
  error("any(bandb_allocsd ~= socp_allocsd)");
endif
if any(bandb_Lim_sd ~= socp_Lim_sd)
  error("any(bandb_Lim_sd ~= socp_Lim_sd)");
endif

exact_sd_digits=socp_sd_digits;
exact_sd_adders=socp_sd_adders;

exact_Lim_sd_digits=socp_Lim_sd_digits;
exact_Lim_sd_adders=socp_Lim_sd_adders;

print_polynomial(A1k0_sd,"A1k0_sd", ...
                 strcat(strf,"_A1k0_sd_coef.m"),nscale);
print_polynomial(A2k0_sd,"A2k0_sd", ...
                 strcat(strf,"_A2k0_sd_coef.m"),nscale);
print_polynomial(Aaa1k0_sd,"Aaa1k0_sd", ...
                 strcat(strf,"_Aaa1k0_sd_coef.m"),nscale);
print_polynomial(Aaa2k0_sd,"Aaa2k0_sd", ...
                 strcat(strf,"_Aaa2k0_sd_coef.m"),nscale);

print_polynomial(A1k_allocsd_digits,"A1k_allocsd_digits", ...
                 strcat(strf,"_A1k_allocsd_digits.m"),"%2d");
print_polynomial(A2k_allocsd_digits,"A2k_allocsd_digits", ...
                 strcat(strf,"_A2k_allocsd_digits.m"),"%2d");
print_polynomial(Aaa1k_allocsd_digits,"Aaa1k_allocsd_digits", ...
                 strcat(strf,"_Aaa1k_allocsd_digits.m"),"%2d");
print_polynomial(Aaa2k_allocsd_digits,"Aaa2k_allocsd_digits", ...
                 strcat(strf,"_Aaa2k_allocsd_digits.m"),"%2d");

print_polynomial(A1k_Lim_sd,"A1k_Lim_sd", ...
                 strcat(strf,"_A1k_Lim_sd_coef.m"),nscale);
print_polynomial(A2k_Lim_sd,"A2k_Lim_sd", ...
                 strcat(strf,"_A2k_Lim_sd_coef.m"),nscale);
print_polynomial(Aaa1k_Lim_sd,"Aaa1k_Lim_sd", ...
                 strcat(strf,"_Aaa1k_Lim_sd_coef.m"),nscale);
print_polynomial(Aaa2k_Lim_sd,"Aaa2k_Lim_sd", ...
                 strcat(strf,"_Aaa2k_Lim_sd_coef.m"),nscale);

% Avoid confusion
clear socp_k0_sd bandb_k0_sd socp_k_Lim_sd bandb_k_Lim_sd
clear A1k_min A2k_min Aaa1k_min Aaa2k_min
clear A1k_allocsd_digits A2k_allocsd_digits
clear Aaa1k_allocsd_digits Aaa2k_allocsd_digits
clear socp_allocsd socp_sd_digits socp_allocsd_adders
clear socp_Lim_sd_digits socp_Lim_sd_adders
clear socp_allocsd bandb_sd_digits bandb_sd_adders
clear bandb_Lim_sd_digits bandb_Lim_sd_adders

% Set coeficient ranges
NA1k=length(A1k0_sd);
NA2k=length(A2k0_sd);
NAaa1k=length(Aaa1k0_sd);
NAaa2k=length(Aaa2k0_sd);
NA=NA1k+NA2k+NAaa1k+NAaa2k;
RA1k=1:NA1k;
RA2k=(NA1k+1):(NA1k+NA2k);
RAaa1k=(NA1k+NA2k+1):(NA1k+NA2k+NAaa1k);
RAaa2k=(NA1k+NA2k+NAaa1k+1):(NA1k+NA2k+NAaa1k+NAaa2k);

%
% Frequency vectors
%
n=1000;
f=(0:(n-1))'*0.5/n;
w=2*pi*f;

% Desired squared magnitude response
wa=w;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Rap=[napl:napu];
Ras=[1:nasl,nasu:length(wa)];
Asqd=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(length(wa)-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(length(wa)-nasu+1,1)];
% Sanity checks
nchka=[1, ...
       nasl-1,nasl,nasl+1, ...
       napl-1,napl,napl+1, ...
       napu-1,napu,napu+1, ...
       nasu-1,nasu,nasu+1,...
       length(wa)-1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Desired pass-band phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=wa(nppl:nppu);
Pd=(pp*pi)-(tp*wp);
Wp=Wpp*ones(nppu-nppl+1,1);
Pz2=-wp*Tz2;

% Desired pass-band group delay response
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
wt=wa(ntpl:ntpu);
Td=tp*ones(length(wt),1);
Wt=Wtp*ones(length(wt),1);

% Desired pass-band dAsqdw response
ndpl=floor(n*fdpl/0.5)+1;
ndpu=ceil(n*fdpu/0.5)+1;
wd=wa(ndpl:ndpu);
Dd=dp*ones(length(wd),1);
Wd=Wdp*ones(length(wd),1);

%
% Calculate responses
%

fpassl=0.08;fpassu=0.22;
npassl=floor(n*fpassl/0.5)+1;
npassu=ceil(n*fpassu/0.5)+1;
wpass=w(npassl:npassu);
Rpass=npassl:npassu;
wpass=w(Rpass);
Rpp=nppl:nppu;
Rtp=ntpl:ntpu;
Rdp=ndpl:ndpu;

% Calculate "exact" response
exact_Asq=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
          (w,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);
exact_P=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
          (w,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);
exact_T=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
          (w,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);
exact_dAsqdw=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
          (w,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);

% Calculate "exact" errors
exact_Asq_pass_error=max(abs(10*log10(exact_Asq(Rap))));
exact_Asq_stop_error=min(abs(10*log10(exact_Asq(Ras))));
exact_P_pass_error=max(abs(exact_P(Rpp)-Pz2-Pd+(2*pi))/pi);
exact_T_pass_error=max(abs(exact_T(Rtp)-Tz2-Td));
exact_dAsqdw_pass_error=max(abs(exact_dAsqdw(Rdp)-Dd));
exact_Esq=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
            (A1k0,A2k0,difference,Aaa1k0,Aaa2k0, ...
             wa,Asqd,Wa,wt,Td+Tz2,Wt,wp,Pd+Pz2,Wp,wd,Dd,Wd);

% Calculate signed-digit response
exact_sd_Asq=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
       (w,A1k0_sd,A2k0_sd,difference,Aaa1k0_sd,Aaa2k0_sd);
exact_sd_P=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
       (w,A1k0_sd,A2k0_sd,difference,Aaa1k0_sd,Aaa2k0_sd);
exact_sd_T=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
       (w,A1k0_sd,A2k0_sd,difference,Aaa1k0_sd,Aaa2k0_sd);
exact_sd_dAsqdw=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
       (w,A1k0_sd,A2k0_sd,difference,Aaa1k0_sd,Aaa2k0_sd);

% Calculate signed-digit errors
exact_sd_Asq_pass_error=max(abs(10*log10(exact_sd_Asq(Rap))));
exact_sd_Asq_stop_error=min(abs(10*log10(exact_sd_Asq(Ras))));
exact_sd_P_pass_error=max(abs(exact_sd_P(Rpp)-Pz2-Pd+(2*pi))/pi);
exact_sd_T_pass_error=max(abs(exact_sd_T(Rtp)-Tz2-Td));
exact_sd_dAsqdw_pass_error=max(abs(exact_sd_dAsqdw(Rdp)-Dd));
exact_sd_Esq=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
         (A1k0_sd,A2k0_sd,difference,Aaa1k0_sd,Aaa2k0_sd, ...
          wa,Asqd,Wa,wt,Td+Tz2,Wt,wp,Pd+Pz2,Wp,wd,Dd,Wd);

% Calculate signed-digit Lim response
exact_Lim_sd_Asq=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
       (w,A1k_Lim_sd,A2k_Lim_sd,difference,Aaa1k_Lim_sd,Aaa2k_Lim_sd);
exact_Lim_sd_P=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
       (w,A1k_Lim_sd,A2k_Lim_sd,difference,Aaa1k_Lim_sd,Aaa2k_Lim_sd);
exact_Lim_sd_T=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
       (w,A1k_Lim_sd,A2k_Lim_sd,difference,Aaa1k_Lim_sd,Aaa2k_Lim_sd);
exact_Lim_sd_dAsqdw=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
       (w,A1k_Lim_sd,A2k_Lim_sd,difference,Aaa1k_Lim_sd,Aaa2k_Lim_sd);

% Calculate signed-digit Lim errors
exact_Lim_sd_Asq_pass_error=max(abs(10*log10(exact_Lim_sd_Asq(Rap))));
exact_Lim_sd_Asq_stop_error=min(abs(10*log10(exact_Lim_sd_Asq(Ras))));
exact_Lim_sd_P_pass_error=max(abs(exact_Lim_sd_P(Rpp)-Pz2-Pd+(2*pi))/pi);
exact_Lim_sd_T_pass_error=max(abs(exact_Lim_sd_T(Rtp)-Tz2-Td));
exact_Lim_sd_dAsqdw_pass_error=max(abs(exact_Lim_sd_dAsqdw(Rdp)-Dd));
exact_Lim_sd_Esq=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
         (A1k_Lim_sd,A2k_Lim_sd,difference,Aaa1k_Lim_sd,Aaa2k_Lim_sd, ...
          wa,Asqd,Wa,wt,Td+Tz2,Wt,wp,Pd+Pz2,Wp,wd,Dd,Wd);

% Calculate branch-and-bound response
bandb_Asq=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
  (w,bandb_A1k_min,bandb_A2k_min,difference,bandb_Aaa1k_min,bandb_Aaa2k_min);
bandb_P=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
  (w,bandb_A1k_min,bandb_A2k_min,difference,bandb_Aaa1k_min,bandb_Aaa2k_min);
bandb_T=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
  (w,bandb_A1k_min,bandb_A2k_min,difference,bandb_Aaa1k_min,bandb_Aaa2k_min);
bandb_dAsqdw=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
  (w,bandb_A1k_min,bandb_A2k_min,difference,bandb_Aaa1k_min,bandb_Aaa2k_min);

% Calculate branch-and-bound errors
bandb_Asq_pass_error=max(abs(10*log10(bandb_Asq(Rap))));
bandb_Asq_stop_error=min(abs(10*log10(bandb_Asq(Ras))));
bandb_P_pass_error=max(abs(bandb_P(Rpp)-Pz2-Pd+(2*pi))/pi);
bandb_T_pass_error=max(abs(bandb_T(Rtp)-Tz2-Td));
bandb_dAsqdw_pass_error=max(abs(bandb_dAsqdw(Rdp)-Dd));
bandb_Esq=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
  (bandb_A1k_min,bandb_A2k_min,difference,bandb_Aaa1k_min,bandb_Aaa2k_min, ...
   wa,Asqd,Wa,wt,Td+Tz2,Wt,wp,Pd+Pz2,Wp,wd,Dd,Wd);

% Calculate SOCP-relaxation response
socp_Asq=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
  (w,socp_A1k_min,socp_A2k_min,difference,socp_Aaa1k_min,socp_Aaa2k_min);
socp_P=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
  (w,socp_A1k_min,socp_A2k_min,difference,socp_Aaa1k_min,socp_Aaa2k_min);
socp_T=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
  (w,socp_A1k_min,socp_A2k_min,difference,socp_Aaa1k_min,socp_Aaa2k_min);
socp_dAsqdw=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
  (w,socp_A1k_min,socp_A2k_min,difference,socp_Aaa1k_min,socp_Aaa2k_min);

% Calculate SOCP-relaxation errors
socp_Asq_pass_error=max(abs(10*log10(socp_Asq(Rap))));
socp_Asq_stop_error=min(abs(10*log10(socp_Asq(Ras))));
socp_P_pass_error=max(abs(socp_P(Rpp)-Pz2-Pd+(2*pi))/pi);
socp_T_pass_error=max(abs(socp_T(Rtp)-Tz2-Td));
socp_dAsqdw_pass_error=max(abs(socp_dAsqdw(Rdp)-Dd));
socp_Esq=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
  (socp_A1k_min,socp_A2k_min,difference,socp_Aaa1k_min,socp_Aaa2k_min, ...
   wa,Asqd,Wa,wt,Td+Tz2,Wt,wp,Pd+Pz2,Wp,wd,Dd,Wd);

% Plot amplitude pass-band response error
ha=plot(wa*0.5/pi,10*log10([exact_Asq,exact_Lim_sd_Asq,bandb_Asq,socp_Asq]));
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0.08 0.22 [-0.25,0.05]]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
strt=sprintf(["Schur one-multiplier lattice bandpass Hilbert filter :", ...
              " ndigits=%d,nbits=%d,fapl=%g,fapu=%g"], ...
             ndigits,nbits,fapl,fapu);
title(strt);
legend("Floating point","S-D(Lim)","B-and-B","SOCP-relax");
legend("location","south");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_pass"),"-dpdflatex");
close

% Plot amplitude stop-band response
ha=plot(wa*0.5/pi,10*log10([exact_Asq,exact_Lim_sd_Asq,bandb_Asq,socp_Asq]));
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0 0.5 -50 -10]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
strt=sprintf(["Schur one-multiplier lattice bandpass Hilbert filter :", ...
              " ndigits=%d,nbits=%d,fasl=%g,fapl=%g,fapu=%g,fasu=%g"], ...
             ndigits,nbits,fasl,fapl,fapu,fasu);
title(strt);
legend("Floating point","S-D(Lim)","B-and-B","SOCP-relax");
legend("location","northeast");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot phase pass-band response for signed-digit responses
P_schur_all=[exact_P,exact_Lim_sd_P,bandb_P,socp_P]+(w*(tp+Tz2));
ha=plot(wpass*0.5/pi,mod(P_schur_all(Rpass,:)/pi,2));
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0.08 0.22 mod(pp,2)+0.001*[-1 1]]);
grid("on");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$)");
strt=sprintf(["Schur one-multiplier lattice bandpass Hilbert filter :", ...
              " ndigits=%d,nbits=%d,fppl=%g,fppu=%g"], ...
             ndigits,nbits,fppl,fppu);
title(strt);
legend("Floating point","S-D(Lim)","B-and-B","SOCP-relax");
legend("location","northeast");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_phase"),"-dpdflatex");
close

% Plot delay pass-band response for signed-digit responses
ha=plot(w*0.5/pi,[exact_T,exact_Lim_sd_T,bandb_T,socp_T]-Tz2);
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0.08 0.22 tp+0.04*[-1 1]]);
grid("on");
xlabel("Frequency");
ylabel("Delay(samples)");
strt=sprintf(["Schur one-multiplier lattice bandpass Hilbert filter :", ...
              " ndigits=%d,nbits=%d,ftpl=%g,ftpu=%g"], ...
             ndigits,nbits,ftpl,ftpu);
title(strt);
legend("Floating point","S-D(Lim)","B-and-B","SOCP-relax");
legend("location","northwest");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Plot dAsqdw pass-band signed-digit responses
ha=plot(w*0.5/pi,[exact_dAsqdw,exact_Lim_sd_dAsqdw,bandb_dAsqdw,socp_dAsqdw]);
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0.08 0.22 -0.8 0.8]);
grid("on");
xlabel("Frequency");
ylabel("$\\frac{d|A|^{2}}{d\\omega}$");
strt=sprintf(["Schur one-multiplier lattice bandpass Hilbert filter :", ...
              " ndigits=%d,nbits=%d,fdpl=%g,fdpu=%g"], ...
             ndigits,nbits,fdpl,fdpu);
title(strt);
legend("Floating point","S-D(Lim)","B-and-B","SOCP-relax");
legend("location","south");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_dAsqdw"),"-dpdflatex");
close

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid, ...
        ["Floating point ", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &&\\\\\n"], ...
        exact_Esq, ...
        exact_Asq_pass_error,exact_Asq_stop_error, ...
        exact_P_pass_error,exact_T_pass_error);
fprintf(fid, ...
        ["Signed-Digit ", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"], ...
        exact_sd_Esq, ...
        exact_sd_Asq_pass_error,exact_sd_Asq_stop_error, ...
        exact_sd_P_pass_error,exact_sd_T_pass_error, ...
        exact_sd_digits,exact_sd_adders);
fprintf(fid, ...
        ["Signed-Digit(Lim)",...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"], ...
        exact_Lim_sd_Esq, ...
        exact_Lim_sd_Asq_pass_error,exact_Lim_sd_Asq_stop_error, ...
        exact_Lim_sd_P_pass_error,exact_Lim_sd_T_pass_error, ...
        exact_Lim_sd_digits,exact_Lim_sd_adders);
fprintf(fid, ...
        ["Branch-and-bound ", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"], ...
        bandb_Esq, ...
        bandb_Asq_pass_error,bandb_Asq_stop_error, ...
        bandb_P_pass_error,bandb_T_pass_error, ...
        bandb_min_digits,bandb_min_adders);
fprintf(fid, ...
        ["SOCP-relaxation ", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"], ...
        socp_Esq, ...
        socp_Asq_pass_error,socp_Asq_stop_error, ...
        socp_P_pass_error,socp_T_pass_error, ...
        socp_min_digits,socp_min_adders);
fclose(fid);

%
% Compare with a non-symmetric FIR filter
%
strd="directFIRnonsymmetric_socp_slb_bandpass_hilbert_test";
eval(strcat(strd,"_h_coef;"));

strd="socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_12_nbits_test";
eval(strcat(strd,"_h_allocsd_digits;"));
eval(strcat(strd,"_h_sd_coef;"));
eval(strcat(strd,"_h_Lim_sd_coef;"));
eval(strcat(strd,"_h_min_coef;"))
socp_h=h;
socp_h_allocsd=h_allocsd_digits;
socp_h_sd=h_sd;
socp_h_Lim_sd=h_Lim_sd;
socp_h_min=h_min;

clear h_allocsd_digits h_sd h_Lim_sd h_min 

strd= ...
"branch_bound_directFIRnonsymmetric_bandpass_hilbert_12_nbits_test";
eval(strcat(strd,"_h_sd_coef;"));
eval(strcat(strd,"_h_Lim_sd_coef;"));
eval(strcat(strd,"_h_min_coef;"));
eval(strcat(strd,"_h_allocsd_digits;"));
bandb_h=h;
bandb_h_allocsd=h_allocsd_digits;
bandb_h_sd=h_sd;
bandb_h_Lim_sd=h_Lim_sd;
bandb_h_min=h_min;

clear h_allocsd_digits h_sd h_Lim_sd h_min 

% Sanity check
if any(bandb_h ~= socp_h)
  error("any(bandb_h ~= socp_h)");
endif
if any(bandb_h_allocsd ~= socp_h_allocsd)
  error("any(bandb_h_allocsd ~= socp_h_allocsd)");
endif
if any(bandb_h_sd ~= socp_h_sd)
  error("any(bandb_h_sd ~= socp_h_sd)");
endif
if any(bandb_h_Lim_sd ~= socp_h_Lim_sd)
  error("any(bandb_h_Lim)sd ~= socp_h_Lim_sd)");
endif

exact_h=h;
exact_h_allocsd_digits=bandb_h_allocsd;
exact_h_sd=bandb_h_sd;
exact_h_Lim_sd=bandb_h_Lim_sd;

print_polynomial(exact_h,"h", ...
                 strcat(strf,"_h_coef.m"));
print_polynomial(exact_h_allocsd_digits,"h_allocsd_digits", ...
                 strcat(strf,"_h_allocsd_digits.m"),"%2d");
print_polynomial(exact_h_sd,"h_sd", ...
                 strcat(strf,"_h_sd_coef.m"),nscale_fir);
print_polynomial(exact_h_Lim_sd,"h_Lim_sd", ...
                 strcat(strf,"_h_Lim_sd_coef.m"),nscale_fir);

clear socp_h_allocsd socp_h_sd socp_h_Lim_sd
clear bandb_h_allocsd bandb_h_sd bandb_h_Lim_sd 

[exact_h_sd_digits,exact_h_sd_adders]=SDadders(exact_h_sd,nbits_fir);
[exact_h_Lim_sd_digits,exact_h_Lim_sd_adders]=SDadders(exact_h_Lim_sd,nbits_fir);
[socp_h_min_digits,socp_h_min_adders]=SDadders(socp_h_min,nbits_fir);
[bandb_h_min_digits,bandb_h_min_adders]=SDadders(bandb_h_min,nbits_fir);

Asq_exact_h=directFIRnonsymmetricAsq(w,exact_h);
Asq_exact_h_pass_error=max(abs(10*log10(Asq_exact_h(Rap))));
Asq_exact_h_stop_error=min(abs(10*log10(Asq_exact_h(Ras))));
P_exact_h=directFIRnonsymmetricP(w,exact_h);
P_exact_h_pass_error=max(abs(P_exact_h(Rpp)-Pd+(6*pi))/pi);
T_exact_h=directFIRnonsymmetricT(w,exact_h);
T_exact_h_pass_error=max(abs(T_exact_h(Rtp)-Td));
Esq_exact_h=directFIRnonsymmetricEsq ...
              (exact_h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

Asq_exact_h_sd=directFIRnonsymmetricAsq(w,exact_h_sd);
Asq_exact_h_sd_pass_error=max(abs(10*log10(Asq_exact_h_sd(Rap))));
Asq_exact_h_sd_stop_error=min(abs(10*log10(Asq_exact_h_sd(Ras))));
P_exact_h_sd=directFIRnonsymmetricP(w,exact_h_sd);
P_exact_h_sd_pass_error=max(abs(P_exact_h_sd(Rpp)-Pd+(6*pi))/pi);
T_exact_h_sd=directFIRnonsymmetricT(w,exact_h_sd);
T_exact_h_sd_pass_error=max(abs(T_exact_h_sd(Rtp)-Td));
Esq_exact_h_sd=directFIRnonsymmetricEsq ...
                 (exact_h_sd,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

Asq_exact_h_Lim_sd=directFIRnonsymmetricAsq(w,exact_h_Lim_sd);
Asq_exact_h_Lim_sd_pass_error=max(abs(10*log10(Asq_exact_h_Lim_sd(Rap))));
Asq_exact_h_Lim_sd_stop_error=min(abs(10*log10(Asq_exact_h_Lim_sd(Ras))));
P_exact_h_Lim_sd=directFIRnonsymmetricP(w,exact_h_Lim_sd);
P_exact_h_Lim_sd_pass_error=max(abs(P_exact_h_Lim_sd(Rpp)-Pd+(6*pi))/pi);
T_exact_h_Lim_sd=directFIRnonsymmetricT(w,exact_h_Lim_sd);
T_exact_h_Lim_sd_pass_error=max(abs(T_exact_h_Lim_sd(Rtp)-Td));
Esq_exact_h_Lim_sd=directFIRnonsymmetricEsq ...
                     (exact_h_Lim_sd,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

Asq_socp_h_min=directFIRnonsymmetricAsq(w,socp_h_min);
Asq_socp_h_min_pass_error=max(abs(10*log10(Asq_socp_h_min(Rap))));
Asq_socp_h_min_stop_error=min(abs(10*log10(Asq_socp_h_min(Ras))));
P_socp_h_min=directFIRnonsymmetricP(w,socp_h_min);
P_socp_h_min_pass_error=max(abs(P_socp_h_min(Rpp)-Pd+(6*pi))/pi);
T_socp_h_min=directFIRnonsymmetricT(w,socp_h_min);
T_socp_h_min_pass_error=max(abs(T_socp_h_min(Rtp)-Td));
Esq_socp_h_min=directFIRnonsymmetricEsq ...
                 (socp_h_min,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

Asq_bandb_h_min=directFIRnonsymmetricAsq(w,bandb_h_min);
Asq_bandb_h_min_pass_error=max(abs(10*log10(Asq_bandb_h_min(Rap))));
Asq_bandb_h_min_stop_error=min(abs(10*log10(Asq_bandb_h_min(Ras))));
P_bandb_h_min=directFIRnonsymmetricP(w,bandb_h_min);
P_bandb_h_min_pass_error=max(abs(P_bandb_h_min(Rpp)-Pd+(6*pi))/pi);
T_bandb_h_min=directFIRnonsymmetricT(w,bandb_h_min);
T_bandb_h_min_pass_error=max(abs(T_bandb_h_min(Rtp)-Td));
Esq_bandb_h_min=directFIRnonsymmetricEsq ...
                  (bandb_h_min,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Plot FIR amplitude 
Asq_h_all=[Asq_exact_h,Asq_exact_h_Lim_sd,Asq_bandb_h_min,Asq_socp_h_min];
[ax,ha,hs] = plotyy(w*0.5/pi,10*log10(Asq_h_all), ...
                    w*0.5/pi,10*log10(Asq_h_all));
% Copy line colour and set line style
hac=get(ha,"color");
hls={"-",":","--","-."};
for c=1:4,
  set(hs(c),"color",hac{c});
  set(ha(c),"linestyle",hls{c});
  set(hs(c),"linestyle",hls{c});
endfor
set(ax(1),"ycolor","black");
set(ax(2),"ycolor","black");
axis(ax(1),[0 0.5 -1 0.2]);
axis(ax(2),[0 0.5 -36 -24]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("F-P","S-D(Lim)","B-and-B","SOCP-relax");
legend("location","northeast");
legend("boxoff");
legend("left");
strt=sprintf(["Non-symmetric FIR bandpass Hilbert filter : ", ...
              "ndigits=%d,nbits\\_fir=%d,fasl=%g,fapl=%g,fapu=%g,fasu=%g"], ...
             ndigits,nbits_fir,fasl,fapl,fapu,fasu);
title(strt);
zticks([]);
print(strcat(strf,"_h_min_amplitude"),"-dpdflatex");
close

% Plot FIR amplitude pass-band response error
ha=plot(w*0.5/pi,10*log10(Asq_h_all));
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0.08 0.22 -1 0.1]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
strt=sprintf(["Non-symmetric FIR bandpass Hilbert filter : ", ...
              "ndigits=%d,nbits\\_fir=%d,fapl=%g,fapu=%g"], ...
             ndigits,nbits_fir,fapl,fapu);
title(strt);
legend("F-P","S-D(Lim)","B-and-B","SOCP-relax");
legend("location","south");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_h_min_pass"),"-dpdflatex");
close

% Plot FIR amplitude stop-band response
ha=plot(w*0.5/pi,10*log10(Asq_h_all));
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0 0.5 -40 -20]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
strt=sprintf(["Non-symmetric FIR bandpass Hilbert filter : ", ...
              "ndigits=%d,nbits\\_fir=%d,fasl=%g,fapl=%g,fapu=%g,fasu=%g"], ...
             ndigits,nbits_fir,fasl,fapl,fapu,fasu);
title(strt);
legend("F-P","S-D(Lim)","B-and-B","SOCP-relax");
legend("location","northeast");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_h_min_stop"),"-dpdflatex");
close

% Plot FIR pass band phase response
P_h_all=[P_exact_h,P_exact_h_Lim_sd,P_bandb_h_min,P_socp_h_min];
ha=plot(wpass*0.5/pi,mod(unwrap(P_h_all(Rpass,:)+(w(Rpass)*tp))/pi,2));
% Set line style
hls={"-",":","--","-."};
for c=1:4
  set(ha(c),"linestyle",hls{c});
endfor
axis([0.08 0.22 mod(pp,2)+[-0.001,0.001]]);
grid("on");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$)");
legend("F-P","S-D(Lim)","B-and-B","SOCP-relax");
legend("location","south");
legend("boxoff");
legend("left");
strt=sprintf(["Non-symmetric FIR bandpass Hilbert filter :", ...
              " ndigits=%d,nbits\\_fir=%d,fppl=%g,fppu=%g"], ...
             ndigits,nbits_fir,fppl,fppu);
title(strt);
zticks([]);
print(strcat(strf,"_h_min_phase"),"-dpdflatex");
close

% Plot h_min pass band delay response
T_h_min_all=[T_exact_h,T_exact_h_Lim_sd,T_bandb_h_min,T_socp_h_min];
ha=plot(w*0.5/pi,T_h_min_all);
% Set line style
hls={"-",":","--","-."};
for c=1:4
  set(ha(c),"linestyle",hls{c});
endfor
axis([0.08 0.22 tp+0.04*[-1 1]]);
grid("on");
xlabel("Frequency");
ylabel("Delay(samples)");
legend("F-P","S-D(Lim)","B-and-B","SOCP-relax");
legend("location","northwest");
legend("boxoff");
legend("left");
strt=sprintf(["Non-symmetric FIR bandpass Hilbert filter :", ...
              " ndigits=%d,nbits\\_fir=%d,ftpl=%g,ftpu=%g"], ...
             ndigits,nbits_fir,ftpl,ftpu);
title(strt);
zticks([]);
print(strcat(strf,"_h_min_delay"),"-dpdflatex");
close

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_h_min_cost.tab"),"wt");
fprintf(fid, ...
        ["Floating-point FIR ", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &&\\\\\n"], ...
        Esq_exact_h, ...
        Asq_exact_h_pass_error,Asq_exact_h_stop_error, ...
        P_exact_h_pass_error,T_exact_h_pass_error);
fprintf(fid, ...
        ["Signed-digit FIR ", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"],...
        Esq_exact_h_sd, ...
        Asq_exact_h_sd_pass_error,Asq_exact_h_sd_stop_error, ...
        P_exact_h_sd_pass_error,T_exact_h_sd_pass_error, ...
        exact_h_sd_digits,exact_h_sd_adders);
fprintf(fid, ...
        ["Signed-digit(Lim) FIR", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"],...
        Esq_exact_h_Lim_sd, ...
        Asq_exact_h_Lim_sd_pass_error,Asq_exact_h_Lim_sd_stop_error, ...
        P_exact_h_Lim_sd_pass_error,T_exact_h_Lim_sd_pass_error, ...
        exact_h_Lim_sd_digits,exact_h_Lim_sd_adders);
fprintf(fid, ...
        ["SOCP-relaxation FIR ", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"],...
        Esq_socp_h_min, ...
        Asq_socp_h_min_pass_error,Asq_socp_h_min_stop_error, ...
        P_socp_h_min_pass_error,T_socp_h_min_pass_error, ...
        socp_h_min_digits,socp_h_min_adders);
fprintf(fid, ...
        ["Branch-and-bound FIR ", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"],...
        Esq_bandb_h_min, ...
        Asq_bandb_h_min_pass_error,Asq_bandb_h_min_stop_error,...
        P_bandb_h_min_pass_error,T_bandb_h_min_pass_error, ...
        bandb_h_min_digits,bandb_h_min_adders);
fclose(fid);

% Plot Schur-FIR amplitude 
Asq_Schur_FIR=[bandb_Asq,socp_Asq,Asq_bandb_h_min,Asq_socp_h_min];
[ax,ha,hs] = plotyy(w*0.5/pi,10*log10(Asq_Schur_FIR), ...
                    w*0.5/pi,10*log10(Asq_Schur_FIR));
% Copy line colour and set line style
hac=get(ha,"color");
hls={"-",":","--","-."};
for c=1:4,
  set(hs(c),"color",hac{c});
  set(ha(c),"linestyle",hls{c});
  set(hs(c),"linestyle",hls{c});
endfor
set(ax(1),"ycolor","black");
set(ax(2),"ycolor","black");
axis(ax(1),[0 0.5 -0.6 0.2]);
axis(ax(2),[0 0.5 -50 -10]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("Schur B-and-B","Schur SOCP-relax","FIR B-and-B","FIR SOCP-relax");
legend("location","northeast");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_Schur_FIR_amplitude"),"-dpdflatex");
close

% Plot Schur FIR amplitude pass-band response
ha=plot(w*0.5/pi,10*log10(Asq_Schur_FIR));
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0.08 0.22 -0.5,0.1]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("Schur B-and-B","Schur SOCP-relax","FIR B-and-B","FIR SOCP-relax");
legend("location","southeast");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_Schur_FIR_pass"),"-dpdflatex");
close

% Plot Schur FIR amplitude pass-band response
ha=plot(w*0.5/pi,10*log10(Asq_Schur_FIR));
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0 0.5 -50 -10]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("Schur B-and-B","Schur SOCP-relax","FIR B-and-B","FIR SOCP-relax");
legend("location","northeast");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_Schur_FIR_stop"),"-dpdflatex");
close

% Plot Schur-FIR phase response
P_Schur_FIR=[bandb_P+(w*Tz2),socp_P+(w*Tz2), ...
             P_bandb_h_min+(4*pi),P_socp_h_min+(4*pi)];
ha = plot(w*0.5/pi,(unwrap(P_Schur_FIR)+(w*tp))/pi);
% Set line style
hls={"-",":","--","-."};
for c=1:4,
  set(ha(c),"linestyle",hls{c});
endfor
axis([0.08 0.22 mod(pp,2)+(0.002*[-1 1])]);
grid("on");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$)");
legend("Schur B-and-B","Schur SOCP-relax","FIR B-and-B","FIR SOCP-relax");
legend("location","southwest");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_Schur_FIR_phase"),"-dpdflatex");
close

% Plot Schur-FIR delay response
T_Schur_FIR=[bandb_T-Tz2,socp_T-Tz2,T_bandb_h_min,T_socp_h_min];
h = plot(w*0.5/pi,T_Schur_FIR);
% Set line style
hls={"-",":","--","-."};
for c=1:4,
  set(h(c),"linestyle",hls{c});
endfor
axis([0.08 0.22 tp+0.06*[-1 1]]);
grid("on");
xlabel("Frequency");
ylabel("Delay(samples)");
legend("Schur B-and-B","Schur SOCP-relax","FIR B-and-B","FIR SOCP-relax");
legend("location","south");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_Schur_FIR_delay"),"-dpdflatex");
close

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_Schur_FIR_cost.tab"),"wt");
fprintf(fid, ...
        ["Floating-point Schur ", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &&\\\\\n"], ...
        exact_Esq, ...
        exact_Asq_pass_error,exact_Asq_stop_error, ...
        exact_P_pass_error,exact_T_pass_error);        
fprintf(fid, ...
        ["Floating-point FIR ", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &&\\\\\n"], ...
        Esq_exact_h, ...
        Asq_exact_h_pass_error,Asq_exact_h_stop_error, ...
        P_exact_h_pass_error,T_exact_h_pass_error);
fprintf(fid, ...
        ["SOCP-relax. Schur ", ...
        "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"], ...
        socp_Esq, ...
        socp_Asq_pass_error,socp_Asq_stop_error, ...
        socp_P_pass_error,socp_T_pass_error, ...
        socp_min_digits,socp_min_adders);
fprintf(fid, ...
        ["SOCP-relax. FIR", ...
        "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"], ...
        Esq_socp_h_min, ...
        Asq_socp_h_min_pass_error,Asq_socp_h_min_stop_error, ...
        P_socp_h_min_pass_error,T_socp_h_min_pass_error, ...
        socp_h_min_digits,socp_h_min_adders);
fprintf(fid, ...
        ["B-and-B Schur", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"], ...
        bandb_Esq, ...
        bandb_Asq_pass_error,bandb_Asq_stop_error, ...
        bandb_P_pass_error,bandb_T_pass_error, ...
        bandb_min_digits,bandb_min_adders);
fprintf(fid, ...
        ["B-and-B FIR", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"], ...
        Esq_bandb_h_min, ...
        Asq_bandb_h_min_pass_error,Asq_bandb_h_min_stop_error,...
        P_bandb_h_min_pass_error,T_bandb_h_min_pass_error, ...
        bandb_h_min_digits,bandb_h_min_adders);
fclose(fid);

%
% Filter specification
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"n=%d%% Frequency points across the band\n",n);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"Wasl=%g %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%g %% Amplitude upper stop band weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Pass band delay lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band delay upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"Wtp=%g %% Delay pass band weight\n",Wtp);
fprintf(fid,"fppl=%g %% Pass band phase response lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Pass band phase response upper edge\n",fppu);
fprintf(fid,"pp=%g %% Pass band initial phase response (rad./pi)\n",pp);
fprintf(fid,"Wpp=%g %% Pass band phase response weight\n",Wpp);
fprintf(fid,"fdpl=%g %% Pass band dAsqdw response lower edge\n",fdpl);
fprintf(fid,"fdpu=%g %% Pass band dAsqdw response upper edge\n",fdpu);
fprintf(fid,"Wdp=%g %% Pass band dAsqdw response weight\n",Wdp);
fclose(fid);

%
% Done
%
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
