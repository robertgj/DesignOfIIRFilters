% branch_bound_schurOneMlattice_bandpass_10_nbits_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

% Branch-and-bound search of Schur one-multiplier lattice bandpass filter
% response with 10-bit signed-digit coefficients and Ito et al. allocation

test_common;

delete("branch_bound_schurOneMlattice_bandpass_10_nbits_test.diary");
delete("branch_bound_schurOneMlattice_bandpass_10_nbits_test.diary.tmp");
diary branch_bound_schurOneMlattice_bandpass_10_nbits_test.diary.tmp

% Options
use_best_branch_and_bound_found=true
if use_best_branch_and_bound_found
  warning("Reporting the best branch-and-bound filter found so far. \n\
           Set \"use_best_branch_and_bound_found\"=false to re-run.");
endif
enforce_pcls_constraints_on_final_filter=false

tic;

maxiter=1000
verbose=false;

dBass=33
tpr=0.4
schurOneMlattice_bandpass_10_nbits_common;

strf="branch_bound_schurOneMlattice_bandpass_10_nbits_test";

% Scale the rounded c0 to use all the bits 
c0_rd=round(c0*nscale)/nscale;
c0_rd_range=ceil(-log2(min(abs(c0_rd(find(c0_rd~=0))))/max(abs(c0_rd))));
printf("c0 rounded to %d bits has range %d bits\n",nbits,c0_rd_range);
if exist('cscale','var')~=1
  if (nbits-c0_rd_range-1)<=0
    cscale=1
  else
    cscale=2^(nbits-c0_rd_range-1)
  endif
endif
cnscale=cscale*nscale;

% Scale the signed-digit representation
kc0=[k0;c0*cscale];
[kc0_sd,kc0_sdu,kc0_sdl]=flt2SD(kc0,nbits,ndigits_alloc);
k0_sd=kc0_sd(1:Nk);
k0_sd=k0_sd(:);
c0_sd=kc0_sd((Nk+1):end)/cscale;
c0_sd=c0_sd(:);
% Initialise kc_active
kc0_sdul=kc0_sdu-kc0_sdl;
kc0_active=find(kc0_sdul~=0);
n_active=length(kc0_active);
% Find kc0_sd error
Esq0_sd=schurOneMlatticeEsq(k0_sd,epsilon0,p0,c0_sd,wa,Asqd,Wa,wt,Td,Wt);

% Define stack of current filter coefficients and tree depth
kc_stack=cell(1,n_active);
kc_b=zeros(size(kc0));
kc_b(kc0_active)=kc0(kc0_active);
kc_bl=kc0_l;
kc_bu=kc0_u;
kc_active=kc0_active;
kc_depth=0;
branch_tree=true;
n_branch=0;
% Initialise the search.
improved_solution_found=false;
Esq_min=Esq0_sd;
k_min=k0_sd;
c_min=c0_sd;
printf("Initial Esq_min=%g\n",Esq_min);
printf("Initial kc_active=[ ");printf("%d ",kc_active);printf("];\n");
printf("Initial kc_b=[ ");printf("%g ",kc_b');printf("]';\n");
k_allocsd_digits=int16(ndigits_alloc(1:Nk));
printf("k_allocsd_digits=[ ");printf("%2d ",k_allocsd_digits);printf("]';\n");
c_allocsd_digits=int16(ndigits_alloc((Nk+1):end));
printf("c_allocsd_digits=[ ");printf("%2d ",c_allocsd_digits);printf("]';\n");

if use_best_branch_and_bound_found
  k_min = [        0,      344,        0,      256, ... 
                   0,      184,        0,      212, ... 
                   0,      156,        0,      128, ... 
                   0,       80,        0,       52, ... 
                   0,       19,        0,        7 ]'/nscale;
  c_min = [       69,      -16,     -304,     -480, ... 
                -156,      128,      400,      304, ... 
                  16,      -84,      -80,      -16, ... 
                  -8,      -33,      -24,        4, ... 
                  24,       16,        3,        1, ... 
                   4 ]'/cnscale;
  branches_min=832; % 982 seconds
  kc_min=[k_min(:);c_min(:)*cscale];
  Esq_min=schurOneMlatticeEsq(k_min,epsilon0,p0,c_min,wa,Asqd,Wa,wt,Td,Wt);
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
      [kc_sd,kc_sdu,kc_sdl]=flt2SD(kc_b,nbits,ndigits_alloc);
      if 1
        % Ito et al. suggest ordering the tree branches by max(kc_sdu-kc_sdl)
        kc_sdul=kc_sdu-kc_sdl;
        if any(kc_sdul<0)
          error("any(kc_sdul<0)");
        endif
        [kc_max,kc_max_n]=max(kc_sdul(kc_active));
      else
        % Use the active coefficient with the largest absolute gradient of Esq
        % This method did not find an improved solution despite running the
        % MMSE case for several hours without completing.
        [Esq,gradEsq]=schurOneMlatticeEsq ...
                        (kc_b(1:Nk),epsilon0,p0,kc_b((Nk+1):end)/cscale, ...
                         wa,Asqd,Wa,wt,Td,Wt);
        [kc_max,kc_max_n]=max(abs(gradEsq(kc_active)));
      endif
      coef_n=kc_active(kc_max_n);
      kc_active(kc_max_n)=[];  
      kc_b(coef_n)=kc_sdl(coef_n); 
      % Push a problem onto the stack
      kc_depth=kc_depth+1;
      if kc_depth>n_active
        error("kc_depth(%d)>n_active(%d)",kc_depth,n_active);
      endif
      printf("\nBranch:coef_n=%d,",coef_n);
      kc_problem.kc_b=kc_b;
      kc_problem.kc_active=kc_active;
      kc_stack{kc_depth}=kc_problem;
      % Set up current problem
      kc_b(coef_n)=kc_sdu(coef_n);
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
    printf("kc_b=[ ");printf("%g ",nscale*kc_b');printf("]'/nscale;\n");

    % Try to solve the current sub-problem
    try  
      % Find the SQP PCLS solution for the remaining active coefficents
      [nextk,nextc,slb_iter,opt_iter,func_iter,feasible] = ...
      schurOneMlattice_slb(@schurOneMlattice_sqp_mmse, ...
                           kc_b(1:Nk),epsilon0,p0,kc_b((Nk+1):end)/cscale, ...
                           kc_bu,kc_bl,kc_active,dmax, ...
                           wa,Asqd,Asqdu,Asqdl,Wa, ...
                           wt,Td,Tdu,Tdl,Wt, ...
                           wp,Pd,Pdu,Pdl,Wp, ...
                           maxiter,tol,ctol,verbose);
   catch
      feasible=false;
      warning("Branch and bound SQP failed!\n");
      err=lasterror();
      fprintf(stderr,"%s\n", err.message);
      for e=1:length(err.stack)
        fprintf(stderr,"Called %s at line %d\n", ...
                err.stack(e).name,err.stack(e).line);
      endfor
    end_try_catch

    % If this problem was not solved then pop a new sub-problem off the stack 
    if ~feasible
      branch_tree=false;
    endif
      
    % Update the active coefficients
    if feasible && ~isempty(kc_active)
      % Update kc_b
      nextkc=[nextk(:);nextc(:)*cscale];
      kc_b(kc_active)=nextkc(kc_active);
      % Check bound on Esq 
      Esq=schurOneMlatticeEsq(nextk,epsilon0,p0,nextc,wa,Asqd,Wa,wt,Td,Wt);
      printf("Found Esq=%g\n",Esq); 
      if Esq<Esq_min
        branch_tree=true;
      else
        branch_tree=false;
      endif
    endif
    
    % At maximum depth there are no active coefficients
    if feasible && isempty(kc_active)
      % Update Esq_min
      branch_tree=false;
      k_b=kc_b(1:Nk);
      c_b=kc_b((Nk+1):end)/cscale;
      Esq=schurOneMlatticeEsq(k_b,epsilon0,p0,c_b,wa,Asqd,Wa,wt,Td,Wt);
      printf("At maximum depth Esq=%g\n",Esq);  
      % Check constraints
      if enforce_pcls_constraints_on_final_filter
        Asq=schurOneMlatticeAsq(wa,k_b,epsilon0,p0,c_b);
        T=schurOneMlatticeT(wt,k_b,epsilon0,p0,c_b);
        vS=schurOneMlattice_slb_update_constraints ...
             (Asq,Asqdu,Asqdl,Wa,T,Tdu,Tdl,Wt,[],[],[],[],ctol);
        if ~schurOneMlattice_slb_constraints_are_empty(vS)
          printf("At maximum depth constraints are not empty!\n");
          schurOneMlattice_slb_show_constraints(vS);
        endif
      else
        vS=schurOneMlattice_slb_set_empty_constraints();
      endif
      % Update the best solution
      if Esq<Esq_min && schurOneMlattice_slb_constraints_are_empty(vS)
        improved_solution_found=true;
        Esq_min=Esq;
        kc_min=kc_b;
        k_min=k_b;
        c_min=c_b;
        printf("Improved solution: kc_depth=%d, Esq_min=%g\n",kc_depth,Esq_min);
        print_polynomial(k_min,"k_min",nscale);
        print_polynomial(c_min,"c_min",cnscale);
      endif
    endif

  % Exit the loop when there are no sub-problems left
  until (isempty(kc_active)||(branch_tree==false)) && (kc_depth==0)
  printf("Branch-and-bound search completed with %d branches\n",n_branch);
endif

% Show results
if ~improved_solution_found
  error("Did not find an improved solution!\n");
endif
printf("\nBest new solution:\nEsq_min=%g\n",Esq_min);
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
printf("epsilon0=[ ");printf("%d ",epsilon0');printf("]';\n");
printf("p0=[ ");printf("%g ",p0');printf("]';\n");
print_polynomial(c_min,"c_min",cnscale);
print_polynomial(c_min,"c_min",strcat(strf,"_c_min_coef.m"),cnscale);
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits_Ito.m"),"%2d");
print_polynomial(c_allocsd_digits,"c_allocsd_digits", ...
                 strcat(strf,"_c_allocsd_digits_Ito.m"),"%2d");

% Find the number of signed-digits used
[kc_digits,kc_adders]=SDadders(kc_min(kc0_active),nbits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kc_adders,nbits);
printf("%d signed-digits used\n",kc_digits);

% Filter a quantised noise signal and check the state variables
nsamples=2^12;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u); 
u=round(u*nscale);
[yap,y,xx]=schurOneMlatticeFilter(k0,epsilon0,p0,c0,u,"round");
stdx=std(xx)
[yapf,yf,xxf]= ...
  schurOneMlatticeFilter(k_min,epsilon0,ones(size(k0)),c_min,u,"round");
stdxf=std(xxf)

% Amplitude and delay at local peaks
Asq=schurOneMlatticeAsq(wa,k_min,epsilon0,p0,c_min);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=schurOneMlatticeAsq(wAsqS,k_min,epsilon0,p0,c_min);
printf("k,c_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMlatticeT(wt,k_min,epsilon0,p0,c_min);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMlatticeT(wTS,k_min,epsilon0,p0,c_min);
printf("k,c_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %6.4f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(Ito)&%6.4f & %d & %d \\\\\n",
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
axis([0 0.5 -50 -30]);
strt=sprintf("Schur one-multiplier lattice bandpass filter stop-band \
(nbits=%d) : fasl=%g,fasu=%g,dBas=%g",nbits,fasl,fasu,dBas);
title(strt);
legend("exact","s-d(Ito)","s-d(BandB)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot amplitude pass-band response
plot(wplot*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc0_sd)),"linestyle","--", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0.1 0.2 -2 1]);
strt=sprintf("Schur one-multiplier lattice bandpass filter pass-band \
(nbits=%d) : fapl=%g,fapu=%g,dBap=%g",nbits,fapl,fapu,dBap);
title(strt);
legend("exact","s-d(Ito)","s-d(BandB)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_pass"),"-dpdflatex");
close

% Plot group-delay pass-band response
plot(wplot*0.5/pi,T_kc0,"linestyle","-", ...
     wplot*0.5/pi,T_kc0_sd,"linestyle","--", ...
     wplot*0.5/pi,T_kc_min,"linestyle","-.");
xlabel("Frequency");
ylabel("Group delay(samples)");
axis([0.09 0.21 15.9 16.2]);
strt=sprintf("Schur one-multiplier lattice bandpass filter pass-band \
(nbits=%d) : ftpl=%g,ftpu=%g,tp=%g,tpr=%g",nbits,ftpl,ftpu,tp,tpr);
title(strt);
legend("exact","s-d(Ito)","s-d(BandB)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coefficient update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"maxiter=%d %% SQP iteration limit\n",maxiter);
fprintf(fid,"npoints=%g %% Frequency points across the band\n",npoints);
fprintf(fid,"length(c0)=%d %% Num. tap coefficients\n",length(c0));
fprintf(fid,"sum(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",sum(k0~=0));
fprintf(fid,"dmax=%f %% Constraint on norm of coefficient SQP step size\n",dmax);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal passband filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBas=%d %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%d %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Amplitude upper stop band weight\n",Wasu);
fclose(fid);

% Save results
save branch_bound_schurOneMlattice_bandpass_10_nbits_test.mat ...
     use_best_branch_and_bound_found ...
     k0 epsilon0 p0 c0 tol ctol nbits ndigits ndigits_alloc npoints cscale ...
     fapl fapu dBap Wap fasl fasu dBas Wasl Wasu ftpl ftpu tp tpr Wtp ...
     improved_solution_found k_min c_min
       
% Done
toc;
diary off
movefile branch_bound_schurOneMlattice_bandpass_10_nbits_test.diary.tmp ...
         branch_bound_schurOneMlattice_bandpass_10_nbits_test.diary;
