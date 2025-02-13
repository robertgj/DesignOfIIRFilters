% pop_relaxation_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test.m
% Copyright (C) 2025 Robert G. Jenssen

% POP relaxation optimisation of a Schur one-multiplier allpass
% lattice lowpass differentiator filter with 12-bit signed-digit coefficients
% having an average of 3 signed-digits

test_common;

strf="pop_relaxation_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test"

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
ftol=1e-4
ctol=1e-8
verbose=false;

nbits=12
ndigits=3

use_kc0_coefficient_bounds=true
use_schurOneMlattice_allocsd_Lim=false
use_schurOneMlattice_allocsd_Ito=true
use_fix_coefficient_difference_greater_than_alpha=true
alpha_num=3
alpha_min=0.8
rho=0.999 

%
% Low-pass differentiator filter specification 
%
nN=10; % Order of correction filter for (1-z^-1)
R=2;   % Denominator polynomial in z^-2 only
fap=0.2;fas=0.4;
Arp=0.002;Art=0.002;Ars=0.0104;Wap=1;Wat=0.0001;Was=0.1;
fpp=fap;pp=1.5;ppr=0.002;Wpp=1;
ftp=fap;tp=nN-1;tpr=0.04;Wtp=0.1;
fdp=fap;cpr=0.04;Wdp=0.1;

%
% Initial coefficients
%
schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_k2_coef;
schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_epsilon2_coef;
schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_p2_coef;
schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_c2_coef;
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
f=(1:(n-1))'*0.5/n;
w=2*pi*f;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);
npp=ceil(fpp*n/0.5);
ntp=ceil(ftp*n/0.5);
ndp=ceil(fdp*n/0.5);

% Pass and transition band amplitudes
wa=w;
Rap=1:nap;
Ras=nas:length(w);
Azm1=2*sin(wa/2);
Azm1sq=Azm1.^2;
dAzm1sqdw=2*sin(wa);
Ad=[wa(1:nap)/2;zeros(n-1-nap,1)];
Asqd=Ad.^2;
dAsqddw=Ad;
Adu=[wa(1:nas-1)/2; zeros(n-nas,1)] + ...
    ([Arp*ones(nap,1);Art*ones((nas-nap-1),1);Ars*ones(n-nas,1)]/2);
Asqdu=Adu.^2;
Adl=Ad-([Arp*ones(nap,1);zeros(n-1-nap,1)]/2);
Adl(find(Adl<=0))=0;
Asqdl=Adl.^2;
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas,1)];
% Sanity check
nachk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Ad(nachk)=[");printf("%g ",Ad(nachk));printf(" ]\n");
printf("Adu(nachk)=[");printf("%g ",Adu(nachk));printf(" ]\n");
printf("Adl(nachk)=[");printf("%g ",Adl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");

% Phase response with z^{-1}-1 removed
wp=w(1:npp);
Pzm1=(pi/2)-(wp/2);
Pd=(pi*pp)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% Group delay
wt=w(1:ntp);
Tzm1=0.5;
Td=tp*ones(size(wt));
Tdu=Td+(tpr*ones(ntp,1)/2);
Tdl=Td-(tpr*ones(ntp,1)/2);
Wt=Wtp*ones(size(wt));

% dAsqdw response
wd=wa(1:ndp);
Dd=dAsqddw(1:ndp);
Wd=Wdp*ones(size(wd));
Cd=(Dd-(Asqd(1:ndp).*cot(w(1:ndp)/2)))./Azm1sq(1:ndp);
Cdu=Cd+(cpr/2);
Cdl=Cd-(cpr/2);
dpr=(cpr./Azm1sq(1:ndp));
Ddu=Dd+(dpr/2);
Ddl=Dd-(dpr/2);

% Exact error
Esq0 = ...
  schurOneMlatticeEsq(k0,epsilon0,p_ones,c0, ...
                      wa,Asqd./Azm1sq,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp,wd,Cd,Wd);

% Allocate digits
nscale=2^(nbits-1);
if use_schurOneMlattice_allocsd_Lim
  ndigits_alloc=schurOneMlattice_allocsd_Lim ...
                  (nbits,ndigits,k0,epsilon0,p0,c0, ...
                   wa,Asqd./Azm1sq,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp,wd,Cd,Wd);
elseif use_schurOneMlattice_allocsd_Ito
  ndigits_alloc=schurOneMlattice_allocsd_Ito ...
                  (nbits,ndigits,k0,epsilon0,p0,c0, ...
                   wa,Asqd./Azm1sq,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp,wd,Cd,Wd);
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
  
  % Sanity check on kc_sdul
  [~,n_kc_sdul_0]=find(kc_sdul(kc_active)==0);
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
    kc_fixed_alpha=find(alpha>alpha_min);
    [kc_fixed_sorted,kc_fixed_sorted_i]=sort(alpha(kc_fixed_alpha),"descend");
    if length(kc_fixed_sorted) > alpha_num
      kc_fixed_sorted_i=kc_fixed_sorted_i(1:alpha_num);
    endif
    kc_fixed=kc_fixed_alpha(sort(kc_fixed_sorted_i));
    if isempty(kc_fixed)
      [~,kc_fixed]=max(kc_sdul(kc_active));
    endif
    printf("kc_fixed=[ ");printf("%d ",kc_fixed(:)');printf(" ]\n");
  else 
    % Ito et al. suggest ordering the search by max(kc_sdu-kc_sdl)
    [~,kc_fixed]=max(kc_sdul(kc_active));
  endif
  printf("Fixing coef. kc([ ");
  printf("%d ",kc_active(kc_fixed));
  printf("])=[ ");
  printf("%12.8f ",kc(kc_active(kc_fixed))*nscale);
  printf("]/%d\n",nscale);
  
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
      schurOneMlattice_slb(@schurOneMlattice_pop_socp_mmse, ...
                           kc(Rk),epsilon0,p_ones,kc(Rc), ...
                           kc_u,kc_l,kc_active,kc_fixed, ...
                           wa,Asqd./Azm1sq,Asqdu./Azm1sq,Asqdl./Azm1sq,Wa, ...
                           wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
                           wp,Pd-Pzm1,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
                           wd,Cd,Cdu,Cdl,Wd, ...
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
Asq_kc_sd_min = ...
  schurOneMlatticeAsq(wa,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));

P_kc0= ...
  schurOneMlatticeP(wp,kc0(Rk),epsilon0,p_ones,kc0(Rc));
P_kc0_sd= ...
  schurOneMlatticeP(wp,kc0_sd(Rk),epsilon0,p_ones,kc0_sd(Rc));
P_kc0_sd_Ito= ...
  schurOneMlatticeP(wp,kc0_sd_Ito(Rk),epsilon0,p_ones,kc0_sd_Ito(Rc));
P_kc_sd_min = ...
  schurOneMlatticeP(wp,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));
T_kc_sd_min = ...
  schurOneMlatticeT(wt,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));

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
dAsqdw_kc_sd_min= ...
  schurOneMlatticedAsqdw(wd,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));

% Find mean-squared errrors
Esq0 = ...
  schurOneMlatticeEsq(k0,epsilon0,p_ones,c0, ...
                      wa,Asqd./Azm1sq,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp,wd,Cd,Wd);
Esq0_sd = ...
  schurOneMlatticeEsq(k0_sd,epsilon0,p_ones,c0_sd, ... 
                      wa,Asqd./Azm1sq,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp,wd,Cd,Wd);
Esq0_sd_Ito = ...
  schurOneMlatticeEsq(k0_sd_Ito,epsilon0,p_ones,c0_sd_Ito, ...
                      wa,Asqd./Azm1sq,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp,wd,Cd,Wd);
Esq_sd_min = ...
  schurOneMlatticeEsq(k_sd_min,epsilon0,p_ones,c_sd_min, ...
                      wa,Asqd./Azm1sq,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp,wd,Cd,Wd);
printf("Esq_sd_min=%g\n",Esq_sd_min);

% Amplitude and delay at local peaks
vAl=local_max(Asqdl-(Asq_kc_sd_min.*Azm1sq));
vAu=local_max((Asq_kc_sd_min.*Azm1sq)-Asqdu);
vAsqS=sort(unique([vAl;vAu;1;length(Ad)]));
wAsqS=wa(vAsqS);
AsqS=schurOneMlatticeAsq(wAsqS,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));
printf("kc0_sd_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kc0_sd_min:sqrt(AsqS.*Azm1sq)=[ ");
printf("%f ",sqrt((Azm1sq(vAsqS).*AsqS)'));printf("]\n");

vPl=local_max(Pdl-(P_kc_sd_min+Pzm1));
vPu=local_max((P_kc_sd_min+Pzm1)-Pdu);
vPS=sort(unique([vPl;vPu;1;length(Pd)]));
wPS=wp(vPS);
PS=schurOneMlatticeP(wPS,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));
printf("kc_sd_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kc_sd_min:PS+Pzm1=[ ");printf("%f ",unwrap(PS+Pzm1(vPS)+(wPS*tp))'/pi);
printf("] (rad./pi)\n");

vTl=local_max(Tdl-Tzm1-T_kc_sd_min);
vTu=local_max(T_kc_sd_min-(Tdu-Tzm1));
vTS=sort(unique([vTl;vTu;1;length(Td)]));
wTS=wt(vTS);
TS=schurOneMlatticeT(wTS,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));
printf("k0_sd_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k0_sd_min:TS+Tzm1=[ ");printf("%f ",(TS+Tzm1)');printf("] (Samples)\n");

vCl=local_max(Cdl-dAsqdw_kc_sd_min);
vCu=local_max(dAsqdw_kc_sd_min-Cdu);
wCS=sort(unique([wd(vCl);wd(vCu);wd([1,end])]));
CS=schurOneMlatticedAsqdw(wCS,kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));
printf("kc_sd_kmin:fCS=[ ");printf("%f ",wCS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kc_sd_kmin:CS=[ ");printf("%f ",CS');printf("]\n")

% Find maximum stop band response
rsb=[nas:length(wa)];
max_sb_Asq_kc0=max(abs(Asq_kc0(rsb).*Azm1sq(rsb)))
max_sb_Asq_kc0_sd=max(abs(Asq_kc0_sd(rsb).*Azm1sq(rsb)))
max_sb_Asq_kc0_sd_Ito=max(abs(Asq_kc0_sd_Ito(rsb).*Azm1sq(rsb)))
max_sb_Asq_kc_sd_min=max(abs(Asq_kc_sd_min(rsb).*Azm1sq(rsb)))

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %8.2e & %4.1f & & \\\\\n",Esq0,10*log10(max_sb_Asq_kc0));
fprintf(fid,"%d-bit %d-signed-digit & %8.2e & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,10*log10(max_sb_Asq_kc0_sd),kc0_digits_sd,kc0_adders_sd);
fprintf(fid,"%d-bit %d-signed-digit(Ito) & %8.2e & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd_Ito,10*log10(max_sb_Asq_kc0_sd_Ito), ...
        kc0_digits_sd_Ito,kc0_adders_sd_Ito);
fprintf(fid,"%d-bit %d-signed-digit(POP-relax) & %8.2e & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq_sd_min,10*log10(max_sb_Asq_kc_sd_min), ...
        kc_sd_min_digits,kc_sd_min_adders);
fclose(fid);

% Plot stop band amplitude response
plot(wa*0.5/pi,sqrt(Asq_kc0).*Azm1,"linestyle","-", ...
     wa*0.5/pi,sqrt(Asq_kc0_sd).*Azm1,"linestyle",":", ...
     wa*0.5/pi,sqrt(Asq_kc0_sd_Ito).*Azm1,"linestyle","--", ...
     wa*0.5/pi,sqrt(Asq_kc_sd_min).*Azm1,"linestyle","-.", ...
     wa*0.5/pi,Adu,"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude");
axis([fas 0.5 0 0.008]);
strt=sprintf("Tapped lattice low-pass differentiator filter stop-band \
amplitude : nbits=%d,ndigits=%d,fas=%g",nbits,ndigits,fas);
title(strt);
legend("Exact","s-d","s-d(Ito)","s-d(POP-relax)");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot pass band amplitude response error
plot(wa*0.5/pi,Ad-(Azm1.*sqrt(Asq_kc0)),"linestyle","-", ...
     wa*0.5/pi,Ad-(Azm1.*sqrt(Asq_kc0_sd)),"linestyle",":", ...
     wa*0.5/pi,Ad-(Azm1.*sqrt(Asq_kc0_sd_Ito)),"linestyle","--", ...
     wa*0.5/pi,Ad-(Azm1.*sqrt(Asq_kc_sd_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude error");
axis([0 max([fap fpp ftp]) 0.001*[-1,1]]);
strt=sprintf("Tapped lattice low-pass differentiator filter pass-band \
amplitude error : nbits=%d,ndigits=%d,fap=%g",nbits,ndigits,fap);
title(strt);
legend("Exact","s-d","s-d(Ito)","s-d(POP-relax)");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_pass_error"),"-dpdflatex");
close

% Plot phase response
plot(wp*0.5/pi,((P_kc0+Pzm1+(wp*tp))/pi),"linestyle","-", ...
     wp*0.5/pi,((P_kc0_sd+Pzm1+(wp*tp))/pi),"linestyle",":", ...
     wp*0.5/pi,((P_kc0_sd_Ito+Pzm1+(wp*tp))/pi),"linestyle","--", ...
     wp*0.5/pi,((P_kc_sd_min+Pzm1+(wp*tp))/pi),"linestyle","-.");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$)");
axis([0 max([fap fpp ftp]) pp+(0.001)*[-1,1]]);
strt=sprintf("Tapped lattice low-pass differentiator filter pass-band phase :\
 nbits=%d,ndigits=%d,fpp=%g",nbits,ndigits,fpp);
title(strt);
legend("Exact","s-d","s-d(Ito)","s-d(POP-relax)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_phase"),"-dpdflatex");
close

% Plot delay response
plot(wt*0.5/pi,T_kc0+Tzm1,"linestyle","-", ...
     wt*0.5/pi,T_kc0_sd+Tzm1,"linestyle",":", ...
     wt*0.5/pi,T_kc0_sd_Ito+Tzm1,"linestyle","--", ...
     wt*0.5/pi,T_kc_sd_min+Tzm1,"linestyle","-.");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0 max([fap fpp ftp]),(tp+(0.02*[-1,1]))]);
strt=sprintf("Tapped lattice low-pass differentiator filter pass-band delay :\
 nbits=%d,ndigits=%d,ftp=%g",nbits,ndigits,ftp);
title(strt);
legend("Exact","s-d","s-d(Ito)","s-d(POP-relax)"); 
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Plot stop band correction filter amplitude response
plot(wa*0.5/pi,sqrt(Asq_kc0),"linestyle","-", ...
     wa*0.5/pi,sqrt(Asq_kc0_sd),"linestyle",":", ...
     wa*0.5/pi,sqrt(Asq_kc0_sd_Ito),"linestyle","--", ...
     wa*0.5/pi,sqrt(Asq_kc_sd_min),"linestyle","-.", ...
     wa*0.5/pi,Adu./Azm1,"linestyle","-", ...
     wa*0.5/pi,Adl./Azm1,"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude error");
axis([fas 0.5 0 0.004]);
strt=sprintf("Tapped lattice low-pass differentiator correction filter \
stop-band amplitude error : nbits=%d,ndigits=%d,fas=%g",nbits,ndigits,fas);
title(strt);
legend("Exact","s-d","s-d(Ito)","s-d(POP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_correction_stop"),"-dpdflatex");
close

% Plot pass band correction filter amplitude response error
plot(wa*0.5/pi,sqrt(Asq_kc0)-(Ad./Azm1),"linestyle","-", ...
     wa*0.5/pi,sqrt(Asq_kc0_sd)-(Ad./Azm1),"linestyle",":", ...
     wa*0.5/pi,sqrt(Asq_kc0_sd_Ito)-(Ad./Azm1),"linestyle","--", ...
     wa*0.5/pi,sqrt(Asq_kc_sd_min)-(Ad./Azm1),"linestyle","-.", ...
     wa*0.5/pi,(Adu-Ad)./Azm1,"linestyle","-", ...
     wa*0.5/pi,(Adl-Ad)./Azm1,"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude error");
axis([0 fap 0.01*[-1,1]]);
strt=sprintf("Tapped lattice low-pass differentiator correction filter \
pass-band amplitude error : nbits=%d,ndigits=%d,fap=%g",nbits,ndigits,fap);
title(strt);
legend("Exact","s-d","s-d(Ito)","s-d(POP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_correction_pass"),"-dpdflatex");
close

% Plot correction filter amplitude response
A_kc = sqrt([Asq_kc0,Asq_kc0_sd,Asq_kc0_sd_Ito,Asq_kc_sd_min, ...
             Asqdu./Azm1sq,Asqdl./Azm1sq]);
[ax,ha,hs]=plotyy(wa(Rap)*0.5/pi, A_kc(Rap,:)-(Ad(Rap)./Azm1(Rap)), ...
                  wa(Ras)*0.5/pi, A_kc(Ras,:));
hac=get(ha,"color");
hls={"-",":","--","-.","-","-"};
for c=1:length(hls)
  set(hs(c),"color",hac{c}); 
  set(ha(c),"linestyle",hls{c});
  set(hs(c),"linestyle",hls{c}); 
endfor
axis(ax(1),[0 0.5 0.004*[-1,1]]);
axis(ax(2),[0 0.5 0.004*[-1,1]]);
xlabel("Frequency");
ylabel("Amplitude error");
strt=sprintf("Tapped lattice low-pass differentiator correction filter \
amplitude error : nbits=%d,ndigits=%d,fas=%g",nbits,ndigits,fas);
title(strt);
legend("Exact","s-d","s-d(Ito)","s-d(POP-relax)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_correction_error"),"-dpdflatex");
close

% Plot correction filter dAsqdw error response
plot(wd*0.5/pi,dAsqdw_kc0-Cd,"linestyle","-", ...
     wd*0.5/pi,dAsqdw_kc0_sd-Cd,"linestyle",":", ...
     wd*0.5/pi,dAsqdw_kc0_sd_Ito-Cd,"linestyle","--", ...
     wd*0.5/pi,dAsqdw_kc_sd_min-Cd,"linestyle","-.");
xlabel("Frequency");
ylabel("dAsqdw");
axis([0 fdp 0.02*[-1,1]]);
strt=sprintf("Tapped lattice low-pass differentiator correction filter \
pass-band dAsqdw error : nbits=%d,ndigits=%d,fdp=%g",nbits,ndigits,fdp);
title(strt);
legend("Exact","s-d","s-d(Ito)","s-d(POP-relax)");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_correction_dAsqdw"),"-dpdflatex");
close

% Pole-zero plot
[N_sd_min,D_sd_min] = ...
  schurOneMlattice2tf(kc_sd_min(Rk),epsilon0,p_ones,kc_sd_min(Rc));
print_polynomial(N_sd_min,"N_sd_min");
print_polynomial(N_sd_min,"N_sd_min",strcat(strf,"_N_sd_min_coef.m"));
print_polynomial(D_sd_min,"D_sd_min");
print_polynomial(D_sd_min,"D_sd_min",strcat(strf,"_D_sd_min_coef.m"));
zplane(qroots(conv(N_sd_min,[1,-1])),qroots(D_sd_min));
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
fprintf(fid,"alpha_num=%g %% Fix at most alpha_num coefficients with POP\n", ...
        alpha_num);
fprintf(fid,"alpha_min=%g %% Minimum threshold for alpha\n",alpha_min);
fprintf(fid,"rho=%g %% Upper limit on abs(k)\n",rho);
fprintf(fid,"n=%d%% Frequency points across the band\n",n);
fprintf(fid,"nN=%d %% Correction filter order\n",nN);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"Arp=%g %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Art=%g %% Amplitude transition band peak-to-peak ripple\n",Art);
fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band lower edge\n",fas);
fprintf(fid,"Ars=%g %% Amplitude stop band peak-to-peak ripple\n",Ars);
fprintf(fid,"Was=%g %% Amplitude stop band weight(PCLS)\n",Was);
fprintf(fid,"fpp=%g %% Phase pass band upper edge\n",fpp);
fprintf(fid,"pp=%g %% Nominal pass band phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fprintf(fid,"ftp=%g %% Delay pass band upper edge\n",ftp);
fprintf(fid,"tp=%g %% Pass band group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"fdp=%g %% dAsqdw pass band upper edge\n",fdp);
fprintf(fid,"cpr=%g %% Corr. filter pass band dAsqdw peak-to-peak ripple\n",cpr);
fprintf(fid,"Wdp=%g %% Pass band dAsqdw weight\n",Wdp);
fclose(fid);

% Save results
eval(sprintf("save %s.mat ftol ctol nbits nscale ndigits ndigits_alloc n \
use_kc0_coefficient_bounds \
use_schurOneMlattice_allocsd_Lim \
use_schurOneMlattice_allocsd_Ito \
use_fix_coefficient_difference_greater_than_alpha \
alpha_num alpha_min rho \
fap fas Arp Ars tp tpr pp ppr dpr Wap Wat Was Wtp Wpp Wdp \
k0 epsilon0 p0 c0 k0_sd c0_sd k0_sd_Ito c0_sd_Ito k_sd_min c_sd_min \
N_sd_min D_sd_min",strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
