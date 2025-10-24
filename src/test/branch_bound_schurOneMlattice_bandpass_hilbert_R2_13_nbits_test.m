% branch_bound_schurOneMlattice_bandpass_R2_13_nbits_test.m
% Copyright (C) 2025 Robert G. Jenssen

% Branch-and-bound search of a pipelined Schur one-multiplier lattice bandpass
% Hilbert filter response with 13-bit 3-signed-digit coefficients and R=2

test_common;

strf="branch_bound_schurOneMlattice_bandpass_hilbert_R2_13_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

nbits=13;
ndigits=3;

% Bandpass R=2 filter specification for
% schurOneMlattice_socp_slb_bandpass_hilbert_R2_test.m
fasl=0.05,fapl=0.1,fapu=0.2,fasu=0.25
Wap=0.1,Watl=1e-3,Watu=1e-3,Wasl=1,Wasu=10000
fppl=0.1,fppu=0.2,pp=3.5,Wpp=1
ftpl=0.1,ftpu=0.2,tp=16,Wtp=0.1
fdpl=0.1,fdpu=0.2,dp=0,Wdp=0.01

%
% Initial coefficients
%
schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_k2_coef;
schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_epsilon2_coef;
schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_p2_coef;
schurOneMlattice_socp_slb_bandpass_hilbert_R2_test_c2_coef;
k0=k2(:);clear k2;
epsilon0=epsilon2(:);clear epsilon2;
p0=p2(:);clear p2;
c0=c2(:);clear c2;
kc0=[k0;c0];
p_ones = ones(size(p0));

% Initialise coefficient range vectors
Nk=length(k0);
Nc=length(c0);
Nkc=Nk+Nc;
Rk=1:Nk;
Rc=(Nk+1):Nkc;

%
% Frequency vectors
%
n=1000;
f=(0:(n-1))'*0.5/n;
w=2*pi*f;

% Desired squared magnitude response
wa=w;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Asqd=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
    Watl*ones(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Watu*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];
% Sanity checks
nchka=[1, ...
       nasl-1,nasl,nasl+1, ...
       napl-1,napl,napl+1, ...
       napu-1,napu,napu+1, ...
       nasu-1,nasu,nasu+1,...
       n-1]';
printf("0.5*wa(nchka)'/pi=[ ");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Desired pass-band phase response
nppl=floor(n*fppl/0.5)+1;
nppu=ceil(n*fppu/0.5)+1;
wp=wa(nppl:nppu);
Pd=(pp*pi)-(tp*wp);
Wp=Wpp*ones(nppu-nppl+1,1);

% Desired pass-band group delay response
ntpl=floor(n*ftpl/0.5)+1;
ntpu=ceil(n*ftpu/0.5)+1;
wt=wa(ntpl:ntpu);
Td=tp*ones(length(wt),1);
Wt=Wtp*ones(length(wt),1);

% Desired pass-band dAsqdw response
ndpl=floor(n*fdpl/0.5)+1;
ndpu=ceil(n*fdpu/0.5)+1;
wd=wa(ndpl:ndpu);
Dd=dp*ones(length(wd),1);
Wd=Wdp*ones(length(wd),1);

% Constraints on the coefficients
rho=0.999 
dmax=0.05;
kc_u=[rho*ones(Nk,1);10*ones(Nc,1)];
kc_l=-kc_u;
kc0_active=find((kc0)~=0);
n_active=length(kc0_active);

% Exact error
Esq0=schurOneMlatticeEsq(k0,epsilon0,p_ones,c0, ...
                         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Allocate digits
nscale=2^(nbits-1);
ndigits_alloc=schurOneMlattice_allocsd_Ito ...
                (nbits,ndigits,k0,epsilon0,p0,c0, ...
                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
k_allocsd_digits=int16(ndigits_alloc(Rk));
c_allocsd_digits=int16(ndigits_alloc(Rc));
printf("k_allocsd_digits=[ ");printf("%2d ",k_allocsd_digits);printf("]';\n");
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%2d");
printf("c_allocsd_digits=[ ");printf("%2d ",c_allocsd_digits);printf("]';\n");
print_polynomial(c_allocsd_digits,"c_allocsd_digits", ...
                 strcat(strf,"_c_allocsd_digits.m"),"%2d");

% Find the signed-digit approximations to kc0
[kc0_sd,kc0_sdu,kc0_sdl]=flt2SD(kc0,nbits,ndigits);
[kc0_sd_digits,kc0_sd_adders]=SDadders(kc0_sd,nbits);
k0_sd=kc0_sd(Rk);
c0_sd=kc0_sd(Rc);
print_polynomial(k0_sd,"k0_sd",nscale);
print_polynomial(k0_sd,"k0_sd",strcat(strf,"_k0_sd_coef.m"),nscale);
print_polynomial(c0_sd,"c0_sd",nscale);
print_polynomial(c0_sd,"c0_sd",strcat(strf,"_c0_sd_coef.m"),nscale);

[kc0_sd_Ito,kc0_sdu_Ito,kc0_sdl_Ito]=flt2SD(kc0,nbits,ndigits_alloc);
[kc0_sd_Ito_digits,kc0_sd_Ito_adders]=SDadders(kc0_sd_Ito,nbits);
k0_sd_Ito=kc0_sd_Ito(Rk);
c0_sd_Ito=kc0_sd_Ito(Rc);
print_polynomial(k0_sd_Ito,"k0_sd_Ito",nscale);
print_polynomial(k0_sd_Ito,"k0_sd_Ito",strcat(strf,"_k0_sd_Ito_coef.m"),nscale);
print_polynomial(c0_sd_Ito,"c0_sd_Ito",nscale);
print_polynomial(c0_sd_Ito,"c0_sd_Ito",strcat(strf,"_c0_sd_Ito_coef.m"),nscale);

% Initialise kc_active
kc0_sdul_Ito=kc0_sdu_Ito-kc0_sdl_Ito;
kc0_active=find(kc0_sdul_Ito~=0);
n_active=length(kc0_active);

% Find initial stop-band response
Asq0=schurOneMlatticeAsq(wa,k0,epsilon0,p_ones,c0);
Asq0_max_sb=10*log10(max(Asq0([1:nasl,nasu:end])));
Asq0_sd=schurOneMlatticeAsq(wa,k0_sd,epsilon0,p_ones,c0_sd);
Asq0_sd_max_sb=10*log10(max(Asq0_sd([1:nasl,nasu:end])));
Asq0_sd_Ito=schurOneMlatticeAsq(wa,k0_sd_Ito,epsilon0,p_ones,c0_sd_Ito);
Asq0_sd_Ito_max_sb=10*log10(max(Asq0_sd_Ito([1:nasl,nasu:end])));

% Find initial mean-squared errrors
Esq0=schurOneMlatticeEsq(k0,epsilon0,p_ones,c0, ...
                         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
Esq0_sd=schurOneMlatticeEsq(k0_sd,epsilon0,p_ones,c0_sd, ... 
                            wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
Esq0_sd_Ito=schurOneMlatticeEsq(k0_sd_Ito,epsilon0,p_ones,c0_sd_Ito, ...
                                wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

% Define stack of current filter coefficients and tree depth
kc_stack=cell(1,n_active);
kc_b=kc0_sd_Ito;
kc_active=kc0_active;
kc_depth=0;
branch_tree=true;
n_branch=0;

% Initialise the search
improved_solution_found=false;
Esq_min=Esq0_sd_Ito;
kc_min=kc0_sd_Ito;
printf("Initial Esq_min=%g\n",Esq_min);
printf("Initial kc_active=[ ");printf("%d ",kc_active);printf("];\n");
printf("Initial kc_b=[ ");printf("%g ",kc_b');printf("]';\n");

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
    [kc0_sdul_Ito_max,kc0_sdul_Ito_max_n]=max(kc0_sdul_Ito(kc_active));
    coef_n=kc_active(kc0_sdul_Ito_max_n);
    kc_active(kc0_sdul_Ito_max_n)=[];
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
  printf("kc_b=[ ");printf("%g ",nscale*kc_b');printf("]'/%d;\n",nscale);

  % Find the error for the current sub-problem
  Esq=schurOneMlatticeEsq(kc_b(Rk),epsilon0,p0,kc_b(Rc), ...
                          wa,Asqd,Wa,wt,Td,Wt);
  printf("Found Esq=%g\n",Esq); 
  
  % Update the active coefficients
  if ~isempty(kc_active)
    % Check bound on Esq 
    if (Esq<Esq_min) || (kc_depth == 0)
      branch_tree=true;
    else
      branch_tree=false;
    endif
  endif
  
  % At maximum depth there are no active coefficients so update Esq_min
  if isempty(kc_active)
    % At the maximum depth so update Esq_min
    branch_tree=false;
    k_b=kc_b(Rk);
    c_b=kc_b(Rc);
    printf("At maximum depth Esq=%g\n",Esq); 
    if Esq<Esq_min
      improved_solution_found=true;
      Esq_min=Esq;
      kc_min=kc_b;
      k_min=k_b;
      c_min=c_b;
      printf("Improved solution: kc_depth=%d, Esq_min=%g\n",kc_depth,Esq_min);
      print_polynomial(k_min,"k_min",nscale);
      print_polynomial(c_min,"c_min",nscale);
    endif
  endif

% Exit the loop when there are no sub-problems left
until (isempty(kc_active)||(branch_tree==false)) && (kc_depth==0)
printf("Branch-and-bound search completed with %d branches\n",n_branch);

% Calculate state scaling
delta=4;
[A_min,B_min,C_min,D_min]= ...
  schurOneMlattice2Abcd(k_min,epsilon0,p0,c_min);
ng_min=Abcd2ng(A_min,B_min,C_min,D_min);
[K_min,W_min]=KW(A_min,B_min,C_min,D_min);
p_min=1./(delta*sqrt(diag(K_min)'));
p_min=flt2SD(p_min,nbits,1);

% Show results
if ~improved_solution_found
  error("Did not find an improved solution!\n");
endif
printf("\nBest new solution:\n Esq_min=%g\n ng_min=%g\n",Esq_min,ng_min);
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
print_polynomial(epsilon0,"epsilon0");
print_polynomial(p_min,"p_min");
print_polynomial(p_min,"p_min",strcat(strf,"_p_min_coef.m"),nscale);
print_polynomial(c_min,"c_min",nscale);
print_polynomial(c_min,"c_min",strcat(strf,"_c_min_coef.m"),nscale);
% Find the number of signed-digits and adders used
[kc_digits,kc_adders]=SDadders(kc_min(kc0_active),nbits);
printf("%d signed-digits used\n",kc_digits);
printf("%d %d-bit adders used for coef. multiplications\n",kc_adders,nbits);

% Transfer function polynomials
[N_min,D_min]=schurOneMlattice2tf(k_min,epsilon0,p_min,c_min);
print_polynomial(N_min,"N_min");
print_polynomial(N_min,"N_min",strcat(strf,"_N_min_coef.m"));
print_polynomial(D_min,"D_min");
print_polynomial(D_min,"D_min",strcat(strf,"_D_min_coef.m"));
H_min=freqz(N_min,D_min,wa);
Asq=schurOneMlatticeAsq(wa,k_min,epsilon0,p_min,c_min);
if max(abs((abs(H_min).^2)-Asq)) > 100*eps
  error("max(abs((abs(H_min).^2)-Asq))(%g*eps) > 100*eps", ...
        max(abs((abs(H_min).^2)-Asq))/eps);
endif
T_min=delayz(N_min,D_min,wt);
T=schurOneMlatticeT(wt,k_min,epsilon0,p_min,c_min);
if max(abs(T_min-T)) > 1e4*eps
  error("max(abs(T_min-T))(%g*eps) > 1e4*eps", ...
        max(abs(T_min-T))/eps);
endif

% Amplitude, phase and delay at local peaks
Asq=schurOneMlatticeAsq(wa,k_min,epsilon0,p_min,c_min);
Asq_max_sb=10*log10(max(Asq([1:nasl,nasu:end])));
vAl=local_max(-Asq);
vAu=local_max(Asq);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=schurOneMlatticeAsq(wAsqS,k_min,epsilon0,p_min,c_min);
printf("k,c_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
P=schurOneMlatticeP(wp,k_min,epsilon0,p_min,c_min);
vPl=local_max(-(P+(wp*tp))/pi);
vPu=local_max( (P+(wp*tp))/pi);
wPS=unique([wp(vPl);wp(vPu);wp([1,end])]);
PS=schurOneMlatticeP(wPS,k_min,epsilon0,p_min,c_min);
printf("k,c_min:fPS=[ ");printf("%f ",wPS*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:PS=[ ");printf("%f ",rem(((PS)+(wPS*tp))/pi,2));printf(" ](rad./pi)\n");
T=schurOneMlatticeT(wt,k_min,epsilon0,p_min,c_min);
vTl=local_max(-T);
vTu=local_max(T);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMlatticeT(wTS,k_min,epsilon0,p_min,c_min);
printf("k,c_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %10.4e & %6.2f & & \\\\\n",Esq0,Asq0_max_sb);
fprintf(fid,"%d-bit %d-signed-digit&%10.4e & %6.2f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd,Asq0_sd_max_sb,kc0_sd_digits,kc0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(Ito)&%10.4e & %6.2f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd_Ito,Asq0_sd_Ito_max_sb, ...
        kc0_sd_Ito_digits,kc0_sd_Ito_adders);
fprintf(fid,"%d-bit %d-signed-digit(b-and-b)& %10.4e & %6.2f& %d & %d\\\\\n",...
        nbits,ndigits,Esq_min,Asq_max_sb,kc_digits,kc_adders);
fclose(fid);

% Calculate response
nplot=2048;
wplot=(0:(nplot-1))'*pi/nplot;
Asq_kc0=schurOneMlatticeAsq(wplot,k0,epsilon0,p0,c0);
Asq_kc0_sd=schurOneMlatticeAsq(wplot,k0_sd,epsilon0,p0,c0_sd);
Asq_kc0_sd_Ito=schurOneMlatticeAsq(wplot,k0_sd_Ito,epsilon0,p0,c0_sd_Ito);
Asq_kc_min=schurOneMlatticeAsq(wplot,k_min,epsilon0,p_min,c_min);
P_kc0=schurOneMlatticeP(wplot,k0,epsilon0,p0,c0);
P_kc0_sd=schurOneMlatticeP(wplot,k0_sd,epsilon0,p0,c0_sd);
P_kc0_sd_Ito=schurOneMlatticeP(wplot,k0_sd_Ito,epsilon0,p0,c0_sd_Ito);
P_kc_min=schurOneMlatticeP(wplot,k_min,epsilon0,p_min,c_min);
T_kc0=schurOneMlatticeT(wplot,k0,epsilon0,p0,c0);
T_kc0_sd=schurOneMlatticeT(wplot,k0_sd,epsilon0,p0,c0_sd);
T_kc0_sd_Ito=schurOneMlatticeT(wplot,k0_sd_Ito,epsilon0,p0,c0_sd_Ito);
T_kc_min=schurOneMlatticeT(wplot,k_min,epsilon0,p_min,c_min);

% Plot amplitude stop-band response
strt=sprintf(["Schur one-multiplier R=2 lattice bandpass filter %%s : ", ...
 "nbits=%d,fasl=%g,fapl=%g,fapu=%g,fasu=%g"],nbits,fasl,fapl,fapu,fasu);
plot(wplot*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc0_sd)),"linestyle",":", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc0_sd_Ito)),"linestyle","--", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -40 -32]);
strt=sprintf(strt,"stop-band");
title(strt);
legend("exact","s-d","s-d(Ito)","s-d(BandB)");
legend("location","southeast");
legend("boxoff");
legend("right");
grid("on");
zticks([]);
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot amplitude pass-band response
plot(wplot*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc0_sd)),"linestyle",":", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc0_sd_Ito)),"linestyle","--", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0.1 0.2 -0.4 0.2]);
strt=sprintf(strt,"pass-band");
title(strt);
legend("exact","s-d","s-d(Ito)","s-d(BandB)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_pass"),"-dpdflatex");
close

% Plot phase pass-band response
plot(wplot*0.5/pi,rem((P_kc0+(wplot*tp))/pi,2),"linestyle","-", ...
     wplot*0.5/pi,rem((P_kc0_sd+(wplot*tp))/pi,2),"linestyle",":", ...
     wplot*0.5/pi,rem((P_kc0_sd_Ito+(wplot*tp))/pi,2),"linestyle","--", ...
     wplot*0.5/pi,rem((P_kc_min+(wplot*tp))/pi,2),"linestyle","-.");
xlabel("Frequency");
ylabel("Phase(rad./$\\pi$)");
axis([0.1 0.2 1.5+(0.004*[-1,1])]);
strt=sprintf(["Schur one-multiplier R=2 lattice bandpass filter pass-band ", ...
 ": nbits=%d,ftpl=%g,ftpu=%g,tp=%g"],nbits,ftpl,ftpu,tp);
title(strt);
legend("exact","s-d","s-d(Ito)","s-d(BandB)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_phase"),"-dpdflatex");
close

% Plot group-delay pass-band response
plot(wplot*0.5/pi,T_kc0,"linestyle","-", ...
     wplot*0.5/pi,T_kc0_sd,"linestyle",":", ...
     wplot*0.5/pi,T_kc0_sd_Ito,"linestyle","--", ...
     wplot*0.5/pi,T_kc_min,"linestyle","-.");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0.09 0.21 15.7 16.2]);
strt=sprintf(["Schur one-multiplier R=2 lattice bandpass filter pass-band ", ...
 ": nbits=%d,ftpl=%g,ftpu=%g,tp=%g"],nbits,ftpl,ftpu,tp);
title(strt);
legend("exact","s-d","s-d(Ito)","s-d(BandB)");
legend("location","south");
legend("boxoff");
legend("right");
grid("on");
zticks([]);
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%d %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%d %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"%% length(c0)=%d %% Num. tap coefficients\n",length(c0));
fprintf(fid,"%% sum(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",sum(k0~=0));
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Watl=%d %% Amplitude lower transition band weight\n",Watl);
fprintf(fid,"Watu=%d %% Amplitude upper transition band weight\n",Watu);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"Wasl=%d %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Amplitude upper stop band weight\n",Wasu);
fprintf(fid,"fppl=%g %% Phase pass band lower edge\n",fppl);
fprintf(fid,"fppu=%g %% Phase pass band upper edge\n",fppu);
fprintf(fid,"pp=%g %% Nominal passband filter phase(rad./pi)\n",pp);
fprintf(fid,"Wpp=%g %% Phase pass band weight\n",Wtp);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal passband filter group delay\n",tp);
fprintf(fid,"Wtp=%g %% Delay pass band weight\n",Wtp);
fprintf(fid,"fdpl=%g %% dAsqdw pass band lower edge\n",fdpl);
fprintf(fid,"fdpu=%g %% dAsqdw pass band upper edge\n",fdpu);
fprintf(fid,"dp=%g %% Nominal passband filter dAsqdw\n",dp);
fprintf(fid,"Wdp=%g %% dAsqdw pass band weight\n",Wdp);
fclose(fid);

% Save results
eval(sprintf(["save %s.mat improved_solution_found ", ...
              " k0 epsilon0 c0 nbits ndigits n ", ...
              " fapl fapu Wap fasl fasu Wasl Wasu ", ...
              " fppl fppu pp Wpp ftpl ftpu tp Wtp fdpl fdpu dp Wdp ", ...
              " k_min p_min c_min N_min D_min"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
