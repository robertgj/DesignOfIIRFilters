% sqp_relaxation_schurOneMlattice_bandpass_10_nbits_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

% Optimisation of Schur one-multiplier lattice bandpass filter response with
% 10-bit signed-digit coefficients having Ito et al. allocation and SQP
% relaxation solution.

test_common;

strf="sqp_relaxation_schurOneMlattice_bandpass_10_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
verbose=false;

dBass=36;
Wtp=2;
use_schurOneMlattice_allocsd_Ito=true
schurOneMlattice_bandpass_10_nbits_common;

% Initial coefficients
kc=zeros(size(kc0));
kc(kc0_active)=kc0(kc0_active);
kc_l=kc0_l;
kc_u=kc0_u;
kc_active=kc0_active;
p_ones=ones(size(k0));

% Fix one coefficient at each iteration 
while ~isempty(kc_active)
  
  % Define filter coefficients 
  [kc_sd,kc_sdu,kc_sdl]=flt2SD(kc,nbits,ndigits_alloc);
  kc_sdul=kc_sdu-kc_sdl;
  kc_b=kc;
  kc_bl=kc_l;
  kc_bu=kc_u;
  
  % Ito et al. suggest ordering the search by max(kc_sdu-kc_sdl)
  [kc_max,kc_max_n]=max(kc_sdul(kc_active));
  coef_n=kc_active(kc_max_n);
  kc_bl(coef_n)=kc_sdl(coef_n);
  kc_bu(coef_n)=kc_sdu(coef_n);

  % Try to solve the current SQP problem with bounds kc_bu and kc_bl
  try
    % Find the SQP PCLS solution for the remaining active coefficents
    [nextk,nextc,slb_iter,opt_iter,func_iter,feasible] = ...
    schurOneMlattice_slb(@schurOneMlattice_sqp_mmse, ...
                         kc_b(1:Nk),epsilon0,p_ones,kc_b((Nk+1):end), ...
                         kc_bu,kc_bl,kc_active,dmax, ...
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
    error("SQP problem infeasible!");
  endif

  % Fix coef_n
  nextkc=[nextk(:);nextc(:)];
  if 1
    % Choose nearest signed-digit coefficient
    alpha= ...
      (nextkc(coef_n)-((kc_sdu(coef_n)+kc_sdl(coef_n))/2))/(kc_sdul(coef_n)/2);
    if alpha>=0
      nextkc(coef_n)=kc_sdu(coef_n);
    else
      nextkc(coef_n)=kc_sdl(coef_n);
    endif
  else
    % Choose lowest Esq signed-digit coefficient
    kc_ul=nextkc;
    [~,kc_ul_sdu,kc_ul_sdl]=flt2SD(kc_ul(coef_n),nbits,ndigits_alloc(coef_n))
    kc_ul(coef_n)=kc_ul_sdu;
    Esq_u=schurOneMlatticeEsq(kc_ul(1:Nk),epsilon0,p_ones,kc_ul((Nk+1):end), ...
                              wa,Asqd,Wa,wt,Td,Wt)
    kc_ul(coef_n)=kc_ul_sdl;
    Esq_l=schurOneMlatticeEsq(kc_ul(1:Nk),epsilon0,p_ones,kc_ul((Nk+1):end), ...
                              wa,Asqd,Wa,wt,Td,Wt)
    if Esq_l<Esq_u
      nextkc(coef_n)=kc_ul_sdl
    else 
      nextkc(coef_n)=kc_ul_sdu
    endif
  endif
  kc=nextkc;
  kc_active(kc_max_n)=[];
  printf("Fixed kc(%d)=%g/%d\n",coef_n,kc(coef_n)*nscale,nscale);
  printf("kc_active=[ ");printf("%d ",kc_active);printf("];\n\n");

endwhile

% Show results
kc_min=kc;
k_min=kc(1:Nk);
c_min=kc((Nk+1):end);

Esq_min=schurOneMlatticeEsq(k_min,epsilon0,p_ones,c_min,wa,Asqd,Wa,wt,Td,Wt);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);

printf("ndigits_alloc=[ ");printf("%d ",ndigits_alloc);printf("]\n");
k_allocsd_digits=int16(ndigits_alloc(1:Nk));
c_allocsd_digits=int16(ndigits_alloc((Nk+1):end));

printf("k_allocsd_digits=[ ");
printf("%2d ",k_allocsd_digits);printf("]';\n");
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%2d");

printf("c_allocsd_digits=[ ");
printf("%2d ",c_allocsd_digits);printf("]';\n");
print_polynomial(c_allocsd_digits,"c_allocsd_digits", ...
                 strcat(strf,"_c_allocsd_digits.m"),"%2d");

print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
print_polynomial(c_min,"c_min",nscale);
print_polynomial(c_min,"c_min",strcat(strf,"_c_min_coef.m"),nscale);

% Find the number of signed-digits and adders used
[kc_digits,kc_adders]=SDadders(kc_min(kc0_active),nbits);
printf("%d signed-digits used\n",kc_digits);
fid=fopen(strcat(strf,"_signed_digits.tab"),"wt");
fprintf(fid,"%d",kc_digits);
fclose(fid);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kc_adders,nbits);
fid=fopen(strcat(strf,"_adders.tab"),"wt");
fprintf(fid,"%d",kc_adders);
fclose(fid);

% Filter a quantised noise signal and check the state variables
nsamples=2^12;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u); 
u=round(u*nscale);
[yap,y,xx]=schurOneMlatticeFilter(k0,epsilon0,p_ones,c0,u,"round");
stdx=std(xx)
[yapf,yf,xxf]= ...
schurOneMlatticeFilter(k_min,epsilon0,p_ones,c_min,u,"round");
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

% Compare with 3 signed-digit allocation
kc0_3sd=flt2SD(kc0,nbits,3);
kc0_3sd_active=find(kc0_3sd ~= 0);
[kc0_3sd_digits,kc0_3sd_adders]=SDadders(kc0_3sd(kc0_3sd_active),nbits);
printf("%d signed-digits used for 3-sd allocation\n",kc0_3sd_digits);
printf("%d %d-bit adders used for 3-sd coefficient multiplications\n",
       kc0_3sd_adders,nbits);
k0_3sd=kc0_3sd(1:Nk);
c0_3sd=kc0_3sd((Nk+1):end);
Esq0_3sd=schurOneMlatticeEsq(k0_3sd,epsilon0,p_ones,c0_3sd,wa,Asqd,Wa,wt,Td,Wt);

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %6.4f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit&%6.4f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_3sd,kc0_3sd_digits,kc0_3sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(Ito)&%6.4f & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,kc0_digits,kc0_adders);
fprintf(fid,"%d-bit %d-signed-digit(SQP-relax) & %6.4f & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,kc_digits,kc_adders);
fclose(fid);

% Calculate response
nplot=1000;
wplot=(0:(nplot-1))'*pi/nplot;
Asq_kc0=schurOneMlatticeAsq(wplot,k0,epsilon0,p0,c0);
Asq_kc0_sd=schurOneMlatticeAsq(wplot,k0_sd,epsilon0,p_ones,c0_sd);
Asq_kc_min=schurOneMlatticeAsq(wplot,k_min,epsilon0,p_ones,c_min);
Asq_kc0_3sd=schurOneMlatticeAsq(wplot,k0_3sd,epsilon0,p_ones,c0_3sd);
T_kc0=schurOneMlatticeT(wplot,k0,epsilon0,p0,c0);
T_kc0_sd=schurOneMlatticeT(wplot,k0_sd,epsilon0,p_ones,c0_sd);
T_kc_min=schurOneMlatticeT(wplot,k_min,epsilon0,p_ones,c_min);
T_kc0_3sd=schurOneMlatticeT(wplot,k0_3sd,epsilon0,p_ones,c0_3sd);

% Plot amplitude stop-band response
plot(wplot*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc0_3sd)),"linestyle",":", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc0_sd)),"linestyle","--", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -50 -30]);
strt=sprintf("Schur one-multiplier lattice bandpass filter stop-band \
(nbits=%d) : fasl=%g,fasu=%g,dBas=%g",nbits,fasl,fasu,dBas);
title(strt);
legend("exact","s-d","s-d(Ito)","s-d(SQP-relax)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot amplitude pass-band response
plot(wplot*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc0_3sd)),"linestyle",":", ... 
     wplot*0.5/pi,10*log10(abs(Asq_kc0_sd)),"linestyle","--", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0.1 0.2 -2 0.5]);
strt=sprintf("Schur one-multiplier lattice bandpass filter pass-band \
(nbits=%d) : fapl=%g,fapu=%g,dBap=%g",nbits,fapl,fapu,dBap);
title(strt);
legend("exact","s-d","s-d(Ito)","s-d(SQP-relax)");
legend("location","south");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_pass"),"-dpdflatex");
close

% Plot group-delay pass-band response
plot(wplot*0.5/pi,T_kc0,"linestyle","-", ...
     wplot*0.5/pi,T_kc0_3sd,"linestyle",":", ...
     wplot*0.5/pi,T_kc0_sd,"linestyle","--", ...
     wplot*0.5/pi,T_kc_min,"linestyle","-.");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0.09 0.21 15.8 16.2]);
strt=sprintf("Schur one-multiplier lattice bandpass filter pass-band \
(nbits=%d) : ftpl=%g,ftpu=%g,tp=%g,tpr=%g",nbits,ftpl,ftpu,tp,tpr);
 title(strt);
legend("exact","s-d","s-d(Ito)","s-d(SQP-relax)");
legend("location","southeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Plot responses for the introduction
print_for_web_page=false;
if print_for_web_page
  set(0,"defaultlinelinewidth",1.5);
endif
subplot(311)
plot(wplot*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
     wplot*0.5/pi,10*log10(abs(Asq_kc_min)),"linestyle","--");
ylabel("Passband(dB)");
axis([0 0.5 -2 0.5]);
legend("exact","3-s-d Ito and SQP");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
if ~print_for_web_page
  strt=sprintf("Schur one-multiplier lattice bandpass filter pass-band \
(nbits=%d) : ftpl=%g,ftpu=%g,tp=%g,tpr=%g",nbits,ftpl,ftpu,tp,tpr);
  title(strt);
endif
subplot(312)
Trange=floor(nplot*ftpl/0.5):ceil(nplot*ftpu/0.5);
plot(wplot(Trange)*0.5/pi,T_kc0(Trange),"linestyle","-", ...
     wplot(Trange)*0.5/pi,T_kc_min(Trange),"linestyle","--");
ylabel("Delay(samples)");
axis([0 0.5 15.9 16.1]);
grid("on");
subplot(313)
plot(wplot*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ... 
     wplot*0.5/pi,10*log10(abs(Asq_kc_min)),"linestyle","--");
ylabel("Stopband(dB)");
xlabel("Frequency");
axis([0 0.5 -50 -36]);
grid("on");
print(strcat(strf,"_intro"),"-dpdflatex");
if print_for_web_page
  print(strcat(strf,"_intro"),"-dsvg");
endif
close

% For the website icon
if print_for_web_page
  Arange=1:700;
  plot(wplot(Arange)*0.5/pi,10*log10(abs(Asq_kc0(Arange))),'linewidth',20);
  axis('off');
  print(strcat(strf,"_icon"),"-dsvg");
  system(sprintf('convert %s.svg -define icon:auto-resize=64,32,16 %s', ...
                 strcat(strf,"_icon"),'favicon.ico'));
  close
endif

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"maxiter=%d %% SQP iteration limit\n",maxiter);
fprintf(fid,"npoints=%d %% Frequency points across the band\n",npoints);
fprintf(fid,"%% length(c0)=%d %% Num. tap coefficients\n",length(c0));
fprintf(fid,"%% sum(k0~=0)=%d %% Num. non-zero all-pass coef.s\n",sum(k0~=0));
fprintf(fid,"dmax=%f %% Constraint on norm of coefficient SQP step size\n",dmax);
fprintf(fid,"rho=%f %% Constraint on allpass coefficients\n",rho);
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
eval(sprintf("save %s.mat ...\n\
     k0 epsilon0 p0 c0 ...\n\
     ftol ctol nbits nscale ndigits ndigits_alloc npoints ...\n\
     fapl fapu dBap Wap ...\n\
     fasl fasu dBas fasll fasuu dBass Wasl Wasu ...\n\
     ftpl ftpu tp tpr Wtp k_min c_min",strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
