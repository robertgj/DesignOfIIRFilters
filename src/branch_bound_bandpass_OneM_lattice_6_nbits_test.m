% branch_bound_bandpass_OneM_lattice_6_nbits_test.m
% Copyright (C) 2017 Robert G. Jenssen

% Branch-and-bound search of Schur one-multiplier lattice bandpass filter
% response with 6-bit signed-digit coefficients and Ito et al. allocation

test_common;

unlink("branch_bound_bandpass_OneM_lattice_6_nbits_test.diary");
unlink("branch_bound_bandpass_OneM_lattice_6_nbits_test.diary.tmp");
diary branch_bound_bandpass_OneM_lattice_6_nbits_test.diary.tmp

use_best_branch_and_bound_found=false
if use_best_branch_and_bound_found
  warning("Reporting the best branch-and-bound filter found so far. \n\
           Set \"use_best_branch_and_bound_found\"=false to re-run.");
endif

tic;
maxiter=400
verbose=false
tol=1e-3

% Coefficients found by schurOneMlattice_sqp_slb_bandpass_test.m
k0 = [   0.0000000000,   0.6578120679,   0.0000000000,   0.5164877092, ... 
         0.0000000000,   0.3527537927,   0.0000000000,   0.4280317934, ... 
         0.0000000000,   0.2989556994,   0.0000000000,   0.2525473176, ... 
         0.0000000000,   0.1498954992,   0.0000000000,   0.1010893608, ... 
         0.0000000000,   0.0332806170,   0.0000000000,   0.0134002323 ];
epsilon0 = [  0,  1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0,  1,  0, -1, ... 
              0, -1,  0,  1, ... 
              0, -1,  0, -1 ];
p0 = [   1.0859542638,   1.0859542638,   0.4933739682,   0.4933739682, ... 
         0.8737595176,   0.8737595176,   0.6043900367,   0.6043900367, ... 
         0.9549932244,   0.9549932244,   0.7015778220,   0.7015778220, ... 
         0.9081991060,   0.9081991060,   1.0562679428,   1.0562679428, ... 
         0.9543794437,   0.9543794437,   0.9866883596,   0.9866883596 ];
c0 = [   0.0751717907,  -0.0082427906,  -0.2880852630,  -0.4887366083, ... 
        -0.1709389778,   0.1065369928,   0.3845903475,   0.3074219368, ... 
         0.0242136637,  -0.0804302473,  -0.0844066957,  -0.0154037568, ... 
        -0.0063029471,  -0.0302681729,  -0.0243108556,   0.0037923197, ... 
         0.0245894675,   0.0177004014,   0.0024010069,  -0.0015285861, ... 
         0.0023859122 ];

% Constraints on the coefficients
dmax=0.25
rho=127/128
k0=k0(:);
c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kc0=[k0;c0];

% Find the signed-digit approximations to k0 and c0.
nbits=6
nscale=2^(nbits-1)
ndigits=3
[kc0_sd,kc0_sdu,kc0_sdl]=flt2SD(kc0,nbits,ndigits);
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

% Find the number of signed-digits used by kc0_sd
[kc0_digits,kc0_adders]=SDadders(kc0_sd(kc0_active),nbits);
printf("kc0_sd uses %d signed-digits\n",kc0_digits);
printf("kc0_sd uses %d %d-bit adders for coefficient multiplications\n",
       kc0_adders,nbits);

% Bandpass R=2 filter specification for schurOneMlattice_sqp_slb_bandpass_test.m
fapl=0.1,fapu=0.2,dBap=2,Wap=1
fasl=0.05,fasu=0.25,dBas=23,Wasl=1e4,Wasu=1e5
ftpl=0.09,ftpu=0.21,tp=16,tpr=1.6,Wtp=8

% Amplitude constraints
npoints=250;
wa=(0:(npoints-1))'*pi/npoints;
nasl=ceil(npoints*fasl/0.5)+1;
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
nasu=floor(npoints*fasu/0.5)+1;
Asqd=[zeros(napl-1,1); ...
      ones(napu-napl+1,1); ...
      zeros(npoints-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(npoints-nasu+1,1)];

% Group delay constraints
ntpl=floor(npoints*ftpl/0.5);
ntpu=ceil(npoints*ftpu/0.5);
wt=(ntpl:ntpu)'*pi/npoints;
ntp=length(wt);
Td=tp*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Wp=[];

% Define stack of current filter coefficients and tree depth
kc_stack=cell(1,n_active);
kc_b=kc0_sd;
kc_active=kc0_active;
kc_depth=0;
branch_tree=true;
n_branch=0;
% Find the exact coefficient error
Esq0=schurOneMlatticeEsq(k0,epsilon0,p0,c0,wa,Asqd,Wa,wt,Td,Wt);
printf("Esq0=%g\n",Esq0);
% Find signed-digit error
Esq0_sd=schurOneMlatticeEsq(k0_sd,epsilon0,p0,c0_sd,wa,Asqd,Wa,wt,Td,Wt);
% Initialise the search.
improved_solution_found=false;
Esq_min=Esq0_sd;
k_min=k0_sd;
c_min=c0_sd;
printf("Initial Esq_min=%g\n",Esq_min);
printf("Initial kc_active=[ ");printf("%d ",kc_active);printf("];\n");
printf("Initial kc_b=[ ");printf("%g ",kc_b');printf("]';\n");

if use_best_branch_and_bound_found
  k_min=[ 0 24 0 15 0 11 0 11 0 9 0 6 0 4 0 2 0 1 0 0 ]'/nscale;
  c_min=[ 2 0 -8 -14 -5 3 11 8 0 -3 -2 0 0 -1 -1 0 1 0 0 0 0 ]'/nscale;
  branches_min=3813
  improved_solution_found=true;
  kc_min=[k_min(:);c_min(:)];
  Esq_min=schurOneMlatticeEsq(k_min,epsilon0,p0,c_min,wa,Asqd,Wa,wt,Td,Wt);
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
      % Ito et al. suggest ordering the tree branches by max(kc0_sdu-kc0_sdl)
      [kc0_sdul_max,kc0_sdul_max_n]=max(kc0_sdul(kc_active));
      coef_n=kc_active(kc0_sdul_max_n);
      kc_active(kc0_sdul_max_n)=[];
      % Push a problem onto the stack
      kc_depth=kc_depth+1;
      if kc_depth>n_active
        error("kc_depth(%d)>n_active(%d)",kc_depth,n_active);
      endif
      printf("\nBranch:coef_n=%d,",coef_n);
      kc_problem.kc_b=kc_b;
      kc_problem.kc_active=kc_active;
      kc_stack{kc_depth}=kc_problem;
      % Set up the current sub-problem
      if kc_b(coef_n)==kc0_sdu(coef_n);
        kc_b(coef_n)=kc0_sdl(coef_n);
      else
        kc_b(coef_n)=kc0_sdu(coef_n);
      endif
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
    printf("nscale*kc_b=[ ");printf("%g ",nscale*kc_b');printf("]';\n");

    % Find the error for the current sub-problem
    Esq=schurOneMlatticeEsq(kc_b(1:Nk),epsilon0,p0,kc_b((Nk+1):end), ...
                            wa,Asqd,Wa,wt,Td,Wt);
    printf("Found Esq=%g\n",Esq); 
      
    % Update the active coefficients
    if ~isempty(kc_active)
      % Check bound on Esq 
      if Esq<Esq_min
        branch_tree=true;
      else
        branch_tree=false;
      endif
    endif
    
    % At maximum depth there are no active coefficients so update Esq_min
    if isempty(kc_active)
      % At the maximum depth so update Esq_min
      branch_tree=false;
      k_b=kc_b(1:Nk);
      c_b=kc_b((Nk+1):end);
      printf("At maximum depth Esq=%g\n",Esq); 
      if Esq<Esq_min
        improved_solution_found=true;
        Esq_min=Esq;
        kc_min=kc_b;
        k_min=k_b;
        c_min=c_b;
        printf("Improved solution: kc_depth=%d, Esq_min=%g\n",kc_depth,Esq_min);
        printf("nscale*k_min=[ ");printf("%g ",nscale*k_min');printf("]';\n");
        printf("nscale*c_min=[ ");printf("%g ",nscale*c_min');printf("]';\n");
      endif
    endif

  % Exit the loop when there are no sub-problems left
  until (isempty(kc_active)||(branch_tree==false)) && (kc_depth==0)
  printf("Branch-and-bound search completed with %d branches\n",n_branch);
endif

% Show results
fstr=sprintf("branch_bound_bandpass_OneM_lattice_%d_nbits_test",nbits);
if improved_solution_found
  printf("\nBest new solution:\nEsq_min=%g\n",Esq_min);
  printf("k_min=[ ");printf("%g ",nscale*k_min');printf("]'/nscale;\n");
  printf("epsilon0=[ ");printf("%d ",epsilon0');printf("]';\n");
  printf("p0=[ ");printf("%g ",p0');printf("]';\n");
  printf("c_min=[ ");printf("%g ",nscale*c_min');printf("]'/nscale;\n");
  print_polynomial(nscale*k_min,sprintf("%d*k_min",nscale), ...
                   strcat(fstr,"_k_min_coef.m"),"%6d");
  print_polynomial(nscale*c_min,sprintf("%d*c_min",nscale), ...
                   strcat(fstr,"_c_min_coef.m"),"%6d");
  % Find the number of signed-digits and adders used
  [kc_digits,kc_adders]=SDadders(kc_min(kc0_active),nbits);
  printf("%d signed-digits used\n",kc_digits);
  printf("%d %d-bit adders used for coef. multiplications\n",kc_adders,nbits);
  
  % Amplitude and delay at local peaks
  Asq=schurOneMlatticeAsq(wa,k_min,epsilon0,p0,c_min);
  vAl=local_max(-Asq);
  vAu=local_max(Asq);
  wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
  AsqS=schurOneMlatticeAsq(wAsqS,k_min,epsilon0,p0,c_min);
  printf("k,c_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
  printf("k,c_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
  T=schurOneMlatticeT(wt,k_min,epsilon0,p0,c_min);
  vTl=local_max(-T);
  vTu=local_max(T);
  wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
  TS=schurOneMlatticeT(wTS,k_min,epsilon0,p0,c_min);
  printf("k,c_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
  printf("k,c_min:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

  % Make a LaTeX table for cost
  fid=fopen(strcat(fstr,"_cost.tab"),"wt");
  fprintf(fid,"Exact & %6.4f & & \\\\\n",Esq0);
  fprintf(fid,"%d-bit %d-signed-digit&%6.4f & %d & %d \\\\\n",
          nbits,ndigits,Esq0_sd,kc0_digits,kc0_adders);
  fprintf(fid,"%d-bit %d-signed-digit(branch-and-bound)&%6.4f & %d & %d \\\\\n",
          nbits,ndigits,Esq_min,kc_digits,kc_adders);
  fclose(fid);

  % Calculate response
  nplot=2048;
  wplot=(0:(nplot-1))'*pi/nplot;
  Asq_kc0=schurOneMlatticeAsq(wplot,k0,epsilon0,p0,c0);
  Asq_kc0_sd=schurOneMlatticeAsq(wplot,k0_sd,epsilon0,p0,c0_sd);
  Asq_kc_min=schurOneMlatticeAsq(wplot,k_min,epsilon0,p0,c_min);
  T_kc0=schurOneMlatticeT(wplot,k0,epsilon0,p0,c0);
  T_kc0_sd=schurOneMlatticeT(wplot,k0_sd,epsilon0,p0,c0_sd);
  T_kc_min=schurOneMlatticeT(wplot,k_min,epsilon0,p0,c_min);

  % Plot amplitude stop-band response
  plot(wplot*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
       wplot*0.5/pi,10*log10(abs(Asq_kc0_sd)),"linestyle","--", ...
       wplot*0.5/pi,10*log10(abs(Asq_kc_min)),"linestyle","-.");
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  axis([0 0.5 -50 -10]);
  tstr=sprintf("Schur one-multiplier lattice bandpass filter stop-band \
(nbits=%d) : fasl=%g,fasu=%g,dBas=%g",nbits,fasl,fasu,dBas);
  title(tstr);
  legend("exact","s-d","s-d(BandB)");
  legend("location","northeast");
  legend("Boxoff");
  legend("left");
  grid("on");
  print(strcat(fstr,"_stop"),"-dpdflatex");
  close

  % Plot amplitude pass-band response
  plot(wplot*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
       wplot*0.5/pi,10*log10(abs(Asq_kc0_sd)),"linestyle","--", ...
       wplot*0.5/pi,10*log10(abs(Asq_kc_min)),"linestyle","-.");
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  axis([0.1 0.2 -6 6]);
  tstr=sprintf("Schur one-multiplier lattice bandpass filter pass-band \
(nbits=%d) : fapl=%g,fapu=%g,dBap=%g",nbits,fapl,fapu,dBap);
  title(tstr);
  legend("exact","s-d","s-d(BandB)");
  legend("location","northeast");
  legend("Boxoff");
  legend("left");
  grid("on");
  print(strcat(fstr,"_pass"),"-dpdflatex");
  close

  % Plot group-delay pass-band response
  plot(wplot*0.5/pi,T_kc0,"linestyle","-", ...
       wplot*0.5/pi,T_kc0_sd,"linestyle","--", ...
       wplot*0.5/pi,T_kc_min,"linestyle","-.");
  xlabel("Frequency");
  ylabel("Group delay(samples)");
  axis([0.09 0.21 15 17]);
  tstr=sprintf("Schur one-multiplier lattice bandpass filter pass-band \
(nbits=%d) : ftpl=%g,ftpu=%g,tp=%g,tpr=%g",nbits,ftpl,ftpu,tp,tpr);
  title(tstr);
  legend("exact","s-d","s-d(BandB)");
  legend("location","northeast");
  legend("Boxoff");
  legend("left");
  grid("on");
  print(strcat(fstr,"_delay"),"-dpdflatex");
  close

else
  printf("Did not find an improved solution!\n");
endif

% Filter specification
fid=fopen(strcat(fstr,".spec"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coefficient. update\n",tol);
fprintf(fid,"maxiter=%d %% SQP iteration limit\n",maxiter);
fprintf(fid,"npoints=%g %% Frequency points across the band\n",npoints);
fprintf(fid,"length(c0)=%d %% Num. tap coefficients\n",length(c0));
fprintf(fid,"sum(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",sum(k0~=0));
fprintf(fid,"dmax=%f %% Constraint on norm of coefficient SQP step size\n",dmax);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal passband filter group delay\n",tp);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"Wasl=%d %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Amplitude upper stop band weight\n",Wasu);
fclose(fid);

% Save results
save branch_bound_bandpass_OneM_lattice_6_nbits_test.mat ...
     use_best_branch_and_bound_found ...
     k0 epsilon0 p0 c0 tol nbits ndigits npoints ...
     fapl fapu dBap Wap fasl fasu dBas Wasl Wasu ftpl ftpu tp tpr Wtp ...
     improved_solution_found k_min c_min 
       
% Done
toc;
diary off
movefile branch_bound_bandpass_OneM_lattice_6_nbits_test.diary.tmp ...
       branch_bound_bandpass_OneM_lattice_6_nbits_test.diary;
