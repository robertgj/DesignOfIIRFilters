% samin_schurNSlattice_lowpass_test.m
% Copyright (C) 2017-2021 Robert G. Jenssen
%
% Test case for the simulated annealing algorithm with coefficents of
% a 5th order elliptic lattice filter in normalised-scaled form.
%
% Notes:
%  1. Unfortunately samin is not repeatable. The minimum cost found varies.
%  2. Change use_best_samin_found to false to run samin

test_common;

delete("samin_schurNSlattice_lowpass_test.diary");
delete("samin_schurNSlattice_lowpass_test.diary.tmp");
diary samin_schurNSlattice_lowpass_test.diary.tmp

truncation_test_common;

use_best_samin_found=true
if use_best_samin_found
  warning("Using the best filter found so far. \n\
Set \"use_best_samin_found\"=false to re-run samin.");
endif

strf="samin_schurNSlattice_lowpass_test";

% Lattice decomposition
[s10_0,s11_0,s20_0,s00_0,s02_0,s22_0]=tf2schurNSlattice(n0,d0);

% Find vector of exact lattice coefficients
use_symmetric_s=true;
[cost_ex,s10_ex,s11_ex,s20_ex,s00_ex,s02_ex,s22_ex,svec_ex] = ...
  schurNSlattice_cost([],Ad,Wa,Td,Wt, ...
                      s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                      use_symmetric_s,0,0);
printf("cost_ex=%8.5f\n",cost_ex);

% Find the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
% Rounded truncation
[cost_rd,s10_rd,s11_rd,s20_rd,s00_rd,s02_rd,s22_rd,svec_rd] = ...
  schurNSlattice_cost([],Ad,Wa,Td,Wt, ...
                      s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                      use_symmetric_s,nbits,0);
printf("cost_rd=%8.5f\n",cost_rd);
[svec_rd_digits,svec_rd_adders]=SDadders(svec_rd,nbits);
printf("svec_rd_digits=%d,svec_rd_adders=%d\n",svec_rd_digits,svec_rd_adders);
[n_rd,d_rd]=schurNSlattice2tf(s10_rd,s11_rd,s20_rd,s00_rd,s02_rd,s22_rd);
h_rd=freqz(n_rd,d_rd,nplot);
% Find the optimised rounded lattice coefficients with samin
if use_best_samin_found
  svec_sa_exact = [  25,  28,  13,   6, ... 
                      1, -19,  31,  22, ... 
                     23,  21, -26,  30, ... 
                    -32,  22, -15,  23, ... 
                      7,  17,  16,  21 ]';
else
  ub=nshift*ones(length(svec_rd),1);
  lb=-ub;
  samin_opt=optimset("Display","iter", "Algorithm","samin", "MaxIter",1000, ...
                     "TolX",max(ub-lb), "lbound",lb,"ubound",ub);
  svec_sa_exact=[];
  [svec_sa_exact,cost_sa,conv_sa,details_sa] = ...
    nonlin_min("schurNSlattice_cost",svec_rd(:),samin_opt);
  if isempty(svec_sa_exact)
    error("samin failed!");
  endif
endif
[cost_sa,s10_sa,s11_sa,s20_sa,s00_sa,s02_sa,s22_sa,svec_sa] = ...
  schurNSlattice_cost(svec_sa_exact);
printf("cost_sa=%8.5f\n",cost_sa);
print_polynomial(svec_sa,"svec_sa","%3d");
[svec_sa_digits,svec_sa_adders]=SDadders(svec_sa,nbits);
printf("svec_sa_digits=%d,svec_sa_adders=%d\n",svec_sa_digits,svec_sa_adders);
[n_sa,d_sa]=schurNSlattice2tf(s10_sa,s11_sa,s20_sa,s00_sa,s02_sa,s22_sa);
h_sa=freqz(n_sa,d_sa,nplot);

% Signed-digit truncation
use_symmetric_s=false;
[cost_sd,s10_sd,s11_sd,s20_sd,s00_sd,s02_sd,s22_sd,svec_sd] = ...
  schurNSlattice_cost([],Ad,Wa,Td,Wt, ...
                      s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                      use_symmetric_s,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[svec_sd_digits,svec_sd_adders]=SDadders(svec_sd,nbits);
printf("svec_sd_digits=%d,svec_sd_adders=%d\n",svec_sd_digits,svec_sd_adders);
[n_sd,d_sd]=schurNSlattice2tf(s10_sd,s11_sd,s20_sd,s00_sd,s02_sd,s22_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find the optimised signed-digit lattice coefficients with samin
if use_best_samin_found
  svec_sasd_exact = [  28,  17,   6,   1, ... 
                        0,  20,  28,  28, ... 
                       18,  14, -24,  30, ... 
                      -28,  28, -24,  17, ... 
                        9,  20,  14,  28, ... 
                       24, -30,  31, -24, ... 
                       17,  24,   6,  12, ... 
                       12, -10 ]';
else
  ub=nshift*ones(length(svec_sd),1);
  lb=-ub;
  samin_opt=optimset("Display","iter", "Algorithm","samin", "MaxIter",1000, ...
                     "TolX",max(ub-lb), "lbound",lb,"ubound",ub);
  svec_sasd_exact=[];
  [svec_sasd_exact,cost_sasd,conv_sasd,details_sasd] = ...
    nonlin_min("schurNSlattice_cost",svec_sd(:),samin_opt);
  if isempty(svec_sasd_exact)
    error("samin SD failed!");
  endif
endif
[cost_sasd,s10_sasd,s11_sasd,s20_sasd,s00_sasd,s02_sasd,s22_sasd,svec_sasd] = ...
  schurNSlattice_cost(svec_sasd_exact);
printf("cost_sasd=%8.5f\n",cost_sasd);
print_polynomial(svec_sasd,"svec_sasd","%3d");
[svec_sasd_digits,svec_sasd_adders]=SDadders(svec_sasd,nbits);
printf("svec_sasd_digits=%d,svec_sasd_adders=%d\n", ...
       svec_sasd_digits,svec_sasd_adders);
[n_sasd,d_sasd] = ...
  schurNSlattice2tf(s10_sasd,s11_sasd,s20_sasd,s00_sasd,s02_sasd,s22_sasd);
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
strt=sprintf("5th order elliptic NS lattice: nbits=%d,ndigits=%d",nbits,ndigits);
title(strt);
legend("exact","round","samin(round)","signed-digit","samin(s-d)");
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
legend("exact","round","samin(round)","signed-digit","samin(s-d)");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Save results
print_polynomial(s10_rd,"s10_rd","%9.6f");
print_polynomial(s11_rd,"s11_rd","%9.6f");
print_polynomial(s20_rd,"s20_rd","%9.6f");
print_polynomial(s00_rd,"s00_rd","%9.6f");
print_polynomial(s02_rd,"s02_rd","%9.6f");
print_polynomial(s22_rd,"s22_rd","%9.6f");
print_polynomial(s10_sa,"s10_sa","%9.6f");
print_polynomial(s11_sa,"s11_sa","%9.6f");
print_polynomial(s20_sa,"s20_sa","%9.6f");
print_polynomial(s00_sa,"s00_sa","%9.6f");
print_polynomial(s02_sa,"s02_sa","%9.6f");
print_polynomial(s22_sa,"s22_sa","%9.6f");
print_polynomial(s10_sd,"s10_sd","%9.6f");
print_polynomial(s11_sd,"s11_sd","%9.6f");
print_polynomial(s20_sd,"s20_sd","%9.6f");
print_polynomial(s00_sd,"s00_sd","%9.6f");
print_polynomial(s02_sd,"s02_sd","%9.6f");
print_polynomial(s22_sd,"s22_sd","%9.6f");
print_polynomial(s10_sasd,"s10_sasd","%9.6f");
print_polynomial(s11_sasd,"s11_sasd","%9.6f");
print_polynomial(s20_sasd,"s20_sasd","%9.6f");
print_polynomial(s00_sasd,"s00_sasd","%9.6f");
print_polynomial(s02_sasd,"s02_sasd","%9.6f");
print_polynomial(s22_sasd,"s22_sasd","%9.6f");
save samin_schurNSlattice_lowpass_test.mat ...
     s10_rd s11_rd s20_rd s00_rd s02_rd s22_rd ...
     s10_sa s11_sa s20_sa s00_sa s02_sa s22_sa ...
     s10_sd s11_sd s20_sd s00_sd s02_sd s22_sd ...
     s10_sasd s11_sasd s20_sasd s00_sasd s02_sasd s22_sasd

% Done
diary off
movefile samin_schurNSlattice_lowpass_test.diary.tmp ...
         samin_schurNSlattice_lowpass_test.diary;
