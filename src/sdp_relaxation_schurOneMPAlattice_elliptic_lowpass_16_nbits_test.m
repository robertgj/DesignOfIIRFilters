% sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.m
% Copyright (C) 2019 Robert G. Jenssen

% SDP relaxation optimisation of a Schur parallel one-multiplier allpass
% lattice elliptic lowpass filter with 16-bit signed-digit coefficients having
% an average of 5 signed-digits

test_common;

unlink ...
("sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.diary");
unlink ...
("sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.diary.tmp");
diary sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.diary.tmp

tic;

maxiter=2000
verbose=false;
tol=1e-5;
ctol=1e-8
strf="sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test";

% Initial filters found by parallel_allpass_socp_slb_test.m
Da1 = [   1.0000000000,  -2.9402572112,   4.3065870986,  -3.5543099587, ... 
          1.6640472637,  -0.3494581651 ]';
Db1 = [   1.0000000000,  -3.5113112515,   6.3224172805,  -6.8117054892, ... 
          4.6326494921,  -1.8594338344,   0.3514813431 ]';

% Lattice decomposition of Da1 and Db1
[A1k0,A1epsilon0,A1p0,~] = tf2schurOneMlattice(flipud(Da1),Da1);
[A2k0,A2epsilon0,A2p0,~] = tf2schurOneMlattice(flipud(Db1),Db1);

% Initialise coefficient range vectors
A1p_ones=ones(size(A1p0));
A2p_ones=ones(size(A2p0));
NA1k=length(A1k0);
NA2k=length(A2k0);
RA1k=1:NA1k;
RA2k=(NA1k+1):(NA1k+NA2k);

% Lowpass filter specification
maxiter=500
verbose=false
n=1000;
difference=false
rho=0.999
fap=0.15
dBap=0.04
Wap=1
Wat=tol
fas=0.17
dBas=76
Was=5e5

% Desired squared magnitude response
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
wa=(0:(n-1))'*pi/n;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Dummy responses
wt=[];Td=[];Tdu=[];Tdl=[];Wt=[];wp=[];Pd=[];Pdu=[];Pdl=[];Wp=[];

% Sanity checks
nchka=[nap-1,nap,nap+1,nas-1,nas,nas+1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Linear constraints
dmax=inf;
rho=127/128
k0=[A1k0(:);A2k0(:)];
k0_active=find(k0~=0);
k0_u=rho*ones(size(k0));
k0_l=-k0_u;

% Find initial mean-squared errror
Esq0=schurOneMPAlatticeEsq(A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                           difference,wa,Asqd,Wa)
% Allocate digits
nbits=16;
nscale=2^(nbits-1);
ndigits=5;

% Find the signed-digit approximations to k0
[k0_sd,k0_sdu,k0_sdl]=flt2SD(k0,nbits,ndigits);
[k0_digits_sd,k0_adders_sd]=SDadders(k0_sd,nbits);
A1k0_sd=k0_sd(RA1k);
A2k0_sd=k0_sd(RA2k);
Esq0_sd=schurOneMPAlatticeEsq(A1k0_sd,A1epsilon0,A1p_ones, ...
                              A2k0_sd,A2epsilon0,A2p_ones, ... 
                              difference,wa,Asqd,Wa)
print_polynomial(A1k0_sd,"A1k0_sd",nscale);
print_polynomial(A1k0_sd,"A1k0_sd", ...
                 strcat(strf,"_A1k0_sd_coef.m"),nscale);
print_polynomial(A2k0_sd,"A2k0_sd",nscale);
print_polynomial(A2k0_sd,"A2k0_sd", ...
                 strcat(strf,"_A2k0_sd_coef.m"),nscale);

% Solve the SDP problem with SeDuMi
k0_sd_delta=(k0_sdu-k0_sdl)/2;
k0_sd_x=(k0_sdu+k0_sdl)/2;
k0_sd_x_active=find((k0_sd_x)~=0);
[A1k0_sd_sdp,A2k0_sd_sdp,socp_iter,func_iter,feasible] = ...
  schurOneMPAlattice_sdp_mmse([], ...
                              k0_sd_x(RA1k),A1epsilon0,A1p0, ...
                              k0_sd_x(RA2k),A2epsilon0,A2p0, ...
                              difference,k0_u,k0_l,k0_sd_x_active,k0_sd_delta, ...
                              wa,Asqd,Asqdu,Asqdl,Wa, ...
                              wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                              maxiter,tol,verbose);
if feasible==false
  error("schurOneMPAlattice_sdp_mmse failed!");
endif
k0_sd_sdp=[A1k0_sd_sdp(:);A2k0_sd_sdp];
[k0_digits_sd_sdp,k0_adders_sd_sdp]=SDadders(k0_sd_sdp,nbits);
Esq0_sd_sdp=schurOneMPAlatticeEsq(A1k0_sd_sdp,A1epsilon0,A1p_ones, ...
                                  A2k0_sd_sdp,A2epsilon0,A2p_ones, ...
                                  difference,wa,Asqd,Wa);
print_polynomial(A1k0_sd_sdp,"A1k0_sd_sdp",nscale);
print_polynomial(A1k0_sd_sdp,"A1k0_sd_sdp", ...
                 strcat(strf,"_A1k0_sd_sdp_coef.m"),nscale);
print_polynomial(A2k0_sd_sdp,"A2k0_sd_sdp",nscale);
print_polynomial(A2k0_sd_sdp,"A2k0_sd_sdp", ...
                 strcat(strf,"_A2k0_sd_sdp_coef.m"),nscale);

% Find coefficients with successive relaxation
k=zeros(size(k0));
k(k0_sd_x_active)=k0(k0_sd_x_active);
k_active=k0_sd_x_active;

% Fix one coefficient at each iteration 
while 1
  
  % Find the signed-digit filter coefficients 
  [k_sd,k_sdu,k_sdl]=flt2SD(k,nbits,ndigits);
  
  % Run the SeDuMi problem to find the SDP solution for the current coefficients
  k_sdul=k_sdu-k_sdl;
  k_sd_delta=k_sdul/2;
  k_sd_x=k_sdl+k_sd_delta;
  k_sd_x_active=find((k_sd_x)~=0);
  [A1k_sd_sdp,A2k_sd_sdp,socp_iter,func_iter,feasible] = ...
    schurOneMPAlattice_sdp_mmse([], ...
                                k_sd_x(RA1k),A1epsilon0,A1p0, ...
                                k_sd_x(RA2k),A2epsilon0,A2p0, ...
                                difference, ...
                                k0_u,k0_l,k_sd_x_active,k_sd_delta, ...
                                wa,Asqd,Asqdu,Asqdl,Wa, ...
                                wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                                maxiter,tol,verbose);
  if feasible==false
    error("schurOneMPAlattice_sdp_mmse failed!");
  endif

  % Ito et al. suggest ordering the search by max(k_sdu-k_sdl)
  [k_max,k_max_n]=max(k_sdul(k_active));
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
                                      difference,wa,Asqd,Wa);
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
                             difference,k0_u,k0_l,k_active,dmax, ...
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
Asq_k0_sd=schurOneMPAlatticeAsq(wa,A1k0_sd,A1epsilon0,A1p_ones, ...
                                A2k0_sd,A2epsilon0,A2p_ones,difference);
Asq_k0_sd_sdp=schurOneMPAlatticeAsq(wa,A1k0_sd_sdp,A1epsilon0,A1p_ones, ...
                                    A2k0_sd_sdp,A2epsilon0,A2p_ones,difference);
Asq_k0_sd_min=schurOneMPAlatticeAsq(wa,A1k0_sd_min,A1epsilon0,A1p_ones, ...
                                    A2k0_sd_min,A2epsilon0,A2p_ones,difference);

% Amplitude and delay at local peaks
vAl=local_max(Asqdl-Asq_k0_sd_min);
vAu=local_max(Asq_k0_sd_min-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,end])]);
AsqS=schurOneMPAlatticeAsq(wAsqS,A1k0_sd_min,A1epsilon0,A1p0, ...
                           A2k0_sd_min,A2epsilon0,A2p0,difference);
printf("k0_sd_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k0_sd_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

% Find maximum stop band response
rsb=[nas:n];
max_sb_Asq_k0=10*log10(max(abs(Asq_k0(rsb))))
max_sb_Asq_k0_sd=10*log10(max(abs(Asq_k0_sd(rsb))))
max_sb_Asq_k0_sd_sdp=10*log10(max(abs(Asq_k0_sd_sdp(rsb))))
max_sb_Asq_k0_sd_min=10*log10(max(abs(Asq_k0_sd_min(rsb))))

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %6.2g & %4.1f & & \\\\\n",Esq0,max_sb_Asq_k0);
fprintf(fid,"%d-bit %d-signed-digit & %6.2g & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,max_sb_Asq_k0_sd,k0_digits_sd,k0_adders_sd);
fprintf(fid,"%d-bit %d-signed-digit(SDP) & %6.2g & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd_sdp,max_sb_Asq_k0_sd_sdp, ...
        k0_digits_sd_sdp,k0_adders_sd_sdp);
fprintf(fid,"%d-bit %d-signed-digit(min) & %6.2g & %4.1f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd_min,max_sb_Asq_k0_sd_min, ...
        k0_digits_sd_min,k0_adders_sd_min);
fclose(fid);

% Plot stop band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_k0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_sdp)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([fap, 0.5, -90, -50]);
strt=sprintf("Parallel allpass lattice elliptic lowpass filter stop-band \
(nbits=%d,ndigits=%d) : fas=%g",nbits,ndigits,fas);
title(strt);
legend("initial","s-d","s-d(SDP)","s-d(min)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot pass band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_k0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_sdp)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_k0_sd_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0, fap, -0.03, 0.01]);
strt=sprintf("Parallel allpass lattice elliptic lowpass filter pass-band \
amplitude nbits=%d,ndigits=%d) : fap=%g",nbits,ndigits,fap);
title(strt);
legend("initial","s-d","s-d(SDP)","s-d(min)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_pass"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%g %% Frequency points across the band\n",n);
fprintf(fid,"m1=%d %% All-pass filter 1 order\n",NA1k-1);
fprintf(fid,"m2=%d %% All-pass filter 2 order\n",NA2k-1);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%d %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);

% Save results
save sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.mat ...
     tol ctol nbits nscale ndigits n fap dBap Wap fas dBas Was  ...
     A1k0 A1epsilon0 A1p0 A2k0 A2epsilon0 A2p0 ...
     A1k0_sd A2k0_sd A1k0_sd_sdp A2k0_sd_sdp A1k0_sd_min A2k0_sd_min
       
% Done
toc;
diary off
movefile ...
  sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.diary.tmp ...
  sdp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.diary;
