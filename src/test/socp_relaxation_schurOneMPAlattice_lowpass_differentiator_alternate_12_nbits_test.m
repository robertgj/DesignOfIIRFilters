% socp_relaxation_schurOneMPAlattice_lowpass_differentiator_alternate_12_nbits_test.m
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="socp_relaxation_schurOneMPAlattice_lowpass_differentiator_alternate_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

verbose=false
maxiter=2000
ftol=1e-5
ctol=ftol/20

nbits=12;
ndigits=3;
nscale=2^(nbits-1);
rho=1023/1024;

% Options
socp_relaxation_schurOneMPAlattice_lowpass_differentiator_allocsd_Lim=true
socp_relaxation_schurOneMPAlattice_lowpass_differentiator_allocsd_Ito=false

% Initial filter 
schurOneMPAlattice_socp_slb_lowpass_differentiator_alternate_test_A1k2_coef;
schurOneMPAlattice_socp_slb_lowpass_differentiator_alternate_test_A2k2_coef;
A1k0=A1k2(:);clear A1k2;
A2k0=A2k2(:);clear A2k2;
NA1=length(A1k0);
NA2=length(A2k0);
RA1=1:NA1;
RA2=(NA1+1):(NA1+NA2);
A1kones=ones(size(A1k0));
A2kones=ones(size(A2k0));

% Low-pass differentiator filter specification
difference=true;
df=difference;
fap=0.2;fas=0.4;
Arp=0.002;Ars=0.002;Wap=10;Wat=0.1;Was=1;
fpp=fap;pp=0.5;ppr=0.0004;Wpp=0.5;
ftp=fap;tp=ceil((NA1+NA2)/2);tpr=0.02;Wtp=1;
fdp=0.1;cpr=0.002;cn=4;Wdp=0.1;

Arp=0.002,Ars=0.002,ppr=0.01,tpr=0.1,cpr=0.1

% Frequency points
n=400;
w=pi*(0:(n-1))'/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;
ntp=ceil(ftp*n/0.5)+1;
npp=ceil(fpp*n/0.5)+1;
ndp=ceil(fdp*n/0.5)+1;

% Pass and transition band amplitudes
wa=w;
Rap=1:nap;
Ras=nas:length(wa);
Fz=[1;1]/2;
Az=cos(wa/2);
Azsq=Az.^2;
dAzsqdw=-sin(wa)/2;
Ad=[wa(Rap)/2;zeros(n-nap,1)];
Asqd=Ad.^2;
dAsqddw=Ad;
Adu=[wa(1:(nas-1))/2;zeros(n-nas+1,1)]+ ...
    [(Arp/2)*ones(nas-1,1); (Ars/2)*ones(n-nas+1,1)];
Adu(find(Adu>(1-Arp)))=1-Arp;
Asqdu=Adu.^2;
Adl=Ad-[(Arp/2)*ones(nap,1);zeros(n-nap,1)];
Adl(find(Adl<=0))=0;
Asqdl=Adl.^2;
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas+1,1)];
% Sanity check
nachk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1,n];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Ad(nachk)=[");printf("%g ",Ad(nachk));printf(" ]\n");
printf("Adu(nachk)=[");printf("%g ",Adu(nachk));printf(" ]\n");
printf("Adl(nachk)=[");printf("%g ",Adl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");

% Group delay
Rtp=2:ntp;
wt=w(Rtp);
Tz=0.5*ones(size(wt));
Td=tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));

% Phase response
Rpp=2:npp;
wp=w(Rpp);
Pz=-wp/2;
Pd=(pp*pi)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% dAsqdw response
Rdp=1:ndp;
wd=w(Rdp);
Wd=Wdp*ones(size(wd));
%Cd=((Azsq(Rdp).*dAsqddw(Rdp))-(Asqd(Rdp).*dAzsqdw(Rdp)))./(Azsq(Rdp).^2);
Cd=((wa(Rdp)/2).*(sec(wa(Rdp)/2).^2)).*(1+((wa(Rdp)/2).*tan(wa(Rdp)/2)));
Cderr=(cpr/2)*(1+((Rdp(:)/ndp).^cn));
Cdu=Cd+Cderr;
Cdl=Cd-Cderr;
Dd=dAsqddw(Rdp);
Dderr=(Cderr.*Azsq(Rdp));
Ddu=Dd+Dderr;
Ddl=Dd-Dderr;

% Calculate the initial response
Asqc_k0=schurOneMPAlatticeAsq(wa,A1k0,A1kones,A1kones, ...
                              A2k0,A2kones,A2kones,difference);
Ac_k0=sqrt(Asqc_k0);
A_k0=Ac_k0.*Az;
Pc_k0=schurOneMPAlatticeP(wp,A1k0,A1kones,A1kones, ...
                          A2k0,A2kones,A2kones,difference);
P_k0=Pc_k0+Pz;
Tc_k0=schurOneMPAlatticeT(wt,A1k0,A1kones,A1kones, ...
                          A2k0,A2kones,A2kones,difference);
T_k0=Tc_k0+Tz;
dCsqdw_k0=schurOneMPAlatticedAsqdw(wd,A1k0,A1kones,A1kones, ...
                                   A2k0,A2kones,A2kones,difference);
dAsqdw_k0=(Asqc_k0(Rdp).*dAzsqdw(Rdp))+(dCsqdw_k0.*(Azsq(Rdp)));

% Plot initial response
subplot(311);
plot(wa*0.5/pi,[A_k0 Adl Adu]);
ylabel("Amplitude");
axis([0 0.5 0 1]);
grid("on");
strt=sprintf("Initial parallel allpass");
title(strt);
subplot(312);
plot(wp*0.5/pi,([P_k0 Pd Pdl Pdu]+(wp*tp))/pi);
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 pp+(0.02*[-1 1])]);
grid("on");
subplot(313);
plot(wt*0.5/pi,[T_k0 Td Tdl Tdu]);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 tp+0.2*[-1,1]]);
grid("on");
print(strcat(strf,"_initial_response"),"-dpdflatex");
close

% Find k0 error
Esq0=schurOneMPAlatticeEsq(A1k0,A1kones,A1kones, ...
                           A2k0,A2kones,A2kones, ...
                           difference, ...
                           wa,Asqd./Azsq,Wa, ...
                           wt,Td-Tz,Wt, ...
                           wp,Pd-Pz,Wp, ...
                           wd,Cd,Wd);

% Coefficient constraints
dmax=inf; % For compatibility with SQP
k0_u=rho*ones(NA1+NA2,1);
k0_l=-k0_u;
k0=[A1k0;A2k0];

% Allocate signed-digits to the coefficients
if socp_relaxation_schurOneMPAlattice_lowpass_differentiator_allocsd_Lim
  ndigits_alloc = ...
    schurOneMPAlattice_allocsd_Lim(nbits,ndigits, ...
                                   A1k0,A1kones,A1kones, ...
                                   A2k0,A2kones,A2kones, ...
                                   difference, ...
                                   wa,Asqd./Azsq,ones(size(Wa)), ...
                                   wt,Td-Tz,ones(size(Wt)), ...
                                   wp,Pd-Pz,ones(size(Wp)), ...
                                   wd,Cd,ones(size(Wd)));
  strItoLim="Lim";
elseif socp_relaxation_schurOneMPAlattice_lowpass_differentiator_allocsd_Ito
  ndigits_alloc = ...
    schurOneMPAlattice_allocsd_Ito(nbits,ndigits,...
                                   A1k0,A1kones,A1kones, ...
                                   A2k0,A2kones,A2kones, ...
                                   difference, ...
                                   wa,Asqd./Azsq,Wa, ...
                                   wt,Td-Tz,Wt, ...
                                   wp,Pd-Pz,Wp, ...
                                   wd,Cd,Wd);
  strItoLim="Ito";
else
  ndigits_alloc=ndigits*ones(NA1+NA2,1);
  strItoLim="none";
endif
k_allocsd_digits=int16(ndigits_alloc);
A1k_allocsd_digits=k_allocsd_digits(RA1);
A2k_allocsd_digits=k_allocsd_digits(RA2);
print_polynomial(k_allocsd_digits,"k_allocsd_digits","%1d");
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%1d");
print_polynomial(A1k_allocsd_digits,"A1k_allocsd_digits","%1d");
print_polynomial(A1k_allocsd_digits,"A1k_allocsd_digits", ...
                 strcat(strf,"_A1k_allocsd_digits.m"),"%1d");
print_polynomial(A2k_allocsd_digits,"A2k_allocsd_digits","%1d");
print_polynomial(A2k_allocsd_digits,"A2k_allocsd_digits", ...
                 strcat(strf,"_A2k_allocsd_digits.m"),"%1d");
% Find the signed-digit approximations to k0
[A1k0_sd,A1k0_sdu,A1k0_sdl]=flt2SD(A1k0,nbits,ndigits_alloc(RA1));
[A2k0_sd,A2k0_sdu,A2k0_sdl]=flt2SD(A2k0,nbits,ndigits_alloc(RA2));
print_polynomial(A1k0_sd,"A1k0_sd",nscale);
print_polynomial(A1k0_sd,"A1k0_sd",strcat(strf,"_A1k0_sd_coef.m"),nscale);
print_polynomial(A2k0_sd,"A2k0_sd",nscale);
print_polynomial(A2k0_sd,"A2k0_sd",strcat(strf,"_A2k0_sd_coef.m"),nscale);

% Calculate the signed-digit response
Asqc_k0_sd=schurOneMPAlatticeAsq(wa,A1k0_sd,A1kones,A1kones, ...
                                 A2k0_sd,A2kones,A2kones,difference);
Ac_k0_sd=sqrt(Asqc_k0_sd);
A_k0_sd=Ac_k0_sd.*Az;
Pc_k0_sd=schurOneMPAlatticeP(wp,A1k0_sd,A1kones,A1kones, ...
                             A2k0_sd,A2kones,A2kones,difference);
P_k0_sd=Pc_k0_sd+Pz;
Tc_k0_sd=schurOneMPAlatticeT(wt,A1k0_sd,A1kones,A1kones, ...
                             A2k0_sd,A2kones,A2kones,difference);
T_k0_sd=Tc_k0_sd+Tz;
dCsqdw_k0_sd=schurOneMPAlatticedAsqdw(wd,A1k0_sd,A1kones,A1kones, ...
                                      A2k0_sd,A2kones,A2kones,difference);
dAsqdw_k0_sd=(Asqc_k0_sd(Rdp).*dAzsqdw(Rdp))+(dCsqdw_k0_sd.*(Azsq(Rdp)));
                         
% Find k0_sd error
Esq0_sd=schurOneMPAlatticeEsq(A1k0_sd,A1kones,A1kones, ...
                              A2k0_sd,A2kones,A2kones, ...
                              difference, ...
                              wa,Asqd./Azsq,Wa, ...
                              wt,Td-Tz,Wt, ...
                              wp,Pd-Pz,Wp, ...
                              wd,Cd,Wd);

% Plot signed-digit response
subplot(311);
plot(wa*0.5/pi,[A_k0 A_k0_sd Adl Adu]-Ad);
ylabel("Amplitude");
axis([0 0.5 0.01*[-1,1]]);
grid("on");
strt=sprintf("Signed-digit parallel allpass");
title(strt);
subplot(312);
plot(wp*0.5/pi,([P_k0 P_k0_sd Pdl Pdu]+(wp*tp))/pi);
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 pp+(0.002*[-1 1])]);
grid("on");
subplot(313);
plot(wt*0.5/pi,[T_k0 T_k0_sd Tdl Tdu]);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 tp+0.02*[-1,1]]);
grid("on");
print(strcat(strf,"_initial_sd_response"),"-dpdflatex");
close

% Initialise k0_active
k0_sd=[A1k0_sd(:);A2k0_sd(:)];
k0_sdu=[A1k0_sdu(:);A2k0_sdu(:)];
k0_sdl=[A1k0_sdl(:);A2k0_sdl(:)];
k0_sdul=k0_sdu-k0_sdl(:);
k0_active=find(k0_sdul~=0);
n_active=length(k0_active);
% Check for consistent upper and lower bounds
if any(k0_sdul < 0)
  error("found k0_sdul<0");
endif
if any(k0_sd(k0_active)>k0_sdu(k0_active))
  error("found k0_sd(k0_active)>k0_sdu(k0_active)");
endif
if any(k0_sdl(k0_active)>k0_sd(k0_active))
  error("found k0_sdl(k0_active)>k0_sd(k0_active)");
endif
if any(k0(k0_active)>k0_sdu(k0_active))
  error("found k0(k0_active)>k0_sdu(k0_active)");
endif
if any(k0_sdl(k0_active)>k0(k0_active))
  error("found k0_sdl>k0");
endif

% Find the number of signed-digits and adders used by k0_sd
[k0_sd_digits,k0_sd_adders]=SDadders(k0_sd(k0_active),nbits);

% Initialise the vector of filter coefficients to be optimised
k=zeros(size(k0));
k(k0_active)=k0(k0_active);
k_l=k0_l;
k_u=k0_u;
k_active=k0_active;

% Fix one coefficient at each iteration 
while ~isempty(k_active)
  
  % Define filter coefficients 
  [k_sd,k_sdu,k_sdl]=flt2SD(k,nbits,ndigits_alloc);
  k_sdul=k_sdu-k_sdl;
  k_b=k;
  k_bl=k_l;
  k_bu=k_u;
  
  % Ito et al. suggest ordering the search by max(k_sdu-k_sdl)
  [k_max,k_max_n]=max(k_sdul(k_active));
  coef_n=k_active(k_max_n);
  k_bl(coef_n)=k_sdl(coef_n);
  k_bu(coef_n)=k_sdu(coef_n);

  % Try to solve the current SOCP problem with bounds k_bu and k_bl
  try
    % Find the SOCP PCLS solution for the remaining active coefficients
    [nextA1k,nextA2k,slb_iter,opt_iter,func_iter,feasible] = ...
       schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                              k_b(RA1),A1kones,A1kones, ...
                              k_b(RA2),A2kones,A2kones, ...
                              difference, ...
                              k_u,k_l,k_active,dmax, ...
                              wa,Asqd./Azsq,Asqdu./Azsq,Asqdl./Azsq,Wa, ...
                              wt,Td-Tz,Tdu-Tz,Tdl-Tz,Wt, ...
                              wp,Pd-Pz,Pdu-Pz,Pdl-Pz,Wp, ...
                              wd,Cd,Cdu,Cdl,Wd, ...
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
  nextk=[nextA1k(:);nextA2k(:)];
  alpha=(nextk(coef_n)-((k_sdu(coef_n)+k_sdl(coef_n))/2))/(k_sdul(coef_n)/2);
  if alpha>=0
    nextk(coef_n)=k_sdu(coef_n);
  else
    nextk(coef_n)=k_sdl(coef_n);
  endif
  k=nextk;
  k_active(k_max_n)=[];
  printf("Fixed k(%d)=%13.10f\n",coef_n,k(coef_n));
  printf("k_active=[ ");printf("%d ",k_active);printf("];\n\n");

endwhile

% Show results
k_min=k;
A1k_min=k_min(RA1);
A2k_min=k_min(RA2);
Esq_min=schurOneMPAlatticeEsq(A1k_min,A1kones,A1kones, ...
                              A2k_min,A2kones,A2kones, ...
                              difference, ...
                              wa,Asqd./Azsq,Wa, ...
                              wt,Td-Tz,Wt, ...
                              wp,Pd-Pz,Wp, ...
                              wd,Cd,Wd);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
print_polynomial(A1k_min,"A1k_min",nscale);
print_polynomial(A1k_min,"A1k_min",strcat(strf,"_A1k_min_coef.m"),nscale);
print_polynomial(A2k_min,"A2k_min",nscale);
print_polynomial(A2k_min,"A2k_min",strcat(strf,"_A2k_min_coef.m"),nscale);
% Find the number of signed-digits and adders 
[k_digits,k_adders]=SDadders(k_min(k0_active),nbits);
printf("%d signed-digits used\n",k_digits);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       k_adders,nbits);

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %10.4e & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(%s)& %10.4e & %d & %d \\\\\n", ...
        nbits,ndigits,strItoLim,Esq0_sd,k0_sd_digits,k0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %10.4e & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_min,k_digits,k_adders);
fclose(fid);

% Calculate response
Asqc_k0=schurOneMPAlatticeAsq(wa,A1k0,A1kones,A1kones, ...
                              A2k0,A2kones,A2kones,difference);
Asq_k0=Asqc_k0.*Azsq;
Ac_k0=sqrt(Asqc_k0);
A_k0=Ac_k0.*Az;
Asqc_k0_sd=schurOneMPAlatticeAsq(wa,A1k0_sd,A1kones,A1kones, ...
                                 A2k0_sd,A2kones,A2kones,difference);
Asq_k0_sd=Asqc_k0_sd.*Azsq;
Ac_k0_sd=sqrt(Asqc_k0_sd);
A_k0_sd=Ac_k0_sd.*Az;
Asqc_k_min=schurOneMPAlatticeAsq(wa,A1k_min,A1kones,A1kones, ...
                                 A2k_min,A2kones,A2kones,difference);
Asq_k_min=Asqc_k_min.*Azsq;
Ac_k_min=sqrt(Asqc_k_min);
A_k_min=Ac_k_min.*Az;

Pc_k0=schurOneMPAlatticeP(wp,A1k0,A1kones,A1kones, ...
                          A2k0,A2kones,A2kones,difference);
P_k0=Pc_k0+Pz;
Pc_k0_sd=schurOneMPAlatticeP(wp,A1k0_sd,A1kones,A1kones, ...
                             A2k0_sd,A2kones,A2kones,difference);
P_k0_sd=Pc_k0_sd+Pz;
Pc_k_min=schurOneMPAlatticeP(wp,A1k_min,A1kones,A1kones, ...
                             A2k_min,A2kones,A2kones,difference);
P_k_min=Pc_k_min+Pz;

Tc_k0=schurOneMPAlatticeT(wt,A1k0,A1kones,A1kones, ...
                          A2k0,A2kones,A2kones,difference);
T_k0=Tc_k0+Tz;
Tc_k0_sd=schurOneMPAlatticeT(wt,A1k0_sd,A1kones,A1kones, ...
                             A2k0_sd,A2kones,A2kones,difference);
T_k0_sd=Tc_k0_sd+Tz;
Tc_k_min=schurOneMPAlatticeT(wt,A1k_min,A1kones,A1kones, ...
                             A2k_min,A2kones,A2kones,difference);
T_k_min=Tc_k_min+Tz;

dCsqdw_k0=schurOneMPAlatticedAsqdw(wd,A1k0,A1kones,A1kones, ...
                                   A2k0,A2kones,A2kones,difference);
dCsqdw_k0_sd=schurOneMPAlatticedAsqdw(wd,A1k0_sd,A1kones,A1kones, ...
                                      A2k0_sd,A2kones,A2kones,difference);
dCsqdw_k_min=schurOneMPAlatticedAsqdw(wd,A1k_min,A1kones,A1kones, ...
                                      A2k_min,A2kones,A2kones,difference);

% Check constraints after the last truncation
vS=schurOneMPAlattice_slb_update_constraints ...
     (Asq_k_min./Azsq,Asqdu./Azsq,Asqdl./Azsq,Wa, ...
      T_k_min-Tz,Tdu-Tz,Tdl-Tz,Wt, ...
      P_k_min-Pz,Pdu-Pz,Pdl-Pz,Wp, ...
      dCsqdw_k_min,Cdu,Cdl,Wd, ...
      ctol);
if ~schurOneMPAlattice_slb_constraints_are_empty(vS)
  printf("These constraints on the correction filter response are not met:\n");
  schurOneMPAlattice_slb_show_constraints ...
    (vS,wa,Asq_k_min,wt,T_k_min,wp,P_k_min,wd,dCsqdw_k_min);
endif

% Sanity check on difference of parallel all pass
D1k_min=schurOneMAPlattice2tf(A1k_min);
D2k_min=schurOneMAPlattice2tf(A2k_min);
H1k_min=freqz(flipud(D1k_min(:)),D1k_min(:),wa);
H2k_min=freqz(flipud(D2k_min(:)),D2k_min(:),wa);
H12_min=0.5*(H1k_min-H2k_min);
Hz=freqz(Fz,1,wa);
if max(abs(abs(H12_min.*Hz)-A_k_min)) > 10*eps
  error("max(abs(abs(H12_min.*Hz)-A_k_min))(%g*eps) > 10*eps", ...
        max(abs(abs(H12_min.*Hz)-A_k_min))/eps)
endif
T1k_min=delayz(flipud(D1k_min(:)),D1k_min(:),wt);
T2k_min=delayz(flipud(D2k_min(:)),D2k_min(:),wt);
T12_min=0.5*(T1k_min+T2k_min);
if max(abs(T12_min+0.5-T_k_min)) > 10e5*eps
  error("max(abs(T12_min+0.5-T_k_min))(%g*eps) > 10e5*eps", ...
        max(abs(T12_min+0.5-T_k_min))/eps)
endif
% Sanity check on  difference of polyphase all pass
D2k_min_s=D2k_min(1:(end-1));
H2k_min_s=freqz(flipud(D2k_min_s(:)),D2k_min_s(:),wa);
H12_min_s=0.5*(H2k_min_s-(H1k_min.*exp(j*wa)));
if max(abs(abs(H12_min_s.*Hz)-A_k_min)) > 10*eps
  error("max(abs(abs(H12_min_s.*Hz)-A_k_min))(%g*eps) > 10*eps", ...
        max(abs(abs(H12_min_s.*Hz)-A_k_min))/eps)
endif
T2k_min_s=delayz(flipud(D2k_min_s(:)),D2k_min_s(:),wt);
T12_min_s=0.5*(T1k_min+1+T2k_min_s);
if max(abs(T12_min_s+0.5-T_k_min)) > 10e5*eps
  error("max(abs(T12_min_s+0.5-T_k_min))(%g*eps) > 10e5*eps", ...
        max(abs(T12_min_s+0.5-T_k_min))/eps)
endif
% Sanity check on overall
[N_min,D_min]=schurOneMPAlattice2tf(A1k_min,A1kones,A1kones, ...
                                    A2k_min,A2kones,A2kones,difference);
H_min=freqz(N_min,D_min,wa);
if max(abs(abs(H_min.*Hz)-A_k_min)) > 10*eps
  error("max(abs(abs(H_min.*Hz)-A_k_min))(%g*eps) > 10*eps", ...
        max(abs(abs(H_min.*Hz)-A_k_min))/eps)
endif

print_polynomial(D1k_min,"D1k_min");
print_polynomial(D1k_min,"D1k_min",strcat(strf,"_D1k_min_coef.m"));
print_polynomial(D2k_min,"D2k_min");
print_polynomial(D2k_min,"D2k_min",strcat(strf,"_D2k_min_coef.m"));
print_polynomial(N_min,"N_min");
print_polynomial(N_min,"N_min",strcat(strf,"_N_min_coef.m"));
print_polynomial(D_min,"D_min");
print_polynomial(D_min,"D_min",strcat(strf,"_D_min_coef.m"));

% Plot response error
subplot(311);
[ax,ha,hs]= ...
  plotyy(wa(Rap)*0.5/pi, ...
         ([A_k0(Rap),A_k0_sd(Rap),A_k_min(Rap)])-Ad(Rap), ...
         wa(Ras)*0.5/pi, ...
         (Az(Ras).*[A_k0(Ras),A_k0_sd(Ras),A_k_min(Ras)])-Ad(Ras));
% Copy line colour
hac=get(ha,"color");
hls={"-","--","-."};
for c=1:3
  set(hs(c),"color",hac{c}); 
  set(ha(c),"linestyle",hls{c});
  set(hs(c),"linestyle",hls{c}); 
endfor
axis(ax(1),[0 0.5 0.004*[-1,1]]);
axis(ax(2),[0 0.5 0.0004*[-1,1]]);
ylabel("Amplitude error");
strt=sprintf(["Low-pass differentiator filter : ", ...
              "fap=%g,fas=%g,Arp=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"], ...
             fap,fas,Arp,Ars,tp,tpr,ppr);
title(strt);
grid("on");
subplot(312);
plot(wp*0.5/pi,(P_k0+(wp*tp))/pi,"linestyle","-", ...
     wp*0.5/pi,(P_k0_sd+(wp*tp))/pi,"linestyle","--", ...
     wp*0.5/pi,(P_k_min+(wp*tp))/pi,"linestyle","-.");
axis([0 0.5 pp+(0.002*[-1,1])]);
grid("on");
ylabel("Phase(rad./$\\pi$)");
legend("exact",sprintf("s-d(%s)",strItoLim),"s-d(SOCP-relax)");
legend("location","east");
legend("boxoff");
legend("left");
subplot(313);
plot(wt*0.5/pi,T_k0,"linestyle","-", ...
     wt*0.5/pi,T_k0_sd,"linestyle","--", ...
     wt*0.5/pi,T_k_min,"linestyle","-.");
axis([0 0.5 tp+(0.02*[-1,1])]);
grid("on");
ylabel("Group delay(samples)");
xlabel("Frequency");
print(strcat(strf,"_response_error"),"-dpdflatex");
close

% Plot relative amplitude response error
ha=plot(wa(Rap)*0.5/pi,([A_k0(Rap),A_k0_sd(Rap),A_k_min(Rap)]./Ad(Rap))-1);
% Copy line colour
hls={"-","--","-."};
for c=1:3
  set(ha(c),"linestyle",hls{c});
endfor
axis([0 0.5 0.01*[-1,1]]);
grid("on");
strt=sprintf(["Low-pass differentiator filter : ", ...
              "fap=%g,fas=%g,Arp=%g,Ars=%g,tp=%g,tpr=%g,ppr=%g"], ...
             fap,fas,Arp,Ars,tp,tpr,ppr);
title(strt);
xlabel("Frequency");
ylabel("Relative amplitude error");
legend("exact",sprintf("s-d(%s)",strItoLim),"s-d(SOCP-relax)");
legend("location","east");
legend("boxoff");
legend("left");
print(strcat(strf,"_pass_relative_error"),"-dpdflatex");
close

% Plot poles and zeros
zplane(qroots(flipud(D1k_min(:))),qroots(D1k_min(:)));
title(strt);
print(strcat(strf,"_D1k_min_pz"),"-dpdflatex");
close
zplane(qroots(flipud(D2k_min(:))),qroots(D2k_min(:)));
title(strt);
print(strcat(strf,"_D2k_min_pz"),"-dpdflatex");
close
zplane(qroots(conv(N_min(:),Fz)),qroots(D_min(:)));
title(strt);
print(strcat(strf,"_k_min_pz"),"-dpdflatex");
close

% Save specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid, ...
"socp_relaxation_schurOneMPAlattice_lowpass_differentiator_allocsd_Lim=%d\n", ...
socp_relaxation_schurOneMPAlattice_lowpass_differentiator_allocsd_Lim);
fprintf(fid, ...
"socp_relaxation_schurOneMPAlattice_lowpass_differentiator_allocsd_Ito=%d\n", ...
socp_relaxation_schurOneMPAlattice_lowpass_differentiator_allocsd_Ito);
fprintf(fid,"nbits=%d %% Bits-per-coefficient \n",nbits);
fprintf(fid,"ndigits=%d %% Average signed-digits-per-coefficient \n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"rho=%g %% Constraint on reflection coefficients\n",rho);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"fap=%g %% Amplitude pass band upper edge\n",fap);
fprintf(fid,"Arp=%g %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wat=%g %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band lower edge\n",fas);
fprintf(fid,"Ars=%g %% Amplitude stop band peak-to-peak ripple\n",Ars);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"tp=%g %% Pass band group delay\n",tp);
fprintf(fid,"tpr=%g %% Pass band group delay peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Pass band group delay weight\n",Wtp);
fprintf(fid,"pp=%g %% Phase pass band nominal phase(rad./pi))\n",pp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple(rad./pi))\n",ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fprintf(fid,"fdp=%g %% dAsqdw pass band upper edge\n",fdp);
fprintf(fid, ...
        "cpr=%g %% Correction filter dCsqdw pass band peak-to-peak ripple\n", ...
        cpr);
fprintf(fid,"cn=%d %% Correction filter pass band dCsqdw w exponent\n",cn);
fprintf(fid,"Wdp=%g %% Correction filter dCsqdw pass band weight\n",Wdp);
fclose(fid);

eval(sprintf(["save %s.mat ", ...
 "socp_relaxation_schurOneMPAlattice_lowpass_differentiator_allocsd_Lim ", ...
 "socp_relaxation_schurOneMPAlattice_lowpass_differentiator_allocsd_Ito ", ...
 "nbits ndigits ndigits_alloc k_allocsd_digits ", ...
 "ftol ctol rho n fap Arp Wap Wat Ars Was tp tpr Wtp pp ppr Wpp ", ...
 "fdp cpr cn Wdp A1k0 A2k0 A1k0_sd A2k0_sd A1k_min A2k_min"],strf));

% Done 
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));

