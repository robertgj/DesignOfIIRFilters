% branch_bound_schurOneMAPlattice_frm_12_nbits_test.m
% Copyright (C) 2019 Robert G. Jenssen

% Branch-and-bound search of an FRM low-pass filter response with 12-bit
% signed-digit coefficients. The model filter is a Schur one-multiplier
% all-pass lattice filter.

test_common;

unlink("branch_bound_schurOneMAPlattice_frm_12_nbits_test.diary");
unlink("branch_bound_schurOneMAPlattice_frm_12_nbits_test.diary.tmp");
diary branch_bound_schurOneMAPlattice_frm_12_nbits_test.diary.tmp

tic;


% Common strings
strf="branch_bound_schurOneMAPlattice_frm_12_nbits_test";

%
% Options
%
use_best_branch_and_bound_found=true
if use_best_branch_and_bound_found
  warning("Reporting the best branch-and-bound filter found so far. \n\
           Set \"use_best_branch_and_bound_found\"=false to re-run.");
endif
enforce_pcls_constraints_on_final_filter=true
branch_bound_schurOneMAPlattice_frm_12_nbits_test_allocsd_Lim=false
branch_bound_schurOneMAPlattice_frm_12_nbits_test_allocsd_Ito=true

%
% Initial filter from schurOneMAPlattice_frm_socp_slb_test.m
%
k0 = [  -0.0146211106,   0.5777414027,   0.0181702261,  -0.1428708243, ... 
        -0.0045559735,   0.0545939011,   0.0099115903,  -0.0279491983, ... 
        -0.0043777543,   0.0086675795 ]';
epsilon0 = [  1,  1, -1,  1, ... 
              1, -1, -1,  1, ... 
              1, -1 ]';
p0 = ones(size(k0));
u0 = [   0.5698720310,   0.3066139370,  -0.0622874460,  -0.0846974802, ... 
         0.0503130252,   0.0341474095,  -0.0429614935,  -0.0058587109, ... 
         0.0349980389,  -0.0115266842,  -0.0173788251,   0.0128969260, ... 
         0.0100895313,  -0.0087030450,  -0.0047145346,   0.0083435145, ... 
        -0.0004541138,  -0.0075994376,   0.0045979132,   0.0025210304, ... 
        -0.0039022018 ]';
v0 = [  -0.6661044946,  -0.2735403306,   0.1346966860,   0.0031754878, ... 
        -0.0651379084,   0.0491337252,   0.0028885497,  -0.0337456463, ... 
         0.0281133985,  -0.0004993262,  -0.0182710308,   0.0157696235, ... 
         0.0015726826,  -0.0101280774,   0.0079311008,   0.0013575676, ... 
        -0.0066956214,   0.0060711378,  -0.0010413743,  -0.0025151577, ... 
         0.0030291400 ]';

%
% Filter specification
%
n=1000;
tol=1e-4
ctol=tol/10
maxiter=2000
verbose=false
nbits=12
nscale=2^(nbits-1);
ndigits=3
Mmodel=9 % Model filter decimation
Dmodel=9 % Desired model filter passband delay
dmask=length(u0)-1 % FIR masking filter delay
mr=length(k0) % Model filter order
fap=0.3 % Pass band edge
dBap=0.2 % Pass band amplitude ripple
Wap=1 % Pass band amplitude weight
Wat=0 % Transition band amplitude weight
fas=0.3105 % Stop band edge
dBas=37 % Stop band amplitude ripple
Was=10 % Stop band amplitude weight
ftp=fap % Delay pass band edge
tp=(Mmodel*Dmodel)+dmask;
tpr=1 % Peak-to-peak pass band delay ripple
Wtp=0.1 % Pass band delay weight
fpp=fap % Phase pass band edge
pp=0 % Pass band zero-phase phase
ppr=0.02*pi % Peak-to-peak pass band phase ripple
Wpp=0.1 % Pass band phase weight
rho=31/32 % Stability constraint on pole radius

%
% Frequency vectors
%
w=(0:(n-1))'*pi/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;

% Amplitude constraints
wa=w;
wap=wa(1:nap);
was=wa(nas:end);
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
wt=w(1:nap);
Td=zeros(nap,1);
Tdu=(tpr/2)*ones(nap,1);
Tdl=-Tdu;
Wt=Wtp*ones(nap,1);

% Phase constraints
wp=w(1:nap);
Pd=zeros(nap,1);
Pdu=(ppr/2)*ones(nap,1);
Pdl=-Pdu;
Wp=Wpp*ones(nap,1);

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
if branch_bound_schurOneMAPlattice_frm_12_nbits_test_allocsd_Lim
  ndigits_alloc=schurOneMAPlattice_frm_allocsd_Lim ...
                  (nbits,ndigits,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
                   wa,Asqd,ones(size(Wa)), ...
                   wt,Td,ones(size(Wt)), ...
                   wp,Pd,ones(size(Wp)));
elseif branch_bound_schurOneMAPlattice_frm_12_nbits_test_allocsd_Ito
  ndigits_alloc=schurOneMAPlattice_frm_allocsd_Ito ...
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
print_polynomial(epsilon0_sd,"epsilon0_sd");
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
Esq0=schurOneMAPlattice_frmEsq ...
       (k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
        wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Find kuv0_sd error
Esq0_sd=schurOneMAPlattice_frmEsq ...
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
  k_min = [     -16,     1184,       40,     -292, ... 
                 -8,      117,       15,      -55, ... 
                 -7,       16 ]'/2048;
  u_min = [    1168,      623,     -128,     -168, ... 
                104,       64,      -88,       -8, ... 
                 72,      -28,      -32,       28, ... 
                 18,      -17,       -8,       16, ... 
                 -4,       -8,        8,        1, ... 
                 -7 ]'/2048;
  v_min = [   -1361,     -560,      275,        8, ... 
               -132,      104,        6,      -68, ... 
                 60,       -4,      -36,       32, ... 
                  4,      -19,       16,        4, ... 
                -12,       12,       -4,       -4, ... 
                  6 ]'/2048;
  branches_min=8074; % Esq_min=0.00149051; % Stopped after more than 36hrs
  %{ 
  % Previously: 
  dBas=36,Was=100,tpr=2,Wtp=0.02,ppr=0.04*pi,Wpp=0.01
  k_min = [      32,    1232,      -40,     -295, ... 
                  8,     136,       -8,      -56, ... 
                  8,      36 ]'/nscale;
  u_min = [    1200,     606,     -128,     -174, ... 
                109,      64,      -88,       -8, ... 
                 85,     -51,      -16,       24, ... 
                 20,     -20,       -8,       16, ... 
                 -4,     -20,       23,       -8, ... 
                 -4 ]'/nscale;
  v_min = [   -1375,    -542,      274,        7, ... 
               -133,     100,        8,      -72, ... 
                 72,     -11,      -25,       32, ... 
                  2,     -20,       16,        4, ... 
                -15,      20,       -8,        1, ... 
                  4 ]'/nscale;
  branches_min=1175; % Esq_min=0.00155893
  %}
  kuv_min=[k_min(:);u_min(:);v_min(:)];
  [epsilon_min,p_min]=schurOneMscale(k_min);
  Esq_min=schurOneMAPlattice_frmEsq ...
            (k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel, ...
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
      % Find the SQP PCLS solution for the remaining active coefficents
      [nextk,nextu,nextv,slb_iter,opt_iter,func_iter,feasible] = ...
        schurOneMAPlattice_frm_slb ...
          (@schurOneMAPlattice_frm_socp_mmse, ...
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
      Esq=schurOneMAPlattice_frmEsq ...
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
      Esq=schurOneMAPlattice_frmEsq ...
        (k_b,epsilon0,p0,u_b,v_b,Mmodel,Dmodel,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      printf("At maximum depth Esq=%g\n",Esq);  
      % Check constraints
      if enforce_pcls_constraints_on_final_filter
        Asq=schurOneMAPlattice_frmAsq ...
              (wa,k_b,epsilon0,p0,u_b,v_b,Mmodel,Dmodel);
        T=schurOneMAPlattice_frmT ...
              (wt,k_b,epsilon0,p0,u_b,v_b,Mmodel,Dmodel);
        P=schurOneMAPlattice_frmP ...
              (wp,k_b,epsilon0,p0,u_b,v_b,Mmodel,Dmodel);
        vS=schurOneMAPlattice_frm_slb_update_constraints ...
             (Asq,Asqdu,Asqdl,Wa,T,Tdu,Tdl,Wt,P,Pdu,Pdl,Wp,ctol);
        if ~schurOneMAPlattice_frm_slb_constraints_are_empty(vS)
          printf("At maximum depth constraints are not empty!\n");
          schurOneMAPlattice_frm_slb_show_constraints(vS);
        endif
      else
        vS=schurOneMAPlattice_frm_slb_set_empty_constraints();
      endif
      % Update the best solution
      if Esq<Esq_min && ...
         schurOneMAPlattice_frm_slb_constraints_are_empty(vS)
        improved_solution_found=true;
        Esq_min=Esq;
        kuv_min=kuv_b;
        k_min=k_b;
        [epsilon_min,p_min]=schurOneMscale(k_min);
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
if improved_solution_found
  printf("\nBest new solution:\nEsq_min=%g\n",Esq_min);
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
  Asq=schurOneMAPlattice_frmAsq ...
        (wa,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
  vAl=local_max(Asqdl-Asq);
  vAu=local_max(Asq-Asqdu);
  wAsqS=unique([wa(vAl);wa(vAu);wa([1,end])]);
  AsqS=schurOneMAPlattice_frmAsq ...
         (wAsqS,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
  printf("k,u,v_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ](fs==1)\n");
  printf("k,u,v_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ](dB)\n");
  T=schurOneMAPlattice_frmT ...
      (wt,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
  vTl=local_max(Tdl-T);
  vTu=local_max(T-Tdu);
  wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
  TS=schurOneMAPlattice_frmT ...
       (wTS,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
  printf("k,u,v_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ](fs==1)\n");
  printf("k,u,v_min:TS=[ ");printf("%f ",TS'+tp);
  printf("] (Samples)\n")
  P=schurOneMAPlattice_frmP ...
      (wp,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
  vPl=local_max(Pdl-P);
  vPu=local_max(P-Pdu);
  wPS=sort(unique([wp(vPl);wp(vPu);wp([1,end])]));
  PS=schurOneMAPlattice_frmP ...
       (wPS,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
  printf("k,u,v_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ](fs==1)\n");
  printf("k,u,v_min:PS=[ ");printf("%f ",PS'/pi);
  printf("] (rad./pi) adjusted for delay\n");

  %
  % Make a LaTeX table for cost
  %
  fid=fopen(strcat(strf,"_cost.tab"),"wt");
  fprintf(fid,"Exact & %8.6f & & \\\\\n",Esq0);
  fprintf(fid,"%d-bit %d-signed-digit(Ito)&%8.6f & %d & %d \\\\\n",
          nbits,ndigits,Esq0_sd,kuv0_digits,kuv0_adders);
  fprintf(fid,"%d-bit %d-signed-digit(branch-and-bound)&%8.6f & %d & %d \\\\\n",
          nbits,ndigits,Esq_min,kuv_digits,kuv_adders);
  fclose(fid);

  %
  % Plot response
  %
  % Plot amplitude
  AsqP_kuv0=schurOneMAPlattice_frmAsq ...
              (wap,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
  AsqP_kuv0_sd=schurOneMAPlattice_frmAsq ...
                 (wap,k0_sd,epsilon0,p0,u0_sd,v0_sd,Mmodel,Dmodel);
  AsqP_kuv_min=schurOneMAPlattice_frmAsq ...
                 (wap,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
  AsqS_kuv0=schurOneMAPlattice_frmAsq ...
              (was,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
  AsqS_kuv0_sd=schurOneMAPlattice_frmAsq ...
                 (was,k0_sd,epsilon0,p0,u0_sd,v0_sd,Mmodel,Dmodel);
  AsqS_kuv_min=schurOneMAPlattice_frmAsq ...
                 (was,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
  subplot(311);
  [ax,h1,h2]= ...
    plotyy(wap*0.5/pi,10*log10([AsqP_kuv0,AsqP_kuv0_sd,AsqP_kuv_min]), ...
           was*0.5/pi,10*log10([AsqS_kuv0,AsqS_kuv0_sd,AsqS_kuv_min]));
  % Hack to set line colour and style 
  h1c=get(h1,"color");
  for k=1:3
    set(h2(k),"color",h1c{k});
  endfor
  set(h1(1),"linestyle","--");
  set(h1(2),"linestyle","-.");
  set(h1(3),"linestyle","-");
  set(h2(1),"linestyle","--");
  set(h2(2),"linestyle","-.");
  set(h2(3),"linestyle","-");
  set(ax(1),'ycolor','black');
  set(ax(2),'ycolor','black');
  ylabel(ax(1),"Amplitude(dB)");
  set(ax(1),'ycolor','black');
  set(ax(2),'ycolor','black');
  % End of hack
  axis(ax(1),[0 0.5 -dBap dBap]);
  axis(ax(2),[0 0.5 -50 -30]);
  ylabel("Amplitude(dB)");
  strt=sprintf("FRM filter (nbits=%d,ndigits=%d) : fap=%g,fas=%g,\
dBap=%g,dBas=%g,tp=%g,tpr=%g,ppr=%g",nbits,ndigits,fap,fas,dBap,dBas,tp,tpr,ppr);
  title(strt);
  grid("on");
  % Plot delay
  T_kuv0=schurOneMAPlattice_frmT ...
           (wt,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
  T_kuv0_sd=schurOneMAPlattice_frmT ...
              (wt,k0_sd,epsilon0,p0,u0_sd,v0_sd,Mmodel,Dmodel);
  T_kuv_min=schurOneMAPlattice_frmT ...
              (wt,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
  subplot(312);
  plot(wt*0.5/pi,T_kuv0+tp,"linestyle","--", ...
       wt*0.5/pi,T_kuv0_sd+tp,"linestyle","-.", ...
       wt*0.5/pi,T_kuv_min+tp,"linestyle","-");
  axis([0 0.5 tp-tpr tp+tpr]);
  ylabel("Delay(Samples)");
  grid("on");
  % Plot phase
  subplot(313);
  P_kuv0=schurOneMAPlattice_frmP ... 
           (wp,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel);
  P_kuv0_sd=schurOneMAPlattice_frmP ...
              (wp,k0_sd,epsilon0,p0,u0_sd,v0_sd,Mmodel,Dmodel);
  P_kuv_min=schurOneMAPlattice_frmP ...
              (wp,k_min,epsilon_min,p_min,u_min,v_min,Mmodel,Dmodel);
  plot(wp*0.5/pi,P_kuv0/pi,"linestyle","--", ...
       wp*0.5/pi,P_kuv0_sd/pi,"linestyle","-.", ...
       wp*0.5/pi,P_kuv_min/pi,"linestyle","-");
  axis([0 0.5 (pp-ppr)/pi (pp+ppr)/pi]);
  ylabel("Phase(rad./$\\pi$)\n(Adjusted for delay)");
  xlabel("Frequency");
  legend("exact","s-d(Ito)","s-d(SOCP-relax)");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  grid("on");
  print(strcat(strf,"_response"),"-dpdflatex");
  close();
else
  error("Did not find an improved solution!");
endif

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"mr=%d %% Allpass model filter denominator order\n",mr);
fprintf(fid,"Mmodel=%d %% Model filter FRM decimation factor\n",Mmodel);
fprintf(fid,"Dmodel=%d %% Model filter nominal pass band group delay \n",Dmodel);
fprintf(fid,"dmask=%d %% FIR masking filter delay\n",dmask);
fprintf(fid,"fap=%g %% Magnitude-squared pass band edge\n",fap);
fprintf(fid,"dBap=%g %% Pass band magnitude peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Pass band magnitude-squared weight\n",Wap);
fprintf(fid,"fas=%g %% Magnitude-squared stop band edge\n",fas);
fprintf(fid,"dBas=%g %% Stop band magnitude minimum attenuation\n",dBas);
fprintf(fid,"Was=%g %% Stop band magnitude-squared weight\n",Was);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"tp=%d %% Pass band nominal delay\n",tp);
fprintf(fid,"tpr=tp/%g %% Pass band delay peak-to-peak ripple\n",tp/tpr);
fprintf(fid,"Wtp=%g %% Pass band magnitude-squared weight\n",Wap);
fprintf(fid,"fpp=%g %% Phase pass band edge\n",fpp);
fprintf(fid,"ppr=%g*pi %% Pass band phase peak-to-peak ripple (rad.)\n",ppr/pi);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wpp);
fprintf(fid,"rho=%f %% Constraint on allpass pole radius\n",rho);
fclose(fid);

% Save results
save branch_bound_schurOneMAPlattice_frm_12_nbits_test.mat ...
     enforce_pcls_constraints_on_final_filter ...
     branch_bound_schurOneMAPlattice_frm_12_nbits_test_allocsd_Lim ...
     branch_bound_schurOneMAPlattice_frm_12_nbits_test_allocsd_Ito ...
     k0 epsilon0 p0 u0 v0 Mmodel Dmodel ...
     n tol ctol maxiter nbits ndigits ndigits_alloc dmax rho  ...
     fap fas dBap Wap ftp tp tpr Wtp fpp pp ppr Wpp ...
     use_best_branch_and_bound_found improved_solution_found ...
     k0_sd u0_sd v0_sd k_min epsilon_min p_min u_min v_min
       
% Done
toc;
diary off
movefile branch_bound_schurOneMAPlattice_frm_12_nbits_test.diary.tmp ...
         branch_bound_schurOneMAPlattice_frm_12_nbits_test.diary;
