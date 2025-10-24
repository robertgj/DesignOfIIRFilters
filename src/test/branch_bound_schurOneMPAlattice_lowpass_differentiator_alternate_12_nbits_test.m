% branch_bound_schurOneMPAlattice_lowpass_differentiator_alternate_12_nbits_test.m
% Branch-and-bound optimisation of the response of a low pass differentiator
% filter with 12-bit 3-signed-digit coefficients.
% Copyright (C) 2025 Robert G. Jenssen

test_common;

strf="branch_bound_schurOneMPAlattice_lowpass_differentiator_alternate_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Options
use_best_branch_and_bound_found=false
if use_best_branch_and_bound_found
  warning(["Reporting the best branch-and-bound filter found so far. \n", ...
 "           Set \"use_best_branch_and_bound_found\"=false to re-run."]);
endif
enforce_pcls_constraints_on_final_filter=false
branch_bound_schurOneMPAlattice_lowpass_differentiator_alternate_allocsd_Lim=true
branch_bound_schurOneMPAlattice_lowpass_differentiator_alternate_allocsd_Ito=false

tic;

ctol=1e-5
maxiter=1000
verbose=false

nbits=12;
ndigits=3;
nscale=2^(nbits-1);

% Initial filter 
schurOneMPAlattice_socp_slb_lowpass_differentiator_alternate_test_A1k2_coef;
schurOneMPAlattice_socp_slb_lowpass_differentiator_alternate_test_A2k2_coef;
A1k0=A1k2(:);clear A1k2;
A2k0=A2k2(:);clear A2k2;
NA1k=length(A1k0);
NA2k=length(A2k0);
RA1k=1:NA1k;
RA2k=(NA1k+1):(NA1k+NA2k);
A1kones=ones(size(A1k0));
A2kones=ones(size(A2k0));

% Low-pass differentiator filter specification
difference=true;
rho=127/128;
fap=0.2;fas=0.4;
Arp=0;Ars=0;Wap=10;Wat=0.001;Was=1;
fpp=fap;pp=0.5;ppr=0;Wpp=0.5;
ftp=fap;tp=(NA1k+NA2k)/2;tpr=0;Wtp=1;
fdp=0.1;cpr=0;cn=0;Wdp=0.1;

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
Cderr=(cpr/2)*((Rdp(:)/ndp).^cn);
Cdu=Cd+Cderr;
Cdl=Cd-Cderr;
Dd=dAsqddw(Rdp);
Dderr=(Cderr.*Azsq(Rdp));
Ddu=Dd+Dderr;
Ddl=Dd-Dderr;

% Calculate the initial response
Csq_k0=schurOneMPAlatticeAsq(wa,A1k0,A1kones,A1kones, ...
                              A2k0,A2kones,A2kones,difference);
A_k0=sqrt(Csq_k0).*Az;
Pc_k0=schurOneMPAlatticeP(wp,A1k0,A1kones,A1kones, ...
                          A2k0,A2kones,A2kones,difference);
P_k0=Pc_k0+Pz;
Tc_k0=schurOneMPAlatticeT(wt,A1k0,A1kones,A1kones, ...
                          A2k0,A2kones,A2kones,difference);
T_k0=Tc_k0+Tz;
dCsqdw_k0=schurOneMPAlatticedAsqdw(wd,A1k0,A1kones,A1kones, ...
                                   A2k0,A2kones,A2kones,difference);
dAsqdw_k0=(Csq_k0(Rdp).*dAzsqdw(Rdp))+(dCsqdw_k0.*(Azsq(Rdp)));

% Plot initial response
subplot(311);
plot(wa*0.5/pi,(A_k0./Ad)-1);
ylabel("Relative amplitude error");
axis([0 0.5 0.002*[-1,1]]);
grid("on");
strt=sprintf("Initial parallel allpass");
title(strt);
subplot(312);
plot(wp*0.5/pi,(P_k0+(wp*tp))/pi);
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 pp+(0.0002*[-1,1])]);
grid("on");
subplot(313);
plot(wt*0.5/pi,T_k0);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 tp+0.01*[-1,1]]);
grid("on");
zticks([]);
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
k0_u=rho*ones(NA1k+NA2k,1);
k0_l=-k0_u;
k0=[A1k0;A2k0];

% Allocate signed-digits to the coefficients
if branch_bound_schurOneMPAlattice_lowpass_differentiator_alternate_allocsd_Lim
  if 0
    ndigits_alloc = ...
       schurOneMPAlattice_allocsd_Lim(nbits,ndigits, ...
                                      A1k0,A1kones,A1kones, ...
                                      A2k0,A2kones,A2kones, ...
                                      difference, ...
                                      wa,Asqd./Azsq,ones(size(Wa)), ...
                                      wt,Td-Tz,ones(size(Wt)), ...
                                      wp,Pd-Pz,ones(size(Wp)), ...
                                      wd,Cd,ones(size(Wd)));
  else
    ndigits_alloc = schurOneMPAlattice_allocsd_Lim(nbits,ndigits, ...
                                                   A1k0,A1kones,A1kones, ...
                                                   A2k0,A2kones,A2kones, ...
                                                   difference, ...
                                                   wa,Asqd./Azsq,Wa, ...
                                                   wt,Td-Tz,Wt, ...
                                                   wp,Pd-Pz,Wp, ...
                                                   wd,Cd,Wd);
  endif
  strItoLim="Lim";
elseif
  branch_bound_schurOneMPAlattice_lowpass_differentiator_alternate_allocsd_Ito
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
  ndigits_alloc=ndigits*ones(NA1k+NA2k,1);
  strItoLim="none";
endif
k_allocsd_digits=int16(ndigits_alloc);
print_polynomial(k_allocsd_digits,"k_allocsd_digits","%1d");
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%1d");
A1k_allocsd_digits=ndigits_alloc(RA1k);
print_polynomial(A1k_allocsd_digits,"A1k_allocsd_digits","%1d");
print_polynomial(A1k_allocsd_digits,"A1k_allocsd_digits", ...
                 strcat(strf,"_A1k_allocsd_digits.m"),"%1d");
A2k_allocsd_digits=ndigits_alloc(RA2k);
print_polynomial(A2k_allocsd_digits,"A2k_allocsd_digits","%1d");
print_polynomial(A2k_allocsd_digits,"A2k_allocsd_digits", ...
                 strcat(strf,"_A2k_allocsd_digits.m"),"%1d");
% Find the signed-digit approximations to k0
[A1k0_sd,A1k0_sdu,A1k0_sdl]=flt2SD(A1k0,nbits,ndigits_alloc(RA1k));
[A2k0_sd,A2k0_sdu,A2k0_sdl]=flt2SD(A2k0,nbits,ndigits_alloc(RA2k));
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
ylabel("Amplitude error");
axis([0 0.5 0.01*[-1,1]]);
grid("on");
strt=sprintf("Signed-digit parallel allpass");
title(strt);
subplot(312);
plot(wp*0.5/pi,([P_k0 P_k0_sd Pdl Pdu]+(wp*tp))/pi);
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 pp+(0.004*[-1 1])]);
grid("on");
subplot(313);
plot(wt*0.5/pi,[T_k0 T_k0_sd Tdl Tdu]);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 tp+0.04*[-1,1]]);
grid("on");
zticks([]);
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

%
% Loop finding truncated coefficients
%

% Define stack of current filter coefficients and tree depth
k_stack=cell(1,n_active);
k_b=zeros(size(k0));
k_b(k_active)=k0(k_active);
k_bl=k0_l;
k_bu=k0_u;
k_depth=0;
branch_tree=true;
n_branch=0;

% Initialise the search k_min
improved_solution_found=false;
k_min=k0_sd;
Esq_min=Esq0_sd;
printf("Initial Esq_min=%g\n",Esq_min);
printf("Initial k_active=[ ");printf("%d ",k_active);printf("];\n");
printf("Initial k_b=[ ");printf("%g ",k_b');printf("]';\n");

% Fix one coefficient at each iteration 
if use_best_branch_and_bound_found
  % Esq_min=
  branches_min= 0;
  A1k_min = [ 0 ]'/2048;
  A2k_min = [ 0 ]'/2048;
  k_min=[A1k_min(:);A2k_min(:)];
  Esq_min=schurOneMPAlatticeEsq ...
            (A1k_min,A1kones,A1kones,A2k_min,A2kones,A2kones, ...
             difference,wa,Asqd./Azsq,Wa,wt,Td-Tz,Wt,wp-Pz,Pd,Wp,wd,Cd,Wd);
  improved_solution_found=true;
else
  % At each node of a branch, define two SQP sub-problems, one of which is
  % stacked and one of which is solved immediately. If the solved problem
  % reduces Esq_min, then continue to the next node on that branch. If the
  % solved problem does not improve Esq_min then give up on this branch and
  % continue by solving the problem on top of the stack.
  do

    % Choose the sub-problem to solve
    if branch_tree  
      n_branch=n_branch+1;
      [k_sd,k_sdu,k_sdl]=flt2SD(k_b,nbits,ndigits_alloc);
      % Ito et al. suggest ordering the tree branches by max(k_sdu-k_sdl)
      k_sdul=k_sdu-k_sdl;
      if any(k_sdul<0)
        error("any(k_sdul<0)");
      endif
      [k_max,k_max_n]=max(k_sdul(k_active));
      coef_n=k_active(k_max_n);
      k_active(k_max_n)=[];  
      k_b(coef_n)=k_sdl(coef_n); 
      % Push a problem onto the stack
      k_depth=k_depth+1;
      if k_depth>n_active
        error("k_depth(%d)>n_active(%d)",k_depth,n_active);
      endif
      printf("\nBranch %d:coef_n=%d,",n_branch,coef_n);
      k_problem.k_b=k_b;
      k_problem.k_active=k_active;
      k_stack{k_depth}=k_problem;
      % Set up current problem
      k_b(coef_n)=k_sdu(coef_n);
    else
      % Pop a problem off the stack 
      if k_depth<=0
        error("k_depth(%d)<=0",k_depth);
      endif
      k_problem=k_stack{k_depth};
      k_depth=k_depth-1;
      k_b=k_problem.k_b;
      k_active=k_problem.k_active;
      printf("\nBacktrack:");
    endif
    printf("k_depth=%d\n",k_depth);
    printf("k_active=[ ");printf("%d ",k_active);printf("];\n");
    printf("k_b=[ ");printf("%g ",nscale*k_b');printf("]'/%d;\n",nscale);

  % Update Esq_min
    Esq=schurOneMPAlatticeEsq ...
          (k_b(RA1k),A1kones,A1kones,k_b(RA2k),A2kones,A2kones, ...
           difference,wa,Asqd./Azsq,Wa,wt,Td-Tz,Wt,wp,Pd-Pz,Wp,wd,Cd,Wd);
      
    % Update the active coefficients
    if ~isempty(k_active)
      % Check bound on Esq 
      printf("Found Esq=%g\n",Esq); 
      if Esq<Esq_min
        branch_tree=true;
      else
        branch_tree=false;
      endif
    endif
    
    % At maximum depth there are no active coefficients
    if isempty(k_active)
      branch_tree=false;
      printf("At maximum depth Esq=%g\n",Esq);  
      % Check constraints
      if enforce_pcls_constraints_on_final_filter
        Csq=schurOneMPAlatticeAsq(wa,k_b(RA1k),A1kones,A1kones, ...
                                  k_b(RA2k),A2kones,A2kones,difference);
        Tc=schurOneMPAlatticeT(wt,k_b(RA1k),A1kones,A1kones, ...
                              k_b(RA2k),A2kones,A2kones,difference);
        Pc=schurOneMPAlatticeP(wp,k_b(RA1k),A1kones,A1kones, ...
                              k_b(RA2k),A2kones,A2kones,difference);
        dCsqdw=schurOneMPAlatticedAsqdw(wd,k_b(RA1k),A1kones,A1kones, ...
                                        k_b(RA2k),A2kones,A2kones,difference);
        dAsqdw=(Csq(1:ndp).*dAzsqdw(1:ndp))+(dCsqdw.*(Azsq(1:ndp)));

        vS=schurOneMPAlattice_slb_update_constraints ...
             (Csq,Asqdu./Azsq,Asqdl./Azsq,Wa, ...
              Tc,Tdu-Tz,Tdl-Tz,Wt, ...
              Pc,Pdu-Pz,Pdl-Pz,Wp, ...
              dCsqdw,Cdu,Cdl,Wd, ...
              ctol);
        if ~schurOneMPAlattice_slb_constraints_are_empty(vS)
          printf("At maximum depth constraints are not empty!\n");
          schurOneMPAlattice_slb_show_constraints ...
            (vS,wa,sqrt(Csq.*Azsq),wt,Tc+Tz,wp,Pc+Pz,wd,dCsqdw);
        endif
      else
        vS=schurOneMPAlattice_slb_set_empty_constraints();
      endif
      % Update the best solution
      if Esq<Esq_min && schurOneMPAlattice_slb_constraints_are_empty(vS)
        improved_solution_found=true;
        Esq_min=Esq;
        k_min=k_b;
        branches_min=n_branch;
        printf("Improved solution: k_depth=%d, Esq_min=%g\n",k_depth,Esq_min);
        print_polynomial(k_min,"k_min",nscale);
      endif
    endif

  % Exit the loop when there are no sub-problems left
  until (isempty(k_active)||(branch_tree==false)) && (k_depth==0)
  printf("Branch-and-bound search completed with %d branches\n",n_branch);
endif
  
% Show results
if ~improved_solution_found
  k_min=k_sd;
  warning("Did not find an improved solution!\n");
endif
A1k_min=k_min(RA1k);
A1epsilon_min=schurOneMscale(A1k_min);
A2k_min=k_min(RA2k);
A2epsilon_min=schurOneMscale(A2k_min);
Esq_min=schurOneMPAlatticeEsq(A1k_min,A1epsilon_min,A1kones, ...
                              A2k_min,A2epsilon_min,A2kones, ...
                              difference, ...
                              wa,Asqd./Azsq,Wa, ...
                              wt,Td-Tz,Wt, ...
                              wp,Pd-Pz,Wp, ...
                              wd,Cd,Wd);
printf("\nBest new solution:\nEsq_min=%g\n",Esq_min);
print_polynomial(A1k_min,"A1k_min",nscale);
print_polynomial(A1k_min,"A1k_min",strcat(strf,"_A1k_min_coef.m"),nscale);
printf("A1epsilon_min=[ ");printf("%d ",A1epsilon_min);printf("]';\n");
print_polynomial(A2k_min,"A2k_min",nscale);
print_polynomial(A2k_min,"A2k_min",strcat(strf,"_A2k_min_coef.m"),nscale);
printf("A2epsilon_min=[ ");printf("%d ",A2epsilon_min);printf("]';\n");
% Find the number of signed-digits and adders used
[k_min_digits,k_min_adders]=SDadders(k_min,nbits);
printf("%d signed-digits used\n",k_min_digits);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       k_min_adders,nbits);
fid=fopen(strcat(strf,"_k_min_digits.m"),"wt");
fprintf(fid,"$%d$",k_min_digits);
fclose(fid);
fid=fopen(strcat(strf,"_k_min_adders.m"),"wt");
fprintf(fid,"$%d$",k_min_adders);
fclose(fid);

%
% Make a LaTeX table for cost
%
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Floating point & %8.6f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(Lim)& %8.6f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd,k0_sd_digits,k0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(B-and-B) & %8.6f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_min,k_min_digits,k_min_adders);
fclose(fid);

%
% Calculate response
%

% Squared-amplitude
Csq_k0=schurOneMPAlatticeAsq(wa,A1k0,A1kones,A1kones, ...
                             A2k0,A2kones,A2kones,difference);
Asq_k0=Csq_k0.*Azsq;
A_k0=sqrt(Asq_k0);

Csq_k0_sd=schurOneMPAlatticeAsq(wa,A1k0_sd,A1kones,A1kones, ...
                                A2k0_sd,A2kones,A2kones,difference);
Asq_k0_sd=Csq_k0_sd.*Azsq;
A_k0_sd=sqrt(Asq_k0_sd);

Csq_k_min=schurOneMPAlatticeAsq(wa,A1k_min,A1epsilon_min,A1kones, ...
                               A2k_min,A2epsilon_min,A2kones,difference);
Asq_k_min=Csq_k_min.*Azsq;
A_k_min=sqrt(Asq_k_min);

% Group-delay
Tc_k0=schurOneMPAlatticeT(wt,A1k0,A1kones,A1kones, ...
                          A2k0,A2kones,A2kones,difference);
T_k0=Tc_k0+Tz;
Tc_k0_sd=schurOneMPAlatticeT(wt,A1k0_sd,A1kones,A1kones, ...
                            A2k0_sd,A2kones,A2kones,difference);
T_k0_sd=Tc_k0_sd+Tz;
Tc_k_min=schurOneMPAlatticeT(wt,A1k_min,A1epsilon_min,A1kones, ...
                           A2k_min,A2epsilon_min,A2kones,difference);
T_k_min=Tc_k_min+Tz;

% Phase
Pc_k0=schurOneMPAlatticeP(wp,A1k0,A1kones,A1kones, ...
                          A2k0,A2kones,A2kones,difference);
P_k0=Pc_k0+Pz;
Pc_k0_sd=schurOneMPAlatticeP(wp,A1k0_sd,A1kones,A1kones, ...
                            A2k0_sd,A2kones,A2kones,difference);
P_k0_sd=Pc_k0_sd+Pz;
Pc_k_min=schurOneMPAlatticeP(wp,A1k_min,A1epsilon_min,A1kones, ...
                           A2k_min,A2epsilon_min,A2kones,difference);
P_k_min=Pc_k_min+Pz;

% dCsqdw
dCsqdw_k0=schurOneMPAlatticedAsqdw(wd,A1k0,A1kones,A1kones, ...
                                   A2k0,A2kones,A2kones,difference);
dAsqdw_k0=(Csq_k0(1:ndp).*dAzsqdw(1:ndp)) + (dCsqdw_k0.*Azsq(1:ndp));

dCsqdw_k0_sd=schurOneMPAlatticedAsqdw(wd,A1k0_sd,A1kones,A1kones, ...
                                      A2k0_sd,A2kones,A2kones,difference);
dAsqdw_k0_sd=(Csq_k0_sd(1:ndp).*dAzsqdw(1:ndp)) + (dCsqdw_k0_sd.*Azsq(1:ndp));

dCsqdw_k_min=schurOneMPAlatticedAsqdw(wd,A1k_min,A1epsilon_min,A1kones, ...
                                     A2k_min,A2epsilon_min,A2kones,difference);
dAsqdw_k_min=(Csq_k_min(1:ndp).*dAzsqdw(1:ndp)) + (dCsqdw_k_min.*Azsq(1:ndp));

%
% Optimised response at local peaks
%

% Amplitude
vAsql=local_max(Asqdl-Asq_k_min);
vAsqu=local_max(Asq_k_min-Asqdu);
wAsqS=unique([wa(vAsql);wa(vAsqu);wa([1,end])]);
AsqS=schurOneMPAlatticeAsq(wAsqS,A1k_min,A1epsilon_min,A1kones, ...
                           A2k_min,A2epsilon_min,A2kones,difference);
printf("k_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:sqrt(AsqS)=[ ");printf("%f ",sqrt(AsqS'));printf(" ]\n");

% Delay
vTl=local_max(Tdl-T_k_min);
vTu=local_max(T_k_min-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
TS=schurOneMPAlatticeT(wTS,A1k_min,A1epsilon_min,A1kones, ...
                       A2k_min,A2epsilon_min,A2kones,difference);
printf("k_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:TS=[ ");printf("%f ",TS');printf("] (Samples)\n");

% Phase
vPl=local_max(Pdl-P_k_min);
vPu=local_max(P_k_min-Pdu);
wPS=sort(unique([wp(vPl);wp(vPu);wp([1,end])]));
PS=schurOneMPAlatticeP(wPS,A1k_min,A1epsilon_min,A1kones, ...
                       A2k_min,A2epsilon_min,A2kones,difference);
PS_on_pi=mod((PS+(wPS*tp))/pi,2);
printf("k_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:PS=[ ");printf("%f ",PS_on_pi');printf("] (rad./pi)\n");

% dCsqdw 
vCl=local_max(Cdl-dCsqdw_k_min);
vCu=local_max(dCsqdw_k_min-Cdu);
wCS=sort(unique([wd(vCl);wd(vCu);wd([1,end])]));
dCsqdwS=schurOneMPAlatticedAsqdw(wCS,A1k_min,A1epsilon_min,A1kones, ...
                                 A2k_min,A2epsilon_min,A2kones,difference);
printf("k_min:fCS=[ ");printf("%f ",wCS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:dCsqdwS=[ ");printf("%f ",dCsqdwS');printf("]\n")

%
% Plot response
%

% Plot stop-band amplitude
plot(wa*0.5/pi,A_k0,"linestyle","-", ...
     wa*0.5/pi,A_k0_sd,"linestyle","--", ...
     wa*0.5/pi,A_k_min,"linestyle","-.");
legend("F-P","S-D(Lim)","S-D(B-and-B)");
legend("location","northeast");
legend("boxoff");
legend("left");
ylabel("Amplitude");
xlabel("Frequency");
strt=sprintf(["Parallel all pass latticelow pass differentiator filter ", ...
 "stop band (nbits=%d,ndigits=%d) : fas=%g,Ars=%g"],nbits,ndigits,fas,Ars);
title(strt);
axis([fas, 0.5, 0 0.004]);
grid("on");
zticks([]);
print(strcat(strf,"_stop_amplitude_response"),"-dpdflatex");  
close

% Plot pass-band amplitude error
plot(wa*0.5/pi,A_k0-Ad,"linestyle","-", ...
     wa*0.5/pi,A_k0_sd-Ad,"linestyle","--", ...
     wa*0.5/pi,A_k_min-Ad,"linestyle","-.");
ylabel("Amplitude");
xlabel("Frequency");
strt=sprintf(["Parallel all pass lattice low pass differentiator filter ", ...
 "pass band(nbits=%d,ndigits=%d) : fap=%g,Arp=%g"],nbits,ndigits,fap,Arp);
title(strt);
axis([0 fap 0.01*[-1,1]]);
legend("F-P","S-D(Lim)","S-D(B-and-B)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_pass_amplitude_error"),"-dpdflatex"); 
close

% Plot pass band relative amplitude response error
ha=plot(wa(Rap)*0.5/pi,(([A_k0(Rap),A_k0_sd(Rap),A_k_min(Rap)])./Ad(Rap))-1);
% Set line style
hls={"-","--","-."};
for c=1:3
  set(ha(c),"linestyle",hls{c});
endfor
axis([0 fap -0.05 0.1]);
grid("on");
ylabel("Relative amplitude");
xlabel("Frequency");
legend("F-P","S-D(Lim)","S-D(B-and-B)");
legend("location","northeast");
legend("boxoff");
legend("left");
zticks([]);
print(strcat(strf,"_pass_relative_error"),"-dpdflatex");
close

% Plot pass-band phase
plot(wp*0.5/pi,mod((P_k0+(wp*tp))/pi,2),"linestyle","-", ...
     wp*0.5/pi,mod((P_k0_sd+(wp*tp))/pi,2),"linestyle","--", ...
     wp*0.5/pi,mod((P_k_min+(wp*tp))/pi,2),"linestyle","-.");
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
strt=sprintf(["Parallel all pass lattice low pass differentiator filter ", ...
 "pass-band(nbits=%d,ndigits=%d) : ftp=%g,tpr=%g"],nbits,ndigits,ftp,tpr);
title(strt);
axis([0, fpp, mod(pp,2)+((0.004)*[-1,1])]);
legend("F-P","S-D(Lim)","S-D(B-and-B)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_pass_phase_response"),"-dpdflatex"); 
close

% Plot pass-band delay
plot(wt*0.5/pi,T_k0,"linestyle","-", ...
     wt*0.5/pi,T_k0_sd,"linestyle","--", ...
     wt*0.5/pi,T_k_min,"linestyle","-.");
ylabel("Delay(samples)");
xlabel("Frequency");
strt=sprintf(["Parallel all pass lattice low pass differentiator filter ", ...
 "pass band(nbits=%d,ndigits=%d) : ftp=%g,tpr=%g"],nbits,ndigits,ftp,tpr);
title(strt);
axis([0, ftp, tp+0.04*[-1,1]]);
legend("F-P","S-D(Lim)","S-D(B-and-B)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_pass_delay_response"),"-dpdflatex");
close

% Plot pass band dCsqdw error
plot(wd*0.5/pi,dCsqdw_k0-Cd,"linestyle","-", ...
     wd*0.5/pi,dCsqdw_k0_sd-Cd,"linestyle","--", ...
     wd*0.5/pi,dCsqdw_k_min-Cd,"linestyle","-.");
ylabel("$\\frac{dCsq}{d\\omega}$ error");
xlabel("Frequency");
strt=sprintf(["Parallel all pass lattice low pass differentiator filter ", ...
 "pass band(nbits=%d,ndigits=%d) : fdp=%g,cpr=%g"],nbits,ndigits,fdp,cpr);
title(strt);
axis([0,fdp,0.02*[-1,1]]);
legend("F-P","S-D(Lim)","S-D(B-and-B)");
legend("location","south");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_pass_dCsqdw_error"),"-dpdflatex");
close

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
% Sanity check on overall
[N_min,D_min]=schurOneMPAlattice2tf(A1k_min,A1kones,A1kones, ...
                                    A2k_min,A2kones,A2kones,difference);
H_min=freqz(N_min,D_min,wa);
if max(abs(abs(H_min.*Hz)-A_k_min)) > 100*eps
  error("max(abs(abs(H_min.*Hz)-A_k_min))(%g*eps) > 100*eps", ...
        max(abs(abs(H_min.*Hz)-A_k_min))/eps)
endif

% Plot poles and zeros
zplane(qroots(flipud(D1k_min(:))),qroots(D1k_min(:)));
zticks([]);
print(strcat(strf,"_D1k_min_pz"),"-dpdflatex");
close
zplane(qroots(flipud(D2k_min(:))),qroots(D2k_min(:)));
zticks([]);
print(strcat(strf,"_D2k_min_pz"),"-dpdflatex");
close
zplane(qroots(conv(N_min(:),Fz)),qroots(D_min(:)));
zticks([]);
print(strcat(strf,"_k_min_pz"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"use_best_branch_and_bound_found=%d\n", ...
        use_best_branch_and_bound_found);
fprintf(fid,"enforce_pcls_constraints_on_final_filter=%d\n", ...
        enforce_pcls_constraints_on_final_filter);
fprintf(fid,sprintf("%s_allocsd_Lim=%d\n", strf, ...
branch_bound_schurOneMPAlattice_lowpass_differentiator_alternate_allocsd_Lim));
fprintf(fid,sprintf("%s_allocsd_Lim=%d\n", strf,...
branch_bound_schurOneMPAlattice_lowpass_differentiator_alternate_allocsd_Ito));
fprintf(fid,"nbits=%d %% Coefficient word length\n",nbits);
fprintf(fid,"ndigits=%d %% Average number of signed digits per coef.\n", ...
        ndigits);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"NA1k=%d %% Allpass filter 1 denominator order\n",NA1k);
fprintf(fid,"NA2k=%d %% Allpass filter 2 denominator order\n",NA2k);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n", ...
        difference);
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

% Save results
eval(sprintf(["save %s.mat ", ...
 "use_best_branch_and_bound_found enforce_pcls_constraints_on_final_filter ", ...
 "branch_bound_schurOneMPAlattice_lowpass_differentiator_alternate_allocsd_Lim ", ...
 "branch_bound_schurOneMPAlattice_lowpass_differentiator_alternate_allocsd_Ito ", ...
 "nbits ndigits ndigits_alloc k_allocsd_digits ctol rho n ", ...
 "fap Arp Wap Wat Ars Was tp tpr Wtp pp ppr Wpp fdp cpr cn Wdp ", ...
 "A1k0 A2k0 A1k0_sd A2k0_sd A1k_min A2k_min"],strf))

% Done
toc;
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));
