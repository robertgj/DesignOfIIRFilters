% schurOneMPAlattice_lowpass_allocsd_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test Lims and Itos signed-digit allocation algorithms with the coefficents
% of a parallel one-multiplier all-pass lattice low-pass filter.

test_common;

unlink("schurOneMPAlattice_lowpass_allocsd_test.diary");
unlink("schurOneMPAlattice_lowpass_allocsd_test.diary.tmp");
diary schurOneMPAlattice_lowpass_allocsd_test.diary.tmp

% Coefficients found by schurOneMPAlattice_socp_slb_lowpass_test.m
A1k = [  0.7443908914,  -0.3042576697,  -0.0626208799,   0.0884311645, ... 
        -0.3588846414,   0.3587038004,  -0.0783633145,  -0.0748085391, ... 
         0.1263624295,  -0.0900968799,   0.0284686833 ];
A1epsilon = [  1,   1,   1,  -1, ...
               1,   1,   1,   1, ...
              -1,   1,  -1 ];
A1p = [  1.0998181327,   0.4210048834,   0.5764274038,   0.6137283063, ... 
         0.6706283423,   0.9763490507,   0.6707675530,   0.7255623222, ... 
         0.7820318991,   0.8879691854,   0.9719252527 ];
A2k = [  0.2690347663,  -0.2543494931,   0.4298554003,  -0.0378193975, ... 
        -0.2014911283,   0.3478950340,  -0.3145103585,   0.1067123496, ... 
         0.0713276982,  -0.1388447513,   0.0846842850,  -0.0277935824 ];
A2epsilon = [ -1,   1,   1,   1, ... 
               1,   1,   1,  -1, ... 
              -1,  -1,  -1,   1 ];
A2p = [  0.6490202260,   0.8551585273,   1.1091448098,   0.7003815530, ... 
         0.7273899429,   0.8922523560,   0.6206095018,   0.8594091607, ... 
         0.9565808706,   1.0274285085,   0.8934290639,   0.9725821418 ];

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
    ylabel("Group delay(samples)");
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
  grid("off");
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
