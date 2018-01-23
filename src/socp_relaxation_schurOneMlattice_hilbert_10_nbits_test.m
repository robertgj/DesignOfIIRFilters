% socp_relaxation_schurOneMlattice_hilbert_10_nbits_test.m

% SOCP-relaxation optimisation of the response of a Schur one-multiplier
% lattice Hilbert filter with 10-bit 3-signed-digit coefficients.

% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("socp_relaxation_schurOneMlattice_hilbert_10_nbits_test.diary");
unlink("socp_relaxation_schurOneMlattice_hilbert_10_nbits_test.diary.tmp");
diary socp_relaxation_schurOneMlattice_hilbert_10_nbits_test.diary.tmp

% Options
socp_relaxation_schurOneMlattice_hilbert_10_nbits_test_allocsd_Lim=true
socp_relaxation_schurOneMlattice_hilbert_10_nbits_test_allocsd_Ito=false

tic;

maxiter=2000
verbose=false
tol=1e-8
ctol=tol
nbits=10
nscale=2^(nbits-1);
ndigits=3
strf="socp_relaxation_schurOneMlattice_hilbert_10_nbits_test";

% Coefficients found by schurOneMlattice_sqp_slb_hilbert_test.m
k0 = [   0.0000000000,  -0.9135081383,   0.0000000000,   0.5546428065, ... 
         0.0000000000,  -0.0966755700,   0.0000000000,   0.0007462345, ... 
         0.0000000000,  -0.0020582169,   0.0000000000,   0.0015840382 ];
epsilon0 = [  0,  -1,  0,  -1, ... 
              0,   1,  0,  -1, ... 
              0,   1,  0,  -1 ];
p0 = [   2.2748007025,   2.2748007025,   0.4836328807,   0.4836328807, ... 
         0.9036013990,   0.9036013990,   0.9956211215,   0.9956211215, ... 
         0.9963643657,   0.9963643657,   0.9984172144,   0.9984172144 ];
c0 = [   0.0435189924,   0.0508921396,   0.2428519491,   0.2882277479, ... 
         0.1877845008,   0.2854412257,   0.6862739755,  -0.5909939642, ... 
        -0.1639093077,  -0.0790058478,  -0.0435858017,  -0.0252833112, ... 
        -0.0155222725 ];

% Hilbert filter specification
tp=(length(k0)-1)/2
ft=0.05 % Transition bandwidth [0 ft]

% Frequency points
n=400;
w=pi*(0:(n-1))'/n;

% Amplitude constraints
wa=w;
Asqd=ones(n,1);
dBap=0.17;
nt=ceil(ft*n/0.5);
dBapmask=dBap*[ones(nt,1);0.5*ones(n-nt,1)];
Asqdu=10.^(dBapmask/10);
Asqdl=10.^(-dBapmask/10);
Wat=tol;
Wap=1;
Wa=Wap*[Wat*ones(nt,1);ones(n-nt,1)];

% Group delay constraints
wt=[];
Td=[];
Tdu=[];
Tdl=[];
Wt=[];

% Phase constraints
wp=w;
Pd=-(wp*tp)-(pi/2);
pr=0.011;
prmask=pi*[4*ones(nt,1);2*pr*ones(nt,1);0.5*pr*ones(n-(2*nt),1)];
Pdu=Pd+prmask;
Pdl=Pd-prmask;
Wpp=1;
Wp=Wpp*[zeros(nt,1);ones(n-nt,1)];

% Constraints on the coefficients
dmax=inf;
rho=1-tol;
k0=k0(:);
c0=c0(:);
kc0=[k0;c0];
Nk=length(k0);
Nc=length(c0);
kc0_u=[rho*ones(size(k0));10*ones(size(c0))];
kc0_l=-kc0_u;
kc0_active=[find((k0)~=0);(Nk+(1:Nc))'];

% Allocate signed-digits to the coefficients
if socp_relaxation_schurOneMlattice_hilbert_10_nbits_test_allocsd_Lim
  ndigits_alloc=schurOneMlattice_allocsd_Lim(nbits,ndigits,k0,epsilon0,p0,c0, ...
                                             wa,Asqd,ones(size(wa)), ...
                                             wt,Td,ones(size(wt)), ...
                                             wp,Pd,ones(size(wp)));
elseif socp_relaxation_schurOneMlattice_hilbert_10_nbits_test_allocsd_Ito
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

% Find kc0 error
Esq0=schurOneMlatticeEsq(k0,epsilon0,p0,c0,wa,Asqd,Wa,wt,Td,Wt);

% Find kc0_sd error
Esq0_sd=schurOneMlatticeEsq(k0_sd,epsilon0,p0,c0_sd,wa,Asqd,Wa,wt,Td,Wt);

% Find the number of signed-digits and adders used by kc0_sd
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

  % Try to solve the current SOCP problem with bounds kc_bu and kc_bl
  try
    % Find the SOCP PCLS solution for the remaining active coefficents
    [nextk,nextc,slb_iter,opt_iter,func_iter,feasible] = ...
      schurOneMlattice_slb(@schurOneMlattice_socp_mmse, ...
                           kc_b(1:Nk),epsilon0,p0,kc_b((Nk+1):end), ...
                           kc_bu,kc_bl,kc_active,dmax, ...
                           wa,Asqd,Asqdu,Asqdl,Wa, ...
                           wt,Td,Tdu,Tdl,Wt, ...
                           wp,Pd,Pdu,Pdl,Wp, ...
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
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
printf("epsilon0=[ ");printf("%d ",epsilon0');printf("]';\n");
printf("p_ones=[ ");printf("%g ",p_ones');printf("]';\n");
print_polynomial(c_min,"c_min",nscale);
print_polynomial(c_min,"c_min",strcat(strf,"_c_min_coef.m"),nscale);
% Find the number of signed-digits and adders used by kc_sd
[kc_digits,kc_adders]=SDadders(kc_sd(kc0_active),nbits);
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

% Amplitude and phase at local peaks
Asq=schurOneMlatticeAsq(wa,k_min,epsilon0,p_ones,c_min);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nt,end])]);
AsqS=schurOneMlatticeAsq(wAsqS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
P=schurOneMlatticeP(wp,k_min,epsilon0,p_ones,c_min);
vPl=local_max(Pdl-P);
vPu=local_max(P-Pdu);
wPS=sort(unique([wp(vPl);wp(vPu);wp([1,nt,end])]));
PS=schurOneMlatticeP(wPS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:PS=[ ");printf("%f ",mod((PS+(wPS*tp))'/pi,-1));
                        printf("] (rad./pi) adjusted for delay\n");

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_kc_min_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(Lim)& %8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,kc0_digits,kc0_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,kc_digits,kc_adders);
fclose(fid);

% Plot response
subplot(211);
Asq_kc0=schurOneMlatticeAsq(wa,k0,epsilon0,p0,c0);
Asq_kc0_sd=schurOneMlatticeAsq(wa,k0_sd,epsilon0,p0,c0_sd);
Asq_kc_min=schurOneMlatticeAsq(wa,k_min,epsilon0,p0,c_min);
plot(wa*0.5/pi,10*log10(Asq_kc0),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_kc0_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_kc_min),"linestyle","-.");
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
ylabel("Amplitude(dB)");
strt=sprintf("Hilbert filter:ft=%g,dBap=%g,tp=%g,pr=%g,Wap=%g,Wpp=%g",
             ft,dBap,tp,pr,Wap,Wpp);
title(strt);
axis([0  0.5 -0.2 0.4]);
grid("on");
hold on
plot(wa*0.5/pi,10*log10([Asqdl Asqdu]));
subplot(212);
P_kc0=schurOneMlatticeP(wp,k0,epsilon0,p0,c0);
P_kc0_sd=schurOneMlatticeP(wp,k0_sd,epsilon0,p0,c0_sd);
P_kc_min=schurOneMlatticeP(wp,k_min,epsilon0,p0,c_min);
plot(wp*0.5/pi,(P_kc0+(wp*tp))/pi,"linestyle","-", ...
     wp*0.5/pi,(P_kc0_sd+(wp*tp))/pi,"linestyle","--", ...
     wp*0.5/pi,(P_kc_min+(wp*tp))/pi,"linestyle","-.");
ylabel("Phase(rad./pi)\n(Adjusted for delay)");
xlabel("Frequency");
axis([0 0.5 -0.53 -0.47]);
grid("on");
hold on
plot(wp*0.5/pi,([Pdu Pdl]+(wp*tp))/pi);
print(strcat(strf,"_kc_min"),"-dpdflatex");
close

% Plot poles and zeros
[n_min,d_min]=schurOneMlattice2tf(k_min,epsilon0,p0,c_min);
subplot(111);
zplane(roots(n_min),roots(d_min));
title(strt);
print(strcat(strf,"_kc_min_pz"),"-dpdflatex");
close 

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"rho=%f %% Constraint on lattice coefficient magnitudes\n",rho);
fprintf(fid,"ft=%g %% Transition band width [0,ft]\n",ft);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay (samples)\n",tp);
fprintf(fid,"pr=%g * pi %% Phase pass band peak-to-peak ripple (rad.)\n",pr);
fprintf(fid,"Wpp=%d %% Phase pass band weight\n",Wpp);
fclose(fid);

% Save results
save socp_relaxation_schurOneMlattice_hilbert_10_nbits_test.mat ...
     k0 epsilon0 p0 c0 ...
     tol ctol nbits ndigits ndigits_alloc ...
     nt Asqd dBap Wat Wap Pd pr Wpp dmax rho ...
     k_min c_min 
       
% Done
toc;
diary off
movefile socp_relaxation_schurOneMlattice_hilbert_10_nbits_test.diary.tmp ...
         socp_relaxation_schurOneMlattice_hilbert_10_nbits_test.diary;
