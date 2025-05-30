% schurOneMlattice_pop_mmse_test.m

% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

strf="schurOneMlattice_pop_mmse_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;
ftol=1e-8
ctol=ftol
maxiter=0
verbose=true;

dBap=1,dBas=30,tpr=0.4
use_schurOneMlattice_allocsd_Ito=true
schurOneMlattice_bandpass_10_nbits_common;

% Options (adjust param.eqTolerance and param.SDPsolverEpsilon if necessary)
test_fix_all_coefficients_simultaneously=false;
test_fix_coefficient_difference_greater_than_alpha=true;
test_add_linear_response_inequality_constraints=true;

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
  if test_fix_all_coefficients_simultaneously
    % All at once
    kc_fixed=1:length(kc_active);
  elseif test_fix_coefficient_difference_greater_than_alpha
    % Lu suggests fixing the coefficients for which alpha>0.5
    alpha=abs((2*kc)-kc_sdu-kc_sdl);
    alpha=alpha(kc_active)./kc_sdul(kc_active);
    kc_fixed=find(alpha>0.5);
    if isempty(kc_fixed)
      kc_fixed=1:length(kc_active);
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
  kc_u(kc_active)=kc0_u(kc_active);
  kc_u(kc_active(kc_fixed))=kc_sdu(kc_active(kc_fixed));
  kc_l=kc;
  kc_l(kc_active)=kc0_l(kc_active);
  kc_l(kc_active(kc_fixed))=kc_sdl(kc_active(kc_fixed));

  % Find linear constraints on the response
  if test_add_linear_response_inequality_constraints
    Asqk=schurOneMlatticeAsq(wa,kc(1:Nk),epsilon0,ones(size(p0)),kc((Nk+1):end));
    Tk=schurOneMlatticeT(wt,kc(1:Nk),epsilon0,ones(size(p0)),kc((Nk+1):end));
    vS=schurOneMlattice_slb_update_constraints ...
         (Asqk,Asqdu,Asqdl,Wa,Tk,Tdu,Tdl,Wt,[],[],[],[],[],[],[],[],ctol);
    schurOneMlattice_slb_show_constraints(vS,wa,Asqk,wt,Tk,[],[],[],[]);
  else
    vS=[];
  endif

  % Solve POP MMSE
  try
    [k1,c1,opt_iter,func_iter,feasible]=...
      schurOneMlattice_pop_mmse ...
        (vS,kc(1:Nk),epsilon0,ones(size(p0)),kc((Nk+1):end), ...
         kc_u,kc_l,kc_active,kc_fixed, ...
         wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
         wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd,...
         maxiter,ftol,ctol,verbose);
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
printf("%d %d-bit adders used for coefficient multiplications\n", ...
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
strt=sprintf(["Schur one-multiplier lattice bandpass filter stop-band ", ...
 "(nbits=%d) : fasl=%g,fasu=%g,dBas=%g"],nbits,fasl,fasu,dBas);
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
axis([0.1 0.2 -0.2 0.2]);
strt=sprintf(["Schur one-multiplier lattice bandpass filter pass-band ", ...
 "(nbits=%d) : fapl=%g,fapu=%g,dBap=%g"],nbits,fapl,fapu,dBap);
title(strt);
legend("exact","s-d(Ito)","s-d(POP-relax)");
legend("location","northwest");
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
ylabel("Delay(samples)");
axis([0.09 0.21 15.8 16.2]);
strt=sprintf(["Schur one-multiplier lattice bandpass filter pass-band ", ...
 "nbits=%d) : ftpl=%g,ftpu=%g,tp=%g,tpr=%g"],nbits,ftpl,ftpu,tp,tpr);
 title(strt);
legend("exact","s-d(Ito)","s-d(POP-relax)");
legend("location","north");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_k1c1_delay"),"-dpdflatex");
close

%
% Save the results
%
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"ftol=%g %% Tolerance on coefficient update vector\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"maxiter=%d %% POP iteration limit\n",maxiter);
fprintf(fid,"npoints=%g %% Frequency points across the band\n",npoints);
fprintf(fid,"length(c0)=%d %% Num. tap coefficients\n",length(c0));
fprintf(fid,"sum(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",sum(k0~=0));
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fasl=%g %% Amplitude stop band inner lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band inner upper edge\n",fasu);
fprintf(fid,"dBas=%g %% Inner stop band amplitude (dB)\n",dBas);
fprintf(fid,"Wasl=%g %% Lower stop band amplitude weight\n",Wasl);
fprintf(fid,"Wasu=%g %% Upper stop band amplitude weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Delay pass band lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Delay pass band upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal passband filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Delay pass band weight\n",Wtp);
fclose(fid);

print_polynomial(k1,"k1",strcat(strf,"_k1_coef.m"),nscale);
print_polynomial(c1,"c1",strcat(strf,"_c1_coef.m"),nscale);

eval(sprintf(["save %s.mat " ...
              " k0 epsilon0 p0 c0 ctol ftol nbits ndigits npoints ", ...
              " fapl fapu dBap Wap fasl fasu dBas Wasl Wasu ", ...
              " ftpl ftpu tp tpr Wtp ndigits_alloc k1 c1"],strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
