% directFIRhilbert_allocsd_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% Test Lims and Itos signed-digit allocation algorithms with
% the distinct non-zero coefficients of a Hilbert FIR filter

test_common;

unlink("directFIRhilbert_allocsd_test.diary");
unlink("directFIRhilbert_allocsd_test.diary.tmp");
diary directFIRhilbert_allocsd_test.diary.tmp

maxiter=400
verbose=false
tol=1e-4

% Hilbert filter frequency specification
M=40;fapl=0.01;fapu=0.5-fapl;Wap=1;Was=0;
npoints=1000;
wa=(0:((npoints)-1))'*pi/(npoints);
napl=floor(npoints*fapl/0.5)+1;
napu=ceil(npoints*fapu/0.5)+1;
Ad=ones(npoints,1);
Wa=[Was*ones(napl-1,1); ...
    Wap*ones(napu-napl+1,1); ...
    Was*ones(npoints-napu,1)];

% For directFIRhilbertEsqPW
waf=wa([napl napu]);
Adf=1;
Waf=Wap;

% Make a Hilbert filter
n4M1=((-2*M)+1):2:((2*M)-1)';
h0=zeros((4*M)+1,1);
h0(n4M1+(2*M)+1)=2*(sin(pi*n4M1/2).^2)./(pi*n4M1);
h0=h0.*hamming((4*M)+1);
hM=h0(((2*M)+2):2:(end-1));

% Find response of exact filter
A_ex=directFIRhilbertA(wa,hM);

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
  strf=sprintf("directFIRhilbert_allocsd_%d_ndigits_test",ndigits);
  for l=1:length(nbits_range),
    nbits=nbits_range(l);
    nscale=2^(nbits-1);
    namestr=sprintf ...
              ("directFIRhilbert_allocsd_%d_ndigits_%d_nbits_test",
               ndigits,nbits);
    
    % Rounded truncation
    hM_rd=round(hM.*nscale)./nscale;
    nbits_cost_rd(l)=directFIRhilbertEsqPW(hM_rd,waf,Adf,Waf);
    A_rd=directFIRhilbertA(wa,hM_rd);
    % Find the actual number of signed digits used
    nbits_hM_rd_digits(l)=SDadders(hM_rd,nbits);
    
    % Signed-digit truncation without allocation
    hM_sd=flt2SD(hM,nbits,ndigits);
    nbits_cost_sd(l)=directFIRhilbertEsqPW(hM_sd,waf,Adf,Waf);
    A_sd=directFIRhilbertA(wa,hM_sd);
    % Find the actual number of signed digits used
    nbits_hM_sd_digits(l)=SDadders(hM_sd,nbits);

    % Use Lim's heuristic to allocate an average of ndigits signed-digits
    ndigits_Lim=directFIRhilbert_allocsd_Lim ...
                  (nbits,ndigits,hM,waf,Adf,ones(size(Waf)));
    print_polynomial(int16(ndigits_Lim(1:length(hM))), ...
                     "hM_allocsd_digits", ...
                     strcat(namestr,"_hM_Lim_digits.m"),"%2d");
    % Signed-digits allocated by Lim
    hM_Lim=flt2SD(hM,nbits,ndigits_Lim(1:length(hM)));
    nbits_cost_Lim(l)=directFIRhilbertEsqPW(hM_Lim,waf,Adf,Waf);
    A_Lim=directFIRhilbertA(wa,hM_Lim);
    % Find the actual number of signed digits used
    [nbits_hM_digits_Lim(l),hM_Lim_adders]=SDadders(hM_Lim,nbits);
    fid=fopen(strcat(namestr,"_Lim.adders.tab"),"wt");
    fprintf(fid,"$%d$",hM_Lim_adders);
    fclose(fid);

    % Use Ito's heuristic to allocate an average of ndigits signed-digits
    ndigits_Ito=directFIRhilbert_allocsd_Ito(nbits,ndigits,hM,waf,Adf,Waf);
    print_polynomial(int16(ndigits_Ito(1:length(hM))), ...
                     "hM_allocsd_digits", ...
                     strcat(namestr,"_hM_Ito_digits.m"),"%2d");
    % Signed-digits allocated by Ito
    hM_Ito=flt2SD(hM,nbits,ndigits_Ito(1:length(hM)));
    nbits_cost_Ito(l)=directFIRhilbertEsqPW(hM_Ito,waf,Adf,Waf);
    A_Ito=directFIRhilbertA(wa,hM_Ito);
    % Find the actual number of signed digits used
    [nbits_hM_digits_Ito(l),hM_Ito_adders]=SDadders(hM_Ito,nbits);
    fid=fopen(strcat(namestr,"_Ito.adders.tab"),"wt");
    fprintf(fid,"$%d$",hM_Ito_adders);
    fclose(fid);

    % Plot the results 
    subplot(211)
    plot(wa*0.5/pi,20*log10(abs(A_ex)),"linestyle","-", ...
         wa*0.5/pi,20*log10(abs(A_rd)),"linestyle",":", ...
         wa*0.5/pi,20*log10(abs(A_sd)),"linestyle","-.", ... 
         wa*0.5/pi,20*log10(abs(A_Lim)),"linestyle","--", ...
         wa*0.5/pi,20*log10(abs(A_Ito)),"linestyle","-")
    xlabel("Frequency");
    ylabel("Amplitude(dB)");
    legend("exact","round","signed-digit","Lim","Ito");
    legend("location","northeast");
    legend("boxoff");
    legend("left");
    axis([0 0.5 -2 2]);
    grid("on");
    strt=sprintf("Hilbert FIR,nbits=%d,ndigits=%d",
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
    print(strcat(namestr,"_response"),"-dpdflatex");
    close

    % Print the maximum side-lobe for Lim
    printf("\n");
    printf("Lim,ndigits=%d,nbits=%d,maximum pass-band (%4.2f to 0.25) = %gdB\n",
           ndigits,nbits,fapl,max(20*log10(abs(A_Lim(napl:(npoints/2))))));
    printf("Lim,ndigits=%d,nbits=%d,maximum pass-band (%4.2f to 0.25) = %gdB\n",
           ndigits,nbits,fapl,max(20*log10(abs(A_Lim(napl:(npoints/2))))));
    
    % Print the maximum side-lobe for Ito
    printf("\n");
    printf("Ito,ndigits=%d,nbits=%d,maximum pass-band (%4.2f to 0.25) = %gdB\n",
           ndigits,nbits,fapl,max(20*log10(abs(A_Ito(napl:(npoints/2)))))); 
    printf("Ito,ndigits=%d,nbits=%d,maximum pass-band (%4.2f to 0.25) = %gdB\n",
           ndigits,nbits,fapl,max(20*log10(abs(A_Ito(napl:(npoints/2))))));

    % Save the maximum sidelobes in lower pass-band (fapl to 0.25)
    nbits_sidelobe_ex(l)=max(20*log10(abs(A_ex(napl:(npoints/2)))));
    nbits_sidelobe_rd(l)=max(20*log10(abs(A_rd(napl:(npoints/2)))));
    nbits_sidelobe_sd(l)=max(20*log10(abs(A_sd(napl:(npoints/2)))));
    nbits_sidelobe_Lim(l)=max(20*log10(abs(A_Lim(napl:(npoints/2)))));
    nbits_sidelobe_Ito(l)=max(20*log10(abs(A_Ito(napl:(npoints/2)))));
    
    % Print the results
    format short
    print_polynomial(hM_rd,sprintf("hM_rd_%d_bits",nbits), ...
                     strcat(namestr,"_hM_rd_coef.m"),nscale);
    print_polynomial(hM_sd,sprintf("hM_sd_%d_bits",nbits), ...
                     strcat(namestr,"_hM_sd_coef.m"),nscale);
    print_polynomial(hM_Lim,sprintf("hM_Lim_%d_bits",nbits),...
                     strcat(namestr,"_hM_Lim_coef.m"),nscale);
    print_polynomial(hM_Ito,sprintf("hM_Ito_%d_bits",nbits),...
                     strcat(namestr,"_hM_Ito_coef.m"),nscale);
    format long e
  endfor

  % Plot comparison of cost
  subplot(111)
  semilogy(nbits_range,nbits_cost_rd,"linestyle",":", ...
           nbits_range,nbits_cost_sd,"linestyle","-.", ... 
           nbits_range,nbits_cost_Lim,"linestyle","--",...
           nbits_range,nbits_cost_Ito,"linestyle","-")
  strt=sprintf("Hilbert FIR cost, ndigits=%d", ndigits);
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
  strt=sprintf("Hilbert FIR maximum response \
in [%4.2f,0.25) (dB), ndigits=%d",fapl,ndigits);
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
  strt=sprintf("Hilbert FIR total signed-digits used by coefficients,ndigits=%d",
               ndigits);
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
movefile directFIRhilbert_allocsd_test.diary.tmp ...
         directFIRhilbert_allocsd_test.diary;
