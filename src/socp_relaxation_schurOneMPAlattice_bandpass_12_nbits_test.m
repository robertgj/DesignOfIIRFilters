% socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test.m

% SOCP-relaxation optimisation of the response of a band-pass filter
% composed of parallel Schur one-multiplier all-pass lattice filters
% with 12-bit 3-signed-digit coefficients.

% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test.diary");
delete("socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test.diary.tmp");
diary socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test.diary.tmp

% Options
socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Lim=true
socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Ito=false

tic;

maxiter=5000
verbose=false
strf="socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test";

%
% Initial coefficients found by schurOneMPAlattice_socp_slb_bandpass_test.m
%
A1k = [  -0.7666597804,   0.8667401054,   0.0252095961,  -0.3718472889, ... 
          0.5652033325,  -0.1071060380,  -0.1373512436,   0.4282945944, ... 
         -0.3103535415,   0.1515745427 ];
A1epsilon = [  1,  1, -1,  1, ... 
              -1,  1,  1,  1, ... 
               1, -1 ];
A1p = [   0.3641454523,   1.0019742264,   0.2677098521,   0.2745459635, ... 
          0.4057283252,   0.7697994683,   0.8571804817,   0.9842435480, ... 
          0.6227013820,   0.8583428975 ];
A1p_ones=ones(size(A1p));
A2k = [  -0.4417700339,   0.8255993520,   0.0573543439,  -0.3256363836, ... 
          0.5450440870,  -0.1927089741,  -0.1833550314,   0.4373452222, ... 
         -0.2825856868,   0.1647448391 ];
A2epsilon = [  1,  1, -1,  1, ... 
              -1, -1,  1,  1, ... 
               1, -1 ];
A2p = [   0.7519814809,   1.2085053288,   0.3735251772,   0.3955996713, ... 
          0.5546526142,   1.0221316716,   0.8409199665,   1.0122680973, ... 
          0.6333386770,   0.8468260055 ];
A2p_ones=ones(size(A2p));

% Initialise coefficient range vectors
NA1=length(A1k);
NA2=length(A2k);
R1=1:NA1;
R2=(NA1+1):(NA1+NA2);

% Band pass filter specification
difference=true
tol=1e-4
ctol=tol/10
rho=127/128
m1=length(A1k);
m2=length(A2k);
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=2
Wap=1
Watl=0.001
Watu=0.001
dBas=40
Wasl=200
Wasu=100
ftpl=0.09
ftpu=0.21
td=16
tdr=0.2
Wtp=1

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
Td=td*ones(ntpu-ntpl+1,1);
Tdu=(td+(tdr/2))*ones(ntpu-ntpl+1,1);
Tdl=(td-(tdr/2))*ones(ntpu-ntpl+1,1);
Wt=Wtp*ones(ntpu-ntpl+1,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Linear constraints
dmax=inf;
k=[A1k(:);A2k(:)];
k_u=rho*ones(size(k));
k_l=-k_u;
k_active=find(k~=0);

% Common strings
strf="socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test";

% Allocate signed-digits to the coefficients
nbits=12
nscale=2^(nbits-1);
ndigits=3
if socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Lim
  ndigits_alloc=schurOneMPAlattice_allocsd_Lim ...
                  (nbits,ndigits,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                   difference,wa,Asqd,ones(size(Wa)), ...
                   wt,Td,ones(size(Wt)),wp,Pd,ones(size(Wp)));
elseif socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Ito
  ndigits_alloc=schurOneMPAlattice_allocsd_Ito ...
                  (nbits,ndigits,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                   difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
else
  ndigits_alloc=zeros(size(k));
  ndigits_alloc(k_active)=ndigits;
endif

% Find the signed-digit approximations to k0,u0 and v0
[k_sd,k_sdu,k_sdl]=flt2SD(k,nbits,ndigits_alloc);
A1k_sd=k_sd(R1);
A2k_sd=k_sd(R2);
print_polynomial(A1k_sd,"A1k_sd",nscale);
print_polynomial(A1k_sd,"A1k_sd",strcat(strf,"_A1k_sd_coef.m"),nscale);
print_polynomial(A2k_sd,"A2k_sd",nscale);
print_polynomial(A2k_sd,"A2k_sd",strcat(strf,"_A2k_sd_coef.m"),nscale);

% Initialise k_active
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
if any(k(k_active)>k_sdu(k_active))
  error("found k(k_active)>k_sdu(k_active)");
endif
if any(k_sdl(k_active)>k(k_active))
  error("found k_sdl>k");
endif

% Find k error
Esq0=schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                           difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Find k_sd error
Esq0_sd=schurOneMPAlatticeEsq ...
          (k_sd(R1),A1epsilon,A1p,k_sd(R2),A2epsilon,A2p,difference, ...
           wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Find the number of signed-digits and adders used by k_sd
[k_digits,k_adders]=SDadders(k_sd(k_active),nbits);

% Initialise the vector of filter coefficients to be optimised
kopt=zeros(size(k));
kopt(k_active)=k(k_active);
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
    % Find the SOCP PCLS solution for the remaining active coefficents
    [nextA1k,nextA2k,slb_iter,opt_iter,func_iter,feasible] = ...
    schurOneMPAlattice_slb ...
      (@schurOneMPAlattice_socp_mmse, ...
       kopt_b(R1),A1epsilon,A1p,kopt_b(R2),A2epsilon,A2p,difference, ...
       kopt_bu,kopt_bl,kopt_active,dmax, ...
       wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
       maxiter,tol,ctol,verbose);
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
    printf("kopt*nscale=[ ");printf("%g ",kopt(:)'*nscale);printf(" ];\n");
    error("SOCP problem infeasible!");
  endif

  % Fix coef_n
  nextkopt=[nextA1k(:);nextA2k(:)];
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
A1p_ones=ones(size(A1p));
A2p_ones=ones(size(A2p));
kmin=kopt;
A1k_min=kopt(R1);
A1epsilon_min=schurOneMscale(A1k_min);
A2k_min=kopt(R2);
A2epsilon_min=schurOneMscale(A2k_min);
Esq_min=schurOneMPAlatticeEsq ...
          (A1k_min,A1epsilon_min,A1p_ones, ...
           A2k_min,A2epsilon_min,A2p_ones,difference, ...
           wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
print_polynomial(A1k_min,"A1k_min",nscale);
print_polynomial(A1k_min,"A1k_min",strcat(strf,"_A1k_min_coef.m"),nscale);
printf("A1epsilon_min=[ ");printf("%d ",A1epsilon_min');printf("]';\n");
print_polynomial(A2k_min,"A2k_min",nscale);
print_polynomial(A2k_min,"A2k_min",strcat(strf,"_A2k_min_coef.m"),nscale);
printf("A2epsilon_min=[ ");printf("%d ",A2epsilon_min');printf("]';\n");
% Find the number of signed-digits and adders used
[kopt_digits,kopt_adders]=SDadders(kmin(k_active),nbits);
printf("%d signed-digits used\n",kopt_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kopt_adders,nbits);
fid=fopen(strcat(strf,"_kmin_digits.tab"),"wt");
fprintf(fid,"$%d$",kopt_digits);
fclose(fid);
fid=fopen(strcat(strf,"_kmin_adders.tab"),"wt");
fprintf(fid,"$%d$",kopt_adders);
fclose(fid);

% Amplitude and delay at local peaks
Asq=schurOneMPAlatticeAsq ...
      (wa,A1k_min,A1epsilon_min,A1p_ones, ...
       A2k_min,A2epsilon_min,A2p_ones,difference);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,end])]);
AsqS=schurOneMPAlatticeAsq ...
       (wAsqS,A1k_min,A1epsilon_min,A1p_ones, ...
        A2k_min,A2epsilon_min,A2p_ones,difference);
printf("kmin:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kmin:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMPAlatticeT ...
    (wt,A1k_min,A1epsilon_min,A1p_ones, ...
     A2k_min,A2epsilon_min,A2p_ones,difference);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
TS=schurOneMPAlatticeT ...
     (wTS,A1k_min,A1epsilon_min,A1p_ones, ...
      A2k_min,A2epsilon_min,A2p_ones,difference);
printf("kmin:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kmin:TS=[ ");printf("%f ",TS');printf("] (Samples)\n")
                        
% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_kmin_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(Lim)& %8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,k_digits,k_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,kopt_digits,kopt_adders);
fclose(fid);

%
% Plot response
%

% Find squared-magnitude and group-delay
Asq_k=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
Asq_k_sd=schurOneMPAlatticeAsq ...
           (wa,A1k_sd,A1epsilon,A1p_ones,A2k_sd,A2epsilon,A2p_ones,difference);
Asq_kmin=schurOneMPAlatticeAsq ...
           (wa,A1k_min,A1epsilon_min,A1p_ones, ...
            A2k_min,A2epsilon_min,A2p_ones,difference);
T_k=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
T_k_sd=schurOneMPAlatticeT ...
         (wt,A1k_sd,A1epsilon,A1p_ones,A2k_sd,A2epsilon,A2p_ones,difference);
T_kmin=schurOneMPAlatticeT ...
         (wt,A1k_min,A1epsilon_min,A1p_ones, ...
          A2k_min,A2epsilon_min,A2p_ones,difference);

% Plot stop-band amplitude
plot(wa*0.5/pi,10*log10(Asq_k),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_k_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_kmin),"linestyle","-.");
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
ylabel("Amplitude(dB)");
xlabel("Frequency");
  strt=sprintf("Parallel one-multplier allpass lattice bandpass filter \
(nbits=%d) : fapl=%g,fapu=%g,dBas=%g,td=%g",nbits,fapl,fapu,dBas,td);
title(strt);
axis([0  0.5 -70 -20]);
grid("on");
print(strcat(strf,"_kmin_stop"),"-dpdflatex");
close

% Plot pass-band amplitude and delay
subplot(211)
plot(wa*0.5/pi,10*log10(Asq_k),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_k_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_kmin),"linestyle","-.");
ylabel("Amplitude(dB)");
title(strt);
axis([min(fapl,ftpl) max(fapu,ftpu) -2*dBap 2*dBap]);
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
subplot(212)
plot(wt*0.5/pi,T_k,"linestyle","-", ...
     wt*0.5/pi,T_k_sd,"linestyle","--", ...
     wt*0.5/pi,T_kmin,"linestyle","-.");
ylabel("Delay(samples)");
xlabel("Frequency");
axis([min(fapl,ftpl) max(fapu,ftpu) td-0.2 td+0.2]);
grid("on");
print(strcat(strf,"_kmin_pass"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test_\
allocsd_Lim=%d\n", ...
        socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Lim);
fprintf(fid,"socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test_\
allocsd_Ito=%d\n", ...
        socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Ito);
fprintf(fid,"nbits=%d %% Coefficient word length\n",nbits);
fprintf(fid,"ndigits=%d %% Average number of signed digits per coef.\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n",difference);
fprintf(fid,"m1=%d %% Allpass model filter 1 denominator order\n",m1);
fprintf(fid,"m2=%d %% Allpass model filter 2 denominator order\n",m2);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fapl=%g %% Pass band amplitude response lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Pass band amplitude response upper edge\n",fapu);
fprintf(fid,"dBap=%f %% Pass band amplitude response ripple(dB)\n",dBap);
fprintf(fid,"Wap=%d %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"Watl=%d %% Lower transition band amplitude response weight\n",Watl);
fprintf(fid,"Watu=%d %% Upper transition band amplitude response weight\n",Watu);
fprintf(fid,"fasl=%g %% Stop band amplitude response lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Stop band amplitude response upper edge\n",fasu);
fprintf(fid,"dBas=%f %% Stop band amplitude response ripple(dB)\n",dBas);
fprintf(fid,"Wasl=%d %% Lower stop band amplitude response weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Upper stop band amplitude response weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Pass band group-delay response lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band group-delay response upper edge\n",ftpu);
fprintf(fid,"td=%f %% Pass band nominal group-delay response(samples)\n",td);
fprintf(fid,"tdr=%f %% Pass band group-delay response ripple(samples)\n",tdr);
fprintf(fid,"Wtp=%d %% Pass band group-delay response weight\n",Wtp);
fclose(fid);

% Save results
save socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test.mat ...
     socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Lim ...
     socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Ito ...
     n m1 m2 difference tol ctol rho  ...
     fapl fapu dBap Wap Watl Watu ...
     fasl fasu dBas Wasl Wasu ...
     ftpl ftpu td tdr Wtp ...
     A1k A1epsilon A1p A2k A2epsilon A2p ...
     nbits ndigits ndigits_alloc ...
     A1k_min A1epsilon_min A2k_min A2epsilon_min

% Done
toc;
diary off
movefile socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test.diary.tmp ...
         socp_relaxation_schurOneMPAlattice_bandpass_12_nbits_test.diary;
