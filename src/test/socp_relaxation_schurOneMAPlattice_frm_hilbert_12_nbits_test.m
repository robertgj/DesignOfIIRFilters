% socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.m

% SOCP-relaxation optimisation of the response of an FRM Hilbert filter
% with 12-bit 3-signed-digit coefficients and an allpass model filter
% implemented as a Schur one-multiplier lattice.

% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary");
delete("socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary.tmp");
diary socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary.tmp

% Options
socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test_allocsd_Lim=true
socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test_allocsd_Ito=false

tic;


%
% Initial filter from schurOneMAPlattice_frm_hilbert_socp_slb_test.m
%
schurOneMAPlattice_frm_hilbert_socp_slb_test_k2_coef;
schurOneMAPlattice_frm_hilbert_socp_slb_test_p2_coef;
schurOneMAPlattice_frm_hilbert_socp_slb_test_epsilon2_coef;
schurOneMAPlattice_frm_hilbert_socp_slb_test_u2_coef;
schurOneMAPlattice_frm_hilbert_socp_slb_test_v2_coef;
k0=k2;epsilon0=epsilon2;p0=p2;u0=u2;v0=v2;

%
% Filter specification
%
tol=5e-5
ctol=tol
maxiter=2000
verbose=false
Mmodel=7; % Model filter decimation
Dmodel=9; % Desired model filter passband delay
mr=length(k0); % Model filter order
dmask=2*length(v0); % FIR masking filter delay
fap=0.01 % Amplitude pass band edge
fas=0.49 % Amplitude stop band edge
dBap=0.22 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
ftp=0.01 % Delay pass band edge
fts=0.49 % Delay stop band edge
tp=(Mmodel*Dmodel)+dmask % Nominal FRM filter group delay
tpr=tp/50 % Peak-to-peak pass band delay ripple
Wtp=0.005 % Pass band delay weight
fpp=0.01 % Phase pass band edge
fps=0.49 % Phase stop band edge
pp=-pi/2 % Nominal passband phase (adjusted for delay)
ppr=(pi/2)/50 % Peak-to-peak pass band phase ripple
Wpp=0.005 % Pass band phase weight
nbits=12; % Coefficient length
ndigits=2; % Signed-digits per coefficient
nscale=2^(nbits-1);

%
% Frequency vectors
%
n=800;
w=(0:(n-1))'*pi/n;

% Amplitude constraints
nap=floor(fap*n/0.5)+1;
nas=ceil(fas*n/0.5)+1;
wa=w(nap:nas);
Asqd=ones(size(wa));
Asqdu=Asqd;
Asqdl=(10^(-dBap/10))*ones(size(wa));
Wa=Wap*ones(size(wa));

% Group delay constraints
ntp=floor(ftp*n/0.5)+1;
nts=ceil(fts*n/0.5)+1;
wt=w(ntp:nts);
Td=zeros(size(wt));
Tdu=(tpr/2)*ones(size(wt));
Tdl=-Tdu;
Wt=Wtp*ones(size(wt));

% Phase constraints
npp=floor(fpp*n/0.5)+1;
nps=ceil(fps*n/0.5)+1;
wp=w(npp:nps);
Pd=pp*ones(size(wp));
Pdu=pp+(ppr/2)*ones(size(wp));
Pdl=pp-(ppr/2)*ones(size(wp));
Wp=Wpp*ones(size(wp));

% Coefficient constraints
rho=127/128;
kuv0_u=[rho*ones(size(k0(:)));10*ones(size(u0(:)));10*ones(size(v0(:)))];
kuv0_l=-kuv0_u;
kuv0_active=(1:(length(k0)+length(u0)+length(v0)))';
dmax=inf;

% Common strings
strt= ...
sprintf("FRM Hilbert %%s %%s : Mmodel=%d,Dmodel=%d,fap=%g,fas=%g,tp=%d",...
        Mmodel,Dmodel,fap,fas,tp);
strf="socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test";

% Initialise coefficient vectors
Nk=length(k0);
Nu=length(u0);
Nv=length(v0);
kuv0=[k0(:);u0(:);v0(:)];
kuv=kuv0;
kuv_l=kuv0_l;
kuv_u=kuv0_u;
Rk=1:Nk;
Ru=(Nk+1):(Nk+Nu);
Rv=(Nk+Nu+1):(Nk+Nu+Nv);

% Allocate signed-digits to the coefficients
if socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test_allocsd_Lim
  ndigits_alloc=schurOneMAPlattice_frm_hilbert_allocsd_Lim ...
                  (nbits,ndigits,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                   wa,Asqd,ones(size(Wa)), ...
                   wt,Td,ones(size(Wt)), ...
                   wp,Pd,ones(size(Wp)));
elseif socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test_allocsd_Ito
  ndigits_alloc=schurOneMAPlattice_frm_hilbert_allocsd_Ito ...
                  (nbits,ndigits,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
else
  ndigits_alloc=zeros(size(kuv0));
  ndigits_alloc(kuv0_active)=ndigits;
endif
k_allocsd_digits=int16(ndigits_alloc(Rk));
u_allocsd_digits=int16(ndigits_alloc(Ru));
v_allocsd_digits=int16(ndigits_alloc(Rv));
print_polynomial(k_allocsd_digits,"k_allocsd_digits");
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%2d");
print_polynomial(u_allocsd_digits,"u_allocsd_digits");
print_polynomial(u_allocsd_digits,"u_allocsd_digits", ...
                 strcat(strf,"_u_allocsd_digits.m"),"%2d");
print_polynomial(v_allocsd_digits,"v_allocsd_digits");
print_polynomial(v_allocsd_digits,"v_allocsd_digits", ...
                 strcat(strf,"_v_allocsd_digits.m"),"%2d");

% Find the signed-digit approximations to k0,u0 and v0
[kuv0_sd,kuv0_sdu,kuv0_sdl]=flt2SD(kuv0,nbits,ndigits_alloc);
k0_sd=kuv0_sd(Rk);
k0_sd=k0_sd(:);
[epsilon0_sd,p0_sd]=schurOneMscale(k0_sd);
u0_sd=kuv0_sd(Ru);
u0_sd=u0_sd(:);
v0_sd=kuv0_sd(Rv);
v0_sd=v0_sd(:);
print_polynomial(k0_sd,"k0_sd",nscale);
print_polynomial(k0_sd,"k0_sd",strcat(strf,"_k0_sd_coef.m"),nscale);
print_polynomial(epsilon0_sd,"epsilon0_sd",nscale);
print_polynomial(epsilon0_sd,"epsilon0_sd", ...
                 strcat(strf,"_epsilon0_sd_coef.m"),"%2d");
print_polynomial(p0_sd,"p0_sd");
print_polynomial(p0_sd,"p0_sd",strcat(strf,"_p0_sd_coef.m"));
print_polynomial(u0_sd,"u0_sd",nscale);
print_polynomial(u0_sd,"u0_sd",strcat(strf,"_u0_sd_coef.m"),nscale);
print_polynomial(v0_sd,"v0_sd",nscale);
print_polynomial(v0_sd,"v0_sd",strcat(strf,"_v0_sd_coef.m"),nscale);

% Initialise kuv_active
kuv0_sdul=kuv0_sdu-kuv0_sdl;
kuv0_active=find(kuv0_sdul~=0);
n_active=length(kuv0_active);
kuv_active=kuv0_active;

% Check for consistent upper and lower bounds
if any(kuv0_sdl>kuv0_sdu)
  error("found kuv0_sdl>kuv0_sdu");
endif
if any(kuv0_sdl>kuv0_sdu)
  error("found kuv0_sdl>kuv0_sdu");
endif
if any(kuv0_sd(kuv0_active)>kuv0_sdu(kuv0_active))
  error("found kuv0_sd(kuv0_active)>kuv0_sdu(kuv0_active)");
endif
if any(kuv0_sdl(kuv0_active)>kuv0_sd(kuv0_active))
  error("found kuv0_sdl(kuv0_active)>kuv0_sd(kuv0_active)");
endif
if any(kuv0(kuv0_active)>kuv0_sdu(kuv0_active))
  error("found kuv0(kuv0_active)>kuv0_sdu(kuv0_active)");
endif
if any(kuv0_sdl(kuv0_active)>kuv0(kuv0_active))
  error("found kuv0_sdl>kuv0");
endif

% Find kuv0 error
Esq0=schurOneMAPlattice_frm_hilbertEsq ...
       (k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
        wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Find kuv0_sd error
Esq0_sd=schurOneMAPlattice_frm_hilbertEsq ...
          (k0_sd,epsilon0,p0,u0_sd,v0_sd,Mmodel,Dmodel, ...
           wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Find the number of signed-digits and adders used by kuv0_sd
[kuv0_digits,kuv0_adders]=SDadders(kuv0_sd(kuv0_active),nbits);

% Initialise the vector of filter coefficients to be optimised
kuv=zeros(size(kuv0));
kuv(kuv0_active)=kuv0(kuv0_active);
kuv_l=kuv0_l;
kuv_u=kuv0_u;
kuv_active=kuv0_active;

%
% Loop finding truncated coefficients
%

% Fix one coefficient at each iteration 
while ~isempty(kuv_active)
  
  % Define filter coefficients 
  [kuv_sd,kuv_sdu,kuv_sdl]=flt2SD(kuv,nbits,ndigits_alloc);
  kuv_sdul=kuv_sdu-kuv_sdl;
  kuv_b=kuv;
  kuv_bl=kuv_l;
  kuv_bu=kuv_u;
  
  % Ito et al. suggest ordering the search by max(kuv_sdu-kuv_sdl)
  [kuv_max,kuv_max_n]=max(kuv_sdul(kuv_active));
  coef_n=kuv_active(kuv_max_n);
  kuv_bl(coef_n)=kuv_sdl(coef_n);
  kuv_bu(coef_n)=kuv_sdu(coef_n);

  % Try to solve the current SOCP problem with bounds kuv_bu and kuv_bl
  try
    % Find the SOCP PCLS solution for the remaining active coefficients
    [nextk,nextu,nextv,slb_iter,opt_iter,func_iter,feasible] = ...
    schurOneMAPlattice_frm_hilbert_slb ...
      (@schurOneMAPlattice_frm_hilbert_socp_mmse, ...
       kuv_b(Rk),epsilon0,p0,kuv_b(Ru),kuv_b(Rv),Mmodel,Dmodel, ...
       kuv_bu,kuv_bl,kuv_active,dmax, ...
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
  nextkuv=[nextk(:);nextu(:);nextv(:)];
  alpha=(nextkuv(coef_n)-((kuv_sdu(coef_n)+kuv_sdl(coef_n))/2))/ ...
        (kuv_sdul(coef_n)/2);
  if alpha>=0
    nextkuv(coef_n)=kuv_sdu(coef_n);
  else
    nextkuv(coef_n)=kuv_sdl(coef_n);
  endif
  kuv=nextkuv;
  kuv_active(kuv_max_n)=[];
  printf("Fixed kuv(%d)=%13.10f\n",coef_n,kuv(coef_n));
  printf("kuv_active=[ ");printf("%d ",kuv_active);printf("];\n\n");

endwhile

% Show results
p_ones=ones(size(p0));
kuv_min=kuv;
k_min=kuv(Rk);
[epsilon_min,p_min]=schurOneMscale(k_min);
u_min=kuv(Ru);
v_min=kuv(Rv);
Esq_min=schurOneMAPlattice_frm_hilbertEsq ...
          (k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel, ...
           wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
print_polynomial(epsilon_min,"epsilon_min");
print_polynomial(epsilon_min,"epsilon_min", ...
                 strcat(strf,"_epsilon_min_coef.m"),"%2d");
print_polynomial(p_min,"p_min");
print_polynomial(p_min,"p_min",strcat(strf,"_p_min_coef.m"));
print_polynomial(u_min,"u_min",nscale);
print_polynomial(u_min,"u_min",strcat(strf,"_u_min_coef.m"),nscale);
print_polynomial(v_min,"v_min",nscale);
print_polynomial(v_min,"v_min",strcat(strf,"_v_min_coef.m"),nscale);
% Find the number of signed-digits and adders used
[kuv_digits,kuv_adders]=SDadders(kuv_min(kuv0_active),nbits);
printf("%d signed-digits used\n",kuv_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kuv_adders,nbits);

% Amplitude,delay and phase at local peaks
Asq=schurOneMAPlattice_frm_hilbertAsq ...
      (wa,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,end])]);
AsqS=schurOneMAPlattice_frm_hilbertAsq ...
       (wAsqS,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
printf("k,u,v_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,u,v_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMAPlattice_frm_hilbertT ...
    (wt,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
TS=schurOneMAPlattice_frm_hilbertT ...
     (wTS,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
printf("k,u,v_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,u,v_min:TS=[ ");printf("%f ",TS'+tp);
printf("] (Samples)\n")
P=schurOneMAPlattice_frm_hilbertP ...
    (wp,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
vPl=local_max(Pdl-P);
vPu=local_max(P-Pdu);
wPS=sort(unique([wp(vPl);wp(vPu);wp([1,end])]));
PS=schurOneMAPlattice_frm_hilbertP ...
     (wPS,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
printf("k,u,v_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,u,v_min:PS=[ ");printf("%f ",PS'/pi);
printf("] (rad./pi) adjusted for delay\n");
                        
% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_kuv_min_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(Lim)& %8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,kuv0_digits,kuv0_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,kuv_digits,kuv_adders);
fclose(fid);

%
% Plot response
%

% Plot amplitude
Asq_kuv0=schurOneMAPlattice_frm_hilbertAsq ...
           (wa,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
Asq_kuv0_sd=schurOneMAPlattice_frm_hilbertAsq ...
           (wa,k0_sd,epsilon0,p0,u0_sd,v0_sd,Mmodel,Dmodel);
Asq_kuv_min=schurOneMAPlattice_frm_hilbertAsq ...
           (wa,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
plot(wa*0.5/pi,10*log10(Asq_kuv0),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_kuv0_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_kuv_min),"linestyle","-.");
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
ylabel("Amplitude(dB)");
xlabel("Frequency");
strt=sprintf("FRM Hilbert filter (nbits=12) : \
fap=%g,fas=%g,dBap=%g,Wap=%g,tp=%g,Wtp=%g,Wpp=%g",fap,fas,dBap,Wap,tp,Wtp,Wpp);
title(strt);
axis([0  0.5 -0.3 0.2]);
grid("on");
print(strcat(strf,"_kuv_minAsq"),"-dpdflatex");
close
% Plot phase
P_kuv0=schurOneMAPlattice_frm_hilbertP ...
         (wp,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
P_kuv0_sd=schurOneMAPlattice_frm_hilbertP ...
            (wp,k0_sd,epsilon0,p0,u0_sd,v0_sd,Mmodel,Dmodel);
P_kuv_min=schurOneMAPlattice_frm_hilbertP ...
            (wp,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
plot(wp*0.5/pi,P_kuv0/pi,"linestyle","-", ...
     wp*0.5/pi,P_kuv0_sd/pi,"linestyle","--", ...
     wp*0.5/pi,P_kuv_min/pi,"linestyle","-.");
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
title(strt);
axis([0 0.5 -0.505 -0.495]);
grid("on");
print(strcat(strf,"_kuv_minP"),"-dpdflatex");
close
% Plot delay
T_kuv0=schurOneMAPlattice_frm_hilbertT ...
         (wt,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
T_kuv0_sd=schurOneMAPlattice_frm_hilbertT ...
            (wt,k0_sd,epsilon0,p0,u0_sd,v0_sd,Mmodel,Dmodel);
T_kuv_min=schurOneMAPlattice_frm_hilbertT ...
            (wt,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
plot(wt*0.5/pi,T_kuv0+tp,"linestyle","-", ...
     wt*0.5/pi,T_kuv0_sd+tp,"linestyle","--", ...
     wt*0.5/pi,T_kuv_min+tp,"linestyle","-.");
ylabel("Delay(samples)");
xlabel("Frequency");
title(strt);
axis([0 0.5 78 80]);
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_kuv_minT"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"mr=%d %% Allpass model filter denominator order\n",mr);
fprintf(fid,"Mmodel=%d %% Model filter FRM decimation factor\n",Mmodel);
fprintf(fid,"Dmodel=%d %% Model filter nominal pass band group delay \n",Dmodel);
fprintf(fid,"dmask=%d %% FIR masking filter delay\n",dmask);
fprintf(fid,"fap=%g %% Magnitude-squared pass band edge\n",fap);
fprintf(fid,"fas=%g %% Magnitude-squared stop band edge\n",fas);
fprintf(fid,"dBap=%g %% Pass band magnitude-squared peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Pass band magnitude-squared weight\n",Wap);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"fts=%g %% Delay stop band edge\n",fts);
fprintf(fid,"tp=%d %% Pass band nominal delay\n",tp);
fprintf(fid,"tpr=tp/%g %% Pass band delay peak-to-peak ripple\n",tp/tpr);
fprintf(fid,"Wtp=%g %% Pass band magnitude-squared weight\n",Wap);
fprintf(fid,"fpp=%g %% Phase pass band edge\n",fpp);
fprintf(fid,"fps=%g %% Phase stop band edge\n",fps);
fprintf(fid,"pp=%g*pi %% Pass band nominal phase (rad.)\n",pp/pi);
fprintf(fid,"ppr=%g*pi %% Pass band phase peak-to-peak ripple (rad.)\n",ppr/pi);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

% Save results
save socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.mat ...
     n tol ctol maxiter nbits ndigits ndigits_alloc dmax rho ...
     fap fas dBap Wap ftp fts tp tpr Wtp fpp fps pp ppr Wpp ...
     k0 epsilon0 p0 u0 v0 Mmodel Dmodel ...
     k0_sd epsilon0_sd p0_sd u0_sd v0_sd ...
     k_min epsilon_min p_min u_min v_min
       
% Done
toc;
diary off
movefile ...
  socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary.tmp ...
  socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary;
