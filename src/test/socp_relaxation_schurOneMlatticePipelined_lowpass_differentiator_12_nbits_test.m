% socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_12_nbits_test.m
%
% Use SOCP relaxation to find the 12 bit 3 signed-digit coefficients of a
% low-pass differentiator filter implemented as the series combination of
% (1-z^{-1}) with a pipelined Schur one-multiplier lattice correction filter.
%
% Copyright (C) 2024 Robert G. Jenssen

test_common;

strf="socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false
maxiter=2000
ftol=1e-3
ctol=ftol/1000
nbits=12
nscale=2^(nbits-1);
ndigits=3 % flt2SD expects ndigits*2 <= nbits

%
% Initial correction filter
%
schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test_epsilon0_coef;
schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test_k2_coef;
schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test_c2_coef;
schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test_kk2_coef;
schurOneMlatticePipelined_socp_slb_lowpass_differentiator_test_ck2_coef;
epsilon0=epsilon0(:);k0=k2(:);c0=c2(:);kk0=kk2(:);ck0=ck2(:);

%
% Lowpass differentiator filter specification
%
fap=0.18;fas=0.3;
Arp=0.01;Art=0.02;Ars=0.01;Wap=1;Wat=0.0001;Was=1;
fpp=fap;pp=1.5;ppr=0.004;Wpp=1;
ftp=fap;td=length(k0)-1;tdr=0.08;Wtp=1;

% Options
socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_allocsd_Lim=false
socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_allocsd_Ito=true

%
% Frequency vectors for the Schur one-mulitplier lattice correction filter
%

n=400;
w=(1:(n-1))'*pi/n;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);
npp=ceil(fpp*n/0.5);
ntp=ceil(ftp*n/0.5);

% Amplitude
wa=w;
Ad=([(wa(1:nap)/2);zeros(n-nap-1,1)]);
Adu=[(wa(1:(nas-1))/2);zeros(n-nas,1)] + ...
    [(Arp/2)*ones(nap,1);(Art/2)*ones(nas-nap-1,1);Ars*ones(n-nas,1)];
Adl=Ad-[(Arp/2)*ones(nap,1);(Art/2)*ones(nas-nap-1,1);Ars*ones(n-nas,1)];
Adl(find(Adl<0))=0;
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas,1)];
% Amplitude response of (1-z^-1)
Azm1=2*sin(wa/2);

% Phase response 
wp=w(1:npp);
Pd=(pp*pi)-(wp*td);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));
% Phase response of (1-z^-1)
Pzm1=(pi/2)-(wp/2);

% Group delay
wt=w(1:ntp);
Td=td*ones(size(wt));
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wt=Wtp*ones(size(wt));
% Group delay response of (1-z^-1)
Tzm1=0.5;

% dAsqdw constraints
wd=[];
dAsqdwd=[];
dAsqdwdu=[];
dAsqdwdl=[];
Wd=[];
% dAsqdw response of (1-z^-1)
dAsqdwzm1=[];

% Constraints on the coefficients
dmax=inf;
rho=1-ftol;
Nk=length(k0);
Rk=1:Nk;
Nc=length(c0);
Rc=(Nk+1):(Nk+Nc);
Nkk=length(kk0);
Rkk=(Nk+Nc+1):(Nk+Nc+Nkk);
Nck=length(ck0);
Rck=(Nk+Nc+Nkk+1):(Nk+Nc+Nkk+Nck);
kc0=[k0;c0;kk0;ck0];
Nx=Nk+Nc+Nkk+Nck;
kc0_u=[rho*ones(size(k0));10*ones(size(c0));rho*ones(size(kk0));10*ones(size(ck0))];
kc0_l=-kc0_u;
Nx=Nk+Nc+Nkk+Nck;
kc0_active=(1:Nx)';

% Initial response
Asq0=schurOneMlatticePipelinedAsq(wa,k0,epsilon0,c0,kk0,ck0);
A0=sqrt(Asq0).*Azm1;
P0=schurOneMlatticePipelinedP(wp,k0,epsilon0,c0,kk0,ck0)+Pzm1;
T0=schurOneMlatticePipelinedT(wt,k0,epsilon0,c0,kk0,ck0)+Tzm1;
dAsqdw0=schurOneMlatticePipelineddAsqdw(wd,k0,epsilon0,c0,kk0,ck0);

% Sanity check
nchk=[1,2,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nchk=[");printf("%d ",nchk);printf(" ]\n");
printf("wa(nchk)*0.5/pi=[");printf("%g ",wa(nchk)*0.5/pi);printf(" ]\n");
printf("Ad(nchk)=[");printf("%g ",Ad(nchk));printf(" ]\n");
printf("Adu(nchk)=[");printf("%g ",Adu(nchk));printf(" ]\n");
printf("Adl(nchk)=[");printf("%g ",Adl(nchk));printf(" ]\n");
printf("Wa(nchk)=[");printf("%g ",Wa(nchk));printf(" ]\n");

% Allocate signed-digits to the coefficients
if socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_allocsd_Lim
  ndigits_alloc = schurOneMlatticePipelined_allocsd_Lim  ...
                    (nbits,ndigits,k0,epsilon0,p0_ones,c0, ...
                     wa,(Ad./Azm1).^2,ones(size(wa)), ...
                     wt,Td-Tzm1,ones(size(wt)), ...
                     wp,Pd-Pzm1,ones(size(wp)), ...
                     wd,dAsqdwd,ones(size(wd)));
elseif ...
  socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_allocsd_Ito 
  ndigits_alloc = schurOneMlatticePipelined_allocsd_Ito ...
                    (nbits,ndigits,k0,epsilon0,c0,kk0,ck0, ...
                     wa,(Ad./Azm1).^2,Wa, ...
                     wt,Td-Tzm1,Wt, ...
                     wp,Pd-Pzm1,Wp, ...
                     wd,dAsqdwd,Wd);
else
  ndigits_alloc=zeros(size(kc0));
  ndigits_alloc(kc0_active)=ndigits;
endif
k_allocsd_digits=int16(ndigits_alloc(Rk));
c_allocsd_digits=int16(ndigits_alloc(Rc));
kk_allocsd_digits=int16(ndigits_alloc(Rkk));
ck_allocsd_digits=int16(ndigits_alloc(Rck));
print_polynomial(k_allocsd_digits,"k_allocsd_digits","%1d");
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%1d");
print_polynomial(c_allocsd_digits,"c_allocsd_digits","%1d");
print_polynomial(c_allocsd_digits,"c_allocsd_digits", ...
                 strcat(strf,"_c_allocsd_digits.m"),"%1d");
print_polynomial(kk_allocsd_digits,"kk_allocsd_digits","%1d");
print_polynomial(kk_allocsd_digits,"kk_allocsd_digits", ...
                 strcat(strf,"_kk_allocsd_digits.m"),"%1d");
print_polynomial(ck_allocsd_digits,"ck_allocsd_digits","%1d");
print_polynomial(ck_allocsd_digits,"ck_allocsd_digits", ...
                 strcat(strf,"_ck_allocsd_digits.m"),"%1d");
% Find the signed-digit approximations to k0 and c0
[kc0_sd,kc0_sdu,kc0_sdl]=flt2SD(kc0,nbits,ndigits_alloc);
k0_sd=kc0_sd(Rk)(:);
c0_sd=kc0_sd(Rc)(:);
kk0_sd=kc0_sd(Rkk)(:);
ck0_sd=kc0_sd(Rck)(:);
print_polynomial(k0_sd,"k0_sd",nscale);
print_polynomial(k0_sd,"k0_sd",strcat(strf,"_k0_sd_coef.m"),nscale);
print_polynomial(c0_sd,"c0_sd",nscale);
print_polynomial(c0_sd,"c0_sd",strcat(strf,"_c0_sd_coef.m"),nscale);
print_polynomial(kk0_sd,"kk0_sd",nscale);
print_polynomial(kk0_sd,"kk0_sd",strcat(strf,"_kk0_sd_coef.m"),nscale);
print_polynomial(ck0_sd,"ck0_sd",nscale);
print_polynomial(ck0_sd,"ck0_sd",strcat(strf,"_ck0_sd_coef.m"),nscale);

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
Esq0=schurOneMlatticePipelinedEsq(k0,epsilon0,c0,kk0,ck0, ...
                                  wa,(Ad./Azm1).^2,Wa, ...
                                  wt,Td-Tzm1,Wt, ...
                                  wp,Pd-Pzm1,Wp, ...
                                  wd,dAsqdwd,Wd);
printf("Exact coefficients Esq0=%g\n",Esq0);

% Find kc0_sd error
Esq0_sd=schurOneMlatticePipelinedEsq(k0_sd,epsilon0,c0_sd,kk0_sd,ck0_sd, ...
                                     wa,(Ad./Azm1).^2,Wa, ...
                                     wt,Td-Tzm1,Wt, ...
                                     wp,Pd-Pzm1,Wp, ...
                                     wd,dAsqdwd,Wd);
printf("Signed-digit coefficients Esq0_sd=%g\n",Esq0);

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
    [nextk,nextc,nextkk,nextck,slb_iter,opt_iter,func_iter,feasible] = ...
      schurOneMlatticePipelined_slb(@schurOneMlatticePipelined_socp_mmse, ...
                           kc_b(Rk),epsilon0,kc_b(Rc),kc_b(Rkk),kc_b(Rck), ...
                           kc_bu,kc_bl,kc_active,dmax, ...
                           wa,(Ad./Azm1).^2,(Adu./Azm1).^2,(Adl./Azm1).^2,Wa, ...
                           wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
                           wp,Pd-Pzm1,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
                           wd,dAsqdwd,dAsqdwdu,dAsqdwdl,Wd, ...
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
  nextkc=[nextk(:);nextc(:);nextkk(:);nextck(:)];
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
k_min=kc(Rk);
c_min=kc(Rc);
kk_min=kc(Rkk);
ck_min=kc(Rck);
Esq_min=schurOneMlatticePipelinedEsq ...
          (k_min,epsilon0,c_min,kk_min,ck_min, ...
           wa,(Ad./Azm1).^2,Wa,wt,Td-Tzm1,Wt,wp,Pd-Pzm1,Wp,wd,dAsqdwd,Wd);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
print_polynomial(c_min,"c_min",nscale);
print_polynomial(c_min,"c_min",strcat(strf,"_c_min_coef.m"),nscale);
print_polynomial(kk_min,"kk_min",nscale);
print_polynomial(kk_min,"kk_min",strcat(strf,"_kk_min_coef.m"),nscale);
print_polynomial(ck_min,"ck_min",nscale);
print_polynomial(ck_min,"ck_min",strcat(strf,"_ck_min_coef.m"),nscale);
% Find the number of signed-digits and adders used by kc_sd
[kc_digits,kc_adders]=SDadders(kc_sd(kc0_active),nbits);
printf("%d signed-digits used\n",kc_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kc_adders,nbits);

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_kc_min_cost.tab"),"wt");
fprintf(fid,"Exact & %9.7f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(Ito)& %9.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,kc0_digits,kc0_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %9.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,kc_digits,kc_adders);
fclose(fid);

% Calculate response
Asq_kc0=schurOneMlatticePipelinedAsq(wa,k0,epsilon0,c0,kk0,ck0);
Asq_kc0_sd=schurOneMlatticePipelinedAsq(wa,k0_sd,epsilon0,c0_sd,kk0_sd,ck0_sd);
Asq_kc_min=schurOneMlatticePipelinedAsq(wa,k_min,epsilon0,c_min,kk_min,ck_min);
P_kc0=schurOneMlatticePipelinedP(wp,k0,epsilon0,c0,kk0,ck0);
P_kc0_sd=schurOneMlatticePipelinedP(wp,k0_sd,epsilon0,c0_sd,kk0_sd,ck0_sd);
P_kc_min=schurOneMlatticePipelinedP(wp,k_min,epsilon0,c_min,kk_min,ck_min);
T_kc0=schurOneMlatticePipelinedT(wt,k0,epsilon0,c0,kk0,ck0);
T_kc0_sd=schurOneMlatticePipelinedT(wt,k0_sd,epsilon0,c0_sd,kk0_sd,ck0_sd);
T_kc_min=schurOneMlatticePipelinedT(wt,k_min,epsilon0,c_min,kk_min,ck_min);
dAsqdw_kc0=schurOneMlatticePipelineddAsqdw(wd,k0,epsilon0,c0,kk0,ck0);
dAsqdw_kc0_sd=schurOneMlatticePipelineddAsqdw ...
                (wd,k0_sd,epsilon0,c0_sd,kk0_sd,ck0_sd);
dAsqdw_kc_min=schurOneMlatticePipelineddAsqdw ...
                (wd,k_min,epsilon0,c_min,kk_min,ck_min);

% Check constraints after the last truncation
printf("These constraints on the correction filter response are not met:\n");
vS=schurOneMlatticePipelined_slb_update_constraints ...
     (Asq_kc_min,(Adu./Azm1).^2,(Adl./Azm1).^2,Wa, ...
      T_kc_min,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
      P_kc_min,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
      dAsqdw_kc_min,dAsqdwdu./dAsqdwzm1,dAsqdwdl./dAsqdwzm1,Wd, ...
      ctol);
schurOneMlatticePipelined_slb_show_constraints ...
  (vS,wa,Asq_kc_min,wt,T_kc_min,wp,P_kc_min,wd,dAsqdw_kc_min);

% Plot response error
subplot(311);
plot(wa*0.5/pi,(Azm1.*sqrt(Asq_kc0))-Ad,"linestyle","-", ...
     wa*0.5/pi,(Azm1.*sqrt(Asq_kc0_sd)-Ad),"linestyle","--", ...
     wa*0.5/pi,(Azm1.*sqrt(Asq_kc_min))-Ad,"linestyle","-.");
ylabel("Amplitude error");
strt=sprintf("Pipelined low-pass differentiator : \
fap=%g,fas=%g,Arp=%g,Ars=%g,td=%g,ppr=%g",fap,fas,Arp,Ars,td,ppr);
title(strt);
axis([0 0.5 max(Arp,Ars)*[-1,1]]);
grid("on");
subplot(312);
plot(wp*0.5/pi,(P_kc0+Pzm1-Pd)/pi,"linestyle","-", ...
     wp*0.5/pi,(P_kc0_sd+Pzm1-Pd)/pi,"linestyle","--", ...
     wp*0.5/pi,(P_kc_min+Pzm1-Pd)/pi,"linestyle","-.");
axis([0 0.5 ppr*[-1,1]]);
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
[A_min,B_min,C_min,dd_min]= ...
  schurOneMlatticePipelined2Abcd(k_min,epsilon0,c_min,kk_min,ck_min);
[N_min,D_min]=Abcd2tf(A_min,B_min,C_min,dd_min);
D_min=D_min(1:(Nk+1));
print_polynomial(N_min,"N_min");
print_polynomial(N_min,"N_min",strcat(strf,"_N_min_coef.m"));
print_polynomial(D_min,"D_min");
print_polynomial(D_min,"D_min",strcat(strf,"_D_min_coef.m"));
subplot(111);
zplane(qroots(conv(N_min(:),[1;-1])),qroots(D_min(:)));
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
fprintf(fid,"Ars=%g %% Amplitude stop band peak ripple\n",Ars/2);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"td=%g %% Pass band group delay\n",td);
fprintf(fid,"tdr=%g %% Pass band group delay peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple(rad./pi))\n",ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

eval(sprintf(strcat("save %s.mat ",
" socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_allocsd_Lim",
" socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_allocsd_Ito",
" nbits ndigits ndigits_alloc k_allocsd_digits c_allocsd_digits ",
" k_allocsd_digits c_allocsd_digits ftol ctol n ",
" fap Arp Wap Ars Was td tdr Wtp ppr Wpp k0 epsilon0 c0 kk0 ck0 ",
" k0_sd c0_sd kk0_sd ck0_sd k_min c_min kk_min ck_min"),strf));

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
