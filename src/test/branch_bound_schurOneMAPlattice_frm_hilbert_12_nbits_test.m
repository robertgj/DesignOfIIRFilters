% branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

% Branch-and-bound search of FRM Hilbert filter response with 12-bit
% signed-digit coefficients. The model filter is implemented as the parallel
% combination of a Schur one-multiplier lattice filter and a delay.

test_common;

delete("branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary");
delete("branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary.tmp");
diary branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary.tmp

tic;


% Common strings
strf="branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test";

%
% Options
%
use_best_branch_and_bound_found=true
if use_best_branch_and_bound_found
  warning(["Reporting the best branch-and-bound filter found so far. \n", ...
 "           Set \"use_best_branch_and_bound_found\"=false to re-run."]);
endif
enforce_pcls_constraints_on_final_filter=false
branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test_allocsd_Lim=false
branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test_allocsd_Ito=false

%
% Initial filter from schurOneMAPlattice_frm_hilbert_socp_slb_test.m
%
schurOneMAPlattice_frm_hilbert_socp_slb_test_k2_coef;
k0=k2;
schurOneMAPlattice_frm_hilbert_socp_slb_test_epsilon2_coef;
epsilon0=epsilon2;
schurOneMAPlattice_frm_hilbert_socp_slb_test_p2_coef;
p0=p2;
schurOneMAPlattice_frm_hilbert_socp_slb_test_u2_coef;
u0=u2;
schurOneMAPlattice_frm_hilbert_socp_slb_test_v2_coef;
v0=v2;

%
% Filter specification
%
n=800
tol=1e-5
ctol=tol
maxiter=2000
verbose=false
nbits=12 % Coefficient length
nscale=2^(nbits-1);
ndigits=2 % Signed-digits per coefficient
Mmodel=7 % Model filter decimation
Dmodel=9 % Desired model filter passband delay
mr=length(k0); % Model filter order
dmask=2*length(v0); % FIR masking filter delay
fap=0.01 % Amplitude pass band edge
fas=0.49 % Amplitude stop band edge
dBap=0.2 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
ftp=0.01 % Delay pass band edge
fts=0.49 % Delay stop band edge
tp=(Mmodel*Dmodel)+dmask % Nominal FRM filter group delay
tpr=tp/90 % Peak-to-peak pass band delay ripple
Wtp=0.005 % Pass band delay weight
fpp=0.01 % Phase pass band edge
fps=0.49 % Phase stop band edge
pp=-pi/2 % Nominal passband phase (adjusted for delay)
ppr=(pi/2)/180 %180 % Peak-to-peak pass band phase ripple
Wpp=0.005 % Pass band phase weight

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
if branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test_allocsd_Lim
  ndigits_alloc=schurOneMAPlattice_frm_hilbert_allocsd_Lim ...
                  (nbits,ndigits,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                   wa,Asqd,ones(size(Wa)), ...
                   wt,Td,ones(size(Wt)), ...
                   wp,Pd,ones(size(Wp)));
elseif branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test_allocsd_Ito
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
print_polynomial(k0_sd,"k0_sd",nscale);
print_polynomial(k0_sd,"k0_sd",strcat(strf,"_k0_sd_coef.m"),nscale);
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

% Find the number of signed-digits adders used
[kuv0_digits,kuv0_adders]=SDadders(kuv0_sd(kuv0_active),nbits);
printf("%d signed-digits used\n",kuv0_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kuv0_adders,nbits);
  
% Initialise the vector of filter coefficients to be optimised
kuv=zeros(size(kuv0));
kuv(kuv0_active)=kuv0(kuv0_active);
kuv_l=kuv0_l;
kuv_u=kuv0_u;
kuv_active=kuv0_active;

%
% Initialise the branch-and-bound search
%

% Define stack of current filter coefficients and tree depth
kuv_stack=cell(1,n_active);
kuv_b=zeros(size(kuv0));
kuv_b(kuv0_active)=kuv0(kuv0_active);
kuv_bl=kuv0_l;
kuv_bu=kuv0_u;
kuv_active=kuv0_active;
kuv_depth=0;
branch_tree=true;
n_branch=0;
% Initialise the search.
improved_solution_found=false;
Esq_min=Esq0_sd;
k_min=k0_sd;
u_min=u0_sd;
v_min=v0_sd;
printf("Initial Esq_min=%g\n",Esq_min);
printf("Initial kuv_active=[ ");printf("%d ",kuv_active);printf("];\n");
printf("Initial kuv_b=[ ");printf("%g ",kuv_b');printf("]';\n");
k_allocsd_digits=int16(ndigits_alloc(Rk));
printf("k_allocsd_digits=[ ");printf("%2d ",k_allocsd_digits);printf("]';\n");
u_allocsd_digits=int16(ndigits_alloc(Ru));
printf("u_allocsd_digits=[ ");printf("%2d ",u_allocsd_digits);printf("]';\n");
v_allocsd_digits=int16(ndigits_alloc(Rv));
printf("v_allocsd_digits=[ ");printf("%2d ",v_allocsd_digits);printf("]';\n");

if use_best_branch_and_bound_found
  if branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test_allocsd_Lim...
  || branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test_allocsd_Ito 
    error("No solution found with signed digit allocation!");
  else
    branches_min=75
    k_min = [    -1152,     -264,      -96,      -36, ...
                   -12 ]'/nscale;
    u_min = [        0,       -3,      -16,      -24, ... 
                   -63,      -72,     -112,     -120, ... 
                   896 ]'/nscale;
    v_min = [       14,        9,       18,        8, ... 
                   -12,      -63,     -160,     -640 ]'/nscale;
  endif
  kuv_min=[k_min(:);u_min(:);v_min(:)];
  Esq_min=schurOneMAPlattice_frm_hilbertEsq ...
            (k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel, ...
             wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
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
      [kuv_sd,kuv_sdu,kuv_sdl]=flt2SD(kuv_b,nbits,ndigits_alloc);
      % Ito et al. suggest ordering the tree branches by max(kuv_sdu-kuv_sdl)
      kuv_sdul=kuv_sdu-kuv_sdl;
      if any(kuv_sdul<0)
        error("any(kuv_sdul<0)");
      endif
      [kuv_max,kuv_max_n]=max(kuv_sdul(kuv_active));
      coef_n=kuv_active(kuv_max_n);
      kuv_active(kuv_max_n)=[];  
      kuv_b(coef_n)=kuv_sdl(coef_n); 
      % Push a problem onto the stack
      kuv_depth=kuv_depth+1;
      if kuv_depth>n_active
        error("kuv_depth(%d)>n_active(%d)",kuv_depth,n_active);
      endif
      printf("\nBranch:coef_n=%d,",coef_n);
      kuv_problem.kuv_b=kuv_b;
      kuv_problem.kuv_active=kuv_active;
      kuv_stack{kuv_depth}=kuv_problem;
      % Set up current problem
      kuv_b(coef_n)=kuv_sdu(coef_n);
    else
      % Pop a problem off the stack 
      if kuv_depth<=0
        error("kuv_depth(%d)<=0",kuv_depth);
      endif
      kuv_problem=kuv_stack{kuv_depth};
      kuv_depth=kuv_depth-1;
      kuv_b=kuv_problem.kuv_b;
      kuv_active=kuv_problem.kuv_active;
      printf("\nBacktrack:");
    endif
    printf("kuv_depth=%d\n",kuv_depth);
    printf("kuv_active=[ ");printf("%d ",kuv_active);printf("];\n");
    printf("kuv_b=[ ");printf("%g ",nscale*kuv_b');printf("]'/%d;\n",nscale);

    % Try to solve the current sub-problem
    try  
      % Find the SQP PCLS solution for the remaining active coefficients
      [nextk,nextu,nextv,slb_iter,opt_iter,func_iter,feasible] = ...
        schurOneMAPlattice_frm_hilbert_slb ...
          (@schurOneMAPlattice_frm_hilbert_socp_mmse, ...
           kuv_b(Rk),epsilon0,p0,kuv_b(Ru),kuv_b(Rv),Mmodel,Dmodel, ...
           kuv_bu,kuv_bl,kuv_active,dmax, ...
           wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
           maxiter,tol,ctol,verbose);
   catch
      feasible=false;
      warning("Branch and bound SQP failed!\n");
      err=lasterror();
      fprintf(stderr,"%s\n", err.message);
      for e=1:length(err.stack)
        fprintf(stderr,"Called %s at line %d\n", ...
                err.stack(e).name,err.stack(e).line);
      endfor
    end_try_catch

    % If this problem was not solved then pop a new sub-problem off the stack 
    if ~feasible
      branch_tree=false;
    endif
      
    % Update the active coefficients
    if feasible && ~isempty(kuv_active)
      % Update kuv_b
      nextkuv=[nextk(:);nextu(:);nextv(:)];
      kuv_b(kuv_active)=nextkuv(kuv_active);
      % Check bound on Esq 
      Esq=schurOneMAPlattice_frm_hilbertEsq ...
            (nextk,epsilon0,p0,nextu,nextv,Mmodel,Dmodel, ...
             wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      printf("Found Esq=%g\n",Esq); 
      if Esq<Esq_min
        branch_tree=true;
      else
        branch_tree=false;
      endif
    endif
    
    % At maximum depth there are no active coefficients
    if feasible && isempty(kuv_active)
      % Update Esq_min
      branch_tree=false;
      k_b=kuv_b(Rk);
      u_b=kuv_b(Ru);
      v_b=kuv_b(Rv);
      Esq=schurOneMAPlattice_frm_hilbertEsq ...
        (k_b,epsilon0,p0,u_b,v_b,Mmodel,Dmodel,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      printf("At maximum depth Esq=%g\n",Esq);  
      % Check constraints
      if enforce_pcls_constraints_on_final_filter
        Asq=schurOneMAPlattice_frm_hilbertAsq ...
              (wa,k_b,epsilon0,p0,u_b,v_b,Mmodel,Dmodel);
        T=schurOneMAPlattice_frm_hilbertT ...
              (wt,k_b,epsilon0,p0,u_b,v_b,Mmodel,Dmodel);
        P=schurOneMAPlattice_frm_hilbertP ...
              (wp,k_b,epsilon0,p0,u_b,v_b,Mmodel,Dmodel);
        vS=schurOneMAPlattice_frm_hilbert_slb_update_constraints ...
             (Asq,Asqdu,Asqdl,Wa,T,Tdu,Tdl,Wt,P,Pdu,Pdl,Wp,ctol);
        if ~schurOneMAPlattice_frm_hilbert_slb_constraints_are_empty(vS)
          printf("At maximum depth constraints are not empty!\n");
          schurOneMAPlattice_frm_hilbert_slb_show_constraints(vS);
        endif
      else
        vS=schurOneMAPlattice_frm_hilbert_slb_set_empty_constraints();
      endif
      % Update the best solution
      if Esq<Esq_min && ...
         schurOneMAPlattice_frm_hilbert_slb_constraints_are_empty(vS)
        improved_solution_found=true;
        Esq_min=Esq;
        kuv_min=kuv_b;
        k_min=k_b;
        u_min=u_b;
        v_min=v_b;
        branches_min=n_branch;
        printf("Improved solution: kuv_depth=%d,Esq_min=%g\n",kuv_depth,Esq_min);
        print_polynomial(k_min,"k_min",nscale);
        print_polynomial(u_min,"u_min",nscale);
        print_polynomial(v_min,"v_min",nscale);
      endif
    endif

  % Exit the loop when there are no sub-problems left
  until (isempty(kuv_active)||(branch_tree==false)) && (kuv_depth==0)
  printf("Branch-and-bound search completed with %d branches\n",n_branch);
endif

% Show results
if ~improved_solution_found
  error("Did not find an improved solution!\n");
endif
printf("\nBest new solution:\nEsq_min=%g\n",Esq_min);
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
printf("epsilon0=[ ");printf("%d ",epsilon0');printf("]';\n");
printf("p0=[ ");printf("%g ",p0');printf("]';\n");
print_polynomial(u_min,"u_min",nscale);
print_polynomial(u_min,"u_min",strcat(strf,"_u_min_coef.m"),nscale);
print_polynomial(v_min,"v_min",nscale);
print_polynomial(v_min,"v_min",strcat(strf,"_v_min_coef.m"),nscale);
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%2d");
print_polynomial(u_allocsd_digits,"u_allocsd_digits", ...
                 strcat(strf,"_u_allocsd_digits.m"),"%2d");
print_polynomial(v_allocsd_digits,"v_allocsd_digits", ...
                 strcat(strf,"_v_allocsd_digits.m"),"%2d");
% Find the number of signed-digits adders used
[kuv_digits,kuv_adders]=SDadders(kuv_min(kuv0_active),nbits);
printf("%d signed-digits used\n",kuv_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kuv_adders,nbits);

% Amplitude,delay and phase at local peaks
Asq=schurOneMAPlattice_frm_hilbertAsq ...
      (wa,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,end])]);
AsqS=schurOneMAPlattice_frm_hilbertAsq ...
       (wAsqS,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
printf("k,u,v_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ](fs==1)\n");
printf("k,u,v_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ](dB)\n");
T=schurOneMAPlattice_frm_hilbertT ...
    (wt,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
TS=schurOneMAPlattice_frm_hilbertT ...
     (wTS,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
printf("k,u,v_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ](fs==1)\n");
printf("k,u,v_min:TS=[ ");printf("%f ",TS'+tp);
printf("] (Samples)\n")
P=schurOneMAPlattice_frm_hilbertP ...
    (wp,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
vPl=local_max(Pdl-P);
vPu=local_max(P-Pdu);
wPS=sort(unique([wp(vPl);wp(vPu);wp([1,end])]));
PS=schurOneMAPlattice_frm_hilbertP ...
     (wPS,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
printf("k,u,v_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ](fs==1)\n");
printf("k,u,v_min:PS=[ ");printf("%f ",PS'/pi);
printf("] (rad./pi) adjusted for delay\n");

%
% Compare with remez
%
b=remez(2*tp,2*[fap fas],[1 1],1,"hilbert");
b_sd=flt2SD(b,nbits,ndigits);
Afir_sd=freqz(b_sd,1,wa);
Pfir_sd=freqz(b_sd,1,w);
Pfir_sd=unwrap(arg(Pfir_sd))+(w*tp);
Pfir_sd=Pfir_sd(npp:nps);
Asq_kuv_min=schurOneMAPlattice_frm_hilbertAsq ...
              (wa,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
P_kuv_min=schurOneMAPlattice_frm_hilbertP ...
            (wp,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
subplot(211);
plot(wa*0.5/pi,20*log10(abs(Afir_sd)),"-", ...
     wa*0.5/pi,10*log10(Asq_kuv_min),"-.");
legend("s-d(remez)","s-d(SOCP-bb)");
legend("location","north");
legend("boxoff");
legend("left");
ylabel("Amplitude(dB)");
axis([0 0.5 -0.5 0.5]);
grid("on");
subplot(212);
plot(wp*0.5/pi,Pfir_sd/pi,"-",wp*0.5/pi,P_kuv_min/pi,"-.");
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
axis([0 0.5 -0.502 -0.498]);
grid("on");
print(strcat(strf,"_remez"),"-dpdflatex");
close
% Find the number of signed-digits used
[b_digits,b_adders]=SDadders(b_sd(1:(tp+1)),nbits);
printf("%d signed-digits used by remez\n",b_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       b_adders,nbits);

% Calculate the FIR cost
Err_fir_sd=((abs(Afir_sd).^2)-Asqd).^2;
Na=length(wa);
Esq_fir_sd=sum(diff(wa).*(Err_fir_sd(1:(Na-1))+Err_fir_sd(2:Na)))/2;

%
% Make a LaTeX table for cost
%
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit&%8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,kuv0_digits,kuv0_adders);
fprintf(fid,"%d-bit %d-signed-digit(branch-and-bound)&%8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,kuv_digits,kuv_adders);
fprintf(fid,"%d-bit %d-signed-digit(remez)&%8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq_fir_sd,b_digits,b_adders);
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
legend("exact","s-d","s-d(SOCP-bb)");
legend("location","north");
legend("boxoff");
legend("left");
ylabel("Amplitude(dB)");
xlabel("Frequency");
strt=sprintf(["FRM Hilbert filter (nbits=12) : ", ...
 "fap=%g,fas=%g,dBap=%g,Wap=%g,tp=%g,Wtp=%g,Wpp=%g"],fap,fas,dBap,Wap,tp,Wtp,Wpp);
title(strt);
axis([0  0.5 -0.2 0.2]);
grid("on");
print(strcat(strf,"_kuv_minAsq"),"-dpdflatex");
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
legend("exact","s-d","s-d(SOCP-bb)");
legend("location","north");
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
            (wt,k_min,epsilon0,p0,u_min,v_min,Mmodel,Dmodel);
plot(wt*0.5/pi,T_kuv0+tp,"linestyle","-", ...
     wt*0.5/pi,T_kuv0_sd+tp,"linestyle","--", ...
     wt*0.5/pi,T_kuv_min+tp,"linestyle","-.");
ylabel("Delay(samples)");
xlabel("Frequency");
title(strt);
axis([0 0.5 78 80]);
legend("exact","s-d","s-d(SOCP-bb)");
legend("location","north");
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
fprintf(fid,"pp=%g*pi %% Pass band phase peak-to-peak ripple (rad.)\n",pp/pi);
fprintf(fid,"ppr=pi/%g %% Pass band phase peak-to-peak ripple (rad.)\n",pi/ppr);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fclose(fid);

% Save results
save branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test.mat ...
     k0 epsilon0 p0 u0 v0 Mmodel Dmodel ...
     n tol ctol maxiter nbits ndigits ndigits_alloc dmax rho  ...
     fap fas dBap Wap ftp fts tp tpr Wtp fpp fps pp ppr Wpp ...
     use_best_branch_and_bound_found improved_solution_found ...
     k_min u_min v_min
       
% Done
toc;
diary off
movefile branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary.tmp ...
         branch_bound_schurOneMAPlattice_frm_hilbert_12_nbits_test.diary;
