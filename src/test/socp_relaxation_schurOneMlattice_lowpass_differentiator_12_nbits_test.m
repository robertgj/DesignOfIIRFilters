% socp_relaxation_schurOneMlattice_lowpass_differentiator_12_nbits_test.m
%
% Use SOCP relaxation to find the 12 bit 3 signed-digit coefficients of a
% low-pass differentiator filter implemented as the series combination of
% (1-z^{-1}) with a Schur one-multiplier lattice correction filter.
%
% Copyright (C) 2022-2024 Robert G. Jenssen

test_common;

strf="socp_relaxation_schurOneMlattice_lowpass_differentiator_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false
maxiter=2000
ftol=1e-4
ctol=ftol/10
nbits=12
nscale=2^(nbits-1);
ndigits=3

%
% Initial correction filter
%
iir_sqp_slb_lowpass_differentiator_test_N1_coef;N0=N1;
iir_sqp_slb_lowpass_differentiator_test_D1_coef;D0=D1;

%
% Convert initial correction filter to Schur one-multiplier lattice form
%
[k0,epsilon0,~,c0,S0]=tf2schurOneMlattice(N0,D0);
p0_ones=ones(size(k0));

%
% Lowpass differentiator filter specification
%
fap=0.18;fas=0.25;
Arp=0.01;Art=0.02;Ars=0.02;Wap=2;Wat=0.0001;Was=1;
td=length(N0)-2;tdr=0.2;Wtp=1;
pr=0.002;Wpp=1;

% Options
socp_relaxation_schurOneMlattice_lowpass_differentiator_allocsd_Lim=true
socp_relaxation_schurOneMlattice_lowpass_differentiator_allocsd_Ito=false

%
% Frequency vectors for the Schur one-mulitplier lattice correction filter
%

n=400;
w=(1:(n-1))'*pi/n;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);

% Amplitude
wa=w;
Azm1=2*sin(wa/2);
Ad=([(wa(1:nap)/2);zeros(n-nap-1,1)]);
Adu=[(wa(1:(nas-1))/2);zeros(n-nas,1)] + ...
    [(Arp/2)*ones(nap,1);(Art/2)*ones(nas-nap-1,1);(Ars/2)*ones(n-nas,1)];
Adl=Ad-[(Arp/2)*ones(nap,1);(Art/2)*ones(nas-nap-1,1);(Ars/2)*ones(n-nas,1)];
Adl(find(Adl<0))=0;
Wa=[Wap*ones(nap,1); ...
    Wat*ones(nas-nap-1,1); ...
    Was*ones(n-nas,1)];

nchk=[1,2,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nchk=[");printf("%d ",nchk);printf(" ]\n");
printf("wa(nchk)*0.5/pi=[");printf("%g ",wa(nchk)*0.5/pi);printf(" ]\n");
printf("Ad(nchk)=[");printf("%g ",Ad(nchk));printf(" ]\n");
printf("Adu(nchk)=[");printf("%g ",Adu(nchk));printf(" ]\n");
printf("Adl(nchk)=[");printf("%g ",Adl(nchk));printf(" ]\n");
printf("Wa(nchk)=[");printf("%g ",Wa(nchk));printf(" ]\n");

% Phase response 
wp=w(1:nap);
Pzm1=(pi/2)-(wp/2);
Pd=(pi/2)-(wp*td);
Pdu=Pd+(pr*pi/2);
Pdl=Pd-(pr*pi/2);
Wp=Wpp*ones(size(wp));

% Group delay
wt=w(1:nap);
Tzm1=0.5;
Td=td*ones(size(wt));
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wt=Wtp*ones(size(wt));

% dAsqdw constraints
wd=[];
Dzm1=[];
Dd=[];
Ddu=[];
Ddl=[];
Wd=[];

% Initial response
Asq0=schurOneMlatticeAsq(wa,k0,epsilon0,p0_ones,c0);
A0=sqrt(Asq0).*Azm1;
P0=schurOneMlatticeP(wp,k0,epsilon0,p0_ones,c0)+Pzm1;
T0=schurOneMlatticeT(wt,k0,epsilon0,p0_ones,c0)+Tzm1;

% Constraints on the coefficients
dmax=inf;
rho=1-ftol;
k0=k0(:);
c0=c0(:);
kc0=[k0;c0];
Nk=length(k0);
Nc=length(c0);
kc0_u=[rho*ones(size(k0));10*ones(size(c0))];
kc0_l=-kc0_u;
kc0_active=[find((k0)~=0);(Nk+(1:Nc))'];

% Allocate signed-digits to the coefficients
if socp_relaxation_schurOneMlattice_lowpass_differentiator_allocsd_Lim
  ndigits_alloc = ...
    schurOneMlattice_allocsd_Lim(nbits,ndigits,k0,epsilon0,p0_ones,c0, ...
                                 wa,(Ad./Azm1).^2,ones(size(wa)), ...
                                 wt,Td-Tzm1,ones(size(wt)), ...
                                 wp,Pd-Pzm1,ones(size(wp)));
elseif socp_relaxation_schurOneMlattice_lowpass_differentiator_allocsd_Ito
  ndigits_alloc = ...
         schurOneMlattice_allocsd_Ito(nbits,ndigits,k0,epsilon0,p0_ones,c0, ...
                                      wa,(Ad./Azm1).^2,Wa, ...
                                      wt,Td-Tzm1,Wt, ...
                                      wp,Pd-Pzm1,Wp);
else
  ndigits_alloc=zeros(size(kc0));
  ndigits_alloc(kc0_active)=ndigits;
endif
k_allocsd_digits=int16(ndigits_alloc(1:Nk));
c_allocsd_digits=int16(ndigits_alloc((Nk+1):end));
print_polynomial(k_allocsd_digits,"k_allocsd_digits","%1d");
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%1d");
print_polynomial(c_allocsd_digits,"c_allocsd_digits","%1d");
print_polynomial(c_allocsd_digits,"c_allocsd_digits", ...
                 strcat(strf,"_c_allocsd_digits.m"),"%1d");
% Find the signed-digit approximations to k0 and c0
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

% Find kc0 error
Esq0=schurOneMlatticeEsq(k0,epsilon0,p0_ones,c0, ...
                         wa,(Ad./Azm1).^2,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp);

% Find kc0_sd error
Esq0_sd=schurOneMlatticeEsq(k0_sd,epsilon0,p0_ones,c0_sd, ...
                            wa,(Ad./Azm1).^2,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp);

% Find the number of signed-digits and adders used by kc0_sd
[kc0_digits,kc0_adders]=SDadders(kc0_sd(kc0_active),nbits);

% Initialise the vector of filter coefficients to be optimised
kc=zeros(size(kc0));
kc(kc0_active)=kc0(kc0_active);
kc_l=kc0_l;
kc_u=kc0_u;
kc_active=kc0_active;

% Fix one coefficient at each iteration 
while ~isempty(kc_active)
  
  % Define filter coefficients 
  [kc_sd,kc_sdu,kc_sdl]=flt2SD(kc,nbits,ndigits_alloc);
  kc_sdul=kc_sdu-kc_sdl;
  kc_b=kc;
  kc_bl=kc_l;
  kc_bu=kc_u;
  
  % Ito et al. suggest ordering the search by max(kc_sdu-kc_sdl)
  [kc_max,kc_max_n]=max(kc_sdul(kc_active));
  coef_n=kc_active(kc_max_n);
  kc_bl(coef_n)=kc_sdl(coef_n);
  kc_bu(coef_n)=kc_sdu(coef_n);

  % Try to solve the current SOCP problem with bounds kc_bu and kc_bl
  try
    % Find the SOCP PCLS solution for the remaining active coefficents
    [nextk,nextc,slb_iter,opt_iter,func_iter,feasible] = ...
      schurOneMlattice_slb(@schurOneMlattice_socp_mmse, ...
                           kc_b(1:Nk),epsilon0,p0_ones,kc_b((Nk+1):end), ...
                           kc_bu,kc_bl,kc_active,dmax, ...
                           wa,(Ad./Azm1).^2,(Adu./Azm1).^2,(Adl./Azm1).^2,Wa, ...
                           wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
                           wp,Pd-Pzm1,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
                           wd,(Dd./Dzm1),(Ddu./Dzm1),(Ddl./Dzm1),Wd, ...
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
    error("SOCP problem infeasible!");
    break;
  endif
  
  % Fix coef_n
  nextkc=[nextk(:);nextc(:)];
  alpha=(nextkc(coef_n)-((kc_sdu(coef_n)+kc_sdl(coef_n))/2))/(kc_sdul(coef_n)/2);
  if alpha>=0
    nextkc(coef_n)=kc_sdu(coef_n);
  else
    nextkc(coef_n)=kc_sdl(coef_n);
  endif
  kc=nextkc;
  kc_active(kc_max_n)=[];
  printf("Fixed kc(%d)=%13.10f\n",coef_n,kc(coef_n));
  printf("kc_active=[ ");printf("%d ",kc_active);printf("];\n\n");

endwhile

% Show results
kc_min=kc;
k_min=kc(1:Nk);
c_min=kc((Nk+1):end);
Esq_min=schurOneMlatticeEsq(k_min,epsilon0,p0_ones,c_min, ...
                            wa,(Ad./Azm1).^2,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
print_polynomial(c_min,"c_min",nscale);
print_polynomial(c_min,"c_min",strcat(strf,"_c_min_coef.m"),nscale);
% Find the number of signed-digits and adders used by kc_sd
[kc_digits,kc_adders]=SDadders(kc_sd(kc0_active),nbits);
printf("%d signed-digits used\n",kc_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kc_adders,nbits);

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_kc_min_cost.tab"),"wt");
fprintf(fid,"Exact & %9.7f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(Lim)& %9.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,kc0_digits,kc0_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %9.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,kc_digits,kc_adders);
fclose(fid);

% Calculate response
Asq_kc0=schurOneMlatticeAsq(wa,k0,epsilon0,p0_ones,c0);
Asq_kc0_sd=schurOneMlatticeAsq(wa,k0_sd,epsilon0,p0_ones,c0_sd);
Asq_kc_min=schurOneMlatticeAsq(wa,k_min,epsilon0,p0_ones,c_min);
P_kc0=schurOneMlatticeP(wp,k0,epsilon0,p0_ones,c0);
P_kc0_sd=schurOneMlatticeP(wp,k0_sd,epsilon0,p0_ones,c0_sd);
P_kc_min=schurOneMlatticeP(wp,k_min,epsilon0,p0_ones,c_min);
T_kc0=schurOneMlatticeT(wt,k0,epsilon0,p0_ones,c0);
T_kc0_sd=schurOneMlatticeT(wt,k0_sd,epsilon0,p0_ones,c0_sd);
T_kc_min=schurOneMlatticeT(wt,k_min,epsilon0,p0_ones,c_min);
dAsqdw_kc0=schurOneMlatticedAsqdw(wd,k0,epsilon0,p0_ones,c0);
dAsqdw_kc0_sd=schurOneMlatticedAsqdw(wd,k0_sd,epsilon0,p0_ones,c0_sd);
dAsqdw_kc_min=schurOneMlatticedAsqdw(wd,k_min,epsilon0,p0_ones,c_min);

% Check constraints after the last truncation
printf("These constraints on the correction filter response are not met:\n");
vS=schurOneMlattice_slb_update_constraints ...
     (Asq_kc_min,(Adu./Azm1).^2,(Adl./Azm1).^2,Wa, ...
      T_kc_min,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
      P_kc_min,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
      dAsqdw_kc_min,Ddu./Dzm1,Ddl./Dzm1,Wd, ...
      ctol);
schurOneMlattice_slb_show_constraints ...
  (vS,wa,Asq_kc_min,wt,T_kc_min,wp,P_kc_min,wd,dAsqdw_kc_min);

% Plot response error
subplot(311);
plot(wa*0.5/pi,(Azm1.*sqrt(Asq_kc0))-Ad,"linestyle","-", ...
     wa*0.5/pi,(Azm1.*sqrt(Asq_kc0_sd)-Ad),"linestyle","--", ...
     wa*0.5/pi,(Azm1.*sqrt(Asq_kc_min))-Ad,"linestyle","-.");
ylabel("Amplitude error");
strt=sprintf("Low-pass differentiator filter : \
fap=%g,fas=%g,Arp=%g,Ars=%g,td=%g,pr=%g",fap,fas,Arp,Ars,td,pr);
title(strt);
axis([0  0.5 max(Arp,Ars)*[-1,1]]);
grid("on");
subplot(312);
plot(wp*0.5/pi,(P_kc0+Pzm1-Pd)/pi,"linestyle","-", ...
     wp*0.5/pi,(P_kc0_sd+Pzm1-Pd)/pi,"linestyle","--", ...
     wp*0.5/pi,(P_kc_min+Pzm1-Pd)/pi,"linestyle","-.");
axis([0 0.5 pr*[-1,1]]);
grid("on");
ylabel("Phase error(rad./$\\pi$)");
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","east");
legend("boxoff");
legend("left");
subplot(313);
plot(wt*0.5/pi,T_kc0+Tzm1-Td,"linestyle","-", ...
     wt*0.5/pi,T_kc0_sd+Tzm1-Td,"linestyle","--", ...
     wt*0.5/pi,T_kc_min+Tzm1-Td,"linestyle","-.");
axis([0 0.5 tdr/2*[-1,1]]);
grid("on");
ylabel("Group delay error(samples)");
xlabel("Frequency");
print(strcat(strf,"_kc_min"),"-dpdflatex");
close

% Plot poles and zeros
[N_min,D_min]=schurOneMlattice2tf(k_min,epsilon0,p0_ones,c_min);
subplot(111);
zplane(qroots(conv([1;-1],N_min(:))),qroots(D_min(:)));
title(strt);
print(strcat(strf,"_kc_min_pz"),"-dpdflatex");
close

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%d %% Bits-per-coefficient \n",nbits);
fprintf(fid,"ndigits=%d %% Average signed-digits-per-coefficient \n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"Arp=%g %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fas=%g %% Amplitude stop band lower edge\n",fas);
fprintf(fid,"Ars=%g %% Amplitude stop band peak-to-peak ripple\n",Ars);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"td=%g %% Pass band group delay\n",td);
fprintf(fid,"tdr=%g %% Pass band group delay peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"pr=%g %% Phase pass band peak-to-peak ripple(rad./pi))\n",pr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

eval(sprintf("save %s.mat \
socp_relaxation_schurOneMlattice_lowpass_differentiator_allocsd_Lim \
socp_relaxation_schurOneMlattice_lowpass_differentiator_allocsd_Ito \
nbits ndigits ndigits_alloc k_allocsd_digits c_allocsd_digits \
ftol ctol n fap Arp Wap Ars Was td tdr Wtp pr Wpp \
k0 epsilon0 c0 k0_sd c0_sd k_min c_min",strf));

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
