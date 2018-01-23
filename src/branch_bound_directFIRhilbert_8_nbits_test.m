% branch_bound_directFIRhilbert_8_nbits_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

% Branch-and-bound search of even-order direct-form hilbert bandpass filter
% response with 8-bit signed-digit coefficients

test_common;

unlink("branch_bound_directFIRhilbert_8_nbits_test.diary");
unlink("branch_bound_directFIRhilbert_8_nbits_test.diary.tmp");
diary branch_bound_directFIRhilbert_8_nbits_test.diary.tmp

tic;
maxiter=400
verbose=false
tol=1e-4
ctol=tol
strf="branch_bound_directFIRhilbert_8_nbits_test";

% Hilbert filter frequency specification
M=8;fapl=0.045;fapu=0.5-fapl;dBap=0.2;Wap=1;Was=0;
npoints=1000;
wa=(0:((npoints)-1))'*pi/(npoints);
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
Ad=ones(npoints,1);
Adu=(10^(dBap/40))*ones(npoints,1);
Adl=[zeros(napl-1,1); ...
     (10^(-dBap/40))*ones(napu-napl+1,1); ...
     zeros(npoints-napu,1)];
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

% MMSE solution
war=1:(npoints/2);
A0=directFIRhilbertA(wa,hM0);
vS=directFIRhilbert_slb_update_constraints(A0(war),Adu(war),Adl(war),ctol);
[hM1,socp_iter,func_iter,feasible]=directFIRhilbert_mmsePW ...
  (vS,hM0,hM0_active,[napl,(npoints/2)], ...
   wa(war),Ad(war),Adu(war),Adl(war),Wa(war),maxiter,tol,verbose);
hM1_active=find(hM1~=0);

% SLB solution
[hM2,slb_iter,socp_iter,func_iter,feasible]=directFIRhilbert_slb ...
  (@directFIRhilbert_mmsePW,hM1,hM0_active,[napl,(npoints/2)], ...
   wa(war),Ad(war),Adu(war),Adl(war),Wa(war),maxiter,tol,ctol,verbose);
if feasible==false
  error("directFIRhilbert_slb failed!");
endif

% Find the exact coefficient error
waf=wa([napl napu]);
Adf=1;
Waf=Wap;
Esq0=directFIRhilbertEsqPW(hM0,waf,Adf,Waf);
printf("Esq0=%g\n",Esq0);
Esq1=directFIRhilbertEsqPW(hM1,waf,Adf,Waf);
printf("Esq1=%g\n",Esq1);
Esq2=directFIRhilbertEsqPW(hM2,waf,Adf,Waf);
printf("Esq2=%g\n",Esq2);

% Scale the rounded coefficients to use all the bits 
nbits=8
nscale=2^(nbits-1)
ndigits=3

% Find the signed-digit approximations to hM2
hM2=hM2(:);
NhM=length(hM2);
[hM2_sd,hM2_sdu,hM2_sdl]=flt2SD(hM2,nbits,ndigits);

% Initialise hM2_active
hM2_sdul=hM2_sdu-hM2_sdl;
hM2_active=find(hM2_sdul~=0);
n_active=length(hM2_active);

% Check for consistent upper and lower bounds
if any(hM2_sdl>hM2_sdu)
  error("found hM2_sdl>hM2_sdu");
endif
if any(hM2_sdl>hM2_sdu)
  error("found hM2_sdl>hM2_sdu");
endif
if any(hM2_sd(hM2_active)>hM2_sdu(hM2_active))
  error("found hM2_sd(hM2_active)>hM2_sdu(hM2_active)");
endif
if any(hM2_sdl(hM2_active)>hM2_sd(hM2_active))
  error("found hM2_sdl(hM2_active)>hM2_sd(hM2_active)");
endif

% Find the number of signed-digits used by hM2_sd
[hM2_sd_digits,hM2_sd_adders]=SDadders(hM2_sd(hM2_active),nbits);
printf("hM2_sd uses %d signed-digits\n",hM2_sd_digits);
printf("hM2_sd uses %d %d-bit adders for coefficient multiplications\n",
       hM2_sd_adders,nbits);

% Define stack of current filter coefficients and tree depth
hM_stack=cell(1,n_active);
hM_b=hM2_sd;
hM_active=hM2_active;
hM_depth=0;
branch_tree=true;
n_branch=0;

% Find signed-digit error
Esq2_sd=directFIRhilbertEsqPW(hM2_sd,waf,Adf,Waf);
% Initialise the search.
improved_solution_found=false;
Esq_min=Esq2_sd;
hM_min=hM2_sd;
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
    [hM_sdul_max,hM_sdul_max_n]=max(hM2_sdul(hM_active));
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
    if hM_b(coef_n)==hM2_sdu(coef_n);
      hM_b(coef_n)=hM2_sdl(coef_n);
    else
      hM_b(coef_n)=hM2_sdu(coef_n);
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
  [hM_min_digits,hM_min_adders]=SDadders(hM_min(hM2_active)*nscale,nbits);
  printf("%d signed-digits used\n",hM_min_digits);
  printf("%d %d-bit adders used for coefficient multiplications\n", ...
         hM_min_adders,nbits);
  fname=strcat(strf,"_hM_min_adders.tab");
  fid=fopen(fname,"wt");
  fprintf(fid,"$%d$",hM_min_adders);
  fclose(fid);

  % Make a LaTeX table for cost
  fid=fopen(strcat(strf,"_cost.tab"),"wt");
  fprintf(fid,"Initial & %10.2e \\\\\n",Esq0);
  fprintf(fid,"MMSE & %10.2e \\\\\n",Esq1);
  fprintf(fid,"PCLS & %10.2e \\\\\n",Esq2);
  fprintf(fid,"%d-bit %d-signed-digit&%10.2e \\\\\n",nbits,ndigits,Esq2_sd);
  fprintf(fid,"%d-bit %d-signed-digit(branch-and-bound)&%10.2e \\\\\n",
          nbits,ndigits,Esq_min);
  fclose(fid);

  % Amplitude and delay at local peaks
  A=directFIRhilbertA(wa(war),hM_min);
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
  A_hM1=directFIRhilbertA(wplot,hM1);
  A_hM2=directFIRhilbertA(wplot,hM2);
  A_hM2_sd=directFIRhilbertA(wplot,hM2_sd);
  A_hM_min=directFIRhilbertA(wplot,hM_min);

  % Plot amplitude response
  plot(wplot*0.5/pi,20*log10(abs(A_hM0)),"linestyle","-", ...
       wplot*0.5/pi,20*log10(abs(A_hM1)),"linestyle",":", ...
       wplot*0.5/pi,20*log10(abs(A_hM2)),"linestyle","-.", ...
       wplot*0.5/pi,20*log10(abs(A_hM2_sd)),"linestyle","--", ...
       wplot*0.5/pi,20*log10(abs(A_hM_min)),"linestyle","-");
  xlabel("Frequency");
  ylabel("Amplitude(dB)");
  axis([0 0.25 -0.2 0.2]);
  strt=sprintf("Direct-form FIR Hilbert filter (nbits=%d,ndigits=%d) : \
fapl=%g,fapu=%g,dBap=%g,Wap=%g,Was=%g",nbits,ndigits,fapl,fapu,dBap,Wap,Was);
  title(strt);
  legend("initial","mmse","pcls","s-d","s-d(BandB)");
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
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coefficient. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"maxiter=%d %% iteration limit\n",maxiter);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple(dB)\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);

print_polynomial(hM0,"hM0");
print_polynomial(hM0,"hM0",strcat(strf,"_hM0_coef.m"),"%12.8f");
print_polynomial(hM1,"hM1");
print_polynomial(hM1,"hM1",strcat(strf,"_hM1_coef.m"),"%12.8f");
print_polynomial(hM2,"hM2");
print_polynomial(hM2,"hM2",strcat(strf,"_hM2_coef.m"),"12.8f");
print_polynomial(hM2_sd,"hM2_sd",nscale);
print_polynomial(hM2_sd,"hM2_sd",strcat(strf,"_hM2_sd_coef.m"),nscale);
print_polynomial(hM_min,"hM_min",nscale);
print_polynomial(hM_min,"hM_min",strcat(strf,"_hM_min_coef.m"),nscale);

% Save results
save branch_bound_directFIRhilbert_8_nbits_test.mat ...
     hM0 hM1 hM2 hM2_sd tol ctol nbits ndigits fapl fapu dBap Wap Was ...
     improved_solution_found hM_min
       
% Done
toc;
diary off
movefile branch_bound_directFIRhilbert_8_nbits_test.diary.tmp ...
         branch_bound_directFIRhilbert_8_nbits_test.diary;
