% pop_relaxation_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test.m
%
% POP relaxation optimisation of a Schur one-multiplier tapped allpass
% lattice bandpass Hilbert filter with 13-bit signed-digit coefficients having
% an average of 4 signed-digits
%
% Unfortunately, I could not find a good filter specification for this script
% that would run under QEMU.
%
% Copyright (C) 2025 Robert G. Jenssen


test_common;

strf="pop_relaxation_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test"

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
ftol=1e-3
ctol=2e-4
verbose=false;

nbits=13
ndigits=3

use_kc0_coefficient_bounds=true
use_plot_intermediate_filters=false
use_schurOneMlattice_allocsd_Lim=false
use_schurOneMlattice_allocsd_Ito=true
use_fix_coefficient_difference_greater_than_alpha=true
use_maximum_number_of_fixed_coefficients_is_alpha_num=true
alpha_num=3
alpha_min=0.5
rho=0.999 

%
% Band-pass Hilbert filter specification
%

fasl=0.05,fapl=0.1,fapu=0.2,fasu=0.25
dBap=0.3,dBas=32,Wasl=20,Watl=0.001,Wap=1,Watu=0.001,Wasu=10
fppl=0.1,fppu=0.2,pp=3.5,ppr=0.0048,Wpp=2
ftpl=0.1,ftpu=0.2,tp=16,tpr=0.32,Wtp=1
fdpl=0.1,fdpu=0.2,dp=0,dpr=1.2,Wdp=0.001

% The following works under QEMU:
% alpha_min=0.8,dBap=1,dBas=30,ppr=0.01,tpr=0.8,dpr=2

%
% Initial coefficients
%
schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_k2_coef;
schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_epsilon2_coef;
schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_p2_coef;
schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_c2_coef;
k0=k2(:);clear k2;
epsilon0=epsilon2(:);clear epsilon2;
p0=p2(:);clear p2;
c0=c2(:);clear c2;
kc0=[k0;c0];
p_ones = ones(size(p0));
kc0_u=[rho*ones(size(k0));10*ones(size(c0))];
kc0_l=-kc0_u;
kc0_active=find((kc0)~=0);

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

% Exact error
Esq0=schurOneMlatticeEsq(k0,epsilon0,p_ones,c0, ...
                         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Allocate digits
nscale=2^(nbits-1);
if use_schurOneMlattice_allocsd_Lim
  ndigits_alloc=schurOneMlattice_allocsd_Lim ...
                  (nbits,ndigits,k0,epsilon0,p0,c0, ...
                   wa,Asqd,ones(size(wa)), ...
                   wt,Td,ones(size(wt)), ...
                   wp,Pd,ones(size(wp)), ...
                   wd,Dd,ones(size(wd)));
elseif use_schurOneMlattice_allocsd_Ito
  ndigits_alloc=schurOneMlattice_allocsd_Ito ...
                  (nbits,ndigits,k0,epsilon0,p0,c0, ...
                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
else
  ndigits_alloc=ndigits*ones(Nkc,1);
endif
k_allocsd_digits=int16(ndigits_alloc(Rk));
c_allocsd_digits=int16(ndigits_alloc(Rc));
printf("k_allocsd_digits=[ ");printf("%2d ",k_allocsd_digits);printf("]';\n"); print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%2d");
printf("c_allocsd_digits=[ ");printf("%2d ",c_allocsd_digits);printf("]';\n");
print_polynomial(c_allocsd_digits,"c_allocsd_digits", ...
                 strcat(strf,"_c_allocsd_digits.m"),"%2d");

% Find the signed-digit approximations to kc0
[kc0_sd,kc0_sdu,kc0_sdl]=flt2SD(kc0,nbits,ndigits);
[kc0_sd_digits,kc0_sd_adders]=SDadders(kc0_sd,nbits);
printf("kc0_sd %d signed-digits used\n",kc0_sd_digits);
printf("kc0_sd %d %d-bit adders used for coefficient multiplications\n", ...
       kc0_sd_adders,nbits);
k0_sd=kc0_sd(Rk);
c0_sd=kc0_sd(Rc);
print_polynomial(k0_sd,"k0_sd",nscale);
print_polynomial(k0_sd,"k0_sd",strcat(strf,"_k0_sd_coef.m"),nscale);
print_polynomial(c0_sd,"c0_sd",nscale);
print_polynomial(c0_sd,"c0_sd",strcat(strf,"_c0_sd_coef.m"),nscale);

[kc0_sd_Ito,kc0_sdu_Ito,kc0_sdl_Ito]=flt2SD(kc0,nbits,ndigits_alloc);
[kc0_sd_Ito_digits,kc0_sd_Ito_adders]=SDadders(kc0_sd_Ito,nbits);
printf("kc0_sd_Ito %d signed-digits used\n",kc0_sd_Ito_digits);
printf("kc0_sd_Ito %d %d-bit adders used for coefficient multiplications\n", ...
       kc0_sd_Ito_adders,nbits);
k0_sd_Ito=kc0_sd_Ito(Rk);
c0_sd_Ito=kc0_sd_Ito(Rc);
print_polynomial(k0_sd_Ito,"k0_sd_Ito",nscale);
print_polynomial(k0_sd_Ito,"k0_sd_Ito",strcat(strf,"_k0_sd_Ito_coef.m"),nscale);
print_polynomial(c0_sd_Ito,"c0_sd_Ito",nscale);
print_polynomial(c0_sd_Ito,"c0_sd_Ito",strcat(strf,"_c0_sd_Ito_coef.m"),nscale);

% Calculate initial response
Asq_kc0= ...
  schurOneMlatticeAsq(wa,kc0(Rk),epsilon0,p_ones,kc0(Rc));
Asq_kc0_sd= ...
  schurOneMlatticeAsq(wa,kc0_sd(Rk),epsilon0,p_ones,kc0_sd(Rc));
Asq_kc0_sd_Ito= ...
  schurOneMlatticeAsq(wa,kc0_sd_Ito(Rk),epsilon0,p_ones,kc0_sd_Ito(Rc));

P_kc0= ...
  schurOneMlatticeP(wp,kc0(Rk),epsilon0,p_ones,kc0(Rc));
P_kc0_sd= ...
  schurOneMlatticeP(wp,kc0_sd(Rk),epsilon0,p_ones,kc0_sd(Rc));
P_kc0_sd_Ito= ...
  schurOneMlatticeP(wp,kc0_sd_Ito(Rk),epsilon0,p_ones,kc0_sd_Ito(Rc));

T_kc0= ...
  schurOneMlatticeT(wt,kc0(Rk),epsilon0,p_ones,kc0(Rc));
T_kc0_sd= ...
  schurOneMlatticeT(wt,kc0_sd(Rk),epsilon0,p_ones,kc0_sd(Rc));
T_kc0_sd_Ito= ...
  schurOneMlatticeT(wt,kc0_sd_Ito(Rk),epsilon0,p_ones,kc0_sd_Ito(Rc));

dAsqdw_kc0= ...
  schurOneMlatticedAsqdw(wd,kc0(Rk),epsilon0,p_ones,kc0(Rc));
dAsqdw_kc0_sd= ...
  schurOneMlatticedAsqdw(wd,kc0_sd(Rk),epsilon0,p_ones,kc0_sd(Rc));
dAsqdw_kc0_sd_Ito= ...
  schurOneMlatticedAsqdw(wd,kc0_sd_Ito(Rk),epsilon0,p_ones,kc0_sd_Ito(Rc));

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
iter=0;

while ~isempty(kc_active)
  iter=iter+1;
  
  % Show kc_active
  printf("\nkc_active=[ ");printf("%d ",kc_active);printf("]\n");
  printf("kc=[ ");printf("%g ",nscale*kc');printf("]'/%d;\n",nscale);

  % Find the limits of the signed-digit approximations to k and c
  [~,kc_sdu,kc_sdl]=flt2SD(kc,nbits,ndigits_alloc);
  kc_sdul=kc_sdu-kc_sdl;
  printf("kc_sdl=[ ");printf("%g ",nscale*kc_sdl');printf("]'/%d;\n",nscale);
  printf("kc_sdu=[ ");printf("%g ",nscale*kc_sdu');printf("]'/%d;\n",nscale);
  printf("kc_sdul=[ ");printf("%g ",nscale*kc_sdul');printf("]'/%d;\n",nscale);
  
  % Sanity check on kc_sdul
  n_kc_sdul_0=find(kc_sdul(kc_active)==0);
  if ~isempty(n_kc_sdul_0)
    kc_active(n_kc_sdul_0) = [];
    if isempty(kc_active)
      break;
    else
      continue;
    endif
  endif
    
  if use_fix_coefficient_difference_greater_than_alpha
    % Lu suggests fixing the coefficients for which alpha>alpha_min
    alpha=abs((2*kc)-kc_sdu-kc_sdl);
    alpha=alpha(kc_active)./kc_sdul(kc_active);
    printf("alpha=[ ");printf(" %g",alpha(:)');printf(" ]\n");
    kc_fixed_alpha=find(alpha>alpha_min);
    printf("kc_fixed_alpha=[ ");printf(" %d",kc_fixed_alpha(:)');printf(" ]\n");
    if use_maximum_number_of_fixed_coefficients_is_alpha_num
      [kc_fixed_sorted,kc_fixed_sorted_i]=sort(alpha(kc_fixed_alpha),"descend");
      if length(kc_fixed_sorted) > alpha_num
        kc_fixed_sorted_i=kc_fixed_sorted_i(1:alpha_num);
      endif
      kc_fixed=kc_fixed_alpha(sort(kc_fixed_sorted_i));
    else
      kc_fixed=find(alpha>alpha_min);
    endif
    if isempty(kc_fixed)
      [~,kc_fixed]=max(kc_sdul(kc_active));
    endif
    printf("kc_sdl_fixed=[ ");
    printf("%g ",nscale*kc_sdl(kc_active(kc_fixed))');
    printf("]'/%d;\n",nscale);
    printf("kc_sdu_fixed=[ ");
    printf("%g ",nscale*kc_sdu(kc_active(kc_fixed))');
    printf("]'/%d;\n",nscale);
    printf("kc_sdul_fixed=[ ");
    printf("%g ",nscale*kc_sdul(kc_active(kc_fixed))');
    printf("]'/%d;\n",nscale);
    printf("kc_fixed=[ ");printf("%d ",kc_fixed(:)');printf(" ]\n");
    alpha_kc_fixed=alpha(kc_fixed)(:)';
    printf("Selected alpha=[ ");printf(" %g",alpha_kc_fixed);printf(" ]\n");
  else 
    % Ito et al. suggest ordering the search by max(kc_sdu-kc_sdl)
    [~,kc_fixed]=max(kc_sdul(kc_active));
  endif
  printf("Fixing coef. kc([ ");
  printf("%d ",kc_active(kc_fixed));
  printf("])=[ ");
  printf("%12.8f ",kc(kc_active(kc_fixed))*nscale);
  printf("]/%d\n",nscale);
  printf("k=[ ");  printf("%g ",kc(Rk)'*nscale);printf(" ]'\n"); 
  printf("c=[ ");  printf("%g ",kc(Rc)'*nscale);printf(" ]'\n");
 
  % Initialise upper and lower constraints on kc
  kc_u=kc;
  kc_l=kc;
  if use_kc0_coefficient_bounds
    kc_u(kc_active)=kc0_u(kc_active);
    kc_l(kc_active)=kc0_l(kc_active);
  else
    kc_u(kc_active)=kc_sdu(kc_active);
    kc_l(kc_active)=kc_sdl(kc_active);
  endif
  coef_n=kc_active(kc_fixed);
  kc_u(coef_n)=kc_sdu(coef_n);
  kc_l(coef_n)=kc_sdl(coef_n);

  % Try to solve the current POP problem for the active coefficients
  try
    feasible=false;
    [nextk,nextc,slb_iter,opt_iter,func_iter,feasible] = ...
      schurOneMlattice_slb(@schurOneMlattice_pop_mmse, ...
                           kc(Rk),epsilon0,p_ones,kc(Rc), ...
                           kc_u,kc_l,kc_active,kc_fixed, ...
                           wa,Asqd,Asqdu,Asqdl,Wa, ...
                           wt,Td,Tdu,Tdl,Wt, ...
                           wp,Pd,Pdu,Pdl,Wp, ...
                           wd,Dd,Ddu,Ddl,Wd, ...
                           maxiter,ftol,ctol,verbose);
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
    error("POP problem infeasible!");
  endif

  % Update coefficients
  kc=[nextk(:);nextc(:)];
  
  % Fix coefficient
  kc_fixed_sd=flt2SD(kc(coef_n),nbits,ndigits_alloc(coef_n));
  kc(coef_n)=kc_fixed_sd;
  printf("Fixed kc([ ");
  printf("%d ",kc_active(kc_fixed));
  printf("])=[ ");
  printf("%g ",kc(kc_active(kc_fixed))*nscale);
  printf("]/%d\n",nscale);

  % Update kc_active
  kc_active(kc_fixed)=[];

  if use_plot_intermediate_filters
    % Calculate intermediate response
    Asq_kc=schurOneMlatticeAsq(wa,kc(Rk),epsilon0,p_ones,kc(Rc));
    P_kc=schurOneMlatticeP(wp,kc(Rk),epsilon0,p_ones,kc(Rc));
    T_kc=schurOneMlatticeT(wt,kc(Rk),epsilon0,p_ones,kc(Rc));
    dAsqdw_kc=schurOneMlatticedAsqdw(wd,kc(Rk),epsilon0,p_ones,kc(Rc));
    % Plot intermediate filter response
    subplot(411);
    plot(wa*0.5/pi,10*log10(Asq_kc));
    axis([0 0.5 -40 10]);
    grid("on");
    strP=sprintf(["POP band-pass Hilbert R2 filter (%d) : ", ...
                  "fasl=%g,fapl=%g,fapu=%g,fasu=%g,dBap=%g,dBas=%g,tp=%g"], ...
                 iter,fasl,fapl,fapu,fasu,dBap,dBas,tp);
    title(strP);
    ylabel("Amplitude");
    subplot(412);
    plot(wp*0.5/pi,(P_kc-(pp*pi)+(wp*tp))/pi);
    %axis([0 0.5 [-1,1])]);
    grid("on");
    ylabel("Phase(rad./$\\pi$)");
    subplot(413);
    plot(wt*0.5/pi,T_kc);
    %axisa([0 0.5 tp+tpr*[-1,1]]);
    grid("on");
    ylabel("Delay(samples)");
    subplot(414);
    plot(wd*0.5/pi,dAsqdw_kc);
    axis([0 0.5 -1 1]);
    grid("on");
    ylabel("dAsqdw");
    xlabel("Frequency");
    print(sprintf("%s_iter_%d_response",strf,iter),"-dpdflatex");
    close
  endif
  
endwhile

% Adders
kc_min=kc;
[kc_min_digits,kc_min_adders]=SDadders(kc_min,nbits);
printf("%d signed-digits used\n",kc_min_digits);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       kc_min_adders,nbits);
% Coefficients
k_min=kc_min(Rk);
c_min=kc_min(Rc);
Esq_min=schurOneMlatticeEsq(k_min,epsilon0,p_ones,c_min, ...
                               wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
printf("Esq_min=%g\n",Esq_min);
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min", ...
                 strcat(strf,"_k_min_coef.m"),nscale);
print_polynomial(c_min,"c_min",nscale);
print_polynomial(c_min,"c_min", ...
                 strcat(strf,"_c_min_coef.m"),nscale);

% Calculate response
Asq_kc_min=schurOneMlatticeAsq(wa,kc_min(Rk),epsilon0,p_ones,kc_min(Rc));
P_kc_min=schurOneMlatticeP(wp,kc_min(Rk),epsilon0,p_ones,kc_min(Rc));
T_kc_min=schurOneMlatticeT(wt,kc_min(Rk),epsilon0,p_ones,kc_min(Rc));
dAsqdw_kc_min= ...
  schurOneMlatticedAsqdw(wd,kc_min(Rk),epsilon0,p_ones,kc_min(Rc));

% Amplitude and delay at local peaks
vAl=local_max(Asqdl-Asq_kc_min);
vAu=local_max(Asq_kc_min-Asqdu);
wAsqS=sort(unique([wa(vAl);wa(vAu);wa([1,end])]));
AsqS=schurOneMlatticeAsq(wAsqS,kc_min(Rk),epsilon0,p_ones,kc_min(Rc));
printf("kc0_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kc0_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

vPl=local_max(Pdl-P_kc_min);
vPu=local_max(P_kc_min-Pdu);
wPS=sort(unique([wp(vPl);wp(vPu);wp([1,end])]));
PS=schurOneMlatticeP(wPS,kc_min(Rk),epsilon0,p_ones,kc_min(Rc));
printf("kc_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kc_min:PS=[ ");printf("%f ",rem((PS+(wPS*tp))'/pi,2));
printf("] (rad./pi)\n");

vTl=local_max(Tdl-T_kc_min);
vTu=local_max(T_kc_min-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
TS=schurOneMlatticeT(wTS,kc_min(Rk),epsilon0,p_ones,kc_min(Rc));
printf("k0_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k0_min:TS=[ ");printf("%f ",TS');printf("] (Samples)\n");

vDl=local_max(Ddl-dAsqdw_kc_min);
vDu=local_max(dAsqdw_kc_min-Ddu);
wDS=sort(unique([wd(vDl);wd(vDu);wd([1,end])]));
DS=schurOneMlatticedAsqdw(wDS,kc_min(Rk),epsilon0,p_ones,kc_min(Rc));
printf("k_sd_kmin:fDS=[ ");printf("%f ",wDS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_sd_kmin:DS=[ ");printf("%f ",DS');printf("]\n")

% Find maximum stop band response
rsb=[1:nasl,nasu:n];
max_sb_Asq_kc0=10*log10(max(abs(Asq_kc0(rsb))))
max_sb_Asq_kc0_sd=10*log10(max(abs(Asq_kc0_sd(rsb))))
max_sb_Asq_kc0_sd_Ito=10*log10(max(abs(Asq_kc0_sd_Ito(rsb))))
max_sb_Asq_kc_min=10*log10(max(abs(Asq_kc_min(rsb))))

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %10.4e & %6.2f & & \\\\\n",Esq0,max_sb_Asq_kc0);
fprintf(fid,"%d-bit %d-signed-digit & %10.4e & %6.2f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd,max_sb_Asq_kc0_sd,kc0_sd_digits,kc0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(Ito) & %10.4e & %6.2f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd_Ito,max_sb_Asq_kc0_sd_Ito, ...
        kc0_sd_Ito_digits,kc0_sd_Ito_adders);
fprintf(fid,"%d-bit %d-signed-digit(POP min.) & %10.4e & %6.2f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_min,max_sb_Asq_kc_min, ...
        kc_min_digits,kc_min_adders);
fclose(fid);

% Plot stop band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_kc0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_kc0_sd_Ito)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_kc_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -40 -30]);
strt=sprintf(["Bandpass Hilbert R=2 filter : ", ...
              "nbits=%d,ndigits=%d,fasl=%g,fasu=%g"],nbits,ndigits,fasl,fasu);
title(strt);
legend("Exact","s-d","s-d(Ito)","s-d(POP-relax)");
legend("location","southwest");
legend("boxoff");
legend("right");
grid("on");
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot pass band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_kc0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_kc0_sd_Ito)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_kc_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([min([fapl fppl ftpl]), max([fapu fppu ftpu]), -0.2, 0.05]);
strt=sprintf(["Bandpass Hilbert R=2 filter :", ...
              " nbits=%d,ndigits=%d,fapl=%g,fapu=%g"],nbits,ndigits,fapl,fapu);
title(strt);
legend("Exact","s-d","s-d(Ito)","s-d(POP-relax)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_pass"),"-dpdflatex");
close

% Plot phase response
plot(wp*0.5/pi,rem((P_kc0+(wp*tp))/pi,2),"linestyle","-", ...
     wp*0.5/pi,rem((P_kc0_sd+(wp*tp))/pi,2),"linestyle",":", ...
     wp*0.5/pi,rem((P_kc0_sd_Ito+(wp*tp))/pi,2),"linestyle","--", ...
     wp*0.5/pi,rem((P_kc_min+(wp*tp))/pi,2),"linestyle","-.");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$)");
axis([min([fapl fppl ftpl]), max([fapu fppu fppu]), rem(pp,2)+(0.004*[-1,1])]);
strt=sprintf(["Bandpass Hilbert R=2 filter :", ...
              " nbits=%d,ndigits=%d,fppl=%g,fppu=%g"],nbits,ndigits,fppl,fppu);
title(strt);
legend("Exact","s-d","s-d(Ito)","s-d(POP-relax)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_phase"),"-dpdflatex");
close

% Plot delay response
plot(wt*0.5/pi,T_kc0,"linestyle","-", ...
     wt*0.5/pi,T_kc0_sd,"linestyle",":", ...
     wt*0.5/pi,T_kc0_sd_Ito,"linestyle","--", ...
     wt*0.5/pi,T_kc_min,"linestyle","-.");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([min([fapl fppl ftpl]),max([fapu fppu ftpu]),(tp+(0.2*[-1,1]))]);
strt=sprintf(["Bandpass Hilbert R=2 filter : ", ...
              " nbits=%d,ndigits=%d,ftpl=%g,ftpu=%g"],nbits,ndigits,ftpl,ftpu);
title(strt);
legend("Exact","s-d","s-d(Ito)","s-d(POP-relax)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Pole-zero plot
[N_min,D_min] = ...
  schurOneMlattice2tf(kc_min(Rk),epsilon0,p_ones,kc_min(Rc));
print_polynomial(N_min,"N_min");
print_polynomial(N_min,"N_min",strcat(strf,"_N_min_coef.m"));
print_polynomial(D_min,"D_min");
print_polynomial(D_min,"D_min",strcat(strf,"_D_min_coef.m"));
zplane(qroots(N_min),qroots(D_min));
strt="Bandpass Hilbert R=2 filter";
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"use_kc0_coefficient_bounds=%d\n", ...
        use_kc0_coefficient_bounds);
fprintf(fid,"use_schurOneMlattice_allocsd_Lim=%d\n", ...
        use_schurOneMlattice_allocsd_Lim);
fprintf(fid,"use_schurOneMlattice_allocsd_Ito=%d\n", ...
        use_schurOneMlattice_allocsd_Ito);
fprintf(fid,"use_fix_coefficient_difference_greater_than_alpha=%d\n", ...
        use_fix_coefficient_difference_greater_than_alpha);
fprintf(fid,"use_maximum_number_of_fixed_coefficients_is_alpha_num=%d\n", ...
        use_maximum_number_of_fixed_coefficients_is_alpha_num);
fprintf(fid,"alpha_num=%g %% Fix at most alpha_num coefficients with POP\n", ...
        alpha_num);
fprintf(fid,"alpha_min=%g %% Minimum threshold for alpha\n",alpha_min);
fprintf(fid,"rho=%g %% Upper limit on abs(k)\n",rho);
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
fprintf(fid,"fppl=%g %% Pass band phase response lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Pass band phase response upper edge\n",fppu);
fprintf(fid,"pp=%g %% Pass band initial phase response (rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Pass band phase response ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Pass band phase response weight\n",Wpp);
fprintf(fid,"ftpl=%g %% Pass band delay lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band delay upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Delay pass band weight\n",Wtp);
fprintf(fid,"fdpl=%g %% Pass band dAsqdw response lower edge\n",fdpl);
fprintf(fid,"fdpu=%g %% Pass band dAsqdw response upper edge\n",fdpu);
fprintf(fid,"dp=%g %% Pass band initial dAsqdw response (rad./pi)\n",dp);
fprintf(fid,"dpr=%g %% Pass band dAsqdw response ripple\n",dpr);
fprintf(fid,"Wdp=%g %% Pass band dAsqdw response weight\n",Wdp);
fclose(fid);

% Save results
eval(sprintf(["save %s.mat ftol ctol nbits nscale ndigits ndigits_alloc n ", ...
              "use_kc0_coefficient_bounds ", ...
              "use_schurOneMlattice_allocsd_Lim ", ...
              "use_schurOneMlattice_allocsd_Ito ", ...
              "use_fix_coefficient_difference_greater_than_alpha ", ...
              "alpha_num alpha_min rho ", ...
              "fapl fapu dBap Wap fasl fasu dBas Wasl Wasu ", ...
              "ftpl ftpu tp tpr Wtp ", ...
              "fppl fppu pp ppr Wpp ", ...
              "fdpl fdpu dp dpr Wdp ", ...
              "k0 epsilon0 p0 c0 k0_sd c0_sd k0_sd_Ito c0_sd_Ito ", ...
              "k_min c_min N_min D_min"], ...
             strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
