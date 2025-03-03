% samin_schurOneMlattice_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the simulated annealing algorithm with coefficients of
% a 5th order elliptic lattice filter in one multiplier form.
%
% Notes:
%  1. Unfortunately the siman algorithm is not repeatable.
%     The minimum cost found varies.
%  2. Change use_best_siman_found to false to run siman

test_common;

pkg load optim;

delete("samin_schurOneMlattice_lowpass_test.diary");
delete("samin_schurOneMlattice_lowpass_test.diary.tmp");
diary samin_schurOneMlattice_lowpass_test.diary.tmp

truncation_test_common;

use_best_siman_found=true
if use_best_siman_found
  warning("Using the best filter found so far. \n\
Set \"use_best_siman_found\"=false to re-run siman.");
endif

strf="samin_schurOneMlattice_lowpass_test";

% Lattice decomposition
[k0,epsilon0,p0,c0] = tf2schurOneMlattice(n0,d0);

% Find vector of exact lattice coefficients
[cost_ex,k_ex,c_ex,svec_ex] = ...
  schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,0,0);
printf("cost_ex=%8.5f\n",cost_ex);

% Find the responses for exact, rounded and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
% Rounded truncation
% Find vector of rounded lattice coefficients
[cost_rd,k_rd,c_rd,svec_rd] = ...
  schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,0);
printf("cost_rd=%8.5f\n",cost_rd);
[svec_rd_digits,svec_rd_adders]=SDadders(svec_rd,nbits);
printf("svec_rd_digits=%d,svec_rd_adders=%d\n",svec_rd_digits,svec_rd_adders);
[n_rd,d_rd]=schurOneMlattice2tf(k_rd,epsilon0,ones(size(p0)),c_rd);
h_rd=freqz(n_rd,d_rd,nplot);
% Find optimised rounded lattice coefficients with samin
if use_best_siman_found
  svec_sa_exact = [ -24.4980,  31.3441, -27.5855,  26.0357, ... 
                    -14.6749,   1.8947,   3.0174,  20.5365, ... 
                      2.8491,   3.9006,   1.1337 ]';
else
  ub=nshift*ones(length(svec_rd),1);
  lb=-ub;
  siman_opt=optimset("algorithm","siman","lbound",lb,"ubound",ub);
  svec_sa_exact=[];
  [svec_sa_exact,cost_sa,conv,details_sa] = ...
    nonlin_min("schurOneMlattice_cost",svec_rd(:),siman_opt);
  print_polynomial(svec_sa_exact,"svec_sa_exact","%8.4f");
endif
[cost_sa,k_sa,c_sa,svec_sa]=schurOneMlattice_cost(svec_sa_exact);
printf("cost_sa=%8.5f\n",cost_sa);
print_polynomial(svec_sa,"svec_sa","%3d");
[svec_sa_digits,svec_sa_adders]=SDadders(svec_sa,nbits);
printf("svec_sa_digits=%d,svec_sa_adders=%d\n",svec_sa_digits,svec_sa_adders);
[n_sa,d_sa]=schurOneMlattice2tf(k_sa,epsilon0,ones(size(p0)),c_sa);
h_sa=freqz(n_sa,d_sa,nplot);

% Signed-digit truncation
[cost_sd,k_sd,c_sd,svec_sd] = ...
   schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[svec_sd_digits,svec_sd_adders]=SDadders(svec_sd,nbits);
printf("svec_sd_digits=%d,svec_sd_adders=%d\n", ...
       svec_sd_digits,svec_sd_adders);
[n_sd,d_sd]=schurOneMlattice2tf(k_sd,epsilon0,ones(size(p0)),c_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised signed-digit lattice coefficients with samin
if use_best_siman_found
  svec_sasd_exact = [ -25.6539,  30.9578, -28.1478,  23.3156, ... 
                      -11.1031,   1.9848,   3.0024,  21.5298, ... 
                        3.4376,   4.3894,   1.1791 ]';
else
  ub=nshift*ones(length(svec_sd),1);
  lb=-ub;
  siman_opt=optimset("algorithm","siman","lbound",lb,"ubound",ub);
  svec_sasd_exact=[];
  [svec_sasd_exact,cost_sasd,conv,details_sasd] = ...
    nonlin_min("schurOneMlattice_cost",svec_rd(:),siman_opt);
  print_polynomial(svec_sasd_exact,"svec_sasd_exact","%8.4f");
endif
[cost_sasd,k_sasd,c_sasd,svec_sasd]=schurOneMlattice_cost(svec_sasd_exact);
printf("cost_sasd=%8.5f\n",cost_sasd);
print_polynomial(svec_sasd,"svec_sasd","%3d");
[svec_sasd_digits,svec_sasd_adders]=SDadders(svec_sasd,nbits);
printf("svec_sasd_digits=%d,svec_sasd_adders=%d\n", ...
       svec_sasd_digits,svec_sasd_adders);
[n_sasd,d_sasd]=schurOneMlattice2tf(k_sasd,epsilon0,ones(size(p0)),c_sasd);
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
strt=sprintf("5th order elliptic OneM lattice: nbits=%d,ndigits=%d",
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
     wplot*0.5/pi,20*log10(abs(h_sasd)),"linestyle","-")
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
print_polynomial(k_rd,"k_rd","%9.6f");
print_polynomial(c_rd,"c_rd","%9.6f");
print_polynomial(k_sa,"k_sa","%9.6f");
print_polynomial(c_sa,"c_sa","%9.6f");
print_polynomial(k_sd,"k_sd","%9.6f");
print_polynomial(c_sd,"c_sd","%9.6f");
print_polynomial(k_sasd,"k_sasd","%9.6f");
print_polynomial(c_sasd,"c_sasd","%9.6f");
save samin_schurOneMlattice_lowpass_test.mat ...
     k_rd c_rd k_sa c_sa k_sd c_sd k_sasd c_sasd

% Done
diary off
movefile samin_schurOneMlattice_lowpass_test.diary.tmp ...
         samin_schurOneMlattice_lowpass_test.diary;
