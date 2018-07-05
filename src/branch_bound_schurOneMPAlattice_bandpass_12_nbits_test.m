% branch_bound_schurOneMPAlattice_bandpass_12_nbits_test.m

% Branch-and-bound optimisation of the response of a low-pass filter
% composed of parallel Schur one-multiplier all-pass lattice filters
% with 12-bit 3-signed-digit coefficients.

% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("branch_bound_schurOneMPAlattice_bandpass_12_nbits_test.diary");
unlink("branch_bound_schurOneMPAlattice_bandpass_12_nbits_test.diary.tmp");
diary branch_bound_schurOneMPAlattice_bandpass_12_nbits_test.diary.tmp

% Options
use_best_branch_and_bound_found=true
if use_best_branch_and_bound_found
  warning("Reporting the best branch-and-bound filter found so far. \n\
           Set \"use_best_branch_and_bound_found\"=false to re-run.");
endif
enforce_pcls_constraints_on_final_filter=true
branch_bound_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Lim=true
branch_bound_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Ito=false

tic;

format compact

maxiter=500
verbose=false
strf="branch_bound_schurOneMPAlattice_bandpass_12_nbits_test";

%
% Initial coefficients found by schurOneMPAlattice_socp_slb_bandpass_test.m
%
A1k0 = [ -0.7439798219,   0.6995939122,   0.5687440455,  -0.5949729017, ... 
          0.6418807756,  -0.1876737790,  -0.0727863223,   0.3975097802, ... 
         -0.2987957903,   0.1475939404 ];
A1epsilon0 = [ -1,  -1,   1,   1, ... 
                1,   1,   1,  -1, ... 
               -1,  -1 ];
A1p0 = [  1.3371222843,   0.5123155011,   1.2185846837,   0.6389210876, ... 
          1.2678907588,   0.5921406078,   0.7159920388,   0.7701492424, ... 
          1.1729441127,   0.8618449495 ];
A1p_ones=ones(size(A1p0));
A2k0 = [ -0.3719287724,   0.6200621662,   0.5671128090,  -0.5507078250, ... 
          0.6254086902,  -0.2720910105,  -0.1175660659,   0.4072436737, ... 
         -0.2708847768,   0.1607942619 ];
A2epsilon0 = [ -1,   1,  -1,   1, ... 
                1,   1,   1,   1, ... 
                1,  -1 ];
A2p0 = [  1.1996156084,   0.8116723932,   0.3930711833,   0.7478835290, ... 
          1.3894231491,   0.6670096093,   0.8817645629,   0.9923117728, ... 
          0.6440233154,   0.8502694908 ];
A2p_ones=ones(size(A2p0));

% Initialise coefficient range vectors
NA1=length(A1k0);
NA2=length(A2k0);
R1=1:NA1;
R2=(NA1+1):(NA1+NA2);

% Band pass filter specification
difference=true
tol=1e-4
ctol=1e-6
rho=127/128
m1=length(A1k0);
m2=length(A2k0);
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=2
Wap=0.5
Watl=0.1
Watu=0.1
dBas=40
Wasl=1e4
Wasu=1e4
ftpl=0.09
ftpu=0.21
td=16
tdr=0.2
Wtp=1

%
% Frequency vectors
%
n=1000;
wa=(0:(n-1))'*pi/n;

% Desired squared magnitude response
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Asqd=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)];
Asqdu=[(10^(-dBas/10))*ones(nasl,1); ...
       ones(nasu-nasl-1,1); ...
       (10^(-dBas/10))*ones(n-nasu+1,1)];
Asqdl=[zeros(napl-1,1);(10^(-dBap/10))*ones(napu-napl+1,1);zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];

% Desired pass-band group delay response
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
wt=wa(ntpl:ntpu);
Td=td*ones(ntpu-ntpl+1,1);
Tdu=(td+(tdr/2))*ones(ntpu-ntpl+1,1);
Tdl=(td-(tdr/2))*ones(ntpu-ntpl+1,1);
Wt=Wtp*ones(ntpu-ntpl+1,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Linear constraints
dmax=inf;
k0=[A1k0(:);A2k0(:)];
k0_active=find(k0~=0);
k0_u=rho*ones(size(k0));
k0_l=-k0_u;

% Exact error
Esq0=schurOneMPAlatticeEsq(A1k0,A1epsilon0,A1p_ones, ...
                           A2k0,A2epsilon0,A2p_ones, ...
                           difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Allocate signed-digits to the coefficients
nbits=12
nscale=2^(nbits-1);
ndigits=3
if branch_bound_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Lim
  ndigits_alloc=schurOneMPAlattice_allocsd_Lim ...
                  (nbits,ndigits,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                   difference,wa,Asqd,ones(size(Wa)), ...
                   wt,Td,ones(size(Wt)),wp,Pd,ones(size(Wp)));
elseif branch_bound_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Ito
  ndigits_alloc=schurOneMPAlattice_allocsd_Ito ...
                  (nbits,ndigits,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                   difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
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
                              difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
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
  if branch_bound_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Lim
    % Lim
    A1k_min = [    -1488,     1408,     1104,    -1140, ... 
                    1352,     -484,        0,      752, ... 
                    -560,      320 ]'/2048;
    A2k_min = [     -740,     1296,     1120,    -1039, ... 
                    1342,     -608,      -80,      764, ... 
                    -544,      320 ]'/2048;
    branches_min=349; % 3153 seconds, Esq_min=0.0119449
  else
    % Ito

    A1k_min = [    -1520,     1424,     1150,    -1216, ... 
                    1316,     -384,     -160,      799, ... 
                    -592,      289 ]'/2048;
    A2k_min = [     -768,     1248,     1156,    -1128, ... 
                    1280,     -540,     -248,      816, ... 
                    -546,      304 ]'/2048;
    branches_min=587; % 4601 seconds, Esq_min=0.0151461
  endif
  k_min=[A1k_min(:);A2k_min(:)];
  Esq_min=schurOneMPAlatticeEsq(A1k_min,A1epsilon0,A1p_ones, ...
                                A2k_min,A2epsilon0,A2p_ones, ...
                                difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
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
                       difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
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
                               wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
                               wp,Pd,Pdu,Pdl,Wp,maxiter,tol,ctol,verbose);
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
             difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
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
             difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      printf("At maximum depth Esq=%g\n",Esq);  
      % Check constraints
      if enforce_pcls_constraints_on_final_filter
        Asq=schurOneMPAlatticeAsq(wa,k_b(R1),A1epsilon0,A1p_ones, ...
                                  k_b(R2),A2epsilon0,A2p_ones,difference);
        T=schurOneMPAlatticeT(wt,k_b(R1),A1epsilon0,A1p_ones, ...
                              k_b(R2),A2epsilon0,A2p_ones,difference);
        vS=schurOneMPAlattice_slb_update_constraints ...
             (Asq,Asqdu,Asqdl,Wa,T,Tdu,Tdl,Wt,[],[],[],[],ctol);
        if ~schurOneMPAlattice_slb_constraints_are_empty(vS)
          printf("At maximum depth constraints are not empty!\n");
          schurOneMPAlattice_slb_show_constraints(vS,wa,Asq,wt,T);
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
             difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
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
  T=schurOneMPAlatticeT ...
      (wt,A1k_min,A1epsilon0,A1p_ones,A2k_min,A2epsilon0,A2p_ones,difference);
  vTl=local_max(Tdl-T);
  vTu=local_max(T-Tdu);
  wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
  TS=schurOneMPAlatticeT ...
       (wTS,A1k_min,A1epsilon0,A1p_ones,A2k_min,A2epsilon0,A2p_ones,difference);
  printf("kmin:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
  printf("kmin:TS=[ ");printf("%f ",TS');printf("] (Samples)\n")
  
  % Make a LaTeX table for cost
  fid=fopen(strcat(strf,"_kmin_cost.tab"),"wt");
  fprintf(fid,"Exact & %8.6f & & \\\\\n",Esq0);
  fprintf(fid,"%d-bit %d-signed-digit(Lim)& %8.6f & %d & %d \\\\\n",
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
  T_k0=schurOneMPAlatticeT(wt,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,...
               difference);
  T_k0_sd=schurOneMPAlatticeT ...
           (wt,A1k0_sd,A1epsilon0,A1p_ones,A2k0_sd,A2epsilon0,A2p_ones,...
               difference);
  T_kmin=schurOneMPAlatticeT ...
           (wt,A1k_min,A1epsilon0,A1p_ones,A2k_min,A2epsilon0,A2p_ones,...
               difference);

  % Plot stop-band amplitude
  plot(wa*0.5/pi,10*log10(Asq_k0),"linestyle","-", ...
       wa*0.5/pi,10*log10(Asq_k0_sd),"linestyle","--", ...
       wa*0.5/pi,10*log10(Asq_kmin),"linestyle","-.");
  legend("exact","s-d(Lim)","s-d(SOCP b-and-b)");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  ylabel("Amplitude(dB)");
  xlabel("Frequency");
  strt=sprintf("Parallel one-multplier allpass lattice bandpass filter stop-band\
(nbits=%d,ndigits=%d) : fasl=%g,fasu=%g,dBas=%g",nbits,ndigits,fasl,fasu,dBas);
  title(strt);
  axis([0, 0.5, -70, -20]);
  grid("on");
  print(strcat(strf,"_kmin_stop"),"-dpdflatex"); 
  close

  % Plot pass-band amplitude
  plot(wa*0.5/pi,10*log10(Asq_k0),"linestyle","-", ...
       wa*0.5/pi,10*log10(Asq_k0_sd),"linestyle","--", ...
       wa*0.5/pi,10*log10(Asq_kmin),"linestyle","-.");
  ylabel("Amplitude(dB)");
  strt=sprintf("Parallel one-multplier allpass lattice bandpass filter pass-band\
(nbits=%d,ndigits=%d) : fapl=%g,fapu=%g,dBap=%g",nbits,ndigits,fapl,fapu,dBap);
  title(strt);
  axis([fapl fapu -3, 1]);
  legend("exact","s-d(Lim)","s-d(b-and-b)");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  grid("on");
  print(strcat(strf,"_kmin_pass"),"-dpdflatex");
  close

  % Plot pass-band delay
  plot(wt*0.5/pi,T_k0,"linestyle","-", ...
       wt*0.5/pi,T_k0_sd,"linestyle","--", ...
       wt*0.5/pi,T_kmin,"linestyle","-.");
  ylabel("Delay(Samples)");
  xlabel("Frequency");
  strt=sprintf("Parallel one-multplier allpass lattice bandpass filter pass-band\
(nbits=%d,ndigits=%d) : ftpl=%g,ftpu=%g,tdr=%g",nbits,ndigits,ftpl,ftpu,tdr);
  title(strt);
  axis([ftpl ftpu, td-tdr, td+tdr]);
  legend("exact","s-d(Lim)","s-d(b-and-b)");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  grid("on");
  print(strcat(strf,"_kmin_delay"),"-dpdflatex");
  close

endif

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"use_best_branch_and_bound_found=%d\n", ...
        use_best_branch_and_bound_found);
fprintf(fid,"enforce_pcls_constraints_on_final_filter=%d\n", ...
        enforce_pcls_constraints_on_final_filter);
fprintf(fid,"branch_bound_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Lim\
=%d\n",branch_bound_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Lim);
fprintf(fid,"branch_bound_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Ito\
=%d\n",branch_bound_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Ito);
fprintf(fid,"nbits=%d %% Coefficient word length\n",nbits);
fprintf(fid,"ndigits=%d %% Average number of signed digits per coef.\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n",difference);
fprintf(fid,"m1=%d %% Allpass model filter 1 denominator order\n",m1);
fprintf(fid,"m2=%d %% Allpass model filter 2 denominator order\n",m2);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fapl=%g %% Pass band amplitude response lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Pass band amplitude response upper edge\n",fapu);
fprintf(fid,"dBap=%f %% Pass band amplitude response ripple(dB)\n",dBap);
fprintf(fid,"Wap=%d %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"Watl=%d %% Lower transition band amplitude response weight\n",Watl);
fprintf(fid,"Watu=%d %% Upper transition band amplitude response weight\n",Watu);
fprintf(fid,"fasl=%g %% Stop band amplitude response lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Stop band amplitude response upper edge\n",fasu);
fprintf(fid,"dBas=%f %% Stop band amplitude response ripple(dB)\n",dBas);
fprintf(fid,"Wasl=%d %% Lower stop band amplitude response weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Upper stop band amplitude response weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Pass band group-delay response lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band group-delay response upper edge\n",ftpu);
fprintf(fid,"td=%f %% Pass band nominal group-delay response(samples)\n",td);
fprintf(fid,"tdr=%f %% Pass band group-delay response ripple(samples)\n",tdr);
fprintf(fid,"Wtp=%d %% Pass band group-delay response weight\n",Wtp);
fclose(fid);

% Save results
save branch_bound_schurOneMPAlattice_bandpass_12_nbits_test.mat ...
     use_best_branch_and_bound_found ...
     enforce_pcls_constraints_on_final_filter ...
     branch_bound_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Lim ...
     branch_bound_schurOneMPAlattice_bandpass_12_nbits_test_allocsd_Ito ...
     n m1 m2 difference tol ctol rho  ...
     fapl fapu dBap Wap Watl Watu ...
     fasl fasu dBas Wasl Wasu ...
     ftpl ftpu td tdr Wtp ...
     A1k0 A1epsilon0 A1p0 A2k0 A2epsilon0 A2p0 A1k_min A2k_min 

% Done
toc;
diary off
movefile branch_bound_schurOneMPAlattice_bandpass_12_nbits_test.diary.tmp ...
         branch_bound_schurOneMPAlattice_bandpass_12_nbits_test.diary;
