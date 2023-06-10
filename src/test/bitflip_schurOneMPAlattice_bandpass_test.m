% bitflip_schurOneMPAlattice_bandpass_test.m
% Copyright (C) 2019-2023 Robert G. Jenssen
%
% Test case for the bit-flipping algorithm with coefficents of
% a bandpass lattice filter in one multiplier parallel allpass form.

test_common;

delete("bitflip_schurOneMPAlattice_bandpass_test.diary");
delete("bitflip_schurOneMPAlattice_bandpass_test.diary.tmp");
diary bitflip_schurOneMPAlattice_bandpass_test.diary.tmp

% File name string
strf="bitflip_schurOneMPAlattice_bandpass_test";

bitflip_bandpass_test_common;

% All-pass filters from schurOneMPAlattice_socp_slb_bandpass_test.m
schurOneMPAlattice_socp_slb_bandpass_test_A1k_coef;
schurOneMPAlattice_socp_slb_bandpass_test_A1p_coef;
schurOneMPAlattice_socp_slb_bandpass_test_A1epsilon_coef;
schurOneMPAlattice_socp_slb_bandpass_test_A2k_coef;
schurOneMPAlattice_socp_slb_bandpass_test_A2epsilon_coef;
schurOneMPAlattice_socp_slb_bandpass_test_A2p_coef;

A1k0=A1k;
A1p0=A1p;
A1epsilon0=A1epsilon;
A2k0=A2k;
A2epsilon0=A2epsilon;
A2p0=A2p;
difference=true;

% Find vector of exact lattice coefficients
[cost_ex,A1k_ex,A2k_ex,svecnz_ex] = ...
schurOneMPAlattice_cost([],Ad,Wa,Td,Wt, ...
                        A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                        difference,0,0);

% Find the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
[n0,d0]=schurOneMPAlattice2tf(A1k0,A1epsilon0,ones(size(A1p0)), ...
                              A2k0,A2epsilon0,ones(size(A2p0)),difference);
[h0,wplot]=freqz(n0,d0,nplot);
t0=delayz(n0,d0,nplot);
% Rounded truncation
[cost_rd,A1k_rd,A2k_rd,svec_rd] = ...
  schurOneMPAlattice_cost([],Ad,Wa,Td,Wt, ...
                          A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                          difference,nbits,0)
[n_rd,d_rd]=schurOneMPAlattice2tf(A1k_rd,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_rd,A2epsilon0,ones(size(A2p0)), ...
                                  difference);
h_rd=freqz(n_rd,d_rd,nplot);
t_rd=delayz(n_rd,d_rd,nplot);
% Find the total number of adders required to implement the rounded multipliers
krd=[A1k_rd(:);A2k_rd(:)];
[krd_digits,krd_adders]=SDadders(krd,nbits);
fname=strcat(strf,"_adders_rd.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",krd_adders);
fclose(fid);

% Find optimised lattice coefficients with bit-flipping
svec_bf=bitflip(@schurOneMPAlattice_cost,svec_rd,nbits,bitstart,msize);
[cost_bf,A1k_bf,A2k_bf]=schurOneMPAlattice_cost(svec_bf)
[n_bf,d_bf]= ...
  schurOneMPAlattice2tf(A1k_bf,A1epsilon0,ones(size(A1p0)), ...
                        A2k_bf,A2epsilon0,ones(size(A2p0)),difference);
h_bf=freqz(n_bf,d_bf,nplot);
t_bf=delayz(n_bf,d_bf,nplot);
% Find the total number of adders required to implement the BF multipliers
kbf=[A1k_bf(:);A2k_bf(:)];
[kbf_digits,kbf_adders]=SDadders(kbf,nbits);
fname=strcat(strf,"_adders_bf.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",kbf_adders);
fclose(fid);

% Signed-digit truncation
[cost_sd,A1k_sd,A2k_sd,svec_sd] = ...
   schurOneMPAlattice_cost([],Ad,Wa,Td,Wt, ...
                           A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                           difference,nbits,ndigits)
[n_sd,d_sd]=schurOneMPAlattice2tf(A1k_sd,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_sd,A2epsilon0,ones(size(A2p0)), ...
                                  difference);
h_sd=freqz(n_sd,d_sd,nplot);
t_sd=delayz(n_sd,d_sd,nplot);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsd=bitflip(@schurOneMPAlattice_cost,svec_sd,nbits,bitstart,msize);
[cost_bfsd,A1k_bfsd,A2k_bfsd]=schurOneMPAlattice_cost(svec_bfsd)
[n_bfsd,d_bfsd]=schurOneMPAlattice2tf(A1k_bfsd,A1epsilon0,ones(size(A1p0)), ...
                                      A2k_bfsd,A2epsilon0,ones(size(A2p0)), ...
                                      difference);
h_bfsd=freqz(n_bfsd,d_bfsd,nplot);
t_bfsd=delayz(n_bfsd,d_bfsd,nplot);

% Allocate signed digits with Lim's algorithm
ndigits_Lim=schurOneMPAlattice_allocsd_Lim ...
              (nbits,ndigits, ...
               A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,difference, ...
               w,Ad.^2,Wa,w,Td,Wt);

% Signed-digit truncation with Lim's algorithm
[cost_sdl,A1k_sdl,A2k_sdl,svec_sdl] = ...
   schurOneMPAlattice_cost([],Ad,Wa,Td,Wt, ...
                           A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                           difference,nbits,ndigits_Lim)
[n_sdl,d_sdl]= ...
  schurOneMPAlattice2tf(A1k_sdl,A1epsilon0,ones(size(A1p0)), ...
                        A2k_sdl,A2epsilon0,ones(size(A2p0)),difference);
h_sdl=freqz(n_sdl,d_sdl,nplot);
t_sdl=delayz(n_sdl,d_sdl,nplot);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsdl=bitflip(@schurOneMPAlattice_cost,svec_sdl,nbits,bitstart,msize);
[cost_bfsdl,A1k_bfsdl,A2k_bfsdl]=schurOneMPAlattice_cost(svec_bfsdl)
[n_bfsdl,d_bfsdl]= ...
  schurOneMPAlattice2tf(A1k_bfsdl,A1epsilon0,ones(size(A1p0)), ...
                        A2k_bfsdl,A2epsilon0,ones(size(A2p0)),difference);
h_bfsdl=freqz(n_bfsdl,d_bfsdl,nplot);
t_bfsdl=delayz(n_bfsdl,d_bfsdl,nplot);

% Allocate signed digits with Ito's algorithm
ndigits_Ito= ...
  schurOneMPAlattice_allocsd_Ito(nbits,ndigits, ...
                                 A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                                 difference, ...
                                 w,Ad.^2,Wa,w,Td,Wt);

% Signed-digit truncation with Ito's algorithm
[cost_sdi,A1k_sdi,A2k_sdi,svec_sdi] = ...
   schurOneMPAlattice_cost([],Ad,Wa,Td,Wt, ...
                           A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                           difference,nbits,ndigits_Ito)
[n_sdi,d_sdi]=schurOneMPAlattice2tf(A1k_sdi,A1epsilon0,ones(size(A1p0)), ...
                                    A2k_sdi,A2epsilon0,ones(size(A2p0)), ...
                                    difference);
h_sdi=freqz(n_sdi,d_sdi,nplot);
t_sdi=delayz(n_sdi,d_sdi,nplot);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsdi=bitflip(@schurOneMPAlattice_cost,svec_sdi,nbits,bitstart,msize);
[cost_bfsdi,A1k_bfsdi,A2k_bfsdi]=schurOneMPAlattice_cost(svec_bfsdi)
[n_bfsdi,d_bfsdi]= ...
  schurOneMPAlattice2tf(A1k_bfsdi,A1epsilon0,ones(size(A1p0)), ...
                        A2k_bfsdi,A2epsilon0,ones(size(A2p0)),difference);
h_bfsdi=freqz(n_bfsdi,d_bfsdi,nplot);
t_bfsdi=delayz(n_bfsdi,d_bfsdi,nplot);

% Make a LaTeX table for cost
fname=strcat(strf,"_cost.tab");
fid=fopen(fname,"wt");
fprintf(fid,"Exact & %6.4f\\\\\n",cost_ex);
fprintf(fid,"%d-bit rounded & %6.4f\\\\\n",nbits,cost_rd);
fprintf(fid,"%d-bit rounded with bit-flipping & %6.4f\\\\\n",nbits,cost_bf);
fprintf(fid,"%d-bit %d-signed-digit & %6.4f \\\\ \n",nbits,ndigits,cost_sd);
fprintf(fid,"%d-bit %d-signed-digit with bit-flipping & %6.4f\\\\\n",
        nbits,ndigits,cost_bfsd);
fprintf(fid,"%d-bit %d-signed-digit(Lim alloc.) & %6.4f\\\\\n",
        nbits,ndigits,cost_sdl);
fprintf(fid,"%d-bit %d-signed-digit(Lim alloc.) with bit-flipping & %6.4f\\\\\n",
        nbits,ndigits,cost_bfsdl);
fprintf(fid,"%d-bit %d-signed-digit(Ito alloc.) & %6.4f\\\\\n",
        nbits,ndigits,cost_sdi);
fprintf(fid,"%d-bit %d-signed-digit(Ito alloc.) with bit-flipping & %6.4f\\\\\n",
        nbits,ndigits,cost_bfsdi);
fclose(fid);

% Find the total number of adders required to implement the SD multipliers
kbfsd=[A1k_bfsd(:);A2k_bfsd(:)];
[kbfsd_digits,kbfsd_adders]=SDadders(kbfsd,nbits);
fname=strcat(strf,"_adders_bfsd.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",kbfsd_adders);
fclose(fid);

% Find the total number of adders required to implement the SD multipliers
% with Lim's allocation method
kbfsdl=[A1k_bfsdl(:);A2k_bfsdl(:)];
[kbfsdl_digits,kbfsdl_adders]=SDadders(kbfsdl,nbits);
fname=strcat(strf,"_adders_Lim.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",kbfsdl_adders);
fclose(fid);

% Find the total number of adders required to implement the SD multipliers
% with Ito's allocation method
kbfsdi=[A1k_bfsdi(:);A2k_bfsdi(:)];
[kbfsdi_digits,kbfsdi_adders]=SDadders(kbfsdi,nbits);
fname=strcat(strf,"_adders_Ito.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",kbfsdi_adders);
fclose(fid);

% Plot the results
subplot(211)
plot(wplot*0.5/pi,20*log10(abs(    h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(  h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(  h_bf)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(  h_sd)),"linestyle","-.", ... 
     wplot*0.5/pi,20*log10(abs(h_bfsd)),"linestyle","-")
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
strt=sprintf("Bandpass OneM PA lattice, nbits=%d,bitstart=%d,\
msize=%d,ndigits=%d",nbits,bitstart,msize,ndigits);
title(strt);
subplot(212)
iplot=1:(0.7*nplot); % Avoid overlap with legend
plot(wplot(iplot)*0.5/pi,    t0(iplot),"linestyle","-", ...
     wplot(iplot)*0.5/pi,  t_rd(iplot),"linestyle",":", ...
     wplot(iplot)*0.5/pi,  t_bf(iplot),"linestyle","--", ... 
     wplot(iplot)*0.5/pi,  t_sd(iplot),"linestyle","-.", ... 
     wplot(iplot)*0.5/pi,t_bfsd(iplot),"linestyle","-");
legend("exact","round","bitflip(round)","signed-digit","bitflip(s-d)");
legend("location","northeast");
legend("boxoff");
legend("left");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0 0.5 0 25]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close
% Re-plot for the passband (!?!?!?)
subplot(211)
plot(wplot*0.5/pi,20*log10(abs(    h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(  h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(  h_bf)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(  h_sd)),"linestyle","-.", ... 
     wplot*0.5/pi,20*log10(abs(h_bfsd)),"linestyle","-")
ylabel("Amplitude(dB)");
strt=sprintf("Bandpass OneM PA lattice, nbits=%d,bitstart=%d,\
msize=%d,ndigits=%d",nbits,bitstart,msize,ndigits);
title(strt);
grid("on");
axis([0 0.5 -3 1]);
subplot(212)
iplot=1:(0.7*nplot); % Avoid overlap with legend
plot(wplot(iplot)*0.5/pi,    t0(iplot),"linestyle","-", ...
     wplot(iplot)*0.5/pi,  t_rd(iplot),"linestyle",":", ...
     wplot(iplot)*0.5/pi,  t_bf(iplot),"linestyle","--", ... 
     wplot(iplot)*0.5/pi,  t_sd(iplot),"linestyle","-.", ... 
     wplot(iplot)*0.5/pi,t_bfsd(iplot),"linestyle","-");
legend("exact","round","bitflip(round)","signed-digit","bitflip(s-d)");
legend("location","northeast");
legend("boxoff");
legend("left");
xlabel("Frequency");
ylabel("Delay(samples)");
grid("on");
title(strt);
axis([0 0.5 14 18]);
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Plot results with signed-digit allocation
subplot(211)
plot(wplot*0.5/pi,20*log10(abs(    h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(  h_sdl)),"linestyle",":", ... 
     wplot*0.5/pi,20*log10(abs(h_bfsdl)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(  h_sdi)),"linestyle","-.", ...  
     wplot*0.5/pi,20*log10(abs(h_bfsdi)),"linestyle","-")
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
strt=sprintf("Bandpass OneM PA lattice, nbits=%d,bitstart=%d,\
msize=%d,ndigits=%d, Lim and Ito SD allocation",nbits,bitstart,msize,ndigits);
title(strt);
subplot(212)
iplot=1:(0.7*nplot); % Avoid overlap with legend
plot(wplot(iplot)*0.5/pi,      t0(iplot),"linestyle","-", ...
     wplot(iplot)*0.5/pi,   t_sdl(iplot),"linestyle",":", ...
     wplot(iplot)*0.5/pi, t_bfsdl(iplot),"linestyle","--", ... 
     wplot(iplot)*0.5/pi,   t_sdi(iplot),"linestyle","-.", ... 
     wplot(iplot)*0.5/pi, t_bfsdi(iplot),"linestyle","-");
legend("exact","signed-digit (Lim)","bitflip(s-d Lim)","signed-digit (Ito)", ...
       "bitflip(s-d Ito)");
legend("location","northeast");
legend("boxoff");
legend("left");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0 0.5 0 25]);
grid("on");
print(strcat(strf,"_response_allocsd"),"-dpdflatex");
% Re-display plots
subplot(211);
axis([0 0.5 -3 1]);
subplot(212);
axis([0 0.5 14 18]);
print(strcat(strf,"_passband_response_allocsd"),"-dpdflatex");
close

% Print the results
print_polynomial(A1k_ex,"A1k_ex");
print_polynomial(A2k_ex,"A2k_ex");

print_polynomial(A1k_ex,"A1k_ex",strcat(strf,"_A1k_ex_coef.m"));
print_polynomial(A2k_ex,"A2k_ex",strcat(strf,"_A2k_ex_coef.m"));

print_polynomial(A1k_rd,"A1k_rd",nscale);
print_polynomial(A2k_rd,"A2k_rd",nscale);

print_polynomial(A1k_rd,"A1k_rd",strcat(strf,"_A1k_rd_coef.m"),nscale);
print_polynomial(A2k_rd,"A2k_rd",strcat(strf,"_A2k_rd_coef.m"),nscale);

print_polynomial(A1k_bf,"A1k_bf",nscale);
print_polynomial(A2k_bf,"A2k_bf",nscale);

print_polynomial(A1k_bf,"A1k_bf",strcat(strf,"_A1k_bf_coef.m"),nscale);
print_polynomial(A2k_bf,"A2k_bf",strcat(strf,"_A2k_bf_coef.m"),nscale);

print_polynomial(A1k_sd,"A1k_sd",nscale);
print_polynomial(A2k_sd,"A2k_sd",nscale);

print_polynomial(A1k_sd,"A1k_sd",strcat(strf,"_A1k_sd_coef.m"),nscale);
print_polynomial(A2k_sd,"A2k_sd",strcat(strf,"_A2k_sd_coef.m"),nscale);

print_polynomial(A1k_bfsd,"A1k_bfsd",nscale);
print_polynomial(A2k_bfsd,"A2k_bfsd",nscale);

print_polynomial(A1k_bfsd,"A1k_bfsd",strcat(strf,"_A1k_bfsd_coef.m"),nscale);
print_polynomial(A2k_bfsd,"A2k_bfsd",strcat(strf,"_A2k_bfsd_coef.m"),nscale);

print_polynomial(A1k_sdl,"A1k_sdl",nscale);
print_polynomial(A2k_sdl,"A2k_sdl",nscale);

print_polynomial(A1k_sdl,"A1k_sdl",strcat(strf,"_A1k_sdl_coef.m"),nscale);
print_polynomial(A2k_sdl,"A2k_sdl",strcat(strf,"_A2k_sdl_coef.m"),nscale);

print_polynomial(A1k_bfsdl,"A1k_bfsdl",nscale);
print_polynomial(A2k_bfsdl,"A2k_bfsdl",nscale);

print_polynomial(A1k_bfsdl,"A1k_bfsdl",strcat(strf,"_A1k_bfsdl_coef.m"),nscale);
print_polynomial(A2k_bfsdl,"A2k_bfsdl",strcat(strf,"_A2k_bfsdl_coef.m"),nscale);

print_polynomial(A1k_sdi,"A1k_sdi",nscale);
print_polynomial(A2k_sdi,"A2k_sdi",nscale);

print_polynomial(A1k_sdi,"A1k_sdi",strcat(strf,"_A1k_sdi_coef.m"),nscale);
print_polynomial(A2k_sdi,"A2k_sdi",strcat(strf,"_A2k_sdi_coef.m"),nscale);

print_polynomial(A1k_bfsdi,"A1k_bfsdi",nscale);
print_polynomial(A2k_bfsdi,"A2k_bfsdi",nscale);

print_polynomial(A1k_bfsdi,"A1k_bfsdi",strcat(strf,"_A1k_bfsdi_coef.m"),nscale);
print_polynomial(A2k_bfsdi,"A2k_bfsdi",strcat(strf,"_A2k_bfsdi_coef.m"),nscale);

% Save the results
save bitflip_schurOneMPAlattice_bandpass_test.mat ...
   A1k_ex A2k_ex A1k_rd A2k_rd A1k_bf A2k_bf A1k_sd A2k_sd A1k_bfsd A2k_bfsd ...
   A1k_sdl A2k_sdl A1k_bfsdl A2k_bfsdl A1k_sdi A2k_sdi A1k_bfsdi A2k_bfsdi 

% Done
diary off
movefile bitflip_schurOneMPAlattice_bandpass_test.diary.tmp ...
         bitflip_schurOneMPAlattice_bandpass_test.diary;
