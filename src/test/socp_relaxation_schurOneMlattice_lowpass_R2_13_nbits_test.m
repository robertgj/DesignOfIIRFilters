% socp_relaxation_schurOneMlattice_lowpass_R2_13_nbits_test.m 
%
% Use SOCP relaxation to find the 13 bit 4 signed-digit coefficients of a
% low-pass filter implemented as a tapped Schur one-multiplier all-pass lattice  % filter having denominator polynomial coefficients only in z^-2.
%
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="socp_relaxation_schurOneMlattice_lowpass_R2_13_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false
maxiter=5000
ftol=1e-4
ctol=1e-6
nbits=13
nscale=2^(nbits-1);
ndigits=4

% Options
socp_relaxation_schurOneMlattice_lowpass_R2_allocsd_Lim=false
socp_relaxation_schurOneMlattice_lowpass_R2_allocsd_Ito=true

%
% Initial filter
%
schurOneMlattice_socp_slb_lowpass_R2_test_k2_coef;
k0=k2(:);clear k2;
schurOneMlattice_socp_slb_lowpass_R2_test_epsilon2_coef;
epsilon0=epsilon2(:);clear epsilon2;
schurOneMlattice_socp_slb_lowpass_R2_test_c2_coef;
c0=c2(:);clear c2;
p_ones=ones(size(k0));

%
% Lowpass R=2 filter specification
%
% Low-pass filter specification (denominator polynomial in z^-2 only)
R=2;fap=0.15;dBap=0.1;Wap=1;fas=0.18;dBas=53;Was=5e6;

%
% Frequency vectors for the Schur one-mulitplier lattice filter
%

n=1000;
w=(0:(n-1))'*pi/n;
wa=w;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Amplitude
wa=w;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

nchk=[1,2,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nchk=[");printf("%d ",nchk);printf(" ]\n");
printf("wa(nchk)*0.5/pi=[");printf("%g ",wa(nchk)*0.5/pi);printf(" ]\n");
printf("Asqd(nchk)=[");printf("%g ",Asqd(nchk));printf(" ]\n");
printf("Asqdu(nchk)=[");printf("%g ",Asqdu(nchk));printf(" ]\n");
printf("Asqdl(nchk)=[");printf("%g ",Asqdl(nchk));printf(" ]\n");
printf("Wa(nchk)=[");printf("%g ",Wa(nchk));printf(" ]\n");

% Initial response
Asq0=schurOneMlatticeAsq(wa,k0,epsilon0,p_ones,c0);

% Find kc0 error
Esq0=schurOneMlatticeEsq(k0,epsilon0,p_ones,c0,wa,Asqd,Wa)

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
  schurOneMlatticeEsq(k0_sd_no_alloc,epsilon0,p_ones,c0_sd_no_alloc,wa,Asqd,Wa);

%
% Allocate signed-digits to the coefficients
%
if socp_relaxation_schurOneMlattice_lowpass_R2_allocsd_Lim
  ndigits_alloc = schurOneMlattice_allocsd_Lim ...
                    (nbits,ndigits,k0,epsilon0,p_ones,c0, ...
                     wa,Asqd,Wa,[],[],[],[],[],[],[],[],[]);
  strItoLim="Lim";
elseif socp_relaxation_schurOneMlattice_lowpass_R2_allocsd_Ito
  ndigits_alloc = schurOneMlattice_allocsd_Ito ...
                    (nbits,ndigits,k0,epsilon0,p_ones,c0, ...
                     wa,Asqd,Wa,[],[],[],[],[],[],[],[],[]);
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
Esq0_sd=schurOneMlatticeEsq(k0_sd,epsilon0,p_ones,c0_sd,wa,Asqd,Wa);

% Find the number of signed-digits and adders used by kc0_sd
[kc0_sd_digits,kc0_sd_adders]=SDadders(kc0_sd(kc0_active),nbits);

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
    [nextk,nextc,slb_iter,opt_iter,func_iter,feasible] = ...
      schurOneMlattice_slb(@schurOneMlattice_socp_mmse, ...
                           kc_b(1:Nk),epsilon0,p_ones,kc_b((Nk+1):end), ...
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
k_min=kc_min(1:Nk);
c_min=kc_min((Nk+1):end);
Esq_min=schurOneMlatticeEsq(k_min,epsilon0,p_ones,c_min,wa,Asqd,Wa);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
print_polynomial(c_min,"c_min",nscale);
print_polynomial(c_min,"c_min",strcat(strf,"_c_min_coef.m"),nscale);
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
% Amplitude at local peaks
%
Asq=schurOneMlatticeAsq(wa,k_min,epsilon0,p_ones,c_min);
vAsql=local_max(Asqdl-Asq);
vAsqu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAsql);wa(vAsqu);wa([1,nap,nas,end])]);
AsqS=schurOneMlatticeAsq(wAsqS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fAS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:10*log10(AsqS)=[ ");printf("%f ",10*log10(AsqS'));
printf(" ] (dB)\n");

%
% Calculate response
%
Asq_kc0=schurOneMlatticeAsq(wa,k0,epsilon0,p_ones,c0);
Asq_kc0_sd_no_alloc=schurOneMlatticeAsq ...
                      (wa,k0_sd_no_alloc,epsilon0,p_ones,c0_sd_no_alloc);
Asq_kc0_sd=schurOneMlatticeAsq(wa,k0_sd,epsilon0,p_ones,c0_sd);
Asq_kc_min=schurOneMlatticeAsq(wa,k_min,epsilon0,p_ones,c_min);

% Check constraints after the last truncation
vS=schurOneMlattice_slb_update_constraints ...
     (Asq_kc_min,Asqdu,Asqdl,Wa,[],[],[],[],[],[],[],[],[],[],[],[],ctol);
if ~schurOneMlattice_slb_constraints_are_empty(vS)
  printf("These constraints on the filter response are not met:\n");
  schurOneMlattice_slb_show_constraints(vS,wa,Asq_kc_min,[],[],[],[],[],[]);
endif

% Check response
[N_min,D_min]=schurOneMlattice2tf(k_min,epsilon0,p_ones,c_min);
print_polynomial(N_min,"N_min");
print_polynomial(N_min,"N_min",strcat(strf,"_N_min_coef.m"));
print_polynomial(D_min,"D_min");
print_polynomial(D_min,"D_min",strcat(strf,"_D_min_coef.m"));
Hchk=freqz(N_min(:),D_min(:),wa);
if max(abs(abs(Hchk)-sqrt(Asq_kc_min))) > 100*eps
  error("max(abs(abs(Hchk)-sqrt(Asq_kc_min)))(%g*eps) > 100*eps", ...
        max(abs(abs(Hchk)-sqrt(Asq_kc_min)))/eps);
endif

% Plot squared-amplitude response
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
axis(ax(1),[0  0.5 -0.15 0.05]);
axis(ax(2),[0  0.5 -70 -50]);
strt=sprintf(["Low-pass R=2 filter : ", ...
             "nbits=%d,fap=%g,dBap=%g,fas=%g,dBas=%g,ctol=%g"], ...
             nbits,fap,dBap,fas,dBas,ctol);
title(strt);
grid("on");
ylabel("Amplitude(dB)");
xlabel("Frequency");
legend("initial","s-d",sprintf("s-d(%s)",strItoLim),"s-d(SOCP-relax)");
legend("location","southwest");
legend("boxoff");
legend("left");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Pole-zero plot
[N_min,D_min]=schurOneMlattice2tf(k_min,epsilon0,p_ones,c_min);
zplane(qroots(conv([1;-1],N_min(:))),qroots(D_min(:)));
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"socp_relaxation_schurOneMlattice_lowpass_R2_allocsd_Lim=%d\n", ...
        socp_relaxation_schurOneMlattice_lowpass_R2_allocsd_Lim);
fprintf(fid,"socp_relaxation_schurOneMlattice_lowpass_R2_allocsd_Ito=%d\n", ...
        socp_relaxation_schurOneMlattice_lowpass_R2_allocsd_Ito);
fprintf(fid,"nbits=%d %% Bits-per-coefficient \n",nbits);
fprintf(fid,"ndigits=%d %% Average signed-digits-per-coefficient \n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple(dB)\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fas=%g %% Amplitude stop band lower edge\n",fas);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple(dB)\n",dBas);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fclose(fid);

eval(sprintf(["save %s.mat ", ...
 "socp_relaxation_schurOneMlattice_lowpass_R2_allocsd_Lim ", ...
 "socp_relaxation_schurOneMlattice_lowpass_R2_allocsd_Ito ", ...
 "nbits ndigits ndigits_alloc k_allocsd_digits c_allocsd_digits ftol ctol ", ...
 "n fap dBap Wap fas dBas Was k0 epsilon0 c0 k0_sd c0_sd ", ...
 "k_min c_min N_min D_min"], strf));

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
