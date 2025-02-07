% socp_relaxation_schurOneMlattice_bandpass_hilbert_13_nbits_test.m
% Copyright (C) 2025 Robert G. Jenssen

% SOCP relaxation optimisation of a Schur parallel one-multiplier allpass
% lattice bandpass hilbert filter with 13-bit signed-digit coefficients having
% an average of 3 signed-digits

test_common;

strf="socp_relaxation_schurOneMlattice_bandpass_hilbert_13_nbits_test"

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
ftol=1e-4
ctol=ftol/100
verbose=false;

nbits=13;
ndigits=3;

%
% Band-pass filter specification for parallel all-pass filters
%
fasl=0.05,fapl=0.1,fapu=0.2,fasu=0.25
dBap=0.26,Wap=1,dBas=32,Watl=1e-3,Watu=1e-3,Wasl=10,Wasu=10
fppl=0.1,fppu=0.2,pp=3.5,ppr=0.0048,Wpp=2
ftpl=0.1,ftpu=0.2,tp=16,tpr=0.32,Wtp=0.2
fdpl=0.1,fdpu=0.2,dp=0,dpr=1.2,Wdp=0.001

%
% Initial coefficients
%
schurOneMlattice_socp_slb_bandpass_hilbert_test_k2_coef;
schurOneMlattice_socp_slb_bandpass_hilbert_test_epsilon2_coef;
schurOneMlattice_socp_slb_bandpass_hilbert_test_p2_coef;
schurOneMlattice_socp_slb_bandpass_hilbert_test_c2_coef;
k0=k2(:);clear k2;
epsilon0=epsilon2(:);clear epsilon2;
p0=p2(:);clear p2;
c0=c2(:);clear c2;
kc0=[k0;c0];
p_ones = ones(size(p0));

% Initialise coefficient range vectors
Nk=length(k0);
Nc=length(c0);
Nkc=Nk+Nc;
Rk=1:Nk;
Rc=(Nk+1):Nkc;

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
Asqd=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)];
Asqdu=[(10^(-dBas/10))*ones(nasl,1); ...
       ones(nasu-nasl-1,1); ...
       (10^(-dBas/10))*ones(n-nasu+1,1)];
Asqdl=[zeros(napl-1,1);(10^(-dBap/10))*ones(napu-napl+1,1);zeros(n-napu,1)];
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
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Desired pass-band phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=wa(nppl:nppu);
Pd=(pp*pi)-(tp*wp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(nppu-nppl+1,1);

% Desired pass-band group delay response
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
wt=wa(ntpl:ntpu);
Td=tp*ones(length(wt),1);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(length(wt),1);

% Desired pass-band dAsqdw response
ndpl=floor(n*fdpl/0.5)+1;
ndpu=ceil(n*fdpu/0.5)+1;
wd=wa(ndpl:ndpu);
Dd=dp*ones(length(wd),1);
Ddu=Dd+(dpr/2);
Ddl=Dd-(dpr/2);
Wd=Wdp*ones(length(wd),1);

% Constraints on the coefficients
rho=0.999 
dmax=0.05;
kc_u=[rho*ones(Nk,1);10*ones(Nc,1)];
kc_l=-kc_u;
kc0_active=find((kc0)~=0);

% Exact error
Esq0=schurOneMlatticeEsq(k0,epsilon0,p_ones,c0, ...
                         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Allocate digits
nscale=2^(nbits-1);
ndigits_alloc=schurOneMlattice_allocsd_Ito ...
                (nbits,ndigits,k0,epsilon0,p0,c0, ...
                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
k_allocsd_digits=int16(ndigits_alloc(Rk));
c_allocsd_digits=int16(ndigits_alloc(Rc));
printf("k_allocsd_digits=[ ");printf("%2d ",k_allocsd_digits);printf("]';\n");
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%2d");
printf("c_allocsd_digits=[ ");printf("%2d ",c_allocsd_digits);printf("]';\n");
print_polynomial(c_allocsd_digits,"c_allocsd_digits", ...
                 strcat(strf,"_c_allocsd_digits.m"),"%2d");

% Find the signed-digit approximations to kc0
[kc0_sd,kc0_sdu,kc0_sdl]=flt2SD(kc0,nbits,ndigits);
[kc0_digits_sd,kc0_adders_sd]=SDadders(kc0_sd,nbits);
k0_sd=kc0_sd(Rk);
c0_sd=kc0_sd(Rc);
print_polynomial(k0_sd,"k0_sd",nscale);
print_polynomial(k0_sd,"k0_sd",strcat(strf,"_k0_sd_coef.m"),nscale);
print_polynomial(c0_sd,"c0_sd",nscale);
print_polynomial(c0_sd,"c0_sd",strcat(strf,"_c0_sd_coef.m"),nscale);
[kc0_sd_Ito,kc0_sdu_Ito,kc0_sdl_Ito]=flt2SD(kc0,nbits,ndigits_alloc);

[kc0_digits_sd_Ito,kc0_adders_sd_Ito]=SDadders(kc0_sd_Ito,nbits);
k0_sd_Ito=kc0_sd_Ito(Rk);
c0_sd_Ito=kc0_sd_Ito(Rc);
print_polynomial(k0_sd_Ito,"k0_sd_Ito",nscale);
print_polynomial(k0_sd_Ito,"k0_sd_Ito",strcat(strf,"_k0_sd_Ito_coef.m"),nscale);
print_polynomial(c0_sd_Ito,"c0_sd_Ito",nscale);
print_polynomial(c0_sd_Ito,"c0_sd_Ito",strcat(strf,"_c0_sd_Ito_coef.m"),nscale);

% Find initial mean-squared errrors
Esq0=schurOneMlatticeEsq(k0,epsilon0,p_ones,c0, ...
                         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
Esq0_sd=schurOneMlatticeEsq(k0_sd,epsilon0,p_ones,c0_sd, ... 
                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
Esq0_sd_Ito=schurOneMlatticeEsq(k0_sd_Ito,epsilon0,p_ones,c0_sd_Ito, ...
                                wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Find coefficients with successive relaxation
kc=kc0;
kc_active=kc0_active;
while ~isempty(kc_active)
  
  % Try to solve the current SOCP problem for the active coefficients
  try
    feasible=false;
    [nextk,nextc,slb_iter,opt_iter,func_iter,feasible] = ...
      schurOneMlattice_slb(@schurOneMlattice_socp_mmse, ...
                           kc(Rk),epsilon0,p_ones,kc(Rc), ...
                           kc_u,kc_l,kc_active,dmax, ...
                           wa,Asqd,Asqdu,Asqdl,Wa, ...
                           wt,Td,Tdu,Tdl,Wt, ...
                           wp,Pd,Pdu,Pdl,Wp, ...
                           wd,Dd,Ddu,Ddl,Wd, ...
                           maxiter,ftol,ctol,verbose);
    kc=[nextk(:);nextc(:)];
  catch
    feasible=false;
    err=lasterror();
    fprintf(stderr,"%s\n", err.message);
    for e=1:length(err.stack)
      fprintf(stderr,"Called %s at line %d\n", ...
              err.stack(e).name,err.stack(e).line);
    endfor
  end_try_catch

  % If this problem was not solved then give up
  if ~feasible
    error("SOCP problem infeasible!");
  endif

  % Ito et al. suggest ordering the search by max(kc_sdu-kc_sdl)
  [kc_sd_min,kc_sdu_min,kc_sdl_min]=flt2SD(kc,nbits,ndigits_alloc);
  kc_sdul_min=kc_sdu_min-kc_sdl_min;
  [kc_max,kc_max_n]=max(kc_sdul_min(kc_active));
  coef_n=kc_active(kc_max_n);
  kc_active(kc_max_n)=[];
  kc(coef_n)=kc_sd_min(coef_n);
  printf("\nFixed kc(%d)=%g/%d\n",coef_n,kc(coef_n)*nscale,nscale);
  printf("kc=[ ");printf("%g ",kc'*nscale);printf("]/%d;\n",nscale);
  printf("kc_active=[ ");printf("%d ",kc_active);printf("];\n\n");

endwhile

% Adders
kc_sd_min=kc;
[kc_sd_min_digits,kc_sd_min_adders]=SDadders(kc_sd_min,nbits);
printf("%d signed-digits used\n",kc_sd_min_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kc_sd_min_adders,nbits);
fid=fopen(strcat(strf,"_kc_sd_min_digits.tab"),"wt");
fprintf(fid,"$%d$",kc_sd_min_digits);
fclose(fid);
fid=fopen(strcat(strf,"_kc_sd_min_adders.tab"),"wt");
fprintf(fid,"$%d$",kc_sd_min_adders);
fclose(fid);
% Coefficients
k_sd_min=kc_sd_min(Rk);
c_sd_min=kc_sd_min(Rc);
Esq_sd_min=schurOneMlatticeEsq(k_sd_min,epsilon0,p_ones,c_sd_min, ...
                               wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
printf("Esq_sd_min=%g\n",Esq_sd_min);
print_polynomial(k_sd_min,"k_sd_min",nscale);
print_polynomial(k_sd_min,"k_sd_min", ...
                 strcat(strf,"_k_sd_min_coef.m"),nscale);
print_polynomial(c_sd_min,"c_sd_min",nscale);
print_polynomial(c_sd_min,"c_sd_min", ...
                 strcat(strf,"_c_sd_min_coef.m"),nscale);

% Calculate response
Asq_kc0= ...
  schurOneMlatticeAsq(wa,kc0(Rk),epsilon0,p_ones,kc0(Rc));
Asq_kc0_sd= ...
  schurOneMlatticeAsq(wa,kc0_sd(Rk),epsilon0,p_ones,kc0_sd(Rc));
Asq_kc0_sd_Ito= ...
  schurOneMlatticeAsq(wa,kc0_sd_Ito(Rk),epsilon0,p_ones,kc0_sd_Ito(Rc));
Asq_kc_sd_min= ...
  schurOneMlatticeAsq(wa,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));

P_kc0= ...
  schurOneMlatticeP(wp,kc0(Rk),epsilon0,p_ones,kc0(Rc));
P_kc0_sd= ...
  schurOneMlatticeP(wp,kc0_sd(Rk),epsilon0,p_ones,kc0_sd(Rc));
P_kc0_sd_Ito= ...
  schurOneMlatticeP(wp,kc0_sd_Ito(Rk),epsilon0,p_ones,kc0_sd_Ito(Rc));
P_kc_sd_min= ...
  schurOneMlatticeP(wp,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));

T_kc0= ...
  schurOneMlatticeT(wt,kc0(Rk),epsilon0,p_ones,kc0(Rc));
T_kc0_sd= ...
  schurOneMlatticeT(wt,kc0_sd(Rk),epsilon0,p_ones,kc0_sd(Rc));
T_kc0_sd_Ito= ...
  schurOneMlatticeT(wt,kc0_sd_Ito(Rk),epsilon0,p_ones,kc0_sd_Ito(Rc));
T_kc_sd_min= ...
  schurOneMlatticeT(wt,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));

dAsqdw_kc0= ...
  schurOneMlatticedAsqdw(wd,kc0(Rk),epsilon0,p_ones,kc0(Rc));
dAsqdw_kc0_sd= ...
  schurOneMlatticedAsqdw(wd,kc0_sd(Rk),epsilon0,p_ones,kc0_sd(Rc));
dAsqdw_kc0_sd_Ito= ...
  schurOneMlatticedAsqdw(wd,kc0_sd_Ito(Rk),epsilon0,p_ones,kc0_sd_Ito(Rc));
dAsqdw_kc_sd_min= ...
  schurOneMlatticedAsqdw(wd,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));

% Amplitude and delay at local peaks
vAl=local_max(Asqdl-Asq_kc_sd_min);
vAu=local_max(Asq_kc_sd_min-Asqdu);
wAsqS=sort(unique([wa(vAl);wa(vAu);wa([1,end])]));
AsqS=schurOneMlatticeAsq(wAsqS,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));
printf("kc0_sd_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kc0_sd_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

vPl=local_max(Pdl-P_kc_sd_min);
vPu=local_max(P_kc_sd_min-Pdu);
wPS=sort(unique([wp(vPl);wp(vPu);wp([1,end])]));
PS=schurOneMlatticeP(wPS,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));
printf("kc_sd_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kc_sd_min:PS=[ ");printf("%f ",mod((PS+(wPS*tp))'/pi,2));
printf("] (rad./pi)\n");

vTl=local_max(Tdl-T_kc_sd_min);
vTu=local_max(T_kc_sd_min-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
TS=schurOneMlatticeT(wTS,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));
printf("k0_sd_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k0_sd_min:TS=[ ");printf("%f ",TS');printf("] (Samples)\n");

vDl=local_max(Ddl-dAsqdw_kc_sd_min);
vDu=local_max(dAsqdw_kc_sd_min-Ddu);
wDS=sort(unique([wd(vDl);wd(vDu);wd([1,end])]));
DS=schurOneMlatticedAsqdw(wDS,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));
printf("k_sd_kmin:fDS=[ ");printf("%f ",wDS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_sd_kmin:DS=[ ");printf("%f ",DS');printf("]\n")

% Find maximum stop band response
rsb=[1:nasl,nasu:n];
max_sb_Asq_kc0=10*log10(max(abs(Asq_kc0(rsb))))
max_sb_Asq_kc0_sd=10*log10(max(abs(Asq_kc0_sd(rsb))))
max_sb_Asq_kc0_sd_Ito=10*log10(max(abs(Asq_kc0_sd_Ito(rsb))))
max_sb_Asq_kc_sd_min=10*log10(max(abs(Asq_kc_sd_min(rsb))))

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & %4.1f & & \\\\\n",Esq0,max_sb_Asq_kc0);
fprintf(fid,"%d-bit %d-signed-digit & %8.6f & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,max_sb_Asq_kc0_sd,kc0_digits_sd,kc0_adders_sd);
fprintf(fid,"%d-bit %d-signed-digit(Ito) & %8.6f & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd_Ito,max_sb_Asq_kc0_sd_Ito, ...
        kc0_digits_sd_Ito,kc0_adders_sd_Ito);
fprintf(fid,"%d-bit %d-signed-digit(min) & %8.6f & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq_sd_min,max_sb_Asq_kc_sd_min, ...
        kc_sd_min_digits,kc_sd_min_adders);
fclose(fid);

% Plot stop band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_kc0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_kc0_sd_Ito)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_kc_sd_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -40 -30]);
strt=sprintf("Schur lattice bandpass Hilbert filter stop-band : \
nbits=%d,ndigits=%d,fasl=%g,fasu=%g",nbits,ndigits,fasl,fasu);
title(strt);
legend("initial","s-d","s-d(Ito)","s-d(min)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot pass band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_kc0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_kc0_sd_Ito)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_kc_sd_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([min([fapl ftpl fppl]), max([fapu ftpu ftpu]), -0.3, 0.1]);
strt=sprintf("Schur lattice bandpass Hilbert filter pass-band \
amplitude : nbits=%d,ndigits=%d,fapl=%g,fapu=%g",nbits,ndigits,fapl,fapu);
title(strt);
legend("initial","s-d","s-d(Ito)","s-d(min)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_pass"),"-dpdflatex");
close

% Plot phase response
plot(wp*0.5/pi,((P_kc0+(wp*tp))/pi)-pp,"linestyle","-", ...
     wp*0.5/pi,((P_kc0_sd+(wp*tp))/pi)-pp,"linestyle",":", ...
     wp*0.5/pi,((P_kc0_sd_Ito+(wp*tp))/pi)-pp,"linestyle","--", ...
     wp*0.5/pi,((P_kc_sd_min+(wp*tp))/pi)-pp,"linestyle","-.");
xlabel("Frequency");
ylabel("Phase error(rad./$\\pi$)");
axis([min([fapl ftpl fppl]), max([fapu ftpu ftpu]), 0.004*[-1,1]]);
strt=sprintf("Schur lattice bandpass Hilbert filter pass-band phase :\
 nbits=%d,ndigits=%d,fppl=%g,fppu=%g",nbits,ndigits,fppl,fppu);
title(strt);
legend("initial","s-d","s-d(Ito)","s-d(min)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_phase"),"-dpdflatex");
close

% Plot delay response
plot(wt*0.5/pi,T_kc0,"linestyle","-", ...
     wt*0.5/pi,T_kc0_sd,"linestyle",":", ...
     wt*0.5/pi,T_kc0_sd_Ito,"linestyle","--", ...
     wt*0.5/pi,T_kc_sd_min,"linestyle","-.");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([min([fapl ftpl fppl]),max([fapu ftpu ftpu]),(tp+(0.2*[-1,1]))]);
strt=sprintf("Schur lattice bandpass Hilbert filter pass-band delay :\
 nbits=%d,ndigits=%d,ftpl=%g,ftpu=%g",nbits,ndigits,ftpl,ftpu);
title(strt);
legend("initial","s-d","s-d(Ito)","s-d(min)");
legend("location","south");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d%% Frequency points across the band\n",n);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%g %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%g %% Amplitude upper stop band weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Pass band delay lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band delay upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Delay pass band weight\n",Wtp);
fprintf(fid,"fppl=%g %% Pass band phase response lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Pass band phase response upper edge\n",fppu);
fprintf(fid,"pp=%g %% Pass band initial phase response (rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Pass band phase response ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Pass band phase response weight\n",Wpp);
fprintf(fid,"fdpl=%g %% Pass band dAsqdw response lower edge\n",fdpl);
fprintf(fid,"fdpu=%g %% Pass band dAsqdw response upper edge\n",fdpu);
fprintf(fid,"dp=%g %% Pass band initial dAsqdw response (rad./pi)\n",dp);
fprintf(fid,"dpr=%g %% Pass band dAsqdw response ripple(rad./pi)\n",dpr);
fprintf(fid,"Wdp=%g %% Pass band dAsqdw response weight\n",Wdp);
fclose(fid);

% Save results
eval(sprintf("save %s.mat ftol ctol nbits nscale ndigits ndigits_alloc n \
fapl fapu dBap Wap fasl fasu dBas Wasl Wasu ftpl ftpu tp tpr Wtp \
fppl fppu pp ppr Wpp fdpl fdpu dp dpr Wdp \
k0 epsilon0 p0 c0 k0_sd c0_sd k0_sd_Ito c0_sd_Ito k_sd_min c_sd_min",strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
