% sdp_relaxation_directFIRhilbert_12_nbits_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

% SDP relaxation optimisation of a direct-form FIR Hilbert filter
% with 12-bit signed-digit coefficients

test_common;

strf="sdp_relaxation_directFIRhilbert_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
ftol=1e-5
ctol=ftol
verbose=false

nbits=12
nscale=2^(nbits-1)
ndigits=2

% Hilbert filter frequency specification
M=40
fapl=0.01
fapu=0.5-fapl
dBap_exact=0.04
dBap=0.2
Ad_passband=-1
Wap=1
Was=0

% Frequency vectors
n=500;
wa=(0:(n-1))'*pi/n;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
Ad=Ad_passband*ones(n,1);
Adl=Ad_passband*(10^(dBap/40))*ones(n,1);;
Adu=[zeros(napl-1,1); ...
     Ad_passband*(10^(-dBap/40))*ones(napu-napl+1,1); ...
     zeros(n-napu,1)];
Wa=[Was*ones(napl-1,1);Wap*ones(napu-napl+1,1);Was*ones(n-napu,1)];
       
% Sanity checks
nchka=[napl-1,napl,napl+1,napu-1,napu,napu+1];
printf("nchka=[napl-1,napl,napl+1,napu-1,napu,napu+1];\n");
printf("nchka=[ ");printf("%d ",nchka);printf("];\n");
printf("wa(nchka)*0.5/pi=[");printf("%6.4g ",wa(nchka)'/(2*pi));printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

%
% Make a Hilbert filter
%
n4M1=((-2*M)+1):2:((2*M)-1)';
h0=zeros((4*M)-1,1);
h0(n4M1+(2*M))=2*(sin(pi*n4M1/2).^2)./(pi*n4M1);
h0=h0.*hamming((4*M)-1);
hM0=h0(1:2:((2*M)-1));

%
% Find the optimised exact coefficients
%
% Find the SOCP PCLS solution for the exact filter
hM_active=1:length(hM0);
na=[napl (n/2)];
Adu_exact=[zeros(napl-1,1); ...
           -(10^(-dBap_exact/40))*ones(napu-napl+1,1); ...
           zeros(n-napu,1)];
Adl_exact=-(10^(dBap_exact/40))*ones(n,1);
[hM1,slb_iter,socp_iter,func_iter,feasible]= ...
  directFIRhilbert_slb(@directFIRhilbert_socp_mmsePW, ...
                       hM0,hM_active,na, ...
                       wa,Ad,Adu_exact,Adl_exact,Wa, ...
                       maxiter,ftol,ctol,verbose);
if ~feasible
  error("SOCP PCLS problem for exact filter is infeasible!");
endif

%
% Allocate digits
%
waf=wa(na);Adf=Ad_passband;Waf=Wap;
ndigits_alloc=directFIRhilbert_allocsd_Ito(nbits,ndigits,hM1,waf,Adf,Waf);
printf("ndigits_alloc=[ ");printf("%2d ",int16(ndigits_alloc));printf("]';\n");
print_polynomial(int16(ndigits_alloc),"hM1_allocsd_digits", ...
                 strcat(strf,"_hM1_allocsd_digits.m"),"%2d");

% Find the signed-digit approximations to hM1
[hM1_sd,hM1_sdu,hM1_sdl]=flt2SD(hM1,nbits,ndigits);

% Find the signed-digit approximations to hM1 with Ito allocation
[hM1_Ito,hM1_Ito_sdu,hM1_Ito_sdl]=flt2SD(hM1,nbits,ndigits_alloc);

%
% Solve the overall SDP problem with SeDuMi
%
hM1_sdp_x=(hM1_Ito_sdu+hM1_Ito_sdl)/2;
hM1_sdp_delta=(hM1_Ito_sdu-hM1_Ito_sdl)/2;
[hM1_sdp,socp_iter,func_iter,feasible] = ...
  directFIRhilbert_sdp_mmsePW([],hM1_sdp_x,hM1_sdp_delta, ...
                              na,wa,Ad,Adu,Adl,Wa,maxiter,ftol,ctol,verbose);
if feasible==false
  error("directFIRhilbert_sdp_mmsePW failed!");
endif

%
% Find coefficients with successive relaxation
%
hM1_socp=hM1;
hM1_socp(find(ndigits_alloc == 0))=0;
while 1
  
  % Find the signed-digit filter coefficients 
  [~,hM1_socp_sdu,hM1_socp_sdl]=flt2SD(hM1_socp,nbits,ndigits_alloc);
  hM1_socp_x=(hM1_socp_sdu+hM1_socp_sdl)/2;
  hM1_socp_delta=(hM1_socp_sdu-hM1_socp_sdl)/2;

  % Find the SDP signed-digit solution for all the active coefficients
  [nexthM1_socp_x,socp_iter,func_iter,feasible]= ...
    directFIRhilbert_sdp_mmsePW([], ...
                                hM1_socp_x,hM1_socp_delta, na, ...
                                wa,Ad,Adu,Adl,Wa, ...
                                maxiter,ftol,ctol,verbose);
  if feasible==false
    error("directFIRhilbert_sdp_mmsePW failed!");
  endif

  % Ito et al. suggest ordering the search by max hM1_socp_delta (try min here)
  if 1
    [~,coef_n]=max(hM1_socp_delta);
  else
    hM1_socp_delta_nz=find(hM1_socp_delta ~= 0);
    [~,hM1_socp_min_nz_n]=min(hM1_socp_delta(hM1_socp_delta_nz));
    hM1_socp_min_n=hM1_socp_delta_nz(hM1_socp_min_nz_n);
    coef_n=hM1_socp_min_n;
  endif

  % Fix the coefficient with the largest hM1_socp_delta to the SDP value
  hM1_socp(coef_n)=nexthM1_socp_x(coef_n);
  hM1_socp_delta(coef_n)=0;
  printf("\nFixed hM1_socp(%d)=%g/%d\n",coef_n,hM1_socp(coef_n)*nscale,nscale);
  printf("hM1_socp=[ ");printf("%g ",hM1_socp'*nscale);printf("]/%d;\n",nscale);
  printf("hM1_socp_delta=[ ");printf("%d ",hM1_socp_delta');printf("];\n\n");
  
  % Check if done
  if all(hM1_socp_delta == 0)
    hM1_min=hM1_socp;
    break;
 endif
  
  % Try to solve the current SOCP problem for the active coefficients
  hM1_socp_active=find(hM1_socp_delta ~= 0);
  printf("hM1_socp_active=[ ");printf("%d ",hM1_socp_active');printf("];\n\n");
  try
    % Find the SOCP solution for the active coefficients
    [nexthM1_socp,slb_iter,socp_iter,func_iter,feasible] = ...
       directFIRhilbert_slb(@directFIRhilbert_socp_mmsePW, ...
                            hM1_socp,hM1_socp_active, ...
                            na,wa,Ad,Adu,Adl,Wa, ...
                            maxiter,ftol,ctol,verbose);
    if feasible==false
      error("directFIRhilbert_socp_mmsePW failed!");
    endif
    hM1_socp=nexthM1_socp;
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

print_polynomial(hM0,"hM0");
print_polynomial(hM0,"hM0",strcat(strf,"_hM0_coef.m"),"%12.8g");
print_polynomial(hM1,"hM1");
print_polynomial(hM1,"hM1",strcat(strf,"_hM1_coef.m"),"%12.8g");
print_polynomial(hM1_sd,"hM1_sd",nscale);
print_polynomial(hM1_sd,"hM1_sd",strcat(strf,"_hM1_sd_coef.m"),nscale);
print_polynomial(hM1_Ito,"hM1_Ito",nscale);
print_polynomial(hM1_Ito,"hM1_Ito",strcat(strf,"_hM1_Ito_coef.m"),nscale);
print_polynomial(hM1_sdp,"hM1_sdp",nscale);
print_polynomial(hM1_sdp,"hM1_sdp",strcat(strf,"_hM1_sdp_coef.m"),nscale);
print_polynomial(hM1_min,"hM1_min",nscale);
print_polynomial(hM1_min,"hM1_min",strcat(strf,"_hM1_min_coef.m"),nscale);

% Find mean-squared errrors
Esq0=directFIRhilbertEsqPW(hM0,waf,Adf,Waf)
Esq1=directFIRhilbertEsqPW(hM1,waf,Adf,Waf)
Esq1_sd=directFIRhilbertEsqPW(hM1_sd,waf,Adf,Waf)
Esq1_Ito=directFIRhilbertEsqPW(hM1_Ito,waf,Adf,Waf)
Esq1_sdp=directFIRhilbertEsqPW(hM1_sdp,waf,Adf,Waf)
Esq1_min=directFIRhilbertEsqPW(hM1_min,waf,Adf,Waf)

% Find digits
[hM1_sd_digits,hM1_sd_adders]=SDadders(hM1_sd,nbits)
[hM1_Ito_digits,hM1_Ito_adders]=SDadders(hM1_Ito,nbits)
[hM1_sdp_digits,hM1_sdp_adders]=SDadders(hM1_sdp,nbits)
[hM1_min_digits,hM1_min_adders]=SDadders(hM1_min,nbits)

% Calculate response
A_hM0=directFIRhilbertA(wa,hM0);
A_hM1=directFIRhilbertA(wa,hM1);
A_hM1_sd=directFIRhilbertA(wa,hM1_sd);
A_hM1_Ito=directFIRhilbertA(wa,hM1_Ito);
A_hM1_sdp=directFIRhilbertA(wa,hM1_sdp);
A_hM1_min=directFIRhilbertA(wa,hM1_min);

% Sanity check on response
h_min=kron([hM1_min(:);-flipud(hM1_min(:))],[1;0])(1:(end-1));
H_min=freqz(h_min,1,wa);
if max(abs(abs(H_min)-abs(A_hM1_min))) > 100*eps
  error("max(abs(abs(H_min)-A_hM1_min))(%g*eps) > 100*eps", ...
        max(abs(abs(H_min)-A_hM1_min))/eps);
endif

% Find maximum pass-band response error
Rpb=[napl:napu];
[max_pb_A_hM0    ,max_pb_A_hM0_n]    =max(abs(A_hM0(Rpb)    -Ad_passband));
[max_pb_A_hM1    ,max_pb_A_hM1_n]    =max(abs(A_hM1(Rpb)    -Ad_passband));
[max_pb_A_hM1_sd ,max_pb_A_hM1_sd_n] =max(abs(A_hM1_sd(Rpb) -Ad_passband));
[max_pb_A_hM1_Ito,max_pb_A_hM1_Ito_n]=max(abs(A_hM1_Ito(Rpb)-Ad_passband));
[max_pb_A_hM1_sdp,max_pb_A_hM1_sdp_n]=max(abs(A_hM1_sdp(Rpb)-Ad_passband));
[max_pb_A_hM1_min,max_pb_A_hM1_min_n]=max(abs(A_hM1_min(Rpb)-Ad_passband));

printf("At f=%g, max_pb_A_hM0=%g\n", ...
       wa(napl+max_pb_A_hM0_n)*0.5/pi,max_pb_A_hM0);
printf("At f=%g, max_pb_A_hM1=%g\n", ...
       wa(napl+max_pb_A_hM1_n)*0.5/pi,max_pb_A_hM1);
printf("At f=%g, max_pb_A_hM1_sd=%g\n", ...
       wa(napl+max_pb_A_hM1_sd_n)*0.5/pi,max_pb_A_hM1_sd);
printf("At f=%g, max_pb_A_hM1_Ito=%g\n", ...
       wa(napl+max_pb_A_hM1_Ito_n)*0.5/pi,max_pb_A_hM1_Ito);
printf("At f=%g, max_pb_A_hM1_sdp=%g\n", ...
       wa(napl+max_pb_A_hM1_sdp_n)*0.5/pi,max_pb_A_hM1_sdp);
printf("At f=%g, max_pb_A_hM1_min=%g\n", ...
       wa(napl+max_pb_A_hM1_min_n)*0.5/pi,max_pb_A_hM1_min);

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Initial & %10.3e & %10.5f & & \\\\\n",Esq1,max_pb_A_hM0);
fprintf(fid,"Exact(SOCP) & %10.3e & %10.5f & & \\\\\n",Esq1,max_pb_A_hM1);
fprintf(fid,"%d-bit %d-signed-digit & %10.3e & %10.5f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq1_sd,max_pb_A_hM1_sd,hM1_sd_digits,hM1_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(Ito) & %10.3e & %10.5f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq1_Ito,max_pb_A_hM1_Ito, ...
        hM1_Ito_digits,hM1_Ito_adders);
fprintf(fid,"%d-bit %d-signed-digit(SDP) & %10.3e & %10.5f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq1_sdp,max_pb_A_hM1_sdp, ...
        hM1_sdp_digits,hM1_sdp_adders);
fprintf(fid,"%d-bit %d-signed-digit(min) & %10.3e & %10.5f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq1_min,max_pb_A_hM1_min, ...
        hM1_min_digits,hM1_min_adders);
fclose(fid);

% Plot amplitude response
plot(wa*0.5/pi,20*log10(abs(A_hM1)),"linestyle","-", ...
     wa*0.5/pi,20*log10(abs(A_hM1_Ito)),"linestyle","--", ...
     wa*0.5/pi,20*log10(abs(A_hM1_sdp)),"linestyle",":", ...
     wa*0.5/pi,20*log10(abs(A_hM1_min)),"linestyle","-.");
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.25 -0.2 0.2]);
strt=sprintf(["Direct-form Hilbert filter (nbits=%d,ndigits=%d) : ", ...
 "fapl=%g,fapu=%g,dBap=%g"],nbits,ndigits,fapl,fapu,dBap);
title(strt);
legend("Exact","s-d(Ito)","s-d(SDP)","s-d(min)");
legend("location","southwest");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_amplitude"),"-dpdflatex");
close

% Filter specification
fid=fopen(strcat(strf,"_spec.m"),"wt");
fprintf(fid,"M=%d %% Number of distinct coefficients\n",M);
fprintf(fid,"nbits=%d %% Coefficient bits\n",nbits);
fprintf(fid,"ndigits=%d %% Nominal average coefficient signed-digits\n",ndigits);
fprintf(fid,"ftol=%g %% Tolerance on coef. update\n",ftol);
fprintf(fid,"ctol=%g %% Tolerance on constraints\n",ctol);
fprintf(fid,"n=%d %% Frequency points across the band\n",n);
fprintf(fid,"fapl=%g %% Amplitude pass band lower edge\n",fapl);
fprintf(fid,"fapu=%g %% Amplitude pass band upper edge\n",fapu);
fprintf(fid,"dBap=%g %% Amplitude pass band peak-to-peak ripple\n",dBap);
fprintf(fid,"Wap=%g %% Amplitude pass band weight\n",Wap);
fprintf(fid,"Was=%g %% Amplitude stop band weight\n",Was);
fclose(fid);

% Save results
eval(sprintf(["save %s.mat ftol ctol nbits nscale ndigits n ", ...
              "fapl fapu dBap Wap Was hM1 hM1_sd hM1_Ito hM1_sdp hM1_min"], ...
             strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
