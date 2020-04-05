% branch_bound_johanssonOneMlattice_bandstop_16_nbits_test.m
% Copyright (C) 2019 Robert G. Jenssen

% Branch-and-bound search of Johansson and Saramaki cascade all-pass band-stop
% filter response with 16-bit 3-signed-digit coefficients

test_common;

strf="branch_bound_johanssonOneMlattice_bandstop_16_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));

diary branch_bound_johanssonOneMlattice_bandstop_16_nbits_test.diary.tmp

tic;
maxiter=400
verbose=false

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Band-stopfilter specification
fapl=0.15,fasl=0.2,fasu=0.25,fapu=0.3,Wap=1,Was=1

% Band-stop filter from johansson_cascade_allpass_bandstop_test.m
fM = [  -0.0314881200,  -0.0000085599,   0.2814857078,   0.5000169443 ];
a0 = [   1.0000000000,  -0.5650802796,   1.6504647259,  -0.4790659039, ... 
         0.7284633026 ];
a1 = [   1.0000000000,  -0.2594839587,   0.6383172372 ];

% Convert all-pass filter transfer functions to Schur 1-multiplier lattice
[k0,epsilon0,~,~]=tf2schurOneMlattice(fliplr(a0),a0);
[k1,epsilon1,~,~]=tf2schurOneMlattice(fliplr(a1),a1);

% Frequencies
nf=5000;
wa=(0:nf)'*pi/nf;
napl=ceil(fapl*nf/0.5)+1;
nasl=floor(fasl*nf/0.5)+1;
nasu=ceil(fasu*nf/0.5)+1;
napu=floor(fapu*nf/0.5)+1;
Ad=[ones(napl,1);zeros(napu-napl-1,1);ones(nf-napu+2,1)];
Wa=[Wap*ones(napl,1); ...
    zeros(nasl-napl-1,1); ...
    Was*ones(nasu-nasl+1,1); ...
    zeros(napu-nasu-1,1); ...
    Wap*ones(nf-napu+2,1)];
nchk=[1, napl-1,napl,napl+1,nasl-1,nasl,nasl+1, ...
         nasu-1,nasu,nasu+1,napu-1,napu,napu+1,nf+1];
printf("nchk=[1, napl-1,napl,napl+1,nasl-1,nasl,nasl+1, ...\n");
printf("       nasu-1,nasu,nasu+1,napu-1,napu,napu+1,nf+1];\n");
printf("nchk=[ ");printf("%d ",nchk(1:7));printf(" ... \n");
printf("         ");printf("%d ",nchk(8:end));printf("];\n");
printf("wa(nchk)=[ ");printf("%g ",wa(nchk(1:7))*0.5/pi);printf(" ... \n");
printf("             ");printf("%g ",wa(nchk(8:end))*0.5/pi);printf("]*2*pi;\n");
printf("Ad(nchk)=[ ");printf("%d ",Ad(nchk(1:7)));printf(" ... \n");
printf("             ");printf("%d ",Ad(nchk(8:end)));printf("];\n");
printf("Wa(nchk)=[ ");printf("%d ",Wa(nchk(1:7)));printf(" ... \n");
printf("             ");printf("%d ",Wa(nchk(8:end)));printf("];\n");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Quantised coefficient specifications
nbits=16
nscale=2^(nbits-1)
ndigits=3

% Find the signed-digit approximations to fM, k0 and k1.
fM=fM(:);
k0=k0(:);
k1=k1(:);
NfM=length(fM);
Nk0=length(k0);
Nk1=length(k1);
RfM=1:NfM;
Rk0=(NfM+1):(NfM+Nk0);
Rk1=(NfM+Nk0+1):(NfM+Nk0+Nk1);
fMk=[fM;k0;k1];
[fMk_sd,fMk_sdu,fMk_sdl]=flt2SD(fMk,nbits,ndigits);
fM_sd=fMk_sd(RfM);
fM_sd=fM_sd(:);
k0_sd=fMk_sd(Rk0);
k0_sd=k0_sd(:);
k1_sd=fMk_sd(Rk1);
k1_sd=k1_sd(:);
% Initialise fMk_active
fMk_sdul=fMk_sdu-fMk_sdl;
fMk0k1_active=find(fMk_sdul~=0);
n_active=length(fMk0k1_active);
% Check for consistent upper and lower bounds
if any(fMk_sdl>fMk_sdu)
  error("found fMk_sdl>fMk_sdu");
endif
if any(fMk_sdl>fMk_sdu)
  error("found fMk_sdl>fMk_sdu");
endif
if any(fMk_sd(fMk0k1_active)>fMk_sdu(fMk0k1_active))
  error("found fMk_sd(fMk0k1_active)>fMk_sdu(fMk0k1_active)");
endif
if any(fMk_sdl(fMk0k1_active)>fMk_sd(fMk0k1_active))
  error("found fMk_sdl(fMk0k1_active)>fMk_sd(fMk0k1_active)");
endif
if any(fMk(fMk0k1_active)>fMk_sdu(fMk0k1_active))
  error("found fMk(fMk0k1_active)>fMk_sdu(fMk0k1_active)");
endif
if any(fMk_sdl(fMk0k1_active)>fMk(fMk0k1_active))
  error("found fMk_sdl>fMk");
endif

% Find the number of signed-digits used by fMk_sd
[fMk_digits,fMk_adders]=SDadders(fMk_sd(fMk0k1_active),nbits);
printf("fMk_sd uses %d signed-digits\n",fMk_digits);
printf("fMk_sd uses %d %d-bit adders for coefficient multiplications\n",
       fMk_adders,nbits);

% Define stack of current filter coefficients and tree depth
fMk_stack=cell(1,n_active);
fMk_active=fMk0k1_active;
fMk_b=fMk_sd;
fMk_depth=0;
branch_tree=true;
n_branch=0;
% Find the exact coefficient error
Esq0=johanssonOneMlatticeEsq(fM,k0,epsilon0,k1,epsilon1,wa,Ad,Wa);
printf("Esq0=%g\n",Esq0);
% Find signed-digit error
Esq0_sd=johanssonOneMlatticeEsq(fM_sd,k0_sd,epsilon0,k1_sd,epsilon1,wa,Ad,Wa);
% Initialise the search.
improved_solution_found=false;
Esq_min=Esq0_sd;
fM_min=fM_sd;
k0_min=k0_sd;
k1_min=k1_sd;
printf("Initial Esq_min=%g\n",Esq_min);
printf("Initial fMk_active=[ ");printf("%d ",fMk_active);printf("];\n");
printf("Initial fMk_b=[ ");printf("%g ",fMk_b');printf("]';\n");

% At each node of a branch, define two sub-problems, one of which is
% stacked and one of which is solved immediately. If the solved problem
% reduces Esq_min, then continue to the next node on that branch. If the
% solved problem does not improve Esq_min then give up on this branch and
% continue by solving the problem on top of the stack.
do

  % Choose the sub-problem to solve
  if branch_tree  
    n_branch=n_branch+1;
    % Ito et al. suggest ordering the tree branches by max(fMk_sdu-fMk_sdl)
    [fMk_sdul_max,fMk_sdul_max_n]=max(fMk_sdul(fMk_active));
    coef_n=fMk_active(fMk_sdul_max_n);
    fMk_active(fMk_sdul_max_n)=[];
    % Push a problem onto the stack
    fMk_depth=fMk_depth+1;
    if fMk_depth>n_active
      error("fMk_depth(%d)>n_active(%d)",fMk_depth,n_active);
    endif
    printf("\nBranch:coef_n=%d,",coef_n);
    fMk_problem.fMk_b=fMk_b;
    fMk_problem.fMk_active=fMk_active;
    fMk_stack{fMk_depth}=fMk_problem;
    % Set up the current sub-problem
    if fMk_b(coef_n)==fMk_sdu(coef_n);
      fMk_b(coef_n)=fMk_sdl(coef_n);
    else
      fMk_b(coef_n)=fMk_sdu(coef_n);
    endif
  else
    % Pop a problem off the stack 
    if fMk_depth<=0
      error("fMk_depth(%d)<=0",fMk_depth);
    endif
    fMk_problem=fMk_stack{fMk_depth};
    fMk_depth=fMk_depth-1;
    fMk_b=fMk_problem.fMk_b;
    fMk_active=fMk_problem.fMk_active;
    printf("\nBacktrack:");
  endif
  printf("fMk_depth=%d\n",fMk_depth);
  printf("fMk_active=[ ");printf("%d ",fMk_active);printf("];\n");
  printf("fMk_b=[ ");printf("%g ",nscale*fMk_b');printf("]'/%d;\n",nscale);

  % Find the error for the current sub-problem
  Esq=johanssonOneMlatticeEsq ...
        (fMk_b(RfM),fMk_b(Rk0),epsilon0,fMk_b(Rk1),epsilon1,wa,Ad,Wa);
  printf("Found Esq=%g\n",Esq); 
  
  % Update the active coefficients
  if ~isempty(fMk_active)
    % Check bound on Esq 
    if (Esq<Esq_min) || (fMk_depth == 0)
      branch_tree=true;
    else
      branch_tree=false;
    endif
  endif
  
  % At maximum depth there are no active coefficients so update Esq_min
  if isempty(fMk_active)
    % At the maximum depth so update Esq_min
    branch_tree=false;
    fM_b=fMk_b(RfM);
    k0_b=fMk_b(Rk0);
    k1_b=fMk_b(Rk1);
    printf("At maximum depth Esq=%g\n",Esq); 
    if Esq<Esq_min
      improved_solution_found=true;
      Esq_min=Esq;
      fMk_min=fMk_b;
      fM_min=fM_b;
      f_min=[fM_min;fM_min((length(fM_min)-1):-1:1)];
      k0_min=k0_b;
      k1_min=k1_b;
      printf("Improved solution: fMk_depth=%d, Esq_min=%g\n",fMk_depth,Esq_min);
      print_polynomial(f_min,"f_min",nscale);
      print_polynomial(k0_min,"k0_min",nscale);
      print_polynomial(k1_min,"k1_min",nscale);
    endif
  endif

% Exit the loop when there are no sub-problems left
until (isempty(fMk_active)||(branch_tree==false)) && (fMk_depth==0)
printf("Branch-and-bound search completed with %d branches\n",n_branch);

% Show results
if improved_solution_found
  printf("\nBest new solution:\nEsq_min=%g\n",Esq_min);
  print_polynomial(f_min,"f_min",nscale);
  print_polynomial(f_min,"f_min",strcat(strf,"_f_min_coef.m"),nscale);
  print_polynomial(k0_min,"k0_min",nscale);
  print_polynomial(k0_min,"k0_min",strcat(strf,"_k0_min_coef.m"),nscale);
  print_polynomial(k1_min,"k1_min",nscale);
  print_polynomial(k1_min,"k1_min",strcat(strf,"_k1_min_coef.m"),nscale);
  % Find the number of signed-digits and adders used
  [fMk_digits,fMk_adders]=SDadders(fMk_min(fMk0k1_active),nbits);
  printf("%d signed-digits used\n",fMk_digits);
  printf("%d %d-bit adders used for coef. multiplications\n",fMk_adders,nbits);
  
  % Amplitude and delay at local peaks
  Azp=johanssonOneMlatticeAzp(wa,fM_min,k0_min,epsilon0,k1_min,epsilon1);
  vAl=local_max(-Azp);
  vAu=local_max(Azp);
  wAzpS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
  AzpS=johanssonOneMlatticeAzp(wAzpS,fM_min,k0_min,epsilon0,k1_min,epsilon1);
  printf("fM,k0,k1_min:fAzpS=[ ");printf("%f ",wAzpS'*0.5/pi);
  printf(" ] (fs==1)\n");
  printf("fM,k0,k1_min:AzpS=[ ");printf("%f ",20*log10(AzpS'));
  printf(" ] (dB)\n");

  % Make a LaTeX table for cost
  fid=fopen(strcat(strf,"_cost.tab"),"wt");
  fprintf(fid,"Exact & %10.4g & & \\\\\n",Esq0);
  fprintf(fid,"%d-bit %d-signed-digit&%10.4g & %d & %d \\\\\n",
          nbits,ndigits,Esq0_sd,fMk_digits,fMk_adders);
  fprintf(fid,"%d-bit %d-signed-digit(branch-and-bound)&%10.4g & %d & %d \\\\\n",
          nbits,ndigits,Esq_min,fMk_digits,fMk_adders);
  fclose(fid);

  % Calculate response
  nplot=2048;
  wplot=(0:(nplot-1))'*pi/nplot;
  Azp_fMk=johanssonOneMlatticeAzp(wplot,fM,k0,epsilon0,k1,epsilon1);
  Azp_fMk_sd= ...
    johanssonOneMlatticeAzp(wplot,fM_sd,k0_sd,epsilon0,k1_sd,epsilon1);
  Azp_fMk_min= ...
    johanssonOneMlatticeAzp(wplot,fM_min,k0_min,epsilon0,k1_min,epsilon1);

  % Plot amplitude stop-band response
subplot(211)
  % Plot amplitude pass-band response
  plot(wplot*0.5/pi,20*log10(abs(Azp_fMk)),"linestyle","-", ...
       wplot*0.5/pi,20*log10(abs(Azp_fMk_sd)),"linestyle","--", ...
       wplot*0.5/pi,20*log10(abs(Azp_fMk_min)),"linestyle","-.");
  ylabel("Amplitude(dB)");
  axis([0 0.5 -0.0001 0.0004]);
  strt=sprintf("Johansson-and-Saram\\\"{a}ki cascade all-pass band-stop \
response after branch-and-bound search (nbits=%d)",nbits);
  title(strt);
  grid("on");
  subplot(212)
  plot(wplot*0.5/pi,20*log10(abs(Azp_fMk)),"linestyle","-", ...
       wplot*0.5/pi,20*log10(abs(Azp_fMk_sd)),"linestyle","--", ...
       wplot*0.5/pi,20*log10(abs(Azp_fMk_min)),"linestyle","-.");
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  axis([0 0.5 -120 -80]);
  legend("exact","s-d","s-d(BandB)");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  grid("on");
  print(strcat(strf,"_resp"),"-dpdflatex");
  close
else
  printf("Did not find an improved solution!\n");
endif

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Coefficient signed-digits\n",ndigits);
fprintf(fid,"nf=%g %% Frequency points across the band\n",nf);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);

% Save results
save branch_bound_johanssonOneMlattice_bandstop_16_nbits_test.mat ...
     fM a0 a1 k0 epsilon0 k1 epsilon1 nbits ndigits nf ...
     fapl fasl fasu fapu Wap Was ...
     improved_solution_found f_min k0_min k1_min
       
% Done
toc;
diary off
movefile branch_bound_johanssonOneMlattice_bandstop_16_nbits_test.diary.tmp ...
         branch_bound_johanssonOneMlattice_bandstop_16_nbits_test.diary;
