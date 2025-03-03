% branch_bound_schurNSPAlattice_lowpass_12_nbits_test.m
% Copyright (C) 2023-2025 Robert G. Jenssen
% Branch-and-bound optimisation of the response of a low-pass filter
% composed of parallel Schur approximately normalised-scaled all-pass
% lattice filters with 12-bit 3-signed-digit coefficients.

test_common;

strf="branch_bound_schurNSPAlattice_lowpass_12_nbits_test";

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

maxiter=500
verbose=false
sxx_symmetric=true;

%
% Initial coefficients from schurNSPAlattice_socp_slb_lowpass_test.m
%
schurNSPAlattice_socp_slb_lowpass_test_A1s20_coef;
schurNSPAlattice_socp_slb_lowpass_test_A1s00_coef;
schurNSPAlattice_socp_slb_lowpass_test_A2s20_coef;
schurNSPAlattice_socp_slb_lowpass_test_A2s00_coef;

% Low pass filter specification
nbits=12
ndigits=3
tol=1e-3
ctol=1e-6
n=400
difference=false % Use sum of all-pass outputs
dmax=inf;
rho=0.999
fap=0.125 % Pass band amplitude response edge
dBap=0.6 % Pass band amplitude response ripple
Wap=1 % Pass band amplitude response weight
Wat=0 % Transition band amplitude response weight
fas=0.25 % Stop band amplitude response edge
dBas=45 % Stop band amplitude response ripple
Was=1000 % Stop band amplitude response weight
ftp=0.175 % Pass band group delay response edge
tp=(length(A1s20)+length(A2s20))/2 % Pass band nominal group delay
tpr=0.1 % Pass band group delay response ripple
Wtp=1 % Pass band group delay response weight

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=[ones(nap,1); zeros(n-nap,1)];
Asqdu=[ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1); zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];
P=[];

% Initialise coefficient range vectors
NA1=length(A1s20);
NA2=length(A2s20);
RA1s20=1:NA1;
RA1s00=RA1s20+NA1;
RA2s20=(4*NA1)+(1:NA2);
RA2s00=RA2s20+NA2;

% Linear constraints
A1s20_0=A1s20(:);A1s00_0=A1s00(:);A2s20_0=A2s20(:);A2s00_0=A2s00(:);
sxx_0=[A1s20_0;A1s00_0;-A1s20_0;A1s00_0;A2s20_0;A2s00_0;-A2s20_0;A2s00_0;];
sxx_active=intersect(find(sxx_0~=0),[RA1s20,RA1s00,RA2s20,RA2s00]');
n_active=length(sxx_active);
sxx_u=rho*ones(size(sxx_0));
sxx_l=-sxx_u;

% Exact error
Esq0=schurNSPAlatticeEsq(A1s20_0,A1s00_0,-A1s20_0,A1s00_0, ...
                         A2s20_0,A2s00_0,-A2s20_0,A2s00_0, ...
                         difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Find the signed-digit approximations to A1s20 etc.
nscale=2^(nbits-1);
ndigits_alloc=ndigits*ones(size(sxx_0));
sxx_allocsd_digits=int16(ndigits_alloc);
sxx_sd=flt2SD(sxx_0,nbits,ndigits_alloc);
[sxx_sd_digits,sxx_sd_adders]=SDadders(sxx_sd,nbits);
A1s20_sd=sxx_sd(RA1s20);
A1s00_sd=sxx_sd(RA1s00);
A2s20_sd=sxx_sd(RA2s20);
A2s00_sd=sxx_sd(RA2s00);

Esq_sd=schurNSPAlatticeEsq(A1s20_sd,A1s00_sd,-A1s20_sd,A1s00_sd, ...
                           A2s20_sd,A2s00_sd,-A2s20_sd,A2s00_sd, ...
                           difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

print_polynomial(A1s20_sd,"A1s20_sd",strcat(strf,"_A1s20_sd_coef.m"),nscale);
print_polynomial(A1s00_sd,"A1s00_sd",strcat(strf,"_A1s00_sd_coef.m"),nscale);
print_polynomial(A2s20_sd,"A2s20_sd",strcat(strf,"_A2s20_sd_coef.m"),nscale);
print_polynomial(A2s00_sd,"A2s00_sd",strcat(strf,"_A2s00_sd_coef.m"),nscale);

%
% Loop finding truncated coefficients
%

% Define stack of current filter coefficients and tree depth
sxx_stack=cell(1,n_active);
sxx_depth=0;
branch_tree=true;
n_branch=0;

% Initialise the search sxx_min
improved_solution_found=false;
sxx_b=zeros(size(sxx_0));
sxx_b(sxx_active)=sxx_0(sxx_active);
sxx_min=sxx_sd;
Esq_min=Esq_sd;
printf("Initial Esq_min=%g\n",Esq_min);
printf("Initial sxx_active=[ ");printf("%d ",sxx_active);printf("];\n");

% Fix one coefficient at each iteration 
if use_best_branch_and_bound_found
  branches_min = 290
  A1s20_min = [     1600,     -127,     -560,     -208, ... 
                    -226,      464,     -262,       49, ... 
                     368,     -336,       96 ]'/2048;
  A1s00_min = [     1272,     2042,     1968,     2042, ... 
                    2043,     1986,     2036,     2045, ... 
                    2018,     2020,     2045 ]'/2048;
  A2s20_min = [      752,     -608,      444,      440, ... 
                     -41,       98,     -416,      382, ... 
                      18,     -386,      296,     -116 ]'/2048;
  A2s00_min = [     1904,     1968,     1980,     2000, ... 
                    2046,     2046,     2028,     2000, ... 
                    2033,     2028,     2028,     2043 ]'/2048;
  sxx_min=[A1s20_min;A1s00_min;-A1s20_min;A1s00_min; ...
           A2s20_min;A2s00_min;-A2s20_min;A2s00_min];
  Esq_min=schurNSPAlatticeEsq(A1s20_min,A1s00_min,-A1s20_min,A1s00_min, ...
                              A2s20_min,A2s00_min,-A2s20_min,A2s00_min, ...
                              difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
  improved_solution_found=true;
else
  % At each node of a branch, define two sub-problems, one of which is
  % stacked and one of which is solved immediately. If the solved problem
  % reduces Esq_min, then continue to the next node on that branch. If the
  % solved problem does not improve Esq_min then give up on this branch and
  % continue by solving the problem on top of the stack.
  do

    % Choose the sub-problem to solve
    if branch_tree  
      n_branch=n_branch+1;
      [sxx_sd,sxx_sdu,sxx_sdl]=flt2SD(sxx_b,nbits,ndigits_alloc);
      % Ito et al. suggest ordering the tree branches by max(sxx_sdu-sxx_sdl)
      sxx_sdul=sxx_sdu-sxx_sdl;
      if any(sxx_sdul<0)
        error("any(sxx_sdul<0)");
      endif
      [sxx_max,sxx_max_n]=max(sxx_sdul(sxx_active));
      coef_n=sxx_active(sxx_max_n);
      sxx_active(sxx_max_n)=[];  
      sxx_b(coef_n)=sxx_sdl(coef_n); 
      % Push a problem onto the stack
      sxx_depth=sxx_depth+1;
      if sxx_depth>n_active
        error("sxx_depth(%d)>n_active(%d)",sxx_depth,n_active);
      endif
      printf("\nBranch %d:coef_n=%d,",n_branch,coef_n);
      sxx_problem.sxx_b=sxx_b;
      sxx_problem.sxx_active=sxx_active;
      sxx_stack{sxx_depth}=sxx_problem;
      % Set up current problem
      sxx_b(coef_n)=sxx_sdu(coef_n);
    else
      % Pop a problem off the stack 
      if sxx_depth<=0
        error("sxx_depth(%d)<=0",sxx_depth);
      endif
      sxx_problem=sxx_stack{sxx_depth};
      sxx_depth=sxx_depth-1;
      sxx_b=sxx_problem.sxx_b;
      sxx_active=sxx_problem.sxx_active;
      printf("\nBacktrack:");
    endif
    printf("sxx_depth=%d\n",sxx_depth);
    printf("sxx_active=[ ");printf("%d ",sxx_active);printf("];\n");
    printf("sxx_b=[ ");printf("%g ",nscale*sxx_b');printf("]'/%d;\n",nscale);

    % Try to solve the current sub-problem
    try  
      % Find the SOCP PCLS solution for the remaining active coefficients
      [nextA1s20,nextA1s00,nextA1s02,nextA1s22, ...
       nextA2s20,nextA2s00,nextA2s02,nextA2s22, ...
       slb_iter,opt_iter,func_iter,feasible] = ...
           schurNSPAlattice_slb ...
             (@schurNSPAlattice_socp_mmse, ...
              sxx_b(RA1s20),sxx_b(RA1s00),-sxx_b(RA1s20),sxx_b(RA1s00), ...
              sxx_b(RA2s20),sxx_b(RA2s00),-sxx_b(RA2s20),sxx_b(RA2s00), ...
              difference,sxx_u,sxx_l,sxx_active,sxx_symmetric,dmax, ...
              wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
              wp,Pd,Pdu,Pdl,Wp,maxiter,tol,ctol,verbose);
      printf("nextA1s20=[ ");printf("%g ",nextA1s20');printf("]';\n");
      printf("nextA1s00=[ ");printf("%g ",nextA1s00');printf("]';\n");
      printf("nextA2s20=[ ");printf("%g ",nextA2s20');printf("]';\n");
      printf("nextA2s00=[ ");printf("%g ",nextA2s00');printf("]';\n");
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
    if feasible && ~isempty(sxx_active)
      % Update sxx_b
      next_sxx=[nextA1s20(:);nextA1s00(:);-nextA1s20(:);nextA1s00(:); ...
                nextA2s20(:);nextA2s00(:);-nextA2s20(:);nextA2s00(:)];
      sxx_b(sxx_active)=next_sxx(sxx_active);
      % Check bound on Esq 
      Esq=schurNSPAlatticeEsq ...
            (sxx_b(RA1s20),sxx_b(RA1s00),-sxx_b(RA1s20),sxx_b(RA1s00), ...
             sxx_b(RA2s20),sxx_b(RA2s00),-sxx_b(RA2s20),sxx_b(RA2s00), ...
             difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      printf("Found Esq=%g\n",Esq); 
      if Esq<Esq_min
        branch_tree=true;
      else
        branch_tree=false;
      endif
    endif
    
    % At maximum depth there are no active coefficients
    if feasible && isempty(sxx_active)
      % Update Esq_min
      branch_tree=false;
      Esq=schurNSPAlatticeEsq ...
            (sxx_b(RA1s20),sxx_b(RA1s00),-sxx_b(RA1s20),sxx_b(RA1s00), ...
             sxx_b(RA2s20),sxx_b(RA2s00),-sxx_b(RA2s20),sxx_b(RA2s00), ...
             difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      printf("At maximum depth Esq=%g\n",Esq);  
      % Check constraints
      if enforce_pcls_constraints_on_final_filter
        Asq=schurNSPAlatticeAsq ...
              (wa, ...
               sxx_b(RA1s20),sxx_b(RA1s00),-sxx_b(RA1s20),sxx_b(RA1s00), ...
               sxx_b(RA2s20),sxx_b(RA2s00),-sxx_b(RA2s20),sxx_b(RA2s00), ...
               difference);
        T=schurNSPAlatticeT ...
            (wt, ...
             sxx_b(RA1s20),sxx_b(RA1s00),-sxx_b(RA1s20),sxx_b(RA1s00), ...
             sxx_b(RA2s20),sxx_b(RA2s00),-sxx_b(RA2s20),sxx_b(RA2s00), ...
             difference);
        vS=schurNSPAlattice_slb_update_constraints ...
             (Asq,Asqdu,Asqdl,Wa,T,Tdu,Tdl,Wt,wp,Pdu,Pdl,Wp,ctol);
        if ~schurNSPAlattice_slb_constraints_are_empty(vS)
          printf("At maximum depth constraints are not empty!\n");
          schurNSPAlattice_slb_show_constraints(vS,wa,Asq,wt,T);
        endif
      else
        vS=schurNSPAlattice_slb_set_empty_constraints();
      endif
      % Update the best solution
      if Esq<Esq_min && schurNSPAlattice_slb_constraints_are_empty(vS)
        improved_solution_found=true;
        Esq_min=Esq;
        sxx_min=[sxx_b(RA1s20);sxx_b(RA1s00);-sxx_b(RA1s20);sxx_b(RA1s00); ...
                 sxx_b(RA2s20);sxx_b(RA2s00);-sxx_b(RA2s20);sxx_b(RA2s00)];
        branches_min=n_branch;
        printf("Improved solution: sxx_depth=%d,Esq_min=%g\n",sxx_depth,Esq_min);
        print_polynomial(sxx_min(RA1s20),"A1s20_min",nscale);
        print_polynomial(sxx_min(RA1s00),"A1s00_min",nscale);
        print_polynomial(sxx_min(RA2s20),"A2s20_min",nscale);
        print_polynomial(sxx_min(RA2s00),"A2s00_min",nscale);
      endif
    endif

  % Exit the loop when there are no sub-problems left
  until (isempty(sxx_active)||(branch_tree==false)) && (sxx_depth==0)
  printf("Branch-and-bound search completed with %d branches\n",n_branch);
endif
  
% Show results
if ~improved_solution_found
  error("Did not find an improved solution!\n");
endif
A1s20_min=sxx_min(RA1s20);
A1s00_min=sxx_min(RA1s00);
A2s20_min=sxx_min(RA2s20);
A2s00_min=sxx_min(RA2s00);
Esq_min=schurNSPAlatticeEsq(A1s20_min,A1s00_min,-A1s20_min,A1s00_min, ...
                            A2s20_min,A2s00_min,-A2s20_min,A2s00_min, ...
                            difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
printf("\nBest new solution:\nEsq_min=%g\n",Esq_min);
print_polynomial(A1s20_min,"A1s20_min",nscale);
print_polynomial(A1s20_min,"A1s20_min",strcat(strf,"_A1s20_min_coef.m"),nscale);
print_polynomial(A1s00_min,"A1s00_min",nscale);
print_polynomial(A1s00_min,"A1s00_min",strcat(strf,"_A1s00_min_coef.m"),nscale);
print_polynomial(A2s20_min,"A2s20_min",nscale);
print_polynomial(A2s20_min,"A2s20_min",strcat(strf,"_A2s20_min_coef.m"),nscale);
print_polynomial(A2s00_min,"A2s00_min",nscale);
print_polynomial(A2s00_min,"A2s00_min",strcat(strf,"_A2s00_min_coef.m"),nscale);

% Find the number of signed-digits and adders used
[sxx_min_digits,sxx_min_adders]=SDadders(sxx_min,nbits);
printf("%d signed-digits used\n",sxx_min_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       sxx_min_adders,nbits);
fid=fopen(strcat(strf,"_sxx_min_digits.tab"),"wt");
fprintf(fid,"$%d$",sxx_min_digits);
fclose(fid);
fid=fopen(strcat(strf,"_sxx_min_adders.tab"),"wt");
fprintf(fid,"$%d$",sxx_min_adders);
fclose(fid);

% Amplitude,delay and phase at local peaks
Asq=schurNSPAlatticeAsq ...
      (wa, ...
       A1s20_min,A1s00_min,-A1s20_min,A1s00_min, ...
       A2s20_min,A2s00_min,-A2s20_min,A2s00_min, ...
       difference);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,end])]);
AsqS=schurNSPAlatticeAsq ...
       (wAsqS, ...
        A1s20_min,A1s00_min,-A1s20_min,A1s00_min, ...
        A2s20_min,A2s00_min,-A2s20_min,A2s00_min, ...
        difference);
printf("sxx_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("sxx_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurNSPAlatticeT ...
    (wt, ...
     A1s20_min,A1s00_min,-A1s20_min,A1s00_min, ...
     A2s20_min,A2s00_min,-A2s20_min,A2s00_min, ...
     difference);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
TS=schurNSPAlatticeT ...
     (wTS, ...
      A1s20_min,A1s00_min,-A1s20_min,A1s00_min, ...
      A2s20_min,A2s00_min,-A2s20_min,A2s00_min, ...
      difference);
printf("sxx_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("sxx_min:TS=[ ");printf("%f ",TS');printf("] (Samples)\n")

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_sxx_min_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit& %8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq_sd,sxx_sd_digits,sxx_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP b-and-b) & %8.6f & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,sxx_min_digits,sxx_min_adders);
fclose(fid);

%
% Plot response
%

% Find squared-magnitude and group-delay
Asq_sxx_0=schurNSPAlatticeAsq ...
            (wa, ...
             A1s20_0,A1s00_0,-A1s20_0,A1s00_0, ...
             A2s20_0,A2s00_0,-A2s20_0,A2s00_0, ...
             difference);
Asq_sxx_sd=schurNSPAlatticeAsq ...
             (wa, ...
              A1s20_sd,A1s00_sd,-A1s20_sd,A1s00_sd, ...
              A2s20_sd,A2s00_sd,-A2s20_sd,A2s00_sd, ...
              difference);
Asq_sxx_min=schurNSPAlatticeAsq ...
              (wa, ...
               A1s20_min,A1s00_min,-A1s20_min,A1s00_min, ...
               A2s20_min,A2s00_min,-A2s20_min,A2s00_min, ...
               difference);
T_sxx_0=schurNSPAlatticeT ...
          (wt, ...
           A1s20_0,A1s00_0,-A1s20_0,A1s00_0, ...
           A2s20_0,A2s00_0,-A2s20_0,A2s00_0, ...
           difference);
T_sxx_sd=schurNSPAlatticeT ...
           (wt, ...
            A1s20_sd,A1s00_sd,-A1s20_sd,A1s00_sd, ...
            A2s20_sd,A2s00_sd,-A2s20_sd,A2s00_sd, ...
            difference);
T_sxx_min=schurNSPAlatticeT ...
            (wt, ...
             A1s20_min,A1s00_min,-A1s20_min,A1s00_min, ...
             A2s20_min,A2s00_min,-A2s20_min,A2s00_min, ...
             difference);

% Plot pass band amplitude response
plot(wa*0.5/pi,10*log10(Asq_sxx_0),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_sxx_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_sxx_min),"linestyle","-.")
axis([0 0.25 -0.6 0.1]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
legend("exact","s-d","s-d(b-and-b)");
legend("location","east");
legend("boxoff");
legend("left");
grid("on");
strt=sprintf("Parallel all-pass lowpass: dBap=%g,dBas=%g",dBap,dBas);
title(strt);
print(strcat(strf,"_sxx_min_pass_amplitude"),"-dpdflatex");
close

% Plot stop band amplitude response
plot(wa*0.5/pi,10*log10(Asq_sxx_0),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_sxx_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_sxx_min),"linestyle","-.")
axis([0 0.5 -60 -20]);
ylabel("Amplitude(dB)");
xlabel("Frequency");
legend("exact","s-d","s-d(b-and-b)");
legend("location","west");
legend("boxoff");
legend("left");
grid("on");
strt=sprintf("Parallel all-pass lowpass: dBap=%g,dBas=%g",dBap,dBas);
title(strt);
print(strcat(strf,"_sxx_min_stop_amplitude"),"-dpdflatex");
close

% Plot pass band delay response
plot(wt*0.5/pi,T_sxx_0,"linestyle","-", ...
     wt*0.5/pi,T_sxx_sd,"linestyle","--", ...
     wt*0.5/pi,T_sxx_min,"linestyle","-.");
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.25 tp-0.1 tp+0.1]);
grid("on");
legend("exact","s-d","s-d(b-and-b)");
legend("location","east");
legend("boxoff");
legend("left");
title(strt);
print(strcat(strf,"_sxx_min_pass_delay"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"sxx_symmetric=%d %% Enforce s02=-s20 and s22=s00\n",sxx_symmetric);
fprintf(fid,"nbits=%d %% Coefficient word length\n",nbits);
fprintf(fid,"ndigits=%d %% Average number of signed digits per coef.\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n",difference);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wat=%d %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%d %% amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fclose(fid);

% Save results
save branch_bound_schurNSPAlattice_lowpass_12_nbits_test.mat ...
     sxx_symmetric use_best_branch_and_bound_found ...
     n fap dBap Wap Wat fas dBas Was ftp tp tpr Wtp rho tol ctol ...
     difference nbits ndigits ndigits_alloc ...
     improved_solution_found ...
     A1s20_0 A1s00_0 A2s20_0 A2s00_0 ...
     A1s20_sd A1s00_sd A2s20_sd A2s00_sd  ...
     A1s20_min A1s00_min A2s20_min A2s00_min 
     
% Done
toc;
diary off
eval(sprintf("movefile %s.diary.tmp %s.diary",strf,strf));
