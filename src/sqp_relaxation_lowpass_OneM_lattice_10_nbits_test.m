% sqp_relaxation_lowpass_OneM_lattice_10_nbits_test.m

% SQP-relaxation optimisation of the response of a Schur one-multiplier
% lattice lowpass filter with 10-bit 3-signed-digit coefficients.

% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("sqp_relaxation_lowpass_OneM_lattice_10_nbits_test.diary");
unlink("sqp_relaxation_lowpass_OneM_lattice_10_nbits_test.diary.tmp");
diary sqp_relaxation_lowpass_OneM_lattice_10_nbits_test.diary.tmp

% Options
sqp_relaxation_lowpass_OneM_lattice_10_nbits_test_allocsd_Lim=true
sqp_relaxation_lowpass_OneM_lattice_10_nbits_test_allocsd_Ito=false

tic;

maxiter=2000
verbose=false
tol=1e-4
nbits=10
nscale=2^(nbits-1);
ndigits=3
strF="sqp_relaxation_lowpass_OneM_lattice_10_nbits_test";

% Coefficients found by schurOneMlattice_sqp_slb_lowpass_test.m
k0 = [  -0.7375771181,   0.7329492530,  -0.6489740765,   0.4943363006, ... 
        -0.2824593372,   0.0878212134,  -0.0000000000,  -0.0000000000, ... 
         0.0000000000,   0.0000000000 ]';
epsilon0 = [ -1, -1, -1, -1, ... 
             -1, -1,  1,  1, ... 
             -1, -1 ]';
p0 = [   1.5591179441,   0.6059095195,   1.5434899280,   0.7121418051, ... 
         1.2242208323,   0.9157168850,   1.0000000000,   1.0000000000, ... 
         1.0000000000,   1.0000000000 ]';
c0 = [   0.2287455707,   0.7274997803,   0.1030199742,  -0.0659731942, ... 
        -0.0487519200,  -0.0063882219,   0.0239044428,   0.0157765877, ... 
        -0.0023124161,  -0.0090627662,  -0.0052625492 ]';
k0=k0(:);
c0=c0(:);
kc0=[k0;c0];
Nk=length(k0);
Nc=length(c0);

% Deczky3 lowpass filter specification
n=400
fap=0.15,dBap=0.4,Wap=1
fas=0.3,dBas=37,Was=1e4
ftp=0.25,tp=10,tpr=0.1,Wtp=1

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=[ones(nap,1); zeros(n-nap,1)];
Asqdu=[ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1); zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);zeros(nas-nap-1,1);Was*ones(n-nas+1,1)];

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

% Constraints on the coefficients
dmax=0.05
rho=127/128
kc0_u=[rho*ones(size(k0));10*ones(size(c0))];
kc0_l=-kc0_u;

% Allocate signed-digits to the coefficients
if sqp_relaxation_lowpass_OneM_lattice_10_nbits_test_allocsd_Lim
  ndigits_alloc=schurOneMlattice_allocsd_Lim(nbits,ndigits,k0,epsilon0,p0,c0, ...
                                             wa,Asqd,ones(size(wa)), ...
                                             wt,Td,ones(size(wt)), ...
                                             wp,Pd,ones(size(wp)));
elseif sqp_relaxation_lowpass_OneM_lattice_10_nbits_test_allocsd_Ito
  ndigits_alloc=schurOneMlattice_allocsd_Ito(nbits,ndigits,k0,epsilon0,p0,c0, ...
                                             wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
else
  ndigits_alloc=zeros(size(kc0));
  ndigits_alloc(kc0_active)=ndigits;
endif
k_allocsd_digits=int16(ndigits_alloc(1:Nk));
c_allocsd_digits=int16(ndigits_alloc((Nk+1):end));
% Find the signed-digit approximations to k0 and c0
[kc0_sd,kc0_sdu,kc0_sdl]=flt2SD(kc0,nbits,ndigits_alloc);
k0_sd=kc0_sd(1:Nk);
k0_sd=k0_sd(:);
c0_sd=kc0_sd((Nk+1):end);
c0_sd=c0_sd(:);
printf("nscale*k0_sd_=[ ");printf("%g ",nscale*k0_sd');printf("]';\n");
printf("nscale*c0_sd=[ ");printf("%g ",nscale*c0_sd');printf("]';\n");
print_polynomial(nscale*k0_sd,sprintf("%d*k0_sd",nscale), ...
                 strcat(strF,"_k0_sd_coef.m"),"%6d");
print_polynomial(nscale*c0_sd,sprintf("%d*c0_sd",nscale), ...
                 strcat(strF,"_c0_sd_coef.m"),"%6d");

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

% Find kc0 error
Esq0=schurOneMlatticeEsq(k0,epsilon0,p0,c0,wa,Asqd,Wa,wt,Td,Wt);

% Find kc0_sd error
Esq0_sd=schurOneMlatticeEsq(k0_sd,epsilon0,p0,c0_sd,wa,Asqd,Wa,wt,Td,Wt);

% Find the number of signed-digits and addersused by kc0_sd
[kc0_digits,kc0_adders]=SDadders(kc0_sd(kc0_active),nbits);

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

  % Try to solve the current SQP problem with bounds kc_bu and kc_bl
  try
    % Find the SQP PCLS solution for the remaining active coefficents
    [nextk,nextc,slb_iter,opt_iter,func_iter,feasible] = ...
      schurOneMlattice_slb(@schurOneMlattice_sqp_mmse, ...
                           kc_b(1:Nk),epsilon0,p0,kc_b((Nk+1):end), ...
                           kc_bu,kc_bl,kc_active,dmax, ...
                           wa,Asqd,Asqdu,Asqdl,Wa, ...
                           wt,Td,Tdu,Tdl,Wt, ...
                           wp,Pd,Pdu,Pdl,Wp, ...
                           maxiter,tol,verbose);
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
    error("SQP problem infeasible!");
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
p_ones=ones(size(p0));
kc_min=kc;
k_min=kc(1:Nk);
c_min=kc((Nk+1):end);
Esq_min=schurOneMlatticeEsq(k_min,epsilon0,p_ones,c_min,wa,Asqd,Wa,wt,Td,Wt);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
printf("nscale*k_min=[ ");printf("%g ",nscale*k_min');printf("]';\n");
printf("epsilon0=[ ");printf("%d ",epsilon0');printf("]';\n");
printf("p_ones=[ ");printf("%g ",p_ones');printf("]';\n");
printf("nscale*c_min=[ ");printf("%g ",nscale*c_min');printf("]';\n");
print_polynomial(nscale*k_min,sprintf("%d*k_min",nscale), ...
                 strcat(strF,"_k_min_coef.m"),"%6d");
print_polynomial(nscale*c_min,sprintf("%d*c_min",nscale), ...
                 strcat(strF,"_c_min_coef.m"),"%6d");
% Find the number of signed-digits used
[kc_digits,kc_adders]=SDadders(kc_min(kc0_active),nbits);
printf("%d signed-digits used\n",kc_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kc_adders,nbits);

% Filter a quantised noise signal and check the state variables
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

% Amplitude and delay at local peaks
Asq=schurOneMlatticeAsq(wa,k_min,epsilon0,p_ones,c_min);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AsqS=schurOneMlatticeAsq(wAsqS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMlatticeT(wt,k_min,epsilon0,p_ones,c_min);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,ntp,end])]));
TS=schurOneMlatticeT(wTS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:TS=[ ");printf("%f ",TS(:)');printf(" ]'\n");

% Make a LaTeX table for cost
fid=fopen(strcat(strF,"_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(Lim)& %8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,kc0_digits,kc0_adders);
fprintf(fid,"%d-bit %d-signed-digit(SQP-relax) & %8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,kc_digits,kc_adders);
fclose(fid);

% Plot response
strT=sprintf("Schur One-M lattice lowpass : \
fap=%g,dBap=%g,ftp=%g,tp=%g,tpr=%g,fas=%g,dBas=%g",fap,dBap,ftp,tp,tpr,fas,dBas);
schurOneMlattice_sqp_slb_lowpass_plot(k_min,epsilon0,p_ones,c_min, ...
                                      fap,dBap,ftp,tp,tpr,fas,dBas, ...
                                      strcat(strF,"_kc_min"),strT);

% Filter specification
fid=fopen(strcat(strF,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"nbits=%d %% coefficient length in bits\n",nbits);
fprintf(fid,"ndigits=%d %% signed-digits per coefficient\n",ndigits);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"length(c0)=%d %% Tap coefficients\n",length(c0));
fprintf(fid,"sum(k0~=0)=%d %% Num. non-zero lattice coefficients\n",sum(k0~=0));
fprintf(fid,"dmax=%f %% Constraint on norm of coefficient SQP step size\n",dmax);
fprintf(fid,"rho=%f %% Constraint on lattice coefficient magnitudes\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%d %% amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fclose(fid);

% Save results
save sqp_relaxation_lowpass_OneM_lattice_10_nbits_test.mat ...
     k0 epsilon0 p0 c0 tol nbits ndigits ndigits_alloc ...
     fap dBap Wap ftp tp tpr Wtp fas dBas Was dmax rho k_min c_min 
       
% Done
toc;
diary off
movefile sqp_relaxation_lowpass_OneM_lattice_10_nbits_test.diary.tmp ...
       sqp_relaxation_lowpass_OneM_lattice_10_nbits_test.diary;
