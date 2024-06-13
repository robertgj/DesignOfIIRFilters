% socp_relaxation_directFIRhilbert_12_nbits_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen

% Optimisation of Hilbert FIR filter response with 12-bit signed-digit
% coefficients allocated with the heuristic of Ito et al. and SOCP relaxation

test_common;

strf="socp_relaxation_directFIRhilbert_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=1000
verbose=false;
ftol=1e-5;
ctol=ftol;

% Hilbert filter frequency specification
M=40;fapl=0.01;fapu=0.5-fapl;dBap=0.1575;Wap=1;Was=0;
npoints=500;
wa=(0:((npoints)-1))'*pi/(npoints);
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
Ad=-ones(npoints,1);
if 1
  Adl=(10^(dBap/40))*Ad;
  Adu=[zeros(napl-1,1); ...
       -(10^(-dBap/40))*ones(napu-napl+1,1); ...
       zeros(npoints-napu,1)];
else
  dBap=0.07 % dBap=0.06 also works
  Adl=Ad;
  Adu=[zeros(napl-1,1); ...
       -(10^(-dBap/20))*ones(napu-napl+1,1); ...
       zeros(npoints-napu,1)];
endif
Wa=[Was*ones(napl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Was*ones(npoints-napu,1)];

% Make a Hilbert filter
n4M1=((-2*M)+1):2:((2*M)-1)';
h0=zeros((4*M)-1,1);
h0(n4M1+(2*M))=2*(sin(pi*n4M1/2).^2)./(pi*n4M1);
h0=h0.*hamming((4*M)-1);
hM0=h0(1:2:((2*M)-1));
printf("hM0=[ ");printf("%g ",hM0');printf("]';\n");
print_polynomial(hM0,"hM0",strcat(strf,"_hM0_coef.m"),"%12.8g");
A0=directFIRhilbertA(wa,hM0);

% Find the exact coefficient error
na=[napl (npoints/2)];
waf=wa(na);
Adf=-1;
Waf=Wap;
Esq0=directFIRhilbertEsqPW(hM0,waf,Adf,Waf);
printf("Esq0=%g\n",Esq0);

% Sanity checks
nchka=[napl-1,napl,napl+1,napu-1,napu,napu+1];
printf("nchka=[napl-1,napl,napl+1,napu-1,napu,napu+1];\n");
printf("nchka=[ ");printf("%d ",nchka);printf("];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)'/(2*pi));printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Allocate digits
nbits=12;
nscale=2^(nbits-1);
ndigits=2;
ndigits_alloc=directFIRhilbert_allocsd_Ito(nbits,ndigits,hM0,waf,Adf,Waf);
% Find the signed-digit approximations to hM0
[hM0_sd,hM0_sdu,hM0_sdl]=flt2SD(hM0,nbits,ndigits);
[hM0_sd_digits,hM0_sd_adders]=SDadders(hM0_sd,nbits);
print_polynomial(hM0_sd,"hM0_sd",nscale);
print_polynomial(hM0_sd,"hM0_sd",strcat(strf,"_hM0_sd_coef.m"),nscale);
% Find the signed-digit approximations to hM0 with Ito allocation
[hM0_Ito_sd,hM0_Ito_sdu,hM0_Ito_sdl]=flt2SD(hM0,nbits,ndigits_alloc);
[hM0_Ito_sd_digits,hM0_Ito_sd_adders]=SDadders(hM0_Ito_sd,nbits);
print_polynomial(hM0_Ito_sd,"hM0_Ito_sd",nscale);
print_polynomial(hM0_Ito_sd,"hM0_Ito_sd", ...
                 strcat(strf,"_hM0_Ito_sd_coef.m"),nscale);

% Find initial mean-squared errrors
Esq0=directFIRhilbertEsqPW(hM0,waf,Adf,Waf);
Esq0_sd=directFIRhilbertEsqPW(hM0_sd,waf,Adf,Waf);
Esq0_Ito_sd=directFIRhilbertEsqPW(hM0_Ito_sd,waf,Adf,Waf);

% Fix one coefficient at each iteration 
hM_active=find(ndigits_alloc~=0);
hM=zeros(size(hM0));
hM(hM_active)=hM0(hM_active);
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
    % Find the SOCP PCLS solution for the remaining active coefficents
    war=(napl:(npoints/2));
    [nexthM,siter,soiter,fiter,feasible]= ...
      directFIRhilbert_slb(@directFIRhilbert_socp_mmsePW, ...
                           hM,hM_active,[1 ((npoints/2)-napl+1)], ...
                           wa(war),Ad(war),Adu(war),Adl(war),Wa(war), ...
                           maxiter,ftol,ctol,verbose);
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
Esq_min=directFIRhilbertEsqPW(hM_min,waf,Adf,Waf);
printf("\nSolution:\nEsq_min=%g\n",Esq_min);
printf("ndigits_alloc=[ ");printf("%d ",ndigits_alloc);printf("]\n");
print_polynomial(hM_min,"hM_min",strcat(strf,"_hM_min_coef.m"),nscale);

% Find the number of signed-digits and adders used
[hM_min_digits,hM_min_adders]=SDadders(hM_min,nbits);
printf("%d signed-digits used\n",hM_min_digits);
fid=fopen(strcat(strf,"_hM_min_signed_digits.tab"),"wt");
fprintf(fid,"%d",hM_min_digits);
fclose(fid);
printf("%d %d-bit adders used for coefficient multiplications\n",
       hM_min_adders,nbits);
fid=fopen(strcat(strf,"_hM_min_adders.tab"),"wt");
fprintf(fid,"%d",hM_min_adders);
fclose(fid);

% Amplitude and delay at local peaks
A=directFIRhilbertA(wa,hM_min);
vAl=local_max(Adl-A);
vAu=local_max(A-Adu);
wAS=unique([wa(vAl);wa(vAu);wa([2,napl,napu,end])]);
AS=directFIRhilbertA(wAS,hM_min);
printf("hM_min:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("hM_min:AS=[ ");printf("%f ",20*log10(AS'));printf(" ] (dB)\n");

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact & %8.4g & & \\\\\n",Esq0);
fprintf(fid,"%d-bit %d-signed-digit&%8.4g & %d & %d \\\\\n",
        nbits,ndigits,Esq0_sd,hM0_sd_digits,hM0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(Ito)&%8.4g & %d & %d \\\\\n",
        nbits,ndigits,Esq0_Ito_sd,hM0_Ito_sd_digits,hM0_Ito_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %8.4g & %d & %d \\\\\n",
        nbits,ndigits,Esq_min,hM_min_digits,hM_min_adders);
fclose(fid);

% Calculate response
nplot=1001;
wplot=(1:(nplot-1))'*pi/nplot;
A_hM0=directFIRhilbertA(wplot,hM0);
A_hM0_sd=directFIRhilbertA(wplot,hM0_sd);
A_hM0_Ito_sd=directFIRhilbertA(wplot,hM0_Ito_sd);
A_hM_min=directFIRhilbertA(wplot,hM_min);

% Plot amplitude response
plot(wplot*0.5/pi,20*log10(abs(A_hM0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(A_hM0_sd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(A_hM0_Ito_sd)),"linestyle","--", ... 
     wplot*0.5/pi,20*log10(abs(A_hM_min)),"linestyle","-.");
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.5 -0.2 0.2]);
strt=sprintf("Direct-form Hilbert filter pass-band \
(nbits=%d,ndigits=%d) : fapl=%g,fapu=%g,dBap=%g,Wap=%g,Was=%g", ...
                      nbits,ndigits,fapl,fapu,dBap,Wap,Was);
title(strt);
legend("exact","s-d","s-d(Ito)","s-d(Ito and SOCP-relax)");
legend("location","north");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"M=%d %% Number of distinct coefficients\n",M);
fprintf(fid,"nbits=%d %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%d %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"maxiter=%d %% SOCP iteration limit\n",maxiter);
fprintf(fid,"npoints=%d %% Frequency points across the band\n",npoints);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fclose(fid);

% Save results
eval(sprintf("save %s.mat ftol ctol nbits nscale ndigits ndigits_alloc npoints \
fapl fapu dBap Wap Was hM0 hM0_sd hM0_Ito_sd hM_min",strf));

% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
