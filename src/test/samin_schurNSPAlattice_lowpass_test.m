% samin_schurNSPAlattice_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the samin algorithm with coefficients of
% a 5th order elliptic filter implemented as the sum of two 
% all-pass lattice filters in normalised-scaled form.
%
% Notes:
%  1. Unfortunately the siman algorithm is not repeatable.
%     The minimum cost found varies.
%  2. Change use_best_siman_found to false to run siman

test_common;

pkg load optim;

delete("samin_schurNSPAlattice_lowpass_test.diary");
delete("samin_schurNSPAlattice_lowpass_test.diary.tmp");
diary samin_schurNSPAlattice_lowpass_test.diary.tmp

truncation_test_common;

use_best_siman_found=true
if use_best_siman_found
  warning("Using the best filter found so far. \n\
Set \"use_best_siman_found\"=false to re-run samin.");
endif

strf="samin_schurNSPAlattice_lowpass_test";

% Lattice decomposition
[Aap1_0,Aap2_0]=tf2pa(n0,d0);
[A1s10_0,A1s11_0,A1s20_0,A1s00_0,A1s02_0,A1s22_0]= ...
  tf2schurNSlattice(fliplr(Aap1_0),Aap1_0);
[A2s10_0,A2s11_0,A2s20_0,A2s00_0,A2s02_0,A2s22_0]= ...
  tf2schurNSlattice(fliplr(Aap2_0),Aap2_0);

% Find vector of exact lattice coefficients
use_symmetric_s=true;
[cost_ex, ...
 A1s20_ex,A1s00_ex,A1s02_ex,A1s22_ex,A2s20_ex,A2s00_ex,A2s02_ex,A2s22_ex, ...
 svec_ex] = ...
  schurNSPAlattice_cost([],Ad,Wa,Td,Wt, ...
                        A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
                        A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
                        use_symmetric_s,0,0);
printf("cost_ex=%8.5f\n",cost_ex);

% Find the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
% Rounded truncation
[cost_rd, ...
 A1s20_rd,A1s00_rd,A1s02_rd,A1s22_rd,A2s20_rd,A2s00_rd,A2s02_rd,A2s22_rd, ...
 svec_rd] = ...
  schurNSPAlattice_cost([],Ad,Wa,Td,Wt, ...
                        A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
                        A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
                        use_symmetric_s,nbits,0);
printf("cost_rd=%8.5f\n",cost_rd);
[svec_rd_digits,svec_rd_adders]=SDadders(svec_rd,nbits);
printf("svec_rd_digits=%d,svec_rd_adders=%d\n",svec_rd_digits,svec_rd_adders);
[n_rd,d_rd]=schurNSPAlattice2tf(A1s20_rd,A1s00_rd,A1s02_rd,A1s22_rd, ...
                                A2s20_rd,A2s00_rd,A2s02_rd,A2s22_rd);
h_rd=freqz(n_rd,d_rd,nplot);
% Find the optimised rounded lattice coefficients with samin
if use_best_siman_found
  svec_sa_exact = [ -26.4871,  22.8623,  17.4886,  24.0457, ... 
                    -24.6244,  28.7904, -21.5945,  20.5965, ... 
                     10.5225,  25.4632 ]';
else
  ub=nshift*ones(length(svec_rd),1);
  lb=-ub;
  siman_opt=optimset("algorithm","siman","lbound",lb,"ubound",ub);
  svec_sa_exact=[];
  [svec_sa_exact,cost_sa,conv_sa,details_sa] = ...
    nonlin_min("schurNSPAlattice_cost",svec_rd(:),siman_opt);
  if isempty(svec_sa_exact)
    error("samin failed!");
  endif
  print_polynomial(svec_sa_exact,"svec_sa_exact","%8.4f");
endif
[cost_sa, ...
 A1s20_sa,A1s00_sa,A1s02_sa,A1s22_sa, ...
 A2s20_sa,A2s00_sa,A2s02_sa,A2s22_sa, ...
 svec_sa] = ...
 schurNSPAlattice_cost(svec_sa_exact);
printf("cost_sa=%8.5f\n",cost_sa);
print_polynomial(svec_sa,"svec_sa","%3d");
[svec_sa_digits,svec_sa_adders]=SDadders(svec_sa,nbits);
printf("svec_sa_digits=%d,svec_sa_adders=%d\n",svec_sa_digits,svec_sa_adders);
[n_sa,d_sa]=schurNSPAlattice2tf(A1s20_sa,A1s00_sa,A1s02_sa,A1s22_sa, ...
                                A2s20_sa,A2s00_sa,A2s02_sa,A2s22_sa);
h_sa=freqz(n_sa,d_sa,nplot);

% Signed-digit truncation
use_symmetric_s=false;
[cost_sd, ...
 A1s20_sd,A1s00_sd,A1s02_sd,A1s22_sd, ...
 A2s20_sd,A2s00_sd,A2s02_sd,A2s22_sd, ...
 svec_sd] = ...
  schurNSPAlattice_cost([],Ad,Wa,Td,Wt, ...
                        A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
                        A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
                        use_symmetric_s,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[svec_sd_digits,svec_sd_adders]=SDadders(svec_sd,nbits);
printf("svec_sd_digits=%d,svec_sd_adders=%d\n",svec_sd_digits,svec_sd_adders);
[n_sd,d_sd]=schurNSPAlattice2tf(A1s20_sd,A1s00_sd,A1s02_sd,A1s22_sd, ...
                                A2s20_sd,A2s00_sd,A2s02_sd,A2s22_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find the optimised signed-digit lattice coefficients with siman
if use_best_siman_found
  svec_sasd_exact = [ -27.3193,  22.0324,  15.2835,  21.9687, ... 
                       21.7154, -23.2544,  21.2597,  21.7381, ... 
                      -22.8011,  28.1662, -22.7167,  21.1847, ... 
                       10.4959,  28.7083,  25.9146, -30.5472, ... 
                       26.3384,  20.0102,  11.7637,  24.4315 ]';
else
  ub=nshift*ones(length(svec_sd),1);
  lb=-ub;
  siman_opt=optimset("algorithm","siman","lbound",lb,"ubound",ub);
  svec_sasd_exact=[];
  [svec_sasd_exact,cost_sasd,conv_sasd,details_sasd] = ...
    nonlin_min("schurNSPAlattice_cost",svec_sd(:),siman_opt);
  if isempty(svec_sasd_exact)
    error("samin SD failed!");
  endif
  print_polynomial(svec_sasd_exact,"svec_sasd_exact","%8.4f");
endif
[cost_sasd, ...
 A1s20_sasd,A1s00_sasd,A1s02_sasd,A1s22_sasd, ...
 A2s20_sasd,A2s00_sasd,A2s02_sasd,A2s22_sasd, ...
 svec_sasd] = ...
  schurNSPAlattice_cost(svec_sasd_exact);
printf("cost_sasd=%8.5f\n",cost_sasd);
print_polynomial(svec_sasd,"svec_sasd","%3d");
[svec_sasd_digits,svec_sasd_adders]=SDadders(svec_sasd,nbits);
printf("svec_sasd_digits=%d,svec_sasd_adders=%d\n", ...
       svec_sasd_digits,svec_sasd_adders);
[n_sasd,d_sasd] = ...
  schurNSPAlattice2tf(A1s20_sasd,A1s00_sasd,A1s02_sasd,A1s22_sasd, ...
                      A2s20_sasd,A2s00_sasd,A2s02_sasd,A2s22_sasd);
h_sasd=freqz(n_sasd,d_sasd,nplot);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_sa)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_sasd)),"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
strt=sprintf("5th order elliptic NS PA lattice: nbits=%d,ndigits=%d",
             nbits,ndigits);
title(strt);
legend("exact","round","siman(round)","signed-digit","siman(s-d)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Passband response
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_sa)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_sasd)),"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 fpass*1.1 -3 3]);
title(strt);
legend("exact","round","siman(round)","signed-digit","siman(s-d)");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Save results
print_polynomial(A1s20_rd,"A1s20_rd","%9.6f");
print_polynomial(A1s00_rd,"A1s00_rd","%9.6f");
print_polynomial(A1s02_rd,"A1s02_rd","%9.6f");
print_polynomial(A1s22_rd,"A1s22_rd","%9.6f");
print_polynomial(A2s20_rd,"A2s20_rd","%9.6f");
print_polynomial(A2s00_rd,"A2s00_rd","%9.6f");
print_polynomial(A2s02_rd,"A2s02_rd","%9.6f");
print_polynomial(A2s22_rd,"A2s22_rd","%9.6f");
print_polynomial(A1s20_sa,"A1s20_sa","%9.6f");
print_polynomial(A1s00_sa,"A1s00_sa","%9.6f");
print_polynomial(A1s02_sa,"A1s02_sa","%9.6f");
print_polynomial(A1s22_sa,"A1s22_sa","%9.6f");
print_polynomial(A2s20_sa,"A2s20_sa","%9.6f");
print_polynomial(A2s00_sa,"A2s00_sa","%9.6f");
print_polynomial(A2s02_sa,"A2s02_sa","%9.6f");
print_polynomial(A2s22_sd,"A2s22_sd","%9.6f");
print_polynomial(A1s20_sd,"A1s20_sd","%9.6f");
print_polynomial(A1s00_sd,"A1s00_sd","%9.6f");
print_polynomial(A1s02_sd,"A1s02_sd","%9.6f");
print_polynomial(A1s22_sd,"A1s22_sd","%9.6f");
print_polynomial(A2s20_sd,"A2s20_sd","%9.6f");
print_polynomial(A2s00_sd,"A2s00_sd","%9.6f");
print_polynomial(A2s02_sd,"A2s02_sd","%9.6f");
print_polynomial(A2s22_sd,"A2s22_sd","%9.6f");
print_polynomial(A1s20_sasd,"A1s20_sasd","%9.6f");
print_polynomial(A1s00_sasd,"A1s00_sasd","%9.6f");
print_polynomial(A1s02_sasd,"A1s02_sasd","%9.6f");
print_polynomial(A1s22_sasd,"A1s22_sasd","%9.6f");
print_polynomial(A2s20_sasd,"A2s20_sasd","%9.6f");
print_polynomial(A2s00_sasd,"A2s00_sasd","%9.6f");
print_polynomial(A2s02_sasd,"A2s02_sasd","%9.6f");
print_polynomial(A2s22_sasd,"A2s22_sasd","%9.6f");
save samin_schurNSPAlattice_lowpass_test.mat ...
  A1s20_rd   A1s00_rd   A1s02_rd   A1s22_rd ...
  A2s20_rd   A2s00_rd   A2s02_rd   A2s22_rd ...
  A1s20_sa   A1s00_sa   A1s02_sa   A1s22_sa ... 
  A2s20_sa   A2s00_sa   A2s02_sa   A2s22_sa ...
  A1s20_sd   A1s00_sd   A1s02_sd   A1s22_sd ...
  A2s20_sd   A2s00_sd   A2s02_sd   A2s22_sd ...
  A1s20_sasd A1s00_sasd A1s02_sasd A1s22_sasd ...
  A2s20_sasd A2s00_sasd A2s02_sasd A2s22_sasd

% Done
diary off
movefile samin_schurNSPAlattice_lowpass_test.diary.tmp ...
         samin_schurNSPAlattice_lowpass_test.diary;
