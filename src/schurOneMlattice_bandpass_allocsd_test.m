% schurOneMlattice_bandpass_allocsd_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test Lims and Itos signed-digit allocation algorithms with
% coefficents of a band-pass one-multiplier lattice filter.

test_common;

delete("schurOneMlattice_bandpass_allocsd_test.diary");
delete("schurOneMlattice_bandpass_allocsd_test.diary.tmp");
diary schurOneMlattice_bandpass_allocsd_test.diary.tmp

% Initialise
schurOneMlattice_bandpass_10_nbits_common;

% Find response of exact filter
nplot=250;
Asq_ex=schurOneMlatticeAsq(wa,k0,epsilon0,p0,c0);
T_ex=schurOneMlatticeT(wt,k0,epsilon0,p0,c0);

% Find noise gain of exact filter ignoring state scaling
[A_ex,B_ex,C_ex,D_ex]=schurOneMR2lattice2Abcd(k0,epsilon0,c0);
[K_ex,W_ex]=KW(A_ex,B_ex,C_ex,D_ex);
selectX_ex=(sum(A_ex~=0,2)+(B_ex~=0))>1;
ng_ex=sum(diag(K_ex).*diag(W_ex).*selectX_ex)
printf("Exact filter noise gain=%g\n",ng_ex);

nbits_range=[6:16];
nbits_cost_rd=zeros(size(nbits_range));
nbits_sidelobe_rd=zeros(size(nbits_range));
nbits_kc_rd_digits=zeros(size(nbits_range));
nbits_cost_sd=zeros(size(nbits_range));
nbits_sidelobe_sd=zeros(size(nbits_range));
nbits_kc_sd_digits=zeros(size(nbits_range));
nbits_cost_Lim=zeros(size(nbits_range));
nbits_sidelobe_Lim=zeros(size(nbits_range));
nbits_kc_digits_Lim=zeros(size(nbits_range));
nbits_cost_Ito=zeros(size(nbits_range));
nbits_sidelobe_Ito=zeros(size(nbits_range));
nbits_kc_digits_Ito=zeros(size(nbits_range));
nbits_ng_rd=zeros(size(nbits_range));
nbits_ng_sd=zeros(size(nbits_range));
nbits_ng_Lim=zeros(size(nbits_range));
nbits_ng_Ito=zeros(size(nbits_range));
for ndigits=2:3
  strf=sprintf("schurOneMlattice_bandpass_allocsd_%d_ndigits_test",ndigits);
  for l=1:length(nbits_range),
    nbits=nbits_range(l);
    nscale=2^(nbits-1);
    nbits_strf= ...
      sprintf("schurOneMlattice_bandpass_allocsd_%d_ndigits_%d_nbits_test", ...
              ndigits,nbits);
    
    % Rounded truncation
    k_rd=round(k0.*nscale)./nscale;
    c_rd=round(c0.*nscale)./nscale;
    nbits_cost_rd(l)= ...
    schurOneMlatticeEsq(k_rd,epsilon0,ones(size(p0)),c_rd,wa,Asqd,Wa,wt,Td,Wt);
    Asq_rd=schurOneMlatticeAsq(wa,k_rd,epsilon0,ones(size(p0)),c_rd);
    T_rd=schurOneMlatticeT(wt,k_rd,epsilon0,ones(size(p0)),c_rd);
    % Find the actual number of signed digits used
    kc_rd=[k_rd(:);c_rd(:)];
    nbits_kc_rd_digits(l)=SDadders(kc_rd,nbits);
    
    % Calculate the noise gain
    [A_rd,B_rd,C_rd,D_rd]=schurOneMR2lattice2Abcd(k_rd,epsilon0,c_rd);
    [K_rd,W_rd]=KW(A_rd,B_rd,C_rd,D_rd);
    selectX_rd=(sum(A_rd~=0,2)+(B_rd~=0))>1;
    nbits_ng_rd(l)=sum(diag(K_rd).*diag(W_rd).*selectX_rd);
    printf("Round,ndigits=%d,nbits=%d,ng=%g\n",ndigits,nbits,nbits_ng_rd(l));
 
    % Signed-digit truncation without allocation
    k_sd=flt2SD(k0,nbits,ndigits);
    c_sd=flt2SD(c0,nbits,ndigits);
    nbits_cost_sd(l)= ...
      schurOneMlatticeEsq(k_sd,epsilon0,ones(size(p0)),c_sd,wa,Asqd,Wa,wt,Td,Wt);
    Asq_sd=schurOneMlatticeAsq(wa,k_sd,epsilon0,ones(size(p0)),c_sd);
    T_sd=schurOneMlatticeT(wt,k_sd,epsilon0,ones(size(p0)),c_sd);
    % Find the actual number of signed digits used
    kc_sd=[k_sd(:);c_sd(:)];
    nbits_kc_sd_digits(l)=SDadders(kc_sd,nbits);

    % Calculate the noise gain
    [A_sd,B_sd,C_sd,D_sd]=schurOneMR2lattice2Abcd(k_sd,epsilon0,c_sd);
    [K_sd,W_sd]=KW(A_sd,B_sd,C_sd,D_sd);
    selectX_sd=(sum(A_sd~=0,2)+(B_sd~=0))>1;
    nbits_ng_sd(l)=sum(diag(K_sd).*diag(W_sd).*selectX_sd);
    printf("S-d,ndigits=%d,nbits=%d,ng=%g\n",ndigits,nbits,nbits_ng_sd(l));

    % Use Lim's heuristic to allocate an average of ndigits signed-digits
    ndigits_Lim=schurOneMlattice_allocsd_Lim ...
                  (nbits,ndigits,k0,epsilon0,p0,c0,...
                   wa,Asqd,ones(size(wa)),wt,Td,ones(size(wt)));
    print_polynomial(int16(ndigits_Lim(1:length(k0))), ...
                     "k_allocsd_digits", ...
                     strcat(nbits_strf,"_k_Lim_digits.m"),"%2d");
    print_polynomial(int16(ndigits_Lim((length(k0)+1):end)), ...
                     "c_allocsd_digits", ...
                     strcat(nbits_strf,"_c_Lim_digits.m"),"%2d");
    % Signed-digits allocated by Lim
    k_Lim=flt2SD(k0,nbits,ndigits_Lim(1:length(k0)));
    c_Lim=flt2SD(c0,nbits,ndigits_Lim((length(k0)+1):end));
    nbits_cost_Lim(l)=schurOneMlatticeEsq(k_Lim,epsilon0,ones(size(p0)),c_Lim,...
                                          wa,Asqd,Wa,wt,Td,Wt);
    Asq_Lim=schurOneMlatticeAsq(wa,k_Lim,epsilon0,ones(size(p0)),c_Lim);
    T_Lim=schurOneMlatticeT(wt,k_Lim,epsilon0,ones(size(p0)),c_Lim);
    % Find the actual number of signed digits used
    kc_Lim=[k_Lim(:);c_Lim(:)];
    [nbits_kc_digits_Lim(l),kc_Lim_adders]=SDadders(kc_Lim,nbits);
    fid=fopen(strcat(nbits_strf,"_Lim.adders.tab"),"wt");
    fprintf(fid,"$%d$",kc_Lim_adders);
    fclose(fid);
    % Calculate the noise gain
    [A_Lim,B_Lim,C_Lim,D_Lim]=schurOneMR2lattice2Abcd(k_Lim,epsilon0,c_Lim);
    [K_Lim,W_Lim]=KW(A_Lim,B_Lim,C_Lim,D_Lim);
    selectX_Lim=(sum(A_Lim~=0,2)+(B_Lim~=0))>1;
    nbits_ng_Lim(l)=sum(diag(K_Lim).*diag(W_Lim).*selectX_Lim);
    printf("Lim,ndigits=%d,nbits=%d,ng=%g\n",ndigits,nbits,nbits_ng_Lim(l));

    % Use Ito's heuristic to allocate an average of ndigits signed-digits
    ndigits_Ito=schurOneMlattice_allocsd_Ito(nbits,ndigits, ...
                                             k0,epsilon0,ones(size(p0)),c0, ...
                                             wa,Asqd,Wa,wt,Td,Wt);
    print_polynomial(int16(ndigits_Ito(1:length(k0))), ...
                     "k_allocsd_digits", ...
                     strcat(nbits_strf,"_k_Ito_digits.m"),"%2d");
    print_polynomial(int16(ndigits_Ito((length(k0)+1):end)), ...
                     "c_allocsd_digits", ...
                     strcat(nbits_strf,"_c_Ito_digits.m"),"%2d");
    % Signed-digits allocated by Ito
    k_Ito=flt2SD(k0,nbits,ndigits_Ito(1:length(k0)));
    c_Ito=flt2SD(c0,nbits,ndigits_Ito((length(k0)+1):end));
    nbits_cost_Ito(l)=schurOneMlatticeEsq(k_Ito,epsilon0,ones(size(p0)),c_Ito,...
                                          wa,Asqd,Wa,wt,Td,Wt);
    Asq_Ito=schurOneMlatticeAsq(wa,k_Ito,epsilon0,ones(size(p0)),c_Ito);
    T_Ito=schurOneMlatticeT(wt,k_Ito,epsilon0,ones(size(p0)),c_Ito);
    % Find the actual number of signed digits used
    kc_Ito=[k_Ito(:);c_Ito(:)];
    [nbits_kc_digits_Ito(l),kc_Ito_adders]=SDadders(kc_Ito,nbits);
    fid=fopen(strcat(nbits_strf,"_Ito.adders.tab"),"wt");
    fprintf(fid,"$%d$",kc_Ito_adders);
    fclose(fid);
    % Calculate the noise gain
    [A_Ito,B_Ito,C_Ito,D_Ito]=schurOneMR2lattice2Abcd(k_Ito,epsilon0,c_Ito);
    [K_Ito,W_Ito]=KW(A_Ito,B_Ito,C_Ito,D_Ito);
    selectX_Ito=(sum(A_Ito~=0,2)+(B_Ito~=0))>1;
    nbits_ng_Ito(l)=sum(diag(K_Ito).*diag(W_Ito).*selectX_Ito);
    printf("Ito,ndigits=%d,nbits=%d,ng=%g\n",ndigits,nbits,nbits_ng_Ito(l));

    % Plot the results
    subplot(111)
    plot(wa*0.5/pi,10*log10(Asq_ex),"linestyle","-", ...
         wa*0.5/pi,10*log10(Asq_rd),"linestyle",":", ...
         wa*0.5/pi,10*log10(Asq_sd),"linestyle","-.", ... 
         wa*0.5/pi,10*log10(Asq_Lim),"linestyle","--",...
         wa*0.5/pi,10*log10(Asq_Ito),"linestyle","-")
    xlabel("Frequency");
    ylabel("Amplitude(dB)");
    axis([0 0.5 -60 10]);
    grid("on");
    strt=sprintf("Bandpass one-multiplier lattice,nbits=%d,ndigits=%d",
                 nbits,ndigits);
    title(strt);
    legend("exact","round","signed-digit","Lim","Ito");
    legend("location","northeast");
    legend("boxoff");
    legend("left");
    print(strcat(nbits_strf,"_response"),"-dpdflatex");
    close
    % Plot the passband detail
    subplot(211)
    plot(wa*0.5/pi,10*log10(Asq_ex),"linestyle","-", ...
         wa*0.5/pi,10*log10(Asq_rd),"linestyle",":", ...
         wa*0.5/pi,10*log10(Asq_sd),"linestyle","-.", ... 
         wa*0.5/pi,10*log10(Asq_Lim),"linestyle","--", ...
         wa*0.5/pi,10*log10(Asq_Ito),"linestyle","-")
    title(strt);
    xlabel("Frequency");
    ylabel("Amplitude(dB)");
    legend("exact","round","signed-digit","Lim","Ito");
    legend("location","northeast");
    legend("boxoff");
    legend("left");
    axis([0.05 0.25 -2 2]);
    grid("on");
    subplot(212)
    plot(wt*0.5/pi,T_ex,"linestyle","-", ...
         wt*0.5/pi,T_rd,"linestyle",":", ...
         wt*0.5/pi,T_sd,"linestyle","-.", ... 
         wt*0.5/pi,T_Lim,"linestyle","--", ...
         wt*0.5/pi,T_Ito,"linestyle","-");
    xlabel("Frequency");
    ylabel("Group delay(samples)");
    axis([0.05 0.25 15 17]);
    grid("on");
    print(strcat(nbits_strf,"_passband_response"),"-dpdflatex");
    close

    % Print the maximum side-lobe for Lim
    printf("\n");
    printf("Lim,ndigits=%d,nbits=%d,maximum stop-band (0.00 to %4.2f) = %gdB\n",
           ndigits,nbits,fasll,max(10*log10(Asq_Lim(1:nasll))));
    printf("Lim,ndigits=%d,nbits=%d,maximum stop-band (0.00 to %4.2f) = %gdB\n",
           ndigits,nbits,fasl,max(10*log10(Asq_Lim(1:nasl))));
    printf("Lim,ndigits=%d,nbits=%d,maximum stop-band (%4.2f to 0.50) = %gdB\n",
           ndigits,nbits,fasu,max(10*log10(Asq_Lim(nasu:end))));
    printf("Lim,ndigits=%d,nbits=%d,maximum stop-band (%4.2f to 0.50) = %gdB\n",
           ndigits,nbits,fasuu,max(10*log10(Asq_Lim(nasuu:end))));
    
    % Print the maximum side-lobe for Ito
    printf("\n");
    printf("Ito,ndigits=%d,nbits=%d,maximum stop-band (0.00 to %4.2f) = %gdB\n",
           ndigits,nbits,fasll,max(10*log10(Asq_Ito(1:nasll)))); 
    printf("Ito,ndigits=%d,nbits=%d,maximum stop-band (0.00 to %4.2f) = %gdB\n",
           ndigits,nbits,fasl,max(10*log10(Asq_Ito(1:nasl))));
    printf("Ito,ndigits=%d,nbits=%d,maximum stop-band (%4.2f to 0.50) = %gdB\n",
           ndigits,nbits,fasu,max(10*log10(Asq_Ito(nasu:end))));
    printf("Ito,ndigits=%d,nbits=%d,maximum stop-band (%4.2f to 0.50) = %gdB\n",
           ndigits,nbits,fasuu,max(10*log10(Asq_Ito(nasuu:end))));

    % Save the maximum sidelobes in upper stop band (fasuu to 0.50)
    nbits_sidelobe_ex(l)=max(10*log10(Asq_ex(nasuu:end)));
    nbits_sidelobe_rd(l)=max(10*log10(Asq_rd(nasuu:end)));
    nbits_sidelobe_sd(l)=max(10*log10(Asq_sd(nasuu:end)));
    nbits_sidelobe_Lim(l)=max(10*log10(Asq_Lim(nasuu:end)));
    nbits_sidelobe_Ito(l)=max(10*log10(Asq_Ito(nasuu:end)));
    
    % Print the results
    print_polynomial(k_rd,sprintf("k_rd_%d_bits",nbits),...
                     strcat(nbits_strf,"_k_rd_coef.m"),nscale);
    print_polynomial(c_rd,sprintf("c_rd_%d_bits",nbits),...
                     strcat(nbits_strf,"_c_rd_coef.m"),nscale);
    print_polynomial(k_sd,sprintf("k_sd_%d_bits",nbits),...
                     strcat(nbits_strf,"_k_sd_coef.m"),nscale);
    print_polynomial(c_sd,sprintf("c_sd_%d_bits",nbits),...
                     strcat(nbits_strf,"_c_sd_coef.m"),nscale);
    print_polynomial(k_Lim,sprintf("k_Lim_%d_bits",nbits),...
                     strcat(nbits_strf,"_k_Lim_coef.m"),nscale);
    print_polynomial(c_Lim,sprintf("c_Lim_%d_bits",nbits),...
                     strcat(nbits_strf,"_c_Lim_coef.m"),nscale);
    print_polynomial(k_Ito,sprintf("k_Ito_%d_bits",nbits),...
                     strcat(nbits_strf,"_k_Ito_coef.m"),nscale);
    print_polynomial(c_Ito,sprintf("c_Ito_%d_bits",nbits),...
                     strcat(nbits_strf,"_c_Ito_coef.m"),nscale);
  endfor

  % Plot comparison of cost
  subplot(111)
  semilogy(nbits_range,nbits_cost_rd,"linestyle",":", ...
           nbits_range,nbits_cost_sd,"linestyle","-.", ... 
           nbits_range,nbits_cost_Lim,"linestyle","--",...
           nbits_range,nbits_cost_Ito,"linestyle","-")
  strt=sprintf("Bandpass one-multiplier lattice cost, ndigits=%d", ndigits);
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

  % Plot comparison of maximum response in [0.26,0.5)
  subplot(111)
  plot(nbits_range,nbits_sidelobe_rd,"linestyle",":", ...
       nbits_range,nbits_sidelobe_sd,"linestyle","-.", ... 
       nbits_range,nbits_sidelobe_Lim,"linestyle","--", ...
       nbits_range,nbits_sidelobe_Ito,"linestyle","-")
  strt=sprintf("Bandpass one-multiplier lattice maximum response \
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
  plot(nbits_range,nbits_kc_rd_digits,"linestyle",":", ...
       nbits_range,nbits_kc_sd_digits,"linestyle","-.", ... 
       nbits_range,nbits_kc_digits_Lim,"linestyle","--",...
       nbits_range,nbits_kc_digits_Ito,"linestyle","-")
  strt=sprintf("Bandpass one-multiplier lattice total signed-digits \
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

  % Plot comparison of noise gain
  subplot(111)
  plot(nbits_range,nbits_ng_rd,"linestyle",":", ...
       nbits_range,nbits_ng_sd,"linestyle","-.", ... 
       nbits_range,nbits_ng_Lim,"linestyle","--",...
       nbits_range,nbits_ng_Ito,"linestyle","-")
  strt=sprintf("Bandpass one-multiplier lattice noise gain,ndigits=%d",ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Noise gain");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  print(strcat(strf,"_ng"),"-dpdflatex");
  close
  
endfor

% Done
diary off
movefile schurOneMlattice_bandpass_allocsd_test.diary.tmp ...
       schurOneMlattice_bandpass_allocsd_test.diary;
