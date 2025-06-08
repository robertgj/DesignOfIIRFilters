% pop_relaxation_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test.m
%
% POP relaxation optimisation of a Schur one-multiplier allpass
% lattice lowpass differentiator filter with 12-bit signed-digit coefficients
% having an average of 3 signed-digits
%
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="pop_relaxation_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test"

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false;
maxiter=2000
ftol=1e-4
ctol=1e-8
nbits=12
nscale=2^(nbits-1);
ndigits=3

% Options
use_kc0_coefficient_bounds=true
use_schurOneMlattice_allocsd_Lim=true
use_schurOneMlattice_allocsd_Ito=false
use_fix_coefficient_difference_greater_than_alpha=true
alpha_num=3
alpha_min=0.8
rho=0.999 

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
p_ones = ones(size(p0));

%
% Low-pass differentiator filter specification 
%
nN=10; % Order of correction filter for (1-z^-1)
R=2;   % Denominator polynomial in z^-2 only
fap=0.2;fas=0.4;
Arp=0.002;Art=0.002;Ars=0.0104;Wap=1;Wat=0.0001;Was=0.1;
fpp=fap;pp=1.5;ppr=0.0008;Wpp=1;
ftp=fap;tp=nN-1;tpr=0.02;Wtp=0.1;
fdp=fap;cpr=0.04;Wdp=0.1;

%
% Frequency vectors
%
n=1000;
f=(1:(n-1))'*0.5/n;
w=2*pi*f;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);
Rap=1:nap;
Ras=nas:length(w);
npp=ceil(fpp*n/0.5);
ntp=ceil(ftp*n/0.5);
ndp=ceil(fdp*n/0.5);

% Pass and transition band amplitudes
wa=w;
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

% Phase
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

% dAsqdw 
wd=wa(1:ndp);
Dd=dAsqddw(1:ndp);
Wd=Wdp*ones(size(wd));
Cd=(Dd-(Asqd(1:ndp).*cot(w(1:ndp)/2)))./Azm1sq(1:ndp);
Cdu=Cd+(cpr/2);
Cdl=Cd-(cpr/2);
dpr=(cpr*Azm1sq(1:ndp));
Ddu=Dd+(dpr/2);
Ddl=Dd-(dpr/2);

% Initial response
Csq0=schurOneMlatticeAsq(wa,k0,epsilon0,p_ones,c0);
A0=sqrt(Csq0).*Azm1;
P0=schurOneMlatticeP(wp,k0,epsilon0,p_ones,c0)+Pzm1;
T0=schurOneMlatticeT(wt,k0,epsilon0,p_ones,c0)+Tzm1;
dCsqdw0=schurOneMlatticedAsqdw(wd,k0,epsilon0,p_ones,c0);
dAsqdw0=(Csq0(1:ndp).*dAzm1sqdw(1:ndp))+(dCsqdw0.*(Azm1sq(1:ndp)));

% Find kc0 error
Esq0=schurOneMlatticeEsq(k0,epsilon0,p_ones,c0, ...
                         wa,(Ad./Azm1).^2,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp);

% Constraints on the coefficients
dmax=inf;
rho=1-ftol;
k0=k0(:);
c0=c0(:);
kc0=[k0;c0];
Nk=length(k0);
Nc=length(c0);
Nkc=Nk+Nc;
Rk=(1:Nk)';
Rc=((Nk+1):Nkc)';
kc0_u=[rho*ones(size(k0));10*ones(size(c0))];
kc0_l=-kc0_u;
kc0_active=[find(k0(Rk)~=0);Rc];

% Signed-digit coefficients with no allocation
kc0_sd_no_alloc=flt2SD(kc0,nbits,ndigits);
k0_sd_no_alloc=kc0_sd_no_alloc(1:Nk);
c0_sd_no_alloc=kc0_sd_no_alloc((Nk+1):end);
print_polynomial(k0_sd_no_alloc,"k0_sd_no_alloc",nscale);
print_polynomial(k0_sd_no_alloc,"k0_sd_no_alloc", ...
                 strcat(strf,"_k0_sd_no_alloc_coef.m"),nscale);
print_polynomial(c0_sd_no_alloc,"c0_sd_no_alloc",nscale);
print_polynomial(c0_sd_no_alloc,"c0_sd_no_alloc", ...
                 strcat(strf,"_c0_sd_no_alloc_coef.m"),nscale);

% Find the number of signed-digits and adders used by kc0_sd_no_alloc
[kc0_sd_no_alloc_digits,kc0_sd_no_alloc_adders] = ...
  SDadders(kc0_sd_no_alloc(find(kc0_sd_no_alloc~=0)),nbits);

% Find kc0_sd_no_alloc error
Esq0_sd_no_alloc= ...
  schurOneMlatticeEsq(k0_sd_no_alloc,epsilon0,p_ones,c0_sd_no_alloc, ...
                      wa,Asqd./Azm1sq,Wa, ...
                      wt,Td-Tzm1,Wt, ...
                      wp,Pd-Pzm1,Wp, ...
                      wd,Cd,Wd);

%
% Allocate signed-digits to the coefficients
%
if use_schurOneMlattice_allocsd_Lim
  if 1
    ndigits_alloc = ...
       schurOneMlattice_allocsd_Lim(nbits,ndigits,k0,epsilon0,p_ones,c0, ...
                                    wa,Asqd./Azm1sq,ones(size(Wa)), ...
                                    wt,Td-Tzm1,ones(size(Wt)), ...
                                    wp,Pd-Pzm1,ones(size(Wp)), ...
                                    wd,Cd,ones(size(Wd)));
  else
    ndigits_alloc = ...
        schurOneMlattice_allocsd_Lim(nbits,ndigits,k0,epsilon0,p_ones,c0, ...
                                     wa,Asqd./Azm1sq,Wa, ...
                                     wt,Td-Tzm1,Wt, ...
                                     wp,Pd-Pzm1,Wp, ...
                                     wd,Cd,Wd);
  endif
  strItoLim="Lim";
elseif use_schurOneMlattice_allocsd_Ito
  ndigits_alloc = ...
    schurOneMlattice_allocsd_Ito(nbits,ndigits,k0,epsilon0,p_ones,c0, ...
                                 wa,Asqd./Azm1sq,Wa, ...
                                 wt,Td-Tzm1,Wt, ...
                                 wp,Pd-Pzm1,Wp, ...
                                 wd,Cd,Wd);
  strItoLim="Ito";
else
  ndigits_alloc=zeros(size(kc0));
  ndigits_alloc(kc0_active)=ndigits;
  strItoLim="none";
endif
k_allocsd_digits=int16(ndigits_alloc(1:Nk));
c_allocsd_digits=int16(ndigits_alloc((Nk+1):end));
print_polynomial(k_allocsd_digits,"k_allocsd_digits","%1d");
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%1d");
print_polynomial(c_allocsd_digits,"c_allocsd_digits","%1d");
print_polynomial(c_allocsd_digits,"c_allocsd_digits", ...
                 strcat(strf,"_c_allocsd_digits.m"),"%1d");

% Find the signed-digit approximations to k0 and c0 with allocation
[kc0_sd,kc0_sdu,kc0_sdl]=flt2SD(kc0,nbits,ndigits_alloc);
k0_sd=kc0_sd(1:Nk);
k0_sd=k0_sd(:);
c0_sd=kc0_sd((Nk+1):end);
c0_sd=c0_sd(:);
print_polynomial(k0_sd,"k0_sd",nscale);
print_polynomial(k0_sd,"k0_sd",strcat(strf,"_k0_sd_coef.m"),nscale);
print_polynomial(c0_sd,"c0_sd",nscale);
print_polynomial(c0_sd,"c0_sd",strcat(strf,"_c0_sd_coef.m"),nscale);

% Initialise kc_active
kc0_sdul=kc0_sdu-kc0_sdl;
kc0_active=find(kc0_sdul~=0);
n_active=length(kc0_active);
% Check for consistent upper and lower bounds
if any(kc0_sdl>kc0_sdu)
  error("found kc0_sdl>kc0_sdu");
endif
if any(kc0_sdl>kc0_sdu)
  error("found kc0_sdl>kc0_sdu");
endif
if any(kc0_sd(kc0_active)>kc0_sdu(kc0_active))
  error("found kc0_sd(kc0_active)>kc0_sdu(kc0_active)");
endif
if any(kc0_sdl(kc0_active)>kc0_sd(kc0_active))
  error("found kc0_sdl(kc0_active)>kc0_sd(kc0_active)");
endif
if any(kc0(kc0_active)>kc0_sdu(kc0_active))
  error("found kc0(kc0_active)>kc0_sdu(kc0_active)");
endif
if any(kc0_sdl(kc0_active)>kc0(kc0_active))
  error("found kc0_sdl>kc0");
endif

% Find kc0_sd error
Esq0_sd=schurOneMlatticeEsq(k0_sd,epsilon0,p_ones,c0_sd, ...
                            wa,(Ad./Azm1).^2,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp);

% Find the number of signed-digits and adders used by kc0_sd
[kc0_sd_digits,kc0_sd_adders]=SDadders(kc0_sd(kc0_active),nbits);

% Initialise the vector of filter coefficients to be optimised
kc=zeros(size(kc0));
kc(kc0_active)=kc0(kc0_active);
kc_l=kc0_l;
kc_u=kc0_u;
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
      schurOneMlattice_slb(@schurOneMlattice_pop_mmse, ...
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

  % Fix coeff_n
  kc=[nextk(:);nextc(:)];
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
kc_min=kc;
k_min=kc_min(Rk);
c_min=kc_min(Rc);
Esq_min=schurOneMlatticeEsq(k_min,epsilon0,p_ones,c_min, ...
                            wa,(Ad./Azm1).^2,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
print_polynomial(c_min,"c_min",nscale);
print_polynomial(c_min,"c_min",strcat(strf,"_c_min_coef.m"),nscale);
% Find the number of signed-digits and adders used by kc_sd
[kc_min_digits,kc_min_adders]=SDadders(kc_min(kc0_active),nbits);
printf("%d signed-digits used\n",kc_min_digits);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       kc_min_adders,nbits);

fid=fopen(strcat(strf,"_kc_min_digits.tab"),"wt");
fprintf(fid,"$%d$",kc_min_digits);
fclose(fid);
fid=fopen(strcat(strf,"_kc_min_adders.tab"),"wt");
fprintf(fid,"$%d$",kc_min_adders);
fclose(fid);

%
% Filter a quantised noise signal and check the state variables
%
nsamples=2^12;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u); 
u=round(u*nscale);
[yap,y,xx]=schurOneMlatticeFilter(k0,epsilon0,p_ones,c0,u,"round");
stdx=std(xx)
[yapf,yf,xxf]= ...
  schurOneMlatticeFilter(k_min,epsilon0,ones(size(k0)),c_min,u,"round");
stdxf=std(xxf)
         
%
% Amplitude and delay at local peaks
%
Csq=schurOneMlatticeAsq(wa,k_min,epsilon0,p_ones,c_min);
Asq=Csq.*Azm1sq;
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AsqS=schurOneMlatticeAsq(wAS,k_min,epsilon0,p_ones,c_min);
AS=sqrt(AsqS);
printf("k,c_min:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:AS=[ ");printf("%f ",AS');printf(" ]\n");

Tc=schurOneMlatticeT(wt,k_min,epsilon0,p_ones,c_min);
T=Tc+Tzm1;
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMlatticeT(wTS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:TS=[ ");printf("%f ",TS');printf("] (samples)\n");

Pc=schurOneMlatticeP(wp,k_min,epsilon0,p_ones,c_min);
P=Pc+Pzm1;
vPl=local_max(Pdl-P);
vPu=local_max(P-Pdu);
wPS=unique([wp(vPl);wp(vPu);wp([1,end])]);
PS=schurOneMlatticeP(wPS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:PS=[ ");printf("%f ",(PS+(wPS*tp))'/pi);printf("] (rad./pi)\n");

dCsqdw=schurOneMlatticedAsqdw(wd,k_min,epsilon0,p_ones,c_min);
dAsqdw=(Csq(1:ndp).*dAzm1sqdw(1:ndp))+(dCsqdw0.*(Azm1sq(1:ndp)));
vDl=local_max(Ddl-dAsqdw);
vDu=local_max(dAsqdw-Ddu);
wDS=unique([wd(vDl);wd(vDu);wd([1,end])]);
DS=schurOneMlatticedAsqdw(wDS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fdS=[ ");printf("%f ",wDS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:dS=[ ");printf("%f ",DS');printf("]\n");

%
% Calculate response
%
Csq_kc0=schurOneMlatticeAsq(wa,k0,epsilon0,p_ones,c0);
Asq_kc0=Csq_kc0.*Azm1sq;
Csq_kc0_sd_no_alloc=schurOneMlatticeAsq ...
                      (wa,k0_sd_no_alloc,epsilon0,p_ones,c0_sd_no_alloc);
Asq_kc0_sd_no_alloc=Csq_kc0_sd_no_alloc.*Azm1sq;
Csq_kc0_sd=schurOneMlatticeAsq(wa,k0_sd,epsilon0,p_ones,c0_sd);
Asq_kc0_sd=Csq_kc0_sd.*Azm1sq;
Csq_kc_min=schurOneMlatticeAsq(wa,k_min,epsilon0,p_ones,c_min);
Asq_kc_min=Csq_kc_min.*Azm1sq;

Tc_kc0=schurOneMlatticeT(wt,k0,epsilon0,p_ones,c0);
T_kc0=Tc_kc0+Tzm1;
Tc_kc0_sd_no_alloc=schurOneMlatticeT ...
                     (wt,k0_sd_no_alloc,epsilon0,p_ones,c0_sd_no_alloc);
T_kc0_sd_no_alloc=Tc_kc0_sd_no_alloc+Tzm1;
Tc_kc0_sd=schurOneMlatticeT(wt,k0_sd,epsilon0,p_ones,c0_sd);
T_kc0_sd=Tc_kc0_sd+Tzm1;
Tc_kc_min=schurOneMlatticeT(wt,k_min,epsilon0,p_ones,c_min);
T_kc_min=Tc_kc_min+Tzm1;

Pc_kc0=schurOneMlatticeP(wp,k0,epsilon0,p_ones,c0);
P_kc0=Pc_kc0+Pzm1;
Pc_kc0_sd_no_alloc=schurOneMlatticeP ...
                     (wp,k0_sd_no_alloc,epsilon0,p_ones,c0_sd_no_alloc);
P_kc0_sd_no_alloc=Pc_kc0_sd_no_alloc+Pzm1;
Pc_kc0_sd=schurOneMlatticeP(wp,k0_sd,epsilon0,p_ones,c0_sd);
P_kc0_sd=Pc_kc0_sd+Pzm1;
Pc_kc_min=schurOneMlatticeP(wp,k_min,epsilon0,p_ones,c_min);
P_kc_min=Pc_kc_min+Pzm1;

dCsqdw_kc0=schurOneMlatticedAsqdw(wd,k0,epsilon0,p_ones,c0);
dAsqdw_kc0=(Csq_kc0(1:ndp).*dAzm1sqdw(1:ndp))+(dCsqdw_kc0.*Azm1sq(1:ndp));
dCsqdw_kc0_sd_no_alloc=schurOneMlatticedAsqdw ...
                         (wd,k0_sd_no_alloc,epsilon0,p_ones,c0_sd_no_alloc);
dAsqdw_kc0_sd_no_alloc=(Csq_kc0_sd_no_alloc(1:ndp).*dAzm1sqdw(1:ndp))+ ...
                      (dCsqdw_kc0_sd_no_alloc.*Azm1sq(1:ndp));
dCsqdw_kc0_sd=schurOneMlatticedAsqdw(wd,k0_sd,epsilon0,p_ones,c0_sd);
dAsqdw_kc0_sd=(Csq_kc0_sd(1:ndp).*dAzm1sqdw(1:ndp)) + ...
              (dCsqdw_kc0_sd.*Azm1sq(1:ndp));
dCsqdw_kc_min=schurOneMlatticedAsqdw(wd,k_min,epsilon0,p_ones,c_min);
dAsqdw_kc_min=(Csq_kc_min(1:ndp).*dAzm1sqdw(1:ndp)) + ...
              (dCsqdw_kc_min.*Azm1sq(1:ndp));

% Check constraints after the last truncation
printf("These constraints on the correction filter response are not met:\n");
vS=schurOneMlattice_slb_update_constraints ...
     (Asq_kc_min,(Adu./Azm1).^2,(Adl./Azm1).^2,Wa, ...
      T_kc_min,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
      P_kc_min,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
      Cd,Cdu,Cdl,Wd, ...
      ctol);
schurOneMlattice_slb_show_constraints ...
  (vS,wa,Asq_kc_min,wt,T_kc_min,wp,P_kc_min,wd,Dd);

% Check response
[N_min,D_min]=schurOneMlattice2tf(k_min,epsilon0,p_ones,c_min);
print_polynomial(N_min,"N_min");
print_polynomial(N_min,"N_min",strcat(strf,"_N_min_coef.m"));
print_polynomial(D_min,"D_min");
print_polynomial(D_min,"D_min",strcat(strf,"_D_min_coef.m"));
Hchk=freqz(N_min(:),D_min(:),wa);
if max(abs(abs(Hchk)-sqrt(Csq_kc_min))) > 10*eps
  error("max(abs(abs(Hchk)-sqrt(Csq_kc_min)))(%g*eps) > 10*eps", ...
        max(abs(abs(Hchk)-sqrt(Csq_kc_min)))/eps);
endif

%
% Make a LaTeX table for cost
%
A_kc0_sb_max=10*log10(max(Asq_kc0(Ras)));
A_kc0_sd_no_alloc_sb_max=10*log10(max(Asq_kc0_sd_no_alloc(Ras)));
A_kc0_sd_sb_max=10*log10(max(Asq_kc0_sd(Ras)));
A_kc_min_sb_max=10*log10(max(Asq_kc_min(Ras)));

fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %10.4e & %6.2f & & \\\\\n",Esq0,A_kc0_sb_max);
fprintf(fid,"%d-bit %d-signed-digit & %10.4e & %6.2f & %d & %d \\\\\n", ...
        nbits,ndigits, ...
        Esq0_sd_no_alloc,A_kc0_sd_no_alloc_sb_max, ...
        kc0_sd_no_alloc_digits,kc0_sd_no_alloc_adders);
fprintf(fid,"%d-bit %d-signed-digit(%s)& %10.4e & %6.2f & %d & %d \\\\\n", ...
        nbits,ndigits,strItoLim,Esq0_sd,A_kc0_sd_sb_max, ...
        kc0_sd_digits,kc0_sd_adders);
fprintf(fid,["%d-bit %d-signed-digit(POP-relax) & ", ...
             "%10.4e & %6.2f & %d & %d \\\\\n"], ...
        nbits,ndigits,Esq_min,A_kc_min_sb_max, ...
        kc_min_digits,kc_min_adders);
fclose(fid);

% Plot amplitude response error
subplot(311);
rap=1:nap;
ras=nas:length(wa);
[ax,ha,hs] = plotyy...
    (wa(rap)*0.5/pi, ...
     sqrt([Asq_kc0(rap),Asq_kc0_sd_no_alloc(rap), ...
           Asq_kc0_sd(rap),Asq_kc_min(rap)])-Ad(rap), ...
     wa(ras)*0.5/pi, ...
     sqrt([Asq_kc0(ras),Asq_kc0_sd_no_alloc(ras), ...
           Asq_kc0_sd(ras),Asq_kc_min(ras)]));
% Copy line colour
hac=get(ha,"color");
hls={"-",":","--","-."};
for c=1:4
  set(hs(c),"color",hac{c});
  set(ha(c),"linestyle",hls{c});
  set(hs(c),"linestyle",hls{c});
endfor
axis(ax(1),[0 0.5 0.002*[-1,1]]);
axis(ax(2),[0 0.5 0.01*[-1,1]]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude");
strt=sprintf(["Schur one-multiplier lattice lowpass differentiator filter", ...
              " (ndigits=%d,nbits=%d) : fap=%g,fas=%g"],nbits,ndigits,fap,fas);
title(strt);
% Plot phase pass-band response
subplot(312);
plot(wp*0.5/pi,(unwrap(P_kc0)+(wp*tp))/pi,"linestyle","-", ...
     wp*0.5/pi,(unwrap(P_kc0_sd_no_alloc)+(wp*tp))/pi,"linestyle",":", ...
     wp*0.5/pi,(unwrap(P_kc0_sd)+(wp*tp))/pi,"linestyle","--", ...
     wp*0.5/pi,(unwrap(P_kc_min)+(wp*tp))/pi,"linestyle","-.");
grid("on");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 pp+0.001*[-1,1]]);
legend("exact","s-d","s-d(Lim)","s-d(POP-relax)");
legend("location","east");
legend("boxoff");
legend("right");
% Plot group-delay pass-band response
subplot(313);
plot(wt*0.5/pi,T_kc0,"linestyle","-", ...
     wt*0.5/pi,T_kc0_sd_no_alloc,"linestyle",":", ...
     wt*0.5/pi,T_kc0_sd,"linestyle","--", ...
     wt*0.5/pi,T_kc_min,"linestyle","-.");
grid("on");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0 0.5 tp+0.02*[-1,1]]);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot dCsqdw pass-band response error
plot(wd*0.5/pi,dCsqdw_kc0-Cd,"linestyle","-", ...
     wd*0.5/pi,dCsqdw_kc0_sd_no_alloc-Cd,"linestyle",":", ...
     wd*0.5/pi,dCsqdw_kc0_sd-Cd,"linestyle","--", ...
     wd*0.5/pi,dCsqdw_kc_min-Cd,"linestyle","-.");
xlabel("Frequency");
ylabel("dCsqdw error");
axis([0 fdp (cpr/2)*[-1,1]]);
title(strt);
legend("exact","s-d","s-d(Lim)","s-d(POP-relax)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_dCsqdw_error"),"-dpdflatex");
close

% Plot amplitude response
rap=1:nas;
ras=nas:length(wa);
[ax,ha,hs] = plotyy...
    (wa(rap)*0.5/pi, ...
     sqrt([Asq_kc0(rap),Asq_kc0_sd_no_alloc(rap), ...
           Asq_kc0_sd(rap),Asq_kc_min(rap)]), ...
     wa(ras)*0.5/pi, ...
     sqrt([Asq_kc0(ras),Asq_kc0_sd_no_alloc(ras), ...
           Asq_kc0_sd(ras),Asq_kc_min(ras)]));
% Copy line colour
hac=get(ha,"color");
hls={"-",":","--","-."};
for c=1:4
  set(hs(c),"color",hac{c});
  set(ha(c),"linestyle",hls{c});
  set(hs(c),"linestyle",hls{c});
endfor
axis(ax(1),[0 0.5 0 0.8]);
axis(ax(2),[0 0.5 0 0.008]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude");
legend("Exact","s-d",sprintf("s-d(%s)",strItoLim),"s-d(POP-relax)");
legend("location","northwest");
legend("boxoff");
legend("left");
strt=sprintf(["Schur one-multiplier lattice lowpass differentiator filter", ...
              " (ndigits=%d,nbits=%d) : fap=%g,fas=%g"],nbits,ndigits,fap,fas);
title(strt);
print(strcat(strf,"_amplitude"),"-dpdflatex");
close

% Plot stop band amplitude response
plot(wa*0.5/pi,sqrt(Asq_kc0),"linestyle","-", ...
     wa*0.5/pi,sqrt(Asq_kc0_sd_no_alloc),"linestyle",":", ...
     wa*0.5/pi,sqrt(Asq_kc0_sd),"linestyle","--", ...
     wa*0.5/pi,sqrt(Asq_kc_min),"linestyle","-.", ...
     wa*0.5/pi,Adu,"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude");
axis([fas 0.5 0 0.008]);
strt=sprintf(["Low-pass differentiator R=2 filter : ", ...
              "nbits=%d,ndigits=%d,fas=%g"],nbits,ndigits,fas);
title(strt);
legend("Exact","s-d",sprintf("s-d(%s)",strItoLim),"s-d(POP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_stop_amplitude"),"-dpdflatex");
close

% Plot pass band amplitude response error
plot(wa*0.5/pi,sqrt(Asq_kc0)-Ad,"linestyle","-", ...
     wa*0.5/pi,sqrt(Asq_kc0_sd_no_alloc)-Ad,"linestyle",":", ...
     wa*0.5/pi,sqrt(Asq_kc0_sd)-Ad,"linestyle","--", ...
     wa*0.5/pi,sqrt(Asq_kc_min)-Ad,"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude error");
axis([0 max([fap fpp ftp]) 0.001*[-1,1]]);
strt=sprintf(["Low-pass differentiator R=2 filter : ", ...
              "nbits=%d,ndigits=%d,fap=%g"],nbits,ndigits,fap);
title(strt);
legend("Exact","s-d",sprintf("s-d(%s)",strItoLim),"s-d(POP-relax)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_pass_amplitude_error"),"-dpdflatex");
close

% Plot phase response
plot(wp*0.5/pi,((P_kc0+(wp*tp))/pi),"linestyle","-", ...
     wp*0.5/pi,((P_kc0_sd_no_alloc+(wp*tp))/pi),"linestyle",":", ...
     wp*0.5/pi,((P_kc0_sd+(wp*tp))/pi),"linestyle","--", ...
     wp*0.5/pi,((P_kc_min+(wp*tp))/pi),"linestyle","-.");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$)");
axis([0 max([fap fpp ftp]) pp+(0.001)*[-1,1]]);
strt=sprintf(["Low-pass differentiator R=2 filter : ", ...
              "nbits=%d,ndigits=%d,fpp=%g"],nbits,ndigits,fpp);
title(strt);
legend("Exact","s-d",sprintf("s-d(%s)",strItoLim),"s-d(POP-relax)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_pass_phase"),"-dpdflatex");
close

% Plot delay response
plot(wt*0.5/pi,T_kc0,"linestyle","-", ...
     wt*0.5/pi,T_kc0_sd_no_alloc,"linestyle",":", ...
     wt*0.5/pi,T_kc0_sd,"linestyle","--", ...
     wt*0.5/pi,T_kc_min,"linestyle","-.");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0 max([fap fpp ftp]),(tp+(0.02*[-1,1]))]);
strt=sprintf(["Low-pass differentiator R=2 filter : ", ...
              "nbits=%d,ndigits=%d,ftp=%g"],nbits,ndigits,ftp);
title(strt);
legend("Exact","s-d",sprintf("s-d(%s)",strItoLim),"s-d(POP-relax)"); 
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_pass_delay"),"-dpdflatex");
close

% Plot stop band correction filter amplitude response
plot(wa*0.5/pi,sqrt(Csq_kc0)-(Ad./Azm1),"linestyle","-", ...
     wa*0.5/pi,sqrt(Csq_kc0_sd_no_alloc)-(Ad./Azm1),"linestyle",":", ...
     wa*0.5/pi,sqrt(Csq_kc0_sd)-(Ad./Azm1),"linestyle","--", ...
     wa*0.5/pi,sqrt(Csq_kc_min)-(Ad./Azm1),"linestyle","-.", ...
     wa*0.5/pi,(Adu-Ad)./Azm1,"linestyle","-", ...
     wa*0.5/pi,(Adl-Ad)./Azm1,"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude error");
axis([fas 0.5 0 0.006]);
strt=sprintf(["Low-pass differentiator R=2 correction filter : ", ...
              " nbits=%d,ndigits=%d,fas=%g"],nbits,ndigits,fas);
title(strt);
legend("Exact","s-d",sprintf("s-d(%s)",strItoLim),"s-d(POP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_stop_correction_error"),"-dpdflatex");
close

% Plot pass band correction filter amplitude response error
plot(wa*0.5/pi,sqrt(Csq_kc0)-(Ad./Azm1),"linestyle","-", ...
     wa*0.5/pi,sqrt(Csq_kc0_sd_no_alloc)-(Ad./Azm1),"linestyle",":", ...
     wa*0.5/pi,sqrt(Csq_kc0_sd)-(Ad./Azm1),"linestyle","--", ...
     wa*0.5/pi,sqrt(Csq_kc_min)-(Ad./Azm1),"linestyle","-.", ...
     wa*0.5/pi,(Adu-Ad)./Azm1,"linestyle","-", ...
     wa*0.5/pi,(Adl-Ad)./Azm1,"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude error");
axis([0 fap 0.01*[-1,1]]);
strt=sprintf(["Low-pass differentiator R=2 correction filter : ", ...
              " nbits=%d,ndigits=%d,fap=%g"],nbits,ndigits,fap);
title(strt);
legend("Exact","s-d",sprintf("s-d(%s)",strItoLim),"s-d(POP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_pass_correction_error"),"-dpdflatex");
close

% Plot correction filter amplitude response
C_kc = sqrt([Csq_kc0,Csq_kc0_sd_no_alloc,Csq_kc0_sd,Csq_kc_min, ...
             Asqdu./Azm1sq,Asqdl./Azm1sq]);
[ax,ha,hs]=plotyy(wa(Rap)*0.5/pi, C_kc(Rap,:)-(Ad(Rap)./Azm1(Rap)), ...
                  wa(Ras)*0.5/pi, C_kc(Ras,:));
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
ylabel("Amplitude");
strt=sprintf(["Low-pass differentiator R=2 correction filter : ", ...
              " nbits=%d,ndigits=%d,fas=%g"],nbits,ndigits,fas);
title(strt);
legend("Exact","s-d",sprintf("s-d(%s)",strItoLim),"s-d(POP-relax)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_correction_amplitude"),"-dpdflatex");
close

% Plot correction filter dCsqdw error response
plot(wd*0.5/pi,dCsqdw_kc0-Cd,"linestyle","-", ...
     wd*0.5/pi,dCsqdw_kc0_sd_no_alloc-Cd,"linestyle",":", ...
     wd*0.5/pi,dCsqdw_kc0_sd-Cd,"linestyle","--", ...
     wd*0.5/pi,dCsqdw_kc_min-Cd,"linestyle","-.");
xlabel("Frequency");
ylabel("dCsqdw error");
axis([0 fdp 0.02*[-1,1]]);
strt=sprintf(["Low-pass differentiator R=2 correction filter : ", ...
              " nbits=%d,ndigits=%d,fdp=%g"],nbits,ndigits,fdp);
title(strt);
legend("Exact","s-d",sprintf("s-d(%s)",strItoLim),"s-d(POP-relax)");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_correction_dCsqdw_error"),"-dpdflatex");
close

% Pole-zero plot
zplane(qroots(conv(N_min(:),[1;-1])),qroots(D_min(:)));
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Calculate response
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
fprintf(fid,"fdp=%g %% Correction filter pass band dCsqdw upper edge\n",fdp);
fprintf(fid, ...
        "cpr=%g %% Correction filter pass band dCsqdw peak-to-peak ripple\n", ...
        cpr);
fprintf(fid,"Wdp=%g %% Correction filter pass band dCsqdw weight\n",Wdp);
fclose(fid);

% Save results
eval(sprintf(["save %s.mat ftol ctol nbits nscale ndigits ndigits_alloc n ", ...
 "use_kc0_coefficient_bounds ", ...
 "use_schurOneMlattice_allocsd_Lim ", ...
 "use_schurOneMlattice_allocsd_Ito ", ...
 "use_fix_coefficient_difference_greater_than_alpha ", ...
 "alpha_num alpha_min rho ", ...
 "fap fas Arp Ars Wap Wat Was ftp tp tpr Wtp fpp pp ppr Wpp fdp cpr Wdp ", ...
 "k0 epsilon0 p0 c0 k0_sd c0_sd k0_sd c0_sd k_min c_min ", ...
 "N_min D_min"],strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
