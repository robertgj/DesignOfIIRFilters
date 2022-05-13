% socp_relaxation_schurOneMlattice_lowpass_differentiator_12_nbits_test.m
%
% Use SOCP relaxation to find the 12 bit 3 signed-digit coefficients of a
% low-pass differentiator filter implemented as the series combination of
% (z-1) with a Schur one-multiplier lattice correction filter.
%
% Copyright (C) 2022 Robert G. Jenssen

test_common;

strf="socp_relaxation_schurOneMlattice_lowpass_differentiator_12_nbits_test";
eval(sprintf("delete(\"%s.diary\")",strf));
eval(sprintf("delete(\"%s.diary.tmp\")",strf));
eval(sprintf("diary %s.diary.tmp",strf));

% Options
socp_relaxation_schurOneMlattice_lowpass_differentiator_allocsd_Lim=false
socp_relaxation_schurOneMlattice_lowpass_differentiator_allocsd_Ito=true

tic;

verbose=false
maxiter=5000
tol=1e-4
ctol=tol/10
nbits=12
nscale=2^(nbits-1);
ndigits=3

%
% Lowpass differentiator filter specification
%
nN=11;nD=11;R=1;
fap=0.19;fas=0.25;
Arp=0.5;Ars=0.5;Wap=1;Wat=0.001;Was=1;
td=nN-2;tdr=0.08;Wtp=0.02;
pr=0.02;Wpp=0.02;

n=1000;
wd=(0:(n-1))'*pi/n;
nap=ceil(fap*n/0.5)+1;
nas=ceil(fas*n/0.5)+1;

%
% Initial correction filter
%
iir_sqp_slb_lowpass_differentiator_test_d1_coef;
% Remove zero at z=1
iz=find(abs(d1(2:(1+Ud1))-1)<tol);
if length(iz) ~= 1
  error("Did not find single zero z==1 in d1!");
endif
d1(1+iz)=[];
Ud1=Ud1-1;
[N0,D0]=x2tf(d1,Ud1,Vd1,Md1,Qd1,Rd1);
nN=length(N0)-1;
nD=length(D0)-1;

%
% Convert initial correction filter to Schur one-multiplier lattice form
%
[k0,epsilon0,~,c0,S0] = tf2schurOneMlattice(N0,D0);
p0_ones=ones(size(k0));

%
% Frequency vectors for the Schur one-mulitplier lattice correction filter
%

% The one-multiplier lattice implementation adds a sample delay
tds=td+1;

% Amplitude with z-1 removed
wa=wd;
Azm1=[1;2*sin(wa(2:end)/2)];
Asqd=([wa(1:nap)./Azm1(1:nap);zeros(n-nap,1)]*0.5/pi).^2;
Asqdu=(([wa(1:(nas-1))./Azm1(1:(nas-1));zeros(n-nas+1,1)]*0.5/pi).^2) + ...
    (([Arp*ones(nas-1,1);Ars*ones(n-nas+1,1)]/(2*Azm1(nas))).^2);
Asqdl=-tol*ones(size(wa));
Wa=[Wap*ones(nap,1); ...
    Wat*ones(nas-nap-1,1); ...
    Was*ones(n-nas+1,1)];

% Group delay with z-1 removed
wt=wd(1:nap);
Td=(tds-0.5)*ones(size(wt));
Tdu=Td+(tdr/2);
Tdl=Td-(tdr/2);
Wt=Wtp*ones(size(wt));

% Phase response with z-1 removed
wp=wd(1:nap);
Pd=pi-(wp*(tds-0.5));
Pdu=Pd+(pr*pi/2);
Pdl=Pd-(pr*pi/2);
Wp=Wpp*ones(size(wp));

nchk=[1,2,nap-1,nap,nap+1,nas-1,nas,nas+1,n];
printf("nchk=[");printf("%d ",nchk);printf(" ]\n");
printf("wa(nchk)*0.5/pi=[");printf("%g ",wa(nchk)*0.5/pi);printf(" ]\n");
printf("Asqd(nchk)=[");printf("%g ",Asqd(nchk));printf(" ]\n");
printf("Asqdu(nchk)=[");printf("%g ",Asqdu(nchk));printf(" ]\n");
printf("Asqdl(nchk)=[");printf("%g ",Asqdl(nchk));printf(" ]\n");
printf("Wa(nchk)=[");printf("%g ",Wa(nchk));printf(" ]\n");

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
if socp_relaxation_schurOneMlattice_lowpass_differentiator_allocsd_Lim
  ndigits_alloc= ...
    schurOneMlattice_allocsd_Lim(nbits,ndigits,k0,epsilon0,p0_ones,c0, ...
                                 wa,Asqd,ones(size(wa)), ...
                                 wt,Td,ones(size(wt)), ...
                                 wp,Pd,ones(size(wp)));
elseif socp_relaxation_schurOneMlattice_lowpass_differentiator_allocsd_Ito
  ndigits_alloc= ...
    schurOneMlattice_allocsd_Ito(nbits,ndigits,k0,epsilon0,p0_ones,c0, ...
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
Esq0=schurOneMlatticeEsq(k0,epsilon0,p0_ones,c0,wa,Asqd,Wa,wt,Td,Wt);

% Find kc0_sd error
Esq0_sd=schurOneMlatticeEsq(k0_sd,epsilon0,p0_ones,c0_sd,wa,Asqd,Wa,wt,Td,Wt);

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
                           kc_b(1:Nk),epsilon0,p0_ones,kc_b((Nk+1):end), ...
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
kc_min=kc;
k_min=kc(1:Nk);
c_min=kc((Nk+1):end);
Esq_min=schurOneMlatticeEsq(k_min,epsilon0,p0_ones,c_min,wa,Asqd,Wa,wt,Td,Wt);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
print_polynomial(c_min,"c_min",nscale);
print_polynomial(c_min,"c_min",strcat(strf,"_c_min_coef.m"),nscale);
% Find the number of signed-digits and adders used by kc_sd
[kc_digits,kc_adders]=SDadders(kc_sd(kc0_active),nbits);
printf("%d signed-digits used\n",kc_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kc_adders,nbits);

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_kc_min_cost.tab"),"wt");
fprintf(fid,"Exact & %g & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(Ito)& %g & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,kc0_digits,kc0_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %g & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,kc_digits,kc_adders);
fclose(fid);

% Plot response
subplot(311);
Ad0=[wa(1:nap)*0.5/pi;zeros(n-nap,1)];
Asq_kc0=schurOneMlatticeAsq(wa,k0,epsilon0,p0_ones,c0);
Asq_kc0_sd=schurOneMlatticeAsq(wa,k0_sd,epsilon0,p0_ones,c0_sd);
Asq_kc_min=schurOneMlatticeAsq(wa,k_min,epsilon0,p0_ones,c_min);
plot(wa*0.5/pi,(Azm1.*sqrt(Asq_kc0))-Ad0,"linestyle","-", ...
     wa*0.5/pi,(Azm1.*sqrt(Asq_kc0_sd))-Ad0,"linestyle","--", ...
     wa*0.5/pi,(Azm1.*sqrt(Asq_kc_min))-Ad0,"linestyle","-.")
ylabel("Amplitude error");
strt=sprintf("Low-pass differentiaor filter:fap=%g,Arp=%g,tds=%g,pr=%g",
             fap,Arp,tds,pr);
title(strt);
axis([0  0.5 -0.01 0.01]);
grid("on");
subplot(312);
Pd0=(pi/2)+(wp*(tds-0.5));
P_kc0=schurOneMlatticeP(wp,k0,epsilon0,p0_ones,c0);
P_kc0_sd=schurOneMlatticeP(wp,k0_sd,epsilon0,p0_ones,c0_sd);
P_kc_min=schurOneMlatticeP(wp,k_min,epsilon0,p0_ones,c_min);
plot(wp*0.5/pi,(Pd0+P_kc0)/pi,"linestyle","-", ...
     wp*0.5/pi,(Pd0+P_kc0_sd)/pi,"linestyle","--", ...
     wp*0.5/pi,(Pd0+P_kc_min)/pi,"linestyle","-.");
axis([0 0.5 1.49 1.51]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
legend("exact","s-d(Ito)","s-d(SOCP-relax)");
legend("location","east");
legend("boxoff");
legend("left");
subplot(313);
Td0=0.5;
T_kc0=schurOneMlatticeT(wt,k0,epsilon0,p0_ones,c0);
T_kc0_sd=schurOneMlatticeT(wt,k0_sd,epsilon0,p0_ones,c0_sd);
T_kc_min=schurOneMlatticeT(wt,k_min,epsilon0,p0_ones,c_min);
plot(wt*0.5/pi,Td0+T_kc0,"linestyle","-", ...
     wt*0.5/pi,Td0+T_kc0_sd,"linestyle","--", ...
     wt*0.5/pi,Td0+T_kc_min,"linestyle","-.");
axis([0 0.5 9.9 10.1]);
grid("on");
ylabel("Group delay(samples)");
xlabel("Frequency");
print(strcat(strf,"_kc_min"),"-dpdflatex");
close

% Plot poles and zeros
[n_min,d_min]=schurOneMlattice2tf(k_min,epsilon0,p0_ones,c_min);
subplot(111);
zplane(roots(conv([1;-1],n_min(:))),roots(d_min(:)));
title(strt);
print(strcat(strf,"_kc_min_pz"),"-dpdflatex");
close

% Save specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"nbits=%d %% Bits-per-coefficient \n",nbits);
fprintf(fid,"ndigits=%d %% Average igned-digits-per-coefficient \n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"Arp=%g %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Ars=%g %% Amplitude stop band peak-to-peak ripple\n",Ars);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"td=%g %% Pass band group delay\n",td);
fprintf(fid,"tdr=%g %% Pass band group delay peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"pr=%6.4f %% Phase pass band peak-to-peak ripple(rad./$\\pi$))\n",
        pr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

% Done 
save socp_relaxation_schurOneMlattice_lowpass_differentiator_12_nbits_test.mat...
  nbits ndigits tol ctol n fap Arp Wap Ars Was td tds tdr Wtp pr Wpp ...
  socp_relaxation_schurOneMlattice_lowpass_differentiator_allocsd_Lim ...
  socp_relaxation_schurOneMlattice_lowpass_differentiator_allocsd_Ito ...
  k0 epsilon0 c0 k0_sd c0_sd k_min c_min

toc;
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));
