% branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_lowpass_12_nbits_test.m

% Branch-and-bound optimisation of the response of a low-pass filter
% composed of parallel doubly pipelined Schur one-multiplier all-pass
% lattice filters in series with a parallel Schur one-multiplier
% all-pass lattice anti-aliasing filter. Both filters use 12-bit
% signed-digit coefficients.

% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_lowpass_12_nbits_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

% Options
use_best_branch_and_bound_found=true
if use_best_branch_and_bound_found
  warning(["Reporting the best branch-and-bound filter found so far. \n", ...
 "Set \"use_best_branch_and_bound_found\"=false to re-run."]);
endif
enforce_pcls_constraints_on_final_filter=false
branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_lowpass_12_nbits_test_allocsd_Lim=false
branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_lowpass_12_nbits_test_allocsd_Ito=true

tic;

ftol=1e-4
ctol=1e-6
maxiter=500
verbose=false
nbits=12
nscale=2^(nbits-1);
ndigits=4


% Initial coefficients found by
% schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test.m
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_A1k2_coef;
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_A2k2_coef;
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_Aaa1k2_coef;
schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test_Aaa2k2_coef;

A1k0=A1k2(:); clear A1k2;
A2k0=A2k2(:); clear A2k2;
Aaa1k0=Aaa1k2(:); clear Aaa1k2;
Aaa2k0=Aaa2k2(:); clear Aaa2k2

k0=[A1k0;A2k0;Aaa1k0;Aaa2k0];

NA1k=length(A1k0);
NA2k=length(A2k0);
NAaa1k=length(Aaa1k0);
NAaa2k=length(Aaa2k0);
NA=NA1k+NA2k+NAaa1k+NAaa2k;
RA1k=1:NA1k;
RA2k=(NA1k+1):(NA1k+NA2k);
RAaa1k=(NA1k+NA2k+1):(NA1k+NA2k+NAaa1k);
RAaa2k=(NA1k+NA2k+NAaa1k+1):(NA1k+NA2k+NAaa1k+NAaa2k);

% Low pass filter specification
difference=false;
fap=0.15;dBap=0.08;Wap=1;Wat=0.01;
fas=0.175;dBas=55;Was=200;
fpp=0.10;pp=0;ppr=0.002;Wpp=1;
ftp=0.10;tp=15;tpr=0.2;Wtp=1;
fdp=0.10;dpr=0.4;Wdp=0.01;

% Frequency points
n=1000;
w=pi*(0:(n-1))'/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;
ntp=ceil(ftp*n/0.5)+1;
npp=ceil(fpp*n/0.5)+1;
ndp=ceil(fdp*n/0.5)+1;

% Pass and transition band amplitudes of combined filters
wa=w;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas+1,1)];

% Sanity check
nachk=[1,nap-1,nap,nap+1,nas-1,nas,nas+1,n-1];
printf("nachk=[");printf("%d ",nachk);printf(" ]\n");
printf("wa(nachk)*0.5/pi=[");printf("%g ",wa(nachk)*0.5/pi);printf(" ]\n");
printf("Asqd(nachk)=[");printf("%g ",Asqd(nachk));printf(" ]\n");
printf("Asqdu(nachk)=[");printf("%g ",Asqdu(nachk));printf(" ]\n");
printf("Asqdl(nachk)=[");printf("%g ",Asqdl(nachk));printf(" ]\n");
printf("Wa(nachk)=[");printf("%g ",Wa(nachk));printf(" ]\n");

% Group delay of combined filters
wt=w(1:ntp);
% Group delay response of z^-2
Tz2=2;
Td=Tz2+tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));

% Phase response of combined filters
wp=w(1:npp);
Pd=(pp*pi)-(wp*(tp+Tz2));
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% dAsqdw response of combined filters
wd=w(1:ndp);
Dd=zeros(ndp,1);
Ddu=Dd+(dpr/2);
Ddl=Dd-(dpr/2);
Wd=Wdp*ones(size(wd));

% Linear constraints
% Reflection coefficient constraint
rho=127/128;
dmax=inf; % For compatibility with SQP
k_u=rho*ones(size(k0));
k_l=-k_u;
k_active=find(k0~=0);

% Allocate signed-digits to the coefficients
if branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_lowpass_12_nbits_test_allocsd_Lim
  strItoLim="Lim"
  if 0
      ndigits_alloc=schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Lim ...
                      (nbits,ndigits, ...
                       k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k), ...
                       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    else
      ndigits_alloc=schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Lim ...
                      (nbits,ndigits, ...
                       k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k), ...
                       wa,Asqd,ones(size(Wa)), ...
                       wt,Td,ones(size(Wt)), ...
                       wp,Pd,ones(size(Wp)), ...
                       wd,Dd,ones(size(Wd))); 
    endif
elseif branch_bound_schurOneMPAlatticeDoublyPipelinedAntiAliased_lowpass_12_nbits_test_allocsd_Ito
  strItoLim="Ito";
  ndigits_alloc=schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Ito ...
                  (nbits,ndigits, ...
                   k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k), ...
                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
else
  strItoLim="none";
  ndigits_alloc=zeros(size(k0));
  ndigits_alloc(k_active)=ndigits;
endif

A1k_allocsd_digits=int16(ndigits_alloc(RA1k));
A2k_allocsd_digits=int16(ndigits_alloc(RA2k));
Aaa1k_allocsd_digits=int16(ndigits_alloc(RAaa1k));
Aaa2k_allocsd_digits=int16(ndigits_alloc(RAaa2k));

printf("A1k_allocsd_digits=[ ");
printf("%2d ",A1k_allocsd_digits);printf("]';\n");
print_polynomial(A1k_allocsd_digits,"A1k_allocsd_digits", ...
                 strcat(strf,"_A1k_allocsd_digits.m"),"%2d");

printf("A2k_allocsd_digits=[ ");
printf("%2d ",A2k_allocsd_digits);printf("]';\n");
print_polynomial(A2k_allocsd_digits,"A2k_allocsd_digits", ...
                 strcat(strf,"_A2k_allocsd_digits.m"),"%2d");

printf("Aaa1k_allocsd_digits=[ ");
printf("%2d ",Aaa1k_allocsd_digits);printf("]';\n");
print_polynomial(Aaa1k_allocsd_digits,"Aaa1k_allocsd_digits", ...
                 strcat(strf,"_Aaa1k_allocsd_digits.m"),"%2d");

printf("Aaa2k_allocsd_digits=[ ");
printf("%2d ",Aaa2k_allocsd_digits);printf("]';\n");
print_polynomial(Aaa2k_allocsd_digits,"Aaa2k_allocsd_digits", ...
                 strcat(strf,"_Aaa2k_allocsd_digits.m"),"%2d");

% Find the signed-digit approximations to k0
[k_sd,k_sdu,k_sdl]=flt2SD(k0,nbits,ndigits_alloc);
A1k_sd=k_sd(RA1k);
A2k_sd=k_sd(RA2k);
Aaa1k_sd=k_sd(RAaa1k);
Aaa2k_sd=k_sd(RAaa2k);
print_polynomial(A1k_sd,"A1k_sd",nscale);
print_polynomial(A1k_sd,"A1k_sd",strcat(strf,"_A1k_sd_coef.m"),nscale);
print_polynomial(A2k_sd,"A2k_sd",nscale);
print_polynomial(A2k_sd,"A2k_sd",strcat(strf,"_A2k_sd_coef.m"),nscale);
print_polynomial(Aaa1k_sd,"Aaa1k_sd",nscale);
print_polynomial(Aaa1k_sd,"Aaa1k_sd",strcat(strf,"_Aaa1k_sd_coef.m"),nscale);
print_polynomial(Aaa2k_sd,"Aaa2k_sd",nscale);
print_polynomial(Aaa2k_sd,"Aaa2k_sd",strcat(strf,"_Aaa2k_sd_coef.m"),nscale);

% Initialise k_active
k_sdul=k_sdu-k_sdl;
k_active=find(k_sdul~=0);
n_active=length(k_active);

% Check for consistent upper and lower bounds
if any(k_sdl>k_sdu)
  error("found k_sdl>k_sdu");
endif
if any(k_sdl>k_sdu)
  error("found k_sdl>k_sdu");
endif
if any(k_sd(k_active)>k_sdu(k_active))
  error("found k_sd(k_active)>k_sdu(k_active)");
endif
if any(k_sdl(k_active)>k_sd(k_active))
  error("found k_sdl(k_active)>kuv0_sd(k_active)");
endif
if any(k0(k_active)>k_sdu(k_active))
  error("found k0(k_active)>k_sdu(k_active)");
endif
if any(k_sdl(k_active)>k0(k_active))
  error("found k_sdl(k_active)>k0(k_active)");
endif

% Find k0 error
Esq0=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
       (k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k), ...
        wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Find k_sd error
Esq_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
       (k_sd(RA1k),k_sd(RA2k),difference,k_sd(RAaa1k),k_sd(RAaa2k), ...
        wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Find the number of signed-digits and adders used by k_sd
[k_sd_digits,k_sd_adders]=SDadders(k_sd(k_active),nbits);

% Initialise the vector of filter coefficients to be optimised
kopt=zeros(size(k0));
kopt(k_active)=k0(k_active);
kopt_l=k_l;
kopt_u=k_u;
kopt_active=k_active;

%
% Loop finding truncated coefficients
%

% Define stack of current filter coefficients and tree depth
k_stack=cell(1,n_active);
k_b=zeros(size(k0));
k_b(k_active)=k0(k_active);
k_bl=k_l;
k_bu=k_u;
k_depth=0;
branch_tree=true;
n_branch=0;

% Initialise the search k_min
improved_solution_found=false;
k_min=k_sd;
Esq_min=Esq_sd;
printf("Initial Esq_min=%g\n",Esq_min);
printf("Initial k_active=[ ");printf("%d ",k_active);printf("];\n");
printf("Initial k_b=[ ");printf("%g ",k_b');printf("]';\n");

% Fix one coefficient at each iteration 
if use_best_branch_and_bound_found
  branches_min=60;
  A1k_min = [  -576,   928,  -912,   768, ... 
               -400,    78 ]'/nscale;
  A2k_min = [   448,  1664, -1184,   808, ... 
               -685,   408,   -93 ]'/nscale;
  Aaa1k_min = [   0,  1536,     0,   128 ]'/nscale;
  Aaa2k_min = [   0,   656,     0 ]'/nscale;
  k_min=[A1k_min(:);A2k_min(:);Aaa1k_min(:);Aaa2k_min(:)];
  Esq_min=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
            (A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min, ...
             wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
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
      [kb_sd,kb_sdu,kb_sdl]=flt2SD(k_b,nbits,ndigits_alloc);
      if 1
        % Ito et al. suggest ordering the tree branches by max(kb_sdu-kb_sdl)
        kb_sdul=kb_sdu-kb_sdl;
        if any(kb_sdul<0)
          error("any(kb_sdul<0)");
        endif
        [k_max,k_max_n]=max(kb_sdul(k_active));
      else
        % Use the active coefficient with the largest absolute gradient of Esq
        % This method did not find an improved solution despite running the
        % MMSE case for several hours without completing.
        [~,gradEsq]=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
           (kb_sd(RA1k),kb_sd(RA2k),difference,kb_sd(RAaa1k),kb_sd(RAaa2k), ...
            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
        [k_max,k_max_n]=max(abs(gradEsq(k_active)));
      endif
      coef_n=k_active(k_max_n);
      k_active(k_max_n)=[];  
      k_b(coef_n)=kb_sdl(coef_n); 
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
      k_b(coef_n)=kb_sdu(coef_n);
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

    % Try to solve the current sub-problem
    try  
      % Find the SOCP PCLS solution for the remaining active coefficients
      feasible=false;
      [nextA1k,nextA2k,nextAaa1k,nextAaa2k, ...
       slb_iter,socp_iter,func_iter,feasible] = ...
        schurOneMPAlatticeDoublyPipelinedAntiAliased_slb ...
          (@schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_mmse, ...
           k_b(RA1k),k_b(RA2k),difference,k_b(RAaa1k),k_b(RAaa2k), ...
           k_bu,k_bl,k_active,dmax, ...
           wa,Asqd,Asqdu,Asqdl,Wa, ...
           wt,Td,Tdu,Tdl,Wt, ...
           wp,Pd,Pdu,Pdl,Wp, ...
           wd,Dd,Ddu,Ddl,Wd, ...
           maxiter,ftol,ctol,verbose);
      printf("nextA1k=[ ");printf("%g ",nextA1k');printf("]';\n");
      printf("nextA2k=[ ");printf("%g ",nextA2k');printf("]';\n");
      printf("nextAaa1k=[ ");printf("%g ",nextAaa1k');printf("]';\n");
      printf("nextAaa2k=[ ");printf("%g ",nextAaa2k');printf("]';\n");
    catch
      feasible=false;
      warning("Branch and bound SOCP relaxation failed!\n");
      err=lasterror();
      fprintf(stderr,"%s\n", err.message);
      for e=1:length(err.stack)
        fprintf(stderr,"Called %s at line %d\n", ...
                err.stack(e).name,err.stack(e).line);
      endfor
    end_try_catch

    % If this problem was not solved then pop a new sub-problem off the stack 
    if feasible==false
      printf("Filter not feasible!\n"); 
      branch_tree=false;
    endif
      
    % Update the active coefficients
    if feasible && ~isempty(k_active)
      % Update k_b
      nextk=[nextA1k(:);nextA2k(:);nextAaa1k(:);nextAaa2k(:)];
      k_b(k_active)=nextk(k_active);
      % Check bound on Esq 
      Esq=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
            (k_b(RA1k),k_b(RA2k),difference,k_b(RAaa1k),k_b(RAaa2k), ...
             wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      printf("Found Esq=%g\n",Esq); 
      if Esq<Esq_min
        branch_tree=true;
      else
        branch_tree=false;
      endif
    endif
    
    % At maximum depth there are no active coefficients
    if feasible && isempty(k_active)
      % Update Esq_min
      branch_tree=false;
      Esq=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
            (k_b(RA1k),k_b(RA2k),difference,k_b(RAaa1k),k_b(RAaa2k), ...
             wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      printf("At maximum depth Esq=%g\n",Esq);  
      % Check constraints
      if enforce_pcls_constraints_on_final_filter
        Asq=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
            (wa,k_b(RA1k),k_b(RA2k),difference,k_b(RAaa1k),k_b(RAaa2k));
        T=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
            (wt,k_b(RA1k),k_b(RA2k),difference,k_b(RAaa1k),k_b(RAaa2k));
        P=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
            (wp,k_b(RA1k),k_b(RA2k),difference,k_b(RAaa1k),k_b(RAaa2k));
        dAsqdw=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
            (wd,k_b(RA1k),k_b(RA2k),difference,k_b(RAaa1k),k_b(RAaa2k));
        vS=schurOneMPAlattice_slb_update_constraints ...
             (Asq,Asqdu,Asqdl,Wa,T,Tdu,Tdl,Wt,P,Pdu,Pdl,Wp,dAsqdw,Ddu,Ddl,Wd,ctol);
        if ~schurOneMPAlattice_slb_constraints_are_empty(vS)
          printf("At maximum depth constraints are not empty!\n");
          schurOneMPAlattice_slb_show_constraints(vS,wa,Asq,wt,T,wp,P,wd,dAsqdw);
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
A1k_min=k_min(RA1k);
A2k_min=k_min(RA2k);
Aaa1k_min=k_min(RAaa1k);
Aaa2k_min=k_min(RAaa2k);

Esq_min=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
       (A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min, ...
        wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);

print_polynomial(A1k_min,"A1k_min",nscale);
print_polynomial(A1k_min,"A1k_min",strcat(strf,"_A1k_min_coef.m"),nscale);
print_polynomial(A2k_min,"A2k_min",nscale);
print_polynomial(A2k_min,"A2k_min",strcat(strf,"_A2k_min_coef.m"),nscale);
print_polynomial(Aaa1k_min,"Aaa1k_min",nscale);
print_polynomial(Aaa1k_min,"Aaa1k_min",strcat(strf,"_Aaa1k_min_coef.m"),nscale);
print_polynomial(Aaa2k_min,"Aaa2k_min",nscale);
print_polynomial(Aaa2k_min,"Aaa2k_min",strcat(strf,"_Aaa2k_min_coef.m"),nscale);

% Find the number of signed-digits and adders used
[k_min_digits,k_min_adders]=SDadders(k_min(k_active),nbits);
printf("%d signed-digits used\n",k_min_digits);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       k_min_adders,nbits);
fid=fopen(strcat(strf,"_k_min_digits.tab"),"wt");
fprintf(fid,"$%d$",k_min_digits);
fclose(fid);
fid=fopen(strcat(strf,"_k_min_adders.tab"),"wt");
fprintf(fid,"$%d$",k_min_adders);
fclose(fid);

% Find squared-magnitude, phase, group-delay and dAsqdw
Asq0=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
         (wa,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);
Asq_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
         (wa,A1k_sd,A2k_sd,difference,Aaa1k_sd,Aaa2k_sd);
Asq_min=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
          (wa,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);

Aaasq0=schurOneMPAlatticeAsq ...
         (wa,Aaa1k0,ones(size(RAaa1k)),ones(size(RAaa1k)), ...
          Aaa2k0,ones(size(RAaa2k)),ones(size(RAaa2k)),false);
Aaasq_sd=schurOneMPAlatticeAsq ...
           (wa,Aaa1k_sd,ones(size(RAaa1k)),ones(size(RAaa1k)), ...
            Aaa2k_sd,ones(size(RAaa2k)),ones(size(RAaa2k)),false);
Aaasq_min=schurOneMPAlatticeAsq ...
            (wa,Aaa1k_min,ones(size(RAaa1k)),ones(size(RAaa1k)), ...
             Aaa2k_min,ones(size(RAaa2k)),ones(size(RAaa2k)),false);

P0=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
         (wp,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);
P_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
         (wp,A1k_sd,A2k_sd,difference,Aaa1k_sd,Aaa2k_sd);
P_min=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
          (wp,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);

T0=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
         (wt,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);
T_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
         (wt,A1k_sd,A2k_sd,difference,Aaa1k_sd,Aaa2k_sd);
T_min=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
         (wt,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);

dAsqdw0=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
          (wd,A1k0,A2k0,difference,Aaa1k0,Aaa2k0);
dAsqdw_sd=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
         (wd,A1k_sd,A2k_sd,difference,Aaa1k_sd,Aaa2k_sd);
dAsqdw_min=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
          (wd,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);

% Amplitude, phase, delay and dAsqdw at local peaks
vAl=local_max(Asqdl-Asq_min);
vAu=local_max(Asq_min-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AsqS=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
       (wAsqS,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);
printf("k_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

vPl=local_max(Pdl-P_min);
vPu=local_max(P_min-Pdu);
nPS=sort(unique([vPl;vPu;1;npp]));
wPS=wp(nPS);
PS=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
     (wPS,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);
PS=mod(PS/pi,2);
PdnPS=mod(Pd(nPS)/pi,2);
printf("k_min:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:PS-Pd=[ ");printf("%f ",(PS-PdnPS)');printf("] (rad.)\n");
                        
vTl=local_max(Tdl-T_min);
vTu=local_max(T_min-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
TS=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
     (wTS,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);
printf("k_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:TS=[ ");printf("%f ",TS');printf("] (Samples)\n");
                        
vDl=local_max(Ddl-dAsqdw_min);
vDu=local_max(dAsqdw_min-Ddu);
wDS=sort(unique([wd(vDl);wd(vDu);wd([1,end])]));
DS=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
     (wDS,A1k_min,A2k_min,difference,Aaa1k_min,Aaa2k_min);
printf("k_min:fDS=[ ");printf("%f ",wDS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k_min:DS=[ ");printf("%f ",DS');printf("] (Samples)\n");
                        
% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(%s)& %8.6f & %d & %d \\\\\n", ...
        nbits,ndigits,strItoLim,Esq_sd,k_sd_digits,k_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(B-B) & %8.6f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_min,k_min_digits,k_min_adders);
fclose(fid);

%
% Plot response
%

% Plot pass-band amplitude
plot(wa*0.5/pi,10*log10(Asq0),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_min),"linestyle","-.");
ylabel("Amplitude(dB)");
xlabel("Frequency");
strt=sprintf(["Parallel OneM all-pass lattice low-pass filter :", ...
              " (nbits=%d) fap=%g,dBap=%g,Wap=%g,tp=%g,Wtp=%g"], ...
             nbits,fap,dBap,Wap,tp,Wtp);
title(strt);
axis([0 0.5 -0.1 0.05]);
legend("exact",sprintf("s-d(%s)",strItoLim),"s-d(B-B)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_k_min_pass_amplitude"),"-dpdflatex");
close

% Plot stop-band amplitude
plot(wa*0.5/pi,10*log10(Asq0),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_min),"linestyle","-.");
legend("exact",sprintf("s-d(%s)",strItoLim),"s-d(B-B)");
legend("location","northwest");
legend("boxoff");
legend("left");
ylabel("Amplitude(dB)");
xlabel("Frequency");
strt=sprintf(["Parallel OneM all-pass lattice low-pass filter :", ...
              " (nbits=%d) fas=%g,dBas=%g,Was=%g"],nbits,fas,dBas,Was);
title(strt);
axis([0 0.5 -80 -30]);
grid("on");
zticks([]);
print(strcat(strf,"_k_min_stop_amplitude"),"-dpdflatex");
close

% Plot anti-aliasing filter amplitude
plot(wa*0.5/pi,10*log10(Aaasq0),"linestyle","-", ...
     wa*0.5/pi,10*log10(Aaasq_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Aaasq_min),"linestyle","-.");
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.5 -70 5]);
grid("on");
legend("exact",sprintf("s-d(%s)",strItoLim),"s-d(B-B)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
strt=sprintf(["Parallel OneM all-pass lattice anti-aliasing filter :", ...
              " (nbits=%d) fap=%g,fas=,dBas=%g"],nbits,fap,fas,dBas);
title(strt);
zticks([]);
print(strcat(strf,"_k_min_antialiasing"),"-dpdflatex");
close

% Plot pass-band delay
plot(wt*0.5/pi,T0,"linestyle","-", ...
     wt*0.5/pi,T_sd,"linestyle","--", ...
     wt*0.5/pi,T_min,"linestyle","-.");
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 (tp+Tz2)+[-0.1 0.15]]);
grid("on");
legend("exact",sprintf("s-d(%s)",strItoLim),"s-d(B-B)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
strt=sprintf(["Parallel OneM all-pass lattice low-pass filter :", ...
              " (nbits=%d) ftp=%g,tp=%g,Wtp=%g"],nbits,ftp,tp,Wtp);
title(strt);
zticks([]);
print(strcat(strf,"_k_min_pass_delay"),"-dpdflatex");
close

% Plot pass-band phase error
plot(wp*0.5/pi,(P0-Pd)/pi,"linestyle","-", ...
     wp*0.5/pi,(P_sd-Pd)/pi,"linestyle","--", ...
     wp*0.5/pi,(P_min-Pd)/pi,"linestyle","-.");
ylabel("Phase error(rad./$\\pi$)");
xlabel("Frequency");
axis([0 0.5 0.001*[-1 1]]);
grid("on");
legend("exact",sprintf("s-d(%s)",strItoLim),"s-d(B-B)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
strt=sprintf(["Parallel OneM all-pass lattice low-pass filter :", ...
              " (nbits=%d) fpp=%g,ppr=%g,Wpp=%g"],nbits,fpp,ppr,Wpp);
title(strt);
zticks([]);
print(strcat(strf,"_k_min_pass_phase"),"-dpdflatex");
close

% Plot pass-band dAsqdw
plot(wd*0.5/pi,dAsqdw0,"linestyle","-", ...
     wd*0.5/pi,dAsqdw_sd,"linestyle","--", ...
     wd*0.5/pi,dAsqdw_min,"linestyle","-.");
ylabel("$\\frac{d\\lvert A\\rvert^{2}}{dw}$");
xlabel("Frequency");
axis([0 0.5 0.4*[-1 1]]);
grid("on");
legend("exact",sprintf("s-d(%s)",strItoLim),"s-d(B-B)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
strt=sprintf(["Parallel OneM all-pass lattice low-pass filter :", ...
              " (nbits=%d) fdp=%g,dpr=%g,Wdp=%g"],nbits,fdp,dpr,Wdp);
title(strt);
zticks([]);
print(strcat(strf,"_k_min_pass_dAsqdw"),"-dpdflatex");
close

% Plot amplitude
rap=1:nap;
ras=nas:(n-1);
[ax,ha,hs]= plotyy(wa(rap)*0.5/pi, ...
                   10*log10([Asq0(rap),Asq_sd(rap),Asq_min(rap)]), ...
                   wa(ras)*0.5/pi, ...
                   10*log10([Asq0(ras),Asq_sd(ras),Asq_min(ras)]));
% Copy line colour
hac=get(ha,"color");
hls={"-","--","-."};
for c=1:3
  set(hs(c),"color",hac{c});
  set(ha(c),"linestyle",hls{c});
  set(hs(c),"linestyle",hls{c});
endfor
axis(ax(1),[0 0.5 -0.1 0.02]);
axis(ax(2),[0 0.5 -80 -20]);
strt=sprintf(["Parallel OneM all-pass lattice low-pass filter :", ...
              " (nbits=%d) fap=%g,dBap=%g,Wap=%g,tp=%g,Wtp=%g"], ...
             nbits,fap,dBap,Wap,tp,Wtp);
title(strt);
grid("on");
ylabel("Amplitude(dB)");
xlabel("Frequency");
legend("exact",sprintf("s-d(%s)",strItoLim),"s-d(B-B)");
legend("location","north");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_k_min_amplitude"),"-dpdflatex");
close

% Plot pass-band phase error and delay
subplot(211)
plot(wp*0.5/pi,(P0-Pd)/pi,"linestyle","-", ...
     wp*0.5/pi,(P_sd-Pd)/pi,"linestyle","--", ...
     wp*0.5/pi,(P_min-Pd)/pi,"linestyle","-.");
ylabel("Phase error(rad./$\\pi$)");
axis([0 0.5 0.001*[-1 1]]);
grid("on");
legend("exact",sprintf("s-d(%s)",strItoLim),"s-d(B-B)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
strt=sprintf(["Parallel OneM all-pass lattice low-pass filter :", ...
              " (nbits=%d) fpp=%g,ppr=%g,ftp=%g,tpr=%g"], ...
             nbits,fpp,ppr,ftp,tpr);
title(strt);
zticks([]);
subplot(212)
plot(wt*0.5/pi,T0,"linestyle","-", ...
     wt*0.5/pi,T_sd,"linestyle","--", ...
     wt*0.5/pi,T_min,"linestyle","-.");
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 (tp+Tz2)+[-0.1 0.15]]);
grid("on");
zticks([]);
print(strcat(strf,"_k_min_phase_delay"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%d %% Coefficient word length\n",nbits);
fprintf(fid,"ndigits=%d %% Average number of signed digits per coef.\n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wat=%d %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%d %% amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fprintf(fid,"fpp=%g %% Pass band phase edge\n",fpp);
fprintf(fid,"pp=%g %% Nominal pass band phase(rad./pi)\n",pp);
fprintf(fid,"ppr=%g %% Pass band phase peak-to-peak ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%g %% Pass band phase weight\n",Wpp);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fprintf(fid,"fdp=%g %% Pass band dAsqdw edge\n",fpp);
fprintf(fid,"dpr=%g %% Pass band dAsqdw peak-to-peak ripple\n",dpr);
fprintf(fid,"Wdp=%g %% Pass band dAsqdw weight\n",Wpp);
fclose(fid);

% Save results
eval(sprintf(["save %s.mat ", ...
 " n  rho ftol ctol fap dBap Wap Wat fas dBas Was ftp tp tpr Wtp ", ...
 " fpp pp ppr Wpp ftp tp tpr Wtp fdp dpr Wdp ", ...
 " nbits ndigits ndigits_alloc A1k_min A2k_min Aaa1k_min Aaa2k_min"], ...
             strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
