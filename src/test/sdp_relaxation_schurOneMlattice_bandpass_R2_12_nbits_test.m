% sdp_relaxation_schurOneMlattice_bandpass_R2_12_nbits_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

% SDP relaxation optimisation of a Schur one-multiplier lattice
% bandpass filter 12-bit signed-digit coefficients

test_common;

strf="sdp_relaxation_schurOneMlattice_bandpass_R2_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
verbose=false;
ftol=1e-3;
ctol=ftol/10;

nbits=12;
nscale=2^(nbits-1);
ndigits=4;

dmax=inf;
rho=127/128

% Bandpass R=2 filter specification
fapl=0.1,fapu=0.2,dBap=2,Wap=1
fasl=0.05,fasu=0.25,dBas=35,Wasl=100,Wasu=100
ftpl=0.1,ftpu=0.2,tp=16,tpr=0.4,Wtp=1

% Initial filter (found by schurOneMlattice_sqp_slb_bandpass_R2_test.m)
schurOneMlattice_sqp_slb_bandpass_R2_test_k2_coef;
k0=k2; clear k2;
schurOneMlattice_sqp_slb_bandpass_R2_test_epsilon2_coef;
epsilon0=epsilon2; clear epsilon2;
schurOneMlattice_sqp_slb_bandpass_R2_test_p2_coef;
p0=p2; clear p2;
schurOneMlattice_sqp_slb_bandpass_R2_test_c2_coef;
c0=c2; clear c2;

% Amplitude constraints
n=500;
wa=(0:(n-1))'*pi/n;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Asqd=[zeros(napl-1,1); ...
      ones(napu-napl+1,1); ...
      zeros(n-napu,1)];
Asqdu=[(10^(-dBas/10))*ones(nasl,1); ...
       ones(nasu-nasl-1,1); ...
       (10^(-dBas/10))*ones(n-nasu+1,1)];
Asqdl=[zeros(napl-1,1); ...
       (10^(-dBap/10))*ones(napu-napl+1,1); ...
       zeros(n-napu,1)];
Wa=[Wasl*ones(nasl,1); ...
         zeros(napl-nasl-1,1); ...
         Wap*ones(napu-napl+1,1); ...
         zeros(nasu-napu-1,1); ...
         Wasu*ones(n-nasu+1,1)];
Wa=[Wasl*ones(nasl,1); ...
         zeros(napl-nasl-1,1); ...
         Wap*ones(napu-napl+1,1); ...
         zeros(nasu-napu-1,1); ...
         Wasu*ones(n-nasu+1,1)];
% Sanity checks
nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu,nasu+1];
printf ...
  ("nchka=[nasl-1,nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu,nasu+1];\n");
printf("nchka=[ ");printf("%6d ",nchka);printf("];\n");
printf("f(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)'/(2*pi));printf("];\n");
printf("Asqd(nchka)=[ ");printf("%6.4g ",Asqd(nchka)');printf("];\n");
printf("Asqdu(nchka)=[ ");printf("%6.4g ",Asqdu(nchka)');printf("];\n");
printf("Asqdl(nchka)=[ ");printf("%6.4g ",Asqdl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Group delay constraints
ntpl=floor(n*ftpl/0.5);
ntpu=ceil(n*ftpu/0.5);
wt=(ntpl:ntpu)'*pi/n;
ntp=length(wt);
Td=tp*ones(ntp,1);
Tdu=(tp+(tpr/2))*ones(ntp,1);
Tdl=(tp-(tpr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Phase constraints
wp=[];Pd=[];Pdu=[];Pdl=[];Wp=[];

% dAsqdw constraints
wd=[];Dd=[];Ddu=[];Ddl=[];Wd=[];

% Constraints on the coefficients
k0=k0(:);
c0=c0(:);
Nk=length(k0);
Nc=length(c0);
kc_u=[rho*ones(size(k0));10*ones(size(c0))];
kc_l=-kc_u;
kc0_active=[find((k0)~=0);(Nk+(1:Nc))'];
Rk=1:Nk;
Rc=Nk+(1:Nc);

% Allocate digits
waf=wa([1 nasl napl napu nasu end]);
Adf=[0 0 1 0 0];
Waf=[Wasl 0 Wap 0 Wasu];
ndigits_alloc=schurOneMlattice_allocsd_Lim(nbits,ndigits,k0,epsilon0,p0,c0, ...
                                           wa,Asqd,ones(size(wa)), ...
                                           wt,Td,ones(size(wt)));

k_allocsd_digits=int16(ndigits_alloc(Rk));
c_allocsd_digits=int16(ndigits_alloc(Rc));

printf("k_allocsd_digits=[ ");
printf("%2d ",k_allocsd_digits);printf("]';\n");
print_polynomial(k_allocsd_digits,"k_allocsd_digits", ...
                 strcat(strf,"_k_allocsd_digits.m"),"%2d");

printf("c_allocsd_digits=[ ");
printf("%2d ",c_allocsd_digits);printf("]';\n");
print_polynomial(c_allocsd_digits,"c_allocsd_digits", ...
                 strcat(strf,"_c_allocsd_digits.m"),"%2d");

% Find the signed-digit approximations to kc0
kc0=[k0;c0];
[kc0_sd,kc0_sdu,kc0_sdl]=flt2SD(kc0,nbits,ndigits);
[kc0_sd_digits,kc0_sd_adders]=SDadders(kc0_sd,nbits);

[kc0_Lim,kc0_Lim_sdu,kc0_Lim_sdl]=flt2SD(kc0,nbits,ndigits_alloc);
[kc0_Lim_digits,kc0_Lim_adders]=SDadders(kc0_Lim,nbits);
print_polynomial(kc0_Lim(Rk),"k0_Lim",nscale);
print_polynomial(kc0_Lim(Rk),"k0_Lim", ...
                 strcat(strf,"_k0_Lim_coef.m"),nscale);
print_polynomial(kc0_Lim(Rc),"c0_Lim",nscale);
print_polynomial(kc0_Lim(Rc),"c0_Lim", ...
                 strcat(strf,"_c0_Lim_coef.m"),nscale);

% Find initial mean-squared errrors
Esq0=schurOneMlatticeEsq(k0,epsilon0,p0,c0,wa,Asqd,Wa,wt,Td,Wt);
Esq0_sd=schurOneMlatticeEsq(kc0_sd(Rk),epsilon0,p0,kc0_sd(Rc), ...
                            wa,Asqd,Wa,wt,Td,Wt);
Esq0_sd_Lim=schurOneMlatticeEsq(kc0_Lim(Rk),epsilon0,p0,kc0_Lim(Rc), ...
                                wa,Asqd,Wa,wt,Td,Wt);

% Define filter coefficients
kc0_sd_delta=(kc0_Lim_sdu-kc0_Lim_sdl)/2;
kc0_sd_x=(kc0_Lim_sdu+kc0_Lim_sdl)/2;
kc0_sd_x_active=find((kc0_sd_x)~=0);
[Esq0_sd_x,gradEsq0_sd_x]=schurOneMlatticeEsq ...
                            (kc0_sd_x(Rk),epsilon0,p0,kc0_sd_x(Rc), ...
                             wa,Asqd,Wa,wt,Td,Wt);

% Solve the SDP problem with SeDuMi
[k0_sdp,c0_sdp,socp_iter,func_iter,feasible] = ... 
  schurOneMlattice_sdp_mmse ...
    ([], ...
     kc0_sd_x(Rk),epsilon0,p0,kc0_sd_x(Rc), ...
     kc0_Lim_sdu,kc0_Lim_sdl,kc0_sd_x_active,kc0_sd_delta, ...
     wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
     wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd,maxiter,ftol,ctol,verbose);
if feasible==false
  error("schurOneMlattice_sdp_mmse failed!");
endif
print_polynomial(k0_sdp,"k0_sdp",nscale);
print_polynomial(k0_sdp,"k0_sdp", ...
                 strcat(strf,"_k0_sdp_coef.m"),nscale);
print_polynomial(c0_sdp,"c0_sdp",nscale);
print_polynomial(c0_sdp,"c0_sdp", ...
                 strcat(strf,"_c0_sdp_coef.m"),nscale);
kc0_sdp=[k0_sdp(:);c0_sdp(:)];
[kc0_sdp_digits,kc0_sdp_adders]=SDadders(kc0_sdp,nbits);
Esq0_sdp=schurOneMlatticeEsq(k0_sdp,epsilon0,p0,c0_sdp, ...
                             wa,Asqd,Wa,wt,Td,Wt);

% Find coefficients with successive relaxation
kc=zeros(size(kc0));
kc(kc0_sd_x_active)=kc0(kc0_sd_x_active);
kc_active=kc0_sd_x_active;
kc_hist=zeros(length(kc0_sd_x_active));
kc_active_max_n_hist=[];

% Fix one coefficient at each iteration 
while 1
  
  % Find the signed-digit filter coefficients 
  [kc_sd,kc_sdu,kc_sdl]=flt2SD(kc,nbits,ndigits_alloc);
  
  % Find the SDP solution for the active coefficients
  kc_delta=(kc_sdu-kc_sdl)/2;
  kc_x=(kc_sdu+kc_sdl)/2;
  [k_sdp,c_sdp,socp_iter,func_iter,feasible] = ...
    schurOneMlattice_sdp_mmse ...
      ([], ...
       kc_x(Rk),epsilon0,p0,kc_x(Rc), ...
       kc_sdu,kc_sdl,kc_active,kc_delta, ...
       wa,Asqd,Asqdu,Asqdl,Wa,wt,Td,Tdu,Tdl,Wt, ...
       wp,Pd,Pdu,Pdl,Wp,wd,Dd,Ddu,Ddl,Wd,maxiter,ftol,ctol,verbose);
  if feasible==false
    error("schurOneMlattice_sdp_mmse failed!");
  endif

  % Ito et al. suggest ordering the search by max(kc_sdu-kc_sdl)
  [kc_max,kc_max_n]=max(kc_delta(kc_active));
  coef_n=kc_active(kc_max_n);

  % Fix the coefficient with the largest kc_sdul to the SDP value
  kc0_sdp=[k_sdp(:);c_sdp(:)];
  kc(coef_n)=kc0_sdp(coef_n);
  kc_active_max_n_hist=[kc_active_max_n_hist,kc_active(kc_max_n)];
  kc_hist(:,length(kc_active_max_n_hist))=kc(kc0_sd_x_active);
  kc_active(kc_max_n)=[];
  printf("\nFixed kc(%d)=%g/%d\n",coef_n,kc(coef_n)*nscale,nscale);
  printf("kc=[ ");printf("%g ",kc'*nscale);printf("]/%d;\n",nscale);
  printf("kc_active=[ ");printf("%d ",kc_active);printf("];\n\n");
  
  % Check if done
  if length(kc_active)==0
    kc_min=kc;
    break;
  endif
  
  % Try to solve the current SOCP problem for the active coefficients
  try
    [nextk,nextc,slb_iter,opt_iter,func_iter,feasible] = ...
    schurOneMlattice_slb(@schurOneMlattice_socp_mmse, ...
                         kc(Rk),epsilon0,p0,kc(Rc), ...
                         kc_u,kc_l,kc_active,dmax, ...
                         wa,Asqd,Asqdu,Asqdl,Wa, ...
                         wt,Td,Tdu,Tdl,Wt, ...
                         wp,Pd,Pdu,Pdl,Wp, ...
                         wd,Dd,Ddu,Ddl,Wd, ...
                         maxiter,ftol,ctol,verbose);
    kc=[nextk(:);nextc(:)];
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
    error("SOCP problem infeasible!");
  endif

endwhile

[kc_min_digits,kc_min_adders]=SDadders(kc_min,nbits);
printf("kc_min_digits=%d,kc_min_adders=%d\n",kc_min_digits,kc_min_adders);

Esq_min=schurOneMlatticeEsq(kc_min(Rk),epsilon0,p0,kc_min(Rc),...
                            wa,Asqd,Wa,wt,Td,Wt);
printf("Esq_min=%g\n",Esq_min);

print_polynomial(kc_min(Rk),"k_min",nscale);
print_polynomial(kc_min(Rk),"k_min",strcat(strf,"_k_min_coef.m"),nscale);
print_polynomial(kc_min(Rc),"c_min",nscale);
print_polynomial(kc_min(Rc),"c_min",strcat(strf,"_c_min_coef.m"),nscale);

% Calculate response
Asq_kc0=schurOneMlatticeAsq(wa,k0,epsilon0,p0,c0);
Asq_kc0_sd=schurOneMlatticeAsq(wa,kc0_sd(Rk),epsilon0,p0,kc0_sd(Rc));
Asq_kc0_Lim=schurOneMlatticeAsq(wa,kc0_Lim(Rk),epsilon0,p0,kc0_Lim(Rc));
Asq_kc0_sdp=schurOneMlatticeAsq(wa,kc0_sdp(Rk),epsilon0,p0,kc0_sdp(Rc));
Asq_kc_min=schurOneMlatticeAsq(wa,kc_min(Rk),epsilon0,p0,kc_min(Rc));
T_kc0=schurOneMlatticeT(wt,k0,epsilon0,p0,c0);
T_kc0_sd=schurOneMlatticeT(wt,kc0_sd(Rk),epsilon0,p0,kc0_sd(Rc));
T_kc0_Lim=schurOneMlatticeT(wt,kc0_Lim(Rk),epsilon0,p0,kc0_Lim(Rc));
T_kc0_sdp=schurOneMlatticeT(wt,kc0_sdp(Rk),epsilon0,p0,kc0_sdp(Rc));
T_kc_min=schurOneMlatticeT(wt,kc_min(Rk),epsilon0,p0,kc_min(Rc));

% Amplitude and delay at local peaks
vAl=local_max(Asqdl-Asq_kc_min);
vAu=local_max(Asq_kc_min-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,end])]);
AsqS=schurOneMlatticeAsq(wAsqS,kc_min(Rk),epsilon0,p0,kc_min(Rc));
printf("kc_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kc_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
vTl=local_max(Tdl-T_kc_min);
vTu=local_max(T_kc_min-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,end])]));
TS=schurOneMlatticeT(wTS,kc_min(Rk),epsilon0,p0,kc_min(Rc));
printf("kc_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("kc_min:TS=[ ");printf("%f ",TS');printf("] (Samples)\n");

% Find maximum stop band response
rsb=[1:nasl,nasu:n];
max_sb_Asq_kc0=10*log10(max(abs(Asq_kc0(rsb))))
max_sb_Asq_kc0_sd=10*log10(max(abs(Asq_kc0_sd(rsb))))
max_sb_Asq_kc0_Lim=10*log10(max(abs(Asq_kc0_Lim(rsb))))
max_sb_Asq_kc0_sdp=10*log10(max(abs(Asq_kc0_sdp(rsb))))
max_sb_Asq_kc_min=10*log10(max(abs(Asq_kc_min(rsb))))

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & %4.1f & & \\\\\n",Esq0,max_sb_Asq_kc0);
fprintf(fid,"%d-bit %d-signed-digit & %8.6f & %4.1f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd,max_sb_Asq_kc0_sd,kc0_sd_digits,kc0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(Lim) & %8.6f & %4.1f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd_Lim,max_sb_Asq_kc0_Lim, ...
        kc0_Lim_digits,kc0_Lim_adders);
fprintf(fid,"%d-bit %d-signed-digit(SDP) & %8.6f & %4.1f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sdp,max_sb_Asq_kc0_sdp,kc0_sdp_digits,kc0_sdp_adders);
fprintf(fid,"%d-bit %d-signed-digit(min) & %8.6f & %4.1f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_min,max_sb_Asq_kc_min,kc_min_digits,kc_min_adders);
fclose(fid);

% Plot stop band amplitude response
plot(wa*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_kc0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_kc0_Lim)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_kc_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -40 -30]);
strt=sprintf(["Schur one-multiplier lattice bandpass filter stop-band ", ...
 "(nbits=%d,ndigits=%d) : fasl=%g,fasu=%g,dBas=%g"],nbits,ndigits,fasl,fasu,dBas);
title(strt);
legend("exact","s-d","s-d(Lim)","s-d(min)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_stop"),"-dpdflatex");
close

% Plot passband response
plot(wa*0.5/pi,10*log10(abs(Asq_kc0)),"linestyle","-", ...
     wa*0.5/pi,10*log10(abs(Asq_kc0_sd)),"linestyle",":", ...
     wa*0.5/pi,10*log10(abs(Asq_kc0_Lim)),"linestyle","--", ...
     wa*0.5/pi,10*log10(abs(Asq_kc_min)),"linestyle","-.");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([fapl fapu -2 1]);
strt=sprintf(["Schur one-multiplier lattice bandpass filter pass-band amplitude ", ...
 "(nbits=%d,ndigits=%d) : fapl=%g,fapu=%g,dBap=%g"],nbits,ndigits,fapl,fapu,dBap);
title(strt);
legend("exact","s-d","s-d(Lim)","s-d(min)");
legend("location","south");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_pass"),"-dpdflatex");
close

% Plot delay response
plot(wt*0.5/pi,T_kc0,"linestyle","-", ...
     wt*0.5/pi,T_kc0_sd,"linestyle",":", ...
     wt*0.5/pi,T_kc0_Lim,"linestyle","--", ...
     wt*0.5/pi,T_kc_min,"linestyle","-.");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([ftpl ftpu (tp+(tpr/2)*[-1 1])]);
strt=sprintf(["Schur one-multiplier lattice bandpass filter pass-band delay ", ...
 "(nbits=%d,ndigits=%d) : ftpl=%g,ftpu=%g,tpr=%g"],nbits,ndigits,ftpl,ftpu,tpr);
title(strt);
legend("exact","s-d","s-d(Lim)","s-d(min)");
legend("location","south");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Plot coefficient histories
kc0_active=kc0(kc0_sd_x_active);
plot(0:length(kc0_active),([kc0_active,kc_hist]-kc0_active)'*nscale);
axis([0 length(kc0_active)]);
title(sprintf(["Schur one-multiplier lattice bandpass filter : ", ...
 "%d bit %d signed-digit coefficients difference from exact"], nbits,ndigits));
xlabel("Relaxation step");
ylabel("Bits difference from exact");
% I have not worked out how to insert a line break in a text string with pdflatex
str_active1=sprintf("The coefficients [k,c] were fixed in the order :");
for l=1:10,
  str_active1=strcat(str_active1,sprintf(" %d,",kc_active_max_n_hist(l)));
endfor
str_active2=sprintf("%d",kc_active_max_n_hist(11));
for l=12:length(kc_active_max_n_hist)
  str_active2=strcat(str_active2,sprintf(", %d",kc_active_max_n_hist(l)));
endfor
text(0.5,-2.4,str_active1,"fontsize",8);
text(0.5,-2.7,str_active2,"fontsize",8);
print(strcat(strf,"_coef_hist"),"-dpdflatex"); 
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coefficient update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%g %% Frequency points across the band\n",n);
fprintf(fid,"Nk=%d %% Filter order\n",Nk);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%g %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%g %% Amplitude upper stop band weight\n",Wasu);
fprintf(fid,"ftpl=%g %% Pass band delay lower edge\n",ftpl);
fprintf(fid,"ftpu=%g %% Pass band delay upper edge\n",ftpu);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple\n",tpr);
fprintf(fid,"Wtp=%g %% Delay pass band weight\n",Wtp);
fclose(fid);

% Save results
eval(sprintf(["save %s.mat ftol ctol nbits nscale ndigits ndigits_alloc n ", ...
 "fapl fapu dBap Wap fasl fasu dBas Wasl Wasu ftpl ftpu tp tpr Wtp ", ...
 "kc0_sd kc0_Lim kc0_sdp kc_min"],strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
