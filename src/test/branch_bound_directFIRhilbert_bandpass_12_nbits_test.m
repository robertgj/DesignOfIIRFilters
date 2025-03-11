% branch_bound_directFIRhilbert_bandpass_12_nbits_test.m
% Copyright (C) 2019-2025 Robert G. Jenssen

% Branch-and-bound search of a direct-form Hilbert bandpass filter
% with 12-bit 2-signed-digit coefficients

test_common;

strf="branch_bound_directFIRhilbert_bandpass_12_nbits_test";

delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));

% Options
branch_bound_directFIRhilbert_bandpass_12_nbits_test_use_unity_passband=false
branch_bound_directFIRhilbert_bandpass_12_nbits_test_use_coef_escale=false

tic;
maxiter=400
verbose=false
tol=1e-4

% Hilbert band-pass filter from directFIRhilbert_bandpass_slb_test.m
directFIRhilbert_bandpass_slb_test_hM2_coef;

% Hilbert filter frequency specification
fasl=0.1;fapl=0.16325;Wap=2;Wat=0;Was=1;
fapu=0.5-fapl;fasu=0.5-fasl;
dBap=0.1;
if branch_bound_directFIRhilbert_bandpass_12_nbits_test_use_unity_passband
  Ad_passband=-1;
else
  Ad_passband=-(10^(-dBap/40));
endif
npoints=5000;
wa=(0:((npoints)-1))'*pi/(npoints);
nasl=ceil(npoints*fasl/0.5)+1;
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
nasu=floor(npoints*fasu/0.5)+1;
% Sanity check
nch=[1,nasl-1,nasl,nasl+1,napl-1,napl,napl+1, ...
      napu-1,napu,napu+1,nasu-1,nasu,nasu+1,npoints];
printf("fa=[ ");printf("%d ",wa(nch)*0.5/pi);printf("]\n");

% Find the exact coefficient error
waf=2*pi*[0 fasl fapl fapu fasu 0.5];
Adf=[0 0 Ad_passband 0 0];
Waf=[Was Wat Wap Wat Was];
Esq2=directFIRhilbertEsqPW(hM2,waf,Adf,Waf);
printf("Esq1=%g\n",Esq2);

% Scale the rounded coefficients to use all the bits 
nbits=12
ndigits=2
nscale=2^(nbits-1)
hM2_rd=round(hM2*nscale)/nscale;
if branch_bound_directFIRhilbert_bandpass_12_nbits_test_use_coef_escale
  escale=ceil(log2(1/max(abs(hM2_rd))));
else
  escale=1;
endif
enscale=escale*nscale;

% Find the signed-digit approximations to hM2
hM2_sd=flt2SD(hM2(:)*escale,nbits,ndigits);
Esq2_sd=directFIRhilbertEsqPW(hM2_sd/escale,waf,Adf,Waf);
% Find the number of signed-digits used by hM2_sd
hM2_active=find(hM2~=0);
[hM2_sd_digits,hM2_sd_adders]=SDadders(hM2_sd(hM2_active),nbits);
printf("hM2_sd uses %d signed-digits\n",hM2_sd_digits);
printf("hM2_sd uses %d %d-bit adders for coefficient multiplications\n", ...
       hM2_sd_adders,nbits);

% Allocate signed digits with the heuristic of Ito et al.
ndigits_Ito=directFIRhilbert_allocsd_Ito(nbits,ndigits,hM2,waf,Adf,Waf);
print_polynomial(ndigits_Ito,"ndigits_Ito");
hM_allocsd_digits=int16(ndigits_Ito);
printf("hM_allocsd_digits=[ ");
printf("%2d ",hM_allocsd_digits);printf("]';\n");
print_polynomial(hM_allocsd_digits,"hM_allocsd_digits", ...
                 strcat(strf,"_hM_allocsd_digits.m"),"%2d");

% Find the signed-digit coefficients
[hM_sd,hM_sdu,hM_sdl]=flt2SD(hM2(:)*escale,nbits,ndigits_Ito);
% Find signed-digit error
Esq_sd=directFIRhilbertEsqPW(hM_sd/escale,waf,Adf,Waf);
% Find the number of signed-digits used by hM_sd
[hM_sd_digits,hM_sd_adders]=SDadders(hM_sd,nbits);
printf("hM_sd uses %d signed-digits\n",hM_sd_digits);
printf("hM_sd uses %d %d-bit adders for coefficient multiplications\n", ...
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
  printf("hM_b=[ ");printf("%g ",nscale*hM_b');printf("]'/%d;\n",enscale);

  % Find the error for the current sub-problem
  Esq=directFIRhilbertEsqPW(hM_b/escale,waf,Adf,Waf);
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
  error("Did not find an improved solution over hM_sd!\n");
endif

printf("\nBest new solution:\nEsq_min=%g\n",Esq_min);
print_polynomial(hM_min/escale,"hM_min",enscale);
print_polynomial(hM_min/escale,"hM_min",strcat(strf,"_hM_min_coef.m"),enscale);
% Find the number of signed-digits and adders used
[hM_min_digits,hM_min_adders]=SDadders(hM_min(hM2_active),nbits);
printf("%d signed-digits used\n",hM_min_digits);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       hM_min_adders,nbits);
fname=strcat(strf,"_hM_min_adders.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",hM_min_adders);
fclose(fid);

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %10.2e & & \\\\\n",Esq2);
fprintf(fid,"%d-bit %d-signed-digit & %10.2e & %d & %d \\\\\n", ...
        nbits,ndigits,Esq2_sd,hM2_sd_digits,hM2_sd_adders);  
fprintf(fid,"%d-bit %d-signed-digit(Ito) & %10.2e & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_sd,hM_sd_digits,hM_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(branch-and-bound)&%10.2e & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_min,hM_min_digits,hM_min_adders);
fclose(fid);

% Amplitude at local peaks
A=directFIRhilbertA(wa,hM_min/escale);
vAl=local_max(-A);
vAu=local_max(A);
wAS=unique([wa(vAl);wa(vAu);wa([nasl,napl])]);
AS=directFIRhilbertA(wAS,hM_min/escale);
wAS=wAS(find(abs(AS)>0));
AS=AS(find(abs(AS)>0));
printf("hM_min:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("hM_min:AS=[ ");printf("%f ",20*log10(abs(AS)'));printf(" ] (dB)\n");

% Calculate response
nplot=2048;
wplot=(0:(nplot-1))'*pi/nplot;
A_hM2=directFIRhilbertA(wplot,hM2);
A_hM2_sd=directFIRhilbertA(wplot,hM2_sd/escale);
A_hM_sd=directFIRhilbertA(wplot,hM_sd/escale);
A_hM_min=directFIRhilbertA(wplot,hM_min/escale);

% Plot amplitude response
subplot(211);
plot(wplot*0.5/pi,20*log10(abs(A_hM2)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(A_hM2_sd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(A_hM_sd)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(A_hM_min)),"linestyle","-.");
ylabel("Amplitude(dB)");
axis([0.15 0.25 -0.2 0.2]);
strt=sprintf(["Direct-form FIR Hilbert bandpass filter (nbits=%d,ndigits=%d) : ", ...
 "fasl=%g,fapl=%g,Wap=%g,Was=%g"],nbits,ndigits,fasl,fapl,Wap,Was);
title(strt);
grid("on");
subplot(212);
plot(wplot*0.5/pi,20*log10(abs(A_hM2)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(A_hM2_sd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(A_hM_sd)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(A_hM_min)),"linestyle","-.");
legend("exact","s-d","s-d(Ito)","s-d(BandB)");
legend("location","southeast");
legend("boxoff");
legend("left");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.15 -50 -20]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"M=%d %% Number of distinct coefficients\n",length(hM2));
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coefficient. update\n",tol);
fprintf(fid,"maxiter=%d %% iteration limit\n",maxiter);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);

print_polynomial(hM2,"hM2");
print_polynomial(hM2,"hM2",strcat(strf,"_hM2_coef.m"),"%12.8f");
print_polynomial(hM2_sd/escale,"hM2_sd",enscale);
print_polynomial(hM2_sd/escale,"hM2_sd",strcat(strf,"_hM2_sd_coef.m"),enscale);
print_polynomial(hM_sd/escale,"hM_sd",enscale);
print_polynomial(hM_sd/escale,"hM_sd",strcat(strf,"_hM_sd_coef.m"),enscale);
print_polynomial(hM_min/escale,"hM_min",enscale);
print_polynomial(hM_min/escale,"hM_min",strcat(strf,"_hM_min_coef.m"),enscale);

% Save results
eval(sprintf(["save %s.mat ", ...
 "hM2 hM2_sd hM_sd tol nbits ndigits escale fapl fapu Wap Was ", ...
 "improved_solution_found hM_min ", ...
 "branch_bound_directFIRhilbert_bandpass_12_nbits_test_use_unity_passband ", ...
 "branch_bound_directFIRhilbert_bandpass_12_nbits_test_use_coef_escale"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
