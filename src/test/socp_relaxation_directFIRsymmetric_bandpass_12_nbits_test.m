% socp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

% Optimisation of Schur one-multiplier lattice bandpass filter response with
% 10-bit signed-digit coefficients having Ito et al. allocation and SOCP
% relaxation solution.

test_common;

strf="socp_relaxation_directFIRsymmetric_bandpass_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=5000
verbose=false;
tol=1e-5;
ctol=tol;

% Band pass filter
M=15;
fapl=0.1;fapu=0.2;Wap=1;dBap=2;
fasll=0.04;fasl=0.05;fasu=0.25;fasuu=0.26;Wasl=40;Wasu=40;dBass=37;dBas=43;

% Desired magnitude response
npoints=1000;
wa=(0:npoints)'*pi/npoints;
nasll=ceil(npoints*fasll/0.5)+1;
nasl=ceil(npoints*fasl/0.5)+1;
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
nasu=floor(npoints*fasu/0.5)+1;  
nasuu=floor(npoints*fasuu/0.5)+1;  
na=[1 nasl napl napu nasu length(wa)];
Ad=[zeros(napl-1,1); ...
    ones(napu-napl+1,1); ...
    zeros(npoints-napu+1,1)];
Adu=[(10^(-dBas/20))*ones(nasll,1); ...
     (10^(-dBass/20))*ones(nasl-nasll,1); ...
     ones(nasu-nasl-1,1); ...
     (10^(-dBass/20))*ones(nasuu-nasu,1);
     (10^(-dBas/20))*ones(npoints-nasuu+2,1)];
Adl=[-(10^(-dBas/20))*ones(napl-1,1); ...
      (10^(-dBap/20))*ones(napu-napl+1,1); ...
     -(10^(-dBas/20))*ones(npoints-napu+1,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(npoints-nasu+2,1)];

% Sanity checks
nchka=[nasll,nasll+1,nasl-1,nasl,nasl+1,napl-1,napl,napu,napu+1, ...
       nasu-1,nasu,nasu+1,nasuu-1,nasuu];
printf(["nchka=[nasll,nasll+1,nasl-1,nasl,nasl+1,napl-1,napl,napu,napu+1, ...\n", ...
 "       nasu-1,nasu,nasu+1,nasuu-1,nasuu];\n"]);
printf("nchka=[ ");printf("%d ",nchka);printf("];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",0.5*wa(nchka)'/pi);printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Make an initial band pass filter
h0=remez(2*M,[0 fasl fapl fapu fasu 0.5]*2,[0 0 1 1 0 0],[10 1 10],"bandpass");
hM0=h0(1:(M+1));
hM0_active=1:length(hM0);
[hM1,slb_iter,socp_iter,func_iter,feasible]= ...
directFIRsymmetric_slb(@directFIRsymmetric_mmsePW, ...
                       hM0,hM0_active,na,wa,Ad,Adu,Adl,Wa, ...
                       maxiter,tol,ctol,verbose);
if feasible==false
  error("directFIRsymmetric_slb failed for initial filter!");
endif

%{
% For nbits=16 change Adu and Adl to:
dBass=42;dBas=45;
Adu=[(10^(-dBas/20))*ones(nasll,1); ...
     (10^(-dBass/20))*ones(nasl-nasll,1); ...
     ones(nasu-nasl-1,1); ...
     (10^(-dBass/20))*ones(nasuu-nasu,1);
     (10^(-dBas/20))*ones(npoints-nasuu+2,1)];
Adl=[-(10^(-dBas/20))*ones(napl-1,1); ...
      (10^(-dBap/20))*ones(napu-napl+1,1); ...
     -(10^(-dBas/20))*ones(npoints-napu+1,1)];
%}

% Allocate digits
nbits=12;
nscale=2^(nbits-1);
ndigits=3;
waf=wa([1 nasl napl napu nasu end]);
Adf=[0 0 1 0 0];
Waf=[Wasl 0 Wap 0 Wasu];
ndigits_alloc=directFIRsymmetric_allocsd_Ito(nbits,ndigits,hM1,waf,Adf,Waf);
hM_allocsd_digits=int16(ndigits_alloc);
printf("hM_allocsd_digits=[ ");
printf("%2d ",hM_allocsd_digits);printf("]';\n");
print_polynomial(hM_allocsd_digits,"hM_allocsd_digits", ...
                 strcat(strf,"_hM_allocsd_digits.m"),"%2d");

% Find the signed-digit approximations to hM1
[hM1_sd,hM1_sdu,hM1_sdl]=flt2SD(hM1,nbits,ndigits_alloc);
[hM1_digits,hM1_adders]=SDadders(hM1_sd,nbits);
print_polynomial(hM1_sd,"hM1_sd",nscale);
print_polynomial(hM1_sd,"hM1_sd",strcat(strf,"_hM1_sd_coef.m"),nscale);
% Find initial mean-squared errrors
Esq0=directFIRsymmetricEsqPW(hM1,waf,Adf,Waf);
Esq0_sd=directFIRsymmetricEsqPW(hM1_sd,waf,Adf,Waf);

% Fix one coefficient at each iteration 
hM_active=find(ndigits_alloc~=0);
hM=zeros(size(hM1));
hM(hM_active)=hM1(hM_active);
slb_iter=0;
socp_iter=0;
func_iter=0;
while ~isempty(hM_active)
  
  % Define filter coefficients 
  [hM_sd,hM_sdu,hM_sdl]=flt2SD(hM,nbits,ndigits_alloc);
  hM_sdul=hM_sdu-hM_sdl;
  
  % Ito et al. suggest ordering the search by max(hM_sdu-hM_sdl)
  [hM_max,hM_max_n]=max(hM_sdul(hM_active));
  if hM_max==0
    warning("hM_max==0 with %d active coefficients. Can't continue!", ...
            length(hM_active));
    break;
  endif
  coef_n=hM_active(hM_max_n);

  % Try to solve the current SOCP problem with bounds
  try
    % Find the SOCP PCLS solution for the remaining active coefficients
    [nexthM,siter,soiter,fiter,feasible]= ...
    directFIRsymmetric_slb(@directFIRsymmetric_socp_mmsePW, ...
                           hM,hM_active,na,wa,Ad,Adu,Adl,Wa, ...
                           maxiter,tol,ctol,verbose);
    slb_iter=slb_iter+siter;
    socp_iter=socp_iter+soiter;
    func_iter=func_iter+fiter;
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

  % Fix coef_n to nearest signed-digit coefficient
  alpha=(nexthM(coef_n)-((hM_sdu(coef_n)+hM_sdl(coef_n))/2))/(hM_sdul(coef_n)/2);
  if alpha>=0
    nexthM(coef_n)=hM_sdu(coef_n);
  else
    nexthM(coef_n)=hM_sdl(coef_n);
  endif
  hM=nexthM;
  hM_active(hM_max_n)=[];
  printf("Fixed hM(%d)=%g/%d\n",coef_n,hM(coef_n)*nscale,nscale);
  printf("hM_active=[ ");printf("%d ",hM_active);printf("];\n\n");

endwhile

% Show results
hM_min=hM;
print_polynomial(hM_min,"hM_min",nscale);
print_polynomial(hM_min,"hM_min",strcat(strf,"_hM_min_coef.m"),nscale);
Esq_min=directFIRsymmetricEsqPW(hM_min,waf,Adf,Waf);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);

% Find the number of signed-digits and adders used
[hM_min_digits,hM_min_adders]=SDadders(hM_min,nbits);
printf("%d signed-digits used\n",hM_min_digits);
fid=fopen(strcat(strf,"_hM_min_signed_digits.tab"),"wt");
fprintf(fid,"%d",hM_min_digits);
fclose(fid);
printf("%d %d-bit adders used for coefficient multiplications\n", ...
       hM_min_adders,nbits);
fid=fopen(strcat(strf,"_hM_min_adders.tab"),"wt");
fprintf(fid,"%d",hM_min_adders);
fclose(fid);

% Amplitude and delay at local peaks
A=directFIRsymmetricA(wa,hM_min);
vAl=local_max(Adl-A);
vAu=local_max(A-Adu);
wAS=unique([wa(vAl);wa(vAu);wa([1,nasl,napl,napu,nasu,end])]);
AS=directFIRsymmetricA(wAS,hM_min);
printf("hM_min:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("hM_min:AS=[ ");printf("%f ",20*log10(AS'));printf(" ] (dB)\n");

% Compare with 3 signed-digit allocation
hM1_3sd=flt2SD(hM1,nbits,3);
hM1_3sd_active=find(hM1_3sd ~= 0);
[hM1_3sd_digits,hM1_3sd_adders]=SDadders(hM1_3sd(hM1_3sd_active),nbits);
printf("%d signed-digits used for 3-sd allocation\n",hM1_3sd_digits);
printf("%d %d-bit adders used for 3-sd coefficient multiplications\n", ...
       hM1_3sd_adders,nbits);
Esq0_3sd=directFIRsymmetricEsqPW(hM1_3sd,waf,Adf,Waf);
print_polynomial(hM1_3sd,"hM1_3sd",nscale);
print_polynomial(hM1_3sd,"hM1_3sd",strcat(strf,"_hM1_3sd_coef.m"),nscale);

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %8.6f & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit&%8.6f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_3sd,hM1_3sd_digits,hM1_3sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(Ito)&%8.6f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq0_sd,hM1_digits,hM1_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %8.6f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_min,hM_min_digits,hM_min_adders);
fclose(fid);

% Calculate response
nplot=1001;
wplot=(0:(nplot-1))'*pi/nplot;
A_hM1=directFIRsymmetricA(wplot,hM1);
A_hM1_sd=directFIRsymmetricA(wplot,hM1_sd);
A_hM_min=directFIRsymmetricA(wplot,hM_min);
A_hM1_3sd=directFIRsymmetricA(wplot,hM1_3sd);

% Plot pass band amplitude response
plot(wplot*0.5/pi,20*log10(abs(A_hM1)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(A_hM1_3sd)),"linestyle",":", ... 
     wplot*0.5/pi,20*log10(abs(A_hM1_sd)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(A_hM_min)),"linestyle","-.");
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.5 -2 0.5]);
strt=sprintf(["Direct-form symmetric bandpass filter pass-band ", ...
 "(nbits=%d,ndigits=%d) : fapl=%g,fapu=%g,dBap=%g"],nbits,ndigits,fapl,fapu,dBap);
title(strt);
legend("exact","s-d","s-d(Ito)","s-d(Ito and SOCP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Plot pass band amplitude response
plot(wplot*0.5/pi,20*log10(abs(A_hM1)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(A_hM1_3sd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(A_hM1_sd)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(A_hM_min)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(Adu)),"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 -30]);
strt=sprintf(["Direct-form symmetric bandpass filter stop-band ", ...
 "(nbits=%d,ndigits=%d) : fasl=%g,fasu=%g,dBas=%g"],nbits,ndigits,fasl,fasu,dBas);
title(strt);
legend("exact","s-d","s-d(Ito)","s-d(Ito and SOCP-relax)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_stopband_response"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"maxiter=%d %% SOCP iteration limit\n",maxiter);
fprintf(fid,"npoints=%g %% Frequency points across the band\n",npoints);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%d %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
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
eval(sprintf(["save %s.mat tol ctol nbits nscale ndigits ndigits_alloc npoints ", ...
 "hM1 fapl fapu dBap Wap fasl fasll fasu fasuu dBas dBass Wasl Wasu hM_min"],strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
