% branch_bound_schurOneMPAlattice_lowpass_12_nbits_test.m

% Branch-and-bound optimisation of the response of a low-pass filter
% composed of parallel Schur one-multiplier all-pass lattice filters
% with 12-bit 3-signed-digit coefficients.

% Copyright (C) 2017-2023 Robert G. Jenssen

test_common;

delete("branch_bound_schurOneMPAlattice_lowpass_12_nbits_test.diary");
delete("branch_bound_schurOneMPAlattice_lowpass_12_nbits_test.diary.tmp");
diary branch_bound_schurOneMPAlattice_lowpass_12_nbits_test.diary.tmp

% Options
use_best_branch_and_bound_found=true
if use_best_branch_and_bound_found
  warning("Reporting the best branch-and-bound filter found so far. \n\
           Set \"use_best_branch_and_bound_found\"=false to re-run.");
endif
enforce_pcls_constraints_on_final_filter=true
branch_bound_schurOneMPAlattice_lowpass_12_nbits_test_allocsd_Lim=false
branch_bound_schurOneMPAlattice_lowpass_12_nbits_test_allocsd_Ito=true

tic;

tol=1e-4
ctol=5e-7
maxiter=500
verbose=false

% Common strings
strf="branch_bound_schurOneMPAlattice_lowpass_12_nbits_test";

% Initial coefficients found by schurOneMPAlattice_socp_slb_lowpass_test.m
schurOneMPAlattice_socp_slb_lowpass_test_A1k_coef;
schurOneMPAlattice_socp_slb_lowpass_test_A1p_coef;
schurOneMPAlattice_socp_slb_lowpass_test_A1epsilon_coef;
schurOneMPAlattice_socp_slb_lowpass_test_A2k_coef;
schurOneMPAlattice_socp_slb_lowpass_test_A2epsilon_coef;
schurOneMPAlattice_socp_slb_lowpass_test_A2p_coef;

A1k0=A1k;
A1p0=A1p;
A1p_ones=ones(size(A1k0));
A1epsilon0=A1epsilon;
A2k0=A2k;
A2epsilon0=A2epsilon;
A2p0=A2p;
A2p_ones=ones(size(A2k0));

% Initialise coefficient range vectors
NA1=length(A1k0);
NA2=length(A2k0);
R1=1:NA1;
R2=(NA1+1):(NA1+NA2);

% Low pass filter specification
n=400
difference=false % Use sum of all-pass outputs
m1=11 % Allpass model filter 1 denominator order
m2=12 % Allpass model filter 2 denominator order
fap=0.125 % Pass band amplitude response edge
dBap=0.2 % Pass band amplitude response ripple
Wap=1 % Pass band amplitude response weight
Wat=0 % Transition band amplitude response weight
fas=0.25 % Stop band amplitude response edge
dBas=56 % Stop band amplitude response ripple
Was=1e4 % Stop band amplitude response weight
ftp=0.175 % Pass band group delay response edge
td=(m1+m2)/2 % Pass band nominal group delay
tdr=0.08 % Pass band group delay response ripple
Wtp=0.1 % Pass band group delay response weight

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
Td=td*ones(ntp,1);
Tdu=(td+(tdr/2))*ones(ntp,1);
Tdl=(td-(tdr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];
P=[];

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
                           difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

% Allocate signed-digits to the coefficients
nbits=12
nscale=2^(nbits-1);
ndigits=3
if branch_bound_schurOneMPAlattice_lowpass_12_nbits_test_allocsd_Lim
  ndigits_alloc=schurOneMPAlattice_allocsd_Lim ...
                  (nbits,ndigits,A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                   difference,wa,Asqd,ones(size(Wa)), ...
                   wt,Td,ones(size(Wt)),wp,Pd,ones(size(Wp)));
elseif branch_bound_schurOneMPAlattice_lowpass_12_nbits_test_allocsd_Ito
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
  if 1
    % Esq_min=0.000151086
    branches_min = 1459
    A1k_min = [     1584,     -176,     -540,     -128, ... 
                    -128,      484,     -296,        2, ... 
                     336,     -321,      112 ]'/2048;
    A2k_min = [      784,     -580,      384,      336, ... 
                     -96,       84,     -402,      368, ... 
                       5,     -360,      304,     -114 ]'/2048;
  else
    % Earlier results with a different initial filter
    if 0
    branches_min=819; 
    A1k_min = [    1592,     -168,     -536,     -128, ... 
                   -129,      480,     -281,       -8, ... 
                    352,     -328,      119 ]'/2048;
    A2k_min = [     800,     -584,      384,      336, ...
                    -96,       84,     -400,      352, ... 
                     16,     -376,      312,     -123 ]'/2048;

    elseif 0
      branches_min=416;
      A1k_min = [  1592,     -168,     -536,     -128, ... 
                   -132,      480,     -296,       -4, ... 
                    352,     -336,      121 ]'/2048;
      A2k_min = [   800,     -580,      384,      336, ... 
                    -96,       88,     -400,      368, ... 
                     10,     -376,      320,     -124 ]'/2048;
    elseif 0
      branches_min=545;
      A1k_min = [  1584,     -184,     -544,     -128, ... 
                   -128,      488,     -296,        1, ... 
                    336,     -316,      112 ]'/2048;
      A2k_min = [   784,     -584,      384,      336, ... 
                    -96,       88,     -404,      368, ... 
                      4,     -360,      300,     -113 ]'/2048;
    endif
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
legend("exact","s-d(Ito)","s-d(SOCP b-and-b)");
legend("location","northwest");
legend("boxoff");
legend("left");
ylabel("Amplitude(dB)");
xlabel("Frequency");
strt=sprintf("Parallel one-multplier allpass lattice lowpass filter \
(nbits=12) : fap=%g,fas=%g,dBap=%g,Wap=%g,td=%g,Wtp=%g",
             fap,fas,dBap,Wap,td,Wtp);
title(strt);
axis([fas, 0.5, -70, -20]);
grid("on");
print(strcat(strf,"_kmin_stop"),"-dpdflatex");
close

% Plot pass-band amplitude
plot(wa*0.5/pi,10*log10(Asq_k0),"linestyle","-", ...
     wa*0.5/pi,10*log10(Asq_k0_sd),"linestyle","--", ...
     wa*0.5/pi,10*log10(Asq_kmin),"linestyle","-.");
ylabel("Amplitude(dB)");
xlabel("Frequency");
title(strt);
axis([0, max(fap,ftp), -0.15, 0.05]);
legend("exact","s-d(Ito)","s-d(b-and-b)");
legend("location","northwest");
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
title(strt);
axis([0, max(fap,ftp), td-tdr, td+tdr]);
legend("exact","s-d(Ito)","s-d(b-and-b)");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_kmin_delay"),"-dpdflatex");
close

% Plot responses for the introduction
print_for_web_page=false;
if print_for_web_page
  set(0,"defaultlinelinewidth",1.5);
endif
subplot(311)
[ax,h1,h2]= ...
  plotyy(wa(1:nap)*0.5/pi,10*log10([Asq_k0(1:nap) Asq_kmin(1:nap)]),...
         wa(nas:n)*0.5/pi,10*log10([Asq_k0(nas:n) Asq_kmin(nas:n)]));
% Hack to match colours. Is there an easier way with colormap?
h1c=get(h1,"color");
for c=1:2
  set(h2(c),"color",h1c{c});
endfor
set(h1(1),"linestyle","-");
set(h1(2),"linestyle","-.");
set(h2(1),"linestyle","-");
set(h2(2),"linestyle","-.");
set(ax(1),'ycolor','black');
set(ax(2),'ycolor','black');
if 0
  ylabel(ax(1),"Pass-band amplitude(dB)");
  ylabel(ax(2),"Stop-band amplitude(dB)");
else
  ylabel(ax(1),"Amplitude(dB)");
endif
% End of hack
axis(ax(1),[0, 0.5,  -0.15, 0.05]);
axis(ax(2),[0, 0.5, -70,  -50]);
grid("on");
if ~print_for_web_page
  strt=sprintf("Parallel all-pass lattice low-pass filter (nbits=%d) : \
fap=%g,dBap=%g,fas=%g,dBas=%g,td=%g,tdr=%g",nbits,fap,dBap,fas,dBas,td,tdr);
  title(strt);
endif
subplot(312)
plot(wt*0.5/pi,T_k0,"linestyle","-",wt*0.5/pi,T_kmin,"linestyle","-.");
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0, 0.5, td-(tdr/2), td+(tdr/2)]);
legend("exact","3-s-d(Ito) and b-and-b");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_kmin_intro"),"-dpdflatex");
if print_for_web_page
  print(strcat(strf,"_kmin_intro"),"-dsvg");
endif
close

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"nbits=%d %% Coefficient word length\n",nbits);
fprintf(fid,"ndigits=%d %% Average number of signed digits per coef.\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"difference=%d %% Use difference of all-pass filters\n",difference);
fprintf(fid,"m1=%d %% Allpass model filter 1 denominator order\n",m1);
fprintf(fid,"m2=%d %% Allpass model filter 2 denominator order\n",m2);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Wat=%d %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"dBas=%d %% amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fprintf(fid,"ftp=%g %% Delay pass band edge\n",ftp);
fprintf(fid,"td=%g %% Nominal pass band filter group delay\n",td);
fprintf(fid,"tdr=%g %% Delay pass band peak-to-peak ripple\n",tdr);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fclose(fid);

% Save results
save branch_bound_schurOneMPAlattice_lowpass_12_nbits_test.mat ...
     use_best_branch_and_bound_found ...
     n m1 m2 fap dBap Wap Wat fas dBas Was ftp td tdr Wtp rho tol ctol ...
     improved_solution_found A1k0 A1epsilon0 A1p0 A2k0 A2epsilon0 A2p0 ...
     difference nbits ndigits ndigits_alloc A1k_min A2k_min
     
% Done
toc;
diary off
movefile branch_bound_schurOneMPAlattice_lowpass_12_nbits_test.diary.tmp ...
         branch_bound_schurOneMPAlattice_lowpass_12_nbits_test.diary;
