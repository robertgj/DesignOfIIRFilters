% sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

% SDP relaxation optimisation of a Schur parallel one-multiplier allpass
% lattice bandpass filter with 13-bit signed-digit coefficients having
% an average of 3 signed-digits allocated by the algorithm of Ito et al.

test_common;

strf="sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test"

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
ftol=1e-4
ctol=1e-5
verbose=false;

rho=0.999 
dmax=0.05;

nbits=13;
nscale=2^(nbits-1);
ndigits=3;

%
% Band-pass filter specification for parallel all-pass filters
%
difference=true
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=0.15
Wap=20
dBas=36
Watl=1e-3
Watu=1e-3
Wasl=50000
Wasu=5000
ftpl=0.11
ftpu=0.19
tp=16
tpr=0.16
Wtp=2
fppl=0.11
fppu=0.19
pp=3.5    % Initial phase offset (rad./pi)
ppr=0.004 % Peak-to-peak phase ripple (rad./pi)
Wpp=20
fdpl=fapl % Pass band dAsqdw response lower edge
fdpu=fapu % Pass band dAsqdw response upper edge
dp=0      % Pass band dAsqdw response nominal value
dpr=1     % Pass band dAsqdw response ripple
Wdp=0.001 % Pass band dAsqdw response weight

%
% Initial coefficients
%
schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A1k_coef;
schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A1epsilon_coef;
schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A1p_coef;
A1k0=A1k;
A1epsilon0=A1epsilon;
A1p0=A1p;
A1p_ones = ones(size(A1p0));
print_polynomial(A1k0,"A1k0");
printf("A1epsilon0=[ ");printf("%d ",A1epsilon0);printf("]';\n");
clear A1k A1epsilon A1p;

schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A2k_coef;
schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A2epsilon_coef;
schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A2p_coef;
A2k0=A2k;
A2epsilon0=A2epsilon;
A2p0=A2p;
A2p_ones = ones(size(A2p0));
print_polynomial(A2k0,"A2k0");
printf("A2epsilon0=[ ");printf("%d ",A2epsilon0);printf("]';\n");
clear A2k A2epsilon A2p;

% Initialise coefficient range vectors
NA1k=length(A1k0);
NA2k=length(A2k0);
RA1k=1:NA1k;
RA2k=(NA1k+1):(NA1k+NA2k);

%
% Frequency vectors
%
n=1000;
wa=(0:(n-1))'*pi/n;

% Desired squared magnitude response
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

% Desired pass-band group delay response
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
wt=wa(ntpl:ntpu);
Td=tp*ones(length(wt),1);
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(length(wt),1);

% Desired pass-band phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=wa(nppl:nppu);
Pd=(pp*pi)-(tp*wp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(nppu-nppl+1,1);

% Desired pass-band dAsqdw response
if 1
  ndpl=floor(n*fdpl/0.5)+1;
  ndpu=ceil(n*fdpu/0.5)+1;
  wd=wa(ndpl:ndpu);
  Dd=dp*ones(length(wd),1);
  Ddu=Dd+(dpr/2);
  Ddl=Dd-(dpr/2);
  Wd=Wdp*ones(length(wd),1);
else
  wd=[];Dd=[];Ddu=[];Ddl=[];Wd=[];
endif

% Sanity checks
nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napl+1,napu-1,napu,napu+1, ...
       nasu-1,nasu,nasu+1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");
nchkt=[ntpl-1,ntpl,ntpl+1,ntpu-1,ntpu,ntpu+1];
printf("0.5*wa(nchkt)'/pi=[ ");printf("%6.4g ",0.5*wa(nchkt)'/pi);printf("];\n");
nchkp=[nppl-1,nppl,nppl+1,nppu-1,nppu,nppu+1];
printf("0.5*wa(nchkp)'/pi=[ ");printf("%6.4g ",0.5*wa(nchkp)'/pi);printf("];\n");

% Constraints on the coefficients
A1k0=A1k0(:);
A2k0=A2k0(:);
k0=[A1k0;A2k0];
Nk=length(k0);
k0_u=rho*ones(Nk,1);
k0_l=-k0_u;
k0_active=find((k0)~=0);

% Exact error
Esq0=schurOneMPAlatticeEsq(A1k0,A1epsilon0,A1p_ones, ...
                           A2k0,A2epsilon0,A2p_ones, ...
                           difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Allocate digits
ndigits_alloc=schurOneMPAlattice_allocsd_Ito ...
                (nbits,ndigits,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                 difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
A1k_allocsd_digits=int16(ndigits_alloc(RA1k));
A2k_allocsd_digits=int16(ndigits_alloc(RA2k));
printf("A1k_allocsd_digits=[ ");
printf("%2d ",A1k_allocsd_digits);printf("]';\n");
print_polynomial(A1k_allocsd_digits,"A1k_allocsd_digits", ...
                 strcat(strf,"_A1k_allocsd_digits.m"),"%2d");
printf("A2k_allocsd_digits=[ ");
printf("%2d ",A2k_allocsd_digits);printf("]';\n");
print_polynomial(A2k_allocsd_digits,"A2k_allocsd_digits", ...
                 strcat(strf,"_A2k_allocsd_digits.m"),"%2d");

% Find the signed-digit approximations to k0
[k0_sd,k0_sdu,k0_sdl]=flt2SD(k0,nbits,ndigits);
[k0_sd_digits,k0_sd_adders]=SDadders(k0_sd,nbits);
A1k0_sd=k0_sd(RA1k);
A2k0_sd=k0_sd(RA2k);
print_polynomial(A1k0_sd,"A1k0_sd",nscale);
print_polynomial(A1k0_sd,"A1k0_sd",strcat(strf,"_A1k0_sd_coef.m"),nscale);
print_polynomial(A2k0_sd,"A2k0_sd",nscale);
print_polynomial(A2k0_sd,"A2k0_sd",strcat(strf,"_A2k0_Ito_coef.m"),nscale);
[k0_Ito,k0_Ito_sdu,k0_Ito_sdl]=flt2SD(k0,nbits,ndigits_alloc);
[k0_Ito_digits,k0_Ito_adders]=SDadders(k0_Ito,nbits);
A1k0_Ito=k0_Ito(RA1k);
A2k0_Ito=k0_Ito(RA2k);
print_polynomial(A1k0_Ito,"A1k0_Ito",nscale);
print_polynomial(A1k0_Ito,"A1k0_Ito",strcat(strf,"_A1k0_Ito_coef.m"),nscale);
print_polynomial(A2k0_Ito,"A2k0_Ito",nscale);
print_polynomial(A2k0_Ito,"A2k0_Ito",strcat(strf,"_A2k0_Ito_coef.m"),nscale);

% Find initial mean-squared errrors
Esq0=schurOneMPAlatticeEsq ...
       (A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
        difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
Esq0_sd=schurOneMPAlatticeEsq ...
          (A1k0_sd,A1epsilon0,A1p0,A2k0_sd,A2epsilon0,A2p0, ... 
           difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
Esq0_Ito=schurOneMPAlatticeEsq ...
          (A1k0_Ito,A1epsilon0,A1p0,A2k0_Ito,A2epsilon0,A2p0, ...
           difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Solve the SDP problem with SeDuMi for all coefficients simultaneously
k0_Ito_delta=(k0_Ito_sdu-k0_Ito_sdl)/2;
k0_Ito_x=(k0_Ito_sdu+k0_Ito_sdl)/2;
k0_Ito_active=find((k0_Ito_x)~=0);
[A1k0_sdp,A2k0_sdp,sdp_iter,func_iter,feasible] = ...
  schurOneMPAlattice_sdp_mmse ...
    ([], ...
     k0_Ito_x(RA1k),A1epsilon0,A1p0,k0_Ito_x(RA2k),A2epsilon0,A2p0, ...
     difference, ...
     k0_Ito_sdu,k0_Ito_sdl,k0_Ito_active,k0_Ito_delta,...
     wa,Asqd,Asqdu,Asqdl,Wa, ...
     wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd,...
     maxiter,ftol,ctol,verbose);if feasible==false
  error("schurOneMPAlattice_sdp_mmse failed!");
endif
k0_sdp=[A1k0_sdp(:);A2k0_sdp];
[k0_sdp_digits,k0_sdp_adders]=SDadders(k0_sdp,nbits);
print_polynomial(A1k0_sdp,"A1k0_sdp",nscale);
print_polynomial(A1k0_sdp,"A1k0_sdp",strcat(strf,"_A1k0_sdp_coef.m"),nscale);
print_polynomial(A2k0_sdp,"A2k0_sdp",nscale);
print_polynomial(A2k0_sdp,"A2k0_sdp",strcat(strf,"_A2k0_sdp_coef.m"),nscale);

% SDP signed-digit MMSE error
Esq0_sdp=schurOneMPAlatticeEsq ...
              (A1k0_sdp,A1epsilon0,A1p0,A2k0_sdp,A2epsilon0,A2p0, ...
               difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Find coefficients with successive relaxation
k=zeros(size(k0));
k(k0_Ito_active)=k0(k0_Ito_active);
k_active=k0_Ito_active;
k_hist=zeros(length(k_active));
k_active_max_n_hist=[];

% Fix one coefficient at each iteration 
while 1
  
  % Find the signed-digit filter coefficients 
  [k_sd,k_sdu,k_sdl]=flt2SD(k,nbits,ndigits_alloc);
  
  % Find the SDP solution for the current coefficients
  k_sdul=k_sdu-k_sdl;
  k_sd_delta=k_sdul/2;
  k_active=find((k_sd_delta)~=0);
  k_sd_x=k;
  k_sd_x(k_active)=(k_sdu(k_active)+k_sdl(k_active))/2;
  [A1k_sdp,A2k_sdp,socp_iter,func_iter,feasible] = ...
    schurOneMPAlattice_sdp_mmse ...
      ([], ...
       k_sd_x(RA1k),A1epsilon0,A1p0,k_sd_x(RA2k),A2epsilon0,A2p0, ...
       difference, ...
       k_sdu,k_sdl,k_active,k_sd_delta, ...
       wa,Asqd,Asqdu,Asqdl,Wa, ...
       wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
       maxiter,ftol,ctol,verbose);
  if feasible==false
    error("schurOneMPAlattice_sdp_mmse failed!");
  endif

  % Ito et al. suggest ordering the search by max(k_sdu-k_sdl)
  [k_max,k_max_n]=max(k_sdul(k_active));
  coef_n=k_active(k_max_n);

  % Fix the coefficient with the largest k_sdul to the SDP value
  k_sdp=[A1k_sdp(:);A2k_sdp(:)];
  k(coef_n)=k_sdp(coef_n);
  k_active_max_n_hist=[k_active_max_n_hist,k_active(k_max_n)]
  k_hist(:,length(k_active_max_n_hist))=k;
  k_active(k_max_n)=[];
  printf("\nFixed k(%d)=%g/%d\n",coef_n,k(coef_n)*nscale,nscale);
  printf("k=[ ");printf("%g ",k'*nscale);printf("]/%d;\n",nscale);
  printf("k_active=[ ");printf("%d ",k_active);printf("];\n\n");
  
  % Check if done
  if length(k_active)==0
    k_min=k;
    break;
  endif
  
  % Relaxation: try to solve the SOCP problem for the active coefficients
  try
    [nextA1k,nextA2k,slb_iter,opt_iter,func_iter,feasible] = ...
       schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                              k(RA1k),A1epsilon0,A1p0, ...
                              k(RA2k),A2epsilon0,A2p0, ...
                              difference, ...
                              k0_u,k0_l,k_active,dmax, ...
                              wa,Asqd,Asqdu,Asqdl,Wa, ...
                              wt,Td,Tdu,Tdl,Wt, ...
                              wp,Pd,Pdu,Pdl,Wp, ...
                              wd,Dd,Ddu,Ddl,Wd, ...
                              maxiter,ftol,ctol,verbose);
    k=[nextA1k(:);nextA2k(:)];
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

endwhile

% Adders
[k_min_digits,k_min_adders]=SDadders(k_min,nbits);
printf("%d signed-digits used\n",k_min_digits);
fid=fopen(strcat(strf,"_k_min_digits.tab"),"wt");
fprintf(fid,"$%d$",k_min_digits);
fclose(fid);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       k_min_adders,nbits);
fid=fopen(strcat(strf,"_k_min_adders.tab"),"wt");
fprintf(fid,"$%d$",k_min_adders);
fclose(fid);
% Coefficients
A1k_min=k_min(RA1k);
A2k_min=k_min(RA2k);
print_polynomial(A1k_min,"A1k_min",nscale);
print_polynomial(A1k_min,"A1k_min", ...
                 strcat(strf,"_A1k_min_coef.m"),nscale);
print_polynomial(A2k_min,"A2k_min",nscale);
print_polynomial(A2k_min,"A2k_min", ...
                 strcat(strf,"_A2k_min_coef.m"),nscale);

% k_min signed-digit MMSE error
Esq_min=schurOneMPAlatticeEsq ...
          (A1k_min,A1epsilon0,A1p0,A2k_min,A2epsilon0,A2p0, ...
           difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
printf("Esq_min=%g\n",Esq_min);

% Calculate response
Asq_k0=schurOneMPAlatticeAsq(wa,A1k0,A1epsilon0,A1p0, ...
                             A2k0,A2epsilon0,A2p0,difference);
Asq_k0_sd=schurOneMPAlatticeAsq(wa,k0_sd(RA1k),A1epsilon0,A1p0, ...
                                k0_sd(RA2k),A2epsilon0,A2p0,difference);
Asq_k0_Ito=schurOneMPAlatticeAsq(wa,k0_Ito(RA1k),A1epsilon0,A1p0, ...
                                    k0_Ito(RA2k),A2epsilon0,A2p0,difference);
Asq_k0_sdp=schurOneMPAlatticeAsq(wa,k0_sdp(RA1k),A1epsilon0,A1p0, ...
                                    k0_sdp(RA2k),A2epsilon0,A2p0,difference);
Asq_k_min=schurOneMPAlatticeAsq(wa,k_min(RA1k),A1epsilon0,A1p0, ...
                                    k_min(RA2k),A2epsilon0,A2p0,difference);

T_k0=schurOneMPAlatticeT(wt,A1k0,A1epsilon0,A1p0, ...
                         A2k0,A2epsilon0,A2p0,difference);
T_k0_sd=schurOneMPAlatticeT(wt,k0_sd(RA1k),A1epsilon0,A1p0, ...
                            k0_sd(RA2k),A2epsilon0,A2p0,difference);
T_k0_Ito=schurOneMPAlatticeT(wt,k0_Ito(RA1k),A1epsilon0,A1p0, ...
                                k0_Ito(RA2k),A2epsilon0,A2p0,difference);
T_k0_sdp=schurOneMPAlatticeT(wt,k0_sdp(RA1k),A1epsilon0,A1p0, ...
                                k0_sdp(RA2k),A2epsilon0,A2p0,difference);
T_k_min=schurOneMPAlatticeT(wt,k_min(RA1k),A1epsilon0,A1p0, ...
                                k_min(RA2k),A2epsilon0,A2p0,difference);

P_k0=schurOneMPAlatticeP(wp,A1k0,A1epsilon0,A1p0, ...
                         A2k0,A2epsilon0,A2p0,difference);
P_k0_sd=schurOneMPAlatticeP(wp,k0_sd(RA1k),A1epsilon0,A1p0, ...
                            k0_sd(RA2k),A2epsilon0,A2p0,difference);
P_k0_Ito=schurOneMPAlatticeP(wp,k0_Ito(RA1k),A1epsilon0,A1p0, ...
                                k0_Ito(RA2k),A2epsilon0,A2p0,difference);
P_k0_sdp=schurOneMPAlatticeP(wp,k0_sdp(RA1k),A1epsilon0,A1p0, ...
                                k0_sdp(RA2k),A2epsilon0,A2p0,difference);
P_k_min=schurOneMPAlatticeP(wp,k_min(RA1k),A1epsilon0,A1p0, ...
                                k_min(RA2k),A2epsilon0,A2p0,difference);

dAsqdw_k0=schurOneMPAlatticedAsqdw(wd,A1k0,A1epsilon0,A1p0, ...
                                   A2k0,A2epsilon0,A2p0,difference);
dAsqdw_k0_sd=schurOneMPAlatticedAsqdw(wd,k0_sd(RA1k),A1epsilon0,A1p0, ...
                                      k0_sd(RA2k),A2epsilon0,A2p0,difference);
dAsqdw_k0_Ito=schurOneMPAlatticedAsqdw ...
                   (wd,k0_Ito(RA1k),A1epsilon0,A1p0, ...
                    k0_Ito(RA2k),A2epsilon0,A2p0,difference);
dAsqdw_k0_sdp=schurOneMPAlatticedAsqdw ...
                   (wd,k0_sdp(RA1k),A1epsilon0,A1p0, ...
                    k0_sdp(RA2k),A2epsilon0,A2p0,difference);
dAsqdw_k_min=schurOneMPAlatticedAsqdw ...
                   (wd,k_min(RA1k),A1epsilon0,A1p0, ...
                    k_min(RA2k),A2epsilon0,A2p0,difference);

% Amplitude and delay at local peaks
vAl=local_max(Asqdl-Asq_k_min);
vAu=local_max(Asq_k_min-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,end])]);
AsqS=schurOneMPAlatticeAsq(wAsqS,k_min(RA1k),A1epsilon0,A1p0, ...
                           k_min(RA2k),A2epsilon0,A2p0,difference);
printf("k_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

vTl=local_max(Tdl-T_k_min);
vTu=local_max(T_k_min-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
TS=schurOneMPAlatticeT(wTS,k_min(RA1k),A1epsilon0,A1p0, ...
                       k_min(RA2k),A2epsilon0,A2p0,difference);
printf("k_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:TS=[ ");printf("%f ",TS');printf("] (Samples)\n");

vPl=local_max(Pdl-P_k_min);
vPu=local_max(P_k_min-Pdu);
wPS=sort(unique([wp(vPl);wp(vPu);wp([1,end])]));
PS=schurOneMPAlatticeP(wPS,k_min(RA1k),A1epsilon0,A1p0, ...
                       k_min(RA2k),A2epsilon0,A2p0,difference);
printf("k_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:PS=[ ");printf("%f ",mod((PS+(wPS*tp))'/pi,2));
printf("] (rad./pi)\n");

vDl=local_max(Ddl-dAsqdw_k_min);
vDu=local_max(dAsqdw_k_min-Ddu);
wDS=sort(unique([wd(vDl);wd(vDu);wd([1,end])]));
DS=schurOneMPAlatticedAsqdw(wDS,k_min(RA1k),A1epsilon0,A1p_ones, ...
                            k_min(RA2k),A2epsilon0,A2p_ones,difference);
printf("k0_sd_kmin:fDS=[ ");printf("%f ",wDS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k0_sd_kmin:DS=[ ");printf("%f ",DS');printf("]\n")

% Find maximum stop band response
rsb=[1:nasl,nasu:n];
max_sb_Asq_k0=10*log10(max(abs(Asq_k0(rsb))))
max_sb_Asq_k0_sd=10*log10(max(abs(Asq_k0_sd(rsb))))
max_sb_Asq_k0_Ito=10*log10(max(abs(Asq_k0_Ito(rsb))))
max_sb_Asq_k0_sdp=10*log10(max(abs(Asq_k0_sdp(rsb))))
max_sb_Asq_k_min=10*log10(max(abs(Asq_k_min(rsb))))

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & %4.1f & & \\\\\n",Esq0,max_sb_Asq_k0);
fprintf(fid,"%d-bit %d-signed-digit & %8.6f & %4.1f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd,max_sb_Asq_k0_sd,k0_sd_digits,k0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(Ito) & %8.6f & %4.1f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_Ito,max_sb_Asq_k0_Ito,k0_Ito_digits,k0_Ito_adders);
fprintf(fid,"%d-bit %d-signed-digit(SDP) & %8.6f & %4.1f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sdp,max_sb_Asq_k0_sdp,k0_sdp_digits,k0_sdp_adders);
fprintf(fid,"%d-bit %d-signed-digit(min) & %8.6f & %4.1f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_min,max_sb_Asq_k_min,k_min_digits,k_min_adders);
fclose(fid);

% Plot stop band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_k0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_Ito)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sdp)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -50 -20]);
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter stop-band ", ...
 "(nbits=%d,ndigits=%d) : fasl=%g,fasu=%g"],nbits,ndigits,fasl,fasu);
title(strt);
legend("initial","s-d","s-d(Ito)","s-d(SDP)","s-d(min)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot pass band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_k0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_Ito)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sdp)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([min([fapl ftpl fppl]), max([fapu ftpu ftpu]), -dBap, 0.02]);
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter pass-band ", ...
 "amplitude nbits=%d,ndigits=%d) : fapl=%g,fapu=%g"],nbits,ndigits,fapl,fapu);
title(strt);
legend("initial","s-d","s-d(Ito)","s-d(SDP)","s-d(min)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_pass"),"-dpdflatex");
close

% Plot delay response
plot(wt*0.5/pi,T_k0,"linestyle","-", ...
     wt*0.5/pi,T_k0_sd,"linestyle",":", ...
     wt*0.5/pi,T_k0_Ito,"linestyle","--", ...
     wt*0.5/pi,T_k0_sdp,"linestyle","-", ...
     wt*0.5/pi,T_k_min,"linestyle","-.");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([min([fapl ftpl fppl]),max([fapu ftpu ftpu]),(tp+(tpr*[-1,1]))]);
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter pass-band ", ...
              "delay (nbits=%d,ndigits=%d) : ftpl=%g,ftpu=%g"], ...
             nbits,ndigits,ftpl,ftpu);
title(strt);
legend("initial","s-d","s-d(Ito)","s-d(SDP)","s-d(min)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Plot phase response
plot(wp*0.5/pi,((P_k0+(wp*tp))/pi)-pp,"linestyle","-", ...
     wp*0.5/pi,((P_k0_sd+(wp*tp))/pi)-pp,"linestyle",":", ...
     wp*0.5/pi,((P_k0_Ito+(wp*tp))/pi)-pp,"linestyle","--", ...
     wp*0.5/pi,((P_k0_sdp+(wp*tp))/pi)-pp,"linestyle","-", ...
     wp*0.5/pi,((P_k_min+(wp*tp))/pi)-pp,"linestyle","-.");
xlabel("Frequency");
ylabel("Phase error(rad./$\\pi$)");
axis([min([fapl ftpl fppl]), max([fapu ftpu ftpu]), (ppr/2)*[-1,1]]);
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter pass-band ", ...
              "phase (nbits=%d,ndigits=%d) : fppl=%g,fppu=%g"], ...
             nbits,ndigits,fppl,fppu);
title(strt);
legend("initial","s-d","s-d(Ito)","s-d(SDP)","s-d(min)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_phase"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d%% Frequency points across the band\n",n);
fprintf(fid,"NA1k=%d %% All-pass filter a order\n",NA1k);
fprintf(fid,"NA2k=%d %% All-pass filter b order\n",NA2k);
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
eval(sprintf(["save %s.mat ", ...
 "ftol ctol nbits nscale ndigits ndigits_alloc n ", ...
 "fapl fapu dBap Wap fasl fasu dBas Wasl Wasu ", ...
 "ftpl ftpu tp tpr Wtp fppl fppu pp ppr Wpp fdpl fdpu dp dpr Wdp ", ...
 "A1k0 A1epsilon0 A1p0 A2k0 A2epsilon0 A2p0 ", ...
 "A1k0_Ito A2k0_Ito A1k0_sdp A2k0_sdp A1k_min A2k_min"],strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
