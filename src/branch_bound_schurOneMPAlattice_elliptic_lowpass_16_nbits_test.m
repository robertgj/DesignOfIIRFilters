% branch_bound_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.m

% Branch-and-bound optimisation of the response of an elliptic low-pass
% filter composed of parallel Schur one-multiplier all-pass lattice
% filters with 16-bit 3-signed-digit coefficients.

% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("branch_bound_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.diary");
unlink ...
  ("branch_bound_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.diary.tmp");
diary branch_bound_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.diary.tmp

% Options
use_best_branch_and_bound_found=true
if use_best_branch_and_bound_found
  warning("Reporting the best branch-and-bound filter found so far. \n\
           Set \"use_best_branch_and_bound_found\"=false to re-run.");
endif
enforce_pcls_constraints_on_final_filter=true
branch_bound_schurOneMPAlattice_elliptic_lowpass_16_nbits_test_allocsd_Lim=false
branch_bound_schurOneMPAlattice_elliptic_lowpass_16_nbits_test_allocsd_Ito=true

tic;

format compact

% Common strings
strf="branch_bound_schurOneMPAlattice_elliptic_lowpass_16_nbits_test";

% Initial filters found by parallel_allpass_socp_slb_test.m
Da1 = [   1.0000000000,  -2.9447627177,   4.3192364731,  -3.5706356574, ... 
          1.6749334117,  -0.3527563375 ]';
Db1 = [   1.0000000000,  -3.5159456806,   6.3379361398,  -6.8370848228, ... 
          4.6564922855,  -1.8722719971,   0.3547979979 ]';

% Lattice decomposition of Da1 and Db1
[A1k0,A1epsilon0,A1p0,~] = tf2schurOneMlattice(flipud(Da1),Da1);
[A2k0,A2epsilon0,A2p0,~] = tf2schurOneMlattice(flipud(Db1),Db1);

% Initialise coefficient range vectors
A1p_ones=ones(size(A1p0));
A2p_ones=ones(size(A2p0));
NA1=length(A1k0);
NA2=length(A2k0);
R1=1:NA1;
R2=(NA1+1):(NA1+NA2);

% Lowpass filter specification
maxiter=500
verbose=false
% Pass separate tolerances for the coefficient step and SeDuMi eps.
tol=1e-4
ctol=1e-8
del.dtol=tol;
del.stol=ctol;
warning("Using coef. delta tolerance=%g, SeDuMi eps=%g\n",del.dtol,del.stol);
n=1000;
difference=false
rho=0.999
fape=0.14
fap=0.15
dBap=0.5
Wap=1
Wape=Wap % Extra passband weight increasing linearly from fape to fap
Wat=1
fas=0.17
fase=0.18
dBas=63
Was=1e4
Wase=Was % Extra passband weight decreasing linearly from fas to fase

%
% Frequency vectors
%

% Desired squared magnitude response
nape=floor(n*fape/0.5)+1;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
nase=ceil(n*fase/0.5)+1;
wa=(0:(n-1))'*pi/n;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];
Wae=[zeros(nape,1); ...
    Wape*((1:(nap-nape))'/(nap-nape)); ...
    zeros(nas-nap-1,1)
    Wase*(((nase-nas):-1:1)'/(nase-nas)); ...
    zeros(n-nase+1,1)];

% Sanity checks
nchka=[nape-1,nape,nape+1,nap-1,nap,nap+1,nas-1,nas,nas+1,nase-1,nase,nase+1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");
printf("Wae(nchka)=[ ");printf("%6.4g ",Wae(nchka)');printf("];\n");

% Linear constraints
dmax=inf;
rho=127/128
k0=[A1k0(:);A2k0(:)];
k0_active=find(k0~=0);
k0_u=rho*ones(size(k0));
k0_l=-k0_u;

% Exact error
Esq0=schurOneMPAlatticeEsq(A1k0,A1epsilon0,A1p_ones, ...
                           A2k0,A2epsilon0,A2p_ones, ...
                           difference,wa,Asqd,Wa);

% Allocate signed-digits to the coefficients
nbits=16
nscale=2^(nbits-1);
ndigits=3
if branch_bound_schurOneMPAlattice_elliptic_lowpass_16_nbits_test_allocsd_Lim
  ndigits_alloc=schurOneMPAlattice_allocsd_Lim ...
                  (nbits,ndigits,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                   difference,wa,Asqd,ones(size(Wa)));
elseif branch_bound_schurOneMPAlattice_elliptic_lowpass_16_nbits_test_allocsd_Ito
  ndigits_alloc=schurOneMPAlattice_allocsd_Ito ...
                  (nbits,ndigits,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                   difference,wa,Asqd,Wa);
else
  ndigits_alloc=zeros(size(k0));
  ndigits_alloc(k0_active)=ndigits;
endif
k0_allocsd_digits=int16(ndigits_alloc);
printf("k0_allocsd_digits=[ ");printf("%2d ",k0_allocsd_digits);printf("]';\n");

% Find the signed-digit approximations to A1k0 and A2k0
[k0_sd,k0_sdu,k0_sdl]=flt2SD(k0,nbits,ndigits_alloc);
[k0_sd_digits,k0_sd_adders]=SDadders(k0_sd,nbits);
A1k0_sd=k0_sd(R1);A2k0_sd=k0_sd(R2);
Esq0_sd=schurOneMPAlatticeEsq(A1k0_sd,A1epsilon0,A1p_ones, ...
                              A2k0_sd,A2epsilon0,A2p_ones, ...
                              difference,wa,Asqd,Wa);
print_polynomial(A1k0_sd,"A1k0_sd",strcat(strf,"_A1k0_sd_coef.m"),nscale);
print_polynomial(A2k0_sd,"A2k0_sd",strcat(strf,"_A2k0_sd_coef.m"),nscale);

% Initialise k_active
k0_sdul=k0_sdu-k0_sdl;
k_active=find(k0_sdul~=0);
n_active=length(k_active);

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
  A1k_min=[ -24576  29696 -27392  23552 -10240 ]'/nscale
  A2k_min=[ -20735  31736 -27648  27648 -23552  10240 ]'/nscale;
  k_min=[A1k_min(:);A2k_min(:)];
  branches_min=55;
  Esq_min=schurOneMPAlatticeEsq(A1k_min,A1epsilon0,A1p_ones, ...
                                A2k_min,A2epsilon0,A2p_ones, ...
                                difference,wa,Asqd,Wa);
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
      if 1
        % Ito et al. suggest ordering the tree branches by max(k_sdu-k_sdl)
        k_sdul=k_sdu-k_sdl;
        if any(k_sdul<0)
          error("any(k_sdul<0)");
        endif
        [k_max,k_max_n]=max(k_sdul(k_active));
      else
        % Use the active coefficient with the largest absolute gradient of Esq
        % This method did not find an improved solution despite running the
        % MMSE case for several hours without completing.
        [~,gradEsq]=schurOneMPAlatticeEsq ...
                      (k_sd(R1),A1epsilon0,A1p_ones, ...
                       k_sd(R2),A2epsilon0,A2p_ones, ...
                       difference,wa,Asqd,Wa);
        [k_max,k_max_n]=max(abs(gradEsq(k_active)));
      endif
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

    % Try to solve the current sub-problem
    try  
      % Find the SOCP PCLS solution for the remaining active coefficents
      [nextA1k,nextA2k,slb_iter,opt_iter,func_iter,feasible] = ...
        schurOneMPAlattice_slb(@schurOneMPAlattice_socp_mmse, ...
                               k_b(R1),A1epsilon0,A1p_ones, ...
                               k_b(R2),A2epsilon0,A2p_ones, ...
                               difference,k0_u,k0_l,k_active,dmax, ...
                               wa,Asqd,Asqdu,Asqdl,Wa+Wae, ...
                               [],[],[],[],[],[],[],[],[],[], ...
                               maxiter,del,ctol,verbose);
      printf("nextA1k=[ ");printf("%g ",nextA1k');printf("]';\n");
      printf("nextA2k=[ ");printf("%g ",nextA2k');printf("]';\n");
    catch
      feasible=false;
      warning("Branch and bound SOCP failed!\n");
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
      nextk=[nextA1k(:);nextA2k(:)];
      k_b(k_active)=nextk(k_active);
      % Check bound on Esq 
      Esq=schurOneMPAlatticeEsq ...
            (k_b(R1),A1epsilon0,A1p_ones,k_b(R2),A2epsilon0,A2p_ones, ...
             difference,wa,Asqd,Wa);
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
      Esq=schurOneMPAlatticeEsq ...
            (k_b(R1),A1epsilon0,A1p_ones,k_b(R2),A2epsilon0,A2p_ones, ...
             difference,wa,Asqd,Wa);
      printf("At maximum depth Esq=%g\n",Esq);  
      % Check constraints
      if enforce_pcls_constraints_on_final_filter
        Asq=schurOneMPAlatticeAsq(wa,k_b(R1),A1epsilon0,A1p_ones, ...
                                  k_b(R2),A2epsilon0,A2p_ones,difference);
        vS=schurOneMPAlattice_slb_update_constraints ...
             (Asq,Asqdu,Asqdl,Wa,[],[],[],[],[],[],[],[],ctol);
        if ~schurOneMPAlattice_slb_constraints_are_empty(vS)
          printf("At maximum depth constraints are not empty!\n");
          schurOneMPAlattice_slb_show_constraints(vS,wa,Asq,[],[],[],[]);
        endif
      else
        vS=schurOneMPAlattice_slb_set_empty_constraints();
      endif
      % Update the best solution
      if Esq<Esq_min && schurOneMPAlattice_slb_constraints_are_empty(vS)
        improved_solution_found=true;
        Esq_min=Esq;
        k_min=k_b;
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
  printf("Did not find an improved solution!\n");
else
  A1k_min=k_min(R1);
  A2k_min=k_min(R2);
  Esq_min=schurOneMPAlatticeEsq ...
            (A1k_min,A1epsilon0,A1p_ones,A2k_min,A2epsilon0,A2p_ones, ...
             difference,wa,Asqd,Wa);
  printf("\nBest new solution:\nEsq_min=%g\n",Esq_min);
  print_polynomial(A1k_min,"A1k_min",nscale);
  print_polynomial(A1k_min,"A1k_min",strcat(strf,"_A1k_min_coef.m"),nscale);
  printf("A1epsilon0=[ ");printf("%d ",A1epsilon0);printf("]';\n");
  print_polynomial(A2k_min,"A2k_min",nscale);
  print_polynomial(A2k_min,"A2k_min",strcat(strf,"_A2k_min_coef.m"),nscale);
  printf("A2epsilon0=[ ");printf("%d ",A2epsilon0);printf("]';\n");
  % Find the number of signed-digits and adders used
  [kmin_digits,kmin_adders]=SDadders(k_min,nbits);
  printf("%d signed-digits used\n",kmin_digits);
  printf("%d %d-bit adders used for coefficient multiplications\n",
         kmin_adders,nbits);
  fid=fopen(strcat(strf,"_kmin_digits.tab"),"wt");
  fprintf(fid,"$%d$",kmin_digits);
  fclose(fid);
  fid=fopen(strcat(strf,"_kmin_adders.tab"),"wt");
  fprintf(fid,"$%d$",kmin_adders);
  fclose(fid);

  % Amplitude,delay and phase at local peaks
  Asq=schurOneMPAlatticeAsq ...
        (wa,A1k_min,A1epsilon0,A1p_ones,A2k_min,A2epsilon0,A2p_ones,difference);
  vAl=local_max(Asqdl-Asq);
  vAu=local_max(Asq-Asqdu);
  wAsqS=unique([wa(vAl);wa(vAu);wa([1,end])]);
  AsqS=schurOneMPAlatticeAsq ...
         (wAsqS,A1k_min,A1epsilon0,A1p_ones,A2k_min,A2epsilon0,A2p_ones, ...
          difference);
  printf("kmin:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
  printf("kmin:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
  
  % Make a LaTeX table for cost
  fid=fopen(strcat(strf,"_kmin_cost.tab"),"wt");
  fprintf(fid,"Exact & %8.6f & & \\\\\n",Esq0);
  fprintf(fid,"%d-bit %d-signed-digit(Ito)& %8.6f & %d & %d \\\\\n",
          nbits,ndigits,Esq0_sd,k0_sd_digits,k0_sd_adders);
  fprintf(fid,"%d-bit %d-signed-digit(SOCP b-and-b) & %8.6f & %d & %d \\\\\n",
          nbits,ndigits,Esq_min,kmin_digits,kmin_adders);
  fclose(fid);

  %
  % Plot response
  %

  % Find squared-magnitude and group-delay
  Asq_k0=schurOneMPAlatticeAsq(wa,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                               difference);
  Asq_k0_sd=schurOneMPAlatticeAsq ...
              (wa,A1k0_sd,A1epsilon0,A1p_ones,A2k0_sd,A2epsilon0,A2p_ones,...
               difference);
  Asq_kmin=schurOneMPAlatticeAsq ...
             (wa,A1k_min,A1epsilon0,A1p_ones,A2k_min,A2epsilon0,A2p_ones,...
               difference);

  % Plot amplitude
  plot(wa*0.5/pi,10*log10(Asq_k0),"linestyle","-", ...
       wa*0.5/pi,10*log10(Asq_k0_sd),"linestyle","--", ...
       wa*0.5/pi,10*log10(Asq_kmin),"linestyle","-.");
  legend("exact","s-d(Ito)","s-d(SOCP b-and-b)");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  ylabel("Amplitude(dB)");
  xlabel("Frequency");
  strt=sprintf("Parallel one-multplier allpass lattice lowpass filter \
(nbits=%d) : fap=%g,fas=%g,dBap=%g,dBas=%g",nbits,fap,fas,dBap,dBas);
  title(strt);
  axis([0, 0.5, -100, 5]);
  grid("on");
  print(strcat(strf,"_kmin"),"-dpdflatex");
  close
 
  % Plot stop-band amplitude
  plot(wa*0.5/pi,10*log10(Asq_k0),"linestyle","-", ...
       wa*0.5/pi,10*log10(Asq_k0_sd),"linestyle","--", ...
       wa*0.5/pi,10*log10(Asq_kmin),"linestyle","-.");
  legend("exact","s-d(Ito)","s-d(SOCP b-and-b)");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  ylabel("Amplitude(dB)");
  xlabel("Frequency");
  title(strt);
  axis([fap, 0.5, -100, -20]);
  grid("on");
  print(strcat(strf,"_kmin_stop"),"-dpdflatex"); 
  close

  % Plot pass-band amplitude
  plot(wa*0.5/pi,10*log10(Asq_k0),"linestyle","-", ...
       wa*0.5/pi,10*log10(Asq_k0_sd),"linestyle","--", ...
       wa*0.5/pi,10*log10(Asq_kmin),"linestyle","-.");
  ylabel("Amplitude(dB)");
  title(strt);
  axis([0, fas, -0.5, 0.1]);
  legend("exact","s-d(Ito)","s-d(b-and-b)");
  legend("location","southwest");
  legend("boxoff");
  legend("left");
  grid("on");
  print(strcat(strf,"_kmin_pass"),"-dpdflatex"); 
  close
endif

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"nbits=%d %% Coefficient word length\n",nbits);
fprintf(fid,"ndigits=%d %% Average number of signed digits per coef.\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n",difference);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fape=%g %% Extra amplitude weight pass band edge\n",fape);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wape=%d %% Extra amplitude pass band weight\n",Wape);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wat=%d %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"fase=%g %% Extra amplitude weight stop band edge\n",fase);
fprintf(fid,"dBas=%d %% amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fprintf(fid,"Wase=%d %% Extra amplitude stop band weight\n",Wase);
fclose(fid);

% Save results
save branch_bound_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.mat ...
     use_best_branch_and_bound_found ...
     n fape fap dBap Wap Wape Wat fas fase dBas Was Wase rho tol ctol ...
     improved_solution_found A1k0 A1epsilon0 A1p0 A2k0 A2epsilon0 A2p0 ...
     difference nbits ndigits ndigits_alloc A1k_min A2k_min
     
% Done
toc;
diary off
movefile ...
  branch_bound_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.diary.tmp ...
  branch_bound_schurOneMPAlattice_elliptic_lowpass_16_nbits_test.diary;