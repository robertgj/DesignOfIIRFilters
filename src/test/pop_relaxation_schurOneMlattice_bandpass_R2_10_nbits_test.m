% pop_relaxation_schurOneMlattice_bandpass_R2_10_nbits_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

% Optimisation of Schur one-multiplier lattice bandpass filter response with
% 10-bit signed-digit coefficients and POP relaxation solution.

test_common;

strf="pop_relaxation_schurOneMlattice_bandpass_R2_10_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
verbose=false;

use_kc0_coefficient_bounds=true
use_schurOneMlattice_allocsd_Lim=false
use_schurOneMlattice_allocsd_Ito=true
use_fix_coefficient_difference_greater_than_alpha=true
alpha_min=0.8
dBass=37
schurOneMlattice_bandpass_R2_10_nbits_common;

% Initial coefficients
p_ones=ones(size(k0));
kc=zeros(size(kc0));
kc(kc0_active)=kc0(kc0_active);
kc_u=kc0_u;
kc_l=kc0_l;
kc_active=kc0_active;

% Fix one coefficient at each iteration 
while ~isempty(kc_active)
  
  % Show kc_active
  printf("\nkc_active=[ ");printf("%d ",kc_active);printf("]\n");
  printf("kc=[ ");printf("%g ",nscale*kc');printf("]'/%d;\n",nscale);

  % Find the limits of the signed-digit approximations to k and c
  [~,kc_sdu,kc_sdl]=flt2SD(kc,nbits,ndigits_alloc);
  kc_sdul=kc_sdu-kc_sdl;

  % Sanity check on kc_sdul
  [~,n_kc_sdul_0]=find(kc_sdul(kc_active)==0);
  if ~isempty(n_kc_sdul_0)
    kc_active(n_kc_sdul_0) = [];
    if isempty(kc_active)
      break;
    else
      continue;
    endif
  endif

  if use_fix_coefficient_difference_greater_than_alpha
    % Lu suggests fixing the coefficients for which alpha>alpha_min
    alpha=abs((2*kc)-kc_sdu-kc_sdl);
    alpha=alpha(kc_active)./kc_sdul(kc_active);
    kc_fixed=find(alpha>alpha_min);
    if isempty(kc_fixed)
      [~,kc_fixed]=max(kc_sdul(kc_active));
    endif
    printf("kc_fixed=[ ");printf("%d ",kc_fixed(:)');printf(" ]\n");
  else 
    % Ito et al. suggest ordering the search by max(kc_sdu-kc_sdl)
    [~,kc_fixed]=max(kc_sdul(kc_active));
  endif
  printf("Fixing coef. kc([ ");
  printf("%d ",kc_active(kc_fixed));
  printf("])=[ ");
  printf("%12.8f ",kc(kc_active(kc_fixed))*nscale);
  printf("]/%d\n",nscale);
  
  % Initialise upper and lower constraints on kc
  kc_u=kc;
  kc_l=kc;
  if use_kc0_coefficient_bounds
    kc_u(kc_active)=kc0_u(kc_active);
    kc_l(kc_active)=kc0_l(kc_active);
  else
    kc_u(kc_active)=kc_sdu(kc_active);
    kc_l(kc_active)=kc_sdl(kc_active);
  endif
  coef_n=kc_active(kc_fixed);
  kc_u(coef_n)=kc_sdu(coef_n);
  kc_l(coef_n)=kc_sdl(coef_n);

  try
    % Find the SOCP PCLS solution for the remaining active coefficients
    feasible=false;
    [knext,cnext,slb_iter,opt_iter,func_iter,feasible] = ...
    schurOneMlattice_slb(@schurOneMlattice_pop_mmse, ...
                         kc(1:Nk),epsilon0,p_ones,kc((Nk+1):end), ...
                         kc_u,kc_l,kc_active,kc_fixed, ...
                         wa,Asqd,Asqdu,Asqdl,Wa, ...
                         wt,Td,Tdu,Tdl,Wt, ...
                         wp,Pd,Pdu,Pdl,Wp, ...
                         wd,Dd,Ddu,Ddl,Wd, ...
                         maxiter,ftol,ctol,verbose);
  catch
    feasible=false;
    err=lasterror();
    fprintf(stderr,"%s\n", err.message);
    for e=1:length(err.stack)
      fprintf(stderr,"Called %s at line %d\n", ...
              err.stack(e).name,err.stack(e).line);
    endfor
  end_try_catch

  % If this problem was not solved then give up
  if ~feasible
    error("POP problem infeasible!");
  endif

  % Update coefficients
  kc=[knext(:);cnext(:)];

  % Fix coefficient
  kc_fixed_sd=flt2SD(kc(coef_n),nbits,ndigits_alloc(coef_n));
  kc(coef_n)=kc_fixed_sd;
  printf("Fixed kc([ ");
  printf("%d ",kc_active(kc_fixed));
  printf("])=[ ");
  printf("%g ",kc(kc_active(kc_fixed))*nscale);
  printf("]/%d\n",nscale);

  % Update kc_active
  kc_active(kc_fixed)=[];

endwhile

% Show results
kc_min=kc;
k_min=kc(1:Nk);
c_min=kc((Nk+1):end);
Esq_min=schurOneMlatticeEsq(k_min,epsilon0,p_ones,c_min,wa,Asqd,Wa,wt,Td,Wt);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
printf("epsilon0=[ ");printf("%d ",epsilon0');printf("]';\n");
print_polynomial(c_min,"c_min",nscale);
print_polynomial(c_min,"c_min",strcat(strf,"_c_min_coef.m"),nscale);
% Find the number of signed-digits and adders used
[kc_digits,kc_adders]=SDadders(kc_min(kc0_active),nbits);
printf("%d signed-digits used\n",kc_digits);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       kc_adders,nbits);

% Filter a quantised noise signal and check the state variables
nsamples=2^12;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u); 
u=round(u*nscale);
[yap,y,xx]=schurOneMlatticeFilter(k0,epsilon0,p_ones,c0,u,"round");
stdx=std(xx)
[yapf,yf,xxf]= ...
schurOneMlatticeFilter(k_min,epsilon0,ones(size(k0)),c_min,u,"round");
stdxf=std(xxf)

% Amplitude and delay at local peaks
Asq=schurOneMlatticeAsq(wa,k_min,epsilon0,p_ones,c_min);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=schurOneMlatticeAsq(wAsqS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMlatticeT(wt,k_min,epsilon0,p_ones,c_min);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMlatticeT(wTS,k_min,epsilon0,p_ones,c_min);
printf("k,c_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c_min:TS=[ ");printf("%f ",TS');printf(" (samples)\n");

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %6.4f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(Ito) & %6.4f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd,kc0_digits,kc0_adders);
fprintf(fid,"%d-bit %d-signed-digit(POP-relax) & %6.4f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_min,kc_digits,kc_adders);
fclose(fid);

% Calculate response
nplot=2048;
wplot=(0:(nplot-1))'*pi/nplot;
Asq_kc0=schurOneMlatticeAsq(wplot,k0,epsilon0,p_ones,c0);
Asq_kc0_sd=schurOneMlatticeAsq(wplot,k0_sd,epsilon0,p_ones,c0_sd);
Asq_kc_min=schurOneMlatticeAsq(wplot,k_min,epsilon0,p_ones,c_min);
T_kc0=schurOneMlatticeT(wplot,k0,epsilon0,p_ones,c0);
T_kc0_sd=schurOneMlatticeT(wplot,k0_sd,epsilon0,p_ones,c0_sd);
T_kc_min=schurOneMlatticeT(wplot,k_min,epsilon0,p_ones,c_min);

% Plot amplitude stop-band response
plot(wplot*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc0_sd)),"linestyle","--", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -50 -30]);
strt=sprintf("Bandpass R=2 filter : nbits=%d,fasl=%g,fasu=%g,dBas=%g", ...
             nbits,fasl,fasu,dBas);
title(strt);
legend("exact","s-d(Ito)","s-d(POP-relax)");
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
axis([0.1 0.2 -2 2]);
strt=sprintf("Bandpass R=2 filter : nbits=%d,fapl=%g,fapu=%g,dBap=%g", ...
              nbits,fapl,fapu,dBap);
title(strt);
legend("exact","s-d(Ito)","s-d(POP-relax)");
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
ylabel("Delay(samples)");
axis([0.09 0.21 15.9 16.2]);
strt=sprintf("Bandpass R=2 filter : nbits=%d,ftpl=%g,ftpu=%g,tp=%g,tpr=%g", ...
             nbits,ftpl,ftpu,tp,tpr);
 title(strt);
legend("exact","s-d(Ito)","s-d(POP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"use_kc0_coefficient_bounds=%d\n", ...
        use_kc0_coefficient_bounds);
fprintf(fid,"use_schurOneMlattice_allocsd_Lim=%d\n", ...
        use_schurOneMlattice_allocsd_Lim);
fprintf(fid,"use_schurOneMlattice_allocsd_Ito=%d\n", ...
        use_schurOneMlattice_allocsd_Ito);
fprintf(fid,"use_fix_coefficient_difference_greater_than_alpha=%d\n", ...
        use_fix_coefficient_difference_greater_than_alpha);
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"maxiter=%d %% SOCP iteration limit\n",maxiter);
fprintf(fid,"npoints=%g %% Frequency points across the band\n",npoints);
fprintf(fid,"%% length(c0)=%d %% Num. tap coefficients\n",length(c0));
fprintf(fid,"%% sum(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",sum(k0~=0));
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"alpha_min=%f %% Threshold on coefficients to fix\n",alpha_min);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal passband filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Delay pass band weight\n",Wtp);
fprintf(fid,"fasl=%g %% Amplitude stop band(1) lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band(1) upper edge\n",fasu);
fprintf(fid,"dBas=%g %% Amplitude stop band(1) peak-to-peak ripple\n",dBas);
fprintf(fid,"fasll=%g %% Amplitude stop band(2) lower edge\n",fasll);
fprintf(fid,"fasuu=%g %% Amplitude stop band(2) upper edge\n",fasuu);
fprintf(fid,"dBass=%g %% Amplitude stop band(2) peak-to-peak ripple\n",dBass);
fprintf(fid,"Wasl=%g %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%g %% Amplitude upper stop band weight\n",Wasu);
fclose(fid);

% Save results
eval(sprintf(["save %s.mat k0 epsilon0 c0 ftol ctol nbits ndigits ", ...
 "ndigits_alloc npoints fapl fapu dBap Wap fasl fasu dBas fasll fasuu dBass ", ...
 "Wasl Wasu ftpl ftpu tp tpr Wtp k_min c_min"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
