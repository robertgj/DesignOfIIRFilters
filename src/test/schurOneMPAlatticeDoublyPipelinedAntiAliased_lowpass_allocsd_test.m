% schurOneMPAlatticeDoublyPipelinedAntiAliased_lowpass_allocsd_test.m
% Test Lims and Itos signed-digit allocation algorithms with
% coefficients of a low-pass one-multiplier doubly pipelined
% anti-aliased lattice filter.

% Copyright (C) 2026 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticeDoublyPipelinedAntiAliased_lowpass_allocsd_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Initialise with filter designed by
% schurOneMPAlatticeDoublyPipelinedAntiAliased_socp_slb_lowpass_test.m
difference=false;
A1k0 = [  -0.2846558284,   0.4410616104,  -0.4416023676,   0.3738918230, ... 
          -0.1943793036,   0.0395726747 ]';
A2k0 = [   0.2256852415,   0.7856014855,  -0.5685188941,   0.3963557750, ... 
          -0.3369127093,   0.1989457889,  -0.0453177441 ]';
Aaa1k0 = [   0.0000000000,   0.7643214759,   0.0000000000,   0.0642897077 ]';
Aaa2k0 = [   0.0000000000,   0.3347962560,   0.0000000000 ]';

RA1k=1:length(A1k0);
RA2k=length(A1k0)+(1:length(A2k0));
RAaa1k=length(A1k0)+length(A2k0)+(1:length(Aaa1k0));
RAaa2k=length(A1k0)+length(A2k0)+length(Aaa1k0)+(1:length(Aaa2k0));
k0=[A1k0(:);A2k0(:);Aaa1k0(:);Aaa2k0(:)];

% Parallel all-pass filter order
ma=6;mb=7;
% Low-pass filter specification 
fap=0.15;dBap=0.06;Wap=1;Wat=0.01;
fas=0.175;dBas=71;Was=200;Was_wise=0.1;
fpp=0.1;pp=0;ppr=0.001;Wpp=1;
ftp=0.1;tp=15;;tpr=0.2;Wtp=1;
fdp=0.1;dpr=0.3;Wdp=0.01;
% Anti-aliasing filter
maa=7;
faap=0.25;

% Frequency points
n=1000;
w=pi*(0:(n-1))'/n;
nap=ceil(fap*n/0.5)+1;
nas=floor(fas*n/0.5)+1;
ntp=ceil(ftp*n/0.5)+1;
npp=ceil(fpp*n/0.5)+1;
ndp=ceil(fdp*n/0.5)+1;

% Pass and transition band amplitudes of combined filters
wa=w;
Asqd=[ones(nap,1);zeros(n-nap,1)];
Asqdu=[ones(nas-1,1);(10^(-dBas/10))*ones(n-nas+1,1)];
Adsql=[(10^(-dBap/10))*ones(nap,1);zeros(n-nap,1)];
Wa=[Wap*ones(nap,1); Wat*ones(nas-nap-1,1); Was*ones(n-nas+1,1)];

% Group delay of combined filters
wt=w(1:ntp);
% Delay of z^-2
Tz2=2;
Td=(tp+Tz2)*ones(size(wt));
Tdu=Td+(tpr/2);
Tdl=Td-(tpr/2);
Wt=Wtp*ones(size(wt));

% Phase response of combined filters
wp=w(1:npp);
Pd=(pp*pi)-(wp*(tp+Tz2));
Pdu=Pd+(ppr*pi/2);
Pdl=Pd-(ppr*pi/2);
Wp=Wpp*ones(size(wp));

% dAsqdw response of combined filters
wd=w(1:ndp);
Dd=zeros(ndp,1);
Ddu=Dd+(dpr/2);
Ddl=Dd-(dpr/2);
Wd=Wdp*ones(size(wd));

% Find response of exact filter
Asq_ex=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
         (wa,k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k));
T_ex=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
         (wt,k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k));
P_ex=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
         (wp,k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k));
dAsqdw_ex=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
         (wd,k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k));

% Find response of exact anti-aliasing filter
Asq_aa_ex=schurOneMPAlatticeAsq ...
            (wa,k0(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
             k0(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
T_aa_ex=schurOneMPAlatticeT ...
            (wt,k0(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
             k0(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
P_aa_ex=schurOneMPAlatticeP ...
            (wp,k0(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
             k0(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
dAsqdw_aa_ex=schurOneMPAlatticedAsqdw ...
            (wd,k0(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
             k0(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);

% Print the minimum pass-band amplitude for exact
printf("\n");
printf("Exact,minimum pass-band amplitude (0 to %5.3f)=%7.3fdB\n", ...
       fap,min(10*log10(Asq_ex(1:nap))));
% Print the maximum stop-band amplitude for exact
printf("Exact,maximum stop-band amplitude(%5.3f to 0.50)=%7.3fdB\n", ...
       fas,max(10*log10(Asq_ex(nas:end))));
% Print the maximum pass-band phase error for exact
printf("Exact,maximum pass-band phase error(0 to %5.3f)=%8.6f(rad./pi)\n", ...
       fpp,max(abs((P_ex-Pd)/pi)));
% Print the maximum pass-band delay error for exact
printf("Exact,maximum pass-band delay error(0 to %5.3f)=%7.5f(samples)\n", ...
       ftp,max(abs(T_ex-Td)));

% Find noise gain of exact filter ignoring state scaling
[A_ex,B_ex,C_ex,D_ex]= schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd ...
                         (k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k));
[K_ex,W_ex]=KW(A_ex,B_ex,C_ex,D_ex);
ng_ex=sum(diag(K_ex).*diag(W_ex));
printf("Exact filter noise gain=%7.3f\n",ng_ex);

nbits_range=[10:16];
nbits_rd_cost=zeros(size(nbits_range));
nbits_sd_cost=zeros(size(nbits_range));
nbits_Ito_cost=zeros(size(nbits_range));
nbits_Lim_cost=zeros(size(nbits_range));
nbits_rd_passband=zeros(size(nbits_range));
nbits_sd_passband=zeros(size(nbits_range));
nbits_Ito_passband=zeros(size(nbits_range));
nbits_Lim_passband=zeros(size(nbits_range));
nbits_rd_stopband=zeros(size(nbits_range));
nbits_sd_stopband=zeros(size(nbits_range));
nbits_Ito_stopband=zeros(size(nbits_range));
nbits_Lim_stopband=zeros(size(nbits_range));
nbits_rd_phase_error=zeros(size(nbits_range));
nbits_sd_phase_error=zeros(size(nbits_range));
nbits_Ito_phase_error=zeros(size(nbits_range));
nbits_Lim_phase_error=zeros(size(nbits_range));
nbits_rd_delay_error=zeros(size(nbits_range));
nbits_sd_delay_error=zeros(size(nbits_range));
nbits_Ito_delay_error=zeros(size(nbits_range));
nbits_Lim_delay_error=zeros(size(nbits_range));
nbits_k_rd_adders=zeros(size(nbits_range));
nbits_k_sd_adders=zeros(size(nbits_range));
nbits_k_Ito_adders=zeros(size(nbits_range));
nbits_k_Lim_adders=zeros(size(nbits_range));
nbits_k_rd_digits=zeros(size(nbits_range));
nbits_k_sd_digits=zeros(size(nbits_range));
nbits_k_Ito_digits=zeros(size(nbits_range));
nbits_k_Lim_digits=zeros(size(nbits_range));
nbits_ng_rd=zeros(size(nbits_range));
nbits_ng_sd=zeros(size(nbits_range));
nbits_ng_Ito=zeros(size(nbits_range));
nbits_ng_Lim=zeros(size(nbits_range));

for l=1:length(nbits_range),
  
  nbits=nbits_range(l);
  nscale=2^(nbits-1);
  strf_nbits=sprintf("%s_%d_nbits",strf,nbits); 

  % Rounded truncation
  k_rd=round(k0.*nscale)./nscale;
  nbits_rd_cost(l) =  ...
    schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
      (k_rd(RA1k),k_rd(RA2k),difference,k_rd(RAaa1k),k_rd(RAaa2k), ...
       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

  % Find response of rounded low-pass filter
  Asq_rd=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
         (wa,k_rd(RA1k),k_rd(RA2k),difference,k_rd(RAaa1k),k_rd(RAaa2k));
  T_rd=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
         (wt,k_rd(RA1k),k_rd(RA2k),difference,k_rd(RAaa1k),k_rd(RAaa2k));
  P_rd=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
         (wp,k_rd(RA1k),k_rd(RA2k),difference,k_rd(RAaa1k),k_rd(RAaa2k));
  dAsqdw_rd=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
         (wd,k_rd(RA1k),k_rd(RA2k),difference,k_rd(RAaa1k),k_rd(RAaa2k));
  
  % Find response of rounded anti-aliasing filter
  Asq_aa_rd=schurOneMPAlatticeAsq ...
              (wa,k_rd(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
               k_rd(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
  T_aa_rd=schurOneMPAlatticeT ...
            (wt,k_rd(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
             k_rd(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
  P_aa_rd=schurOneMPAlatticeP ...
            (wp,k_rd(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
             k_rd(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
  dAsqdw_aa_rd=schurOneMPAlatticedAsqdw ...
              (wd,k_rd(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
               k_rd(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);

  % Find the actual number of signed digits used
  [nbits_k_rd_digits(l),nbits_k_rd_adders(l)]=SDadders(k_rd,nbits);
  
  % Calculate the noise gain
  [A_rd,B_rd,C_rd,D_rd]= ...
    schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd ...
      (k_rd(RA1k),k_rd(RA2k),difference,k_rd(RAaa1k),k_rd(RAaa2k));
  [K_rd,W_rd]=KW(A_rd,B_rd,C_rd,D_rd);
  nbits_ng_rd(l)=sum(diag(K_rd).*diag(W_rd));
  printf("Round,nbits=%d,ng=%7.3f\n",nbits,nbits_ng_rd(l));

  % Save the minimum pass band amplitude(0 to fap)
  nbits_rd_passband(l)=min(10*log10(Asq_rd(1:nap)));
  
  % Save the maximum stop band amplitude(0 to fap)
  nbits_rd_stopband(l)=max(10*log10(Asq_rd(nas:end)));
  
  % Save the maximum phase error (0 to fpp)
  nbits_rd_phase_error(l)= max(abs((P_rd-Pd)/pi));
  
  % Save the maximum delay error (0 to ftp)
  nbits_rd_delay_error(l)= max(abs(T_rd-Td));

  % Print the minimum pass-band amplitude for round
  printf("\n");
  printf(["Round,nbits=%d,minimum pass-band amplitude", ...
          "(0 to %5.3f) = %7.3fdB\n"], ...
         nbits,fap,nbits_rd_passband(l));
  % Print the maximum stop-band amplitude for round
  printf(["Round,nbits=%d,maximum stop-band amplitude", ...
          "(%5.3f to 0.50) = %7.3fdB\n"], ...
         nbits,fas,nbits_rd_stopband(l));
  % Print the maximum pass-band phase error for round
  printf(["Round,nbits=%d,maximum pass-band phase error", ...
          "(0 to %5.3f) = %8.6f(rad./pi)\n"], ...
         nbits,fpp,nbits_rd_phase_error(l));
  % Print the maximum pass-band delay error for exact
  printf(["Round,nbits=%d,maximum pass-band delay error", ...
          "(0 to %5.3f) = %7.5f(samples)\n"], ...
         nbits,ftp,nbits_rd_delay_error(l));

  % Save coefficients
  print_polynomial(k_rd(RA1k),sprintf("A1k_rd_%d_bits",nbits),...
                   strcat(strf_nbits,"_A1k_rd_coef.m"),nscale);
  print_polynomial(k_rd(RA2k),sprintf("A2k_rd_%d_bits",nbits),...
                   strcat(strf_nbits,"_A2k_rd_coef.m"),nscale);
  print_polynomial(k_rd(RAaa1k),sprintf("Aaa1k_rd_%d_bits",nbits),...
                   strcat(strf_nbits,"_Aaa1k_rd_coef.m"),nscale);
  print_polynomial(k_rd(RAaa2k),sprintf("Aaa2k_rd_%d_bits",nbits),...
                   strcat(strf_nbits,"_Aaa2k_rd_coef.m"),nscale);
endfor

for ndigits=3:5
  for l=1:length(nbits_range),

    printf("\n");
    
    nbits=nbits_range(l);
    nscale=2^(nbits-1);
    strf_ndigits=sprintf("%s_%d_ndigits",strf,ndigits); 
    strf_nbits=sprintf("%s_%d_nbits",strf_ndigits,nbits);
    
    % Signed-digit truncation without allocation
    k_sd=flt2SD(k0,nbits,ndigits);
    nbits_sd_cost(l)= ...
      schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
        (k_sd(RA1k),k_sd(RA2k),difference,k_sd(RAaa1k),k_sd(RAaa2k), ...
         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

    % Find response of signed-digit filter
    Asq_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
             (wa,k_sd(RA1k),k_sd(RA2k),difference,k_sd(RAaa1k),k_sd(RAaa2k));
    T_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
           (wt,k_sd(RA1k),k_sd(RA2k),difference,k_sd(RAaa1k),k_sd(RAaa2k));
    P_sd=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
           (wp,k_sd(RA1k),k_sd(RA2k),difference,k_sd(RAaa1k),k_sd(RAaa2k));
    dAsqdw_sd=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
                (wd,k_sd(RA1k),k_sd(RA2k),difference,k_sd(RAaa1k),k_sd(RAaa2k));

    % Find response of signed-digit anti-aliasing filter
    Asq_aa_sd=schurOneMPAlatticeAsq ...
                (wa,k_sd(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
                 k_sd(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
    T_aa_sd=schurOneMPAlatticeT ...
              (wt,k_sd(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
               k_sd(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
    P_aa_sd=schurOneMPAlatticeP ...
              (wp,k_sd(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
               k_sd(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
    dAsqdw_aa_sd=schurOneMPAlatticedAsqdw ...
                   (wd,k_sd(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
                    k_sd(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);

    % Find the actual number of signed digits used
    [nbits_k_sd_digits(l),nbits_k_sd_adders(l)]=SDadders(k_sd,nbits);

    % Calculate the noise gain
    [A_sd,B_sd,C_sd,D_sd]= ...
      schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd ...
        (k_sd(RA1k),k_sd(RA2k),difference,k_sd(RAaa1k),k_sd(RAaa2k));
    [K_sd,W_sd]=KW(A_sd,B_sd,C_sd,D_sd);
    nbits_ng_sd(l)=sum(diag(K_sd).*diag(W_sd));
    printf("S-D,ndigits=%d,nbits=%d,ng=%7.3f\n",ndigits,nbits,nbits_ng_sd(l));

    % Use Lim's heuristic to allocate an average of ndigits signed-digits
    if 0
      ndigits_Lim=schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Lim ...
                    (nbits,ndigits, ...
                     k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k), ...
                     wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    else
      ndigits_Lim=schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Lim ...
                    (nbits,ndigits, ...
                     k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k), ...
                     wa,Asqd,ones(size(Wa)), ...
                     wt,Td,ones(size(Wt)), ...
                     wp,Pd,ones(size(Wp)), ...
                     wd,Dd,ones(size(Wd))); 
    endif
    
    print_polynomial(int16(ndigits_Lim(RA1k)), ...
                     "A1k_allocsd_digits", ...
                     strcat(strf_nbits,"_A1k_Lim_digits.m"),"%2d");
    print_polynomial(int16(ndigits_Lim(RA2k)), ...
                     "A2k_allocsd_digits", ...
                     strcat(strf_nbits,"_A2k_Lim_digits.m"),"%2d");
    print_polynomial(int16(ndigits_Lim(RAaa1k)), ...
                     "Aaa1k_allocsd_digits", ...
                     strcat(strf_nbits,"_Aaa1k_Lim_digits.m"),"%2d");
    print_polynomial(int16(ndigits_Lim(RAaa2k)), ...
                     "Aaa2k_allocsd_digits", ...
                     strcat(strf_nbits,"_Aaa2k_Lim_digits.m"),"%2d");

    % Signed-digits allocated by Lim
    k_Lim=flt2SD(k0,nbits,ndigits_Lim);
    nbits_Lim_cost(l)= ...
      schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
        (k_Lim(RA1k),k_Lim(RA2k),difference,k_Lim(RAaa1k),k_Lim(RAaa2k), ...
         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

    % Find response of Lim filter
    Asq_Lim=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
            (wa,k_Lim(RA1k),k_Lim(RA2k),difference,k_Lim(RAaa1k),k_Lim(RAaa2k));
    T_Lim=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
            (wt,k_Lim(RA1k),k_Lim(RA2k),difference,k_Lim(RAaa1k),k_Lim(RAaa2k));
    P_Lim=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
            (wp,k_Lim(RA1k),k_Lim(RA2k),difference,k_Lim(RAaa1k),k_Lim(RAaa2k));
    dAsqdw_Lim=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
            (wd,k_Lim(RA1k),k_Lim(RA2k),difference,k_Lim(RAaa1k),k_Lim(RAaa2k));
    
    % Find response of Lim anti-aliasing filter
    Asq_aa_Lim=schurOneMPAlatticeAsq ...
                (wa,k_Lim(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
                 k_Lim(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
    T_aa_Lim=schurOneMPAlatticeT ...
              (wt,k_Lim(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
               k_Lim(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
    P_aa_Lim=schurOneMPAlatticeP ...
              (wp,k_Lim(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
               k_Lim(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
    dAsqdw_aa_Lim=schurOneMPAlatticedAsqdw ...
                   (wd,k_Lim(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
                    k_Lim(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);

    % Find the actual number of signed digits used
    [nbits_k_Lim_digits(l),nbits_k_Lim_adders(l)]=SDadders(k_Lim,nbits);
    fid=fopen(strcat(strf_nbits,"_Lim.adders.tab"),"wt");
    fprintf(fid,"$%d$",nbits_k_Lim_adders(l));
    fclose(fid);
    % Calculate the noise gain
    [A_Lim,B_Lim,C_Lim,D_Lim]= ...
      schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd ...
        (k_Lim(RA1k),k_Lim(RA2k),difference,k_Lim(RAaa1k),k_Lim(RAaa2k));
    [K_Lim,W_Lim]=KW(A_Lim,B_Lim,C_Lim,D_Lim);
    nbits_ng_Lim(l)=sum(diag(K_Lim).*diag(W_Lim));
    printf("Lim,ndigits=%d,nbits=%d,ng=%7.3f\n",ndigits,nbits,nbits_ng_Lim(l));

    % Use Ito's heuristic to allocate an average of ndigits signed-digits
    ndigits_Ito=schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Ito ...
                  (nbits,ndigits, ...
                   k0(RA1k),k0(RA2k),difference,k0(RAaa1k),k0(RAaa2k), ...
                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    % Signed-digits allocated by Ito
    k_Ito=flt2SD(k0,nbits,ndigits_Ito);
    nbits_Ito_cost(l)= ...
      schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
        (k_Ito(RA1k),k_Ito(RA2k),difference,k_Ito(RAaa1k),k_Ito(RAaa2k), ...
         wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

    % Find response of Ito anti-aliasing filter
    Asq_Ito=schurOneMPAlatticeDoublyPipelinedAntiAliasedAsq ...
            (wa,k_Ito(RA1k),k_Ito(RA2k),difference,k_Ito(RAaa1k),k_Ito(RAaa2k));
    T_Ito=schurOneMPAlatticeDoublyPipelinedAntiAliasedT ...
            (wt,k_Ito(RA1k),k_Ito(RA2k),difference,k_Ito(RAaa1k),k_Ito(RAaa2k));
    P_Ito=schurOneMPAlatticeDoublyPipelinedAntiAliasedP ...
            (wp,k_Ito(RA1k),k_Ito(RA2k),difference,k_Ito(RAaa1k),k_Ito(RAaa2k));
    dAsqdw_Ito=schurOneMPAlatticeDoublyPipelinedAntiAliaseddAsqdw ...
            (wd,k_Ito(RA1k),k_Ito(RA2k),difference,k_Ito(RAaa1k),k_Ito(RAaa2k));
    
    % Find response of Ito anti-aliasing filter
    Asq_aa_Ito=schurOneMPAlatticeAsq ...
                (wa,k_Ito(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
                 k_Ito(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
    T_aa_Ito=schurOneMPAlatticeT ...
              (wt,k_Ito(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
               k_Ito(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
    P_aa_Ito=schurOneMPAlatticeP ...
              (wp,k_Ito(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
               k_Ito(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);
    dAsqdw_aa_Ito=schurOneMPAlatticedAsqdw ...
                   (wd,k_Ito(RAaa1k),ones(size(RAaa1k)),ones(size(RAaa1k)), ...
                    k_Ito(RAaa2k),ones(size(RAaa2k)),ones(size(RAaa2k)),false);

    % Find the actual number of signed digits used
    [nbits_k_Ito_digits(l),nbits_k_Ito_adders(l)]=SDadders(k_Ito,nbits);
    fid=fopen(strcat(strf_nbits,"_Ito.adders.tab"),"wt");
    fprintf(fid,"$%d$",nbits_k_Ito_adders(l));
    fclose(fid);

    % Calculate the noise gain
    [A_Ito,B_Ito,C_Ito,D_Ito]= ...
      schurOneMPAlatticeDoublyPipelinedAntiAliased2Abcd ...
        (k_Ito(RA1k),k_Ito(RA2k),difference,k_Ito(RAaa1k),k_Ito(RAaa2k));
    [K_Ito,W_Ito]=KW(A_Ito,B_Ito,C_Ito,D_Ito);
    nbits_ng_Ito(l)=sum(diag(K_Ito).*diag(W_Ito));
    printf("Ito,ndigits=%d,nbits=%d,ng=%7.3f\n",ndigits,nbits,nbits_ng_Ito(l));

    % Plot amplitude
    plot(wa*0.5/pi,10*log10(Asq_ex),"linestyle","-", ...
         wa*0.5/pi,10*log10(Asq_rd),"linestyle",":", ...
         wa*0.5/pi,10*log10(Asq_sd),"linestyle","-.", ... 
         wa*0.5/pi,10*log10(Asq_Lim),"linestyle","--",...
         wa*0.5/pi,10*log10(Asq_Ito),"linestyle","-")
    axis([0 0.5 -80 10]);
    xlabel("Frequency");
    ylabel("Amplitude(dB)");
    grid("on");
    strt=sprintf("Lowpass one-multiplier PA lattice,nbits=%d,ndigits=%d", ...
                 nbits,ndigits);
    title(strt);
    legend("exact","round","signed-digit","Lim","Ito");
    legend("location","southwest");
    legend("boxoff");
    legend("left");
    zticks([]);
    print(strcat(strf_nbits,"_amplitude"),"-dpdflatex");
    close

    % Plot the passband amplitude
    plot(wa*0.5/pi,10*log10(Asq_ex),"linestyle","-", ...
         wa*0.5/pi,10*log10(Asq_rd),"linestyle",":", ...
         wa*0.5/pi,10*log10(Asq_sd),"linestyle","-.", ... 
         wa*0.5/pi,10*log10(Asq_Lim),"linestyle","--", ...
         wa*0.5/pi,10*log10(Asq_Ito),"linestyle","-")
    axis([0 0.5 -0.15 0.05]);
    xlabel("Frequency");
    ylabel("Amplitude(dB)");
    legend("exact","round","signed-digit","Lim","Ito");
    legend("location","southeast");
    legend("boxoff");
    legend("left");
    title(strt);
    grid("on");
    zticks([]);
    print(strcat(strf_nbits,"_pass_amplitude"),"-dpdflatex");
    close

    % Plot the passband delay
    plot(wt*0.5/pi,T_ex,"linestyle","-", ...
         wt*0.5/pi,T_rd,"linestyle",":", ...
         wt*0.5/pi,T_sd,"linestyle","-.", ... 
         wt*0.5/pi,T_Lim,"linestyle","--", ...
         wt*0.5/pi,T_Ito,"linestyle","-");
    axis([0 0.5]);
    xlabel("Frequency");
    ylabel("Delay(samples)");
    legend("exact","round","signed-digit","Lim","Ito");
    legend("location","east");
    legend("boxoff");
    legend("left");
    title(strt);
    grid("on");
    zticks([]);
    print(strcat(strf_nbits,"_pass_delay"),"-dpdflatex");
    close

    % Plot the passband phase error (adjusted for delay)
    plot(wp*0.5/pi,(P_ex-Pd)/pi,"linestyle","-", ...
         wp*0.5/pi,(P_rd-Pd)/pi,"linestyle",":", ...
         wp*0.5/pi,(P_sd-Pd)/pi,"linestyle","-.", ... 
         wp*0.5/pi,(P_Lim-Pd)/pi,"linestyle","--", ...
         wp*0.5/pi,(P_Ito-Pd)/pi,"linestyle","-");
    axis([0 0.5]);
    xlabel("Frequency");
    ylabel("Phase error(rad./$\\pi$)");
    legend("exact","round","signed-digit","Lim","Ito");
    legend("location","east");
    legend("boxoff");
    legend("left");
    title(strt);
    grid("on");
    zticks([]);
    print(strcat(strf_nbits,"_pass_phase"),"-dpdflatex");
    close

    % Plot anti-aliasing amplitude
    plot(wa*0.5/pi,10*log10(Asq_aa_ex),"linestyle","-", ...
         wa*0.5/pi,10*log10(Asq_aa_rd),"linestyle",":", ...
         wa*0.5/pi,10*log10(Asq_aa_sd),"linestyle","-.", ... 
         wa*0.5/pi,10*log10(Asq_aa_Lim),"linestyle","--",...
         wa*0.5/pi,10*log10(Asq_aa_Ito),"linestyle","-")
    axis([0 0.5 -80 10]);
    xlabel("Frequency");
    ylabel("Amplitude(dB)");
    grid("on");
    strt=sprintf("Lowpass anti-aliasing filter nbits=%d,ndigits=%d", ...
                 nbits,ndigits);
    title(strt);
    legend("exact","round","signed-digit","Lim","Ito");
    legend("location","southwest");
    legend("boxoff");
    legend("left");
    zticks([]);
    print(strcat(strf_nbits,"_antialiasing"),"-dpdflatex");
    close

    % Save the minimum pass band amplitude(0 to fap)
    nbits_sd_passband(l)=min(10*log10(Asq_sd(1:nap)));
    nbits_Lim_passband(l)=min(10*log10(Asq_Lim(1:nap)));
    nbits_Ito_passband(l)=min(10*log10(Asq_Ito(1:nap)));
   
    % Save the maximum stop band amplitude(fas to 0.50)
    nbits_sd_stopband(l)=max(10*log10(Asq_sd(nas:end)));
    nbits_Lim_stopband(l)=max(10*log10(Asq_Lim(nas:end)));
    nbits_Ito_stopband(l)=max(10*log10(Asq_Ito(nas:end)));
   
    % Save the maximum phase error (0 to fpp)
    nbits_sd_phase_error(l)= max(abs((P_sd-Pd)/pi));
    nbits_Lim_phase_error(l)=max(abs((P_Lim-Pd)/pi));
    nbits_Ito_phase_error(l)=max(abs((P_Ito-Pd)/pi));
    
    % Save the maximum delay error (0 to ftp)
    nbits_sd_delay_error(l)= max(abs(T_sd-Td));
    nbits_Lim_delay_error(l)=max(abs(T_Lim-Td));
    nbits_Ito_delay_error(l)=max(abs(T_Ito-Td));
   
    % Print the minimum pass-band amplitude for S-D
    printf(["S-D,ndigits=%d,nbits=%d,minimum pass-band amplitude", ...
            "(0 to %5.3f) = %7.3fdB\n"],...
           ndigits,nbits,fap,nbits_sd_passband(l));
    % Print the maximum stop-band amplitude for S-D
    printf(["S-D,ndigits=%d,nbits=%d,maximum stop-band amplitude", ...
            "(%5.3f to 0.50) = %7.3fdB\n"], ...
           ndigits,nbits,fas,nbits_sd_stopband(l));
    % Print the maximum pass-band phase error for S-D
    printf(["S-D,ndigits=%d,nbits=%d,maximum pass-band phase error", ...
            "(0 to %5.3f) = %8.6f (rad./pi)\n"], ...
           ndigits,nbits,fpp,nbits_sd_phase_error(l));
    % Print the maximum pass-band delay error for S-D
    printf(["S-D,ndigits=%d,nbits=%d,maximum pass-band delay error", ...
            "(0 to %5.3f) = %7.5f (samples)\n"], ...
           ndigits,nbits,ftp,nbits_sd_delay_error(l));
    
    % Print the minimum pass-band  amplitude for Lim
    printf(["Lim,ndigits=%d,nbits=%d,minimum pass-band amplitude", ...
            "(0 to %5.3f) = %7.3fdB\n"], ...
           ndigits,nbits,fap,nbits_Lim_passband(l));
    % Print the maximum stop-band amplitude for Lim
    printf(["Lim,ndigits=%d,nbits=%d,maximum stop-band amplitude", ...
            "(%5.3f to 0.50) = %7.3fdB\n"], ...
           ndigits,nbits,fas,nbits_Lim_stopband(l));
    % Print the maximum pass-band phase error for Lim
    printf(["Lim,ndigits=%d,nbits=%d,maximum pass-band phase error", ...
            "(0 to %5.3f) = %8.6f (rad./pi)\n"], ...
           ndigits,nbits,fpp,nbits_Lim_phase_error(l));
    % Print the maximum pass-band delay error for Lim
    printf(["Lim,ndigits=%d,nbits=%d,maximum pass-band delay error", ...
            "(0 to %5.3f) = %7.5f (samples)\n"], ...
           ndigits,nbits,ftp,nbits_Lim_delay_error(l));
    
    % Print the minimum pass-band amplitude for Ito
    printf(["Ito,ndigits=%d,nbits=%d,minimum pass-band amplitude", ...
            "(0 to %5.3f) = %7.3fdB\n"],
           ndigits,nbits,fap,nbits_Ito_passband(l));
    % Print the maximum stop-band amplitude for Ito
    printf(["Ito,ndigits=%d,nbits=%d,maximum stop-band amplitude", ...
            "(%5.3f to 0.50) = %7.3fdB\n"], ...
           ndigits,nbits,fas,nbits_Ito_stopband(l));
    % Print the maximum pass-band phase error for Ito
    printf(["Ito,ndigits=%d,nbits=%d,maximum pass-band phase error", ...
            "(0 to %5.3f) = %8.6f (rad./pi)\n"], ...
           ndigits,nbits,fpp,nbits_Ito_phase_error(l));
    % Print the maximum pass-band delay error for Ito
    printf(["Ito,ndigits=%d,nbits=%d,maximum pass-band delay error", ...
            "(0 to %5.3f) = %7.5f (samples)\n"], ...
           ndigits,nbits,ftp,nbits_Ito_delay_error(l));

    % Print the coefficients
    print_polynomial(k_sd(RA1k),sprintf("A1k_sd_%d_bits",nbits),...
                     strcat(strf_nbits,"_A1k_sd_coef.m"),nscale);
    print_polynomial(k_sd(RA2k),sprintf("A2k_sd_%d_bits",nbits),...
                     strcat(strf_nbits,"_A2k_sd_coef.m"),nscale);
    print_polynomial(k_sd(RAaa1k),sprintf("Aaa1k_sd_%d_bits",nbits),...
                     strcat(strf_nbits,"_Aaa1k_sd_coef.m"),nscale);
    print_polynomial(k_sd(RAaa2k),sprintf("Aaa2k_sd_%d_bits",nbits),...
                     strcat(strf_nbits,"_Aaa2k_sd_coef.m"),nscale);
    
    print_polynomial(k_Lim(RA1k),sprintf("A1k_Lim_%d_bits",nbits),...
                     strcat(strf_nbits,"_A1k_Lim_coef.m"),nscale);
    print_polynomial(k_Lim(RA2k),sprintf("A2k_Lim_%d_bits",nbits),...
                     strcat(strf_nbits,"_A2k_Lim_coef.m"),nscale);
    print_polynomial(k_Lim(RAaa1k),sprintf("Aaa1k_Lim_%d_bits",nbits),...
                     strcat(strf_nbits,"_Aaa1k_Lim_coef.m"),nscale);
    print_polynomial(k_Lim(RAaa2k),sprintf("Aaa2k_Lim_%d_bits",nbits),...
                     strcat(strf_nbits,"_Aaa2k_Lim_coef.m"),nscale);

    print_polynomial(k_Ito(RA1k),sprintf("A1k_Ito_%d_bits",nbits),...
                     strcat(strf_nbits,"_A1k_Ito_coef.m"),nscale);
    print_polynomial(k_Ito(RA2k),sprintf("A2k_Ito_%d_bits",nbits),...
                     strcat(strf_nbits,"_A2k_Ito_coef.m"),nscale);
    print_polynomial(k_Ito(RAaa1k),sprintf("Aaa1k_Ito_%d_bits",nbits),...
                     strcat(strf_nbits,"_Aaa1k_Ito_coef.m"),nscale);
    print_polynomial(k_Ito(RAaa2k),sprintf("Aaa2k_Ito_%d_bits",nbits),...
                     strcat(strf_nbits,"_Aaa2k_Ito_coef.m"),nscale);
  endfor

  % Plot comparison of cost
  subplot(111)
  plot(nbits_range,nbits_rd_cost,"linestyle",":", ...
       nbits_range,nbits_sd_cost,"linestyle","-.", ... 
       nbits_range,nbits_Lim_cost,"linestyle","--",...
       nbits_range,nbits_Ito_cost,"linestyle","-")
  strt=sprintf("Low-pass one-multiplier PA lattice cost, ndigits=%d", ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Cost");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  zticks([]);
  print(strcat(strf_ndigits,"_cost"),"-dpdflatex");
  close

  % Plot comparison of maximum amplitude response in stop band
  subplot(111)
  plot(nbits_range,nbits_rd_stopband,"linestyle",":", ...
       nbits_range,nbits_sd_stopband,"linestyle","-.", ... 
       nbits_range,nbits_Lim_stopband,"linestyle","--", ...
       nbits_range,nbits_Ito_stopband,"linestyle","-")
  strt=sprintf(["Low-pass one-multiplier PA lattice maximum amplitude ", ...
                "response in [%5.3f,0.5) (dB), ndigits=%d"],fas,ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Maximum amplitude response(dB)");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  zticks([]);
  print(strcat(strf_ndigits,"_stopband"),"-dpdflatex");
  close

  % Plot comparison of minimum amplitude response in pass band
  subplot(111)
  plot(nbits_range,nbits_rd_passband,"linestyle",":", ...
       nbits_range,nbits_sd_passband,"linestyle","-.", ... 
       nbits_range,nbits_Lim_passband,"linestyle","--", ...
       nbits_range,nbits_Ito_passband,"linestyle","-")
  strt=sprintf(["Low-pass one-multiplier PA lattice minimum amplitude ", ...
                "response in [0 %4.3f) (dB), ndigits=%d"],fap,ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Minimum amplitude response(dB)");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","southeast");
  legend("boxoff");
  legend("left");
  zticks([]);
  print(strcat(strf_ndigits,"_passband"),"-dpdflatex");
  close

  % Plot comparison of maximum phase error in pass band
  subplot(111)
  plot(nbits_range,nbits_rd_phase_error,"linestyle",":", ...
       nbits_range,nbits_sd_phase_error,"linestyle","-.", ... 
       nbits_range,nbits_Lim_phase_error,"linestyle","--", ...
       nbits_range,nbits_Ito_phase_error,"linestyle","-")
  strt=sprintf(["Low-pass one-multiplier PA lattice maximum phase error ", ...
                "in [0 %5.3f) (rad./$\\pi$), ndigits=%d"],fpp,ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Maximum phase error(rad./$\\pi$)");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  zticks([]);
  print(strcat(strf_ndigits,"_phase"),"-dpdflatex");
  close

  % Plot comparison of maximum delay error in pass band
  subplot(111)
  plot(nbits_range,nbits_rd_delay_error,"linestyle",":", ...
       nbits_range,nbits_sd_delay_error,"linestyle","-.", ... 
       nbits_range,nbits_Lim_delay_error,"linestyle","--", ...
       nbits_range,nbits_Ito_delay_error,"linestyle","-")
  strt=sprintf(["Low-pass one-multiplier PA lattice maximum delay error ", ...
                "in [0 %5.3f) (dB), ndigits=%d"],ftp,ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Maximum delay error(samples)");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northeast");
  legend("boxoff");
  legend("left");
  zticks([]);
  print(strcat(strf_ndigits,"_delay"),"-dpdflatex");
  close

  % Plot comparison of total signed-digits used
  subplot(111)
  plot(nbits_range,nbits_k_rd_digits,"linestyle",":", ...
       nbits_range,nbits_k_sd_digits,"linestyle","-.", ... 
       nbits_range,nbits_k_Lim_digits,"linestyle","--",...
       nbits_range,nbits_k_Ito_digits,"linestyle","-")
  strt=sprintf(["Low-pass one-multiplier PA lattice total signed-digits ", ...
                "used by coefficients, ndigits=%d"],ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Total signed-digits used by coefficients");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northwest");
  legend("boxoff");
  legend("left");
  zticks([]);
  print(strcat(strf_ndigits,"_digits"),"-dpdflatex");
  close

  % Plot comparison of total adders used
  subplot(111)
  plot(nbits_range,nbits_k_rd_adders,"linestyle",":", ...
       nbits_range,nbits_k_sd_adders,"linestyle","-.", ... 
       nbits_range,nbits_k_Lim_adders,"linestyle","--",...
       nbits_range,nbits_k_Ito_adders,"linestyle","-")
  strt=sprintf(["Low-pass one-multiplier PA lattice total adders ", ...
                "used by coefficients, ndigits=%d"],ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Total adders used by coefficients");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","northwest");
  legend("boxoff");
  legend("left");
  zticks([]);
  print(strcat(strf_ndigits,"_adders"),"-dpdflatex");
  close

  % Plot comparison of noise gain
  subplot(111)
  plot(nbits_range,nbits_ng_rd,"linestyle",":", ...
       nbits_range,nbits_ng_sd,"linestyle","-.", ... 
       nbits_range,nbits_ng_Lim,"linestyle","--",...
       nbits_range,nbits_ng_Ito,"linestyle","-")
  strt=sprintf("Low-pass one-multiplier PA lattice noise gain, ndigits=%d", ...
               ndigits);
  title(strt);
  xlabel("bits");
  ylabel("Noise gain");
  grid("on");
  legend("round","signed-digit","Lim","Ito");
  legend("location","southeast");
  legend("boxoff");
  legend("left");
  zticks([]);
  print(strcat(strf_ndigits,"_ng"),"-dpdflatex");
  close
  
endfor

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
