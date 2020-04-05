% schurOneMlattice_pop_socp_mmse_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

delete("schurOneMlattice_pop_socp_mmse_test.diary");
delete("schurOneMlattice_pop_socp_mmse_test.diary.tmp");
diary schurOneMlattice_pop_socp_mmse_test.diary.tmp

tic;
tol=1e-8
maxiter=0
verbose=true;
strf="schurOneMlattice_pop_socp_mmse_test";

schurOneMlattice_bandpass_10_nbits_common;

% Options (adjust param.eqTolerance and param.SDPsolverEpsilon if necessary)
test_fix_all_coefficients_simultaneously=false;
test_fix_coefficient_difference_greater_than_alpha=false;
test_add_linear_response_inequality_constraints=false;

% Initial coefficients
kc=kc0;
kc_u=kc0_u;
kc_l=kc0_l;
kc_active=kc0_active;

% Fix one coefficient at each iteration 
while ~isempty(kc_active)
   
  % Show kc_active
  printf("\nkc_active=[ ");printf("%d ",kc_active);printf("]\n");
  
  % Find the signed-digit approximations to k and c
  [~,kc_sdu,kc_sdl]=flt2SD(kc,nbits,ndigits_alloc);
  kc_sdul=kc_sdu-kc_sdl;

  % Initialise kc_fixed
  % (SparsePOP appears to only apply the first equality constraint)
  if test_fix_all_coefficients_simultaneously
    % All at once
    kc_fixed=1:length(kc_active);
    kc_u=kc_sdu;
    kc_l=kc_sdl;
  elseif test_fix_coefficient_difference_greater_than_alpha
    % Lu suggests fixing the coefficients for which alpha>0.5
    alpha=abs((2*kc)-kc_sdu-kc_sdl);
    alpha=alpha(kc_active)./kc_sdul(kc_active);
    kc_fixed=find(alpha>0.5);
    if isempty(kc_fixed)
      kc_fixed=1:length(kc_active);
    endif
    kc_u=kc_sdu;
    kc_l=kc_sdl;
    printf("kc_fixed=[ ");printf("%d ",kc_fixed(:)');printf(" ]\n");
  else 
    % Ito et al. suggest ordering the search by max(kc_sdu-kc_sdl)
    [~,kc_fixed]=max(kc_sdul(kc_active));
    if 0
      % This widens the search and allows linear constraints on the
      % response to succeed but produces very poor results
      kc_u(kc_active(kc_fixed))=kc_sdu(kc_active(kc_fixed));
      kc_l(kc_active(kc_fixed))=kc_sdl(kc_active(kc_fixed));
    else
      kc_u=kc_sdu;
      kc_l=kc_sdl;
    endif
  endif
  printf("Fixing coef. kc([ ");
  printf("%d ",kc_active(kc_fixed));
  printf("])=[ ");
  printf("%12.8f ",kc(kc_active(kc_fixed))*nscale);
  printf("]/%d\n",nscale);

  % Linear constraints
  if test_add_linear_response_inequality_constraints
    Asqk=schurOneMlatticeAsq(wa,kc(1:Nk),epsilon0,ones(size(p0)),kc((Nk+1):end));
    Tk=schurOneMlatticeT(wt,kc(1:Nk),epsilon0,ones(size(p0)),kc((Nk+1):end));
    vS=schurOneMlattice_slb_update_constraints ...
         (Asqk,Asqdu,Asqdl,Wa,Tk,Tdu,Tdl,Wt,[],Pdu,Pdl,Wp,tol);
    schurOneMlattice_slb_show_constraints(vS,wa,Asqk,wt,Tk,[],[]);
  else
    vS=[];
  endif

  % Solve POP MMSE
  try
    [k1,c1,opt_iter,func_iter,feasible]=...
      schurOneMlattice_pop_socp_mmse ...
        (vS,kc(1:Nk),epsilon0,ones(size(p0)),kc((Nk+1):end), ...
         kc_u,kc_l,kc_active,kc_fixed, ...
         wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
         maxiter,tol,verbose);
  catch
    feasible=false;
    err=lasterror();
    fprintf(stderr,"%s\n", err.message);
    for e=1:length(err.stack)
      fprintf(stderr,"Called %s at line %d\n", ...
              err.stack(e).name,err.stack(e).line);
    endfor
    error("k1,c1(pop-mmse) failed!")    
  end_try_catch
  if feasible == 0 
    error("k1,c1(pop-mmse) infeasible");
  endif

  % Update coefficients
  kc=[k1(:);c1(:)];

  % Fix coefficient
  kc_fixed_sd=flt2SD(kc(kc_active(kc_fixed)), ...
                     nbits,ndigits_alloc(kc_active(kc_fixed)));
  printf("Fixed kc([ ");
  printf("%d ",kc_active(kc_fixed));
  printf("])=[ ");
  printf("%12.8f ",kc(kc_active(kc_fixed))*nscale);
  printf("]/%d to [ ",nscale)
  printf("%d ",kc_fixed_sd*nscale);
  printf("]\n")
  kc(kc_active(kc_fixed))=kc_fixed_sd;

  % Update kc_active
  kc_active(kc_fixed)=[];
  
endwhile

% Round the k1 and c1 coefficients to the nearest integer
printf("\nkc=[ ");printf("%g ",nscale*kc(:)');printf(" ]/%d\n",nscale);
kc=round(kc*nscale)/nscale;
printf("Rounded kc=[ ");printf("%g ",nscale*kc(:)');printf(" ]/%d\n",nscale);
k1=kc(1:Nk);
c1=kc((Nk+1):end);

% Find the number of signed-digits and adders used by kc
[kc_digits,kc_adders]=SDadders(kc(kc0_active),nbits);
printf("%d signed-digits used\n",kc_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kc_adders,nbits);

% Amplitude and delay at local peaks
Asq=schurOneMlatticeAsq(wa,k1,epsilon0,ones(size(p0)),c1);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AsqS=schurOneMlatticeAsq(wAsqS,k1,epsilon0,ones(size(p0)),c1);
printf("k,c1:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c1:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=schurOneMlatticeT(wt,k1,epsilon0,ones(size(p0)),c1);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=unique([wt(vTl);wt(vTu);wt([1,end])]);
TS=schurOneMlatticeT(wTS,k1,epsilon0,ones(size(p0)),c1);
printf("k,c1:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,c1:TuS=[ ");printf("%f ",TS');printf(" (samples)\n");

% Calculate response
nplot=2048;
wplot=(0:(nplot-1))'*pi/nplot;
Asq_kc0=schurOneMlatticeAsq(wplot,k0,epsilon0,p0,c0);
Asq_kc0_sd=schurOneMlatticeAsq(wplot,k0_sd,epsilon0,ones(size(p0)),c0_sd);
Asq_kc_min=schurOneMlatticeAsq(wplot,k1,epsilon0,ones(size(p0)),c1);
T_kc0=schurOneMlatticeT(wplot,k0,epsilon0,p0,c0);
T_kc0_sd=schurOneMlatticeT(wplot,k0_sd,epsilon0,ones(size(p0)),c0_sd);
T_kc_min=schurOneMlatticeT(wplot,k1,epsilon0,ones(size(p0)),c1);

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
legend("exact","s-d(Ito)","s-d(POP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_k1c1_stop"),"-dpdflatex");
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
legend("exact","s-d(Ito)","s-d(POP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_k1c1_pass"),"-dpdflatex");
close

% Plot group-delay pass-band response
plot(wplot*0.5/pi,T_kc0,"linestyle","-", ...
     wplot*0.5/pi,T_kc0_sd,"linestyle","--", ...
     wplot*0.5/pi,T_kc_min,"linestyle","-.");
xlabel("Frequency");
ylabel("Group delay(samples)");
axis([0.09 0.21 15.9 16.2]);
strt=sprintf("Schur one-multiplier lattice bandpass filter pass-band \
nbits=%d) : ftpl=%g,ftpu=%g,tp=%g,tpr=%g",nbits,ftpl,ftpu,tp,tpr);
 title(strt);
legend("exact","s-d(Ito)","s-d(POP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_k1c1_delay"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,".spec"),"wt");
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"maxiter=%d %% POP iteration limit\n",maxiter);
fprintf(fid,"npoints=%g %% Frequency points across the band\n",npoints);
fprintf(fid,"length(c0)=%d %% Num. tap coefficients\n",length(c0));
fprintf(fid,"sum(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",sum(k0~=0));
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal passband filter group delay\n",tp);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fprintf(fid,"fasl=%g %% Amplitude stop band(1) lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band(1) upper edge\n",fasu);
fprintf(fid,"Wasl=%d %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%d %% Amplitude upper stop band weight\n",Wasu);
fclose(fid);
print_polynomial(k1,"k1",strcat(strf,"_k1_coef.m"),nscale);
print_polynomial(c1,"c1",strcat(strf,"_c1_coef.m"),nscale);
save schurOneMlattice_pop_socp_mmse_test.mat ...
     k0 epsilon0 p0 c0 tol nbits ndigits ndigits_alloc npoints ...
     fapl fapu Wap fasl fasu Wasl Wasu ftpl ftpu tp Wtp k1 c1

% Done
toc;
diary off
movefile schurOneMlattice_pop_socp_mmse_test.diary.tmp ...
         schurOneMlattice_pop_socp_mmse_test.diary;
