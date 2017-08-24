% schurOneMPAlattice_lowpass_allocsd_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% Test Lims and Itos signed-digit allocation algorithms with the coefficents
% of a parallel one-multiplier all-pass lattice low-pass filter.

test_common;

unlink("schurOneMPAlattice_lowpass_allocsd_test.diary");
unlink("schurOneMPAlattice_lowpass_allocsd_test.diary.tmp");
diary schurOneMPAlattice_lowpass_allocsd_test.diary.tmp

% Coefficients found by schurOneMPAlattice_socp_slb_lowpass_test.m
A1k = [   0.7353878138,  -0.3220515512,  -0.0527627119,   0.1121018051, ... 
         -0.3681035439,   0.3545407413,  -0.0748075136,  -0.0613118944, ... 
          0.1090877104,  -0.0810629033,   0.0325442677 ];
A1epsilon = [  1,  1,  1, -1, ... 
               1,  1,  1,  1, ... 
              -1,  1, -1 ];
A1p = [   1.0679945548,   0.4170380557,   0.5823734217,   0.6139562159, ... 
          0.6871128760,   1.0110313237,   0.6979157392,   0.7522328425, ... 
          0.7998584719,   0.8924391640,   0.9679684700 ];
A2k = [   0.2507238860,  -0.2430299408,   0.4443531125,  -0.0520030934, ... 
         -0.2210411396,   0.3618878966,  -0.3099859803,   0.1000148669, ... 
          0.0557767501,  -0.1213462303,   0.0767042711,  -0.0314227247 ];
A2epsilon = [ -1,  1,  1,  1, ... 
               1,  1,  1, -1, ... 
              -1, -1, -1,  1 ];
A2p = [   0.6788636609,   0.8770863250,   1.1239416976,   0.6971183838, ... 
          0.7343643472,   0.9194316964,   0.6293573123,   0.8671648166, ... 
          0.9587011728,   1.0137525523,   0.8973688402,   0.9690558104 ];

% Lowpass filter specification
n=400
m1=11 % Allpass model filter 1 denominator order
m2=12 % Allpass model filter 2 denominator order
fap=0.125 % Pass band amplitude response edge
dBap=0.1 % Pass band amplitude response ripple
Wap=1 % Pass band amplitude response weight
Wat=0 % Transition band amplitude response weight
fas=0.25 % Stop band amplitude response edge
dBas=60 % Stop band amplitude response ripple
Was=1e2 % Stop band amplitude response weight
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
Asq_ex=schurOneMPAlatticeAsq(wa,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);
T_ex=schurOneMPAlatticeT(wt,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p);

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
  plotstr=sprintf("schurOneMPAlattice_lowpass_allocsd_%d_ndigits_test",ndigits);
  for l=1:length(nbits_range),
    nbits=nbits_range(l);
    nscale=2^(nbits-1);
    namestr=sprintf ...
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
                          A2k_rd,A2epsilon,ones(size(A2p)), ...
                          wa,Asqd,Wa,wt,Td,Wt);
    Asq_rd=schurOneMPAlatticeAsq(wa,A1k_rd,A1epsilon,ones(size(A1p)), ...
                                 A2k_rd,A2epsilon,ones(size(A2p)));
    T_rd=schurOneMPAlatticeT(wt,A1k_rd,A1epsilon,ones(size(A1p)), ...
                             A2k_rd,A2epsilon,ones(size(A2p)));
    
    % Signed-digit truncation without allocation
    k_sd=flt2SD(k,nbits,ndigits);
    A1k_sd=k_sd(1:NA1);
    A2k_sd=k_sd((NA1+1):end);
    % Find the actual number of signed digits used
    nbits_k_sd_digits(l)=SDadders(k_sd,nbits);

    % Calculate signed-digit response
    nbits_cost_sd(l)= ...
      schurOneMPAlatticeEsq(A1k_sd,A1epsilon,ones(size(A1p)), ...
                            A2k_sd,A2epsilon,ones(size(A2p)), ...
                            wa,Asqd,Wa,wt,Td,Wt);
    Asq_sd=schurOneMPAlatticeAsq(wa,A1k_sd,A1epsilon,ones(size(A1p)), ...
                                 A2k_sd,A2epsilon,ones(size(A2p)));
    T_sd=schurOneMPAlatticeT(wt,A1k_sd,A1epsilon,ones(size(A1p)), ...
                             A2k_sd,A2epsilon,ones(size(A2p)));

    % Use Lim's heuristic to allocate an average of ndigits signed-digits
    ndigits_Lim=schurOneMPAlattice_allocsd_Lim ...
                  (nbits,ndigits,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,...
                   wa,Asqd,ones(size(wa)),wt,Td,ones(size(wt)));
    print_polynomial(int16(ndigits_Lim(1:length(A1k))), ...
                     "A1k_allocsd_digits", ...
                     strcat(namestr,"_A1k_Lim_digits.m"),"%2d");
    print_polynomial(int16(ndigits_Lim((NA1+1):end)), ...
                     "A2k_allocsd_digits", ...
                     strcat(namestr,"_A2k_Lim_digits.m"),"%2d");
    
    % Signed-digits allocated by Lim
    k_Lim=flt2SD(k,nbits,ndigits_Lim);
    A1k_Lim=k_Lim(1:NA1);
    A2k_Lim=k_Lim((NA1+1):end);
    
    % Calculate Lim signed-digit response
    nbits_cost_Lim(l) = ...
      schurOneMPAlatticeEsq(A1k_Lim,A1epsilon,ones(size(A1p)), ...
                            A2k_Lim,A2epsilon,ones(size(A2p)), ...
                            wa,Asqd,Wa,wt,Td,Wt);
    Asq_Lim=schurOneMPAlatticeAsq(wa,A1k_Lim,A1epsilon,ones(size(A1p)), ...
                                  A2k_Lim,A2epsilon,ones(size(A2p)));
    T_Lim=schurOneMPAlatticeT(wt,A1k_Lim,A1epsilon,ones(size(A1p)), ...
                              A2k_Lim,A2epsilon,ones(size(A2p)));

    % Find the actual number of signed digits used
    [nbits_k_digits_Lim(l),k_Lim_adders]=SDadders(k_Lim,nbits);
    fid=fopen(strcat(namestr,"_Lim.adders.tab"),"wt");
    fprintf(fid,"$%d$",k_Lim_adders);
    fclose(fid);

    % Use Ito's heuristic to allocate an average of ndigits signed-digits
    ndigits_Ito=schurOneMPAlattice_allocsd_Ito ...
                  (nbits,ndigits,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                   wa,Asqd,Wa,wt,Td,Wt);
    print_polynomial(int16(ndigits_Ito(1:NA1)), ...
                     "A1k_allocsd_digits", ...
                     strcat(namestr,"_A1k_Ito_digits.m"),"%2d");
    print_polynomial(int16(ndigits_Ito((NA1+1):end)), ...
                     "A2k_allocsd_digits", ...
                     strcat(namestr,"_A2k_Ito_digits.m"),"%2d");
    % Signed-digits allocated by Ito
    k_Ito=flt2SD(k,nbits,ndigits_Ito);
    A1k_Ito=k_Ito(1:NA1);
    A2k_Ito=k_Ito((NA1+1):end);
    
    % Calculate Ito signed-digit response
    nbits_cost_Ito(l) = ...
      schurOneMPAlatticeEsq(A1k_Ito,A1epsilon,ones(size(A1p)), ...
                            A2k_Ito,A2epsilon,ones(size(A2p)), ...
                            wa,Asqd,Wa,wt,Td,Wt);
    Asq_Ito=schurOneMPAlatticeAsq(wa,A1k_Ito,A1epsilon,ones(size(A1p)), ...
                                  A2k_Ito,A2epsilon,ones(size(A2p)));
    T_Ito=schurOneMPAlatticeT(wt,A1k_Ito,A1epsilon,ones(size(A1p)), ...
                              A2k_Ito,A2epsilon,ones(size(A2p)));

    % Find the actual number of signed digits used
    [nbits_k_digits_Ito(l),k_Ito_adders]=SDadders(k_Ito,nbits);
    fid=fopen(strcat(namestr,"_Ito.adders.tab"),"wt");
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
    tstr=sprintf("Parallel one-multiplier lattice low-pass,nbits=%d,ndigits=%d",
                 nbits,ndigits);
    title(tstr);
    legend("exact","round","signed-digit","Lim","Ito");
    legend("location","northeast");
    legend("Boxoff");
    legend("left");
    print(strcat(namestr,"_response"),"-dsvg");
    close
    % Plot the passband detail
    subplot(211)
    plot(wa*0.5/pi,10*log10(Asq_ex),"linestyle","-", ...
         wa*0.5/pi,10*log10(Asq_rd),"linestyle",":", ...
         wa*0.5/pi,10*log10(Asq_sd),"linestyle","-.", ... 
         wa*0.5/pi,10*log10(Asq_Lim),"linestyle","--", ...
         wa*0.5/pi,10*log10(Asq_Ito),"linestyle","-")
    title(tstr);
    xlabel("Frequency");
    ylabel("Amplitude(dB)");
    legend("exact","round","signed-digit","Lim","Ito");
    legend("location","northeast");
    legend("Boxoff");
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
    ylabel("Group delay(samples)");
    axis([0 max(fap,ftp) td-(2*tdr) td+(2*tdr)]);
    grid("on");
    print(strcat(namestr,"_passband_response"),"-dsvg");
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
    format short
    fmt_str="%6d";
    print_polynomial(int16(A1k_rd*nscale), ...
                     sprintf("%d*A1k_rd_%d_bits",nscale,nbits),...
                     strcat(namestr,"_A1k_rd_coef.m"),fmt_str);
    print_polynomial(int16(A2k_rd*nscale), ...
                     sprintf("%d*A2k_rd_%d_bits",nscale,nbits),...
                     strcat(namestr,"_A2k_rd_coef.m"),fmt_str);
    print_polynomial(int16(A1k_sd*nscale), ...
                     sprintf("%d*A1k_sd_%d_bits",nscale,nbits),...
                     strcat(namestr,"_A1k_sd_coef.m"),fmt_str);
    print_polynomial(int16(A2k_sd*nscale), ...
                     sprintf("%d*A2k_sd_%d_bits",nscale,nbits),...
                     strcat(namestr,"_A2k_sd_coef.m"),fmt_str);
    print_polynomial(int16(A1k_Lim*nscale), ...
                     sprintf("%d*A1k_Lim_%d_bits",nscale,nbits),...
                     strcat(namestr,"_A1k_Lim_coef.m"),fmt_str);
    print_polynomial(int16(A2k_Lim*nscale), ...
                     sprintf("%d*A2k_Lim_%d_bits",nscale,nbits),...
                     strcat(namestr,"_A2k_Lim_coef.m"),fmt_str);
    print_polynomial(int16(A1k_Ito*nscale), ...
                     sprintf("%d*A1k_Ito_%d_bits",nscale,nbits),...
                     strcat(namestr,"_A1k_Ito_coef.m"),fmt_str);
    print_polynomial(int16(A2k_Ito*nscale), ...
                     sprintf("%d*A2k_Ito_%d_bits",nscale,nbits),...
                     strcat(namestr,"_A2k_Ito_coef.m"),fmt_str);
    format long e
  endfor

  % Plot comparison of cost
  subplot(111)
  semilogy(nbits_range,nbits_cost_rd,"linestyle",":", ...
           nbits_range,nbits_cost_sd,"linestyle","-.", ... 
           nbits_range,nbits_cost_Lim,"linestyle","--",...
           nbits_range,nbits_cost_Ito,"linestyle","-")
  tstr=sprintf("Parallel one-multiplier lattice low-pass cost, ndigits=%d", ...
               ndigits);
  title(tstr);
  xlabel("bits");
  ylabel("Cost");
  grid("off");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northeast");
  legend("Boxoff");
  legend("left");
  print(strcat(plotstr,"_cost"),"-dsvg");
  close

  % Plot comparison of maximum response in [fas,0.5)
  subplot(111)
  plot(nbits_range,nbits_sidelobe_rd,"linestyle",":", ...
       nbits_range,nbits_sidelobe_sd,"linestyle","-.", ... 
       nbits_range,nbits_sidelobe_Lim,"linestyle","--", ...
       nbits_range,nbits_sidelobe_Ito,"linestyle","-")
  tstr=sprintf("Parallel one-multiplier lattice low-pass maximum response \
in [%4.2f,0.5) (dB), ndigits=%d",fas,ndigits);
  title(tstr);
  xlabel("bits");
  ylabel("Maximum response(dB)");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northeast");
  legend("Boxoff");
  legend("left");
  print(strcat(plotstr,"_sidelobe"),"-dsvg");
  close

  % Plot comparison of total signed-digits used
  subplot(111)
  plot(nbits_range,nbits_k_rd_digits,"linestyle",":", ...
       nbits_range,nbits_k_sd_digits,"linestyle","-.", ... 
       nbits_range,nbits_k_digits_Lim,"linestyle","--",...
       nbits_range,nbits_k_digits_Ito,"linestyle","-")
  tstr=sprintf("Parallel one-multiplier lattice low-pass total signed-digits \
used by coefficients, ndigits=%d",ndigits);
  title(tstr);
  xlabel("bits");
  ylabel("Total signed-digits used by coefficients");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northwest");
  legend("Boxoff");
  legend("left");
  print(strcat(plotstr,"_digits"),"-dsvg");
  close
  
endfor

% Done
diary off
movefile schurOneMPAlattice_lowpass_allocsd_test.diary.tmp ...
         schurOneMPAlattice_lowpass_allocsd_test.diary;
