% branch_bound_schurOneMPAlattice_bandpass_hilbert_10_nbits_test.m
% Branch-and-bound optimisation of the response of a Hilbert band-pass filter
% composed of parallel Schur one-multiplier all-pass lattice filters
% with 10-bit 3-signed-digit coefficients.
% Copyright (C) 2017-2024 Robert G. Jenssen

test_common;

strf="branch_bound_schurOneMPAlattice_bandpass_hilbert_10_nbits_test";
delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Options
use_best_branch_and_bound_found=true
if use_best_branch_and_bound_found
  warning("Reporting the best branch-and-bound filter found so far. \n\
           Set \"use_best_branch_and_bound_found\"=false to re-run.");
endif
enforce_pcls_constraints_on_final_filter=true

tic;

tol=1e-4
ctol=1e-5
maxiter=1000
verbose=false

% Band pass filter specification
difference=true
fasl=0.05
fapl=0.1
fapu=0.2
fasu=0.25
dBap=0.2
Wap=20
dBas=37
Watl=1e-3
Watu=1e-3
Wasl=50000
Wasu=5000
ftpl=0.11
ftpu=0.19
tp=16
tpr=0.2
Wtp=2
fppl=0.11
fppu=0.19
pp=3.5   % Initial phase offset in multiples of pi radians
ppr=0.04 % Peak-to-peak phase ripple in multiples of pi radians
Wpp=10
fdpl=fapl % Pass band dAsqdw response lower edge
fdpu=fapu % Pass band dAsqdw response upper edge
dp=0      % Pass band dAsqdw response nominal value
dpr=0.4 % 0.8   % Pass band dAsqdw response ripple
Wdp=0.001 % Pass band dAsqdw response weight

% Initial coefficients
schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A1k_coef;
schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A1epsilon_coef;
schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A1p_coef;
A1k0=A1k;
A1epsilon0=A1epsilon;
A1p0=A1p;
A1p_ones = ones(size(A1p0));
print_polynomial(A1k0,"A1k0");
printf("A1epsilon0=[ ");printf("%d ",A1epsilon0);printf("]';\n");
clear A1k A1epsilon A1p;

schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A2k_coef;
schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A2epsilon_coef;
schurOneMPAlattice_socp_slb_bandpass_hilbert_test_A2p_coef;
A2k0=A2k;
A2epsilon0=A2epsilon;
A2p0=A2p;
A2p_ones = ones(size(A2p0));
print_polynomial(A2k0,"A2k0");
printf("A2epsilon0=[ ");printf("%d ",A2epsilon0);printf("]';\n");
clear A2k A2epsilon A2p;

% Initialise coefficient range vectors
NA1k=length(A1k0);
NA2k=length(A2k0);
R1=1:NA1k;
R2=(NA1k+1):(NA1k+NA2k);

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
Td=tp*ones(ntpu-ntpl+1,1);
Tdu=(tp+(tpr/2))*ones(ntpu-ntpl+1,1);
Tdl=(tp-(tpr/2))*ones(ntpu-ntpl+1,1);
Wt=Wtp*ones(ntpu-ntpl+1,1);

% Phase constraints
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=wa(nppl:nppu);
Pd=(pp*pi)-(tp*wp);
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(nppu-nppl+1,1);

% Desired pass-band dAsqdw response
ndpl=floor(n*fdpl/0.5)+1;
ndpu=ceil(n*fdpu/0.5)+1;
wd=wa(ndpl:ndpu);
Dd=dp*ones(length(wd),1);
Ddu=Dd+(dpr/2);
Ddl=Dd-(dpr/2);
Wd=Wdp*ones(length(wd),1);

% Linear constraints
dmax=inf;
rho=0.999
k0=[A1k0(:);A2k0(:)];
k0_active=find(k0~=0);
k0_u=rho*ones(size(k0));
k0_l=-k0_u;

% Exact error
Esq0=schurOneMPAlatticeEsq(A1k0,A1epsilon0,A1p_ones, ...
                           A2k0,A2epsilon0,A2p_ones, ...
                           difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Allocate signed-digits to the coefficients
nbits=10
nscale=2^(nbits-1);
ndigits=3
ndigits_alloc=zeros(size(k0));
ndigits_alloc(k0_active)=ndigits;
k0_allocsd_digits=int16(ndigits_alloc);
printf("k0_allocsd_digits=[ ");printf("%2d ",k0_allocsd_digits);printf("]';\n");

% Find the signed-digit approximations to A1k0 and A2k0
[k0_sd,k0_sdu,k0_sdl]=flt2SD(k0,nbits,ndigits_alloc);
[k0_sd_digits,k0_sd_adders]=SDadders(k0_sd,nbits);
A1k0_sd=k0_sd(R1);A2k0_sd=k0_sd(R2);
Esq0_sd=schurOneMPAlatticeEsq(A1k0_sd,A1epsilon0,A1p_ones, ...
                              A2k0_sd,A2epsilon0,A2p_ones, ...
                              difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
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
  % Esq_min=0.00343751
  branches_min=406;
  A1k_min = [     -216,      432,     -168,       52, ... 
                   352,     -216,       88,      242, ... 
                  -196,      123 ]'/512;
  A2k_min = [     -400,      446,     -176,       25, ... 
                   352,     -200,       98,      240, ... 
                  -193,      130 ]'/512;
  k_min=[A1k_min(:);A2k_min(:)];
  Esq_min=schurOneMPAlatticeEsq(A1k_min,A1epsilon0,A1p_ones, ...
                                A2k_min,A2epsilon0,A2p_ones, ...
                                difference, ...
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
                       difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
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
                               wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd, ...
                               maxiter,tol,ctol,verbose);
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
             difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
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
             difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      printf("At maximum depth Esq=%g\n",Esq);  
      % Check constraints
      if enforce_pcls_constraints_on_final_filter
        Asq=schurOneMPAlatticeAsq(wa,k_b(R1),A1epsilon0,A1p_ones, ...
                                  k_b(R2),A2epsilon0,A2p_ones,difference);
        T=schurOneMPAlatticeT(wt,k_b(R1),A1epsilon0,A1p_ones, ...
                              k_b(R2),A2epsilon0,A2p_ones,difference);
        P=schurOneMPAlatticeP(wp,k_b(R1),A1epsilon0,A1p_ones, ...
                              k_b(R2),A2epsilon0,A2p_ones,difference);
        D=schurOneMPAlatticedAsqdw(wd,k_b(R1),A1epsilon0,A1p_ones, ...
                                   k_b(R2),A2epsilon0,A2p_ones,difference);
        vS=schurOneMPAlattice_slb_update_constraints ...
             (Asq,Asqdu,Asqdl,Wa,T,Tdu,Tdl,Wt,P,Pdu,Pdl,Wp,D,Ddu,Ddl,Wd,ctol);
        if ~schurOneMPAlattice_slb_constraints_are_empty(vS)
          printf("At maximum depth constraints are not empty!\n");
          schurOneMPAlattice_slb_show_constraints(vS,wa,Asq,wt,T,wp,P,wd,D);
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
  error("Did not find an improved solution!\n");
endif
A1k_min=k_min(R1);
A1epsilon_min=schurOneMscale(A1k_min);
A2k_min=k_min(R2);
A2epsilon_min=schurOneMscale(A2k_min);
Esq_min=schurOneMPAlatticeEsq(A1k_min,A1epsilon_min,A1p_ones, ...
                              A2k_min,A2epsilon_min,A2p_ones, ...
                              difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
printf("\nBest new solution:\nEsq_min=%g\n",Esq_min);
print_polynomial(A1k_min,"A1k_min",nscale);
print_polynomial(A1k_min,"A1k_min",strcat(strf,"_A1k_min_coef.m"),nscale);
printf("A1epsilon_min=[ ");printf("%d ",A1epsilon_min);printf("]';\n");
print_polynomial(A2k_min,"A2k_min",nscale);
print_polynomial(A2k_min,"A2k_min",strcat(strf,"_A2k_min_coef.m"),nscale);
printf("A2epsilon_min=[ ");printf("%d ",A2epsilon_min);printf("]';\n");
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

%
% Make a LaTeX table for cost
%
fid=fopen(strcat(strf,"_kmin_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit& %8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,k0_sd_digits,k0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP b-and-b) & %8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,kmin_digits,kmin_adders);
fclose(fid);

%
% Calculate response
%

% Squared-amplitude
Asq_k0=schurOneMPAlatticeAsq(wa,A1k0,A1epsilon0,A1p0, ...
                             A2k0,A2epsilon0,A2p0,difference);
Asq_k0_sd=schurOneMPAlatticeAsq(wa,A1k0_sd,A1epsilon0,A1p_ones, ...
                                A2k0_sd,A2epsilon0,A2p_ones,difference);
Asq_kmin=schurOneMPAlatticeAsq(wa,A1k_min,A1epsilon_min,A1p_ones, ...
                               A2k_min,A2epsilon_min,A2p_ones,difference);

% Group-delay
T_k0=schurOneMPAlatticeT(wt,A1k0,A1epsilon0,A1p0, ...
                         A2k0,A2epsilon0,A2p0,difference);
T_k0_sd=schurOneMPAlatticeT(wt,A1k0_sd,A1epsilon0,A1p_ones, ...
                            A2k0_sd,A2epsilon0,A2p_ones,difference);
T_kmin=schurOneMPAlatticeT(wt,A1k_min,A1epsilon_min,A1p_ones, ...
                           A2k_min,A2epsilon_min,A2p_ones,difference);

% Phase
P_k0=schurOneMPAlatticeP(wp,A1k0,A1epsilon0,A1p0, ...
                         A2k0,A2epsilon0,A2p0,difference);
P_k0_sd=schurOneMPAlatticeP(wp,A1k0_sd,A1epsilon0,A1p_ones, ...
                            A2k0_sd,A2epsilon0,A2p_ones,difference);
P_kmin=schurOneMPAlatticeP(wp,A1k_min,A1epsilon_min,A1p_ones, ...
                           A2k_min,A2epsilon_min,A2p_ones,difference);

% dAsqdw
D_k0=schurOneMPAlatticedAsqdw(wd,A1k0,A1epsilon0,A1p0, ...
                              A2k0,A2epsilon0,A2p0,difference);
D_k0_sd=schurOneMPAlatticedAsqdw(wd,A1k0_sd,A1epsilon0,A1p_ones, ...
                                 A2k0_sd,A2epsilon0,A2p_ones,difference);
D_kmin=schurOneMPAlatticedAsqdw(wd,A1k_min,A1epsilon_min,A1p_ones, ...
                                A2k_min,A2epsilon_min,A2p_ones,difference);

%
% Optimised response at local peaks
%

% Squared amplitude
vAl=local_max(Asqdl-Asq_kmin);
vAu=local_max(Asq_kmin-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,end])]);
AsqS=schurOneMPAlatticeAsq(wAsqS,A1k_min,A1epsilon_min,A1p_ones, ...
                           A2k_min,A2epsilon_min,A2p_ones,difference);
printf("kmin:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kmin:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");

% Delay
vTl=local_max(Tdl-T_kmin);
vTu=local_max(T_kmin-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
TS=schurOneMPAlatticeT(wTS,A1k_min,A1epsilon_min,A1p_ones, ...
                       A2k_min,A2epsilon_min,A2p_ones,difference);
printf("kmin:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kmin:TS=[ ");printf("%f ",TS');printf("] (Samples)\n");

% Phase
vPl=local_max(Pdl-P_kmin);
vPu=local_max(P_kmin-Pdu);
wPS=sort(unique([wp(vPl);wp(vPu);wp([1,end])]));
PS=schurOneMPAlatticeP(wPS,A1k_min,A1epsilon_min,A1p_ones, ...
                       A2k_min,A2epsilon_min,A2p_ones,difference);
PS_on_pi=mod((PS+(wPS*tp))/pi,2);
printf("kmin:fPS=[ ");printf("%f ",wPS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kmin:PS=[ ");printf("%f ",PS_on_pi');printf("] (rad./pi)\n");

% dAsqdw 
vDl=local_max(Ddl-D_kmin);
vDu=local_max(D_kmin-Ddu);
wDS=sort(unique([wd(vDl);wd(vDu);wd([1,end])]));
DS=schurOneMPAlatticedAsqdw(wDS,A1k_min,A1epsilon_min,A1p_ones, ...
                            A2k_min,A2epsilon_min,A2p_ones,difference);
printf("kmin:fDS=[ ");printf("%f ",wDS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kmin:DS=[ ");printf("%f ",DS');printf("]\n")

%
% Plot response
%

% Plot stop-band amplitude
plot(wa*0.5/pi,10*log10(Asq_k0),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_k0_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_kmin),"linestyle","-.");
legend("exact","s-d","s-d(SOCP b-and-b)");
legend("location","northeast");
legend("boxoff");
legend("left");
ylabel("Amplitude(dB)");
xlabel("Frequency");
strt=sprintf("Parallel one-multplier allpass lattice bandpass Hilbert filter \
stop-band(nbits=%d,ndigits=%d) : fasl=%g,fasu=%g",nbits,ndigits,fasl,fasu);
title(strt);
axis([0, 0.5, -50, -30]);
grid("on");
print(strcat(strf,"_kmin_stop"),"-dpdflatex");  
close

% Plot pass-band amplitude
plot(wa*0.5/pi,10*log10(Asq_k0),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_k0_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_kmin),"linestyle","-.");
ylabel("Amplitude(dB)");
xlabel("Frequency");
strt=sprintf("Parallel one-multplier allpass lattice bandpass Hilbert filter \
pass-band(nbits=%d,ndigits=%d) : fapl=%g,fapu=%g",nbits,ndigits,fapl,fapu);
title(strt);
fpmin=min([fapl,ftpl,fppl,fdpl]);
fpmax=max([fapu,ftpu,fppu,fdpu]);
axis([fpmin, fpmax, -0.2, 0.1]);
legend("exact","s-d","s-d(b-and-b)");
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
ylabel("Delay(samples)");
xlabel("Frequency");
strt=sprintf("Parallel one-multplier allpass lattice bandpass Hilbert filter \
pass-band(nbits=%d,ndigits=%d) : ftpl=%g,ftpu=%g",nbits,ndigits,ftpl,ftpu);
title(strt);
axis([fpmin, fpmax, tp-tpr, tp+tpr]);
legend("exact","s-d","s-d(b-and-b)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_kmin_delay"),"-dpdflatex");
close

% Plot pass-band phase
plot(wp*0.5/pi,mod((P_k0+(wp*tp))/pi,2),"linestyle","-", ...
     wp*0.5/pi,mod((P_k0_sd+(wp*tp))/pi,2),"linestyle","--", ...
     wp*0.5/pi,mod((P_kmin+(wp*tp))/pi,2),"linestyle","-.");
ylabel("Phase(rad./$\\pi$)");
xlabel("Frequency");
strt=sprintf("Parallel one-multplier allpass lattice bandpass Hilbert filter \
pass-band(nbits=%d,ndigits=%d) : ftpl=%g,ftpu=%g",nbits,ndigits,ftpl,ftpu);
title(strt);
axis([fpmin, fpmax, mod(pp-(ppr/4),2), mod(pp+(ppr/4),2)]);
legend("exact","s-d","s-d(b-and-b)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_kmin_phase"),"-dpdflatex"); 
close

% Plot pass-band dAsqdw
plot(wd*0.5/pi,D_k0,"linestyle","-", ...
     wd*0.5/pi,D_k0_sd,"linestyle","--", ...
     wd*0.5/pi,D_kmin,"linestyle","-.");
ylabel("$\\frac{dAsq}{d\\omega}$");
xlabel("Frequency");
strt=sprintf("Parallel one-multplier allpass lattice bandpass Hilbert filter \
pass-band(nbits=%d,ndigits=%d) : fdpl=%g,fdpu=%g",nbits,ndigits,fdpl,fdpu);
title(strt);
axis([fpmin,fpmax,(dp+([-dpr,dpr]/2))]);
legend("exact","s-d","s-d(b-and-b)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_kmin_dAsqdw"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"use_best_branch_and_bound_found=%d\n", ...
        use_best_branch_and_bound_found);
fprintf(fid,"enforce_pcls_constraints_on_final_filter=%d\n", ...
        enforce_pcls_constraints_on_final_filter);
fprintf(fid,"nbits=%d %% Coefficient word length\n",nbits);
fprintf(fid,"ndigits=%d %% Average number of signed digits per coef.\n", ...
        ndigits);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n", ...
        difference);
fprintf(fid,"NA1k=%d %% Allpass model filter 1 denominator order\n",NA1k);
fprintf(fid,"NA2k=%d %% Allpass model filter 2 denominator order\n",NA2k);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fapl=%g %% Pass band amplitude response lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Pass band amplitude response upper edge\n",fapu);
fprintf(fid,"dBap=%f %% Pass band amplitude response ripple(dB)\n",dBap);
fprintf(fid,"Wap=%d %% Pass band amplitude response weight\n",Wap);
fprintf(fid,"Watl=%d %% Lower transition band amplitude response weight\n", ...
        Watl);
fprintf(fid,"Watu=%d %% Upper transition band amplitude response weight\n", ...
        Watu);
fprintf(fid,"fasl=%g %% Stop band amplitude response lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Stop band amplitude response upper edge\n",fasu);
fprintf(fid,"dBas=%f %% Stop band amplitude response ripple(dB)\n",dBas);
fprintf(fid,"Wasl=%d %% Lower stop band amplitude response weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Upper stop band amplitude response weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Pass band group-delay response lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band group-delay response upper edge\n",ftpu);
fprintf(fid,"tp=%f %% Pass band nominal group-delay response(samples)\n",tp);
fprintf(fid,"tpr=%f %% Pass band group-delay response ripple(samples)\n",tpr);
fprintf(fid,"Wtp=%d %% Pass band group-delay response weight\n",Wtp);
fprintf(fid,"fppl=%g %% Pass band phase response lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Pass band phase response upper edge\n",fppu);
fprintf(fid,"pp=%f %% Pass band nominal phase response(rad./pi)\n",pp);
fprintf(fid,"ppr=%f %% Pass band phase response ripple(rad./pi)\n",ppr);
fprintf(fid,"Wpp=%d %% Pass band phase response weight\n",Wpp);
fprintf(fid,"fdpl=%g %% Pass band dAsqdw response lower edge\n",fdpl);
fprintf(fid,"fdpu=%g %% Pass band dAsqdw response upper edge\n",fdpu);
fprintf(fid,"dp=%f %% Pass band nominal dAsqdw response\n",dp);
fprintf(fid,"dpr=%f %% Pass band dAsqdw response ripple\n",dpr);
fprintf(fid,"Wdp=%d %% Pass band dAsqdw response weight\n",Wpp);
fclose(fid);

% Save results
eval(sprintf("save %s.mat ...\n\
     use_best_branch_and_bound_found ...\n\
     enforce_pcls_constraints_on_final_filter ...\n\
     n NA1k NA2k difference tol ctol rho  ...\n\
     fapl fapu dBap Wap Watl Watu ...\n\
     fasl fasu dBas Wasl Wasu ...\n\
     ftpl ftpu tp tpr Wtp ...\n\
     fppl fppu pp ppr Wpp ...\n\
     fdpl fdpu dp dpr Wdp ...\n\
     A1k0 A1epsilon0 A1p0 A2k0 A2epsilon0 A2p0 ...\n\
     A1k_min A1epsilon_min A2k_min A2epsilon_min",strf))

% Done
toc;
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));
