% pop_relaxation_bandpass_OneM_lattice_10_nbits_test.m
% Copyright (C) 2017 Robert G. Jenssen

% Optimisation of Schur one-multiplier lattice bandpass filter response with
% 10-bit signed-digit coefficients and POP relaxation solution.

test_common;

unlink("pop_relaxation_bandpass_OneM_lattice_10_nbits_test.diary");
unlink("pop_relaxation_bandpass_OneM_lattice_10_nbits_test.diary.tmp");
diary pop_relaxation_bandpass_OneM_lattice_10_nbits_test.diary.tmp

tic;

maxiter=2000
verbose=false;

tpr=0.3,dBass=36,Wasu=5e5
schurOneMlattice_bandpass_10_nbits_common;

% Initial coefficients
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

  % Ito et al. suggest ordering the search by max(kc_sdu-kc_sdl)
  kc_sdul=kc_sdu-kc_sdl;
  [~,kc_fixed]=max(kc_sdul(kc_active));
  coef_n=kc_active(kc_fixed);
  kc_u(coef_n)=kc_sdu(coef_n);
  kc_l(coef_n)=kc_sdl(coef_n);
  printf("Fixing kc(%d)=%12.8f/%d\n",coef_n,kc(coef_n)*nscale,nscale);
  
  try
    % Find the SOCP PCLS solution for the remaining active coefficents
    [k1,c1,slb_iter,opt_iter,func_iter,feasible] = ...
    schurOneMlattice_slb(@schurOneMlattice_socp_mmse, ...
                         kc(1:Nk),epsilon0,p0,kc((Nk+1):end), ...
                         kc_u,kc_l,kc_active,dmax, ...
                         wa,Asqd,Asqdu,Asqdl,Wa, ...
                         wt,Td,Tdu,Tdl,Wt, ...
                         wp,Pd,Pdu,Pdl,Wp, ...
                         maxiter,tol,verbose);
    if ~feasible
      error("SOCP PCLS problem infeasible!");
    endif
    kc=[k1(:);c1(:)];
    % Find the POP SOCP MMSE solution with an equality constraint on kc_fixed
    [~,kc_sdu,kc_sdl]=flt2SD(kc,nbits,ndigits_alloc);
    [k2,c2,opt_iter,func_iter,feasible] = ...
    schurOneMlattice_pop_socp_mmse([], ...
                                   kc(1:Nk),epsilon0,p0,kc((Nk+1):end), ...
                                   kc_sdu,kc_sdl,kc_active,kc_fixed, ...
                                   wa,Asqd,Asqdu,Asqdl,Wa, ...
                                   wt,Td,Tdu,Tdl,Wt, ...
                                   wp,Pd,Pdu,Pdl,Wp, ...
                                   maxiter,tol,verbose);
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
  kc=[k2(:);c2(:)];

  % Fix coefficient
  kc_fixed_sd=flt2SD(kc(coef_n),nbits,ndigits_alloc(coef_n));
  printf("Fixed kc(%d)=%12.8f/%d to %d\n", ...
         coef_n,kc(coef_n)*nscale,nscale,kc_fixed_sd*nscale);
  kc(coef_n)=kc_fixed_sd;

  % Update kc_active
  kc_active(kc_fixed)=[];

endwhile

% Show results
fstr=sprintf("pop_relaxation_bandpass_OneM_lattice_%d_nbits_test",nbits);
kc_min=kc;
k_min=kc(1:Nk);
c_min=kc((Nk+1):end);
Esq_min=schurOneMlatticeEsq(k_min,epsilon0,p0,c_min,wa,Asqd,Wa,wt,Td,Wt);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
printf("nscale*k_min=[ ");printf("%g ",nscale*k_min');printf("]';\n");
printf("epsilon0=[ ");printf("%d ",epsilon0');printf("]';\n");
printf("p0=[ ");printf("%g ",p0');printf("]';\n");
printf("nscale*c_min=[ ");printf("%g ",nscale*c_min');printf("]';\n");
print_polynomial(nscale*k_min,sprintf("%d*k_min",nscale), ...
                 strcat(fstr,"_k_min_coef.m"),"%6d");
print_polynomial(nscale*c_min,sprintf("%d*c_min",nscale), ...
                 strcat(fstr,"_c_min_coef.m"),"%6d");
% Find the number of signed-digits and adders used
[kc_digits,kc_adders]=SDadders(kc_min(kc0_active),nbits);
printf("%d signed-digits used\n",kc_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kc_adders,nbits);

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
fid=fopen(strcat(fstr,"_cost.tab"),"wt");
fprintf(fid,"Exact & %6.4f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit(Ito)&%6.4f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,kc0_digits,kc0_adders);
fprintf(fid,"%d-bit %d-signed-digit(POP-relax) & %6.4f & %d & %d \\\\\n",
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
tstr=sprintf("Schur one-multiplier lattice bandpass filter stop-band \
(nbits=%d) : fasl=%g,fasu=%g,dBas=%g",nbits,fasl,fasu,dBas);
title(tstr);
legend("exact","s-d(Ito)","s-d(POP-relax)");
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
axis([0.1 0.2 -2 2]);
tstr=sprintf("Schur one-multiplier lattice bandpass filter pass-band \
(nbits=%d) : fapl=%g,fapu=%g,dBap=%g",nbits,fapl,fapu,dBap);
title(tstr);
legend("exact","s-d(Ito)","s-d(POP-relax)");
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
axis([0.09 0.21 15.9 16.2]);
tstr=sprintf("Schur one-multiplier lattice bandpass filter pass-band \
(nbits=%d) : ftpl=%g,ftpu=%g,tp=%g,tpr=%g",nbits,ftpl,ftpu,tp,tpr);
 title(tstr);
legend("exact","s-d(Ito)","s-d(POP-relax)");
legend("location","northeast");
legend("Boxoff");
legend("left");
grid("on");
print(strcat(fstr,"_delay"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(fstr,".spec"),"wt");
fprintf(fid,"nbits=%g %% Coeficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coeficient signed-digits\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"maxiter=%d %% SOCP iteration limit\n",maxiter);
fprintf(fid,"npoints=%g %% Frequency points across the band\n",npoints);
fprintf(fid,"length(c0)=%d %% Num. tap coefficients\n",length(c0));
fprintf(fid,"sum(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",sum(k0~=0));
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
fprintf(fid,"fasl=%g %% Amplitude stop band(1) lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band(1) upper edge\n",fasu);
fprintf(fid,"dBas=%d %% Amplitude stop band(1) peak-to-peak ripple\n",dBas);
fprintf(fid,"fasll=%g %% Amplitude stop band(2) lower edge\n",fasll);
fprintf(fid,"fasuu=%g %% Amplitude stop band(2) upper edge\n",fasuu);
fprintf(fid,"dBass=%d %% Amplitude stop band(2) peak-to-peak ripple\n",dBass);
fprintf(fid,"Wasl=%d %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Amplitude upper stop band weight\n",Wasu);
fclose(fid);

% Save results
save pop_relaxation_bandpass_OneM_lattice_10_nbits_test.mat ...
     k0 epsilon0 p0 c0 ...
     tol nbits ndigits ndigits_alloc npoints ...
     fapl fapu dBap Wap ...
     fasl fasu dBas fasll fasuu dBass Wasl Wasu ...
     ftpl ftpu tp tpr Wtp ...
     k_min c_min 
       
% Done
toc;
diary off
movefile pop_relaxation_bandpass_OneM_lattice_10_nbits_test.diary.tmp ...
       pop_relaxation_bandpass_OneM_lattice_10_nbits_test.diary;
