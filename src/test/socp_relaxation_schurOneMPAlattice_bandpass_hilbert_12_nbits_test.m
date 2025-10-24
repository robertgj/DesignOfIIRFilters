% socp_relaxation_schurOneMPAlattice_bandpass_hilbert_12_nbits_test.m
% Copyright (C) 2025 Robert G. Jenssen

% SOCP relaxation optimisation of a Schur parallel one-multiplier allpass
% lattice bandpass filter with 12-bit signed-digit coefficients having
% an average of 3 signed-digits

test_common;

strf="socp_relaxation_schurOneMPAlattice_bandpass_hilbert_12_nbits_test"

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
ftol=1e-4
ctol=1e-5
verbose=false;

nbits=12;
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
dBap=0.2
Wap=20
dBas=37
Watl=1e-3
Watu=1e-3
Wasl=50000
Wasu=5000
ftpl=0.11
ftpu=0.19
tp=16
tpr=0.32
Wtp=2
fppl=0.11
fppu=0.19
pp=3.5    % Initial phase offset (rad./pi)
ppr=0.012 % Peak-to-peak phase ripple (rad./pi)
Wpp=20
fdpl=fapl % Pass band dAsqdw response lower edge
fdpu=fapu % Pass band dAsqdw response upper edge
dp=0      % Pass band dAsqdw response nominal value
dpr=0.6   % Pass band dAsqdw response ripple
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
rho=0.999 
dmax=0.05;
A1k0=A1k0(:);
A2k0=A2k0(:);
k0=[A1k0;A2k0];
Nk=length(k0);
k_u=rho*ones(Nk,1);
k_l=-k_u;
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
print_polynomial(A2k0_sd,"A2k0_sd",strcat(strf,"_A2k0_sd_coef.m"),nscale);
[k0_sd_Ito,k0_sdu_Ito,k0_sdl_Ito]=flt2SD(k0,nbits,ndigits_alloc);
[k0_sd_Ito_digits,k0_sd_Ito_adders]=SDadders(k0_sd_Ito,nbits);
A1k0_sd_Ito=k0_sd_Ito(RA1k);
A2k0_sd_Ito=k0_sd_Ito(RA2k);
print_polynomial(A1k0_sd_Ito,"A1k0_sd_Ito",nscale);
print_polynomial(A1k0_sd_Ito,"A1k0_sd_Ito", ...
                 strcat(strf,"_A1k0_sd_Ito_coef.m"),nscale);
print_polynomial(A2k0_sd_Ito,"A2k0_sd_Ito",nscale);
print_polynomial(A2k0_sd_Ito,"A2k0_sd_Ito", ...
                 strcat(strf,"_A2k0_sd_Ito_coef.m"),nscale);

% Find initial mean-squared errrors
Esq0=schurOneMPAlatticeEsq ...
       (A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
        difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
Esq0_sd=schurOneMPAlatticeEsq ...
          (k0_sd(RA1k),A1epsilon0,A1p0,k0_sd(RA2k),A2epsilon0,A2p0, ... 
           difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
Esq0_sd_Ito=schurOneMPAlatticeEsq ...
          (k0_sd_Ito(RA1k),A1epsilon0,A1p0,k0_sd_Ito(RA2k),A2epsilon0,A2p0, ...
           difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Define filter coefficients
k=[A1k0;A2k0];
k_active=find(k~=0);
k_u=rho*ones(size(k));
k_l=-k_u;

% Fix one coefficient at each iteration 
while ~isempty(k_active)
  
  % Find the signed-digit filter coefficients 
  [k_sd_Ito,k_sdu_Ito,k_sdl_Ito]=flt2SD(k,nbits,ndigits_alloc);
  k_sdul_Ito=k_sdu_Ito-k_sdl_Ito;
  
  % Ito et al. suggest ordering the search by max(k_sdu-k_sdl)
  [k_max,k_max_n]=max(k_sdul_Ito(k_active));
  coef_n=k_active(k_max_n);
  k_u(coef_n)=k_sdu_Ito(coef_n);
  k_l(coef_n)=k_sdl_Ito(coef_n);

  % Try to solve the current SOCP problem for the active coefficients
  try
    [nextA1k,nextA2k,slb_iter,opt_iter,func_iter,feasible] = ...
      schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                             k(RA1k),A1epsilon0,A1p0,k(RA2k),A2epsilon0,A2p0, ...
                             difference,k_u,k_l,k_active,dmax, ...
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
  nextk=[nextA1k(:);nextA2k(:)];
  alpha=(nextk(coef_n)-((k_sdu_Ito(coef_n)+k_sdl_Ito(coef_n))/2))/ ...
        (k_sdul_Ito(coef_n)/2);
  if alpha>=0
    nextk(coef_n)=k_sdu_Ito(coef_n);
  else
    nextk(coef_n)=k_sdl_Ito(coef_n);
  endif
  k=nextk;
  k_active(k_max_n)=[];
  printf("Fixed k(%d)=%13.10f\n",coef_n,k(coef_n));
  printf("k_active=[ ");printf("%d ",k_active);printf("];\n\n");

endwhile

% Coefficients (All k_min coefficients are multiples of 4/nscale!)
k_min=k;
A1k_min=k_min(RA1k);
A2k_min=k_min(RA2k);
print_polynomial(A1k_min,"A1k_min",nscale);
print_polynomial(A1k_min,"A1k_min",strcat(strf,"_A1k_min_coef.m"),nscale);
print_polynomial(A2k_min,"A2k_min",nscale);
print_polynomial(A2k_min,"A2k_min",strcat(strf,"_A2k_min_coef.m"),nscale);
% Esq
Esq_min= ...
  schurOneMPAlatticeEsq(A1k_min,A1epsilon0,A1p0,A2k_min,A2epsilon0,A2p0, ...
                        difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
printf("Esq_min=%g\n",Esq_min);
% Adders
[k_min_digits,k_min_adders]=SDadders(k_min,nbits);
printf("%d signed-digits used\n",k_min_digits);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       k_min_adders,nbits);
fid=fopen(strcat(strf,"_k_min_digits.tab"),"wt");
fprintf(fid,"$%d$",k_min_digits);
fclose(fid);
fid=fopen(strcat(strf,"_k_min_adders.tab"),"wt");
fprintf(fid,"$%d$",k_min_adders);
fclose(fid);
  
% Calculate response
Asq_k0=schurOneMPAlatticeAsq(wa,A1k0,A1epsilon0,A1p0, ...
                             A2k0,A2epsilon0,A2p0,difference);
Asq_k0_sd=schurOneMPAlatticeAsq(wa,k0_sd(RA1k),A1epsilon0,A1p0, ...
                                k0_sd(RA2k),A2epsilon0,A2p0,difference);
Asq_k0_sd_Ito=schurOneMPAlatticeAsq(wa,k0_sd_Ito(RA1k),A1epsilon0,A1p0, ...
                                    k0_sd_Ito(RA2k),A2epsilon0,A2p0,difference);
Asq_k_min=schurOneMPAlatticeAsq(wa,k_min(RA1k),A1epsilon0,A1p0, ...
                                    k_min(RA2k),A2epsilon0,A2p0,difference);

P_k0=schurOneMPAlatticeP(wp,A1k0,A1epsilon0,A1p0, ...
                         A2k0,A2epsilon0,A2p0,difference);
P_k0_sd=schurOneMPAlatticeP(wp,k0_sd(RA1k),A1epsilon0,A1p0, ...
                            k0_sd(RA2k),A2epsilon0,A2p0,difference);
P_k0_sd_Ito=schurOneMPAlatticeP(wp,k0_sd_Ito(RA1k),A1epsilon0,A1p0, ...
                                k0_sd_Ito(RA2k),A2epsilon0,A2p0,difference);
P_k_min=schurOneMPAlatticeP(wp,k_min(RA1k),A1epsilon0,A1p0, ...
                                k_min(RA2k),A2epsilon0,A2p0,difference);

T_k0=schurOneMPAlatticeT(wt,A1k0,A1epsilon0,A1p0, ...
                         A2k0,A2epsilon0,A2p0,difference);
T_k0_sd=schurOneMPAlatticeT(wt,k0_sd(RA1k),A1epsilon0,A1p0, ...
                            k0_sd(RA2k),A2epsilon0,A2p0,difference);
T_k0_sd_Ito=schurOneMPAlatticeT(wt,k0_sd_Ito(RA1k),A1epsilon0,A1p0, ...
                                k0_sd_Ito(RA2k),A2epsilon0,A2p0,difference);
T_k_min=schurOneMPAlatticeT(wt,k_min(RA1k),A1epsilon0,A1p0, ...
                                k_min(RA2k),A2epsilon0,A2p0,difference);

dAsqdw_k0=schurOneMPAlatticedAsqdw(wd,A1k0,A1epsilon0,A1p0, ...
                                   A2k0,A2epsilon0,A2p0,difference);
dAsqdw_k0_sd=schurOneMPAlatticedAsqdw(wd,k0_sd(RA1k),A1epsilon0,A1p0, ...
                                      k0_sd(RA2k),A2epsilon0,A2p0,difference);
dAsqdw_k0_sd_Ito= ...
  schurOneMPAlatticedAsqdw(wd,k0_sd_Ito(RA1k),A1epsilon0,A1p0, ...
                           k0_sd_Ito(RA2k),A2epsilon0,A2p0,difference);
dAsqdw_k_min=schurOneMPAlatticedAsqdw(wd,k_min(RA1k),A1epsilon0,A1p0, ...
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
printf("k0_sd_k_min:fDS=[ ");printf("%f ",wDS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k0_sd_k_min:DS=[ ");printf("%f ",DS');printf("]\n")

% Find maximum stop band response
rsb=[1:nasl,nasu:n];
max_sb_Asq_k0=10*log10(max(abs(Asq_k0(rsb))))
max_sb_Asq_k0_sd=10*log10(max(abs(Asq_k0_sd(rsb))))
max_sb_Asq_k0_sd_Ito=10*log10(max(abs(Asq_k0_sd_Ito(rsb))))
max_sb_Asq_k_min=10*log10(max(abs(Asq_k_min(rsb))))

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_k_min_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & %4.1f & & \\\\\n",Esq0,max_sb_Asq_k0);
fprintf(fid,"%d-bit %d-signed-digit & %8.6f & %4.1f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd,max_sb_Asq_k0_sd,k0_sd_digits,k0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(Ito) & %8.6f & %4.1f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd_Ito,max_sb_Asq_k0_sd_Ito, ...
        k0_sd_Ito_digits,k0_sd_Ito_adders);
fprintf(fid,"%d-bit %d-signed-digit(min) & %8.6f & %4.1f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_min,max_sb_Asq_k_min, ...
        k_min_digits,k_min_adders);
fclose(fid);

% Sanity check
[N_min,D_min] = schurOneMPAlattice2tf(A1k_min,A1epsilon0,A1p0, ...
                                      A2k_min,A2epsilon0,A2p0,difference);
% Hack to avoid problems in testing
N_min(find(abs(N_min)<20*eps))=0;
D_min(find(abs(D_min)<20*eps))=0;
% End of hack
print_polynomial(N_min,"N_min");
print_polynomial(N_min,"N_min",strcat(strf,"_N_min_coef.m"));
print_polynomial(D_min,"D_min");
print_polynomial(D_min,"D_min",strcat(strf,"_D_min_coef.m"));
H_min=freqz(N_min,D_min,wa);
if max(abs((abs(H_min).^2)-Asq_k_min)) > 1e4*eps
  error("max(abs((abs(H_min).^2)-Asq_k_min))(%d/eps) > 1e4*eps",
        max(abs((abs(H_min).^2)-Asq_k_min))/eps);
endif
T_min=delayz(N_min,D_min,wt);
if max(abs(T_min-T_k_min)) > 1e7*eps
  error("max(abs(T_min-T_k_min))(%d/eps) > 1e7*eps",
        max(abs(T_min-T_k_min))/eps);
endif

% Plot amplitude response
[ax,h1,h2]=plotyy(wa*0.5/pi, 10*log10([Asq_k0,Asq_k0_sd,Asq_k0_sd_Ito,Asq_k_min]), ...
                  wa*0.5/pi, 10*log10([Asq_k0,Asq_k0_sd,Asq_k0_sd_Ito,Asq_k_min]));
% Hack to match colours. Is there an easier way with colormap?
h1c=get(h1,"color");
for k=1:4
  set(h2(k),"color",h1c{k});
endfor
% End of hack
hline={"-",":","--","-."};
for k=1:4
  set(h1(k),"linestyle",hline{k});
  set(h2(k),"linestyle",hline{k});
endfor
axis(ax(1),[0 0.5 -44 -34]);
axis(ax(2),[0 0.5 -dBap 0.05]);
grid("on");
xlabel("Frequency");
ylabel(ax(1),"Amplitude(dB)");
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter ", ...
              "amplitude nbits=%d,ndigits=%d"],nbits,ndigits);
title(strt);
legend(ax(1),"initial","s-d","s-d(Ito)","s-d(min)");
legend(ax(1),"location","northeast");
legend(ax(1),"boxoff");
legend(ax(1),"left");
zticks([]);
print(strcat(strf,"_k_min_amplitude"),"-dpdflatex");
close

% Plot pass band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_k0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_Ito)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_k_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([min([fapl ftpl fppl]), max([fapu ftpu ftpu]), -dBap, 0.02]);
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter pass-band ", ...
              "amplitude nbits=%d,ndigits=%d) : fapl=%g,fapu=%g"], ...
             nbits,ndigits,fapl,fapu);
title(strt);
legend("initial","s-d","s-d(Ito)","s-d(min)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_k_min_pass_amplitude"),"-dpdflatex");
close

% Plot stop band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_k0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_Ito)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_k_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -50 -20]);
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter stop-band ", ...
              "(nbits=%d,ndigits=%d) : fasl=%g,fasu=%g"], ...
             nbits,ndigits,fasl,fasu);
title(strt);
legend("initial","s-d","s-d(Ito)","s-d(min)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_k_min_stop_amplitude"),"-dpdflatex");
close

% Plot phase response
plot(wp*0.5/pi,rem(unwrap(P_k0+(wp*tp))/pi,2),"linestyle","-", ...
     wp*0.5/pi,rem(unwrap(P_k0_sd+(wp*tp))/pi,2),"linestyle",":", ...
     wp*0.5/pi,rem(unwrap(P_k0_sd_Ito+(wp*tp))/pi,2),"linestyle","--", ...
     wp*0.5/pi,rem(unwrap(P_k_min+(wp*tp))/pi,2),"linestyle","-.");
xlabel("Frequency");
ylabel("Phase (rad./$\\pi$)");
axis([min([fapl ftpl fppl]), max([fapu ftpu ftpu]), 1.5+(0.004*[-1,1])]);
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter pass-band ", ...
              "phase (nbits=%d,ndigits=%d) : fppl=%g,fppu=%g"],
             nbits,ndigits,fppl,fppu);
title(strt);
legend("initial","s-d","s-d(Ito)","s-d(min)");
legend("location","north");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_k_min_pass_phase"),"-dpdflatex");
close

% Plot delay response
plot(wt*0.5/pi,T_k0,"linestyle","-", ...
     wt*0.5/pi,T_k0_sd,"linestyle",":", ...
     wt*0.5/pi,T_k0_sd_Ito,"linestyle","--", ...
     wt*0.5/pi,T_k_min,"linestyle","-.");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([min([fapl ftpl fppl]),max([fapu ftpu ftpu]),(tp+(0.15*[-1,1]))]);
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter pass-band ", ...
              "delay (nbits=%d,ndigits=%d) : ftpl=%g,ftpu=%g"], ...
             nbits,ndigits,ftpl,ftpu);
title(strt);
legend("initial","s-d","s-d(Ito)","s-d(min)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_k_min_pass_delay"),"-dpdflatex");
close

% Plot dAsqdw response
plot(wd*0.5/pi,dAsqdw_k0,"linestyle","-", ...
     wd*0.5/pi,dAsqdw_k0_sd,"linestyle",":", ...
     wd*0.5/pi,dAsqdw_k0_sd_Ito,"linestyle","--", ...
     wd*0.5/pi,dAsqdw_k_min,"linestyle","-.");
xlabel("Frequency");
ylabel("dAsqdw");
axis([fdpl, fdpu, dp+(dpr*[-1,1])]);
strt=sprintf(["Parallel allpass lattice bandpass Hilbert filter pass-band ", ...
              "dAsqdw (nbits=%d,ndigits=%d) : fdpl=%g,fdpu=%g"], ...
             nbits,ndigits,fdpl,fdpu);
title(strt);
legend("initial","s-d","s-d(Ito)","s-d(min)");
legend("location","south");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_k_min_pass_dAsqdw"),"-dpdflatex");
close

% Pole-zero plot
zplane(qroots(N_min),qroots(D_min));
title("Parallel one-multplier allpass lattice bandpass filter");
zticks([]);
print(strcat(strf,"_k_min_pz"),"-dpdflatex");
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
 "ftol ctol nbits nscale ndigits ndigits_alloc n ", ...
 "fapl fapu dBap Wap fasl fasu dBas Wasl Wasu ", ...
 "ftpl ftpu tp tpr Wtp fppl fppu pp ppr Wpp fdpl fdpu dp dpr Wdp ", ...
 "A1k0 A1epsilon0 A1p0 A2k0 A2epsilon0 A2p0 difference ", ...
 "A1k0_sd_Ito A2k0_sd_Ito A1k_min A2k_min N_min D_min"],strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
