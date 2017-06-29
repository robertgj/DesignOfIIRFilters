% socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.m

% SOCP-relaxation optimisation of the response of an FRM Hilbert filter
% with 12-bit 3-signed-digit coefficients and an allpass model filter
% implemented as a Schur one-multiplier lattice.

% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary");
unlink("socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary.tmp");
diary socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary.tmp

% Options
socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test_allocsd_Lim=true
socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test_allocsd_Ito=false

tic;

format compact

%
% Initial filter from schurOneMAPlattice_frm_hilbert_socp_slb_test.m
%
k0 = [  -0.5737912482,  -0.1357861405,  -0.0532745521,  -0.0211256540, ... 
        -0.0087697088 ];
epsilon0 = [ -1,  1,  1,  1, 1 ];
p0 = [   1.5423434313,   0.8026361330,   0.9201452231,   0.9705438144, ... 
         0.9912684101 ];
u0 = [  -0.0009005864,  -0.0025457761,  -0.0071130803,  -0.0128019220, ... 
        -0.0309485917,  -0.0343335606,  -0.0517736811,  -0.0570207655, ... 
         0.4398895843 ]';
v0 = [   0.0065311035,   0.0043827833,   0.0072166026,   0.0020996443, ... 
        -0.0078831931,  -0.0311746387,  -0.0808425030,  -0.3143749022 ]';

%
% Filter specification
%
tol=5e-5
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
strT= ...
sprintf("FRM Hilbert %%s %%s : Mmodel=%d,Dmodel=%d,fap=%g,fas=%g,tp=%d",...
        Mmodel,Dmodel,fap,fas,tp);
strF= ...
sprintf("socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test%%s");

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
                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
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

% Find the signed-digit approximations to k0,u0 and v0
[kuv0_sd,kuv0_sdu,kuv0_sdl]=flt2SD(kuv0,nbits,ndigits_alloc);
k0_sd=kuv0_sd(Rk);
k0_sd=k0_sd(:);
u0_sd=kuv0_sd(Ru);
u0_sd=u0_sd(:);
v0_sd=kuv0_sd(Rv);
v0_sd=v0_sd(:);
printf("nscale*k0_sd_=[ ");printf("%g ",nscale*k0_sd');printf("]';\n");
printf("nscale*u0_sd=[ ");printf("%g ",nscale*u0_sd');printf("]';\n");
printf("nscale*v0_sd=[ ");printf("%g ",nscale*v0_sd');printf("]';\n");
print_polynomial(nscale*k0_sd,sprintf("%d*k0_sd",nscale), ...
                 sprintf(strF,"_k0_sd_coef.m"),"%6d");
print_polynomial(nscale*u0_sd,sprintf("%d*u0_sd",nscale), ...
                 sprintf(strF,"_u0_sd_coef.m"),"%6d");
print_polynomial(nscale*v0_sd,sprintf("%d*v0_sd",nscale), ...
                 sprintf(strF,"_v0_sd_coef.m"),"%6d");

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
    % Find the SOCP PCLS solution for the remaining active coefficents
    [nextk,nextu,nextv,slb_iter,opt_iter,func_iter,feasible] = ...
    schurOneMAPlattice_frm_hilbert_slb ...
      (@schurOneMAPlattice_frm_hilbert_socp_mmse, ...
       kuv_b(Rk),epsilon0,p0,kuv_b(Ru),kuv_b(Rv),Mmodel,Dmodel, ...
       kuv_bu,kuv_bl,kuv_active,dmax, ...
       wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
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
u_min=kuv(Ru);
v_min=kuv(Rv);
Esq_min=schurOneMAPlattice_frm_hilbertEsq ...
          (k_min,epsilon0,p_ones,u_min,v_min,Mmodel,Dmodel, ...
           wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
printf("nscale*k_min=[ ");printf("%g ",nscale*k_min');printf("]';\n");
printf("epsilon0=[ ");printf("%d ",epsilon0');printf("]';\n");
printf("p_ones=[ ");printf("%g ",p_ones');printf("]';\n");
printf("nscale*u_min=[ ");printf("%g ",nscale*u_min');printf("]';\n");
printf("nscale*v_min=[ ");printf("%g ",nscale*v_min');printf("]';\n");
print_polynomial(nscale*k_min,sprintf("%d*k_min",nscale), ...
                 sprintf(strF,"_k_min_coef.m"),"%6d");
print_polynomial(nscale*u_min,sprintf("%d*u_min",nscale), ...
                 sprintf(strF,"_u_min_coef.m"),"%6d");
print_polynomial(nscale*v_min,sprintf("%d*v_min",nscale), ...
                 sprintf(strF,"_v_min_coef.m"),"%6d");
% Find the number of signed-digits and adders used
[kuv_digits,kuv_adders]=SDadders(kuv_min(kuv0_active),nbits);
printf("%d signed-digits used\n",kuv_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kuv_adders,nbits);

% Amplitude,delay and phase at local peaks
Asq=schurOneMAPlattice_frm_hilbertAsq ...
      (wa,k_min,epsilon0,p_ones,u_min,v_min,Mmodel,Dmodel);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,end])]);
AsqS=schurOneMAPlattice_frm_hilbertAsq ...
       (wAsqS,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
printf("k,u,v_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,u,v_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMAPlattice_frm_hilbertT ...
    (wt,k_min,epsilon0,p_ones,u_min,v_min,Mmodel,Dmodel);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
TS=schurOneMAPlattice_frm_hilbertT ...
     (wTS,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
printf("k,u,v_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,u,v_min:TS=[ ");printf("%f ",TS'+tp);
printf("] (Samples)\n")
P=schurOneMAPlattice_frm_hilbertP ...
    (wp,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
vPl=local_max(Pdl-P);
vPu=local_max(P-Pdu);
wPS=sort(unique([wp(vPl);wp(vPu);wp([1,end])]));
PS=schurOneMAPlattice_frm_hilbertP ...
     (wPS,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
printf("k,u,v_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,u,v_min:PS=[ ");printf("%f ",PS'/pi);
printf("] (rad./pi) adjusted for delay\n");
                        
% Make a LaTeX table for cost
fid=fopen(sprintf(strF,"_kuv_min_cost.tab"),"wt");
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
           (wa,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
plot(wa*0.5/pi,10*log10(Asq_kuv0),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_kuv0_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_kuv_min),"linestyle","-.");
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","northeast");
legend("Boxoff");
legend("left");
ylabel("Amplitude(dB)");
xlabel("Frequency");
strT=sprintf("FRM Hilbert filter (nbits=12) : \
fap=%g,fas=%g,dBap=%g,Wap=%g,tp=%g,Wtp=%g,Wpp=%g",fap,fas,dBap,Wap,tp,Wtp,Wpp);
title(strT);
axis([0  0.5 -0.3 0.2]);
grid("on");
print(sprintf(strF,"_kuv_minAsq"),"-dpdflatex");
close
% Plot phase
P_kuv0=schurOneMAPlattice_frm_hilbertP ...
         (wp,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
P_kuv0_sd=schurOneMAPlattice_frm_hilbertP ...
            (wp,k0_sd,epsilon0,p0,u0_sd,v0_sd,Mmodel,Dmodel);
P_kuv_min=schurOneMAPlattice_frm_hilbertP ...
            (wp,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
plot(wp*0.5/pi,P_kuv0/pi,"linestyle","-", ...
     wp*0.5/pi,P_kuv0_sd/pi,"linestyle","--", ...
     wp*0.5/pi,P_kuv_min/pi,"linestyle","-.");
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","northeast");
legend("Boxoff");
legend("left");
ylabel("Phase(rad./pi)\n(Adjusted for delay)");
xlabel("Frequency");
title(strT);
axis([0 0.5 -0.505 -0.495]);
grid("on");
print(sprintf(strF,"_kuv_minP"),"-dpdflatex");
close
% Plot delay
T_kuv0=schurOneMAPlattice_frm_hilbertT ...
         (wt,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
T_kuv0_sd=schurOneMAPlattice_frm_hilbertT ...
            (wt,k0_sd,epsilon0,p0,u0_sd,v0_sd,Mmodel,Dmodel);
T_kuv_min=schurOneMAPlattice_frm_hilbertT ...
            (wt,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
plot(wt*0.5/pi,T_kuv0+tp,"linestyle","-", ...
     wt*0.5/pi,T_kuv0_sd+tp,"linestyle","--", ...
     wt*0.5/pi,T_kuv_min+tp,"linestyle","-.");
ylabel("Delay(Samples)");
xlabel("Frequency");
title(strT);
axis([0 0.5 78 80]);
legend("exact","s-d(Lim)","s-d(SOCP-relax)");
legend("location","northeast");
legend("Boxoff");
legend("left");
grid("on");
print(sprintf(strF,"_kuv_minT"),"-dpdflatex");
close

% Filter specification
fid=fopen(sprintf(strF,".spec"),"wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
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
fprintf(fid,"pp=%g*pi %% Pass band phase peak-to-peak ripple (rad.)\n",pp/pi);
fprintf(fid,"ppr=pi/%g %% Pass band phase peak-to-peak ripple (rad.)\n",pi/ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

% Save results
save socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.mat ...
     k0 epsilon0 p0 u0 v0 Mmodel Dmodel ...
     n tol maxiter nbits ndigits ndigits_alloc dmax rho k_min u_min v_min ...
     fap fas dBap Wap ftp fts tp tpr Wtp fpp fps pp ppr Wpp ...
     k_min u_min v_min
       
% Done
toc;
diary off
movefile ...
  socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary.tmp ...
  socp_relaxation_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary;
