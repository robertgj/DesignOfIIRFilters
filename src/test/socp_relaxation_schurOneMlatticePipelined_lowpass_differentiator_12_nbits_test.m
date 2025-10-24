% socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_12_nbits_test.m
%
% Use SOCP relaxation to find the 12 bit 3 signed-digit coefficients of a
% low-pass differentiator filter implemented as the series combination of
% (1-z^{-1}) with a pipelined Schur one-multiplier lattice correction filter.
%
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false
maxiter=2000
ftol=1e-3
ctol=ftol/100
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
kc0=[k0;c0;kk0;ck0];

%
% Lowpass differentiator filter specification
% (ppr=0.002,tpr=0.06 fails with QEMU/nehalem)
fap=0.3;fas=0.4;
Arp=0.01;Art=0.02;Ars=0.02;Wap=1;Wat=0.001;Was=1;
fpp=fap;pp=1.5;ppr=0.01;Wpp=1;
ftp=fap;tp=length(k0)-1;tpr=0.1;Wtp=0.1;
fdp=fap;cpr=1;cn=0;Wdp=0.1;

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
ndp=ceil(fdp*n/0.5);

% Amplitude
wa=w;
Fz=[1;-1];
Ad=([(wa(1:nap)/2);zeros(n-nap-1,1)]);
Adu=[(wa(1:(nas-1))/2);zeros(n-nas,1)] + ...
    [(Arp/2)*ones(nap,1);(Art/2)*ones(nas-nap-1,1);(Ars/2)*ones(n-nas,1)];
Adl=Ad-[(Arp/2)*ones(nap,1);zeros(n-nap-1,1)];
Adl(find(Adl<0))=0;
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas,1)];
% Amplitude response of (1-z^-1)
Az=2*sin(wa/2);

% Phase response 
wp=w(1:npp);
Pd=(pp*pi)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));
% Phase response of (1-z^-1)
Pz=(pi/2)-(wp/2);

% Group delay
wt=w(1:ntp);
Td=tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));
% Group delay response of (1-z^-1)
Tz=0.5;

% dCsqdw constraints
wd=[];
dAsqdwd=[];
dAsqdwdu=[];
dAsqdwdl=[];
Wd=[];
% dAsqdw response of (1-z^-1)
dAsqdwz=[];
Rdp=1:ndp;
wd=wa(Rdp);
dCsqdwd=((Ad(Rdp)./Az(Rdp)).^2).*((2./wd)-cot(wd/2));
dCsqdwErr=(cpr/2)*((Rdp(:)/ndp).^cn);
dCsqdwdu=dCsqdwd+(dCsqdwErr/2);
dCsqdwdl=dCsqdwd-(dCsqdwErr/2);
Wd=Wdp*ones(size(wd));
% dCsqdw response of (1-z^-1)
dCsqdwz=2*sin(wd);

% Constraints on the coefficients
dmax=inf;
rho=(nscale-1)/nscale;
Nk=length(k0);
Nc=length(c0);
Nkk=length(kk0);
Nck=length(ck0);
Nx=Nk+Nc+Nkk+Nck;
Rk=1:Nk;
Rc=(Nk+1):(Nk+Nc);
Rkk=(Nk+Nc+1):(Nk+Nc+Nkk);
Rck=(Nk+Nc+Nkk+1):(Nk+Nc+Nkk+Nck);
kc0_u=[rho*ones(size(k0));10*ones(size(c0)); ...
       rho*ones(size(kk0));10*ones(size(ck0))];
kc0_l=-kc0_u;
Nx=Nk+Nc+Nkk+Nck;
kc0_active=find(kc0);

% Initial response
Asq0c=schurOneMlatticePipelinedAsq(wa,k0,epsilon0,c0,kk0,ck0);
A0c=sqrt(Asq0c);
A0=A0c.*Az;
P0c=schurOneMlatticePipelinedP(wp,k0,epsilon0,c0,kk0,ck0);
P0=P0c+Pz;
T0c=schurOneMlatticePipelinedT(wt,k0,epsilon0,c0,kk0,ck0);
T0=T0c+Tz;
dCsqdw0=schurOneMlatticePipelineddAsqdw(wd,k0,epsilon0,c0,kk0,ck0);

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
                     wa,(Ad./Az).^2,ones(size(wa)), ...
                     wt,Td-Tz,ones(size(wt)), ...
                     wp,Pd-Pz,ones(size(wp)), ...
                     wd,dCsqdwd,ones(size(wd)));
elseif ...
  socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_allocsd_Ito 
  ndigits_alloc = schurOneMlatticePipelined_allocsd_Ito ...
                    (nbits,ndigits,k0,epsilon0,c0,kk0,ck0, ...
                     wa,(Ad./Az).^2,Wa, ...
                     wt,Td-Tz,Wt, ...
                     wp,Pd-Pz,Wp, ...
                     wd,dCsqdwd,Wd);
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
ck0_sd(2:2:end)=0;
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
                                  wa,(Ad./Az).^2,Wa, ...
                                  wt,Td-Tz,Wt, ...
                                  wp,Pd-Pz,Wp, ...
                                  wd,dCsqdwd,Wd);
printf("Exact coefficients Esq0=%g\n",Esq0);

% Find kc0_sd error
Esq0_sd=schurOneMlatticePipelinedEsq(k0_sd,epsilon0,c0_sd,kk0_sd,ck0_sd, ...
                                     wa,(Ad./Az).^2,Wa, ...
                                     wt,Td-Tz,Wt, ...
                                     wp,Pd-Pz,Wp, ...
                                     wd,dCsqdwd,Wd);
printf("Signed-digit coefficients Esq0_sd=%g\n",Esq0_sd);

% Find the number of signed-digits and adders used by kc0_sd
[kc0_digits,kc0_adders]= ...
  SDadders(kc0_sd([1:(Nk+Nc+Nkk),(Nk+Nc+Nkk+1):2:Nx]),nbits);

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
    % Find the SOCP PCLS solution for the remaining active coefficients
    [nextk,nextc,nextkk,nextck,slb_iter,opt_iter,func_iter,feasible] = ...
      schurOneMlatticePipelined_slb(@schurOneMlatticePipelined_socp_mmse, ...
                           kc_b(Rk),epsilon0,kc_b(Rc),kc_b(Rkk),kc_b(Rck), ...
                           kc_bu,kc_bl,kc_active,dmax, ...
                           wa,(Ad./Az).^2,(Adu./Az).^2,(Adl./Az).^2,Wa, ...
                           wt,Td-Tz,Tdu-Tz,Tdl-Tz,Wt, ...
                           wp,Pd-Pz,Pdu-Pz,Pdl-Pz,Wp, ...
                           wd,dCsqdwd,dCsqdwdu,dCsqdwdl,Wd, ...
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
ck_min(2:2:end)=0;
Esq_min=schurOneMlatticePipelinedEsq ...
          (k_min,epsilon0,c_min,kk_min,ck_min, ...
           wa,(Ad./Az).^2,Wa,wt,Td-Tz,Wt,wp,Pd-Pz,Wp,wd,dCsqdwd,Wd);
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
[kc_digits,kc_adders]=SDadders(kc_min([1:(Nk+Nc+Nkk),(Nk+Nc+Nkk+1):2:Nx]),nbits);
printf("%d signed-digits used\n",kc_digits);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       kc_adders,nbits);

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_kc_min_cost.tab"),"wt");
fprintf(fid,"Exact & %10.4e & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(Ito)& %10.4e & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd,kc0_digits,kc0_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %10.4e & %d & %d \\\\\n", ...
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
dCsqdw_kc0=schurOneMlatticePipelineddAsqdw(wd,k0,epsilon0,c0,kk0,ck0);
dCsqdw_kc0_sd=schurOneMlatticePipelineddAsqdw ...
                (wd,k0_sd,epsilon0,c0_sd,kk0_sd,ck0_sd);
dCsqdw_kc_min=schurOneMlatticePipelineddAsqdw ...
                (wd,k_min,epsilon0,c_min,kk_min,ck_min);

% Check constraints after the last truncation
vS=schurOneMlatticePipelined_slb_update_constraints ...
     (Asq_kc_min,(Adu./Az).^2,(Adl./Az).^2,Wa, ...
      T_kc_min,Tdu-Tz,Tdl-Tz,Wt, ...
      P_kc_min,Pdu-Pz,Pdl-Pz,Wp, ...
      dCsqdw_kc_min,dCsqdwdu,dCsqdwdl,Wd, ...
      ctol);
if ~schurOneMlatticePipelined_slb_constraints_are_empty(vS)
  printf("These constraints on the correction filter response are not met:\n");
  schurOneMlatticePipelined_slb_show_constraints ...
    (vS,wa,Asq_kc_min,wt,T_kc_min,wp,P_kc_min,wd,dCsqdw_kc_min);
endif

% Plot response
subplot(311);
rap=1:nap;
ras=nas:(n-1);
A_kc0=Az.*sqrt(Asq_kc0);
A_kc0_sd=Az.*sqrt(Asq_kc0_sd);
A_kc_min=Az.*sqrt(Asq_kc_min);
[ax,ha,hs] = ...
  plotyy(wa(rap)*0.5/pi,[A_kc0(rap),A_kc0_sd(rap),A_kc_min(rap)]-Ad(rap), ...
         wa(ras)*0.5/pi,[A_kc0(ras),A_kc0_sd(ras),A_kc_min(ras)]-Ad(ras));
% Copy line colour
hac=get(ha,"color");
hls={"-","--","-."};
for c=1:3
  set(hs(c),"color",hac{c}); 
  set(ha(c),"linestyle",hls{c});
  set(hs(c),"linestyle",hls{c}); 
endfor
ylabel("Amplitude error");
strt=sprintf(["Pipelined low-pass differentiator : ", ...
              "fap=%g,fas=%g,Arp=%g,Ars=%g,tp=%g,ppr=%g"], ...
             fap,fas,Arp,Ars,tp,ppr);
title(strt);
axis(ax(1),[0 0.5 Arp*[-1,1]]);
axis(ax(2),[0 0.5 0.02*[-1,1]]);
grid("on");
subplot(312);
plot(wp*0.5/pi,(P_kc0+Pz+(wp*tp))/pi,"linestyle","-", ...
     wp*0.5/pi,(P_kc0_sd+Pz+(wp*tp))/pi,"linestyle","--", ...
     wp*0.5/pi,(P_kc_min+Pz+(wp*tp))/pi,"linestyle","-.");
axis([0 0.5 pp+((ppr/2)*[-1,1])]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
legend("exact","s-d(Ito)","s-d(SOCP-relax)");
legend("location","east");
legend("boxoff");
legend("left");
subplot(313);
plot(wt*0.5/pi,T_kc0+Tz,"linestyle","-", ...
     wt*0.5/pi,T_kc0_sd+Tz,"linestyle","--", ...
     wt*0.5/pi,T_kc_min+Tz,"linestyle","-.");
axis([0 0.5 tp+((tpr/2)*[-1,1])]);
grid("on");
ylabel("Group delay(samples)");
xlabel("Frequency");
zticks([]);
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
zplane(qroots(conv(N_min(:),Fz)),qroots(D_min(:)));
title(strt);
zticks([]);
print(strcat(strf,"_kc_min_pz"),"-dpdflatex");
close

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%d %% Bits-per-coefficient \n",nbits);
fprintf(fid,"ndigits=%d %% Average signed-digits-per-coefficient \n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"rho=%g %% Cnstraint on reflection coefficients\n",rho);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"Arp=%g %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Art=%g %% Amplitude transition band peak-to-peak ripple\n",Art);
fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band lower edge\n",fas);
fprintf(fid,"Ars=%g %% Amplitude stop band peak ripple\n",Ars/2);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"tp=%g %% Pass band group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple(rad./pi))\n",ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fprintf(fid,"fdp=%g %% dAsqdw pass band upper edge\n",fdp);
fprintf(fid, ...
        "cpr=%g %% Correction filter dCsqdw pass band peak-to-peak ripple\n", ...
        cpr);
fprintf(fid,"cn=%d %% Correction filter pass band dCsqdw w exponent\n",cn);
fprintf(fid,"Wdp=%g %% Correction filter dCsqdw pass band weight\n",Wdp);
fclose(fid);

eval(sprintf(strcat("save %s.mat ", ...
" socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_allocsd_Lim", ...
" socp_relaxation_schurOneMlatticePipelined_lowpass_differentiator_allocsd_Ito", ...
" nbits ndigits ndigits_alloc k_allocsd_digits c_allocsd_digits ", ...
" k_allocsd_digits c_allocsd_digits ftol ctol n ", ...
" fap Arp Wap Art Wat Ars Was tp tpr Wtp ppr Wpp fdp cpr cn Wdp ", ...
" k0 epsilon0 c0 kk0 ck0 k0_sd c0_sd kk0_sd ck0_sd ", ...
" k_min c_min kk_min ck_min"),...
             strf));

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
