% schurOneMPAlatticeDelay_lowpass_Esq_comparison_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="schurOneMPAlatticeDelay_lowpass_Esq_comparison_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

% Filter specification
n=1000
m=5 % Allpass filter denominator order
DD=4 % Parallel delay
fap=0.10 % Pass band amplitude response edge
Wap=0.1 % Pass band amplitude response weight
Wat=0 % Transition band amplitude response weight
fas=0.20 % Stop band amplitude response edge
Was=200 % Stop band amplitude response weight

% Initialise
ones_m=ones(m,1);
ones_DD=ones(DD,1);
zeros_DD=zeros(DD,1);

% Frequency vectors
wa=(0:(n-1))'*pi/n;
nap=ceil(n*fap/0.5)+1;
nas=floor(n*fas/0.5)+1;
Ad=[ones(nap,1); zeros(n-nap,1)];
Wa=[Wap*ones(nap,1);Wat*ones(nas-nap-1,1);Was*ones(n-nas+1,1)];

% Read coefficients

schurOneMPAlatticeDelay_socp_slb_lowpass_test_m_5_A1k0_coef;
k0 = A1k0;
Esq0 = schurOneMPAlatticeEsq(k0,ones_m,ones_m, ...
                             zeros_DD,ones_DD,ones_DD,false, ...
                             wa,Ad,Wa)
Asq0 = schurOneMPAlatticeAsq(wa,k0,ones_m,ones_m, ...
                             zeros_DD,ones_DD,ones_DD,false);
A0min_dB = 10*log10(min(Asq0(1:nap)))
A0max_dB = 10*log10(max(Asq0(nas:n)))

schurOneMPAlatticeDelay_socp_slb_lowpass_test_m_5_A1k_coef;
k_socp_slb=A1k;
Esq_socp_slb = schurOneMPAlatticeEsq(k_socp_slb,ones_m,ones_m, ...
                                     zeros_DD,ones_DD,ones_DD,false, ...
                                     wa,Ad,Wa)
Asq_socp_slb = schurOneMPAlatticeAsq(wa,k_socp_slb,ones_m,ones_m, ...
                                     zeros_DD,ones_DD,ones_DD,false);
Amin_dB_socp_slb = 10*log10(min(Asq_socp_slb(1:nap)))
Amax_dB_socp_slb = 10*log10(max(Asq_socp_slb(nas:n)))

schurOneMPAlatticeDoublyPipelinedDelay_kyp_Dinh_lowpass_test_k_coef;
k_kyp_Dinh=k;
Esq_kyp_Dinh = schurOneMPAlatticeEsq(k_kyp_Dinh,ones_m,ones_m, ...
                                     zeros_DD,ones_DD,ones_DD,false, ...
                                     wa,Ad,Wa)
Asq_kyp_Dinh = schurOneMPAlatticeAsq(wa,k_kyp_Dinh,ones_m,ones_m, ...
                                     zeros_DD,ones_DD,ones_DD,false);
Amin_dB_kyp_Dinh = 10*log10(min(Asq_kyp_Dinh(1:nap)))
Amax_dB_kyp_Dinh = 10*log10(max(Asq_kyp_Dinh(nas:n)))

schurOneMPAlatticeDoublyPipelinedDelay_kyp_LeeHu_lowpass_test_k_coef;
k_kyp_LeeHu=k;

Esq_kyp_LeeHu = schurOneMPAlatticeEsq(k_kyp_LeeHu,ones_m,ones_m, ...
                                      zeros_DD,ones_DD,ones_DD,false, ...
                                      wa,Ad,Wa)
Asq_kyp_LeeHu = schurOneMPAlatticeAsq(wa,k_kyp_LeeHu,ones_m,ones_m, ...
                                      zeros_DD,ones_DD,ones_DD,false);
Amin_dB_kyp_LeeHu = 10*log10(min(Asq_kyp_LeeHu(1:nap)))
Amax_dB_kyp_LeeHu = 10*log10(max(Asq_kyp_LeeHu(nas:n)))

% Make LaTeX table for overall noise gains
fname=strcat(strf,".tab");
fid=fopen(fname,"wt");
fprintf(fid,"Initial & %8.3g & %5.2f & %6.3f \\\\ \n", ...
        Esq0, A0max_dB, A0min_dB);
fprintf(fid,"SOCP(PCLS) & %8.3g & %5.2f & %6.3f \\\\ \n", ...
        Esq_socp_slb, Amax_dB_socp_slb, Amin_dB_socp_slb);
fprintf(fid,"KYP(Dinh) & %8.3g & %5.2f & %6.3f \\\\ \n", ...
        Esq_kyp_Dinh, Amax_dB_kyp_Dinh, Amin_dB_kyp_Dinh);
fprintf(fid,"KYP(Lee and Hu) & %8.3g & %5.2f & %6.3f \\\\", ...
        Esq_kyp_LeeHu, Amax_dB_kyp_LeeHu, Amin_dB_kyp_LeeHu);
fclose(fid);

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
