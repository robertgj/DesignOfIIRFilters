% samin_schurOneMPAlattice_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the simulated annealing algorithm with coefficients of
% a 5th order elliptic filter implemented as the sum of two 
% all-pass lattice filters in one-multiplier form.
%
% Notes:
%  1. Unfortunately siman is not repeatable. The minimum cost found varies.
%  2. Change use_best_siman_found to false to run siman

test_common;

pkg load optim;

delete("samin_schurOneMPAlattice_lowpass_test.diary");
delete("samin_schurOneMPAlattice_lowpass_test.diary.tmp");
diary samin_schurOneMPAlattice_lowpass_test.diary.tmp

truncation_test_common;

use_best_siman_found=true
if use_best_siman_found
  warning("Using the best filter found so far. \n\
Set \"use_best_siman_found\"=false to re-run siman.");
endif

strf="samin_schurOneMPAlattice_lowpass_test";

% Lattice decomposition
difference=false;
[Aap1,Aap2]=tf2pa(n0,d0);
[A1k0,A1epsilon0,A1p0,A1c0] = tf2schurOneMlattice(fliplr(Aap1),Aap1);
[A2k0,A2epsilon0,A2p0,A2c0] = tf2schurOneMlattice(fliplr(Aap2),Aap2);

% Find vector of exact lattice coefficients
[cost_ex,A1_ex,A2_ex,svec_ex] = ...
  schurOneMPAlattice_cost([],Ad,Wa,Td,Wt, ...
                          A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0,...
                          difference,0,0);
printf("cost_ex=%8.5f\n",cost_ex);

% Find the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
% Rounded truncation
[cost_rd,A1k_rd,A2k_rd,svec_rd] = ...
  schurOneMPAlattice_cost([],Ad,Wa,Td,Wt,A1k0,A1epsilon0,A1p0, ...
                          A2k0,A2epsilon0,A2p0,difference,nbits,0);
printf("cost_rd=%8.5f\n",cost_rd);
[svec_rd_digits,svec_rd_adders]=SDadders(svec_rd,nbits);
printf("svec_rd_digits=%d,svec_rd_adders=%d\n",svec_rd_digits,svec_rd_adders);
[n_rd,d_rd]=schurOneMPAlattice2tf(A1k_rd,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_rd,A2epsilon0,ones(size(A2p0)));
h_rd=freqz(n_rd,d_rd,nplot);
% Find optimised rounded lattice coefficients with samin
if use_best_siman_found
  svec_sa_exact = [ -26.3028,  20.4907, -25.0999,  29.1703, -19.4704 ]';
else
  ub=nshift*ones(length(svec_rd),1);
  lb=-ub;
  siman_opt=optimset("algorithm","siman","lbound",lb,"ubound",ub);
  svec_sa_exact=[];
  [svec_sa_exact,cost_sa,conv,details_sa] = ...
    nonlin_min("schurOneMPAlattice_cost",svec_rd,siman_opt);
  print_polynomial(svec_sa_exact,"svec_sa_exact","%8.4f");
endif
[cost_sa,A1k_sa,A2k_sa,svec_sa]=schurOneMPAlattice_cost(svec_sa_exact);
printf("cost_sa=%8.5f\n",cost_sa);
print_polynomial(svec_sa,"svec_sa","%3d");
[svec_sa_digits,svec_sa_adders]=SDadders(svec_sa,nbits);
printf("svec_sa_digits=%d,svec_sa_adders=%d\n",svec_sa_digits,svec_sa_adders);
[n_sa,d_sa]=schurOneMPAlattice2tf(A1k_sa,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_sa,A2epsilon0,ones(size(A2p0)));
h_sa=freqz(n_sa,d_sa,nplot);

% Signed-digit truncation
[cost_sd,A1k_sd,A2k_sd,svec_sd] = ...
  schurOneMPAlattice_cost([],Ad,Wa,Td,Wt,A1k0,A1epsilon0,A1p0, ...
                          A2k0,A2epsilon0,A2p0,difference,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[svec_sd_digits,svec_sd_adders]=SDadders(svec_sd,nbits);
printf("svec_sd_digits=%d,svec_sd_adders=%d\n",svec_sd_digits,svec_sd_adders);
[n_sd,d_sd]=schurOneMPAlattice2tf(A1k_sd,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_sd,A2epsilon0,ones(size(A2p0)));
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised signed-digit lattice coefficients with samin
if use_best_siman_found
svec_sasd_exact = [ -26.5557,  20.5398, -23.1040,  29.5403, -20.2830 ]';
else
  ub=nshift*ones(length(svec_sd),1);
  lb=-ub;
  siman_opt=optimset("algorithm","siman","lbound",lb,"ubound",ub);
  svec_sasd_exact=[];
  [svec_sasd_exact,cost_sasd,conv,details_sasd] = ...
    nonlin_min("schurOneMPAlattice_cost",svec_sd,siman_opt);
  print_polynomial(svec_sasd_exact,"svec_sasd_exact","%8.4f");
endif
[cost_sasd,A1k_sasd,A2k_sasd,svec_sasd]=schurOneMPAlattice_cost(svec_sasd_exact);
printf("cost_sasd=%8.5f\n",cost_sasd);
print_polynomial(svec_sasd,"svec_sasd","%3d");
[svec_sasd_digits,svec_sasd_adders]=SDadders(svec_sasd,nbits);
printf("svec_sasd_digits=%d,svec_sasd_adders=%d\n", ...
       svec_sasd_digits,svec_sasd_adders);
[n_sasd,d_sasd] = schurOneMPAlattice2tf(A1k_sasd,A1epsilon0,ones(size(A1p0)), ...
                                        A2k_sasd,A2epsilon0,ones(size(A2p0)));
h_sasd=freqz(n_sasd,d_sasd,nplot);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_sa)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_sasd)),"linestyle","-")
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
strt=sprintf("5th order elliptic OneM PA lattice: nbits=%d,ndigits=%d",
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

% Results
print_polynomial(A1k_rd,"A1k_rd","%9.6f");
print_polynomial(A2k_rd,"A2k_rd","%9.6f");
print_polynomial(A1k_sa,"A1k_sa","%9.6f");
print_polynomial(A2k_sa,"A2k_sa","%9.6f");
print_polynomial(A1k_sd,"A1k_sd","%9.6f");
print_polynomial(A2k_sd,"A2k_sd","%9.6f");
print_polynomial(A1k_sasd,"A1k_sasd","%9.6f");
print_polynomial(A2k_sasd,"A2k_sasd","%9.6f");
save samin_schurOneMPAlattice_lowpass_test.mat ...
     A1k_rd A2k_rd A1k_sa A2k_sa A1k_sd A2k_sd A1k_sasd A2k_sasd

% Done
diary off
movefile samin_schurOneMPAlattice_lowpass_test.diary.tmp ...
         samin_schurOneMPAlattice_lowpass_test.diary;
