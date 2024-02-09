% socp_relaxation_schurFIRlattice_gaussian_16_nbits_test.m

% SOCP-relaxation optimisation of the response of a complementary FIR
% lattice Gaussian filter with 16-bit 3-signed-digit coefficients
% allocated with the algorithm of Lim et al.

% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("socp_relaxation_schurFIRlattice_gaussian_16_nbits_test.diary");
delete("socp_relaxation_schurFIRlattice_gaussian_16_nbits_test.diary.tmp");
diary socp_relaxation_schurFIRlattice_gaussian_16_nbits_test.diary.tmp

% Options
socp_relaxation_schurFIRlattice_gaussian_16_nbits_test_allocsd_Lim=true;
ndigits=3;
nbits=16;
nscale=2^(nbits-1);

tic;

maxiter=2000
verbose=false
tol=1e-8
ctol=tol

strf="socp_relaxation_schurFIRlattice_gaussian_16_nbits_test";

% Gaussian odd-length FIR filter specification
BTs=0.3;
R=8;
Ns=4;
k=(0:(Ns*R))-(Ns*R/2);
g_dc=(BTs/R)*sqrt(2*pi/log(2));
g=g_dc*exp(-((g_dc*sqrt(pi)*k).^2));

% Convert to complementary FIR filter
[g0,gc0,k0,khat0]=complementaryFIRlattice(g(:));
print_polynomial(g0,"g0=",strcat(strf,"_g0_coef.m"),"%12.9f"); 
print_polynomial(k0,"k0=",strcat(strf,"_k0_coef.m"),"%12.9f"); 
print_polynomial(khat0,"khat0=",strcat(strf,"_khat0_coef.m"),"%12.9f"); 
k0=k0(:);
khat0=khat0(:);
Nk=length(k0);

% Frequency response constraints
dBap=0.175;
Wap=1;
dBas=50;
dBasu=63; % 60 gives flat delay ?!?
Was=1e6;
tp=(R*Ns/2);
tpr=0.4;
Wtp=0.01;

% Amplitude constraints
nplot=1024;
[H0,wplot]=freqz(g0,1,nplot);
wa=wplot;
nm=min(find(20*log10(abs(H0))<-dBas))-1;
nmu=min(find(20*log10(abs(H0))<-dBasu))-1;
Asqd=[abs(H0(1:nm)).^2;zeros(nplot-nm,1)];
Asqdu=[(abs(H0(1:nm)).^2)*(10^(dBap/20)); ...
       (10^(-dBas/10))*ones(nmu-nm,1); ...
       (10^(-dBasu/10))*ones(nplot-nmu,1)];
Asqdl=[(abs(H0(1:nm)).^2)*(10^(-dBap/20));zeros(nplot-nm,1)];
Wa=[Wap*ones(nm,1);Was*ones(nplot-nm,1)];

% Group delay constraints
wt=wa(1:nm);
Td=tp*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Constraints on the coefficients
dmax=inf;rho=inf; % Unused
k0=k0(:);
khat0=khat0(:);
kkhat0=[k0;khat0];
Nk=length(k0);
kkhat0_u=ones(size(kkhat0));
kkhat0_l=-kkhat0_u;
kkhat0_active=find(kkhat0~=0);

% Convert g0 coefficients to 3-signed-digits
g0_sd=flt2SD(g0,nbits,ndigits);
print_polynomial(g0_sd,"g0_sd",nscale);
print_polynomial(g0_sd,"g0_sd",strcat(strf,"_g0_sd_coef.m"),nscale);

% Find the number of adders required to implement the g0_sd multiplications
[g0_digits,g0_adders]=SDadders(g0_sd,nbits);

% Allocate signed-digits to the lattice coefficients
if socp_relaxation_schurFIRlattice_gaussian_16_nbits_test_allocsd_Lim
  [Esq0,gradEsq0] = ...
    complementaryFIRlatticeEsq(k0,khat0, ...
                               wa,Asqd,ones(size(Wa)), ...
                               wt,Td,ones(size(Wt)), ...
                               wp,Pd,ones(size(Wp)));
  % Allocate signed digits to non-zero coefficients
  cost=0.36*(log2(abs(kkhat0))+log2(abs(gradEsq0')));
  ndigits_alloc=zeros(size(kkhat0));
  rR=ndigits*sum(double(abs(kkhat0)>=(2^(-nbits))));
  while rR>0
    [mc,imc]=max(cost);
    cost(imc)=cost(imc)-1;
    ndigits_alloc(imc)=ndigits_alloc(imc)+1;
    rR=rR-1;
  endwhile
else
  ndigits_alloc=zeros(size(kkhat0));
  ndigits_alloc(kkhat0_active)=ndigits;
endif
k_allocsd_digits=int16(ndigits_alloc(1:Nk));
khat_allocsd_digits=int16(ndigits_alloc((Nk+1):end));

% Find the signed-digit approximations to k0 and khat0
[kkhat0_sd,kkhat0_sdu,kkhat0_sdl]=flt2SD(kkhat0,nbits,ndigits_alloc);
k0_sd=kkhat0_sd(1:Nk);
k0_sd=k0_sd(:);
khat0_sd=kkhat0_sd((Nk+1):end);
khat0_sd=khat0_sd(:);
print_polynomial(k0_sd,"k0_sd",nscale);
print_polynomial(k0_sd,"k0_sd",strcat(strf,"_k0_sd_coef.m"),nscale);
print_polynomial(khat0_sd,"khat0_sd",nscale);
print_polynomial(khat0_sd,"khat0_sd",strcat(strf,"_khat0_sd_coef.m"),nscale);

% Initialise kkhat_active
kkhat0_sdul=kkhat0_sdu-kkhat0_sdl;
kkhat0_active=find(kkhat0_sdul~=0);
n_active=length(kkhat0_active);
% Check for consistent upper and lower bounds
if any(kkhat0_sdl>kkhat0_sdu)
  error("found kkhat0_sdl>kkhat0_sdu");
endif
if any(kkhat0_sdl>kkhat0_sdu)
  error("found kkhat0_sdl>kkhat0_sdu");
endif
if any(kkhat0_sd(kkhat0_active)>kkhat0_sdu(kkhat0_active))
  error("found kkhat0_sd(kkhat0_active)>kkhat0_sdu(kkhat0_active)");
endif
if any(kkhat0_sdl(kkhat0_active)>kkhat0_sd(kkhat0_active))
  error("found kkhat0_sdl(kkhat0_active)>kkhat0_sd(kkhat0_active)");
endif
if any(kkhat0(kkhat0_active)>kkhat0_sdu(kkhat0_active))
  error("found kkhat0(kkhat0_active)>kkhat0_sdu(kkhat0_active)");
endif
if any(kkhat0_sdl(kkhat0_active)>kkhat0(kkhat0_active))
  error("found kkhat0_sdl>kkhat0");
endif

% Find kkhat0 error
Esq0=complementaryFIRlatticeEsq(k0,khat0,wa,Asqd,Wa,wt,Td,Wt);

% Find kkhat0_sd error
Esq0_sd=complementaryFIRlatticeEsq(k0_sd,khat0_sd,wa,Asqd,Wa,wt,Td,Wt);

% Find the number of signed-digits required by kkhat0_sd
[kkhat0_digits,kkhat0_adders]=SDadders(kkhat0_sd(kkhat0_active),nbits);

% Plot initial filter response
strt=sprintf("Gaussian filter impulse response : BTs=%g,R=%d,Ns=%d",BTs,R,Ns);
plot((0:(Ns*R))/R,g0);
ylabel("Amplitude")
xlabel("Symbols")
title(strt);
grid("on");
print(strcat(strf,"_g0_impulse"),"-dpdflatex");
close
strt=strcat(strt,sprintf(",nbits=%d,ndigits=%d",nbits,ndigits));
nplot=1024;
[H0,wplot]=freqz(g0,1,nplot);
H0_sd=freqz(g0_sd,1,wplot);
Asq_kkhat0_sd=complementaryFIRlatticeAsq(wplot,k0_sd,khat0_sd);
fTs=wplot*0.5*R/pi;
plot(fTs,20*log10(abs(H0)),"linestyle","-", ...
     fTs,20*log10(abs(H0_sd)),"linestyle",":", ...
     fTs,10*log10(Asq_kkhat0_sd),"linestyle","--" );
xlabel("Frequency(Normalised to 1/Ts)");
ylabel("Amplitude(dB)");
title(strt);
legend("exact","signed-digit(direct)","signed-digit(lattice)");
legend("location","northeast");
legend("boxoff");
legend("left");
axis([0 fTs(end) -120 10]);
grid("on");
print(strcat(strf,"_g0_response"),"-dpdflatex");
close

% Initialise the vector of filter coefficients to be optimised
kkhat=zeros(size(kkhat0));
kkhat(kkhat0_active)=kkhat0(kkhat0_active);
kkhat_l=kkhat0_l;
kkhat_u=kkhat0_u;
kkhat_active=kkhat0_active;

% Fix one coefficient at each iteration 
while ~isempty(kkhat_active)
  
  % Define filter coefficients 
  [kkhat_sd,kkhat_sdu,kkhat_sdl]=flt2SD(kkhat,nbits,ndigits_alloc);
  kkhat_sdul=kkhat_sdu-kkhat_sdl;
  kkhat_b=kkhat;
  kkhat_bl=kkhat_l;
  kkhat_bu=kkhat_u;
  
  % Ito et al. suggest ordering the search by max(kkhat_sdu-kkhat_sdl)
  [kkhat_max,kkhat_max_n]=max(kkhat_sdul(kkhat_active));
  coef_n=kkhat_active(kkhat_max_n);
  kkhat_bl(coef_n)=kkhat_sdl(coef_n);
  kkhat_bu(coef_n)=kkhat_sdu(coef_n);

  % Try to solve the current SOCP problem with bounds kkhat_bu and kkhat_bl
  try
    % Find the SOCP PCLS solution for the remaining active coefficents
    [nextk,nextkhat,slb_iter,opt_iter,func_iter,feasible] = ...
      complementaryFIRlattice_slb(@complementaryFIRlattice_socp_mmse, ...
                                  kkhat_b(1:Nk),kkhat_b((Nk+1):end), ...
                                  kkhat_bu,kkhat_bl,kkhat_active,dmax, ...
                                  wa,Asqd,Asqdu,Asqdl,Wa, ...
                                  wt,Td,Tdu,Tdl,Wt, ...
                                  wp,Pd,Pdu,Pdl,Wp, ...
                                  maxiter,tol,ctol,verbose);
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
    print_polynomial(kkhat_active,"kkhat_active");
    error("SOCP problem infeasible!");
  endif

  % Fix coef_n
  nextkkhat=[nextk(:);nextkhat(:)];
  alpha=(nextkkhat(coef_n)- ...
         ((kkhat_sdu(coef_n)+kkhat_sdl(coef_n))/2))/(kkhat_sdul(coef_n)/2);
  if alpha>=0
    nextkkhat(coef_n)=kkhat_sdu(coef_n);
  else
    nextkkhat(coef_n)=kkhat_sdl(coef_n);
  endif
  kkhat=nextkkhat;
  kkhat_active(kkhat_max_n)=[];
  printf("Fixed kkhat(%d)=%13.10f\n",coef_n,kkhat(coef_n));
  printf("kkhat_active=[ ");printf("%d ",kkhat_active);printf("];\n\n");

endwhile

% Show results
kkhat_min=kkhat;
k_min=kkhat(1:Nk);
khat_min=kkhat((Nk+1):end);
Esq_min=complementaryFIRlatticeEsq(k_min,khat_min,wa,Asqd,Wa,wt,Td,Wt);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
print_polynomial(k_min,"k_min",nscale);
print_polynomial(k_min,"k_min",strcat(strf,"_k_min_coef.m"),nscale);
print_polynomial(khat_min,"khat_min",nscale);
print_polynomial(khat_min,"khat_min",strcat(strf,"_khat_min_coef.m"),nscale);
% Find the number of signed-digits and adders used
[kkhat_digits,kkhat_adders]=SDadders(kkhat_min(kkhat0_active),nbits);
printf("%d signed-digits used\n",kkhat_digits);
printf("%d %d-bit adders used for coefficient multiplications\n",
       kkhat_adders,nbits);

% Filter a quantised noise signal and check the state variables
nsamples=2^12;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u); 
u=round(u*nscale);
[y,yc,xx]=complementaryFIRlatticeFilter(k0,khat0,u,"none");
stdx=std(xx)
[yf,ycf,xxf]=complementaryFIRlatticeFilter(k_min,khat_min,u,"round");
stdxf=std(xxf)

% Amplitude and phase at local peaks
Asq=complementaryFIRlatticeAsq(wa,k_min,khat_min);
vAl=local_max(Asqdl-Asq);
vAu=local_max(Asq-Asqdu);
wAsqS=unique([wa(vAl);wa(vAu);wa([1,nm,end])]);
AsqS=complementaryFIRlatticeAsq(wAsqS,k_min,khat_min);
printf("k,khat_min:fAsqS=[ ");printf("%f ",wAsqS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,khat_min:AsqS=[ ");printf("%f ",10*log10(AsqS'));printf(" ] (dB)\n");
T=complementaryFIRlatticeT(wt,k_min,khat_min);
vTl=local_max(Tdl-T);
vTu=local_max(T-Tdu);
wTS=sort(unique([wt(vTl);wt(vTu);wt([1,nm,end])]));
TS=complementaryFIRlatticeT(wTS,k_min,khat_min);
printf("k,khat_min:fTS=[ ");printf("%f ",wTS'*0.5/pi);printf(" ] (fs==1)\n");
printf("k,khat_min:TS=[ ");printf("%f ",TS);printf("] (samples)\n");

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_kkhat_min_cost.tab"),"wt");
fprintf(fid,"%d-bit %d-signed-digit(direct-folded)& %d & %d \\\\\n",
        nbits,ndigits,g0_digits,g0_adders);
fprintf(fid,"%d-bit %d-signed-digit(lattice)& %d & %d \\\\\n",
        nbits,ndigits,kkhat0_digits,kkhat0_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %d & %d \\\\\n",
        nbits,ndigits,kkhat_digits,kkhat_adders);
fclose(fid);

% Plot response
Asq_kkhat0=complementaryFIRlatticeAsq(wa,k0,khat0);
Asq_kkhat0_sd=complementaryFIRlatticeAsq(wa,k0_sd,khat0_sd);
Asq_kkhat_min=complementaryFIRlatticeAsq(wa,k_min,khat_min);
fa=R*wa*0.5/pi;
plot(fa,10*log10(Asq_kkhat0),"linestyle","-", ...
     fa,20*log10(abs(H0_sd)),"linestyle",":", ...
     fa,10*log10(Asq_kkhat0_sd),"linestyle","--", ...
     fa,10*log10(Asq_kkhat_min),"linestyle","-.", ...
     fa,10*log10(Asqdu),"linestyle","-");
legend("exact","s-d(direct)","s-d(lattice)","s-d(SOCP-relax)","Asqdu");
legend("location","northeast");
legend("boxoff");
legend("left");
ylabel("Amplitude(dB)");
xlabel("Frequency(Units of 1/Ts)");
title(strt);
axis([0  fa(end) -120 10]);
grid("on");
print(strcat(strf,"_kkhat_min"),"-dpdflatex");
close
H0_ratio=10*log10((abs(H0_sd(1:nm)).^2)./Asq_kkhat0(1:nm));
Asq_kkhat0_sd_ratio=10*log10(Asq_kkhat0_sd(1:nm)./Asq_kkhat0(1:nm));
Asq_kkhat_min_ratio=10*log10(Asq_kkhat_min(1:nm)./Asq_kkhat0(1:nm));
Asqdu_ratio=10*log10(Asqdu(1:nm)./Asq_kkhat0(1:nm));
Asqdl_ratio=10*log10(Asqdl(1:nm)./Asq_kkhat0(1:nm));
fam=R*wa(1:nm)*0.5/pi;
plot(fam,Asq_kkhat0_sd_ratio,"linestyle","--", ...
     fam,Asq_kkhat_min_ratio,"linestyle","-.", ...
     fam,H0_ratio,"linestyle",":", ...
     fam,Asqdu_ratio,"linestyle","-", ...
     fam,Asqdl_ratio,"linestyle","-");
legend("s-d(Lim)","s-d(SOCP-relax)","s-d(direct)");
legend("location","southwest");
legend("boxoff");
legend("left");
ylabel("Amplitude error(dB)");
xlabel("Frequency(Units of 1/Ts)");
title(strt);
axis([0 fam(end) -dBap dBap]);
axis([0 fam(end) -0.2 0.2]);
grid("on");
print(strcat(strf,"_kkhat_min_pass"),"-dpdflatex");
close
T_kkhat0=complementaryFIRlatticeT(wt,k0,khat0);
T_kkhat0_sd=complementaryFIRlatticeT(wt,k0_sd,khat0_sd);
T_kkhat_min=complementaryFIRlatticeT(wt,k_min,khat_min);
ft=R*wt*0.5/pi;
plot(ft,T_kkhat0_sd,"linestyle","--", ...
     ft,T_kkhat_min,"linestyle","-.", ...
     ft,Tdu,"linestyle","-", ...
     ft,Tdl,"linestyle","-");
axis([0 ft(end) tp-tpr tp+tpr]);
ylabel("Delay(samples)");
xlabel("Frequency(Units of 1/Ts)");
legend("s-d(Lim)","s-d(SOCP-relax)");
legend("location","southwest");
legend("boxoff");
legend("left");
title(strt);
grid("on");
print(strcat(strf,"_kkhat_min_delay"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"BTs=%g %% Bandwidth-Symbol-rate product\n",BTs);
fprintf(fid,"Ns=%g %% Filter width in symbols\n",Ns);
fprintf(fid,"R=%d %% Samples-per-symbol\n",R);
fprintf(fid,"tol=%g %% Tolerance on coefficient update vector\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"nplot=%d %% Frequency points across the band\n",nplot);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"dBas=%d %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"dBasu=%d %% Amplitude upper stop band peak-to-peak ripple\n",dBasu);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fprintf(fid,"tp=%g %% Nominal pass band filter group delay (samples)\n",tp);
fprintf(fid,"tpr=%g %% Delay pass band peak-to-peak ripple (rad.)\n",tpr);
fprintf(fid,"Wtp=%d %% Delay pass band weight\n",Wtp);
fclose(fid);

% Save results
save socp_relaxation_schurFIRlattice_gaussian_16_nbits_test.mat ...
     R Ns BTs g0 k0 khat0 tol ctol nbits ndigits ndigits_alloc ...
     nm Asqd dBap dBas dBasu Wap Was Td tp tpr Wtp k_min khat_min 
       
% Done
toc;
diary off
movefile socp_relaxation_schurFIRlattice_gaussian_16_nbits_test.diary.tmp ...
         socp_relaxation_schurFIRlattice_gaussian_16_nbits_test.diary;
