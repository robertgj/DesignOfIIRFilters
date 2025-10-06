% branch_bound_directFIRantisymmetric_lowpass_differentiator_12_nbits_test.m
% Copyright (C) 2025 Robert G. Jenssen

% Optimisation of a direct-form lowpass differentiator FIR filter
% response with 12-bit signed-digit coefficients and SOCP relaxation solution.

test_common;

strf="branch_bound_directFIRantisymmetric_lowpass_differentiator_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=5000
verbose=false;
tol=1e-5;
ctol=tol;

nbits=13;
nscale=2^(nbits-1);
ndigits=3;

% Found by trial and error to give 16 distinct integer coefficients
M=16;Q=31;L=20;K=21;N=K+(2*L)+2;
h0=selesnickFIRantisymmetric_linear_differentiator(N,K)/2;
hM0=h0((Q-M+1):Q);
print_polynomial(h0(1:Q),"h0");
print_polynomial(h0(1:Q),"h0",strcat(strf,"_h0_coef.m"),"%15.8e");
print_polynomial(hM0,"hM0");
print_polynomial(hM0,"hM0",strcat(strf,"_hM0_coef.m"));

% Response constraints
fap=0.2;fas=0.4;Arp=0;Art=0;Ars=0;Wap=10;Wat=0.01;Was=0.1;

% Desired magnitude response
npoints=1000;
wa=(0:(npoints-1))'*pi/npoints;
nap=ceil(npoints*fap/0.5)+1;
nas=floor(npoints*fas/0.5)+1;  
Ad=[wa(1:nap)/2; zeros(npoints-nap,1)];
Adu=[wa(1:(nas-1))/2;zeros(npoints-nas+1,1)] + ...
    [(Arp/2)*ones(nap,1); ...
     (Art/2)*ones(nas-nap-1,1); ...
     (Ars/2)*ones(npoints-nas+1,1)];
Adl=Ad - ...
    [(Arp/2)*ones(nap,1); ...
     (Art/2)*ones(nas-nap-1,1); ...
     (Ars/2)*ones(npoints-nas+1,1)];
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(npoints-nas+1,1)];
% Sanity check
nchk=[1,2,nap-1,nap,nap+1,nas-1,nas,nas+1,npoints-1];
printf("nchk=[");printf("%d ",nchk);printf(" ]\n");
printf("wa(nchk)*0.5/pi=[");printf("%g ",wa(nchk)*0.5/pi);printf(" ]\n");
printf("Ad(nchk)=[");printf("%g ",Ad(nchk));printf(" ]\n");
printf("Adu(nchk)=[");printf("%g ",Adu(nchk));printf(" ]\n");
printf("Adl(nchk)=[");printf("%g ",Adl(nchk));printf(" ]\n");
printf("Wa(nchk)=[");printf("%g ",Wa(nchk));printf(" ]\n");

%
% Signed-digit coefficients with no allocation
%
% Find the signed-digit approximations to hM0 without allocation
hM0_sd_no_alloc=flt2SD(hM0,nbits,ndigits);
[hM0_sd_no_alloc_digits,hM0_sd_no_alloc_adders] = ...
  SDadders(hM0_sd_no_alloc(find(hM0_sd_no_alloc~=0)),nbits);
print_polynomial(hM0_sd_no_alloc,"hM0_sd_no_alloc",nscale);
print_polynomial(hM0_sd_no_alloc,"hM0_sd_no_alloc", ...
                 strcat(strf,"_hM0_sd_no_alloc_coef.m"),nscale);

% Find the signed-digit approximations to hM0 with Lim allocation
hM0_allocsd_digits=directFIRantisymmetric_allocsd_Lim ...
                    (nbits,ndigits,hM0,wa,Ad,Wa);
print_polynomial(hM0_allocsd_digits,"hM0_allocsd_digits","%2d");
print_polynomial(hM0_allocsd_digits,"hM0_allocsd_digits", ...
                 strcat(strf,"_hM0_allocsd_digits.m"),"%2d");
[hM0_sd,hM0_sdu,hM0_sdl]=flt2SD(hM0,nbits,hM0_allocsd_digits);
hM0_sdul=hM0_sdu-hM0_sdl;
hM0_active=find(hM0_sdul~=0);
[hM0_sd_digits,hM0_sd_adders]=SDadders(hM0_sd,nbits);
print_polynomial(hM0_sd,"hM0_sd",nscale);
print_polynomial(hM0_sd,"hM0_sd",strcat(strf,"_hM0_sd_coef.m"),nscale);

% Find initial mean-squared errrors
EsqN0=directFIRantisymmetricEsq(h0(1:Q),wa,Ad,Wa);
EsqM0=directFIRantisymmetricEsq(hM0,wa,Ad,Wa);
EsqM0_sd_no_alloc=directFIRantisymmetricEsq(hM0_sd_no_alloc,wa,Ad,Wa);
EsqM0_sd=directFIRantisymmetricEsq(hM0_sd,wa,Ad,Wa);

% Define stack of current filter coefficients and tree depth
n_active=length(hM0_active);
hM_stack=cell(1,n_active);
hM_b=zeros(size(hM0));
hM_b(hM0_active)=hM0(hM0_active);
hM_bu=10*ones(size(hM0));
hM_bl=-hM_bu;
hM_active=hM0_active;
hM_depth=0;
branch_tree=true;
n_branch=0;
% Initialise the search.
improved_solution_found=false;
EsqM_min=EsqM0_sd;
hM_min=hM0_sd;
printf("Initial EsqM_min=%g\n",EsqM_min);
printf("Initial hM_active=[ ");printf("%d ",hM_active);printf("];\n");
printf("Initial hM_b=[ ");printf("%g ",hM_b');printf("]';\n");

% At each node of a branch, define two SQP sub-problems, one of which is
% stacked and one of which is solved immediately. If the solved problem
% reduces EsqM_min, then continue to the next node on that branch. If the
% solved problem does not improve EsqM_min then give up on this branch and
% continue by solving the problem on top of the stack.
do
  % Choose the sub-problem to solve
  if branch_tree  
    n_branch=n_branch+1;
    [hM_sd,hM_sdu,hM_sdl]=flt2SD(hM_b,nbits,ndigits);
    % Ito et al. suggest ordering the tree branches by max(hM_sdu-hM_sdl)
    hM_sdul=hM_sdu-hM_sdl;
    if any(hM_sdul<0)
      error("any(hM_sdul<0)");
    endif
    [hM_max,hM_max_n]=max(hM_sdul(hM_active));
    coef_n=hM_active(hM_max_n);
    hM_active(hM_max_n)=[];  
    hM_b(coef_n)=hM_sdl(coef_n); 
    % Push a problem onto the stack
    hM_depth=hM_depth+1;
    if hM_depth>n_active
      error("hM_depth(%d)>n_active(%d)",hM_depth,n_active);
    endif
    printf("\nBranch:coef_n=%d,",coef_n);
    hM_problem.hM_b=hM_b;
    hM_problem.hM_active=hM_active;
    hM_stack{hM_depth}=hM_problem;
    % Set up current problem
    hM_b(coef_n)=hM_sdu(coef_n);
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
  printf("hM_b=[ ");printf("%g ",nscale*hM_b');printf("]'/nscale;\n");

  % Update the active coefficients
  if ~isempty(hM_active)
    % Check bound on Esq 
    EsqM=directFIRantisymmetricEsq(hM_b,wa,Ad,Wa);
    printf("Found EsqM=%g\n",EsqM); 
    if EsqM<EsqM_min
      branch_tree=true;
    else
      branch_tree=false;
    endif
  endif
    
  % At maximum depth there are no active coefficients
  if isempty(hM_active)
    % Update EsqM_min
    branch_tree=false;
    EsqM=directFIRantisymmetricEsq(hM_b,wa,Ad,Wa);
    printf("At maximum depth EsqM=%g\n",EsqM);
    % Update the best solution
    if EsqM<EsqM_min
      improved_solution_found=true;
      EsqM_min=EsqM;
      hM_min=hM_b;
      printf("Improved solution: hM_depth=%d, EsqM_min=%g\n",hM_depth,EsqM_min);
      print_polynomial(hM_min,"hM_min",nscale);
    endif
  endif

% Exit the loop when there are no sub-problems left
until (isempty(hM_active) || (branch_tree==false)) && (hM_depth==0)
printf("Branch-and-bound search completed with %d branches\n",n_branch);

% Show results
if ~improved_solution_found
  hM_min=hM0_sd;
  warning("Did not find an improved solution!\n");
endif
printf("\nBest new solution:\nEsqM_min=%g\n",EsqM_min);

print_polynomial(hM_min,"hM_min",nscale);
print_polynomial(hM_min,"hM_min",strcat(strf,"_hM_min_coef.m"),nscale);
EsqM_min=directFIRantisymmetricEsq(hM_min,wa,Ad,Wa);
printf("\nSolution:\nEsqM_min=%g\n",EsqM_min);

% Find the number of signed-digits and adders used
[hM_min_digits,hM_min_adders]=SDadders(hM_min,nbits);
printf("%d signed-digits used\n",hM_min_digits);
fid=fopen(strcat(strf,"_hM_min_signed_digits.m"),"wt");
fprintf(fid,"%d",hM_min_digits);
fclose(fid);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       hM_min_adders,nbits);
fid=fopen(strcat(strf,"_hM_min_adders.m"),"wt");
fprintf(fid,"%d",hM_min_adders);
fclose(fid);

% Amplitude and delay at local peaks
A=directFIRantisymmetricA(wa,hM_min);
vAl=local_max(Adl-A);
vAu=local_max(A-Adu);
wAS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AS=directFIRantisymmetricA(wAS,hM_min);
printf("hM_min:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("hM_min:AS=[ ");printf("%f ",AS');printf(" ]\n");

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Floating-point(%d) & %10.4e & & \\\\\n",Q,EsqN0);
fprintf(fid,"Floating-point(%d) & %10.4e & & \\\\\n",M,EsqM0);
fprintf(fid,"%d-bit %d-signed-digit & %10.4e & %d & %d \\\\\n", ...
        nbits,ndigits,EsqM0_sd_no_alloc,hM0_sd_no_alloc_digits, ...
        hM0_sd_no_alloc_adders);
fprintf(fid,"%d-bit %d-signed-digit(Lim)&%10.4e & %d & %d \\\\\n", ...
        nbits,ndigits,EsqM0_sd,hM0_sd_digits,hM0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %10.4e & %d & %d \\\\\n", ...
        nbits,ndigits,EsqM_min,hM_min_digits,hM_min_adders);
fclose(fid);

% Calculate response
A_h0=directFIRantisymmetricA(wa,h0(1:Q));
A_hM0=directFIRantisymmetricA(wa,hM0);
A_hM0_sd_no_alloc=directFIRantisymmetricA(wa,hM0_sd_no_alloc);
A_hM0_sd=directFIRantisymmetricA(wa,hM0_sd);
A_hM_min=directFIRantisymmetricA(wa,hM_min);

% Plot amplitude response
Rap=1:nap;
Ras=nas:length(wa);
A_all=[A_h0,A_hM0,A_hM0_sd_no_alloc,A_hM_min];
[ax,ha,hs] = plotyy(wa(Rap)*0.5/pi,A_all(Rap,:)-Ad(Rap), ...
                    wa(Ras)*0.5/pi,A_all(Ras,:));
% Copy line colour
hac=get(ha,"color");
hls={"-",":","--","-."};
for c=1:columns(A_all)
  set(hs(c),"color",hac{c});
  set(ha(c),"linestyle",hls{c});
  set(hs(c),"linestyle",hls{c});
endfor
set(ax(1),"ycolor","black");
set(ax(2),"ycolor","black");
axis(ax(1),[0 0.5 0.003*[-1,1]]);
axis(ax(2),[0 0.5 0.003*[-1,1]]);
ylabel("Amplitude error");
xlabel("Frequency");
strt=sprintf(["Direct-form anti-symmetric low-pass differentiator filter", ...
              " : fap=%g,fas=%g"],fap,fas);
title(strt);
legend(sprintf("F-P(%d)",Q),sprintf("F-P(%d)",M),"S-D","S-D(Lim,B-and-B)");
legend("location","south");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_amplitude_response"),"-dpdflatex");
close

% Plot pass band relative amplitude response
ha=plot(wa(Rap)*0.5/pi,(A_all(Rap,:)./Ad(Rap))-1);
% Set line style
hls={"-",":","--","-."};
for c=1:columns(A_all)
  set(ha(c),"linestyle",hls{c});
endfor
axis([0 fap -0.02 0.01]);
grid("on");
ylabel("Relative amplitude error");
xlabel("Frequency");
title(strt);
legend(sprintf("F-P(%d)",Q),sprintf("F-P(%d)",M),"S-D","S-D(Lim,B-and-B)");
legend("location","southeast");
legend("boxoff");
legend("left");
print(strcat(strf,"_pass_relative_amplitude_response"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"N=%d %% Length of the Selesnick differentiator filter\n",N);
fprintf(fid,"K=%d %% K value of the Selesnick differentiator\n",K);
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"maxiter=%d %% SOCP iteration limit\n",maxiter);
fprintf(fid,"npoints=%d %% Frequency points across the band\n",npoints);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"Arp=%d %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Art=%d %% Amplitude transition band peak-to-peak ripple\n",Art);
fprintf(fid,"Wat=%d %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Ars=%d %% Amplitude stop band peak-to-peak ripple\n",Ars);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);

% Save results
eval(sprintf(["save %s.mat tol ctol nbits nscale ndigits N K ", ...
              "npoints hM0 fap Arp Wap Art Wat fas Ars Was hM_min"],strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
