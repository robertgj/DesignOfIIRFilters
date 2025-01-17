% socp_relaxation_schurOneMlattice_hilbert_10_nbits_test.m

% SOCP-relaxation optimisation of the response of a Schur one-multiplier
% lattice Hilbert filter with 10-bit 3-signed-digit coefficients.

% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="socp_relaxation_schurOneMlattice_hilbert_10_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Options
socp_relaxation_schurOneMlattice_hilbert_10_nbits_test_allocsd_Lim=true
socp_relaxation_schurOneMlattice_hilbert_10_nbits_test_allocsd_Ito=false

tic;

maxiter=2000
verbose=false
ftol=1e-8
ctol=ftol
nbits=10
nscale=2^(nbits-1);
ndigits=3

%
% Coefficients found by schurOneMlattice_socp_slb_hilbert_test.m
%
schurOneMlattice_socp_slb_hilbert_test_k2_coef; k0=k2;
schurOneMlattice_socp_slb_hilbert_test_epsilon2_coef; epsilon0=epsilon2;
schurOneMlattice_socp_slb_hilbert_test_p2_coef; p0=p2;
schurOneMlattice_socp_slb_hilbert_test_c2_coef; c0=c2;

%
% Frequency points
%
% The A and T responses are symmetric in frequency and the P response is
% antisymmetric. Any A and T constraints are duplicated at negative and
% positive frequencies resulting in a reduced rank constraint matrix.
% Avoid this problem by staggering the frequencies.
%
n=400;
nnrng=-(n-2):2:0;
nprng=1:2:(n-1);
w=pi*([nnrng(:);nprng(:)])/n;
non2=floor(n/2);

%
% Hilbert filter specification
%
dBar=0.2;dBat=dBar;Wap=1;Wat=0.1;
pp=5;ppr=0.01;Wpp=2;Wpt=0;
tp=(length(k0)-1)/2;
tpr=0.275;Wtp=0.01;Wtt=0;
ftt=0.08; % Transition band width at zero
ntt=floor(ftt*n);

% Amplitude constraints
wa=w;
Asqd=ones(n,1);
Asqr=1-(10^(-dBar/10));
Asqt=1-(10^(-dBat/10));
Asqdu=[(1+(Asqr/2))*ones(non2-ntt,1); ...
       (1+(Asqt/2))*ones(2*ntt,1); ...
       (1+(Asqr/2))*ones(non2-ntt,1)];
Asqdl=[(1-(Asqr/2))*ones(non2-ntt,1); ...
       (1-(Asqt/2))*ones(2*ntt,1); ...
       (1-(Asqr/2))*ones(non2-ntt,1)];
Wa=[Wap*ones(non2-ntt,1);Wat*ones((2*ntt),1);Wap*ones(non2-ntt,1)];

% Phase constraints
wp=w;
Pd=-wp*tp-(pp*pi)+([ones(non2-1,1);0;-ones(non2,1)]*pi/2);
Pdu=-wp*tp-(pp*pi)+([ones(non2+ntt,1);-ones(non2-ntt,1)]*pi/2)+(ppr*pi/2);
Pdl=-wp*tp-(pp*pi)+([ones(non2-ntt,1);-ones(non2+ntt,1)]*pi/2)-(ppr*pi/2);
Wp=[Wpp*ones(non2-ntt,1);Wpt*ones(2*ntt,1);Wpp*ones(non2-ntt,1)];

% Group delay constraints
wt=w;
Td=tp*ones(n,1);
Tdu=[(tp+(tpr/2))*ones(non2-ntt,1); ...
     10*tp*ones(2*ntt,1); ...
     (tp+(tpr/2))*ones(non2-ntt,1)];
Tdl=[(tp-(tpr/2))*ones(non2-ntt,1);...
     zeros(2*ntt,1); ...
     (tp-(tpr/2))*ones(non2-ntt,1)];
Wt=[Wtp*ones(non2-ntt,1);Wtt*ones(2*ntt,1);Wtp*ones(non2-ntt,1)];

% dAsqdw constraints
wd=[];
Dd=[];
Ddu=[];
Ddl=[];
Wd=[];

% Constraints on the coefficients
dmax=inf;
rho=1-ftol;
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

printf("k_allocsd_digits=[ ");
printf("%2d ",k_allocsd_digits);printf("]';\n");
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%2d");

printf("c_allocsd_digits=[ ");
printf("%2d ",c_allocsd_digits);printf("]';\n");
print_polynomial(c_allocsd_digits,"c_allocsd_digits", ...
                 strcat(strf,"_c_allocsd_digits.m"),"%2d");

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
Esq0=schurOneMlatticeEsq(k0,epsilon0,p0,c0,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Find kc0_sd error
Esq0_sd = ...
  schurOneMlatticeEsq(k0_sd,epsilon0,p0,c0_sd,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

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
Esq_min = ...
  schurOneMlatticeEsq(k_min,epsilon0,p_ones,c_min,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
print_polynomial(c_min,"c_min",nscale);
print_polynomial(c_min,"c_min",strcat(strf,"_c_min_coef.m"),nscale);
% Find the number of signed-digits and adders used by kc_sd
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
schurOneMlatticeFilter(k_min,epsilon0,p_ones,c_min,u,"round");
stdxf=std(xxf)

% Amplitude and phase at local peaks
Asq=schurOneMlatticeAsq(wa,k_min,epsilon0,p_ones,c_min);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,2,ntt,end])]);
AsqS=schurOneMlatticeAsq(wAsqS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
P=schurOneMlatticeP(wp,k_min,epsilon0,p_ones,c_min);
vPl=local_max(Pdl-P);
vPu=local_max(P-Pdu);
wPS=sort(unique([wp(vPl);wp(vPu);wp([1,ntt,end])]));
PS=schurOneMlatticeP(wPS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:PS=[ ");printf("%f ",mod((PS+(wPS*tp))'/pi,-1));
                        printf("] (rad./pi) adjusted for delay\n");
T=schurOneMlatticeT(wt,k_min,epsilon0,p_ones,c_min);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,ntt,end])]));
TS=schurOneMlatticeT(wTS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:TS=[ ");printf("%f ",TS);
                        printf("] (samples) adjusted for delay\n");

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_kc_min_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(Lim)& %8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,kc0_digits,kc0_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,kc_digits,kc_adders);
fclose(fid);

% Plot amplitude response
Asq_kc0=schurOneMlatticeAsq(wa,k0,epsilon0,p0,c0);
Asq_kc0_sd=schurOneMlatticeAsq(wa,k0_sd,epsilon0,p_ones,c0_sd);
Asq_kc_min=schurOneMlatticeAsq(wa,k_min,epsilon0,p_ones,c_min);
plot(wa*0.5/pi,10*log10(Asq_kc0),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_kc0_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_kc_min),"linestyle","-.", ...
     wa*0.5/pi,10*log10(Asqdu),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asqdl),"linestyle","-")
axis([0 0.5 -0.2 0.2]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","southeast");
legend("boxoff");
legend("left");
strt=sprintf("Hilbert filter:ftt=%g,dBar=%g,tp=%g,pr=%g,Wap=%g,Wpp=%g",
             ftt,dBar,tp,ppr,Wap,Wpp);
title(strt);
grid("on");
print(strcat(strf,"_kc_min_amplitude"),"-dpdflatex");
close

% Plot phase response
P_kc0=schurOneMlatticeP(wp,k0,epsilon0,p0,c0);
P_kc0_sd=schurOneMlatticeP(wp,k0_sd,epsilon0,p_ones,c0_sd);
P_kc_min=schurOneMlatticeP(wp,k_min,epsilon0,p_ones,c_min);
plot(wp*0.5/pi,(P_kc0+(wp*tp)+(pp*pi))/pi,"linestyle","-", ...
     wp*0.5/pi,(P_kc0_sd+(wp*tp)+(pp*pi))/pi,"linestyle","--", ...
     wp*0.5/pi,(P_kc_min+(wp*tp)+(pp*pi))/pi,"linestyle","-.", ...
     wp*0.5/pi,(Pdu+(wp*tp)+(pp*pi))/pi,"linestyle","-", ...
     wp*0.5/pi,(Pdl+(wp*tp)+(pp*pi))/pi,"linestyle","-");
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
axis([0 0.5 -0.53 -0.47]);
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","southeast");
legend("boxoff");
legend("left");
title(strt);
grid("on");
print(strcat(strf,"_kc_min_phase"),"-dpdflatex");
close

% Plot delay response
T_kc0=schurOneMlatticeT(wt,k0,epsilon0,p0,c0);
T_kc0_sd=schurOneMlatticeT(wt,k0_sd,epsilon0,p_ones,c0_sd);
T_kc_min=schurOneMlatticeT(wt,k_min,epsilon0,p_ones,c_min);
plot(wt*0.5/pi,T_kc0,"linestyle","-", ...
     wt*0.5/pi,T_kc0_sd,"linestyle","--", ...
     wt*0.5/pi,T_kc_min,"linestyle","-.", ...
     wt*0.5/pi,Tdu,"linestyle","-", ...
     wt*0.5/pi,Tdl,"linestyle","-")
axis([0 0.5 tp-0.2 tp+0.2]);
ylabel("Delay(samples)");
xlabel("Frequency");
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","southeast");
legend("boxoff");
legend("left");
title(strt);
grid("on");
print(strcat(strf,"_kc_min_delay"),"-dpdflatex");
close

% Plot poles and zeros
[n_min,d_min]=schurOneMlattice2tf(k_min,epsilon0,p0,c_min);
subplot(111);
zplane(roots(n_min),roots(d_min));
title(strt);
print(strcat(strf,"_kc_min_pz"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"rho=%f %% Constraint on lattice coefficient magnitudes\n",rho);
fprintf(fid,"ftt=%g %% Transition band width [0,ftt]\n",ftt);
fprintf(fid,"dBar=%g %% Amplitude pass band peak-to-peak ripple\n",dBar);
fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay (samples)\n",tp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple (rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

% Save results
eval(sprintf("save %s.mat k0 epsilon0 p0 c0 ftol ctol nbits ndigits \
ndigits_alloc ntt ftt dBar Wat Wap Pd pp ppr Wpp dmax rho k_min c_min",strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
