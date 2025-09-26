% socp_relaxation_directFIRantisymmetric_lowpass_differentiator_12_nbits_test.m
% Copyright (C) 2025 Robert G. Jenssen

% Optimisation of a direct-form lowpass differentiator FIR filter
% response with 12-bit signed-digit coefficients having Lim et al. allocation
% and SOCP relaxation solution.

test_common;

strf= ...
  "socp_relaxation_directFIRantisymmetric_lowpass_differentiator_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=5000
verbose=false;
tol=1e-5;
ctol=tol;
M=16;

% Found by trial and error to give 16 distinct integer coefficients
Q=31;L=20;K=21;N=K+(2*L)+2;
h0=selesnickFIRantisymmetric_linear_differentiator(N,K)/2;
hM0=h0((Q-M+1):Q);
print_polynomial(h0(1:Q),"h0");
print_polynomial(h0(1:Q),"h0",strcat(strf,"_h0_coef.m"),"%15.8e");
print_polynomial(hM0,"hM0");
print_polynomial(hM0,"hM0",strcat(strf,"_hM0_coef.m"));

% Response constraints
fap=0.2;fas=0.4;Arp=0.002;Art=0.01;Ars=0.001;Wap=1;Wat=0.01;Was=10;

% Desired magnitude response
npoints=1000;
wa=(0:(npoints-1))'*pi/npoints;
nap=ceil(npoints*fap/0.5)+1;
nas=floor(npoints*fas/0.5)+1;  
Ad=[wa(1:nap)/2; zeros(npoints-nap,1)];
Adu=[wa(1:(nas-1))/2;zeros(npoints-nas+1,1)] + ...
    [(Arp/2)*ones(nap,1); ...
     (Art/2)*ones(nas-nap-1,1); ...
     (Ars/2)*ones(npoints-nas+1,1)];
Adl=Ad - ...
    [(Arp/2)*ones(nap,1); ...
     (Art/2)*ones(nas-nap-1,1); ...
     (Ars/2)*ones(npoints-nas+1,1)];
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(npoints-nas+1,1)];
% Sanity check
nchk=[1,2,nap-1,nap,nap+1,nas-1,nas,nas+1,npoints-1];
printf("nchk=[");printf("%d ",nchk);printf(" ]\n");
printf("wa(nchk)*0.5/pi=[");printf("%g ",wa(nchk)*0.5/pi);printf(" ]\n");
printf("Ad(nchk)=[");printf("%g ",Ad(nchk));printf(" ]\n");
printf("Adu(nchk)=[");printf("%g ",Adu(nchk));printf(" ]\n");
printf("Adl(nchk)=[");printf("%g ",Adl(nchk));printf(" ]\n");
printf("Wa(nchk)=[");printf("%g ",Wa(nchk));printf(" ]\n");

% Allocate digits
nbits=13;
nscale=2^(nbits-1);
ndigits=3;
ndigits_alloc=directFIRantisymmetric_allocsd_Lim(nbits,ndigits,hM0,wa,Ad,Wa);
hM_allocsd_digits=int16(ndigits_alloc);
printf("hM_allocsd_digits=[ ");
printf("%2d ",hM_allocsd_digits);printf("]';\n");
print_polynomial(hM_allocsd_digits,"hM_allocsd_digits", ...
                 strcat(strf,"_hM_allocsd_digits.m"),"%2d");

% Find the signed-digit approximations to hM0
[h0_sd,h0_sdu,h0_sdl]=flt2SD(h0,nbits,ndigits);
[hM0_sd,hM0_sdu,hM0_sdl]=flt2SD(hM0,nbits,ndigits_alloc);
[hM0_sd_digits,hM0_sd_adders]=SDadders(hM0_sd,nbits);
print_polynomial(hM0_sd,"hM0_sd",nscale);
print_polynomial(hM0_sd,"hM0_sd",strcat(strf,"_hM0_sd_coef.m"),nscale);
% Find initial mean-squared errrors
EsqN0=directFIRantisymmetricEsq(h0(1:Q),wa,Ad,Wa);
EsqM0=directFIRantisymmetricEsq(hM0,wa,Ad,Wa);
EsqM0_sd=directFIRantisymmetricEsq(hM0_sd,wa,Ad,Wa);

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
    % Find the SOCP PCLS solution for the remaining active coefficients
    [nexthM,siter,soiter,fiter,feasible]= ...
       directFIRantisymmetric_slb(@directFIRantisymmetric_socp_mmse, ...
                                  hM,hM_active,[],wa,Ad,Adu,Adl,Wa, ...
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
Esq_min=directFIRantisymmetricEsq(hM_min,wa,Ad,Wa);
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
A=directFIRantisymmetricA(wa,hM_min);
vAl=local_max(Adl-A);
vAu=local_max(A-Adu);
wAS=unique([wa(vAl);wa(vAu);wa([1,nap,nas,end])]);
AS=directFIRantisymmetricA(wAS,hM_min);
printf("hM_min:fAS=[ ");printf("%f ",wAS'*0.5/pi);printf(" ] (fs==1)\n");
printf("hM_min:AS=[ ");printf("%f ",AS');printf(" ] (dB)\n");

% Compare with 3 signed-digit allocation
hM0_3sd=flt2SD(hM0,nbits,ndigits);
hM0_3sd_active=find(hM0_3sd ~= 0);
[hM0_3sd_digits,hM0_3sd_adders]=SDadders(hM0_3sd(hM0_3sd_active),nbits);
printf("%d signed-digits used for 3-sd allocation\n",hM0_3sd_digits);
printf("%d %d-bit adders used for 3-sd coefficient multiplications\n", ...
       hM0_3sd_adders,nbits);
EsqM0_3sd=directFIRantisymmetricEsq(hM0_3sd,wa,Ad,Wa);
print_polynomial(hM0_3sd,"hM0_3sd",nscale);
print_polynomial(hM0_3sd,"hM0_3sd",strcat(strf,"_hM0_3sd_coef.m"),nscale);

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Exact(N) & %10.4e & & \\\\\n",EsqN0);
fprintf(fid,"Exact(M) & %10.4e & & \\\\\n",EsqM0);
fprintf(fid,"%d-bit %d-signed-digit&%10.4e & %d & %d \\\\\n", ...
        nbits,ndigits,EsqM0_3sd,hM0_3sd_digits,hM0_3sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(Lim)&%10.4e & %d & %d \\\\\n", ...
        nbits,ndigits,EsqM0_sd,hM0_sd_digits,hM0_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(SOCP-relax) & %10.4e & %d & %d \\\\\n", ...
        nbits,ndigits,Esq_min,hM_min_digits,hM_min_adders);
fclose(fid);

% Calculate response
A_h0=directFIRantisymmetricA(wa,h0(1:Q));
A_hM0=directFIRantisymmetricA(wa,hM0);
A_hM0_sd=directFIRantisymmetricA(wa,hM0_sd);
A_hM_min=directFIRantisymmetricA(wa,hM_min);
A_hM0_3sd=directFIRantisymmetricA(wa,hM0_3sd);

% Plot amplitude response
Rap=1:nap;
Ras=nas:length(wa);
A_all=[A_h0,A_hM0,A_hM0_sd,A_hM_min,Adl,Adu];
[ax,ha,hs] = plotyy(wa(Rap)*0.5/pi,A_all(Rap,:)-Ad(Rap), ...
                    wa(Ras)*0.5/pi,A_all(Ras,:));
% Copy line colour
hac=get(ha,"color");
hls={"-",":","--","-.","-","-"};
for c=1:6
  set(hs(c),"color",hac{c});
  set(ha(c),"linestyle",hls{c});
  set(hs(c),"linestyle",hls{c});
endfor
set(ax(1),"ycolor","black");
set(ax(2),"ycolor","black");
axis(ax(1),[0 0.5 0.002*[-1,1]]);
axis(ax(2),[0 0.5 0.002*[-1,1]]);
ylabel("Amplitude error");
xlabel("Frequency");
strt=sprintf(["Direct-form anti-symmetric low-pass differentiator filter", ...
              " : fap=%g,Arp=%g,fas=%g,Ars=%g"],fap,Arp,fas,Ars);
title(strt);
legend("exact(N)","exact(M)","S-D(Lim)","S-D(Lim and SOCP-relax)");
legend("location","south");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"N=%d %% Length of the Selesnick differentiator filter\n",N);
fprintf(fid,"K=%d %% K value of the Selesnick differentiator\n",K);
fprintf(fid,"nbits=%g %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%g %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"tol=%g %% Tolerance on coef. update\n",tol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"maxiter=%d %% SOCP iteration limit\n",maxiter);
fprintf(fid,"npoints=%d %% Frequency points across the band\n",npoints);
fprintf(fid,"fap=%g %% Amplitude pass band edge\n",fap);
fprintf(fid,"Arp=%d %% Amplitude pass band peak-to-peak ripple\n",Arp);
fprintf(fid,"Wap=%d %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Art=%d %% Amplitude transition band peak-to-peak ripple\n",Art);
fprintf(fid,"Wat=%d %% Amplitude transition band weight\n",Wat);
fprintf(fid,"fas=%g %% Amplitude stop band edge\n",fas);
fprintf(fid,"Ars=%d %% Amplitude stop band peak-to-peak ripple\n",Ars);
fprintf(fid,"Was=%d %% Amplitude stop band weight\n",Was);
fclose(fid);

% Save results
eval(sprintf(["save %s.mat tol ctol nbits nscale ndigits ndigits_alloc N K ", ...
              "npoints hM0 fap Arp Wap Art Wat fas Ars Was hM_min"],strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
