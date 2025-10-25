% comparison_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test.m 
%
% Compare branch-and-bound and SOCP-relaxation search for the
% 13-bit, average of 3-signed-digit, coefficients of a band-pass Hilbert
% filter implemented as a Schur one-multiplier lattice correction filter having
% transfer function denominator polynomial coefficients only in z^-2.
%
% This comparison originally included the results of 
% pop_relaxation_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test.m
% Unfortunately, I could not find a good filter specification that converged
% under QEMU.
%
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strs="schurOneMlattice_bandpass_hilbert_R2_13_nbits_test";
strf=strcat("comparison_",strs);

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

nbits=13;
nscale=2^(nbits-1);
ndigits=3;

% Filter specification
R=2;
fasl=0.05,fapl=0.1,fapu=0.2,fasu=0.25
Wasl=20,Watl=0.001,Wap=1,Watu=0.001,Wasu=10
fppl=fapl,fppu=fapu,pp=3.5,ppr=0.008,Wpp=2
ftpl=fapl,ftpu=fapu,tp=16,tpr=0.08,Wtp=1
fdpl=fapl,fdpu=fapu,dp=0,Wdp=0.001

% Load filter coefficients
schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_k2_coef;
schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_epsilon2_coef;
schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_c2_coef;
exact_k=k2;
exact_epsilon=epsilon2;
exact_c=c2;
clear k2 epsilon2 c2 ;

eval(strcat("branch_bound_",strs,"_k_min_coef;"));
eval(strcat("branch_bound_",strs,"_c_min_coef;"));
bandb_k=k_min;
bandb_epsilon=exact_epsilon;
bandb_c=c_min;
[bandb_sd_digits,bandb_sd_adders]=SDadders([bandb_k;bandb_c],nbits);

eval(strcat("socp_relaxation_",strs,"_k_min_coef;"));
eval(strcat("socp_relaxation_",strs,"_c_min_coef;"));
socp_k=k_min;
socp_epsilon=exact_epsilon;
socp_c=c_min;
[socp_sd_digits,socp_sd_adders]=SDadders([socp_k;socp_c],nbits);

clear k_min epsilon_min c_min ;

% Initialise coefficient range vectors
Nk=length(exact_k);
Nc=length(exact_c);
Nkc=Nk+Nc;
Rk=1:Nk;
Rc=(Nk+1):Nkc;
p_ones=ones(size(exact_k));

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
Ras=[1:nasl,nasu:n];
Asqd=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];
% Sanity checks
nchka=[1, ...
       nasl-1,nasl,nasl+1, ...
       napl-1,napl,napl+1, ...
       napu-1,napu,napu+1, ...
       nasu-1,nasu,nasu+1,...
       n-1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Desired pass-band phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=wa(nppl:nppu);
Pd=(pp*pi)-(tp*wp);
Wp=Wpp*ones(nppu-nppl+1,1);

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
% Allocate digits
%
ndigits_alloc=schurOneMlattice_allocsd_Ito ...
                (nbits,ndigits,exact_k,exact_epsilon,p_ones,exact_c, ...
                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
k_allocsd_digits=int16(ndigits_alloc(Rk));
c_allocsd_digits=int16(ndigits_alloc(Rc));
printf("k_allocsd_digits=[ ");printf("%2d ",k_allocsd_digits);printf("]';\n");
printf("c_allocsd_digits=[ ");printf("%2d ",c_allocsd_digits);printf("]';\n");

% Find the signed-digit approximations to exact_k and exact_c
[sd_kc,sdu_kc,sdl_kc]=flt2SD([exact_k;exact_c],nbits,ndigits);
[sd_sd_digits,sd_sd_adders]=SDadders(sd_kc,nbits);
sd_k=sd_kc(Rk);
sd_epsilon=exact_epsilon;
sd_c=sd_kc(Rc);
print_polynomial(sd_k,"sd_k",nscale);
print_polynomial(sd_c,"sd_c",nscale);

[sd_Ito_kc,sdu_Ito_kc,sdl_Ito_kc]=flt2SD([exact_k;exact_c],nbits,ndigits_alloc);
[sd_Ito_sd_digits,sd_Ito_sd_adders]=SDadders(sd_Ito_kc,nbits);
sd_Ito_k=sd_Ito_kc(Rk);
sd_Ito_epsilon=exact_epsilon;
sd_Ito_c=sd_Ito_kc(Rc);
print_polynomial(sd_Ito_k,"sd_Ito_k",nscale);
print_polynomial(sd_Ito_c,"sd_Ito_c",nscale);

%
% Calculate responses
%

% Calculate "exact" response
exact_Asq=schurOneMlatticeAsq(wa,exact_k,exact_epsilon,p_ones,exact_c);
exact_P=schurOneMlatticeP(wp,exact_k,exact_epsilon,p_ones,exact_c);
exact_T=schurOneMlatticeT(wt,exact_k,exact_epsilon,p_ones,exact_c);
exact_dAsqdw=schurOneMlatticedAsqdw(wd,exact_k,exact_epsilon,p_ones,exact_c);

% Calculate "exact" errors
exact_Asq_pass_error=max(abs(10*log10(exact_Asq(Rap))));
exact_Asq_stop_error=min(abs(10*log10(exact_Asq(Ras))));
exact_P_pass_error=max(abs(exact_P-Pd)/pi);
exact_T_pass_error=max(abs(exact_T-Td));
exact_dAsqdw_pass_error=max(abs(exact_dAsqdw-Dd));
exact_Esq=schurOneMlatticeEsq(exact_k,exact_epsilon,p_ones,exact_c, ...
                              wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Calculate signed-digit response
sd_Asq=schurOneMlatticeAsq(wa,sd_k,sd_epsilon,p_ones,sd_c);
sd_P=schurOneMlatticeP(wp,sd_k,sd_epsilon,p_ones,sd_c);
sd_T=schurOneMlatticeT(wt,sd_k,sd_epsilon,p_ones,sd_c);
sd_dAsqdw=schurOneMlatticedAsqdw(wd,sd_k,sd_epsilon,p_ones,sd_c);

% Calculate signed-digit errors
sd_Asq_pass_error=max(abs(10*log10(sd_Asq(Rap))));
sd_Asq_stop_error=min(abs(10*log10(sd_Asq(Ras))));
sd_P_pass_error=max(abs(sd_P-Pd)/pi);
sd_T_pass_error=max(abs(sd_T-Td));
sd_dAsqdw_pass_error=max(abs(sd_dAsqdw-Dd));
sd_Esq=schurOneMlatticeEsq(sd_k,sd_epsilon,p_ones,sd_c, ...
                           wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Calculate signed-digit Ito response
sd_Ito_Asq=schurOneMlatticeAsq(wa,sd_Ito_k,sd_Ito_epsilon,p_ones,sd_Ito_c);
sd_Ito_P=schurOneMlatticeP(wp,sd_Ito_k,sd_Ito_epsilon,p_ones,sd_Ito_c);
sd_Ito_T=schurOneMlatticeT(wt,sd_Ito_k,sd_Ito_epsilon,p_ones,sd_Ito_c);
sd_Ito_dAsqdw=schurOneMlatticedAsqdw(wd,sd_Ito_k,sd_Ito_epsilon,p_ones,sd_Ito_c);

% Calculate signed-digit Ito errors
sd_Ito_Asq_pass_error=max(abs(10*log10(sd_Ito_Asq(Rap))));
sd_Ito_Asq_stop_error=min(abs(10*log10(sd_Ito_Asq(Ras))));
sd_Ito_P_pass_error=max(abs(sd_Ito_P-Pd)/pi);
sd_Ito_T_pass_error=max(abs(sd_Ito_T-Td));
sd_Ito_dAsqdw_pass_error=max(abs(sd_Ito_dAsqdw-Dd));
sd_Ito_Esq=schurOneMlatticeEsq(sd_Ito_k,sd_Ito_epsilon,p_ones,sd_Ito_c, ...
                               wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Calculate branch-and-bound response
bandb_Asq=schurOneMlatticeAsq(wa,bandb_k,bandb_epsilon,p_ones,bandb_c);
bandb_P=schurOneMlatticeP(wp,bandb_k,bandb_epsilon,p_ones,bandb_c);
bandb_T=schurOneMlatticeT(wt,bandb_k,bandb_epsilon,p_ones,bandb_c);
bandb_dAsqdw=schurOneMlatticedAsqdw(wd,bandb_k,bandb_epsilon,p_ones,bandb_c);

% Calculate branch-and-bound errors
bandb_Asq_pass_error=max(abs(10*log10(bandb_Asq(Rap))));
bandb_Asq_stop_error=min(abs(10*log10(bandb_Asq(Ras))));
bandb_P_pass_error=max(abs(bandb_P-Pd)/pi);
bandb_T_pass_error=max(abs(bandb_T-Td));
bandb_dAsqdw_pass_error=max(abs(bandb_dAsqdw-Dd));
bandb_Esq=schurOneMlatticeEsq(bandb_k,bandb_epsilon,p_ones,bandb_c, ...
                              wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Calculate SOCP-relaxation response
socp_Asq=schurOneMlatticeAsq(wa,socp_k,socp_epsilon,p_ones,socp_c);
socp_P=schurOneMlatticeP(wp,socp_k,socp_epsilon,p_ones,socp_c);
socp_T=schurOneMlatticeT(wt,socp_k,socp_epsilon,p_ones,socp_c);
socp_dAsqdw=schurOneMlatticedAsqdw(wd,socp_k,socp_epsilon,p_ones,socp_c);

% Calculate SOCP-relaxation errors
socp_Asq_pass_error=max(abs(10*log10(socp_Asq(Rap))));
socp_Asq_stop_error=min(abs(10*log10(socp_Asq(Ras))));
socp_P_pass_error=max(abs(socp_P-Pd)/pi);
socp_T_pass_error=max(abs(socp_T-Td));
socp_dAsqdw_pass_error=max(abs(socp_dAsqdw-Dd));
socp_Esq=schurOneMlatticeEsq(socp_k,socp_epsilon,p_ones,socp_c, ...
                             wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Plot amplitude pass-band response error
ha=plot(wa*0.5/pi,10*log10([exact_Asq,sd_Ito_Asq,bandb_Asq,socp_Asq]));
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([fapl fapu [-0.3,0]]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
strt=sprintf(["Schur one-multiplier lattice bandpass Hilbert filter :", ...
              " ndigits=%d,nbits=%d,fapl=%g,fapu=%g"], ...
             nbits,ndigits,fapl,fapu);
title(strt);
legend("Floating point","S-D(Ito)","B-and-B","SOCP-relax");
legend("location","southwest");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_pass"),"-dpdflatex");
close

% Plot amplitude stop-band response
ha=plot(wa*0.5/pi,10*log10([exact_Asq,sd_Ito_Asq,bandb_Asq,socp_Asq]));
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([0 0.5 -36 -30]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
strt=sprintf(["Schur one-multiplier lattice bandpass Hilbert filter :", ...
              " ndigits=%d,nbits=%d,fasl=%g,fapl=%g,fapu=%g,fasu=%g"], ...
             nbits,ndigits,fasl,fapl,fapu,fasu);
title(strt);
legend("Floating point","S-D(Ito)","B-and-B","SOCP-relax");
legend("location","northeast");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot phase pass-band response for signed-digit responses
ha=plot(wp*0.5/pi,mod(([exact_P,sd_Ito_P,bandb_P,socp_P]+(wp*tp))/pi,2));
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([fppl fppu mod(pp,2)+(ppr/2)*[-1 1]]);
grid("on");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$)");
strt=sprintf(["Schur one-multiplier lattice bandpass Hilbert filter :", ...
              " ndigits=%d,nbits=%d,fppl=%g,fppu=%g"], ...
             nbits,ndigits,fppl,fppu);
title(strt);
legend("Floating point","S-D(Ito)","B-and-B","SOCP-relax");
legend("location","southeast");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_phase"),"-dpdflatex");
close

% Plot delay pass-band response for signed-digit responses
ha=plot(wt*0.5/pi,[exact_T,sd_Ito_T,bandb_T,socp_T]);
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([ftpl ftpu tp+0.2*[-1 1]]);
grid("on");
xlabel("Frequency");
ylabel("Delay(samples)");
strt=sprintf(["Schur one-multiplier lattice bandpass Hilbert filter :", ...
              " ndigits=%d,nbits=%d,ftpl=%g,ftpu=%g"], ...
             nbits,ndigits,ftpu,ftpu);
title(strt);
legend("Floating point","S-D(Ito)","B-and-B","SOCP-relax");
legend("location","southwest");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_delay"),"-dpdflatex");
close


% Plot dAsqdw pass-band signed-digit responses
ha=plot(wd*0.5/pi,[exact_dAsqdw,sd_Ito_dAsqdw,bandb_dAsqdw,socp_dAsqdw]);
hls={"-",":","--","-."};
for l=1:4
  set(ha(l),"linestyle",hls{l});
endfor
axis([fdpl fdpu -0.6 0.6]);
grid("on");
xlabel("Frequency");
ylabel("$\\frac{d|A|^{2}}{d\\omega}$");
strt=sprintf(["Schur one-multiplier lattice bandpass Hilbert filter :", ...
              " ndigits=%d,nbits=%d,fdpl=%g,fdpu=%g"], ...
             nbits,ndigits,fdpl,fdpu);
title(strt);
legend("Floating point","S-D(Ito)","B-and-B","SOCP-relax");
legend("location","southwest");
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
        sd_Esq, ...
        sd_Asq_pass_error,sd_Asq_stop_error, ...
        sd_P_pass_error,sd_T_pass_error, ...
        sd_sd_digits,sd_sd_adders);
fprintf(fid, ...
        ["Signed-Digit(Ito)",...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"], ...
        sd_Ito_Esq, ...
        sd_Ito_Asq_pass_error,sd_Ito_Asq_stop_error, ...
        sd_Ito_P_pass_error,sd_Ito_T_pass_error, ...
        sd_Ito_sd_digits,sd_Ito_sd_adders);
fprintf(fid, ...
        ["Branch-and-bound ", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"], ...
        bandb_Esq, ...
        bandb_Asq_pass_error,bandb_Asq_stop_error, ...
        bandb_P_pass_error,bandb_T_pass_error, ...
        bandb_sd_digits,bandb_sd_adders);
fprintf(fid, ...
        ["SOCP-relaxation ", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"], ...
        socp_Esq, ...
        socp_Asq_pass_error,socp_Asq_stop_error, ...
        socp_P_pass_error,socp_T_pass_error, ...
        socp_sd_digits,socp_sd_adders);
fclose(fid);

%
% Compare with a non-symmetric FIR filter
%
strd="directFIRnonsymmetric_socp_slb_bandpass_hilbert_test";
eval(strcat(strd,"_h_coef;"));

strd="socp_relaxation_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test";
eval(strcat(strd,"_h_sd_coef;"));
eval(strcat(strd,"_h_Ito_sd_coef;"));
eval(strcat(strd,"_h_min_coef;"))

socp_h=h;
socp_h_sd=h_sd;
socp_h_Ito_sd=h_Ito_sd;
socp_h_min=h_min;

strd= ...
"branch_bound_directFIRnonsymmetric_bandpass_hilbert_13_nbits_test";
eval(strcat(strd,"_h_sd_coef;"));
eval(strcat(strd,"_h_Ito_sd_coef;"));
eval(strcat(strd,"_h_min_coef;"));

bandb_h=h;
bandb_h_sd=h_sd;
bandb_h_Ito_sd=h_Ito_sd;
bandb_h_min=h_min;

clear h h_sd h_Ito_sd h_min

if max(abs(socp_h_sd-bandb_h_sd)) > eps
  error("max(abs(socp_h_sd-bandb_h_sd))(%g*eps) > eps", ...
        max(abs(socp_h_sd-bandb_h_sd))/eps);
endif
if max(abs(socp_h_Ito_sd-bandb_h_Ito_sd)) > eps
  error("max(abs(socp_h_Ito_sd-bandb_h_Ito_sd))(%g*eps) > eps", ...
        max(abs(socp_h_Ito_sd-bandb_h_Ito_sd))/eps);
endif

[socp_h_sd_digits,socp_h_sd_adders]=SDadders(socp_h_sd,nbits);
[socp_h_Ito_sd_digits,socp_h_Ito_sd_adders]=SDadders(socp_h_Ito_sd,nbits);
[socp_h_min_digits,socp_h_min_adders]=SDadders(socp_h_min,nbits);

[bandb_h_sd_digits,bandb_h_sd_adders]=SDadders(bandb_h_sd,nbits);
[bandb_h_Ito_sd_digits,bandb_h_Ito_sd_adders]=SDadders(bandb_h_Ito_sd,nbits);
[bandb_h_min_digits,bandb_h_min_adders]=SDadders(bandb_h_min,nbits);

Asq_socp_h=directFIRnonsymmetricAsq(wa,socp_h);
Asq_socp_h_pass_error=max(abs(10*log10(Asq_socp_h(Rap))));
Asq_socp_h_stop_error=min(abs(10*log10(Asq_socp_h(Ras))));
P_socp_h=directFIRnonsymmetricP(wp,socp_h);
P_socp_h_pass_error=max(abs(P_socp_h-Pd)/pi);
T_socp_h=directFIRnonsymmetricT(wt,socp_h);
T_socp_h_pass_error=max(abs(T_socp_h-Td));
Esq_socp_h=directFIRnonsymmetricEsq(socp_h, ...
                                    wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

Asq_socp_h_sd=directFIRnonsymmetricAsq(wa,socp_h_sd);
Asq_socp_h_sd_pass_error=max(abs(10*log10(Asq_socp_h_sd(Rap))));
Asq_socp_h_sd_stop_error=min(abs(10*log10(Asq_socp_h_sd(Ras))));
P_socp_h_sd=directFIRnonsymmetricP(wp,socp_h_sd);
P_socp_h_sd_pass_error=max(abs(P_socp_h_sd-Pd)/pi);
T_socp_h_sd=directFIRnonsymmetricT(wt,socp_h_sd);
T_socp_h_sd_pass_error=max(abs(T_socp_h_sd-Td));
Esq_socp_h_sd=directFIRnonsymmetricEsq(socp_h_sd, ...
                                       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

Asq_socp_h_Ito_sd=directFIRnonsymmetricAsq(wa,socp_h_Ito_sd);
Asq_socp_h_Ito_sd_pass_error=max(abs(10*log10(Asq_socp_h_Ito_sd(Rap))));
Asq_socp_h_Ito_sd_stop_error=min(abs(10*log10(Asq_socp_h_Ito_sd(Ras))));
P_socp_h_Ito_sd=directFIRnonsymmetricP(wp,socp_h_Ito_sd);
P_socp_h_Ito_sd_pass_error=max(abs(P_socp_h_Ito_sd-Pd)/pi);
T_socp_h_Ito_sd=directFIRnonsymmetricT(wt,socp_h_Ito_sd);
T_socp_h_Ito_sd_pass_error=max(abs(T_socp_h_Ito_sd-Td));
Esq_socp_h_Ito_sd=directFIRnonsymmetricEsq(socp_h_Ito_sd, ...
                                           wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

Asq_socp_h_min=directFIRnonsymmetricAsq(wa,socp_h_min);
Asq_socp_h_min_pass_error=max(abs(10*log10(Asq_socp_h_min(Rap))));
Asq_socp_h_min_stop_error=min(abs(10*log10(Asq_socp_h_min(Ras))));
P_socp_h_min=directFIRnonsymmetricP(wp,socp_h_min);
P_socp_h_min_pass_error=max(abs(P_socp_h_min-Pd)/pi);
T_socp_h_min=directFIRnonsymmetricT(wt,socp_h_min);
T_socp_h_min_pass_error=max(abs(T_socp_h_min-Td));
Esq_socp_h_min=directFIRnonsymmetricEsq(socp_h_min, ...
                                        wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

Asq_bandb_h_sd=directFIRnonsymmetricAsq(wa,bandb_h_sd);
Asq_bandb_h_sd_pass_error=max(abs(10*log10(Asq_bandb_h_sd(Rap))));
Asq_bandb_h_sd_stop_error=min(abs(10*log10(Asq_bandb_h_sd(Ras))));
P_bandb_h_sd=directFIRnonsymmetricP(wp,bandb_h_sd);
P_bandb_h_sd_pass_error=max(abs(P_bandb_h_sd-Pd)/pi);
T_bandb_h_sd=directFIRnonsymmetricT(wt,bandb_h_sd);
T_bandb_h_sd_pass_error=max(abs(T_bandb_h_sd-Td));
Esq_bandb_h_sd=directFIRnonsymmetricEsq(bandb_h_sd, ...
                                        wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

Asq_bandb_h_Ito_sd=directFIRnonsymmetricAsq(wa,bandb_h_Ito_sd);
Asq_bandb_h_Ito_sd_pass_error=max(abs(10*log10(Asq_bandb_h_Ito_sd(Rap))));
Asq_bandb_h_Ito_sd_stop_error=min(abs(10*log10(Asq_bandb_h_Ito_sd(Ras))));
P_bandb_h_Ito_sd=directFIRnonsymmetricP(wp,bandb_h_Ito_sd);
P_bandb_h_Ito_sd_pass_error=max(abs(P_bandb_h_Ito_sd-Pd)/pi);
T_bandb_h_Ito_sd=directFIRnonsymmetricT(wt,bandb_h_Ito_sd);
T_bandb_h_Ito_sd_pass_error=max(abs(T_bandb_h_Ito_sd-Td));
Esq_bandb_h_Ito_sd=directFIRnonsymmetricEsq(bandb_h_Ito_sd, ...
                                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

Asq_bandb_h_min=directFIRnonsymmetricAsq(wa,bandb_h_min);
Asq_bandb_h_min_pass_error=max(abs(10*log10(Asq_bandb_h_min(Rap))));
Asq_bandb_h_min_stop_error=min(abs(10*log10(Asq_bandb_h_min(Ras))));
P_bandb_h_min=directFIRnonsymmetricP(wp,bandb_h_min);
P_bandb_h_min_pass_error=max(abs(P_bandb_h_min-Pd)/pi);
T_bandb_h_min=directFIRnonsymmetricT(wt,bandb_h_min);
T_bandb_h_min_pass_error=max(abs(T_bandb_h_min-Td));
Esq_bandb_h_min=directFIRnonsymmetricEsq(bandb_h_min, ...
                                         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Plot FIR amplitude 
Asq_h_min_all=[Asq_socp_h,Asq_socp_h_Ito_sd,Asq_socp_h_min,Asq_bandb_h_min];
[ax,ha,hs] = plotyy(wa*0.5/pi,10*log10(Asq_h_min_all), ...
                    wa*0.5/pi,10*log10(Asq_h_min_all));
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
legend("FIR F-P","FIR S-D(Ito)","FIR SOCP-relax","FIR B-and-B");
legend("location","northeast");
legend("boxoff");
legend("left");
strt=sprintf(["Non-symmetric FIR bandpass Hilbert filter :", ...
              " ndigits=%d,nbits=%d,fasl=%g,fapl=%g,fapu=%g,fasu=%g"], ...
             nbits,ndigits,fasl,fapl,fapu,fasu);
title(strt);
zticks([]);
print(strcat(strf,"_h_min_amplitude"),"-dpdflatex");
close

% Plot h_min pass band phase response
P_h_min_all=[P_socp_h,P_socp_h_Ito_sd,P_socp_h_min,P_bandb_h_min];
ha=plot(wp*0.5/pi,(unwrap(P_h_min_all)+(wp*tp)-(2*pi))/pi);
% Set line style
hls={"-",":","--","-."};
for c=1:4
  set(ha(c),"linestyle",hls{c});
endfor
axis([fppl fppu mod(pp,2)+0.002*[-1,1]]);
grid("on");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$)");
legend("FIR F-P","FIR S-D(Ito)","FIR SOCP-relax","FIR B-and-B");
legend("location","northeast");
legend("boxoff");
legend("left");
strt=sprintf(["Non-symmetric FIR bandpass Hilbert filter :", ...
              " ndigits=%d,nbits=%d,fppl=%g,fppu=%g"], ...
             nbits,ndigits,fppl,fppu);
title(strt);
zticks([]);
print(strcat(strf,"_h_min_phase"),"-dpdflatex");
close

% Plot h_min pass band delay response
T_h_min_all=[T_socp_h,T_socp_h_Ito_sd,T_socp_h_min,T_bandb_h_min];
ha=plot(wt*0.5/pi,T_h_min_all);
% Set line style
hls={"-",":","--","-."};
for c=1:4
  set(ha(c),"linestyle",hls{c});
endfor
axis([ftpl ftpu tp+0.02*[-1 1]]);
grid("on");
xlabel("Frequency");
ylabel("Delay(samples)");
legend("FIR F-P","FIR S-D(Ito)","FIR SOCP-relax","FIR B-and-B");
legend("location","southeast");
legend("boxoff");
legend("left");
strt=sprintf(["Non-symmetric FIR bandpass Hilbert filter :", ...
              " ndigits=%d,nbits=%d,ftpl=%g,ftpu=%g"], ...
             nbits,ndigits,ftpl,ftpu);
title(strt);
zticks([]);
print(strcat(strf,"_h_min_delay"),"-dpdflatex");
close

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_h_min_cost.tab"),"wt");
fprintf(fid, ...
        ["Floating-point FIR ", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &&\\\\\n"], ...
        Esq_socp_h, ...
        Asq_socp_h_pass_error,Asq_socp_h_stop_error, ...
        P_socp_h_pass_error,T_socp_h_pass_error);
fprintf(fid, ...
        ["Signed-digit FIR ", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"],...
        Esq_socp_h_sd, ...
        Asq_socp_h_sd_pass_error,Asq_socp_h_sd_stop_error, ...
        P_socp_h_sd_pass_error,T_socp_h_sd_pass_error, ...
        socp_h_sd_digits,socp_h_sd_adders);
fprintf(fid, ...
        ["Signed-digit(Ito) FIR", ...
         "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"],...
        Esq_socp_h_Ito_sd, ...
        Asq_socp_h_Ito_sd_pass_error,Asq_socp_h_Ito_sd_stop_error, ...
        P_socp_h_Ito_sd_pass_error,T_socp_h_Ito_sd_pass_error, ...
        socp_h_Ito_sd_digits,socp_h_Ito_sd_adders);
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
Asq_Schur_FIR=[socp_Asq,bandb_Asq,Asq_socp_h_min,Asq_bandb_h_min];
[ax,ha,hs] = plotyy(wa*0.5/pi,10*log10(Asq_Schur_FIR), ...
                    wa*0.5/pi,10*log10(Asq_Schur_FIR));
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
legend("Schur SOCP-relax","Schur B-and-B","FIR SOCP-relax","FIR B-and-B");
legend("location","northeast");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_Schur_FIR_amplitude"),"-dpdflatex");
close

% Plot phase response
P_Schur_FIR=[socp_P,bandb_P,P_socp_h_min,P_bandb_h_min];
h = plot(wp*0.5/pi,(unwrap(P_Schur_FIR)+(wp*tp)-(2*pi))/pi);
% Set line style
hls={"-",":","--","-."};
for c=1:4,
  set(h(c),"linestyle",hls{c});
endfor
axis([fppl fppu mod(pp,2)+0.004*[-1 1]]);
grid("on");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$)");
legend("Schur SOCP-relax","Schur B-and-B","FIR SOCP-relax","FIR B-and-B");
legend("location","northeast");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_Schur_FIR_phase"),"-dpdflatex");
close

% Plot delay response
T_Schur_FIR=[socp_T,bandb_T,T_socp_h_min,T_bandb_h_min];
h = plot(wt*0.5/pi,T_Schur_FIR);
% Set line style
hls={"-",":","--","-."};
for c=1:4,
  set(h(c),"linestyle",hls{c});
endfor
axis([ftpl ftpu tp+0.2*[-1 1]]);
grid("on");
xlabel("Frequency");
ylabel("Delay(samples)");
legend("Schur SOCP-relax","Schur B-and-B","FIR SOCP-relax","FIR B-and-B");
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
        Esq_socp_h, ...
        Asq_socp_h_pass_error,Asq_socp_h_stop_error, ...
        P_socp_h_pass_error,T_socp_h_pass_error);
fprintf(fid, ...
        ["SOCP-relax. Schur ", ...
        "&%8.6f &%5.2f &%5.2f &%8.6f &%5.3f &%d&%d\\\\\n"], ...
        socp_Esq, ...
        socp_Asq_pass_error,socp_Asq_stop_error, ...
        socp_P_pass_error,socp_T_pass_error, ...
        socp_sd_digits,socp_sd_adders);
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
        bandb_sd_digits,bandb_sd_adders);
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
