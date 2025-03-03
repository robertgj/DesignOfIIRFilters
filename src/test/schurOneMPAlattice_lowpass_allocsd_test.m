% schurOneMPAlattice_lowpass_allocsd_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test Lims and Itos signed-digit allocation algorithms with the coefficients
% of a parallel one-multiplier all-pass lattice low-pass filter.

test_common;

delete("schurOneMPAlattice_lowpass_allocsd_test.diary");
delete("schurOneMPAlattice_lowpass_allocsd_test.diary.tmp");
diary schurOneMPAlattice_lowpass_allocsd_test.diary.tmp

% Coefficients found by schurOneMPAlattice_socp_slb_lowpass_test.m
A1k = [   0.7708553001,  -0.0881484548,  -0.2675900297,  -0.0638632672, ... 
         -0.0593328770,   0.2446250997,  -0.1442830937,  -0.0044620112, ... 
          0.1646995029,  -0.1595259210,   0.0536804839 ];
A1epsilon = [   1,   1,   1,   1, ... 
                1,  -1,   1,   1, ... 
                1,   1,  -1 ];
A1p = [   1.0926101831,   0.3930326361,   0.4293491623,   0.5648366952, ... 
          0.6021381819,   0.6389905122,   0.8202238857,   0.9484929273, ... 
          0.9527345977,   0.8068380320,   0.9476859244 ];
A2k = [   0.3876010782,  -0.2733974816,   0.1868202238,   0.1637829241, ... 
         -0.0461373806,   0.0419429260,  -0.2011619974,   0.1801954423, ... 
          0.0057039675,  -0.1785575739,   0.1504907205,  -0.0546896233 ];
A2epsilon = [   1,   1,   1,  -1, ... 
                1,  -1,  -1,  -1, ... 
               -1,  -1,  -1,   1 ];
A2p = [   1.0557307484,   0.7013552707,   0.9284779813,   0.7685505266, ... 
          0.9066692753,   0.9495117520,   0.9902084283,   0.8075235291, ... 
          0.9688956091,   0.9744380102,   0.8135183988,   0.9467272462 ];

% Lowpass filter specification
n=400
difference=false
m1=11 % Allpass model filter 1 denominator order
m2=12 % Allpass model filter 2 denominator order
fap=0.125 % Pass band amplitude response edge
dBap=0.1 % Pass band amplitude response ripple
Wap=1 % Pass band amplitude response weight
Wat=0 % Transition band amplitude response weight
fas=0.25 % Stop band amplitude response edge
dBas=60 % Stop band amplitude response ripple
Was=500 % Stop band amplitude response weight
ftp=0.175 % Pass band group delay response edge
td=(m1+m2)/2 % Pass band nominal group delay
tdr=td/500 % Pass band group delay response ripple
Wtp=1 % Pass band group delay response weight

% Coefficient constraints
rho=31/32;

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Asqd=[ones(nap,1); zeros(n-nap,1)];
Asqdu=[ones(nas-1,1); (10^(-dBas/10))*ones(n-nas+1,1)];
Asqdl=[(10^(-dBap/10))*ones(nap,1); zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Group delay constraints
ntp=ceil(n*ftp/0.5)+1;
wt=(0:(ntp-1))'*pi/n;
Td=td*ones(ntp,1);
Tdu=(td+(tdr/2))*ones(ntp,1);
Tdl=(td-(tdr/2))*ones(ntp,1);
Wt=Wtp*ones(ntp,1);

% Find response of exact filter
nplot=250;
Asq_ex=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);
T_ex=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference);

% Compare nbits
NA1=length(A1k);
NA2=length(A2k);
k=[A1k(:);A2k(:)];
nbits_range=[10:16];
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
for ndigits=2:3
  strf=sprintf("schurOneMPAlattice_lowpass_allocsd_%d_ndigits_test",ndigits);
  for l=1:length(nbits_range),
    nbits=nbits_range(l);
    nscale=2^(nbits-1);
    nbits_strf=sprintf ...
      ("schurOneMPAlattice_lowpass_allocsd_%d_ndigits_%d_nbits_test",
       ndigits,nbits);
    
    % Rounded truncation
    k_rd=round(k.*nscale)./nscale;
    A1k_rd=k_rd(1:NA1);
    A2k_rd=k_rd((NA1+1):end);
    % Find the actual number of signed digits used
    nbits_k_rd_digits(l)=SDadders(k_rd,nbits);

    % Calculate rounded response
    nbits_cost_rd(l)= ...
    schurOneMPAlatticeEsq(A1k_rd,A1epsilon,ones(size(A1p)), ...
                          A2k_rd,A2epsilon,ones(size(A2p)),difference, ...
                          wa,Asqd,Wa,wt,Td,Wt);
    Asq_rd=schurOneMPAlatticeAsq(wa,A1k_rd,A1epsilon,ones(size(A1p)), ...
                                 A2k_rd,A2epsilon,ones(size(A2p)),difference);
    T_rd=schurOneMPAlatticeT(wt,A1k_rd,A1epsilon,ones(size(A1p)), ...
                             A2k_rd,A2epsilon,ones(size(A2p)),difference);
    
    % Signed-digit truncation without allocation
    k_sd=flt2SD(k,nbits,ndigits);
    A1k_sd=k_sd(1:NA1);
    A2k_sd=k_sd((NA1+1):end);
    % Find the actual number of signed digits used
    nbits_k_sd_digits(l)=SDadders(k_sd,nbits);

    % Calculate signed-digit response
    nbits_cost_sd(l)= ...
      schurOneMPAlatticeEsq(A1k_sd,A1epsilon,ones(size(A1p)), ...
                            A2k_sd,A2epsilon,ones(size(A2p)),difference, ...
                            wa,Asqd,Wa,wt,Td,Wt);
    Asq_sd=schurOneMPAlatticeAsq(wa,A1k_sd,A1epsilon,ones(size(A1p)), ...
                                 A2k_sd,A2epsilon,ones(size(A2p)),difference);
    T_sd=schurOneMPAlatticeT(wt,A1k_sd,A1epsilon,ones(size(A1p)), ...
                             A2k_sd,A2epsilon,ones(size(A2p)),difference);

    % Use Lim's heuristic to allocate an average of ndigits signed-digits
    ndigits_Lim=schurOneMPAlattice_allocsd_Lim ...
                  (nbits,ndigits,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                   difference,...
                   wa,Asqd,ones(size(wa)),wt,Td,ones(size(wt)));
    print_polynomial(int16(ndigits_Lim(1:length(A1k))), ...
                     "A1k_allocsd_digits", ...
                     strcat(nbits_strf,"_A1k_Lim_digits.m"),"%2d");
    print_polynomial(int16(ndigits_Lim((NA1+1):end)), ...
                     "A2k_allocsd_digits", ...
                     strcat(nbits_strf,"_A2k_Lim_digits.m"),"%2d");
    
    % Signed-digits allocated by Lim
    k_Lim=flt2SD(k,nbits,ndigits_Lim);
    A1k_Lim=k_Lim(1:NA1);
    A2k_Lim=k_Lim((NA1+1):end);
    
    % Calculate Lim signed-digit response
    nbits_cost_Lim(l) = ...
      schurOneMPAlatticeEsq(A1k_Lim,A1epsilon,ones(size(A1p)), ...
                            A2k_Lim,A2epsilon,ones(size(A2p)),difference, ...
                            wa,Asqd,Wa,wt,Td,Wt);
    Asq_Lim=schurOneMPAlatticeAsq(wa,A1k_Lim,A1epsilon,ones(size(A1p)), ...
                                  A2k_Lim,A2epsilon,ones(size(A2p)),difference);
    T_Lim=schurOneMPAlatticeT(wt,A1k_Lim,A1epsilon,ones(size(A1p)), ...
                              A2k_Lim,A2epsilon,ones(size(A2p)),difference);

    % Find the actual number of signed digits used
    [nbits_k_digits_Lim(l),k_Lim_adders]=SDadders(k_Lim,nbits);
    fid=fopen(strcat(nbits_strf,"_Lim.adders.tab"),"wt");
    fprintf(fid,"$%d$",k_Lim_adders);
    fclose(fid);

    % Use Ito's heuristic to allocate an average of ndigits signed-digits
    ndigits_Ito=schurOneMPAlattice_allocsd_Ito ...
                  (nbits,ndigits,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                   difference, ...
                   wa,Asqd,Wa,wt,Td,Wt);
    print_polynomial(int16(ndigits_Ito(1:NA1)), ...
                     "A1k_allocsd_digits", ...
                     strcat(nbits_strf,"_A1k_Ito_digits.m"),"%2d");
    print_polynomial(int16(ndigits_Ito((NA1+1):end)), ...
                     "A2k_allocsd_digits", ...
                     strcat(nbits_strf,"_A2k_Ito_digits.m"),"%2d");
    % Signed-digits allocated by Ito
    k_Ito=flt2SD(k,nbits,ndigits_Ito);
    A1k_Ito=k_Ito(1:NA1);
    A2k_Ito=k_Ito((NA1+1):end);
    
    % Calculate Ito signed-digit response
    nbits_cost_Ito(l) = ...
      schurOneMPAlatticeEsq(A1k_Ito,A1epsilon,ones(size(A1p)), ...
                            A2k_Ito,A2epsilon,ones(size(A2p)), ...
                            difference, ...
                            wa,Asqd,Wa,wt,Td,Wt);
    Asq_Ito=schurOneMPAlatticeAsq(wa,A1k_Ito,A1epsilon,ones(size(A1p)), ...
                                  A2k_Ito,A2epsilon,ones(size(A2p)),difference);
    T_Ito=schurOneMPAlatticeT(wt,A1k_Ito,A1epsilon,ones(size(A1p)), ...
                              A2k_Ito,A2epsilon,ones(size(A2p)),difference);

    % Find the actual number of signed digits used
    [nbits_k_digits_Ito(l),k_Ito_adders]=SDadders(k_Ito,nbits);
    fid=fopen(strcat(nbits_strf,"_Ito.adders.tab"),"wt");
    fprintf(fid,"$%d$",k_Ito_adders);
    fclose(fid);
    
    % Plot the results
    subplot(111)
    plot(wa*0.5/pi,10*log10(Asq_ex),"linestyle","-", ...
         wa*0.5/pi,10*log10(Asq_rd),"linestyle",":", ...
         wa*0.5/pi,10*log10(Asq_sd),"linestyle","-.", ... 
         wa*0.5/pi,10*log10(Asq_Lim),"linestyle","--",...
         wa*0.5/pi,10*log10(Asq_Ito),"linestyle","-")
    xlabel("Frequency");
    ylabel("Amplitude(dB)");
    axis([0 0.5 -dBas-10 10]);
    grid("on");
    strt=sprintf("Parallel one-multiplier lattice low-pass,nbits=%d,ndigits=%d",
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
    axis([0 max(fap,ftp) -2*dBap dBap]);
    grid("on");
    subplot(212)
    plot(wt*0.5/pi,T_ex,"linestyle","-", ...
         wt*0.5/pi,T_rd,"linestyle",":", ...
         wt*0.5/pi,T_sd,"linestyle","-.", ... 
         wt*0.5/pi,T_Lim,"linestyle","--", ...
         wt*0.5/pi,T_Ito,"linestyle","-");
    xlabel("Frequency");
    ylabel("Delay(samples)");
    axis([0 max(fap,ftp) td-(2*tdr) td+(2*tdr)]);
    grid("on");
    print(strcat(nbits_strf,"_passband_response"),"-dpdflatex");
    close

    % Print the maximum side-lobe for Lim
    printf("\n");
    printf("Lim,ndigits=%d,nbits=%d,maximum stop-band (%4.2f to 0.50) = %gdB\n",
           ndigits,nbits,fas,max(10*log10(Asq_Lim(nas:end))));
    
    % Print the maximum side-lobe for Ito
    printf("\n");
    printf("Ito,ndigits=%d,nbits=%d,maximum stop-band (%4.2f to 0.50) = %gdB\n",
           ndigits,nbits,fas,max(10*log10(Asq_Ito(nas:end))));

    % Save the maximum sidelobes in upper stop band (fas to 0.50)
    nbits_sidelobe_ex(l)=max(10*log10(Asq_ex(nas:end)));
    nbits_sidelobe_rd(l)=max(10*log10(Asq_rd(nas:end)));
    nbits_sidelobe_sd(l)=max(10*log10(Asq_sd(nas:end)));
    nbits_sidelobe_Lim(l)=max(10*log10(Asq_Lim(nas:end)));
    nbits_sidelobe_Ito(l)=max(10*log10(Asq_Ito(nas:end)));
    
    % Print the results
    print_polynomial(A1k_rd,sprintf("A1k_rd_%d_bits",nbits),...
                     strcat(nbits_strf,"_A1k_rd_coef.m"),nscale);
    print_polynomial(A2k_rd,sprintf("A2k_rd_%d_bits",nbits),...
                     strcat(nbits_strf,"_A2k_rd_coef.m"),nscale);
    print_polynomial(A1k_sd,sprintf("A1k_sd_%d_bits",nbits),...
                     strcat(nbits_strf,"_A1k_sd_coef.m"),nscale);
    print_polynomial(A2k_sd,sprintf("A2k_sd_%d_bits",nbits),...
                     strcat(nbits_strf,"_A2k_sd_coef.m"),nscale);
    print_polynomial(A1k_Lim,sprintf("A1k_Lim_%d_bits",nbits),...
                     strcat(nbits_strf,"_A1k_Lim_coef.m"),nscale);
    print_polynomial(A2k_Lim,sprintf("A2k_Lim_%d_bits",nbits),...
                     strcat(nbits_strf,"_A2k_Lim_coef.m"),nscale);
    print_polynomial(A1k_Ito,sprintf("A1k_Ito_%d_bits",nbits),...
                     strcat(nbits_strf,"_A1k_Ito_coef.m"),nscale);
    print_polynomial(A2k_Ito,sprintf("A2k_Ito_%d_bits",nbits),...
                     strcat(nbits_strf,"_A2k_Ito_coef.m"),nscale);
  endfor

  % Plot comparison of cost
  subplot(111)
  semilogy(nbits_range,nbits_cost_rd,"linestyle",":", ...
           nbits_range,nbits_cost_sd,"linestyle","-.", ... 
           nbits_range,nbits_cost_Lim,"linestyle","--",...
           nbits_range,nbits_cost_Ito,"linestyle","-")
  strt=sprintf("Parallel one-multiplier lattice low-pass cost, ndigits=%d", ...
               ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Cost");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  print(strcat(strf,"_cost"),"-dpdflatex");
  close

  % Plot comparison of maximum response in [fas,0.5)
  subplot(111)
  plot(nbits_range,nbits_sidelobe_rd,"linestyle",":", ...
       nbits_range,nbits_sidelobe_sd,"linestyle","-.", ... 
       nbits_range,nbits_sidelobe_Lim,"linestyle","--", ...
       nbits_range,nbits_sidelobe_Ito,"linestyle","-")
  strt=sprintf("Parallel one-multiplier lattice low-pass maximum response \
in [%4.2f,0.5) (dB), ndigits=%d",fas,ndigits);
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
  plot(nbits_range,nbits_k_rd_digits,"linestyle",":", ...
       nbits_range,nbits_k_sd_digits,"linestyle","-.", ... 
       nbits_range,nbits_k_digits_Lim,"linestyle","--",...
       nbits_range,nbits_k_digits_Ito,"linestyle","-")
  strt=sprintf("Parallel one-multiplier lattice low-pass total signed-digits \
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
movefile schurOneMPAlattice_lowpass_allocsd_test.diary.tmp ...
         schurOneMPAlattice_lowpass_allocsd_test.diary;
