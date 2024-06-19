% socp_relaxation_schurOneMPAlattice_lowpass_12_nbits_test.m

% SOCP-relaxation optimisation of the response of a low-pass filter
% composed of parallel Schur one-multiplier all-pass lattice filters
% with 12-bit 3-signed-digit coefficients.

% Copyright (C) 2017-2021 Robert G. Jenssen

test_common;

strf="socp_relaxation_schurOneMPAlattice_lowpass_12_nbits_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

% Options
socp_relaxation_schurOneMPAlattice_lowpass_12_nbits_test_allocsd_Lim=true
socp_relaxation_schurOneMPAlattice_lowpass_12_nbits_test_allocsd_Ito=false

tic;

tol=1e-4
ctol=5e-7
maxiter=2000
verbose=false

% Initial coefficients found by schurOneMPAlattice_socp_slb_lowpass_test.m
schurOneMPAlattice_socp_slb_lowpass_test_A1k_coef;
schurOneMPAlattice_socp_slb_lowpass_test_A1epsilon_coef;
schurOneMPAlattice_socp_slb_lowpass_test_A1p_coef;
schurOneMPAlattice_socp_slb_lowpass_test_A2k_coef;
schurOneMPAlattice_socp_slb_lowpass_test_A2epsilon_coef;
schurOneMPAlattice_socp_slb_lowpass_test_A2p_coef;

% Low pass filter specification
n=1000
difference=false % Sum all-pass filters
m1=11 % Allpass model filter 1 denominator order
m2=12 % Allpass model filter 2 denominator order
fap=0.125 % Pass band amplitude response edge
dBap=0.2 % Pass band amplitude response ripple
Wap=1 % Pass band amplitude response weight
Wat=0 % Transition band amplitude response weight
fas=0.25 % Stop band amplitude response edge
dBas=50 % Stop band amplitude response ripple
Was=100 % Stop band amplitude response weight
ftp=0.175 % Pass band group delay response edge
td=(m1+m2)/2 % Pass band nominal group delay
tdr=0.08 % Pass band group delay response ripple
Wtp=2 % Pass band group delay response weight

% This works with Wa, Wt and Wp passed to schurOneMPAlattice_allocsd_Lim:
% dBas=51;tdr=0.08;Wtp=1;

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=[ones(nap,1); zeros(n-nap,1)];
Asqdu=[ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1); zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=td*ones(ntp,1);
Tdu=(td+(tdr/2))*ones(ntp,1);
Tdl=(td-(tdr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Linear constraints
dmax=inf;
rho=127/128
k=[A1k(:);A2k(:)];
k_u=rho*ones(size(k));
k_l=-k_u;
k_active=find(k~=0);

% Initialise coefficient vectors
NA1=length(A1k);
NA2=length(A2k);
k=[A1k(:);A2k(:)];
R1=1:NA1;
R2=(NA1+1):(NA1+NA2);

% Allocate signed-digits to the coefficients
nbits=12
nscale=2^(nbits-1);
ndigits=3
if socp_relaxation_schurOneMPAlattice_lowpass_12_nbits_test_allocsd_Lim
  ndigits_alloc=schurOneMPAlattice_allocsd_Lim ...
                  (nbits,ndigits,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                   difference,wa,Asqd,ones(size(Wa)), ...
                   wt,Td,ones(size(Wt)),wp,Pd,ones(size(Wp)));
elseif socp_relaxation_schurOneMPAlattice_lowpass_12_nbits_test_allocsd_Ito
  ndigits_alloc=schurOneMPAlattice_allocsd_Ito ...
                  (nbits,ndigits,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                   difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
else
  ndigits_alloc=zeros(size(k));
  ndigits_alloc(k_active)=ndigits;
endif

A1k_allocsd_digits=int16(ndigits_alloc(R1));
A2k_allocsd_digits=int16(ndigits_alloc(R2));

printf("A1k_allocsd_digits=[ ");
printf("%2d ",A1k_allocsd_digits);printf("]';\n");
print_polynomial(A1k_allocsd_digits,"A1k_allocsd_digits", ...
                 strcat(strf,"_A1k_allocsd_digits.m"),"%2d");

printf("A2k_allocsd_digits=[ ");
printf("%2d ",A2k_allocsd_digits);printf("]';\n");
print_polynomial(A2k_allocsd_digits,"A2k_allocsd_digits", ...
                 strcat(strf,"_A2k_allocsd_digits.m"),"%2d");

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
Asq=schurOneMPAlatticeAsq(wa,A1k_min,A1epsilon_min,A1p_ones,A2k_min, ...
                          A2epsilon_min,A2p_ones,difference);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AsqS=schurOneMPAlatticeAsq(wAsqS,A1k_min,A1epsilon_min,A1p_ones, ...
                           A2k_min,A2epsilon_min,A2p_ones,difference);
printf("kmin:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kmin:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

T=schurOneMPAlatticeT(wt,A1k_min,A1epsilon_min,A1p_ones, ...
                      A2k_min,A2epsilon_min,A2p_ones,difference);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
TS=schurOneMPAlatticeT(wTS,A1k_min,A1epsilon_min,A1p_ones, ...
                       A2k_min,A2epsilon_min,A2p_ones,difference);
printf("kmin:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kmin:TS=[ ");printf("%f ",TS');printf("] (Samples)\n");
                        
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
Asq_k_sd=schurOneMPAlatticeAsq(wa,A1k_sd,A1epsilon,A1p_ones, ...
                               A2k_sd,A2epsilon,A2p_ones,difference);
Asq_kmin=schurOneMPAlatticeAsq(wa,A1k_min,A1epsilon_min,A1p_ones, ...
                               A2k_min,A2epsilon_min,A2p_ones,difference);
T_k=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
T_k_sd=schurOneMPAlatticeT(wt,A1k_sd,A1epsilon,A1p_ones, ...
                           A2k_sd,A2epsilon,A2p_ones,difference);
T_kmin=schurOneMPAlatticeT(wt,A1k_min,A1epsilon_min,A1p_ones, ...
                           A2k_min,A2epsilon_min,A2p_ones,difference);

% Plot pass-band amplitude
plot(wa*0.5/pi,10*log10(Asq_k),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_k_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_kmin),"linestyle","-.");
ylabel("Amplitude(dB)");
xlabel("Frequency");
strt=sprintf("Parallel one-multplier allpass lattice lowpass filter (nbits=12) :\
 fap=%g,fas=%g,dBap=%g,Wap=%g,td=%g,Wtp=%g",fap,fas,dBap,Wap,td,Wtp);
title(strt);
axis([0 max(fap,ftp) -0.2 0.05]);
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_kmin_pass_amplitude"),"-dpdflatex");
close

% Plot stop-band amplitude
plot(wa*0.5/pi,10*log10(Asq_k),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_k_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_kmin),"linestyle","-.");
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","northwest");
legend("boxoff");
legend("left");
ylabel("Amplitude(dB)");
xlabel("Frequency");
title(strt);
axis([fas  0.5 -70 -30]);
grid("on");
print(strcat(strf,"_kmin_stop_amplitude"),"-dpdflatex");
close

% Plot pass-band delay
plot(wt*0.5/pi,T_k,"linestyle","-", ...
     wt*0.5/pi,T_k_sd,"linestyle","--", ...
     wt*0.5/pi,T_kmin,"linestyle","-.");
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 max(fap,ftp) td+[-0.1 0.15]]);
grid("on");
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
title(strt);
print(strcat(strf,"_kmin_pass_delay"),"-dpdflatex");
close

% Plot responses for the introduction
print_for_web_page=false;
if print_for_web_page
  set(0,"defaultlinelinewidth",1.5);
endif
subplot(211)
[ax,h1,h2]=plotyy(wa(1:nap)*0.5/pi,10*log10([Asq_k(1:nap) Asq_kmin(1:nap)]), ...
                  wa(nas:n)*0.5/pi,10*log10([Asq_k(nas:n) Asq_kmin(nas:n)]));
% Hack to match colours. Is there an easier way with colormap?
h1c=get(h1,"color");
for k=1:2
  set(h2(k),"color",h1c{k});
endfor
set(h1(1),"linestyle","-");
set(h1(2),"linestyle","-.");
set(h2(1),"linestyle","-");
set(h2(2),"linestyle","-.");
if 0
  ylabel(ax(1),"Pass-band amplitude(dB)");
  ylabel(ax(2),"Stop-band amplitude(dB)");
else
  ylabel(ax(1),"Amplitude(dB)");
endif
% End of hack
axis(ax(1),[0 0.5 -0.15 0.05]);
axis(ax(2),[0 0.5 -70 -50]);
grid("on");
if ~print_for_web_page
  strt=sprintf("Parallel all-pass lattice low-pass filter (nbits=%d) : \
fap=%g,dBap=%g,fas=%g,dBas=%g,td=%g,tdr=%g",nbits,fap,dBap,fas,dBas,td,tdr);
  title(strt);
endif
subplot(212)
plot(wt*0.5/pi,T_k,"linestyle","-", ...
     wt*0.5/pi,T_kmin,"linestyle","-.");
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 11.46 11.54]);
legend("exact","3-s-d Lim and SOCP");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_kmin_intro"),"-dpdflatex");
if print_for_web_page
  print(strcat(strf,"_kmin_intro"),"-dsvg");
endif
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%d %% Coefficient word length\n",nbits);
fprintf(fid,"ndigits=%d %% Average number of signed digits per coef.\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"m1=%d %% Allpass model filter 1 denominator order\n",m1);
fprintf(fid,"m2=%d %% Allpass model filter 2 denominator order\n",m2);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wat=%d %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%d %% amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"td=%g %% Nominal pass band filter group delay\n",td);
fprintf(fid,"tdr=%g %% Delay pass band peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fclose(fid);

% Save results
eval(sprintf("save %s.mat \
n m1 m2 fap dBap Wap Wat fas dBas Was ftp td tdr Wtp rho tol ctol \
nbits ndigits ndigits_alloc \
A1k A1epsilon A1p A2k A2epsilon A2p \
A1k_min A1epsilon_min A2k_min A2epsilon_min",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
