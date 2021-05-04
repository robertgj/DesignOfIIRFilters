% sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test.m
% Copyright (C) 2017-2021 Robert G. Jenssen

% SDP relaxation optimisation of a Schur parallel one-multiplier allpass
% lattice bandpass filter with 12-bit signed-digit coefficients having
% an average of 3 signed-digits

test_common;

delete("sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test.diary");
delete ...
  ("sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test.diary.tmp");
diary sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test.diary.tmp

tic;

maxiter=2000
verbose=false;
tol=1e-5;
ctol=tol/10;
strf="sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test";

%
% Initial filters from tarczynski_parallel_allpass_bandpass_hilbert_test.m
%
D1_0 = [  1.0000000000,  -1.3420348529,   0.9476408004,   0.8924339392, ... 
         -1.9566456567,   1.7230582345,  -0.3125109409,  -0.6221973493, ... 
          0.7605942655,  -0.3624502969,   0.0926731060 ]';
D2_0 = [  1.0000000000,  -1.9568937354,   1.2936834023,   1.1283899984, ... 
         -2.6900919871,   2.1584733783,  -0.3119350555,  -0.8689577257, ... 
          0.9367692460,  -0.4306409818,   0.1000235909 ]';

% SeDuMi fails if p is all ones!!
[A1k0,A1epsilon0,A1p0,~] = tf2schurOneMlattice(flipud(D1_0),D1_0);
[A2k0,A2epsilon0,A2p0,~] = tf2schurOneMlattice(flipud(D2_0),D2_0);
          
%
% Band-pass filter specification for parallel all-pass filters
%
tol=1e-4
ctol=1e-6
difference=true
rho=0.999 
ma=length(A1k0)
mb=length(A2k0)
fasl=0.05
fapl=0.12
fapu=0.18
fasu=0.25
dBap=0.1
Wap=1
Watl=1e-3
Watu=1e-3
dBas=35
Wasl=2000
Wasu=2000
ftpl=0.12
ftpu=0.18
td=16
tdr=0.2
Wtp=2
fppl=0.12
fppu=0.18
pd=3.5 % Initial phase offset in multiples of pi radians
pdr=0.03 % Peak-to-peak phase ripple in multiples of pi radians
Wpp=500

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
Td=td*ones(size(wt),1);
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wt=Wtp*ones(size(wt),1);

% Desired pass-band phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=wa(nppl:nppu);
Pd=(pd*pi)-(td*wp);
Pdu=Pd+(pdr*pi/2);
Pdl=Pd-(pdr*pi/2);
Wp=Wpp*ones(nppu-nppl+1,1);

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

% Relative errors
EsqA0sl=schurOneMPAlatticeEsq ...
         (A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference, ...
          wa,Asqd,[ones(nasl,1);zeros(n-nasl,1)], ...
          wt,Td,zeros(size(wt)), ...
          wp,Pd,zeros(size(wp)))
EsqA0p=schurOneMPAlatticeEsq ...
         (A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference, ...
          wa,Asqd,[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)], ...
          wt,Td,zeros(size(wt)), ...
          wp,Pd,zeros(size(wp)))
EsqA0su=schurOneMPAlatticeEsq ...
         (A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference, ...
          wa,Asqd,[zeros(nasu-1,1);ones(n-nasu+1,1)], ...
          wt,Td,zeros(size(wt)), ...
          wp,Pd,zeros(size(wp)))
EsqT0=schurOneMPAlatticeEsq ...
        (A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference, ...
         wa,Asqd,zeros(size(wa)), ...
         wt,Td,ones(size(wt)), ...
         wp,Pd,zeros(size(wp)))
EsqP0=schurOneMPAlatticeEsq ...
        (A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference, ...
         wa,Asqd,zeros(size(wa)), ...
         wt,Td,zeros(size(wt)), ...
         wp,Pd,ones(size(wp)))

% Constraints on the coefficients
dmax=0.05;
A1k0=A1k0(:);
A2k0=A2k0(:);
NA1k=length(A1k0);
NA2k=length(A2k0);
k0=[A1k0;A2k0];
Nk=length(k0);
Rk=1:Nk;
RA1k=1:NA1k;
RA2k=NA1k+RA1k;
k_u=rho*ones(Nk,1);
k_l=-k_u;
k0_active=find((k0)~=0);

% Allocate digits
nbits=13;
nscale=2^(nbits-1);
ndigits=3;
ndigits_alloc= ...
  schurOneMPAlattice_allocsd_Lim(nbits,ndigits, ...
                                 A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                                 difference, ...
                                 wa,Asqd,ones(size(wa)), ...
                                 wt,Td,ones(size(wt)), ...
                                 wp,Pd,ones(size(wp)));

% Find the signed-digit approximations to k0
[k0_sd,k0_sdu,k0_sdl]=flt2SD(k0,nbits,ndigits);
[k0_digits_sd,k0_adders_sd]=SDadders(k0_sd,nbits);
[k0_sd_Lim,k0_sdu_Lim,k0_sdl_Lim]=flt2SD(k0,nbits,ndigits_alloc);
[k0_digits_sd_Lim,k0_adders_sd_Lim]=SDadders(k0_sd_Lim,nbits);
print_polynomial(k0_sd_Lim(RA1k),"A1k0_sd_Lim",nscale);
print_polynomial(k0_sd_Lim(RA1k),"A1k0_sd_Lim", ...
                 strcat(strf,"_A1k0_sd_Lim_coef.m"),nscale);
print_polynomial(k0_sd_Lim(RA2k),"A2k0_sd_Lim",nscale);
print_polynomial(k0_sd_Lim(RA2k),"A2k0_sd_Lim", ...
                 strcat(strf,"_A2k0_sd_Lim_coef.m"),nscale);

% Find initial mean-squared errrors
Esq0=schurOneMPAlatticeEsq(A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                           difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
Esq0_sd=schurOneMPAlatticeEsq(k0_sd(RA1k),A1epsilon0,A1p0, ...
                              k0_sd(RA2k),A2epsilon0,A2p0, ... 
                              difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
Esq0_sd_Lim=schurOneMPAlatticeEsq(k0_sd_Lim(RA1k),A1epsilon0,A1p0, ...
                                  k0_sd_Lim(RA2k),A2epsilon0,A2p0, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Define filter coefficients
k0_sd_delta=(k0_sdu_Lim-k0_sdl_Lim)/2;
k0_sd_x=(k0_sdu_Lim+k0_sdl_Lim)/2;
k0_sd_x_active=find((k0_sd_x)~=0);
[Esq0_sd_x,gradEsq0_sd_x]= ...
  schurOneMPAlatticeEsq(k0_sd_x(RA1k),A1epsilon0,A1p0, ...
                        k0_sd_x(RA2k),A2epsilon0,A2p0, ...
                        difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Solve the SDP problem with SeDuMi
[A1k0_sd_sdp,A2k0_sd_sdp,socp_iter,func_iter,feasible] = ...
  sdp_relaxation_schurOneMPAlattice_mmse([], ...
                              k0_sd_x(RA1k),A1epsilon0,A1p0, ...
                              k0_sd_x(RA2k),A2epsilon0,A2p0, ...
                              difference,k_u,k_l,k0_sd_x_active,k0_sd_delta, ...
                              wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                              wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose);
if feasible==false
  error("sdp_relaxation_schurOneMPAlattice_mmse failed!");
endif
print_polynomial(A1k0_sd_sdp,"A1k0_sd_sdp",nscale);
print_polynomial(A1k0_sd_sdp,"A1k0_sd_sdp", ...
                 strcat(strf,"_A1k0_sd_sdp_coef.m"),nscale);
print_polynomial(A2k0_sd_sdp,"A2k0_sd_sdp",nscale);
print_polynomial(A2k0_sd_sdp,"A2k0_sd_sdp", ...
                 strcat(strf,"_A2k0_sd_sdp_coef.m"),nscale);
k0_sd_sdp=[A1k0_sd_sdp(:);A2k0_sd_sdp];
[k0_digits_sd_sdp,k0_adders_sd_sdp]=SDadders(k0_sd_sdp,nbits);
Esq0_sd_sdp=schurOneMPAlatticeEsq(A1k0_sd_sdp,A1epsilon0,A1p0, ...
                                  A2k0_sd_sdp,A2epsilon0,A2p0, ...
                                  difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Find coefficients with successive relaxation
k=zeros(size(k0));
k(k0_sd_x_active)=k0(k0_sd_x_active);
k_active=k0_sd_x_active;

% Fix one coefficient at each iteration 
while 1
  
  % Find the signed-digit filter coefficients 
  [k_sd_Lim,k_sdu_Lim,k_sdl_Lim]=flt2SD(k,nbits,ndigits_alloc);
  k_sdul_Lim=k_sdu_Lim-k_sdl_Lim;
  
  % Run the SeDuMi problem to find the SDP solution for the current coefficients
  k_sd_delta=k_sdul_Lim/2;
  k_sd_x=(k_sdu_Lim+k_sdl_Lim)/2;
  k_sd_x_active=find((k_sd_x)~=0);
  [A1k_sd_sdp,A2k_sd_sdp,socp_iter,func_iter,feasible] = ...
    sdp_relaxation_schurOneMPAlattice_mmse([], ...
                                k_sd_x(RA1k),A1epsilon0,A1p0, ...
                                k_sd_x(RA2k),A2epsilon0,A2p0, ...
                                difference,k_u,k_l,k_sd_x_active,k_sd_delta, ...
                                wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                                wp,Pd,Pdu,Pdl,Wp,maxiter,tol,verbose);
  if feasible==false
    error("sdp_relaxation_schurOneMPAlattice_mmse failed!");
  endif

  % Ito et al. suggest ordering the search by max(k_sdu-k_sdl)
  [k_max,k_max_n]=max(k_sdul_Lim(k_active));
  coef_n=k_active(k_max_n);

  % Fix the coefficient with the largest k_sdul to the SDP value
  k_sd_sdp=[A1k_sd_sdp(:);A2k_sd_sdp(:)];
  k(coef_n)=k_sd_sdp(coef_n);
  k_active(k_max_n)=[];
  printf("\nFixed k(%d)=%g/%d\n",coef_n,k(coef_n)*nscale,nscale);
  printf("k=[ ");printf("%g ",k'*nscale);printf("]/%d;\n",nscale);
  printf("k_active=[ ");printf("%d ",k_active);printf("];\n\n");
  
  % Check if done
  if length(k_active)==0
    k0_sd_min=k;
    % Adders
    [k0_digits_sd_min,k0_adders_sd_min]=SDadders(k0_sd_min,nbits);
    printf("%d signed-digits used\n",k0_digits_sd_min);
    printf("%d %d-bit adders used for coefficient multiplications\n",
           k0_adders_sd_min,nbits);
    fid=fopen(strcat(strf,"_kmin_digits.tab"),"wt");
    fprintf(fid,"$%d$",k0_digits_sd_min);
    fclose(fid);
    fid=fopen(strcat(strf,"_kmin_adders.tab"),"wt");
    fprintf(fid,"$%d$",k0_adders_sd_min);
    fclose(fid);
    % Coefficients
    A1k0_sd_min=k0_sd_min(RA1k);
    A2k0_sd_min=k0_sd_min(RA2k);
    Esq0_sd_min=schurOneMPAlatticeEsq(A1k0_sd_min,A1epsilon0,A1p0, ...
                                      A2k0_sd_min,A2epsilon0,A2p0, ...
                                      difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    print_polynomial(A1k0_sd_min,"A1k0_sd_min",nscale);
    print_polynomial(A1k0_sd_min,"A1k0_sd_min", ...
                     strcat(strf,"_A1k0_sd_min_coef.m"),nscale);
    print_polynomial(A2k0_sd_min,"A2k0_sd_min",nscale);
    print_polynomial(A2k0_sd_min,"A2k0_sd_min", ...
                     strcat(strf,"_A2k0_sd_min_coef.m"),nscale);
    break;
  endif
  
  % Try to solve the current SOCP problem for the active coefficients
  try
    [nextA1k,nextA2k,slb_iter,opt_iter,func_iter,feasible] = ...
      schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                             k(RA1k),A1epsilon0,A1p0,k(RA2k),A2epsilon0,A2p0, ...
                             difference,k_u,k_l,k_active,dmax, ...
                             wa,Asqd,Asqdu,Asqdl,Wa, ...
                             wt,Td,Tdu,Tdl,Wt, ...
                             wp,Pd,Pdu,Pdl,Wp, ...
                             maxiter,tol,ctol,verbose);
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


% Calculate response
Asq_k0=schurOneMPAlatticeAsq(wa,A1k0,A1epsilon0,A1p0, ...
                             A2k0,A2epsilon0,A2p0,difference);
Asq_k0_sd=schurOneMPAlatticeAsq(wa,k0_sd(RA1k),A1epsilon0,A1p0, ...
                                k0_sd(RA2k),A2epsilon0,A2p0,difference);
Asq_k0_sd_Lim=schurOneMPAlatticeAsq(wa,k0_sd_Lim(RA1k),A1epsilon0,A1p0, ...
                                    k0_sd_Lim(RA2k),A2epsilon0,A2p0,difference);
Asq_k0_sd_sdp=schurOneMPAlatticeAsq(wa,k0_sd_sdp(RA1k),A1epsilon0,A1p0, ...
                                    k0_sd_sdp(RA2k),A2epsilon0,A2p0,difference);
Asq_k0_sd_min=schurOneMPAlatticeAsq(wa,k0_sd_min(RA1k),A1epsilon0,A1p0, ...
                                    k0_sd_min(RA2k),A2epsilon0,A2p0,difference);
T_k0=schurOneMPAlatticeT(wt,A1k0,A1epsilon0,A1p0, ...
                         A2k0,A2epsilon0,A2p0,difference);
T_k0_sd=schurOneMPAlatticeT(wt,k0_sd(RA1k),A1epsilon0,A1p0, ...
                            k0_sd(RA2k),A2epsilon0,A2p0,difference);
T_k0_sd_Lim=schurOneMPAlatticeT(wt,k0_sd_Lim(RA1k),A1epsilon0,A1p0, ...
                                k0_sd_Lim(RA2k),A2epsilon0,A2p0,difference);
T_k0_sd_sdp=schurOneMPAlatticeT(wt,k0_sd_sdp(RA1k),A1epsilon0,A1p0, ...
                                k0_sd_sdp(RA2k),A2epsilon0,A2p0,difference);
T_k0_sd_min=schurOneMPAlatticeT(wt,k0_sd_min(RA1k),A1epsilon0,A1p0, ...
                                k0_sd_min(RA2k),A2epsilon0,A2p0,difference);
P_k0=schurOneMPAlatticeP(wp,A1k0,A1epsilon0,A1p0, ...
                         A2k0,A2epsilon0,A2p0,difference);
P_k0_sd=schurOneMPAlatticeP(wp,k0_sd(RA1k),A1epsilon0,A1p0, ...
                            k0_sd(RA2k),A2epsilon0,A2p0,difference);
P_k0_sd_Lim=schurOneMPAlatticeP(wp,k0_sd_Lim(RA1k),A1epsilon0,A1p0, ...
                                k0_sd_Lim(RA2k),A2epsilon0,A2p0,difference);
P_k0_sd_sdp=schurOneMPAlatticeP(wp,k0_sd_sdp(RA1k),A1epsilon0,A1p0, ...
                                k0_sd_sdp(RA2k),A2epsilon0,A2p0,difference);
P_k0_sd_min=schurOneMPAlatticeP(wp,k0_sd_min(RA1k),A1epsilon0,A1p0, ...
                                k0_sd_min(RA2k),A2epsilon0,A2p0,difference);

% Amplitude and delay at local peaks
vAl=local_max(Asqdl-Asq_k0_sd_min);
vAu=local_max(Asq_k0_sd_min-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,end])]);
AsqS=schurOneMPAlatticeAsq(wAsqS,k0_sd_min(RA1k),A1epsilon0,A1p0, ...
                           k0_sd_min(RA2k),A2epsilon0,A2p0,difference);
printf("k0_sd_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k0_sd_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

vTl=local_max(Tdl-T_k0_sd_min);
vTu=local_max(T_k0_sd_min-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
TS=schurOneMPAlatticeT(wTS,k0_sd_min(RA1k),A1epsilon0,A1p0, ...
                       k0_sd_min(RA2k),A2epsilon0,A2p0,difference);
printf("k0_sd_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k0_sd_min:TS=[ ");printf("%f ",TS');printf("] (Samples)\n");

vPl=local_max(Pdl-P_k0_sd_min);
vPu=local_max(P_k0_sd_min-Pdu);
wPS=sort(unique([wp(vPl);wp(vPu);wp([1,end])]));
PS=schurOneMPAlatticeP(wPS,k0_sd_min(RA1k),A1epsilon0,A1p0, ...
                       k0_sd_min(RA2k),A2epsilon0,A2p0,difference);
printf("k0_sd_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k0_sd_min:PS=[ ");printf("%f ",mod((PS+(wPS*td))'/pi,2));
printf("] (rad./pi)\n");

% Find maximum stop band response
rsb=[1:nasl,nasu:n];
max_sb_Asq_k0=10*log10(max(abs(Asq_k0(rsb))))
max_sb_Asq_k0_sd=10*log10(max(abs(Asq_k0_sd(rsb))))
max_sb_Asq_k0_sd_Lim=10*log10(max(abs(Asq_k0_sd_Lim(rsb))))
max_sb_Asq_k0_sd_sdp=10*log10(max(abs(Asq_k0_sd_sdp(rsb))))
max_sb_Asq_k0_sd_min=10*log10(max(abs(Asq_k0_sd_min(rsb))))

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & %4.1f & & \\\\\n",Esq0,max_sb_Asq_k0);
fprintf(fid,"%d-bit %d-signed-digit & %8.6f & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,max_sb_Asq_k0_sd,k0_digits_sd,k0_adders_sd);
fprintf(fid,"%d-bit %d-signed-digit(Lim) & %8.6f & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd_Lim,max_sb_Asq_k0_sd_Lim, ...
        k0_digits_sd_Lim,k0_adders_sd_Lim);
fprintf(fid,"%d-bit %d-signed-digit(SDP) & %8.6f & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd_sdp,max_sb_Asq_k0_sd_sdp, ...
        k0_digits_sd_sdp,k0_adders_sd_sdp);
fprintf(fid,"%d-bit %d-signed-digit(min) & %8.6f & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd_min,max_sb_Asq_k0_sd_min, ...
        k0_digits_sd_min,k0_adders_sd_min);
fclose(fid);

% Plot stop band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_k0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_Lim)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_sdp)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -50 -20]);
strt=sprintf("Parallel allpass lattice bandpass Hilbert filter stop-band \
(nbits=%d,ndigits=%d) : fasl=%g,fasu=%g",nbits,ndigits,fasl,fasu);
title(strt);
legend("initial","s-d","s-d(Lim)","s-d(SDP)","s-d(min)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot pass band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_k0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_Lim)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_sdp)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([min([fapl ftpl fppl]), max([fapu ftpu ftpu]), -0.3, 0]);
strt=sprintf("Parallel allpass lattice bandpass Hilbert filter pass-band \
amplitude nbits=%d,ndigits=%d) : fapl=%g,fapu=%g",nbits,ndigits,fapl,fapu);
title(strt);
legend("initial","s-d","s-d(Lim)","s-d(SDP)","s-d(min)");
legend("location","north");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_pass"),"-dpdflatex");
close

% Plot delay response
plot(wt*0.5/pi,T_k0,"linestyle","-", ...
     wt*0.5/pi,T_k0_sd,"linestyle",":", ...
     wt*0.5/pi,T_k0_sd_Lim,"linestyle","--", ...
     wt*0.5/pi,T_k0_sd_sdp,"linestyle","-", ...
     wt*0.5/pi,T_k0_sd_min,"linestyle","-.");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([min([fapl ftpl fppl]),max([fapu ftpu ftpu]),td-tdr,td+tdr]);
strt=sprintf("Parallel allpass lattice bandpass Hilbert filter pass-band delay \
(nbits=%d,ndigits=%d) : ftpl=%g,ftpu=%g",nbits,ndigits,ftpl,ftpu);
title(strt);
legend("initial","s-d","s-d(Lim)","s-d(SDP)","s-d(min)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Plot phase response
plot(wp*0.5/pi,mod((P_k0+(wp*td))/pi,2),"linestyle","-", ...
     wp*0.5/pi,mod((P_k0_sd+(wp*td))/pi,2),"linestyle",":", ...
     wp*0.5/pi,mod((P_k0_sd_Lim+(wp*td))/pi,2),"linestyle","--", ...
     wp*0.5/pi,mod((P_k0_sd_sdp+(wp*td))/pi,2),"linestyle","-", ...
     wp*0.5/pi,mod((P_k0_sd_min+(wp*td))/pi,2),"linestyle","-.");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$)");
axis([min([fapl ftpl fppl]), max([fapu ftpu ftpu]), ...
      mod(pd-(pdr/2),2),     mod(pd+(pdr/2),2)]);
strt=sprintf("Parallel allpass lattice bandpass Hilbert filter pass-band phase \
(nbits=%d,ndigits=%d) : fppl=%g,fppu=%g",nbits,ndigits,fppl,fppu);
title(strt);
legend("initial","s-d","s-d(Lim)","s-d(SDP)","s-d(min)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_phase"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%g %% Frequency points across the band\n",n);
fprintf(fid,"ma=%d %% All-pass filter a order\n",ma);
fprintf(fid,"mb=%d %% All-pass filter b order\n",mb);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBas=%d %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%d %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Amplitude upper stop band weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Pass band delay lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band delay upper edge\n",ftpu);
fprintf(fid,"td=%g %% Nominal pass band filter group delay\n",td);
fprintf(fid,"tdr=%g %% Delay pass band peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fprintf(fid,"fppl=%g %% Pass band phase response lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Pass band phase response upper edge\n",fppu);
fprintf(fid,"pd=%g %% Pass band initial phase response (rad./pi)\n",pd);
fprintf(fid,"pdr=%g %% Pass band phase response ripple(rad./pi)\n",pdr);
fprintf(fid,"Wpp=%d %% Pass band phase response weight\n",Wpp);
fclose(fid);

% Save results
save sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test.mat ...
     tol ctol nbits nscale ndigits ndigits_alloc n ...
     fapl fapu dBap Wap fasl fasu dBas Wasl Wasu  ...
     ftpl ftpu td tdr Wtp fppl fppu pd pdr Wpp ...
     A1k0 A1epsilon0 A1p0 A2k0 A2epsilon0 A2p0 ...
     A1k0_sd_sdp A2k0_sd_sdp A1k0_sd_min A2k0_sd_min
       
% Done
toc;
diary off
movefile ...
  sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test.diary.tmp ...
  sdp_relaxation_schurOneMPAlattice_bandpass_hilbert_13_nbits_test.diary;
