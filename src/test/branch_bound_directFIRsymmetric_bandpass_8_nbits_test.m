% branch_bound_directFIRsymmetric_bandpass_8_nbits_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

% Branch-and-bound search of direct-form symmetric bandpass filter
% response with 8-bit signed-digit coefficients

test_common;

delete("branch_bound_directFIRsymmetric_bandpass_8_nbits_test.diary");
delete("branch_bound_directFIRsymmetric_bandpass_8_nbits_test.diary.tmp");
diary branch_bound_directFIRsymmetric_bandpass_8_nbits_test.diary.tmp

tic;
maxiter=400
verbose=false
tol=1e-4
strf="branch_bound_directFIRsymmetric_bandpass_8_nbits_test";

% Coefficients found by directFIRsymmetric_slb_bandpass_test.m
directFIRsymmetric_slb_bandpass_test_hM1_coef;

% Scale the rounded coefficients to use all the bits 
nbits=8
nscale=2^(nbits-1)
ndigits=3
hM1_rd=round(hM1*nscale)/nscale;
escale=ceil(log2(1/max(abs(hM1_rd))));
printf("Scaling hM1 by %d\n",escale);
enscale=escale*nscale;

% Find the signed-digit approximations to hM1
hM1=hM1(:);
NhM=length(hM1);
[hM1_sd,hM1_sdu,hM1_sdl]=flt2SD(hM1*escale,nbits,ndigits);

% Initialise hM1_active
hM1_sdul=hM1_sdu-hM1_sdl;
hM1_active=find(hM1_sdul~=0);
n_active=length(hM1_active);

% Check for consistent upper and lower bounds
if any(hM1_sdl>hM1_sdu)
  error("found hM1_sdl>hM1_sdu");
endif
if any(hM1_sdl>hM1_sdu)
  error("found hM1_sdl>hM1_sdu");
endif
if any(hM1_sd(hM1_active)>hM1_sdu(hM1_active))
  error("found hM1_sd(hM1_active)>hM1_sdu(hM1_active)");
endif
if any(hM1_sdl(hM1_active)>hM1_sd(hM1_active))
  error("found hM1_sdl(hM1_active)>hM1_sd(hM1_active)");
endif

% Find the number of signed-digits used by hM1_sd
[hM1_sd_digits,hM1_sd_adders]=SDadders(hM1_sd(hM1_active),nbits);
printf("hM1_sd uses %d signed-digits\n",hM1_sd_digits);
printf("hM1_sd uses %d %d-bit adders for coefficient multiplications\n",
       hM1_sd_adders,nbits);

% Bandpass filter specification for directFIRsymmetric_slb_bandpass_test.m
fapl=0.1;fapu=0.2;Wap=1;
fasl=0.05;fasu=0.25;Wasl=5;Wasu=10;

% Desired magnitude response
nplot=1000;
wa=(0:nplot)'*pi/nplot;
nasl=ceil(nplot*fasl/0.5)+1;
napl=floor(nplot*fapl/0.5)+1;
napu=ceil(nplot*fapu/0.5)+1;
nasu=floor(nplot*fasu/0.5)+1;  
na=[1 nasl napl napu nasu length(wa)];
Ad=[zeros(napl-1,1); ...
    ones(napu-napl+1,1); ...
    zeros(nplot-napu+1,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(nplot-nasu+2,1)];

% Define stack of current filter coefficients and tree depth
hM_stack=cell(1,n_active);
hM_b=hM1_sd;
hM_active=hM1_active;
hM_depth=0;
branch_tree=true;
n_branch=0;
% Find the exact coefficient error
waf=wa([1 nasl napl napu nasu end]);
Adf=[0 0 1 0 0];
Waf=[Wasl 0 Wap 0 Wasu];
Esq1=directFIRsymmetricEsqPW(hM1,waf,Adf,Waf);
printf("Esq1=%g\n",Esq1);
% Find signed-digit error
Esq1_sd=directFIRsymmetricEsqPW(hM1_sd/escale,waf,Adf,Waf);
% Initialise the search.
improved_solution_found=false;
Esq_min=Esq1_sd;
hM_min=hM1_sd;
printf("Initial Esq_min=%g\n",Esq_min);
printf("Initial hM_active=[ ");printf("%d ",hM_active);printf("];\n");
printf("Initial hM_b=[ ");printf("%g ",nscale*hM_b');printf("]'/%d;\n",enscale);

% At each node of a branch, define two sub-problems, one of which is
% stacked and one of which is solved immediately. If the solved problem
% reduces Esq_min, then continue to the next node on that branch. If the
% solved problem does not improve Esq_min then give up on this branch and
% continue by solving the problem on top of the stack.
do

  % Choose the sub-problem to solve
  if branch_tree  
    n_branch=n_branch+1;
    % Ito et al. suggest ordering the tree branches by max(hM_sdu-hM_sdl)
    [hM_sdul_max,hM_sdul_max_n]=max(hM1_sdul(hM_active));
    coef_n=hM_active(hM_sdul_max_n);
    hM_active(hM_sdul_max_n)=[];
    % Push a problem onto the stack
    hM_depth=hM_depth+1;
    if hM_depth>n_active
      error("hM_depth(%d)>n_active(%d)",hM_depth,n_active);
    endif
    printf("\nBranch:coef_n=%d,",coef_n);
    hM_problem.hM_b=hM_b;
    hM_problem.hM_active=hM_active;
    hM_stack{hM_depth}=hM_problem;
    % Set up the current sub-problem
    if hM_b(coef_n)==hM1_sdu(coef_n);
      hM_b(coef_n)=hM1_sdl(coef_n);
    else
      hM_b(coef_n)=hM1_sdu(coef_n);
    endif
  else
    % Pop a problem off the stack 
    if hM_depth<=0
      error("hM_depth(%d)<=0",hM_depth);
    endif
    hM_problem=hM_stack{hM_depth};
    hM_depth=hM_depth-1;
    hM_b=hM_problem.hM_b;
    hM_active=hM_problem.hM_active;
    printf("\nBacktrack:");
  endif
  printf("hM_depth=%d\n",hM_depth);
  printf("hM_active=[ ");printf("%d ",hM_active);printf("];\n");
  printf("hM_b=[ ");printf("%g ",nscale*hM_b');printf("]'/%d;\n",enscale);

  % Find the error for the current sub-problem
  Esq=directFIRsymmetricEsqPW(hM_b/escale,waf,Adf,Waf);
  printf("Found Esq=%g\n",Esq); 
  
  % Update the active coefficients
  if ~isempty(hM_active)
    % Check bound on Esq 
    if (Esq<Esq_min) || (hM_depth == 0)
      branch_tree=true;
    else
      branch_tree=false;
    endif
  endif
  
  % At maximum depth there are no active coefficients so update Esq_min
  if isempty(hM_active)
    % At the maximum depth so update Esq_min
    branch_tree=false;
    printf("At maximum depth Esq=%g\n",Esq); 
    if Esq<Esq_min
      improved_solution_found=true;
      Esq_min=Esq;
      hM_min=hM_b;
      printf("Improved solution: hM_depth=%d, Esq_min=%g\n",hM_depth,Esq_min);
      print_polynomial(hM_min/escale,"hM_min",enscale);
    endif
  endif

% Exit the loop when there are no sub-problems left
until (isempty(hM_active)||(branch_tree==false)) && (hM_depth==0)
printf("Branch-and-bound search completed with %d branches\n",n_branch);

% Show results
if ~improved_solution_found
  error("Did not find an improved solution!\n");
endif
print_polynomial(hM1,"hM1",strcat(strf,"_hM1_coef.m"));
printf("\nBest new solution:\nEsq_min=%g\n",Esq_min);
print_polynomial(hM_min/escale,"hM_min",enscale);
print_polynomial(hM_min/escale,"hM_min",strcat(strf,"_hM_min_coef.m"),enscale);
% Find the number of signed-digits and adders used
[hM_min_digits,hM_min_adders]=SDadders(hM_min(hM1_active),nbits);
printf("%d signed-digits used\n",hM_min_digits);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       hM_min_adders,nbits);
fname=strcat(strf,"_hM_min_adders.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",hM_min_adders);
fclose(fid);

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %7.5f \\\\\n",Esq1);
fprintf(fid,"%d-bit %d-signed-digit & %7.5f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq1_sd,hM1_sd_digits,hM1_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(branch-and-bound)& %7.5f & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,hM_min_digits,hM_min_adders);
fclose(fid);

% Amplitude and delay at local peaks
A=directFIRsymmetricA(wa,hM_min/escale);
vAl=local_max(-A);
vAu=local_max(A);
wAS=unique([wa(vAl);wa(vAu);wa([nasl,napl,napu,nasu])]);
AS=directFIRsymmetricA(wAS,hM_min/escale);
wAS=wAS(find(abs(AS)>0));
AS=AS(find(abs(AS)>0));
printf("hM_min:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("hM_min:AS=[ ");printf("%f ",20*log10(abs(AS)'));printf(" ] (dB)\n");

% Calculate response
nplot=2048;
wplot=(0:(nplot-1))'*pi/nplot;
A_hM1=directFIRsymmetricA(wplot,hM1);
A_hM1_sd=directFIRsymmetricA(wplot,hM1_sd/escale);
A_hM_min=directFIRsymmetricA(wplot,hM_min/escale);

% Plot amplitude response
plot(wplot*0.5/pi,20*log10(abs(A_hM1)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(A_hM1_sd)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(A_hM_min)),"linestyle","-.");
axis([0.1 0.2 -1.5 0.5]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("exact","s-d","s-d(BandB)");
legend("location","north");
legend("boxoff");
legend("left");
grid("on");
strt=sprintf(["Direct-form symmetric bandpass filter response ", ...
 "(nbits=%d,ndigits=%d) : fapl=%g,fapu=%g,fasl=%g,fasu=%g"], ...
             nbits,ndigits,fapl,fapu,fasl,fasu);
title(strt);
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

plot(wplot*0.5/pi,20*log10(abs(A_hM1)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(A_hM1_sd)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(A_hM_min)),"linestyle","-.");
axis([0 0.5 -50 -30]);
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("exact","s-d","s-d(BandB)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_stopband_response"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%d %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%d %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"escale=%d %% Coefficient scaling for full range\n",escale);
fprintf(fid,"tol=%g %% Tolerance on coefficient. update\n",tol);
fprintf(fid,"maxiter=%d %% iteration limit\n",maxiter);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"Wasl=%d %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Amplitude upper stop band weight\n",Wasu);
fclose(fid);

% Save results
save branch_bound_directFIRsymmetric_bandpass_8_nbits_test.mat ...
     hM1 hM1_sd tol nbits ndigits escale fapl fapu Wap fasl fasu Wasl Wasu ...
     improved_solution_found hM_min
       
% Done
toc;
diary off
movefile branch_bound_directFIRsymmetric_bandpass_8_nbits_test.diary.tmp ...
         branch_bound_directFIRsymmetric_bandpass_8_nbits_test.diary;
