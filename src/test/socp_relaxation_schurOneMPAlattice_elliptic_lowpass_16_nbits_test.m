% socp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.m

% SOCP-relaxation optimisation of the response of an elliptic low-pass filter
% composed of parallel Schur one-multiplier all-pass lattice filters
% with 16-bit 3-signed-digit coefficients.

% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="socp_relaxation_schurOneMPAlattice_elliptic_lowpass_16_nbits_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

% Options
use_schurOneMPAlattice_allocsd_Lim=false
use_schurOneMPAlattice_allocsd_Ito=false

tic;

maxiter=2000
verbose=false

% Pass separate tolerances for the coefficient step and SeDuMi eps.
ftol=1e-8
ctol=1e-10
del.dtol=ctol;
del.stol=ctol;
warning("Using coef. delta tolerance=%g, SeDuMi eps=%g\n",ctol,del.stol);


% Initial elliptic filter passband edge 0.15, passband ripple 0.02dB,
% and 84dB stopband attenuation. Resulting stopband edge is approx 0.17074.
[N0,D0]=ellip(11,0.02,84,2*0.15);
print_polynomial(N0,"N0");
print_polynomial(N0,"N0",strcat(strf,"_N0_coef.m"));
print_polynomial(D0,"D0");
print_polynomial(D0,"D0",strcat(strf,"_D0_coef.m"));

% Lattice decomposition of Da1 and Db1
[Da1,Db1]=tf2pa(N0,D0);
[A1k0,A1epsilon0,A1p0,~] = tf2schurOneMlattice(flipud(Da1(:)),Da1(:));
[A2k0,A2epsilon0,A2p0,~] = tf2schurOneMlattice(flipud(Db1(:)),Db1(:));
difference=false;

% Initialise coefficient range vectors
A1p_ones=ones(size(A1p0));
A2p_ones=ones(size(A2p0));
NA1=length(A1k0);
NA2=length(A2k0);
R1=1:NA1;
R2=(NA1+1):(NA1+NA2);

% Lowpass filter specification
fap=0.15
dBap=0.03
Wap=1
Wat=ftol
fas=0.171
dBas=81
Was=1e7

% Desired squared magnitude response
n=1000;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
wa=(0:(n-1))'*pi/n;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Sanity checks
nchka=[nap-1,nap,nap+1,nas-1,nas,nas+1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Phase constraints
wp=[];Pd=[];Pdu=[];Pdl=[];Wp=[];

% Group delay constraints
wt=[];Td=[];Tdu=[];Tdl=[];Wt=[];

% dAsqdw constraints
wd=[];Dd=[];Ddu=[];Ddl=[];Wd=[];

% Linear constraints
dmax=inf;
rho=127/128
k0=[A1k0(:);A2k0(:)];
k_u=rho*ones(size(k0));
k_l=-k_u;
k_active=find(k0~=0);

% Initialise coefficient vectors
A1k=A1k0(:);
A1p=A1p_ones(:);
A1epsilon=A1epsilon0(:);
A2k=A2k0(:);
A2p=A2p_ones(:);
A2epsilon=A2epsilon0(:);
NA1=length(A1k);
NA2=length(A2k);
R1=1:NA1;
R2=(NA1+1):(NA1+NA2);
k=[A1k(:);A2k(:)];

% Allocate signed-digits to the coefficients
nbits=16
nscale=2^(nbits-1);
ndigits=5
if use_schurOneMPAlattice_allocsd_Lim
  sd_str="(Lim)";
  ndigits_alloc=schurOneMPAlattice_allocsd_Lim ...
                  (nbits,ndigits,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                   difference,wa,Asqd,ones(size(Wa)),wt,Td,ones(size(Wt)), ...
                   wp,Pd,ones(size(Wp)),wd,Dd,ones(size(Wd)));
elseif use_schurOneMPAlattice_allocsd_Ito
  sd_str="(Ito)";
  ndigits_alloc=schurOneMPAlattice_allocsd_Ito ...
                  (nbits,ndigits,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                   difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
else
  sd_str="";
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
A1k0_sd=k_sd(R1);
A2k0_sd=k_sd(R2);
print_polynomial(A1k0_sd,"A1k0_sd",nscale);
print_polynomial(A1k0_sd,"A1k0_sd",strcat(strf,"_A1k0_sd_coef.m"),nscale);
print_polynomial(A2k0_sd,"A2k0_sd",nscale);
print_polynomial(A2k0_sd,"A2k0_sd",strcat(strf,"_A2k0_sd_coef.m"),nscale);

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

% Find initial error
Esq0=schurOneMPAlatticeEsq(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                           difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
printf("Initial Esq0=%g\n",Esq0);

% Find k_sd error
Esq0_sd=schurOneMPAlatticeEsq ...
          (k_sd(R1),A1epsilon,A1p,k_sd(R2),A2epsilon,A2p,difference, ...
           wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
printf("Esq0_sd=%g\n",Esq0_sd);

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
    % Find the SOCP PCLS solution for the remaining active coefficients
    [nextA1k,nextA2k,slb_iter,opt_iter,func_iter,feasible] = ...
    schurOneMPAlattice_slb ...
      (@schurOneMPAlattice_socp_mmse, ...
       kopt_b(R1),A1epsilon,A1p,kopt_b(R2),A2epsilon,A2p,difference, ...
       kopt_bu,kopt_bl,kopt_active,dmax, ...
       wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
       wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
       maxiter,del,ctol,verbose);
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
[A1epsilon_min,A1p_min]=schurOneMscale(A1k_min);
A2k_min=kopt(R2);
[A2epsilon_min,A2p_min]=schurOneMscale(A2k_min);
Esq_min=schurOneMPAlatticeEsq ...
          (A1k_min,A1epsilon_min,A1p_min, ...
           A2k_min,A2epsilon_min,A2p_min,difference, ...
           wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
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
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       kopt_adders,nbits);
fid=fopen(strcat(strf,"_kmin_digits.tab"),"wt");
fprintf(fid,"$%d$",kopt_digits);
fclose(fid);
fid=fopen(strcat(strf,"_kmin_adders.tab"),"wt");
fprintf(fid,"$%d$",kopt_adders);
fclose(fid);

% Amplitude and delay at local peaks
Asq=schurOneMPAlatticeAsq(wa,A1k_min,A1epsilon_min,A1p_min,A2k_min, ...
                          A2epsilon_min,A2p_min,difference);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AsqS=schurOneMPAlatticeAsq(wAsqS,A1k_min,A1epsilon_min,A1p_min, ...
                           A2k_min,A2epsilon_min,A2p_min,difference);
printf("kmin:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kmin:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
                       
% Check constraints after the last truncation
vS=schurOneMPAlattice_slb_update_constraints ...
     (Asq,Asqdu,Asqdl,Wa,[],[],[],[],[],[],[],[],[],[],[],[],ctol);
if ~schurOneMPAlattice_slb_constraints_are_empty(vS)
  printf("These constraints on the correction filter response are not met:\n");
  schurOneMPAlattice_slb_show_constraints(vS,wa,Asq,[],[],[],[],[],[])
endif

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_kmin_cost.tab"),"wt");
fprintf(fid,"Initial & %8.2e & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit%s & %8.2e & %d & %d \\\\\n", ...
        nbits,ndigits,sd_str,Esq0_sd,k_digits,k_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %8.2e & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_min,kopt_digits,kopt_adders);
fclose(fid);

%
% Plot response
%

% Find squared-magnitude and group-delay
Asq_k0=schurOneMPAlatticeAsq(wa, ...
                             A1k0,A1epsilon0,A1p0, ...
                             A2k0,A2epsilon0,A2p0, ...
                             difference);
Asq_k0_sd=schurOneMPAlatticeAsq(wa, ...
                                A1k0_sd,A1epsilon0,A1p_min, ...
                                A2k0_sd,A2epsilon0,A2p_min, ...
                                difference);
Asq_kmin=schurOneMPAlatticeAsq(wa, ...
                               A1k_min,A1epsilon_min,A1p_min, ...
                               A2k_min,A2epsilon_min,A2p_min, ...
                               difference);

% Plot amplitude response
[ax,h1,h2]=plotyy(wa(1:nap)*0.5/pi, ...
                  10*log10([Asq_k0(1:nap) Asq_k0_sd(1:nap) Asq_kmin(1:nap)]), ...
                  wa(nas:n)*0.5/pi, ...
                  10*log10([Asq_k0(nas:n) Asq_k0_sd(nas:n) Asq_kmin(nas:n)]));
% Hack to match colours. Is there an easier way with colormap?
h1c=get(h1,"color");
for k=1:3
  set(h2(k),"color",h1c{k});
endfor
set(h1(1),"linestyle","-");
set(h1(2),"linestyle","--");
set(h1(3),"linestyle","-.");
set(h2(1),"linestyle","-");
set(h2(2),"linestyle","--");
set(h2(3),"linestyle","-.");
ylabel(ax(1),"Amplitude(dB)");
% End of hack
axis(ax(1),[0 0.5 -0.03 0.01]);
axis(ax(2),[0 0.5 -95 -75]);
xlabel("Frequency");
legend("Initial",sprintf("s-d%s",sd_str),"s-d(min)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
strt=sprintf(["Parallel all-pass lattice elliptic low-pass filter : ", ...
              "nbits=%d,ndigits=%d,fap=%g,dBap=%g,fas=%g,dBas=%g"], ...
             nbits,ndigits,fap,dBap,fas,dBas);
title(strt);
zticks([]);
print(strcat(strf,"_kmin"),"-dpdflatex");
close

% Find the corresponding transfer function polynomials
[N_min,D_min]=schurOneMPAlattice2tf(A1k_min,A1epsilon_min,A1p_min, ...
                                    A2k_min,A2epsilon_min,A2p_min, ...
                                    difference);
print_polynomial(N_min,"N_min");
print_polynomial(N_min,"N_min",strcat(strf,"_N_min_coef.m"));
print_polynomial(D_min,"D_min");
print_polynomial(D_min,"D_min",strcat(strf,"_D_min_coef.m"));
Hchk=freqz(N_min(:),D_min(:),wa);
if max(abs(abs(Hchk)-sqrt(Asq_kmin))) > 1e6*eps
  error("max(abs(abs(Hchk)-sqrt(Asq_kmin)))(%g*eps) > 1e6*eps", ...
        max(abs(abs(Hchk)-sqrt(Asq_kmin)))/eps);
endif

% Pole-zero plot
zplane(qroots(N_min(:)),qroots(D_min(:)));
title(strt);
zticks([]);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%d %% Coefficient word length\n",nbits);
fprintf(fid,"ndigits=%d %% Signed digits per coef.\n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wat=%d %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%d %% amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);

% Save results
eval(sprintf(["save %s.mat n fap dBap Wap Wat fas dBas Was rho ftol ctol ", ...
              "use_schurOneMPAlattice_allocsd_Lim ", ...
              "use_schurOneMPAlattice_allocsd_Ito ", ...
              "nbits ndigits ndigits_alloc ", ...
              "D0 N0 A1k0 A1epsilon0 A1p0 A2k0 A2epsilon0 A2p0 ", ...
              "A1k0_sd A2k0_sd A1k_min A1epsilon_min A1p_min ", ...
              "A2k_min A2epsilon_min A2p_min N_min D_min"], strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
