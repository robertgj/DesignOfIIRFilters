% branch_bound_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test.m
% Copyright (C) 2025 Robert G. Jenssen

% Branch-and-bound search of Schur one-multiplier lattice lowpass differentiator
% filter response with denominator polynomial having coefficients only in
% z^2 and 12-bit signed-digit coefficients with Ito et al. allocation

test_common;

strf="branch_bound_schurOneMlattice_lowpass_differentiator_R2_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Options
use_best_branch_and_bound_found=true
if use_best_branch_and_bound_found
  warning("Reporting the best branch-and-bound filter found so far. \n\
           Set \"use_best_branch_and_bound_found\"=false to re-run.");
endif
enforce_pcls_constraints_on_final_filter=false
use_k_scaling=false
use_c_scaling=false
plot_dAsqdw=false

tic;

maxiter=1000
verbose=false
ftol=1e-3
ctol=ftol/10

nbits=12;
nscale=2^(nbits-1);
ndigits=3;

% Low-pass differentiator filter specification
nN=10; % Order of correction filter for (z-1)
R=2;   % Denominator polynomial in z^-2 only
fap=0.2;fas=0.4;
Arp=0.002;Art=0.02;Ars=0.01;Wap=1;Wat=0.0001;Was=0.1;
fpp=fap;pp=1.5;ppr=0.0008;Wpp=1;
ftp=fap;tp=nN-1;tpr=0.008;Wtp=0.1;
fdp=fap;dpr=1;cpr=0.04;Wdp=0.005;

% Frequency points
n=1000;
w=pi*(1:(n-1))'/n;
nap=ceil(fap*n/0.5);
nas=floor(fas*n/0.5);
npp=ceil(fpp*n/0.5);
ntp=ceil(ftp*n/0.5);
ndp=ceil(fdp*n/0.5);

% Pass and transition band amplitudes
wa=w;
Azm1=2*sin(wa/2);
Azm1sq=Azm1.^2;
dAzm1sqdw=2*sin(wa);
Ad=[wa(1:nap)/2;zeros(n-1-nap,1)];
Asqd=Ad.^2;
dAsqddw=Ad;
Adu=[wa(1:nas-1)/2; zeros(n-nas,1)] + ...
    ([Arp*ones(nap,1);Art*ones((nas-nap-1),1);Ars*ones(n-nas,1)]/2);
Asqdu=Adu.^2;
Adl=Ad-([Arp*ones(nap,1);zeros(n-1-nap,1)]/2);
Adl(find(Adl<=0))=0;
Asqdl=Adl.^2;
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas,1)];

% Phase response with z^{-1}-1 removed
wp=w(1:npp);
Pzm1=(pi/2)-(wp/2);
Pd=(pi*pp)-(wp*tp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% Group delay
wt=w(1:ntp);
Tzm1=0.5;
Td=tp*ones(size(wt));
Tdu=Td+(tpr*ones(ntp,1)/2);
Tdl=Td-(tpr*ones(ntp,1)/2);
Wt=Wtp*ones(size(wt));

% dAsqdw response
wd=wa(1:ndp);
Dd=dAsqddw(1:ndp);
Wd=Wdp*ones(size(wd));
Cd=(Dd-(Asqd(1:ndp).*cot(wd/2)))./Azm1sq(1:ndp);
if plot_dAsqdw
  Ddu=Dd+(dpr/2);
  Ddl=Dd-(dpr/2);
  Cdu=Cd+((dpr/2)./Azm1sq(1:ndp));
  Cdl=Cd-((dpr/2)./Azm1sq(1:ndp));
else
  Cdu=Cd+(cpr/2);
  Cdl=Cd-(cpr/2);
  Ddu=Dd+((cpr/2)./Azm1sq(1:ndp));
  Ddl=Dd-((cpr/2)./Azm1sq(1:ndp));
endif

% Sanity check
nachk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Ad(nachk)=[");printf("%g ",Ad(nachk));printf(" ]\n");
printf("Adu(nachk)=[");printf("%g ",Adu(nachk));printf(" ]\n");
printf("Adl(nachk)=[");printf("%g ",Adl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");

% Initialise filter coefficients
schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_k2_coef;
k0=k2(:);clear k2;
schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_epsilon2_coef;
epsilon0=epsilon2(:);clear epsilon2;
schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_p2_coef;
p0=p2(:);clear p2;p_ones=ones(size(k0));
schurOneMlattice_socp_slb_lowpass_differentiator_R2_test_c2_coef;
c0=c2(:);clear c2;

% Find k0 and c0 error
Esq0=schurOneMlatticeEsq(k0,epsilon0,p0,c0,wa, ...
                         Asqd./Azm1sq,Wa, ...
                         wt,Td-Tzm1,Wt, ...
                         wp,Pd-Pzm1,Wp, ...
                         wd,Cd,Wp);

% Calculate the initial response
Csq0=schurOneMlatticeAsq(wa,k0,epsilon0,p_ones,c0);
A0=sqrt(Csq0).*Azm1;
P0=schurOneMlatticeP(wp,k0,epsilon0,p_ones,c0) + Pzm1;
T0=schurOneMlatticeT(wt,k0,epsilon0,p_ones,c0) + Tzm1;
dCsqdw0=schurOneMlatticedAsqdw(wd,k0,epsilon0,p_ones,c0);
dAsqdw0=(Csq0(1:ndp).*dAzm1sqdw(1:ndp))+(dCsqdw0.*(Azm1sq(1:ndp)));

%
% Constraints on the coefficients
%
dmax=0.25
rho=(nscale-1)/nscale
k0=k0(:);
c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kc0=[k0;c0];
kc0_u=[rho*ones(size(k0));10*ones(size(c0))];
kc0_l=-kc0_u;

%
% Signed-digit coefficients with no allocation
%
kc0_sd_no_alloc=flt2SD(kc0,nbits,ndigits);
k0_sd_no_alloc=kc0_sd_no_alloc(1:Nk);
c0_sd_no_alloc=kc0_sd_no_alloc((Nk+1):end);
print_polynomial(k0_sd_no_alloc,"k0_sd_no_alloc",nscale);
print_polynomial(k0_sd_no_alloc,"k0_sd_no_alloc", ...
                 strcat(strf,"_k0_sd_no_alloc_coef.m"),nscale);
print_polynomial(c0_sd_no_alloc,"c0_sd_no_alloc",nscale);
print_polynomial(c0_sd_no_alloc,"c0_sd_no_alloc", ...
                 strcat(strf,"_c0_sd_no_alloc_coef.m"),nscale);

% Find the number of signed-digits and adders used by kc0_sd_no_alloc
[kc0_sd_no_alloc_digits,kc0_sd_no_alloc_adders] = ...
  SDadders(kc0_sd_no_alloc(find(kc0_sd_no_alloc~=0)),nbits);

% Find kc0_sd_no_alloc error
Esq0_sd_no_alloc= ...
  schurOneMlatticeEsq(k0_sd_no_alloc,epsilon0,p_ones,c0_sd_no_alloc, ...
                      wa,Asqd./Azm1sq,Wa, ...
                      wt,Td-Tzm1,Wt, ...
                      wp,Pd-Pzm1,Wp, ...
                      wd,Cd,Wd);

%
% Allocate signed-digits to the coefficients
%
ndigits_alloc=schurOneMlattice_allocsd_Lim ...
                (nbits,ndigits,k0,epsilon0,p_ones,c0, ...
                 wa,Asqd./Azm1sq,ones(size(wa)), ...
                 wt,Td-Tzm1,ones(size(wt)), ...
                 wp,Pd-Pzm1,ones(size(wp)), ...
                 wd,Cd,ones(size(wd)));
k_allocsd_digits=int16(ndigits_alloc(1:Nk));
c_allocsd_digits=int16(ndigits_alloc((Nk+1):end));
% Find the signed-digit approximations to k0 and c0
[kc0_sd,kc0_sdu,kc0_sdl]=flt2SD(kc0,nbits,ndigits_alloc);
k0_sd=kc0_sd(1:Nk);
k0_sd=k0_sd(:);
c0_sd=kc0_sd((Nk+1):end);
c0_sd=c0_sd(:);
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

% Scale the rounded c0 to use all the bits
if use_c_scaling
  c0_rd=round(c0*nscale)/nscale;
  c0_rd_range=ceil(-log2(min(abs(c0_rd(find(c0_rd~=0))))/max(abs(c0_rd))));
  printf("c0 rounded to %d bits has range %d bits\n",nbits,c0_rd_range);
  if exist("cscale","var")~=1
    if (nbits-c0_rd_range-1)<=0
      cscale=1
    else
      cscale=2^(nbits-c0_rd_range-1)
    endif
  endif
else
  cscale=1;
endif
cnscale=cscale*nscale;

% Scale the rounded k0 to use all the bits 
if use_k_scaling
  k0_rd=round(k0*nscale)/nscale;
  k0_rd_range=ceil(-log2(min(abs(k0_rd(find(k0_rd~=0))))/max(abs(k0_rd))));
  printf("k0 rounded to %d bits has range %d bits\n",nbits,k0_rd_range);
  if exist("kscale","var")~=1
    if (nbits-k0_rd_range-1)<=0
      kscale=1
    else
      kscale=2^(nbits-k0_rd_range-1)
    endif
  endif
else
  kscale=1;
endif
knscale=kscale*nscale;

% Scale the signed-digit representation
kc0=[k0*kscale;c0*cscale];
[kc0_sd,kc0_sdu,kc0_sdl]=flt2SD(kc0,nbits,ndigits_alloc);
k0_sd=kc0_sd(1:Nk)/kscale;
k0_sd=k0_sd(:);
c0_sd=kc0_sd((Nk+1):end)/cscale;
c0_sd=c0_sd(:);
print_polynomial(k0_sd,"k0_sd",nscale);
print_polynomial(k0_sd,"k0_sd",strcat(strf,"_k0_sd_coef.m"),nscale);
print_polynomial(c0_sd,"c0_sd",nscale);
print_polynomial(c0_sd,"c0_sd",strcat(strf,"_c0_sd_coef.m"),nscale);
% Initialise kc_active
kc0_sdul=kc0_sdu-kc0_sdl;
kc0_active=find(kc0_sdul~=0);
n_active=length(kc0_active);
% Find the number of signed-digits and adders used by kc0_sd
[kc0_sd_digits,kc0_sd_adders]=SDadders(kc0_sd(kc0_active),nbits);

% Find kc0_sd error
Esq0_sd=schurOneMlatticeEsq(k0_sd,epsilon0,p_ones,c0_sd, ...
                            wa,Asqd./Azm1sq,Wa, ...
                            wt,Td-Tzm1,Wt, ...
                            wp,Pd-Pzm1,Wp, ...
                            wd,Cd,Wd);

% Define stack of current filter coefficients and tree depth
kc_stack=cell(1,n_active);
kc_b=zeros(size(kc0));
kc_b(kc0_active)=kc0(kc0_active);
kc_bl=kc0_l;
kc_bu=kc0_u;
kc_active=kc0_active;
kc_depth=0;
branch_tree=true;
n_branch=0;
% Initialise the search.
improved_solution_found=false;
Esq_min=Esq0_sd;
k_min=k0_sd;
c_min=c0_sd;
printf("Initial Esq_min=%g\n",Esq_min);
printf("Initial kc_active=[ ");printf("%d ",kc_active);printf("];\n");
printf("Initial kc_b=[ ");printf("%g ",kc_b');printf("]';\n");
k_allocsd_digits=int16(ndigits_alloc(1:Nk));
printf("k_allocsd_digits=[ ");printf("%2d ",k_allocsd_digits);printf("]';\n");
c_allocsd_digits=int16(ndigits_alloc((Nk+1):end));
printf("c_allocsd_digits=[ ");printf("%2d ",c_allocsd_digits);printf("]';\n");

if use_best_branch_and_bound_found
  branches_min=377;
  k_min = [        0,      424,        0,      -57, ... 
                   0,       20,        0,       -7, ... 
                   0,        2 ]'/2048;
  c_min = [      -44,     -447,     -587,      -63, ... 
                 150,      -35,      -46,       34, ... 
                   3,      -12,        4 ]'/2048;
  kc_min=[k_min(:)*kscale;c_min(:)*cscale];
  Esq_min=schurOneMlatticeEsq(k_min,epsilon0,p_ones,c_min, ...
                              wa,Asqd./Azm1sq,Wa, ...
                              wt,Td-Tzm1,Wt, ...
                              wp,Pd-Pzm1,Wp, ...
                              wd,Cd,Wd);
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
      [kc_sd,kc_sdu,kc_sdl]=flt2SD(kc_b,nbits,ndigits_alloc);
      if 1
        % Ito et al. suggest ordering the tree branches by max(kc_sdu-kc_sdl)
        kc_sdul=kc_sdu-kc_sdl;
        if any(kc_sdul<0)
          error("any(kc_sdul<0)");
        endif
        [kc_max,kc_max_n]=max(kc_sdul(kc_active));
      else
        % Use the active coefficient with the largest absolute gradient of Esq
        % This method did not find an improved solution despite running the
        % MMSE case for several hours without completing.
        [Esq,gradEsq]= ...
            schurOneMlatticeEsq ...
              (kc_b(1:Nk)/kscale,epsilon0,p_ones,kc_b((Nk+1):end)/cscale, ...
               wa,Asqd./Azm1sq,Wa, ...
               wt,Td-Tzm1,Wt, ...
               wp,Pd-Pzm1,Wp, ...
               wd,Cd,Wd);
        [kc_max,kc_max_n]=max(abs(gradEsq(kc_active)));
      endif
      coef_n=kc_active(kc_max_n);
      kc_active(kc_max_n)=[];  
      kc_b(coef_n)=kc_sdl(coef_n); 
      % Push a problem onto the stack
      kc_depth=kc_depth+1;
      if kc_depth>n_active
        error("kc_depth(%d)>n_active(%d)",kc_depth,n_active);
      endif
      printf("\nBranch:coef_n=%d,",coef_n);
      kc_problem.kc_b=kc_b;
      kc_problem.kc_active=kc_active;
      kc_stack{kc_depth}=kc_problem;
      % Set up current problem
      kc_b(coef_n)=kc_sdu(coef_n);
    else
      % Pop a problem off the stack 
      if kc_depth<=0
        error("kc_depth(%d)<=0",kc_depth);
      endif
      kc_problem=kc_stack{kc_depth};
      kc_depth=kc_depth-1;
      kc_b=kc_problem.kc_b;
      kc_active=kc_problem.kc_active;
      printf("\nBacktrack:");
    endif
    printf("kc_depth=%d\n",kc_depth);
    printf("kc_active=[ ");printf("%d ",kc_active);printf("];\n");
    printf("kc_b=[ ");printf("%g ",nscale*kc_b');printf("]'/nscale;\n");

    % Try to solve the current sub-problem
    try  
      % Find the SOCP PCLS solution for the remaining active coefficients
      [nextk,nextc,slb_iter,opt_iter,func_iter,feasible] = ...
           schurOneMlattice_slb ...
             (@schurOneMlattice_socp_mmse, ...
              kc_b(1:Nk)/kscale,epsilon0,p_ones,kc_b((Nk+1):end)/cscale, ...
              kc_bu,kc_bl,kc_active,dmax, ...
              wa,Asqd./Azm1sq,Asqdu./Azm1sq,Asqdl./Azm1sq,Wa, ...
              wt,Td-Tzm1,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
              wp,Pd-Pzm1,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
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
      warning("Branch and bound SOCP PCLS failed!\n");
    end_try_catch

    % If this problem was not solved then pop a new sub-problem off the stack 
    if ~feasible
      branch_tree=false;
    endif
      
    % Update the active coefficients
    if feasible && ~isempty(kc_active)
      % Update kc_b
      nextkc=[nextk(:)*kscale;nextc(:)*cscale];
      kc_b(kc_active)=nextkc(kc_active);
      % Check bound on Esq 
      Esq=schurOneMlatticeEsq(nextk,epsilon0,p_ones,nextc, ...
                              wa,Asqd./Azm1sq,Wa, ...
                              wt,Td-Tzm1,Wt, ...
                              wp,Pd-Pzm1,Wp, ...
                              wd,Cd,Wd);
      printf("Found Esq=%g\n",Esq); 
      if Esq<Esq_min
        branch_tree=true;
      else
        branch_tree=false;
      endif
    endif
    
    % At maximum depth there are no active coefficients
    if feasible && isempty(kc_active)
      % Update Esq_min
      branch_tree=false;
      k_b=kc_b(1:Nk)/kscale;
      c_b=kc_b((Nk+1):end)/cscale;
      Esq=schurOneMlatticeEsq(k_b,epsilon0,p_ones,c_b,wa, ...
                              Asqd./Azm1sq,Wa, ...
                              wt,Td-Tzm1,Wt, ...
                              wp,Pd-Pzm1,Wp, ...
                              wd,Cd,Wd);
      printf("At maximum depth Esq=%g\n",Esq);  
      % Check constraints
      if enforce_pcls_constraints_on_final_filter
        Csq=schurOneMlatticeAsq(wa,k_b,epsilon0,p_ones,c_b);
        Tc=schurOneMlatticeT(wt,k_b,epsilon0,p_ones,c_b);
        Pc=schurOneMlatticeT(wp,k_b,epsilon0,p_ones,c_b);
        dCsqdw=schurOneMlatticedAsqdw(wd,k_b,epsilon0,p_ones,c_b);
        vS=schurOneMlattice_slb_update_constraints ...
             (Csq,Asqdu./Azm1sq,Asqdl./Azm1sq,Wa, ...
              Tc,Tdu-Tzm1,Tdl-Tzm1,Wt, ...
              Pc,Pdu-Pzm1,Pdl-Pzm1,Wp, ...
              Cd,Cdu,Cdl,Wd, ...
              ctol);
        if ~schurOneMlattice_slb_constraints_are_empty(vS)
          printf("At maximum depth constraints are not empty!\n");
          schurOneMlattice_slb_show_constraints(vS,wa,Csq,wt,Tc,wp,Pc,wd,dCsqdw);
        endif
      else
        vS=schurOneMlattice_slb_set_empty_constraints();
      endif
      % Update the best solution
      if Esq<Esq_min && schurOneMlattice_slb_constraints_are_empty(vS)
        improved_solution_found=true;
        Esq_min=Esq;
        kc_min=kc_b;
        k_min=k_b;
        c_min=c_b;
        printf("Improved solution: kc_depth=%d, Esq_min=%g\n",kc_depth,Esq_min);
        print_polynomial(k_min,"k_min",knscale);
        print_polynomial(c_min,"c_min",cnscale);
      endif
    endif

  % Exit the loop when there are no sub-problems left
  until (isempty(kc_active)||(branch_tree==false)) && (kc_depth==0)
  printf("Branch-and-bound search completed with %d branches\n",n_branch);
endif

% Show results
if ~improved_solution_found
  error("Did not find an improved solution!\n");
endif
printf("\nBest new solution:\nEsq_min=%g\n",Esq_min);
print_polynomial(k_min,"k_min",knscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),knscale);
printf("epsilon0=[ ");printf("%d ",epsilon0');printf("]';\n");
printf("p_ones=[ ");printf("%g ",p_ones');printf("]';\n");
print_polynomial(c_min,"c_min",cnscale);
print_polynomial(c_min,"c_min",strcat(strf,"_c_min_coef.m"),cnscale);
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%2d");
print_polynomial(c_allocsd_digits,"c_allocsd_digits", ...
                 strcat(strf,"_c_allocsd_digits.m"),"%2d");

% Find the number of signed-digits used
[kc_min_digits,kc_min_adders]=SDadders(kc_min(kc0_active),nbits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kc_min_adders,nbits);
fid=fopen(strcat(strf,"_kc_min_adders.tab"),"wt");
fprintf(fid,"%d",kc_min_adders);
fclose(fid);
printf("%d signed-digits used\n",kc_min_digits);
fid=fopen(strcat(strf,"_kc_min_signed_digits.tab"),"wt");
fprintf(fid,"%d",kc_min_digits);
fclose(fid);

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
Csq=schurOneMlatticeAsq(wa,k_min,epsilon0,p_ones,c_min);
Asq=Csq.*Azm1sq;
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AsqS=schurOneMlatticeAsq(wAS,k_min,epsilon0,p_ones,c_min);
AS=sqrt(AsqS);
printf("k,c_min:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:AS=[ ");printf("%f ",AS');printf(" ]\n");
Tc=schurOneMlatticeT(wt,k_min,epsilon0,p_ones,c_min);
T=Tc+Tzm1;
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMlatticeT(wTS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:TS=[ ");printf("%f ",TS');printf("] (samples)\n");
Pc=schurOneMlatticeP(wp,k_min,epsilon0,p_ones,c_min);
P=Pc+Pzm1;
vPl=local_max(Pdl-P);
vPu=local_max(P-Pdu);
wPS=unique([wp(vPl);wp(vPu);wp([1,end])]);
PS=schurOneMlatticeP(wPS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:PS=[ ");printf("%f ",(PS+(wPS*tp))'/pi);printf("] (rad./pi)\n");
dCsqdw=schurOneMlatticedAsqdw(wd,k_min,epsilon0,p_ones,c_min);
dAsqdw=(Csq(1:ndp).*dAzm1sqdw(1:ndp))+(dCsqdw0.*(Azm1sq(1:ndp)));
vDl=local_max(Ddl-dAsqdw);
vDu=local_max(dAsqdw-Ddu);
wDS=unique([wd(vDl);wd(vDu);wd([1,end])]);
DS=schurOneMlatticedAsqdw(wDS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fdS=[ ");printf("%f ",wDS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:dS=[ ");printf("%f ",DS');printf("]\n");

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %10.4e & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit&%10.4e & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd_no_alloc,kc0_sd_no_alloc_digits,kc0_sd_no_alloc_adders);
fprintf(fid,"%d-bit %d-signed-digit(Lim)&%10.4e & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,kc0_sd_digits,kc0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(branch-and-bound)&%10.4e & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,kc_min_digits,kc_min_adders);
fclose(fid);

%
% Plot the response
%

% Calculate response
Csq_kc0=schurOneMlatticeAsq(wa,k0,epsilon0,p_ones,c0);
Asq_kc0=Csq_kc0.*Azm1sq;
Csq_kc0_sd_no_alloc=schurOneMlatticeAsq ...
                      (wa,k0_sd_no_alloc,epsilon0,p_ones,c0_sd_no_alloc);
Asq_kc0_sd_no_alloc=Csq_kc0_sd_no_alloc.*Azm1sq;
Csq_kc0_sd=schurOneMlatticeAsq(wa,k0_sd,epsilon0,p_ones,c0_sd);
Asq_kc0_sd=Csq_kc0_sd.*Azm1sq;
Csq_kc_min=schurOneMlatticeAsq(wa,k_min,epsilon0,p_ones,c_min);
Asq_kc_min=Csq_kc_min.*Azm1sq;

Tc_kc0=schurOneMlatticeT(wt,k0,epsilon0,p_ones,c0);
T_kc0=Tc_kc0+Tzm1;
Tc_kc0_sd_no_alloc=schurOneMlatticeT ...
                     (wt,k0_sd_no_alloc,epsilon0,p_ones,c0_sd_no_alloc);
T_kc0_sd_no_alloc=Tc_kc0_sd_no_alloc+Tzm1;
Tc_kc0_sd=schurOneMlatticeT(wt,k0_sd,epsilon0,p_ones,c0_sd);
T_kc0_sd=Tc_kc0_sd+Tzm1;
Tc_kc_min=schurOneMlatticeT(wt,k_min,epsilon0,p_ones,c_min);
T_kc_min=Tc_kc_min+Tzm1;

Pc_kc0=schurOneMlatticeP(wp,k0,epsilon0,p_ones,c0);
P_kc0=Pc_kc0+Pzm1;
Pc_kc0_sd_no_alloc=schurOneMlatticeP ...
                     (wp,k0_sd_no_alloc,epsilon0,p_ones,c0_sd_no_alloc);
P_kc0_sd_no_alloc=Pc_kc0_sd_no_alloc+Pzm1;
Pc_kc0_sd=schurOneMlatticeP(wp,k0_sd,epsilon0,p_ones,c0_sd);
P_kc0_sd=Pc_kc0_sd+Pzm1;
Pc_kc_min=schurOneMlatticeP(wp,k_min,epsilon0,p_ones,c_min);
P_kc_min=Pc_kc_min+Pzm1;

dCsqdw_kc0=schurOneMlatticedAsqdw(wd,k0,epsilon0,p_ones,c0);
dAsqdw_kc0=(Csq_kc0(1:ndp).*dAzm1sqdw(1:ndp))+(dCsqdw_kc0.*Azm1sq(1:ndp));
dCsqdw_kc0_sd_no_alloc=schurOneMlatticedAsqdw ...
                         (wd,k0_sd_no_alloc,epsilon0,p_ones,c0_sd_no_alloc);
dAsqdw_kc0_sd_no_alloc=(Csq_kc0_sd_no_alloc(1:ndp).*dAzm1sqdw(1:ndp))+ ...
                      (dCsqdw_kc0_sd_no_alloc.*Azm1sq(1:ndp));
dCsqdw_kc0_sd=schurOneMlatticedAsqdw(wd,k0_sd,epsilon0,p_ones,c0_sd);
dAsqdw_kc0_sd=(Csq_kc0_sd(1:ndp).*dAzm1sqdw(1:ndp)) + ...
              (dCsqdw_kc0_sd.*Azm1sq(1:ndp));
dCsqdw_kc_min=schurOneMlatticedAsqdw(wd,k_min,epsilon0,p_ones,c_min);
dAsqdw_kc_min=(Csq_kc_min(1:ndp).*dAzm1sqdw(1:ndp)) + ...
              (dCsqdw_kc_min.*Azm1sq(1:ndp));

% Check response
[N_min,D_min]=schurOneMlattice2tf(k_min,epsilon0,p_ones,c_min);
print_polynomial(N_min,"N_min");
print_polynomial(N_min,"N_min",strcat(strf,"_N_min_coef.m"));
print_polynomial(D_min,"D_min");
print_polynomial(D_min,"D_min",strcat(strf,"_D_min_coef.m"));
Hchk=freqz(N_min(:),D_min(:),wa);
if max(abs(abs(Hchk)-sqrt(Csq_kc_min))) > 10*eps
  error("max(abs(abs(Hchk)-sqrt(Csq_kc_min)))(%g*eps) > 10*eps", ...
        max(abs(abs(Hchk)-sqrt(Csq_kc_min)))/eps);
endif

% Plot response
% Plot amplitude response error
subplot(311);
rap=1:nap;
ras=nas:length(wa);
[ax,ha,hs] = plotyy...
    (wa(rap)*0.5/pi, ...
     sqrt([Asq_kc0(rap),Asq_kc0_sd_no_alloc(rap), ...
           Asq_kc0_sd(rap),Asq_kc_min(rap)])-Ad(rap), ...
     wa(ras)*0.5/pi, ...
     sqrt([Asq_kc0(ras),Asq_kc0_sd_no_alloc(ras), ...
           Asq_kc0_sd(ras),Asq_kc_min(ras)]));
% Copy line colour
hac=get(ha,"color");
hls={"-",":","--","-."};
for c=1:4
  set(hs(c),"color",hac{c});
  set(ha(c),"linestyle",hls{c});
  set(hs(c),"linestyle",hls{c});
endfor
axis(ax(1),[0 0.5 0.004*[-1,1]]);
axis(ax(2),[0 0.5 0.01*[-1,1]]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude error");
strt=sprintf("Schur one-multiplier lattice lowpass differentiator filter : \
nbits=%d,fap=%g,fas=%g,Arp=%g,Ars=%g",nbits,fap,fas,Arp,Ars);
title(strt);
% Plot phase pass-band response
subplot(312);
plot(wp*0.5/pi,(unwrap(P_kc0)+(wp*tp))/pi,"linestyle","-", ...
     wp*0.5/pi,(unwrap(P_kc0_sd_no_alloc)+(wp*tp))/pi,"linestyle",":", ...
     wp*0.5/pi,(unwrap(P_kc0_sd)+(wp*tp))/pi,"linestyle","--", ...
     wp*0.5/pi,(unwrap(P_kc_min)+(wp*tp))/pi,"linestyle","-.");
grid("on");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$)");
axis([0 0.5 pp+0.001*[-1,1]]);
legend("exact","s-d","s-d(Lim)","s-d(BandB)");
legend("location","east");
legend("boxoff");
legend("right");
% Plot group-delay pass-band response
subplot(313);
plot(wt*0.5/pi,T_kc0,"linestyle","-", ...
     wt*0.5/pi,T_kc0_sd_no_alloc,"linestyle",":", ...
     wt*0.5/pi,T_kc0_sd,"linestyle","--", ...
     wt*0.5/pi,T_kc_min,"linestyle","-.");
grid("on");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0 0.5 tp+0.02*[-1,1]]);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot dCsqdw pass-band response error
plot(wd*0.5/pi,dCsqdw_kc0-Cd,"linestyle","-", ...
     wd*0.5/pi,dCsqdw_kc0_sd_no_alloc-Cd,"linestyle",":", ...
     wd*0.5/pi,dCsqdw_kc0_sd-Cd,"linestyle","--", ...
     wd*0.5/pi,dCsqdw_kc_min-Cd,"linestyle","-.");
xlabel("Frequency");
ylabel("dCsqdw error");
axis([0 fdp cpr*[-1,1]]);
strt=sprintf("Schur one-multiplier lattice lowpass differentiator correction \
filter : nbits=%d,fap=%g,fas=%g,Arp=%g,Ars=%g",nbits,fap,fas,Arp,Ars);
title(strt);
legend("exact","s-d","s-d(Lim)","s-d(BandB)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_correction"),"-dpdflatex");
close

% Pole-zero plot
zplane(qroots(conv(N_min(:),[1;-1])),qroots(D_min(:)));
title(strt);
print(strcat(strf,"_pz"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coefficient update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"maxiter=%d %% SQP iteration limit\n",maxiter);
fprintf(fid,"n=%g %% Frequency points across the band\n",n);
fprintf(fid,"%% length(c0)=%d %% Num. tap coefficients\n",length(c0));
fprintf(fid,"%% sum(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",sum(k0~=0));
fprintf(fid,"dmax=%f %% Constraint on norm of coefficient SQP step size\n",dmax);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"Arp=%d %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wat=%d %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Ars=%d %% Amplitude stop band peak-to-peak ripple\n",Ars);
fprintf(fid,"Was=%d %% Amplitude lower stop band weight\n",Was);
fprintf(fid,"fpp=%g %% Phase pass band edge\n",fpp);
fprintf(fid,"pp=%g %% Nominal passband filter phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Phase pass band peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%d %% Phase pass band weight\n",Wpp);
fprintf(fid,"ftp=%g %% Group delay pass band edge\n",ftp);
fprintf(fid,"tp=%g %% Nominal passband filter group delay(samples)\n",tp);
fprintf(fid,"tpr=%g %% Group delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Group delay pass band weight\n",Wtp);
fprintf(fid,"fdp=%g %% Correction filter dAsqdw pass band edge\n",fdp);
fprintf(fid,"cpr=%g %% Correction filter dAsqdw pass band peak-to-peak ripple\n",cpr);
fprintf(fid,"Wdp=%d %% Correction filter dAsqdw pass band weight\n",Wdp);
fclose(fid);

% Save results
eval(sprintf("save %s.mat \
use_best_branch_and_bound_found \
k0 epsilon0 p0 c0 ftol ctol nbits ndigits ndigits_alloc n kscale cscale \
fap Arp Wap fas Ars Was fpp pp ppr Wpp ftp tp tpr Wtp fdp dpr cpr Wdp \
improved_solution_found kc_min_adders kc_min_digits k0_sd_no_alloc c0_sd_no_alloc \
k0_sd c0_sd k_min c_min N_min D_min",strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
