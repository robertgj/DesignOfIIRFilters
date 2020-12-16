% directFIRsymmetric_bandpass_allocsd_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen
%
% Test Lims and Itos signed-digit allocation algorithms with
% coefficients of a band-pass, symmetric, even-order FIR filter

test_common;

delete("directFIRsymmetric_bandpass_allocsd_test.diary");
delete("directFIRsymmetric_bandpass_allocsd_test.diary.tmp");
diary directFIRsymmetric_bandpass_allocsd_test.diary.tmp

maxiter=500;
verbose=true;
tol=1e-5;
ctol=tol;

% Initialise
% pass Band filter
M=15;
fapl=0.1;fapu=0.2;Wap=1;dBap=2;
fasll=0.04;fasl=0.05;fasu=0.25;fasuu=0.26;Wasl=20;Wasu=40;dBas=46;

% Desired magnitude response
npoints=1000;
wa=(0:npoints)'*pi/npoints;
nasll=floor(npoints*fasll/0.5)+1;
nasl=ceil(npoints*fasl/0.5)+1;
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
nasu=floor(npoints*fasu/0.5)+1;
nasuu=ceil(npoints*fasuu/0.5)+1;
na=[1 nasl napl napu nasu length(wa)];
Ad=[zeros(napl-1,1); ...
    ones(napu-napl+1,1); ...
    zeros(npoints-napu+1,1)];
Adu=[(10^(-dBas/20))*ones(nasl,1); ...
     ones(nasu-nasl-1,1); ...
     (10^(-dBas/20))*ones(npoints-nasu+2,1)];
Adl=[-(10^(-dBas/20))*ones(napl-1,1); ...
      (10^(-dBap/20))*ones(napu-napl+1,1); ...
     -(10^(-dBas/20))*ones(npoints-napu+1,1)];
Wa=[Wasl*ones(nasl,1); ...
    zeros(napl-nasl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    zeros(nasu-napu-1,1); ...
    Wasu*ones(npoints-nasu+2,1)];

% For directFIRsymmetricEsqPW
waf=wa([1 nasl napl napu nasu end]);
Adf=[0 0 1 0 0];
Waf=[Wasl 0 Wap 0 Wasu];

% Make an initial band pass filter
h0=remez(2*M,[0,fasl,fapl,fapu,fasu,0.5]*2,[0 0 1 1 0 0],[Wasl,Wap,Wasu]);
hM0=h0(1:(M+1));
hM0_active=1:length(hM0);

%
% Find SLB solution
%
[hM,slb_iter,socp_iter,func_iter,feasible]= ...
  directFIRsymmetric_slb(@directFIRsymmetric_mmsePW, ...
                         hM0,hM0_active,na,wa,Ad,Adu,Adl,Wa, ...
                         maxiter,tol,ctol,verbose);
if feasible==false
  error("directFIRsymmetric_slb failed!");
endif

% Find response of exact filter
A_ex=directFIRsymmetricA(wa,hM);

nbits_range=[6:16];
nbits_cost_rd=zeros(size(nbits_range));
nbits_sidelobe_rd=zeros(size(nbits_range));
nbits_hM_rd_digits=zeros(size(nbits_range));
nbits_cost_sd=zeros(size(nbits_range));
nbits_sidelobe_sd=zeros(size(nbits_range));
nbits_hM_sd_digits=zeros(size(nbits_range));
nbits_cost_Lim=zeros(size(nbits_range));
nbits_sidelobe_Lim=zeros(size(nbits_range));
nbits_hM_digits_Lim=zeros(size(nbits_range));
nbits_cost_Ito=zeros(size(nbits_range));
nbits_sidelobe_Ito=zeros(size(nbits_range));
nbits_hM_digits_Ito=zeros(size(nbits_range));
for ndigits=2:3
  strf=sprintf("directFIRsymmetric_bandpass_allocsd_%d_ndigits_test",ndigits);
  for l=1:length(nbits_range),
    nbits=nbits_range(l);
    nscale=2^(nbits-1);
    nbits_strf=sprintf ...
      ("directFIRsymmetric_bandpass_allocsd_%d_ndigits_%d_nbits_test",
       ndigits,nbits);
    
    % Rounded truncation
    hM_rd=round(hM.*nscale)./nscale;
    nbits_cost_rd(l)= ...
      directFIRsymmetricEsqPW(hM_rd,waf,Adf,Waf);
    A_rd=directFIRsymmetricA(wa,hM_rd);
    % Find the actual number of signed digits used
    nbits_hM_rd_digits(l)=SDadders(hM_rd,nbits);
    
    % Signed-digit truncation without allocation
    hM_sd=flt2SD(hM,nbits,ndigits);
    nbits_cost_sd(l)=directFIRsymmetricEsqPW(hM_sd,waf,Adf,Waf);
    A_sd=directFIRsymmetricA(wa,hM_sd);
    % Find the actual number of signed digits used
    nbits_hM_sd_digits(l)=SDadders(hM_sd,nbits);

    % Use Lim's heuristic to allocate an average of ndigits signed-digits
    ndigits_Lim=directFIRsymmetric_allocsd_Lim ...
                  (nbits,ndigits,hM,waf,Adf,ones(size(Waf)));
    print_polynomial(int16(ndigits_Lim(1:length(hM))), ...
                     "hM_allocsd_digits", ...
                     strcat(nbits_strf,"_hM_Lim_digits.m"),"%2d");
    % Signed-digits allocated by Lim
    hM_Lim=flt2SD(hM,nbits,ndigits_Lim(1:length(hM)));
    nbits_cost_Lim(l)=directFIRsymmetricEsqPW(hM_Lim,waf,Adf,Waf);
    A_Lim=directFIRsymmetricA(wa,hM_Lim);
    % Find the actual number of signed digits used
    [nbits_hM_digits_Lim(l),hM_Lim_adders]=SDadders(hM_Lim,nbits);
    fid=fopen(strcat(nbits_strf,"_Lim.adders.tab"),"wt");
    fprintf(fid,"$%d$",hM_Lim_adders);
    fclose(fid);

    % Use Ito's heuristic to allocate an average of ndigits signed-digits
    ndigits_Ito=directFIRsymmetric_allocsd_Ito(nbits,ndigits,hM,waf,Adf,Waf);
    print_polynomial(int16(ndigits_Ito(1:length(hM))), ...
                     "hM_allocsd_digits", ...
                     strcat(nbits_strf,"_hM_Ito_digits.m"),"%2d");
    % Signed-digits allocated by Ito
    hM_Ito=flt2SD(hM,nbits,ndigits_Ito(1:length(hM)));
    nbits_cost_Ito(l)=directFIRsymmetricEsqPW(hM_Ito,waf,Adf,Waf);
    A_Ito=directFIRsymmetricA(wa,hM_Ito);
    % Find the actual number of signed digits used
    [nbits_hM_digits_Ito(l),hM_Ito_adders]=SDadders(hM_Ito,nbits);
    fid=fopen(strcat(nbits_strf,"_Ito.adders.tab"),"wt");
    fprintf(fid,"$%d$",hM_Ito_adders);
    fclose(fid);

    % Plot the results 
    subplot(211)
    plot(wa*0.5/pi,20*log10(abs(A_ex)),"linestyle","-", ...
         wa*0.5/pi,20*log10(abs(A_rd)),"linestyle",":", ...
         wa*0.5/pi,20*log10(abs(A_sd)),"linestyle","-.", ... 
         wa*0.5/pi,20*log10(abs(A_Lim)),"linestyle","--", ...
         wa*0.5/pi,20*log10(abs(A_Ito)),"linestyle","-")
    ylabel("Amplitude(dB)");
    legend("exact","round","signed-digit","Lim","Ito");
    legend("location","northeast");
    legend("boxoff");
    legend("left");
    axis([0 0.5 -2 2]);
    grid("on");
    strt=sprintf("Bandpass symmetric FIR,nbits=%d,ndigits=%d",
                 nbits,ndigits);
    title(strt);
    subplot(212)
    plot(wa*0.5/pi,20*log10(abs(A_ex)),"linestyle","-", ...
         wa*0.5/pi,20*log10(abs(A_rd)),"linestyle",":", ...
         wa*0.5/pi,20*log10(abs(A_sd)),"linestyle","-.", ... 
         wa*0.5/pi,20*log10(abs(A_Lim)),"linestyle","--",...
         wa*0.5/pi,20*log10(abs(A_Ito)),"linestyle","-")
    xlabel("Frequency");
    ylabel("Amplitude(dB)");
    axis([0 0.5 -60 10]);
    grid("on");
    print(strcat(nbits_strf,"_response"),"-dpdflatex");
    close

    % Print the maximum side-lobe for Lim
    printf("\n");
    printf("Lim,ndigits=%d,nbits=%d,maximum stop-band (0.00 to %4.2f) = %gdB\n",
           ndigits,nbits,fasll,max(20*log10(abs(A_Lim(1:nasll)))));
    printf("Lim,ndigits=%d,nbits=%d,maximum stop-band (0.00 to %4.2f) = %gdB\n",
           ndigits,nbits,fasl,max(20*log10(abs(A_Lim(1:nasl)))));
    printf("Lim,ndigits=%d,nbits=%d,maximum stop-band (%4.2f to 0.50) = %gdB\n",
           ndigits,nbits,fasu,max(20*log10(abs(A_Lim(nasu:end)))));
    printf("Lim,ndigits=%d,nbits=%d,maximum stop-band (%4.2f to 0.50) = %gdB\n",
           ndigits,nbits,fasuu,max(20*log10(abs(A_Lim(nasuu:end)))));
    
    % Print the maximum side-lobe for Ito
    printf("\n");
    printf("Ito,ndigits=%d,nbits=%d,maximum stop-band (0.00 to %4.2f) = %gdB\n",
           ndigits,nbits,fasll,max(20*log10(abs(A_Ito(1:nasll))))); 
    printf("Ito,ndigits=%d,nbits=%d,maximum stop-band (0.00 to %4.2f) = %gdB\n",
           ndigits,nbits,fasl,max(20*log10(abs(A_Ito(1:nasl)))));
    printf("Ito,ndigits=%d,nbits=%d,maximum stop-band (%4.2f to 0.50) = %gdB\n",
           ndigits,nbits,fasu,max(20*log10(abs(A_Ito(nasu:end)))));
    printf("Ito,ndigits=%d,nbits=%d,maximum stop-band (%4.2f to 0.50) = %gdB\n",
           ndigits,nbits,fasuu,max(20*log10(abs(A_Ito(nasuu:end)))));

    % Save the maximum sidelobes in upper stop band (fasuu to 0.50)
    nbits_sidelobe_ex(l)=max(20*log10(abs(A_ex(nasuu:end))));
    nbits_sidelobe_rd(l)=max(20*log10(abs(A_rd(nasuu:end))));
    nbits_sidelobe_sd(l)=max(20*log10(abs(A_sd(nasuu:end))));
    nbits_sidelobe_Lim(l)=max(20*log10(abs(A_Lim(nasuu:end))));
    nbits_sidelobe_Ito(l)=max(20*log10(abs(A_Ito(nasuu:end))));
    
    % Print the results
    print_polynomial(hM_rd,sprintf("hM_rd_%d_bits",nbits),...
                     strcat(nbits_strf,"_hM_rd_coef.m"),nscale);
    print_polynomial(hM_sd,sprintf("hM_sd_%d_bits",nbits),...
                     strcat(nbits_strf,"_hM_sd_coef.m"),nscale);
    print_polynomial(hM_Lim,sprintf("hM_Lim_%d_bits",nbits),...
                     strcat(nbits_strf,"_hM_Lim_coef.m"),nscale);
    print_polynomial(hM_Ito,sprintf("hM_Ito_%d_bits",nbits),...
                     strcat(nbits_strf,"_hM_Ito_coef.m"),nscale);
  endfor

  % Plot comparison of cost
  subplot(111)
  semilogy(nbits_range,nbits_cost_rd,"linestyle",":", ...
           nbits_range,nbits_cost_sd,"linestyle","-.", ... 
           nbits_range,nbits_cost_Lim,"linestyle","--",...
           nbits_range,nbits_cost_Ito,"linestyle","-")
  strt=sprintf("Bandpass symmetric FIR cost, ndigits=%d", ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Cost");
  grid("off");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  print(strcat(strf,"_cost"),"-dpdflatex");
  close

  % Plot comparison of maximum response
  subplot(111)
  plot(nbits_range,nbits_sidelobe_rd,"linestyle",":", ...
       nbits_range,nbits_sidelobe_sd,"linestyle","-.", ... 
       nbits_range,nbits_sidelobe_Lim,"linestyle","--", ...
       nbits_range,nbits_sidelobe_Ito,"linestyle","-")
  strt=sprintf("Bandpass symmetric FIR maximum response \
in [%4.2f,0.5) (dB), ndigits=%d",fasuu,ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Maximum response(dB)");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  print(strcat(strf,"_sidelobe"),"-dpdflatex");
  close

  % Plot comparison of total signed-digits used
  subplot(111)
  plot(nbits_range,nbits_hM_rd_digits,"linestyle",":", ...
       nbits_range,nbits_hM_sd_digits,"linestyle","-.", ... 
       nbits_range,nbits_hM_digits_Lim,"linestyle","--",...
       nbits_range,nbits_hM_digits_Ito,"linestyle","-")
  strt=sprintf("Bandpass symmetric FIR total signed-digits \
used by coefficients, ndigits=%d",ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Total signed-digits used by coefficients");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northwest");
  legend("boxoff");
  legend("left");
  print(strcat(strf,"_digits"),"-dpdflatex");
  close
  
endfor

% Done
diary off
movefile directFIRsymmetric_bandpass_allocsd_test.diary.tmp ... 
         directFIRsymmetric_bandpass_allocsd_test.diary;
