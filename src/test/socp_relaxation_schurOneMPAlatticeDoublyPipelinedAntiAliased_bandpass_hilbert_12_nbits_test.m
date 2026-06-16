% socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased ...
% ... _bandpass_hilbert_12_nbits_test.m

% SOCP-relaxation optimisation of the response of a band-pass Hilbert filter
% composed of a parallel all-pass Schur one-multiplier lattice low-pass filter
% in series with a parallel all-pass Schur one-multiplier lattice anti-aliasing
% filter. The coefficients have 12-bit 4-signed-digits.

% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf=["socp_relaxation_schurOneMPAlatticeDoublyPipelinedAntiAliased", ...
      "_bandpass_hilbert_12_nbits_test"];

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

% Options
eval(sprintf("%s_allocsd_Lim=true",strf));
eval(sprintf("%s_allocsd_Ito=false",strf));

tic;

ftol=1e-3
ctol=1e-6
maxiter=10000
verbose=false
nbits=12
nscale=2^(nbits-1);
ndigits=3

%
% Band-pass Hilbert filter specification
%
difference=true;
Ni=5; % Initial low-pass filter order
fasl=0.05,fapl=0.1,fapu=0.2,fasu=0.25,fasuu=0.3
dBap=0.3,dBasl=40,dBasu=20,dBasuu=40
Wasl=100,Watl=0.01,Wap=1,Watu=0.01,Wasu=0.01
fppl=0.12,fppu=0.18,pp=3.5,ppr=0.0008,Wpp=10
ftpl=0.12,ftpu=0.18,tp=16,tpr=0.08,Wtp=10
fdpl=0.1,fdpu=0.2,dp=0,dpr=3,Wdp=0.01
% Additional z^-2 delay introduced by doubly-pipelined implementation
Tz2=2;
% The initial anti-aliasing filter is Butterworth half-band (ie:R=2)!
maa=11;
faap=0.25;

%
% Initial coefficients found by
% parallel_allpass_socp_slb_bandpass_hilbert_R2_test.m
%
parallel_allpass_socp_slb_bandpass_hilbert_R2_test_Da1_coef;
parallel_allpass_socp_slb_bandpass_hilbert_R2_test_Db1_coef;
% Convert the R=2 band-pass Hilbert filter to parallel Schur lattice filters
Da0=Da1(1:2:end);clear Da1;Da0=Da0(:)';
Db0=Db1(1:2:end);clear Db1;Db0=Db0(:)';
[A1k0,~,~,~]=tf2schurOneMlattice(fliplr(Da0),Da0);
[A2k0,~,~,~]=tf2schurOneMlattice(fliplr(Db0),Db0);

% Convert the anti-aliasing filter to parallel Schur lattice filters
[Naa,Daa]=butter(maa,faap*2);
[Aaa1_0,Aaa2_0]=tf2pa(Naa,Daa);
[Aaa1k0,~,~,~]=tf2schurOneMlattice(fliplr(Aaa1_0),Aaa1_0);
[Aaa2k0,~,~,~]=tf2schurOneMlattice(fliplr(Aaa2_0),Aaa2_0);
% The anti-aliasing filter is assumed to be Butterworth half-band (ie:R=2)!
Aaa1k0(1:2:end)=0;
Aaa2k0(1:2:end)=0;
Aaa1kones=ones(size(Aaa1k0));
Aaa2kones=ones(size(Aaa2k0));

NA1k=length(A1k0);
NA2k=length(A2k0);
NAaa1k=length(Aaa1k0);
NAaa2k=length(Aaa2k0);
NA=NA1k+NA2k+NAaa1k+NAaa2k;
RA1k=1:NA1k;
RA2k=(NA1k+1):(NA1k+NA2k);
RAaa1k=(NA1k+NA2k+1):(NA1k+NA2k+NAaa1k);
RAaa2k=(NA1k+NA2k+NAaa1k+1):(NA1k+NA2k+NAaa1k+NAaa2k);

k0=[A1k0(:);A2k0(:);Aaa1k0(:);Aaa2k0(:)];

% Reflection coefficient constraint
rho=127/128;
dmax=inf; % For compatibility with SQP

% Frequency points (avoid zero at 0 but not at 0.25?!?)
n=1000;
w=pi*(0:(n-1))'/n;

% Pass and transition band amplitudes of combined filters
wa=w;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
naap=floor(n*faap/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
nasuu=floor(n*fasuu/0.5)+1;
Asqd=[zeros(napl-1,1); ...
      ones(napu-napl+1,1); ...
      zeros(length(wa)-napu,1)];
Asqdu=[(10^(-dBasl/10))*ones(nasl,1); ...
       ones(nasu-nasl-1,1); ...
       (10^(-dBasu/10))*ones(nasuu-nasu,1); ...
       (10^(-dBasuu/10))*ones(length(wa)-nasuu+1,1)];
Asqdl=[zeros(napl-1,1); ...
       (10^(-dBap/10))*ones(napu-napl+1,1); ...
       zeros(length(wa)-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(length(wa)-nasu+1,1)];

% Phase response of combined filters
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=w(nppl:nppu);
Pd=(pp*pi)-(wp*(tp+Tz2));
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% Pass-band group delay response of combined filters
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
wt=w(ntpl:ntpu);
Td=(tp+Tz2)*ones(ntpu-ntpl+1,1);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));

% dAsqdw response of combined filters
ndpl=floor(n*fdpl/0.5)+1;
ndpu=ceil(n*fdpu/0.5)+1;
wd=w(ndpl:ndpu);
dp=0;
Dd=dp*ones(size(wd));
Ddu=Dd+(dpr/2);
Ddl=Dd-(dpr/2);
Wd=Wdp*ones(size(wd));

% Sanity checks
nachk=[1,nasl-1,nasl,nasl+1,napl-1,napl,napl+1,napu-1,napu,napu+1,nasu-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Asqd(nachk)=[");printf("%g ",Asqd(nachk));printf(" ]\n");
printf("Asqdu(nachk)=[");printf("%g ",Asqdu(nachk));printf(" ]\n");
printf("Asqdl(nachk)=[");printf("%g ",Asqdl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");
npchk=[1,length(wp)];
printf("npchk=[");printf("%d ",npchk);printf(" ]\n");
printf("wp(npchk)*0.5/pi=[");printf("%g ",wp(npchk)*0.5/pi);printf(" ]\n");
printf("Pd(npchk)=[");printf("%g ",Pd(npchk));printf(" ]\n");
printf("Pdu(npchk)=[");printf("%g ",Pdu(npchk));printf(" ]\n");
printf("Pdl(npchk)=[");printf("%g ",Pdl(npchk));printf(" ]\n");
printf("Wp(npchk)=[");printf("%g ",Wp(npchk));printf(" ]\n");
ntchk=[1,length(wt)];
printf("ntchk=[");printf("%d ",ntchk);printf(" ]\n");
printf("wt(ntchk)*0.5/pi=[");printf("%g ",wt(ntchk)*0.5/pi);printf(" ]\n");
printf("Td(ntchk)=[");printf("%g ",Td(ntchk));printf(" ]\n");
printf("Tdu(ntchk)=[");printf("%g ",Tdu(ntchk));printf(" ]\n");
printf("Tdl(ntchk)=[");printf("%g ",Tdl(ntchk));printf(" ]\n");
printf("Wt(ntchk)=[");printf("%g ",Wt(ntchk));printf(" ]\n");

% Linear constraints
% Reflection coefficient constraint
k_u=rho*ones(size(k0));
k_l=-k_u;
k_active=find(k0~=0);

% Allocate signed-digits to the coefficients
if eval(sprintf("%s_allocsd_Lim",strf))
  strItoLim="Lim"
  if 0
    ndigits_alloc=schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Lim ...
                    (nbits,ndigits, ...
                     k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k), ...
                     wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
  else
    ndigits_alloc=schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Lim ...
                    (nbits,ndigits, ...
                     k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k), ...
                     wa,Asqd,ones(size(Wa)), ...
                     wt,Td,ones(size(Wt)), ...
                     wp,Pd,ones(size(Wp)), ...
                     wd,Dd,ones(size(Wd))); 
  endif
elseif eval(sprintf("%s_allocsd_Ito",strf))
  strItoLim="Ito";
  ndigits_alloc=schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Ito ...
                  (nbits,ndigits, ...
                   k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k), ...
                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
else
  strItoLim="none";
  ndigits_alloc=zeros(size(k0));
  ndigits_alloc(k_active)=ndigits;
endif

A1k_allocsd_digits=int16(ndigits_alloc(RA1k));
A2k_allocsd_digits=int16(ndigits_alloc(RA2k));
Aaa1k_allocsd_digits=int16(ndigits_alloc(RAaa1k));
Aaa2k_allocsd_digits=int16(ndigits_alloc(RAaa2k));

printf("A1k_allocsd_digits=[ ");
printf("%2d ",A1k_allocsd_digits);printf("]';\n");
print_polynomial(A1k_allocsd_digits,"A1k_allocsd_digits", ...
                 strcat(strf,"_A1k_allocsd_digits.m"),"%2d");

printf("A2k_allocsd_digits=[ ");
printf("%2d ",A2k_allocsd_digits);printf("]';\n");
print_polynomial(A2k_allocsd_digits,"A2k_allocsd_digits", ...
                 strcat(strf,"_A2k_allocsd_digits.m"),"%2d");

printf("Aaa1k_allocsd_digits=[ ");
printf("%2d ",Aaa1k_allocsd_digits);printf("]';\n");
print_polynomial(Aaa1k_allocsd_digits,"Aaa1k_allocsd_digits", ...
                 strcat(strf,"_Aaa1k_allocsd_digits.m"),"%2d");

printf("Aaa2k_allocsd_digits=[ ");
printf("%2d ",Aaa2k_allocsd_digits);printf("]';\n");
print_polynomial(Aaa2k_allocsd_digits,"Aaa2k_allocsd_digits", ...
                 strcat(strf,"_Aaa2k_allocsd_digits.m"),"%2d");

% Find the signed-digit approximations to k0
k0_sd=flt2SD(k0,nbits,ndigits);
A1k0_sd=k0_sd(RA1k);
A2k0_sd=k0_sd(RA2k);
Aaa1k0_sd=k0_sd(RAaa1k);
Aaa2k0_sd=k0_sd(RAaa2k);
[k_sd,k_sdu,k_sdl]=flt2SD(k0,nbits,ndigits_alloc);
A1k_sd=k_sd(RA1k);
A2k_sd=k_sd(RA2k);
Aaa1k_sd=k_sd(RAaa1k);
Aaa2k_sd=k_sd(RAaa2k);
print_polynomial(A1k_sd,"A1k_sd",nscale);
print_polynomial(A1k_sd,"A1k_sd",strcat(strf,"_A1k_sd_coef.m"),nscale);
print_polynomial(A2k_sd,"A2k_sd",nscale);
print_polynomial(A2k_sd,"A2k_sd",strcat(strf,"_A2k_sd_coef.m"),nscale);
print_polynomial(Aaa1k_sd,"Aaa1k_sd",nscale);
print_polynomial(Aaa1k_sd,"Aaa1k_sd",strcat(strf,"_Aaa1k_sd_coef.m"),nscale);
print_polynomial(Aaa2k_sd,"Aaa2k_sd",nscale);
print_polynomial(Aaa2k_sd,"Aaa2k_sd",strcat(strf,"_Aaa2k_sd_coef.m"),nscale);

% Initialise k_active for optimisation
k_sdul=k_sdu-k_sdl;
k_active=find(k_sdul~=0);
n_active=length(k_active);

% Check for consistent upper and lower bounds
if any(k_sdl>k_sdu)
  error("found k_sdl>k_sdu");
endif
if any(k_sdl>k_sdu)
  error("found k_sdl>k_sdu");
endif
if any(k_sd(k_active)>k_sdu(k_active))
  error("found k_sd(k_active)>k_sdu(k_active)");
endif
if any(k_sdl(k_active)>k_sd(k_active))
  error("found k_sdl(k_active)>kuv0_sd(k_active)");
endif
if any(k0(k_active)>k_sdu(k_active))
  error("found k0(k_active)>k_sdu(k_active)");
endif
if any(k_sdl(k_active)>k0(k_active))
  error("found k_sdl(k_active)>k0(k_active)");
endif

% Find k error
Esq0=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
       (k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k), ...
        wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Find k0_sd error
Esq0_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
       (k0_sd(RA1k),k0_sd(RA2k),difference,k0_sd(RAaa1k),k0_sd(RAaa2k), ...
        wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Find k_sd error
Esq_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
       (k_sd(RA1k),k_sd(RA2k),difference,k_sd(RAaa1k),k_sd(RAaa2k), ...
        wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Find the number of signed-digits and adders used by k_sd
[k0_sd_digits,k0_sd_adders]=SDadders(k0_sd(k_active),nbits);
[k_sd_digits,k_sd_adders]=SDadders(k_sd(k_active),nbits);

% Initialise the vector of filter coefficients to be optimised
kopt=zeros(size(k0));
kopt(k_active)=k0(k_active);
kopt_l=k_l;
kopt_u=k_u;
kopt_active=k_active;

%
% Loop finding truncated coefficients
%

% Fix one coefficient at each iteration 
while ~isempty(kopt_active)
  
  % Define filter coefficients 
  [kopt_sd,kopt_sdu,kopt_sdl]=flt2SD(kopt,nbits,ndigits_alloc);
  kopt_sdul=kopt_sdu-kopt_sdl;
  kopt_b=kopt;
  kopt_bl=kopt_l;
  kopt_bu=kopt_u;
  
  % Ito et al. suggest ordering the search by max(kopt_sdu-kopt_sdl)
  [kopt_max,kopt_max_n]=max(kopt_sdul(kopt_active));
  coef_n=kopt_active(kopt_max_n);
  kopt_bl(coef_n)=kopt_sdl(coef_n);
  kopt_bu(coef_n)=kopt_sdu(coef_n);

  % Try to solve the current SOCP problem with bounds kopt_bu and kopt_bl
  try
    feasible=false;
    [nextA1k,nextA2k,nextAaa1k,nextAaa2k, ...
     slb_iter,socp_iter,func_iter,feasible] = ...
      schurOneMPAlatticeDoublyPipelinedAntiAliased_slb ...
        (@schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_mmse, ...
         kopt_b(RA1k),kopt_b(RA2k),difference,kopt_b(RAaa1k),kopt_b(RAaa2k), ...
         kopt_bu,kopt_bl,kopt_active,dmax, ...
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
    error("SOCP problem infeasible!");
  endif

  % Fix coef_n
  nextkopt=[nextA1k(:);nextA2k(:);nextAaa1k(:);nextAaa2k(:)];
  alpha=(nextkopt(coef_n)-((kopt_sdu(coef_n)+kopt_sdl(coef_n))/2))/ ...
        (kopt_sdul(coef_n)/2);
  if alpha>=0
    nextkopt(coef_n)=kopt_sdu(coef_n);
  else
    nextkopt(coef_n)=kopt_sdl(coef_n);
  endif
  kopt=nextkopt;
  kopt_active(kopt_max_n)=[];
  printf("Fixed kopt(%d)=%13.10f\n",coef_n,kopt(coef_n));
  printf("kopt_active=[ ");printf("%d ",kopt_active);printf("];\n\n");

endwhile

% Show results
k_min=kopt;
A1k_min=k_min(RA1k);
A2k_min=k_min(RA2k);
Aaa1k_min=k_min(RAaa1k);
Aaa2k_min=k_min(RAaa2k);

Esq_min=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
       (A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min, ...
        wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);

% Find the number of signed-digits and adders used
[kmin_digits,kmin_adders]=SDadders(k_min(k_active),nbits);
printf("%d signed-digits used\n",kmin_digits);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       kmin_adders,nbits);
fid=fopen(strcat(strf,"_k_min_digits.tab"),"wt");
fprintf(fid,"$%d$",kmin_digits);
fclose(fid);
fid=fopen(strcat(strf,"_k_min_adders.tab"),"wt");
fprintf(fid,"$%d$",kmin_adders);
fclose(fid);

% Find squared-magnitude, phase, group-delay and dAsqdw
Asq0=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
         (w,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);
Asq0_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
         (w,A1k0_sd,A2k0_sd,difference,Aaa1k0_sd,Aaa2k0_sd);
Asq_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
         (w,A1k_sd,A2k_sd,difference,Aaa1k_sd,Aaa2k_sd);
Asq_min=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
          (w,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);

Aaasq0=schurOneMPAlatticeAsq ...
         (w,Aaa1k0,ones(size(RAaa1k)),ones(size(RAaa1k)), ...
          Aaa2k0,ones(size(RAaa2k)),ones(size(RAaa2k)),false);
Aaasq0_sd=schurOneMPAlatticeAsq ...
           (w,Aaa1k0_sd,ones(size(RAaa1k)),ones(size(RAaa1k)), ...
            Aaa2k0_sd,ones(size(RAaa2k)),ones(size(RAaa2k)),false);
Aaasq_sd=schurOneMPAlatticeAsq ...
           (w,Aaa1k_sd,ones(size(RAaa1k)),ones(size(RAaa1k)), ...
            Aaa2k_sd,ones(size(RAaa2k)),ones(size(RAaa2k)),false);
Aaasq_min=schurOneMPAlatticeAsq ...
            (w,Aaa1k_min,ones(size(RAaa1k)),ones(size(RAaa1k)), ...
             Aaa2k_min,ones(size(RAaa2k)),ones(size(RAaa2k)),false);

P0=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
         (w,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);
P0_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
         (w,A1k0_sd,A2k0_sd,difference,Aaa1k0_sd,Aaa2k0_sd);
P_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
         (w,A1k_sd,A2k_sd,difference,Aaa1k_sd,Aaa2k_sd);
P_min=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
          (w,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);

T0=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
         (w,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);
T0_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
         (w,A1k0_sd,A2k0_sd,difference,Aaa1k0_sd,Aaa2k0_sd);
T_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
         (w,A1k_sd,A2k_sd,difference,Aaa1k_sd,Aaa2k_sd);
T_min=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
         (w,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);

dAsqdw0=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
          (w,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);
dAsqdw_sd=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
         (w,A1k_sd,A2k_sd,difference,Aaa1k_sd,Aaa2k_sd);
dAsqdw0_sd=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
         (w,A1k0_sd,A2k0_sd,difference,Aaa1k0_sd,Aaa2k0_sd);
dAsqdw_min=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
          (w,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);

% Amplitude, phase, delay and dAsqdw at local peaks
vAl=local_max(Asqdl-Asq_min);
vAu=local_max(Asq_min-Asqdu);
wAsqS=unique([w(vAl);w(vAu);w([1,nasl,napl,napu,nasu,end])]);
AsqS=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
       (wAsqS,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);
printf("k_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

vPl=local_max(Pdl-P_min(nppl:nppu));
vPu=local_max(P_min(nppl:nppu)-Pdu);
nPS=sort(unique([vPl;vPu;1;length(wp)]));
wPS=wp(nPS);
PS=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
     (wPS,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);
printf("k_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:PS-Pd=[ ");printf("%f ",mod((PS+(wPS*(tp+Tz2)))/pi,2));printf("] (rad.)\n");
                        
vTl=local_max(Tdl-T_min(ntpl:ntpu));
vTu=local_max(T_min(ntpl:ntpu)-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,length(wt)])]));
TS=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
     (wTS,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);
printf("k_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:TS=[ ");printf("%f ",TS');printf("] (Samples)\n");
                        
vDl=local_max(Ddl-dAsqdw_min(ndpl:ndpu));
vDu=local_max(dAsqdw_min(ndpl:ndpu)-Ddu);
wDS=sort(unique([wd(vDl);w(vDu);wd([1,length(wd)])]));
DS=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
     (wDS,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);
printf("k_min:fDS=[ ");printf("%f ",wDS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:DS=[ ");printf("%f ",DS');printf("] (Samples)\n");
                        
% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"w");
fprintf(fid,"Exact & %8.6f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit& %8.6f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd,k0_sd_digits,k0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(%s)& %8.6f & %d & %d \\\\\n", ...
        nbits,ndigits,strItoLim,Esq_sd,k_sd_digits,k_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %8.6f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_min,kmin_digits,kmin_adders);
fclose(fid);

%
% Plot response
%

% Plot anti-aliasing amplitude response
[ax,h1,h2]=plotyy(w*0.5/pi,10*log10([Aaasq0,Aaasq0_sd,Aaasq_sd,Aaasq_min]), ...
                  w*0.5/pi,10*log10([Aaasq0,Aaasq0_sd,Aaasq_sd,Aaasq_min]));
% Hack to match colours. Is there an easier way with colormap?
h1c=get(h1,"color");
hline={"-",":","--","-."};
for k=1:4
  set(h1(k),"color",h1c{k});
  set(h1(k),"linestyle",hline{k});
  set(h2(k),"color",h1c{k});
  set(h2(k),"linestyle",hline{k});
endfor
% End of hack
axis(ax(1),[0 0.5 -0.0006 0.0002]);
axis(ax(2),[0 0.5 -70 -30]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter stop-band ", ...
              "(nbits=%d,ndigits=%d) : fasl=%g,fasu=%g"], ...
             nbits,ndigits,fasl,fasu);
title(strt);
legend("initial","s-d",sprintf("s-d(%s)",strItoLim),"s-d(min)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_k_min_antialiasing"),"-dpdflatex");
close

% Plot amplitude response
[ax,h1,h2]=plotyy(w*0.5/pi, ...
                  10*log10([Asq0,Asq0_sd,Asq_sd,Asq_min]), ...
                  w*0.5/pi, ...
                  10*log10([Asq0,Asq0_sd,Asq_sd,Asq_min]));
% Hack to match colours. Is there an easier way with colormap?
for k=1:4
  set(h1(k),"color",h1c{k});
  set(h1(k),"linestyle",hline{k});
  set(h2(k),"color",h1c{k});
  set(h2(k),"linestyle",hline{k});
endfor
% End of hack
axis(ax(1),[0 0.5 -60 -10]);
axis(ax(2),[0 0.5 -0.5 0]);
grid("on");
xlabel("Frequency");
ylabel(ax(1),"Amplitude(dB)");
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter ", ...
              "amplitude nbits=%d,ndigits=%d"],nbits,ndigits);
title(strt);
legend(ax(1),"initial","s-d",sprintf("s-d(%s)",strItoLim),"s-d(min)");
legend(ax(1),"location","northeast");
legend(ax(1),"boxoff");
legend(ax(1),"left");
zticks([]);
print(strcat(strf,"_k_min_amplitude"),"-dpdflatex");
close

% Plot pass band amplitude response
h1=plot(w*0.5/pi,10*log10([Asq0,Asq0_sd,Asq_sd,Asq_min]));
% Hack to match colours. Is there an easier way with colormap?
for k=1:4
  set(h1(k),"color",h1c{k});
  set(h1(k),"linestyle",hline{k});
endfor
% End of hack
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0.08, 0.24, -0.6, 0.2]);
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter pass-band ", ...
              "amplitude nbits=%d,ndigits=%d) : fapl=%g,fapu=%g"], ...
             nbits,ndigits,fapl,fapu);
title(strt);
legend("initial","s-d",sprintf("s-d(%s)",strItoLim),"s-d(min)");
legend("location","south");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_k_min_pass_amplitude"),"-dpdflatex");
close

% Plot stop band amplitude response
h1=plot(w*0.5/pi,10*log10([Asq0,Asq0_sd,Asq_sd,Asq_min]));
% Hack to match colours. Is there an easier way with colormap?
for k=1:4
  set(h1(k),"color",h1c{k});
  set(h1(k),"linestyle",hline{k});
endfor
% End of hack
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 -10]);
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter stop-band ", ...
              "(nbits=%d,ndigits=%d) : fasl=%g,fasu=%g"], ...
             nbits,ndigits,fasl,fasu);
title(strt);
legend("initial","s-d",sprintf("s-d(%s)",strItoLim),"s-d(min)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_k_min_stop_amplitude"),"-dpdflatex");
close

% Plot phase response
h1=plot(w*0.5/pi,mod(unwrap([P0,P0_sd,P_sd,P_min]+(w*(tp+Tz2)))/pi,2));
% Hack to match colours. Is there an easier way with colormap?
for k=1:4
  set(h1(k),"color",h1c{k});
  set(h1(k),"linestyle",hline{k});
endfor
% End of hack
xlabel("Frequency");
ylabel("Phase (rad./$\\pi$)");
axis([0.08, 0.24, mod(pp,2)+(0.001*[-1,1])]);
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter pass-band ", ...
              "phase (nbits=%d,ndigits=%d) : fppl=%g,fppu=%g,ppr=%g"],
             nbits,ndigits,fppl,fppu,ppr);
title(strt);
legend("initial","s-d",sprintf("s-d(%s)",strItoLim),"s-d(min)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_k_min_pass_phase"),"-dpdflatex");
close

% Plot delay response
h1=plot(w*0.5/pi,[T0,T0_sd,T_sd,T_min]);
% Hack to match colours. Is there an easier way with colormap?
for k=1:4
  set(h1(k),"color",h1c{k});
  set(h1(k),"linestyle",hline{k});
endfor
% End of hack
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0.08, 0.24, (tp+Tz2+((tpr/2)*[-1,1]))]);
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter pass-band ", ...
              "delay (nbits=%d,ndigits=%d) : ftpl=%g,ftpu=%g,tpr=%g"], ...
             nbits,ndigits,ftpl,ftpu,tpr);
title(strt);
legend("initial","s-d",sprintf("s-d(%s)",strItoLim),"s-d(min)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_k_min_pass_delay"),"-dpdflatex");
close

% Plot dAsqdw response
h1=plot(w*0.5/pi,[dAsqdw0,dAsqdw0_sd,dAsqdw_sd,dAsqdw_min]);
% Hack to match colours. Is there an easier way with colormap?
for k=1:4
  set(h1(k),"color",h1c{k});
  set(h1(k),"linestyle",hline{k});
endfor
% End of hack
ylabel("$\\frac{d|A|^{2}}{d\\omega}$");
xlabel("Frequency");
axis([0.08, 0.24, dp+((dpr/2)*[-1,1])]);
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter pass-band ", ...
              "dAsqdw (nbits=%d,ndigits=%d) : fdpl=%g,fdpu=%g"], ...
             nbits,ndigits,fdpl,fdpu);
title(strt);
legend("initial","s-d",sprintf("s-d(%s)",strItoLim),"s-d(min)");
legend("location","south");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_k_min_pass_dAsqdw"),"-dpdflatex");
close

% Convert to transfer functions
[AA1k_min,BA1k_min,CA1k_min,DA1k_min] = ...
  schurOneMAPlatticeDoublyPipelined2Abcd(A1k_min);
[~,DA1k_min]=Abcd2tf(AA1k_min,BA1k_min,CA1k_min,DA1k_min);
[AA2k_min,BA2k_min,CA2k_min,DA2k_min] = ...
  schurOneMAPlatticeDoublyPipelined2Abcd(A2k_min);
[~,DA2k_min]=Abcd2tf(AA2k_min,BA2k_min,CA2k_min,DA2k_min);
DAaa1k_min=schurOneMAPlattice2tf(Aaa1k_min);
DAaa2k_min=schurOneMAPlattice2tf(Aaa2k_min);
Naa_min=(conv(fliplr(DAaa1k_min),DAaa2k_min) + ...
      conv(fliplr(DAaa2k_min),DAaa1k_min))/2;
Daa_min=conv(DAaa1k_min,DAaa2k_min);                        
N_min=conv((conv(fliplr(DA1k_min),DA2k_min) - ...
         conv(fliplr(DA2k_min),DA1k_min))/2,Naa_min);
D_min=conv(conv(DA1k_min,DA2k_min),Daa_min);
% Sanity check
tol=1e-10;
H2c=freqz(N_min,D_min,w);
Asq2c=abs(H2c).^2;
if max(abs(Asq_min-Asq2c)) > tol
  error("max(abs(Asq_min-Asq2c))(%g*tol) > tol",max(abs(Asq_min-Asq2c))/tol);
endif
T2c=delayz(N_min,D_min,wt);
if max(abs(T_min(ntpl:ntpu)-T2c)) > tol
  error("max(abs(T_min-T2c))(%g*tol) > tol",max(abs(T_min-T2c))/tol);
endif

% Save coefficients
print_polynomial(A1k_min,"A1k_min",nscale);
print_polynomial(A1k_min,"A1k_min",strcat(strf,"_A1k_min_coef.m"),nscale);
print_polynomial(A2k_min,"A2k_min",nscale);
print_polynomial(A2k_min,"A2k_min",strcat(strf,"_A2k_min_coef.m"),nscale);

print_polynomial(Aaa1k_min,"Aaa1k_min",nscale);
print_polynomial(Aaa1k_min,"Aaa1k_min",strcat(strf,"_Aaa1k_min_coef.m"),nscale);
print_polynomial(Aaa2k_min,"Aaa2k_min",nscale);
print_polynomial(Aaa2k_min,"Aaa2k_min",strcat(strf,"_Aaa2k_min_coef.m"),nscale);

print_polynomial(DA1k_min,"DA1k_min");
print_polynomial(DA1k_min,"DA1k_min",strcat(strf,"_DA1k_min_coef.m"));
print_polynomial(DA2k_min,"DA2k_min");
print_polynomial(DA2k_min,"DA2k_min",strcat(strf,"_DA2k_min_coef.m"));

print_polynomial(DAaa1k_min,"DAaa1k_min");
print_polynomial(DAaa1k_min,"DAaa1k_min",strcat(strf,"_DAaa1k_min_coef.m"));
print_polynomial(DAaa2k_min,"DAaa2k_min");
print_polynomial(DAaa2k_min,"DAaa2k_min",strcat(strf,"_DAaa2k_min_coef.m"));

print_polynomial(N_min,"N_min");
print_polynomial(N_min,"N_min",strcat(strf,"_N_min_coef.m"));
print_polynomial(D_min,"D_min");
print_polynomial(D_min,"D_min",strcat(strf,"_D_min_coef.m"));

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
%{
fprintf(fid,"%s_allocsd_Lim=%d %% Use Lim digit allocation\n", ...
        strf,eval(sprintf("%s_allocsd_Lim",strf)));
fprintf(fid,"%s_allocsd_Ito=%d %% Use Ito digit allocation\n", ...
        strf,eval(sprintf("%s_allocsd_Ito",strf)));
%}
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d%% Frequency points across the band\n",n);
fprintf(fid,"NA1k=%d %% All-pass filter 1 order\n",NA1k);
fprintf(fid,"NA2k=%d %% All-pass filter 2 order\n",NA2k);
fprintf(fid,"NAaa1k=%d %% Anti-aliasing all-pass filter 1 order\n",NAaa1k);
fprintf(fid,"NAaa2k=%d %% Anti-aliasing all-pass filter 2 order\n",NAaa2k);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBasl=%g %% Amplitude lower stop band peak-to-peak ripple\n",dBasl);
fprintf(fid,"dBasu=%g %% Amplitude upper stop band peak-to-peak ripple\n",dBasu);
fprintf(fid,"dBasuu=%g %% Amp. upper 2 stop band peak-to-peak ripple\n",dBasuu);
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
fprintf(fid,"dpr=%g %% Pass band dAsqdw response ripple(rad./pi)\n",dpr);
fprintf(fid,"Wdp=%g %% Pass band dAsqdw response weight\n",Wdp);
fclose(fid);

% Save results
eval(sprintf(["save %s.mat ", ...
 "%s_allocsd_Lim %s_allocsd_Ito ", ...
 "ftol ctol nbits nscale ndigits ndigits_alloc n ", ...
 "fapl fapu dBap Wap fasl fasu dBasl dBasu dBasuu Wasl Wasu ", ...
 "ftpl ftpu tp tpr Wtp fppl fppu pp ppr Wpp fdpl fdpu dp dpr Wdp ", ...
 "difference A1k0 A2k0 A1k0_sd A2k0_sd ", ...
 "A1k_sd A2k_sd A1k_min A2k_min N_min D_min"],strf,strf,strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
