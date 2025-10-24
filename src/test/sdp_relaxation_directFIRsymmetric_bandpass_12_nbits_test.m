% sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

% SDP relaxation optimisation of a direct-form FIR bandpass filter
% with 12-bit signed-digit coefficients

test_common;

strf="sdp_relaxation_directFIRsymmetric_bandpass_12_nbits_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

tic;

maxiter=2000
ftol=1e-4
ctol=ftol
verbose=false

nbits=12
nscale=2^(nbits-1)
ndigits=2

% Hilbert filter frequency specification
M=15;
fapl=0.1;fapu=0.2;Wap=1;dBap=2;
fasl=0.05;fasu=0.25;Wasl=40;Wasu=40;dBas=36;

% Frequency vectors
n=1000;
fa=(0:n)'/(2*n);
wa=2*pi*fa;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;  
Ad=[zeros(napl-1,1); ...
    ones(napu-napl+1,1); ...
    zeros(n-napu+1,1)];
Adl=[-(10^(-dBas/20))*ones(napl-1,1); ...
      (10^(-dBap/40))*ones(napu-napl+1,1); ...
     -(10^(-dBas/20))*ones(n-napu+1,1)];
Adu=[(10^(-dBas/20))*ones(nasl,1); ...
     (10^( dBap/40))*ones(nasu-nasl+1,1); ...
     (10^(-dBas/20))*ones(n-nasu,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+2,1)];

na=[1 nasl,napl,napu,nasu length(fa)];
faf=[fa(1), fasl, fapl, fapu, fasu, fa(end)];
waf=2*pi*faf;
Adf=[0 0 1 0 0];
Waf=[Wasl 0 Wap 0 Wasu];

% Sanity checks
nchka=[1, ...
       nasl-1, nasl, nasl+1, ...
       napl-1, napl, napl+1, ...
       napu-1, napu, napu+1, ...
       nasu-1, nasu, nasu+1, ...
       n-1];
printf(["nchka=[1,nasl-1,nasl,nasl+1,napl-1,napl,napl+1,", ...
        "napu-1,napu,napu+1,nasu-1,nasu,nasu+1,n-1];\n"]);
printf("nchka=[ ");printf("%d ",nchka);printf("];\n");
printf("fa(nchka)=[");printf("%6.4g ",fa(nchka)');printf("];\n");
printf("Ad(nchka)=[ ");printf("%6.4g ",Ad(nchka)');printf("];\n");
printf("Adu(nchka)=[ ");printf("%6.4g ",Adu(nchka)');printf("];\n");
printf("Adl(nchka)=[ ");printf("%6.4g ",Adl(nchka)');printf("];\n");
printf("Wa(nchka)=[ ");printf("%6.4g ",Wa(nchka)');printf("];\n");

% Make an initial band pass filter
h0=remez(2*M,[0 fasl fapl fapu fasu 0.5]*2,[0 0 1 1 0 0],[10 1 10],"bandpass");
hM0=h0(1:(M+1));
hM0_active=1:length(hM0);
[hM1,slb_iter,socp_iter,func_iter,feasible]= ...
directFIRsymmetric_slb(@directFIRsymmetric_socp_mmsePW, ...
                       hM0,hM0_active,na,wa,Ad,Adu,Adl,Wa, ...
                       maxiter,ftol,ctol,verbose);
if feasible==false
  error("directFIRsymmetric_slb failed for initial filter!");
endif

% Find the signed-digit approximations to hM1
[hM1_sd,hM1_sdu,hM1_sdl]=flt2SD(hM1,nbits,ndigits);

%
% Solve the overall SDP problem with SeDuMi
%
hM1_sdp_x=(hM1_sdu+hM1_sdl)/2;
hM1_sdp_delta=(hM1_sdu-hM1_sdl)/2;
[hM1_sdp,socp_iter,func_iter,feasible] = ...
  directFIRsymmetric_sdp_mmsePW([],hM1_sdp_x,hM1_sdp_delta, ...
                              na,wa,Ad,Adu,Adl,Wa,maxiter,ftol,ctol,verbose);
if feasible==false
  error("directFIRsymmetric_sdp_mmsePW failed!");
endif

%
% Find coefficients with successive relaxation
%
hM1_socp=hM1;
while 1
  
  % Find the signed-digit filter coefficients 
  [~,hM1_socp_sdu,hM1_socp_sdl]=flt2SD(hM1_socp,nbits,ndigits);
  hM1_socp_x=(hM1_socp_sdu+hM1_socp_sdl)/2;
  hM1_socp_delta=(hM1_socp_sdu-hM1_socp_sdl)/2;

  % Find the SDP signed-digit solution for all the active coefficients
  [nexthM1_socp_x,socp_iter,func_iter,feasible]= ...
    directFIRsymmetric_sdp_mmsePW([], ...
                                hM1_socp_x,hM1_socp_delta, na, ...
                                wa,Ad,Adu,Adl,Wa, ...
                                maxiter,ftol,ctol,verbose);
  if feasible==false
    error("directFIRsymmetric_sdp_mmsePW failed!");
  endif

  % Ito et al. suggest ordering the search by max hM1_socp_delta 
  [~,coef_n]=max(hM1_socp_delta);

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
       directFIRsymmetric_slb(@directFIRsymmetric_socp_mmsePW, ...
                            hM1_socp,hM1_socp_active, ...
                            na,wa,Ad,Adu,Adl,Wa, ...
                            maxiter,ftol,ctol,verbose);
    if feasible==false
      error("directFIRsymmetric_socp_mmsePW failed!");
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

print_polynomial(hM1,"hM1");
print_polynomial(hM1,"hM1",strcat(strf,"_hM1_coef.m"),"%12.8g");
print_polynomial(hM1_sd,"hM1_sd",nscale);
print_polynomial(hM1_sd,"hM1_sd",strcat(strf,"_hM1_sd_coef.m"),nscale);
print_polynomial(hM1_sdp,"hM1_sdp",nscale);
print_polynomial(hM1_sdp,"hM1_sdp",strcat(strf,"_hM1_sdp_coef.m"),nscale);
print_polynomial(hM1_min,"hM1_min",nscale);
print_polynomial(hM1_min,"hM1_min",strcat(strf,"_hM1_min_coef.m"),nscale);

% Find mean-squared errrors
Esq1=directFIRsymmetricEsqPW(hM1,waf,Adf,Waf)
Esq1_sd=directFIRsymmetricEsqPW(hM1_sd,waf,Adf,Waf)
Esq1_sdp=directFIRsymmetricEsqPW(hM1_sdp,waf,Adf,Waf)
Esq1_min=directFIRsymmetricEsqPW(hM1_min,waf,Adf,Waf)

% Find digits
[hM1_sd_digits,hM1_sd_adders]=SDadders(hM1_sd,nbits)
[hM1_sdp_digits,hM1_sdp_adders]=SDadders(hM1_sdp,nbits)
[hM1_min_digits,hM1_min_adders]=SDadders(hM1_min,nbits)

% Calculate response
A_hM1=directFIRsymmetricA(wa,hM1);
A_hM1_sd=directFIRsymmetricA(wa,hM1_sd);
A_hM1_sdp=directFIRsymmetricA(wa,hM1_sdp);
A_hM1_min=directFIRsymmetricA(wa,hM1_min);

% Sanity check on response
h_min=[hM1_min(:);flipud(hM1_min(:)(1:end-1))];
H_min=freqz(h_min,1,wa);
if max(abs(abs(H_min)-abs(A_hM1_min))) > 100*eps
  error("max(abs(abs(H_min)-A_hM1_min))(%g*eps) > 100*eps", ...
        max(abs(abs(H_min)-A_hM1_min))/eps);
endif

% Find maximum lower stop-band response error
Rsbl=[1:nasl];
[max_sbl_A_hM1    ,max_sbl_A_hM1_n]    =max(abs(A_hM1(Rsbl)));
[max_sbl_A_hM1_sd ,max_sbl_A_hM1_sd_n] =max(abs(A_hM1_sd(Rsbl)));
[max_sbl_A_hM1_sdp,max_sbl_A_hM1_sdp_n]=max(abs(A_hM1_sdp(Rsbl)));
[max_sbl_A_hM1_min,max_sbl_A_hM1_min_n]=max(abs(A_hM1_min(Rsbl)));

printf("At f=%g, max_sbl_A_hM1=%g\n", ...
       wa(max_sbl_A_hM1_n)*0.5/pi,max_sbl_A_hM1);
printf("At f=%g, max_sbl_A_hM1_sd=%g\n", ...
       wa(max_sbl_A_hM1_sd_n)*0.5/pi,max_sbl_A_hM1_sd);
printf("At f=%g, max_sbl_A_hM1_sdp=%g\n", ...
       wa(max_sbl_A_hM1_sdp_n)*0.5/pi,max_sbl_A_hM1_sdp);
printf("At f=%g, max_sbl_A_hM1_min=%g\n", ...
       wa(max_sbl_A_hM1_min_n)*0.5/pi,max_sbl_A_hM1_min);

% Find maximum pass-band response error
Rpb=[napl:napu];
[max_pb_A_hM1    ,max_pb_A_hM1_n]    =max(abs(A_hM1(Rpb)   -1));
[max_pb_A_hM1_sd ,max_pb_A_hM1_sd_n] =max(abs(A_hM1_sd(Rpb)-1));
[max_pb_A_hM1_sdp,max_pb_A_hM1_sdp_n]=max(abs(A_hM1_sdp(Rpb)-1));
[max_pb_A_hM1_min,max_pb_A_hM1_min_n]=max(abs(A_hM1_min(Rpb)-1));

printf("At f=%g, max_pb_A_hM1=%g\n", ...
       wa(napl-1+max_pb_A_hM1_n)*0.5/pi,max_pb_A_hM1);
printf("At f=%g, max_pb_A_hM1_sd=%g\n", ...
       wa(napl-1+max_pb_A_hM1_sd_n)*0.5/pi,max_pb_A_hM1_sd);
printf("At f=%g, max_pb_A_hM1_sdp=%g\n", ...
       wa(napl-1+max_pb_A_hM1_sdp_n)*0.5/pi,max_pb_A_hM1_sdp);
printf("At f=%g, max_pb_A_hM1_min=%g\n", ...
       wa(napl-1+max_pb_A_hM1_min_n)*0.5/pi,max_pb_A_hM1_min);

% Find maximum upper stop-band response error
Rsbu=[nasu:length(wa)];
[max_sbu_A_hM1    ,max_sbu_A_hM1_n]    =max(abs(A_hM1(Rsbu)));
[max_sbu_A_hM1_sd ,max_sbu_A_hM1_sd_n] =max(abs(A_hM1_sd(Rsbu)));
[max_sbu_A_hM1_sdp,max_sbu_A_hM1_sdp_n]=max(abs(A_hM1_sdp(Rsbu)));
[max_sbu_A_hM1_min,max_sbu_A_hM1_min_n]=max(abs(A_hM1_min(Rsbu)));

printf("At f=%g, max_sbu_A_hM1=%g\n", ...
       wa(nasu-1+max_sbu_A_hM1_n)*0.5/pi,max_sbu_A_hM1);
printf("At f=%g, max_sbu_A_hM1_sd=%g\n", ...
       wa(nasu-1+max_sbu_A_hM1_sd_n)*0.5/pi,max_sbu_A_hM1_sd);
printf("At f=%g, max_sbu_A_hM1_sdp=%g\n", ...
       wa(nasu-1+max_sbu_A_hM1_sdp_n)*0.5/pi,max_sbu_A_hM1_sdp);
printf("At f=%g, max_sbu_A_hM1_min=%g\n", ...
       wa(nasu-1+max_sbu_A_hM1_min_n)*0.5/pi,max_sbu_A_hM1_min);

% Make a LaTeX table for cost
fid=fopen(strcat(strf,"_cost.tab"),"wt");
fprintf(fid,"Initial & %10.3e & %10.5f & & \\\\\n",Esq1,max_pb_A_hM1);
fprintf(fid,"%d-bit %d-signed-digit & %10.3e & %10.5f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq1_sd,max_pb_A_hM1_sd,hM1_sd_digits,hM1_sd_adders);
fprintf(fid,"%d-bit %d-signed-digit(SDP) & %10.3e & %10.5f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq1_sdp,max_pb_A_hM1_sdp, ...
        hM1_sdp_digits,hM1_sdp_adders);
fprintf(fid,"%d-bit %d-signed-digit(min) & %10.3e & %10.5f & %d & %d \\\\\n", ...
        nbits,ndigits,Esq1_min,max_pb_A_hM1_min, ...
        hM1_min_digits,hM1_min_adders);
fclose(fid);

% Dual plot of amplitude response
[ax,h1,h2]=plotyy(wa*0.5/pi, ...
                  20*log10(abs([A_hM1,A_hM1_sd,A_hM1_sdp,A_hM1_min])), ...
                  wa*0.5/pi, ...
                  20*log10(abs([A_hM1,A_hM1_sd,A_hM1_sdp,A_hM1_min])));
% Hack to set line colour and style 
h1c=get(h1,"color");
for c=1:4
  set(h2(c),"color",h1c{c});
endfor
set(h1(1),"linestyle","-");
set(h1(2),"linestyle",":");
set(h1(3),"linestyle","--");
set(h1(4),"linestyle","-.");
set(h2(1),"linestyle","-");
set(h2(2),"linestyle",":");
set(h2(3),"linestyle","--");
set(h2(4),"linestyle","-.");
% End of hack
axis(ax(1),[0, 0.5, -60,  -20]);
axis(ax(2),[0, 0.5,  -1,    1]);
grid("on");
ylabel(ax(1),"Amplitude(dB)");
xlabel("Frequency");
legend("Initial","s-d","s-d(SDP)","s-d(min)");
legend("location","northeast");
legend("boxoff");
legend("left");
strt=sprintf(["FIR band-pass filter (nbits=%d,ndigits=%d) : ", ...
              "fasl=%g,fapl=%g,fapu=%g,fasu=%g,dBap=%g,dBas=%g"], ...
             nbits,ndigits,fasl,fapl,fapu,fapl,dBap,dBas);
title(strt);
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
fprintf(fid,"fasl=%g %% Amplitude stop band lower edge\n",fasl);
fprintf(fid,"fasu=%g %% Amplitude stop band upper edge\n",fasu);
fprintf(fid,"dBas=%g %% Amplitude stop band peak-to-peak ripple\n",dBas);
fprintf(fid,"Wasl=%g %% Amplitude lower stop band weight\n",Wasl);
fprintf(fid,"Wasu=%g %% Amplitude upper stop band weight\n",Wasu);
fclose(fid);

% Save results
eval(sprintf(["save %s.mat ftol ctol nbits nscale ndigits n ", ...
              "fapl fapu dBap Wap fasl fasu dBas Wasl Wasu ", ...
              "hM1 hM1_sd hM1_sdp hM1_min"], ...
             strf));
       
% Done
toc;
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
