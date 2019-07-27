% branch_bound_directFIRhilbert_12_nbits_test.m
% Copyright (C) 2017-2019 Robert G. Jenssen

% Branch-and-bound search of a direct-form Hilbert filter
% with 12-bit 2-signed-digit coefficients

test_common;

unlink("branch_bound_directFIRhilbert_12_nbits_test.diary");
unlink("branch_bound_directFIRhilbert_12_nbits_test.diary.tmp");
diary branch_bound_directFIRhilbert_12_nbits_test.diary.tmp

tic;
maxiter=400
verbose=false
tol=1e-4
strf="branch_bound_directFIRhilbert_12_nbits_test";

% Hilbert filter frequency specification
M=40;fapl=0.01;fapu=0.5-fapl;Wap=1;Was=0;
npoints=1000;
wa=(0:((npoints)-1))'*pi/(npoints);
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
Ad=ones(npoints,1);
Wa=[Was*ones(napl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Was*ones(npoints-napu,1)];

% Make a Hilbert filter
n4M1=((-2*M)+1):2:((2*M)-1)';
h0=zeros((4*M)+1,1);
h0(n4M1+(2*M)+1)=2*(sin(pi*n4M1/2).^2)./(pi*n4M1);
h0=h0.*hamming((4*M)+1);
hM0=h0(((2*M)+2):2:(end-1));
hM0_active=1:length(hM0);

% Find the exact coefficient error
waf=wa([napl napu]);
Adf=1;
Waf=Wap;
Esq0=directFIRhilbertEsqPW(hM0,waf,Adf,Waf);
printf("Esq0=%g\n",Esq0);

% Scale the rounded coefficients to use all the bits 
nbits=12
nscale=2^(nbits-1)
ndigits=2

% Find the signed-digit approximations to hM2
[hM0_sd]=flt2SD(hM0(:),nbits,ndigits);
Esq0_sd=directFIRhilbertEsqPW(hM0_sd,waf,Adf,Waf);
% Find the number of signed-digits used by hM0_sd
[hM0_sd_digits,hM0_sd_adders]=SDadders(hM0_sd(hM0_active),nbits);
printf("hM0_sd uses %d signed-digits\n",hM0_sd_digits);
printf("hM0_sd uses %d %d-bit adders for coefficient multiplications\n",
       hM0_sd_adders,nbits);

% Allocate signed digits with the heuristic of Ito et al.
ndigits_Ito=directFIRhilbert_allocsd_Ito(nbits,ndigits,hM0,waf,Adf,Waf);
[hM_sd,hM_sdu,hM_sdl]=flt2SD(hM0(:),nbits,ndigits_Ito);
% Find signed-digit error
Esq_sd=directFIRhilbertEsqPW(hM_sd,waf,Adf,Waf);
% Find the number of signed-digits used by hM_sd
[hM_sd_digits,hM_sd_adders]=SDadders(hM_sd,nbits);
printf("hM_sd uses %d signed-digits\n",hM_sd_digits);
printf("hM_sd uses %d %d-bit adders for coefficient multiplications\n",
       hM_sd_adders,nbits);

% Initialise hM_active
hM_sdul=hM_sdu-hM_sdl;
hM_active=find(hM_sdul~=0);
n_active=length(hM_active);

% Check for consistent upper and lower bounds
if any(hM_sdl>hM_sdu)
  error("found hM_sdl>hM_sdu");
endif
if any(hM_sdl>hM_sdu)
  error("found hM_sdl>hM_sdu");
endif
if any(hM_sd(hM_active)>hM_sdu(hM_active))
  error("found hM_sd(hM_active)>hM_sdu(hM_active)");
endif
if any(hM_sdl(hM_active)>hM_sd(hM_active))
  error("found hM_sdl(hM_active)>hM_sd(hM_active)");
endif

% Define stack of current filter coefficients and tree depth
hM_stack=cell(1,n_active);
hM_b=hM_sd;
hM_depth=0;
branch_tree=true;
n_branch=0;
% Initialise the search.
improved_solution_found=false;
Esq_min=Esq_sd;
hM_min=hM_sd;
printf("Initial Esq_min=%g\n",Esq_min);
printf("Initial hM_active=[ ");printf("%d ",hM_active);printf("];\n");
printf("Initial hM_b=[ ");printf("%g ",nscale*hM_b');printf("]'/%d;\n",nscale);

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
    [hM_sdul_max,hM_sdul_max_n]=max(hM_sdul(hM_active));
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
    if hM_b(coef_n)==hM_sdu(coef_n);
      hM_b(coef_n)=hM_sdl(coef_n);
    else
      hM_b(coef_n)=hM_sdu(coef_n);
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
  printf("hM_b=[ ");printf("%g ",nscale*hM_b');printf("]'/%d;\n",nscale);

  % Find the error for the current sub-problem
  Esq=directFIRhilbertEsqPW(hM_b,waf,Adf,Waf);
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
      print_polynomial(hM_min,"hM_min",nscale);
    endif
  endif

% Exit the loop when there are no sub-problems left
until (isempty(hM_active)||(branch_tree==false)) && (hM_depth==0)
printf("Branch-and-bound search completed with %d branches\n",n_branch);

% Show results
if improved_solution_found
  printf("\nBest new solution:\nEsq_min=%g\n",Esq_min);
  print_polynomial(hM_min,"hM_min",nscale);
  % Find the number of signed-digits and adders used
  [hM_min_digits,hM_min_adders]=SDadders(hM_min(hM0_active)*nscale,nbits);
  printf("%d signed-digits used\n",hM_min_digits);
  printf("%d %d-bit adders used for coefficient multiplications\n", ...
         hM_min_adders,nbits);
  fname=strcat(strf,"_hM_min_adders.tab");
  fid=fopen(fname,"wt");
  fprintf(fid,"$%d$",hM_min_adders);
  fclose(fid);

  % Make a LaTeX table for cost
  fid=fopen(strcat(strf,"_cost.tab"),"wt");
  fprintf(fid,"Exact & %10.2e & & \\\\\n",Esq0);
  fprintf(fid,"%d-bit %d-signed-digit & %10.2e & %d & %d \\\\\n", ...
          nbits,ndigits,Esq0_sd,hM0_sd_digits,hM0_sd_adders);  
  fprintf(fid,"%d-bit %d-signed-digit(Ito) & %10.2e & %d & %d \\\\\n", ...
          nbits,ndigits,Esq_sd,hM_sd_digits,hM_sd_adders);
  fprintf(fid,"%d-bit %d-signed-digit(branch-and-bound)&%10.2e & %d & %d \\\\\n",
          nbits,ndigits,Esq_min,hM_min_digits,hM_min_adders);
  fclose(fid);

  % Amplitude and delay at local peaks
  A=directFIRhilbertA(wa(1:(npoints/2)),hM_min);
  vAl=local_max(-A);
  vAu=local_max(A);
  wAS=unique([wa(vAl);wa(vAu);wa(napl)]);
  AS=directFIRhilbertA(wAS,hM_min);
  wAS=wAS(find(abs(AS)>0));
  AS=AS(find(abs(AS)>0));
  printf("hM_min:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
  printf("hM_min:AS=[ ");printf("%f ",20*log10(abs(AS)'));printf(" ] (dB)\n");

  % Calculate response
  nplot=2048;
  wplot=(0:(nplot-1))'*pi/nplot;
  A_hM0=directFIRhilbertA(wplot,hM0);
  A_hM0_sd=directFIRhilbertA(wplot,hM0_sd);
  A_hM_sd=directFIRhilbertA(wplot,hM_sd);
  A_hM_min=directFIRhilbertA(wplot,hM_min);

  % Plot amplitude response
  plot(wplot*0.5/pi,20*log10(abs(A_hM0)),"linestyle","-", ...
       wplot*0.5/pi,20*log10(abs(A_hM0_sd)),"linestyle",":", ...
       wplot*0.5/pi,20*log10(abs(A_hM_sd)),"linestyle","--", ...
       wplot*0.5/pi,20*log10(abs(A_hM_min)),"linestyle","-.");
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  axis([0 0.5 -0.2 0.2]);
  strt=sprintf("Direct-form FIR Hilbert filter (nbits=%d,ndigits=%d) : \
fapl=%g,fapu=%g,Wap=%g,Was=%g",nbits,ndigits,fapl,fapu,Wap,Was);
  title(strt);
  legend("exact","s-d","s-d(Ito)","s-d(BandB)");
  legend("location","southeast");
  legend("boxoff");
  legend("left");
  grid("on");
  print(strcat(strf,"_response"),"-dpdflatex");
  close

else
  printf("Did not find an improved solution!\n");
endif

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"M=%d %% Number of distinct coefficients\n",M);
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coefficient. update\n",tol);
fprintf(fid,"maxiter=%d %% iteration limit\n",maxiter);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);

print_polynomial(hM0,"hM0");
print_polynomial(hM0,"hM0",strcat(strf,"_hM0_coef.m"),"%12.8f");
print_polynomial(hM0_sd,"hM0_sd",nscale);
print_polynomial(hM0_sd,"hM0_sd",strcat(strf,"_hM0_sd_coef.m"),nscale);
print_polynomial(hM_sd,"hM_sd",nscale);
print_polynomial(hM_sd,"hM_sd",strcat(strf,"_hM_sd_coef.m"),nscale);
print_polynomial(hM_min,"hM_min",nscale);
print_polynomial(hM_min,"hM_min",strcat(strf,"_hM_min_coef.m"),nscale);

% Save results
save branch_bound_directFIRhilbert_12_nbits_test.mat ...
     hM0 hM0_sd hM_sd tol nbits ndigits fapl fapu Wap Was ...
     improved_solution_found hM_min
       
% Done
toc;
diary off
movefile branch_bound_directFIRhilbert_12_nbits_test.diary.tmp ...
         branch_bound_directFIRhilbert_12_nbits_test.diary;
