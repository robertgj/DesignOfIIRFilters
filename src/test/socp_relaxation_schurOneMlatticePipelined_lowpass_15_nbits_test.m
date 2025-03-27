% socp_relaxation_schurOneMlatticePipelined_lowpass_15_nbits_test.m 
%
% Use SOCP relaxation to find the 15 bit 4 signed-digit coefficients of a
% low-pass filter implemented as a tapped pipelined Schur one-multiplier
% all-pass lattice filter 
%
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="socp_relaxation_schurOneMlatticePipelined_lowpass_15_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false
maxiter=5000
ftol=1e-3
ctol=1e-6
nbits=15
nscale=2^(nbits-1);
ndigits=4

%
% Deczky3 lowpass filter specification
%
n=1000
fap=0.15,dBap=0.11,Wap=1
ftp=0.25,tp=9,tpr=0.04,Wtp=1
Wat=2*ftol
fas=0.35,dBas=46,Was=100

% Options
socp_relaxation_schurOneMlatticePipelined_lowpass_allocsd_Lim=true
socp_relaxation_schurOneMlatticePipelined_lowpass_allocsd_Ito=false

%
% Initial filter
%
schurOneMlattice_socp_slb_lowpass_test_N2_coef;
schurOneMlattice_socp_slb_lowpass_test_D2_coef;
N0=N2(:);
D0=D2(:);
clear N2 D2;
D0=[D0(:);zeros(length(N0)-length(D0),1)];
% Convert to pipelined form
[k0,epsilon0,c0,kk0,ck0] = tf2schurOneMlatticePipelined(N0,D0);
kc0=[k0(:);c0(:);kk0(:);ck0(:)];
Nk=length(k0);
Nc=length(c0);
Nkk=length(kk0);
Nck=length(ck0);
Nx=Nk+Nc+Nkk+Nck;
Rk=1:Nk;
Rc=(Nk+1):(Nk+Nc);
Rkk=(Nk+Nc+1):(Nk+Nc+Nkk);
Rck=(Nk+Nc+Nkk+1):(Nk+Nc+Nkk+Nck);

%
% Frequency vectors for the Schur one-mulitplier lattice filter
%

n=1000;
w=(0:(n-1))'*pi/n;
wa=w;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Amplitude constraints
wa=w;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

nchk=[1,2,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nchk=[");printf("%d ",nchk);printf(" ]\n");
printf("wa(nchk)*0.5/pi=[");printf("%g ",wa(nchk)*0.5/pi);printf(" ]\n");
printf("Asqd(nchk)=[");printf("%g ",Asqd(nchk));printf(" ]\n");
printf("Asqdu(nchk)=[");printf("%g ",Asqdu(nchk));printf(" ]\n");
printf("Asqdl(nchk)=[");printf("%g ",Asqdl(nchk));printf(" ]\n");
printf("Wa(nchk)=[");printf("%g ",Wa(nchk));printf(" ]\n");

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% dAsqdw constraints
wd=[];
Dd=[];
Ddu=[];
Ddl=[];
Wd=[];

% Initial response
Asq0=schurOneMlatticePipelinedAsq(wa,k0,epsilon0,c0,kk0,ck0);

% Find kc0 error
Esq0=schurOneMlatticePipelinedEsq(k0,epsilon0,c0,kk0,ck0,wa,Asqd,Wa,wt,Td,Wt)

% Constraints on the coefficients
dmax=inf;
rho=1-ftol;
kc_u=[rho*ones(Nk,1);10*ones(Nc,1);rho*ones(Nkk,1);10*ones(Nck,1)];
kc_l=-kc_u;
kc_active=[1:(Nk+Nc+Nkk),(Nk+Nc+Nkk+1):2:Nx]';

% Signed-digit coefficients with no allocation
kc0_sd_no_alloc=flt2SD(kc0,nbits,ndigits);
k0_sd_no_alloc=kc0_sd_no_alloc(Rk);
c0_sd_no_alloc=kc0_sd_no_alloc(Rc);
kk0_sd_no_alloc=kc0_sd_no_alloc(Rkk);
ck0_sd_no_alloc=kc0_sd_no_alloc(Rck);
print_polynomial(k0_sd_no_alloc,"k0_sd_no_alloc",nscale);
print_polynomial(k0_sd_no_alloc,"k0_sd_no_alloc", ...
                 strcat(strf,"_k0_sd_no_alloc_coef.m"),nscale);
print_polynomial(c0_sd_no_alloc,"c0_sd_no_alloc",nscale);
print_polynomial(c0_sd_no_alloc,"c0_sd_no_alloc", ...
                 strcat(strf,"_c0_sd_no_alloc_coef.m"),nscale);
print_polynomial(kk0_sd_no_alloc,"kk0_sd_no_alloc",nscale);
print_polynomial(kk0_sd_no_alloc,"kk0_sd_no_alloc", ...
                 strcat(strf,"_kk0_sd_no_alloc_coef.m"),nscale);
print_polynomial(ck0_sd_no_alloc,"ck0_sd_no_alloc",nscale);
print_polynomial(ck0_sd_no_alloc,"ck0_sd_no_alloc", ...
                 strcat(strf,"_ck0_sd_no_alloc_coef.m"),nscale);

% Find the number of signed-digits and adders used by kc0_sd_no_alloc
[kc0_sd_no_alloc_digits,kc0_sd_no_alloc_adders] = ...
  SDadders(kc0_sd_no_alloc(find(kc0_sd_no_alloc~=0)),nbits);

% Find kc0_sd_no_alloc error
Esq0_sd_no_alloc = schurOneMlatticePipelinedEsq ...
                     (k0_sd_no_alloc,epsilon0,c0_sd_no_alloc, ...
                      kk0_sd_no_alloc,ck0_sd_no_alloc, ...
                      wa,Asqd,Wa);

%
% Allocate signed-digits to the coefficients
%
if socp_relaxation_schurOneMlatticePipelined_lowpass_allocsd_Lim
  ndigits_alloc = schurOneMlatticePipelined_allocsd_Lim ...
                    (nbits,ndigits,k0,epsilon0,c0,kk0,ck0, ...
                     wa,Asqd,Wa,[],[],[],[],[],[],[],[],[]);
  strItoLim="Lim";
elseif socp_relaxation_schurOneMlatticePipelined_lowpass_allocsd_Ito
  ndigits_alloc = schurOneMlatticePipelined_allocsd_Ito ...
                    (nbits,ndigits,k0,epsilon0,c0,kk0,ck0, ...
                     wa,Asqd,Wa,[],[],[],[],[],[],[],[],[]);
  strItoLim="Ito";
else
  ndigits_alloc=zeros(size(kc0));
  ndigits_alloc(kc0_active)=ndigits;
  strItoLim="none";
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


% Find the signed-digit approximations to k0 and c0 with allocation
[kc0_sd,kc0_sdu,kc0_sdl]=flt2SD(kc0,nbits,ndigits_alloc);
k0_sd=kc0_sd(Rk);
k0_sd=k0_sd(:);
c0_sd=kc0_sd(Rc);
c0_sd=c0_sd(:);
kk0_sd=kc0_sd(Rkk);
kk0_sd=kk0_sd(:);
ck0_sd=kc0_sd(Rck);
ck0_sd=ck0_sd(:);
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

% Find kc0_sd error
Esq0_sd=schurOneMlatticePipelinedEsq ...
          (k0_sd,epsilon0,c0_sd,kk0_sd,ck0_sd,wa,Asqd,Wa);

% Find the number of signed-digits and adders used by kc0_sd
[kc0_sd_digits,kc0_sd_adders]=SDadders(kc0_sd(kc0_active),nbits);

% Initialise the vector of filter coefficients to be optimised
kc=zeros(size(kc0));
kc(kc0_active)=kc0(kc0_active);
kc_l=kc0_sdl;
kc_u=kc0_sdu;
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
                           wa,Asqd,Asqdu,Asqdl,Wa, ...
                           [],[],[],[],[], ...
                           [],[],[],[],[], ...
                           [],[],[],[],[], ...
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
k_min=kc_min(Rk);
c_min=kc_min(Rc);
kk_min=kc_min(Rkk);
ck_min=kc_min(Rck);
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
print_polynomial(c_min,"c_min",nscale);
print_polynomial(c_min,"c_min",strcat(strf,"_c_min_coef.m"),nscale);
print_polynomial(kk_min,"kk_min",nscale);
print_polynomial(kk_min,"kk_min",strcat(strf,"_kk_min_coef.m"),nscale);
print_polynomial(ck_min,"ck_min",nscale);
print_polynomial(ck_min,"ck_min",strcat(strf,"_ck_min_coef.m"),nscale);
Esq_min=schurOneMlatticePipelinedEsq ...
          (k_min,epsilon0,c_min,kk_min,ck_min,wa,Asqd,Wa);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
% Find the number of signed-digits and adders used by kc_sd
[kc_min_digits,kc_min_adders]=SDadders(kc_min(kc0_active),nbits);
printf("%d signed-digits used\n",kc_min_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kc_min_adders,nbits);

%
% Make a LaTeX table for cost
%
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %10.4e & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit & %10.4e & %d & %d \\\\\n", ...
        nbits,ndigits, ...
        Esq0_sd_no_alloc,kc0_sd_no_alloc_digits,kc0_sd_no_alloc_adders);
fprintf(fid,"%d-bit %d-signed-digit(%s)& %10.4e & %d & %d \\\\\n",
        nbits,ndigits,strItoLim,Esq0_sd,kc0_sd_digits,kc0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %10.4e & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,kc_min_digits,kc_min_adders);
fclose(fid);

%
% Amplitude and delay at local peaks
%
Asq=schurOneMlatticePipelinedAsq(wa,k_min,epsilon0,c_min,kk_min,ck_min);
vAsql=local_max(Asqdl-Asq);
vAsqu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAsql);wa(vAsqu);wa([1,nap,nas,end])]);
AsqS=schurOneMlatticePipelinedAsq(wAsqS,k_min,epsilon0,c_min,kk_min,ck_min);
printf("k,c_min:fAS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:10*log10(AsqS)=[ ");printf("%f ",10*log10(AsqS'));
printf(" ] (dB)\n");
T=schurOneMlatticePipelinedT(wt,k_min,epsilon0,c_min,kk_min,ck_min);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMlatticePipelinedT(wTS,k_min,epsilon0,c_min,kk_min,ck_min);
printf("k,c,kk,ck_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c,kk,ck_min:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

%
% Calculate response
%
Asq_kc0=schurOneMlatticePipelinedAsq(wa,k0,epsilon0,c0,kk0,ck0);
Asq_kc0_sd_no_alloc=schurOneMlatticePipelinedAsq ...
                      (wa,k0_sd_no_alloc,epsilon0,c0_sd_no_alloc, ...
                       kk0_sd_no_alloc,ck0_sd_no_alloc);
Asq_kc0_sd=schurOneMlatticePipelinedAsq ...
             (wa,k0_sd,epsilon0,c0_sd,kk0_sd,ck0_sd);
Asq_kc_min=schurOneMlatticePipelinedAsq(wa,k_min,epsilon0,c_min,kk_min,ck_min);

T_kc0=schurOneMlatticePipelinedT(wt,k0,epsilon0,c0,kk0,ck0);
T_kc0_sd_no_alloc=schurOneMlatticePipelinedT ...
                    (wt,k0_sd_no_alloc,epsilon0,c0_sd_no_alloc, ...
                     kk0_sd_no_alloc,ck0_sd_no_alloc);
T_kc0_sd=schurOneMlatticePipelinedT ...
           (wt,k0_sd,epsilon0,c0_sd,kk0_sd,ck0_sd);
T_kc_min=schurOneMlatticePipelinedT(wt,k_min,epsilon0,c_min,kk_min,ck_min);

% Check constraints after the last truncation
vS=schurOneMlatticePipelined_slb_update_constraints ...
     (Asq_kc_min,Asqdu,Asqdl,Wa,T_kc_min,Tdu,Tdl,Wt,[],[],[],[],[],[],[],[],ctol/100);
if ~schurOneMlatticePipelined_slb_constraints_are_empty(vS)
  printf("These constraints on the filter response are not met:\n");
  schurOneMlatticePipelined_slb_show_constraints ...
    (vS,wa,Asq_kc_min,wt,T_kc_min,[],[],[],[]);
endif

% Check response
[N_min,D_min]=schurOneMlatticePipelined2tf(k_min,epsilon0,c_min,kk_min,ck_min);
print_polynomial(N_min,"N_min");
print_polynomial(N_min,"N_min",strcat(strf,"_N_min_coef.m"));
print_polynomial(D_min,"D_min");
print_polynomial(D_min,"D_min",strcat(strf,"_D_min_coef.m"));
Hchk=freqz(N_min(:),D_min(:),wa);
if max(abs(abs(Hchk)-sqrt(Asq_kc_min))) > 10*eps
  error("max(abs(abs(Hchk)-sqrt(Asq_kc_min)))(%g*eps) > 10*eps", ...
        max(abs(abs(Hchk)-sqrt(Asq_kc_min)))/eps);
endif
Tchk=delayz(N_min(:),D_min(:),wt);
if max(abs(Tchk-T_kc_min)) > 100*eps
  error("max(abs(Tchk-T_kc_min))(%g*eps) > 100*eps", max(abs(Tchk-T_kc_min))/eps);
endif

% Plot response
subplot(211);
rap=1:nap;
ras=nas:(n-1);
[ax,ha,hs]= plotyy(wa(rap)*0.5/pi, ...
                   10*log10([Asq_kc0(rap),Asq_kc0_sd_no_alloc(rap), ...
                             Asq_kc0_sd(rap),Asq_kc_min(rap)]), ...
                   wa(ras)*0.5/pi, ...
                   10*log10([Asq_kc0(ras),Asq_kc0_sd_no_alloc(ras), ...
                             Asq_kc0_sd(ras),Asq_kc_min(ras)]));
% Copy line colour
hac=get(ha,"color");
hls={"-",":","--","-."};
for c=1:4
  set(hs(c),"color",hac{c});
  set(ha(c),"linestyle",hls{c});
  set(hs(c),"linestyle",hls{c});
endfor
axis(ax(1),[0 0.5 -0.15 0.05]);
axis(ax(2),[0 0.5 -52 -44]);
strt=sprintf("Low-pass filter : nbits=%d,fap=%g,dBap=%g,fas=%g,dBas=%g", ...
             nbits,fap,dBap,fas,dBas);
title(strt);
grid("on");
ylabel("Amplitude(dB)");
subplot(212);
h=plot(wt*0.5/pi,[T_kc0,T_kc0_sd_no_alloc,T_kc0_sd,T_kc_min]);
for c=1:4
  set(h(c),"linestyle",hls{c});
  set(h(c),"linestyle",hls{c});
endfor
axis([0 0.5 tp+(tpr*[-1,1])]);
ylabel("Delay(samples)");
xlabel("Frequency");
grid("on");
legend("initial","s-d",sprintf("s-d(%s)",strItoLim),"s-d(SOCP-relax)");
legend("location","east");
legend("boxoff");
legend("left");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Pole-zero plot
zplane(qroots(N_min(:)),qroots(D_min(:)));
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"socp_relaxation_schurOneMlatticePipelined_lowpass_allocsd_Lim=%d\n",
        socp_relaxation_schurOneMlatticePipelined_lowpass_allocsd_Lim);
fprintf(fid,"socp_relaxation_schurOneMlatticePipelined_lowpass_allocsd_Ito=%d\n",
        socp_relaxation_schurOneMlatticePipelined_lowpass_allocsd_Ito);
fprintf(fid,"nbits=%d %% Bits-per-coefficient \n",nbits);
fprintf(fid,"ndigits=%d %% Average signed-digits-per-coefficient \n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple(dB)\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftp=%g %% Group-delay pass band upper edge\n",ftp);
fprintf(fid,"tp=%g %% Nominal pass band group-delay(samples)\n",tp);
fprintf(fid,"tpr=%g %% Group-delay pass band peak-to-peak ripple(samples)\n",tpr);
fprintf(fid,"Wtp=%g %% Group-delay pass band weight\n",Wtp);
fprintf(fid,"fas=%g %% Amplitude stop band lower edge\n",fas);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple(dB)\n",dBas);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fclose(fid);

eval(sprintf(["save %s.mat ", ...
 "socp_relaxation_schurOneMlatticePipelined_lowpass_allocsd_Lim ", ...
 "socp_relaxation_schurOneMlatticePipelined_lowpass_allocsd_Ito ", ...
 "nbits ndigits ndigits_alloc k_allocsd_digits c_allocsd_digits ftol ctol ", ...
 "n fap dBap Wap ftp tp tpr Wtp fas dBas Was k0 epsilon0 c0 ", ...
 "k0_sd c0_sd kk0_sd ck0_sd k_min c_min kk_min ck_min N_min D_min"], strf));

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
