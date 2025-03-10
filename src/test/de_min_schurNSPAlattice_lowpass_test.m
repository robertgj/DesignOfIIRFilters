% de_min_schurNSPAlattice_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the de_min differential evolution algorithm with
% coefficients of a 5th order elliptic filter implemented as the sum of two 
% all-pass lattice filters in normalised-scaled form.
%
% Notes:
%  1. The de_min function from the OctaveForge optim package adds to the end of
%     the vector of coefficients being optimised!
%  2. Unfortunately de_min is not repeatable. The minimum cost found varies.
%  3. Change use_best_de_min_found to false to run de_min

test_common;

pkg load optim;

delete("de_min_schurNSPAlattice_lowpass_test.diary");
delete("de_min_schurNSPAlattice_lowpass_test.diary.tmp");
diary de_min_schurNSPAlattice_lowpass_test.diary.tmp

truncation_test_common;

use_best_de_min_found=true
if use_best_de_min_found
  warning(["Using the best filter found so far. ", ...
 "Set \"use_best_de_min_found\"=false to re-run de_min."]);
endif

strf="de_min_schurNSPAlattice_lowpass_test";

% Lattice decomposition
[Aap1_0,Aap2_0]=tf2pa(n0,d0);
[A1s10_0,A1s11_0,A1s20_0,A1s00_0,A1s02_0,A1s22_0]= ...
  tf2schurNSlattice(fliplr(Aap1_0),Aap1_0);
[A2s10_0,A2s11_0,A2s20_0,A2s00_0,A2s02_0,A2s22_0]= ...
  tf2schurNSlattice(fliplr(Aap2_0),Aap2_0);

% Find vector of exact lattice coefficients
use_symmetric_s=true;
max_cost=1e10;
[cost_ex, ...
 A1s20_ex,A1s00_ex,A1s02_ex,A1s22_ex,A2s20_ex,A2s00_ex,A2s02_ex,A2s22_ex, ...
 svec_ex] = ...
  schurNSPAlattice_cost([],Ad,Wa,Td,Wt, ...
                        A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
                        A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
                        use_symmetric_s,0,0,max_cost);
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
                        use_symmetric_s,nbits,0,max_cost);
printf("cost_rd=%8.5f\n",cost_rd);
[n_rd,d_rd]=schurNSPAlattice2tf(A1s20_rd,A1s00_rd,A1s02_rd,A1s22_rd, ...
                                A2s20_rd,A2s00_rd,A2s02_rd,A2s22_rd);
h_rd=freqz(n_rd,d_rd,nplot);
% Find the optimised rounded lattice coefficients with de_min
if use_best_de_min_found
  svec_de_exact = [ -25.2712,  23.2046, -17.6551,  25.0189, ... 
                    -25.2220,  27.9835, -22.1059, -20.9353, ... 
                     12.1287,  25.8890,   6.4542,  24.5570, ... 
                      8.8134,  14.7333, -22.4383,  30.2752, ... 
                      7.8040,   5.1957,  27.8437,  27.8779 ];
else
  ctl.XVmax=nshift*ones(1,4*(length(A1s00_0)+length(A2s00_0)));
  ctl.XVmin=-ctl.XVmax;
  ctl.NP=10*length(ctl.XVmax);
  ctl.constr=1;
  ctl.const=[];
  ctl.F=0.8;
  ctl.CR=0.9;
  ctl.strategy=12;
  ctl.refresh=10;
  ctl.VTR=-inf;
  ctl.tol=1e-3;
  ctl.maxnfe=1e6;
  ctl.maxiter=1e3;
  [svec_de_exact,cost_de_exact,nfeval_de,conv_de] = ...
    de_min("schurNSPAlattice_cost",ctl);
  if isempty(svec_de_exact)
    error("de_min failed!");
  endif
  print_polynomial(svec_de_exact,"svec_de_exact","%8.4f");
endif
[cost_de, ...
 A1s20_de,A1s00_de,A1s02_de,A1s22_de, ...
 A2s20_de,A2s00_de,A2s02_de,A2s22_de, ...
 svec_de] = ...
 schurNSPAlattice_cost(svec_de_exact);
printf("cost_de=%8.5f\n",cost_de);
[n_de,d_de]=schurNSPAlattice2tf(A1s20_de,A1s00_de,A1s02_de,A1s22_de, ...
                                A2s20_de,A2s00_de,A2s02_de,A2s22_de);
h_de=freqz(n_de,d_de,nplot);

% Signed-digit truncation
use_symmetric_s=false;
[cost_sd, ...
 A1s20_sd,A1s00_sd,A1s02_sd,A1s22_sd, ...
 A2s20_sd,A2s00_sd,A2s02_sd,A2s22_sd, ...
 svec_sd] = ...
  schurNSPAlattice_cost([],Ad,Wa,Td,Wt, ...
                        A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
                        A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
                        use_symmetric_s,nbits,ndigits,max_cost);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=schurNSPAlattice2tf(A1s20_sd,A1s00_sd,A1s02_sd,A1s22_sd, ...
                                A2s20_sd,A2s00_sd,A2s02_sd,A2s22_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find the optimised signed-digit lattice coefficients with de_min
if use_best_de_min_found
  svec_desd_exact = [ -28.4187,  17.3534,  25.2958, -12.0658, ... 
                       25.6123, -30.6279,  24.5852, -25.9757, ... 
                      -11.5191, -31.1691, -14.6264, -27.1050, ... 
                       27.9830, -21.7968,  10.3016, -26.3685, ... 
                      -28.4865, -15.8532,  15.1140,  21.0790, ... 
                        4.5483,  22.0502,  24.8622,  -2.2563, ... 
                       29.8233,   5.8455,  18.2155,  21.2676, ... 
                       -7.4929,   0.4276 ];
else
  ctl.XVmax=nshift*ones(1,6*(length(A1s00_0)+length(A2s00_0)));
  ctl.XVmin=-ctl.XVmax;
  ctl.NP=10*length(ctl.XVmax);
  [svec_desd_exact,cost_desd_exact,nfeval_desd,conv_desd] = ...
    de_min("schurNSPAlattice_cost",ctl);
  if isempty(svec_desd_exact)
    error("de_min SD failed!");
  endif
 print_polynomial(svec_desd_exact,"svec_desd_exact","%8.4f");
endif
[cost_desd, ...
 A1s20_desd,A1s00_desd,A1s02_desd,A1s22_desd, ...
 A2s20_desd,A2s00_desd,A2s02_desd,A2s22_desd, ...
 svec_desd] = ...
  schurNSPAlattice_cost(svec_desd_exact);
printf("cost_desd=%8.5f\n",cost_desd);
[n_desd,d_desd] = ...
  schurNSPAlattice2tf(A1s20_desd,A1s00_desd,A1s02_desd,A1s22_desd, ...
                      A2s20_desd,A2s00_desd,A2s02_desd,A2s22_desd);
h_desd=freqz(n_desd,d_desd,nplot);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_de)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_desd)),"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
strt=sprintf("5th order elliptic NS PA lattice: nbits=%d,ndigits=%d",
             nbits,ndigits);
title(strt);
legend("exact","round","de\\_min(round)","signed-digit","de\\_min(s-d)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Passband response
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_de)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_desd)),"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 fpass*1.1 -3 3]);
title(strt);
legend("exact","round","de\\_min(round)","signed-digit","de\\_min(s-d)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Save results
print_polynomial(A1s20_rd,"A1s20_rd");
print_polynomial(A1s00_rd,"A1s00_rd");
print_polynomial(A1s02_rd,"A1s02_rd");
print_polynomial(A1s22_rd,"A1s22_rd");
print_polynomial(A2s20_rd,"A2s20_rd");
print_polynomial(A2s00_rd,"A2s00_rd");
print_polynomial(A2s02_rd,"A2s02_rd");
print_polynomial(A2s22_rd,"A2s22_rd");
print_polynomial(A1s20_de,"A1s20_de");
print_polynomial(A1s00_de,"A1s00_de");
print_polynomial(A1s02_de,"A1s02_de");
print_polynomial(A1s22_de,"A1s22_de");
print_polynomial(A2s20_de,"A2s20_de");
print_polynomial(A2s00_de,"A2s00_de");
print_polynomial(A2s02_de,"A2s02_de");
print_polynomial(A2s22_sd,"A2s22_sd");
print_polynomial(A1s20_sd,"A1s20_sd");
print_polynomial(A1s00_sd,"A1s00_sd");
print_polynomial(A1s02_sd,"A1s02_sd");
print_polynomial(A1s22_sd,"A1s22_sd");
print_polynomial(A2s20_sd,"A2s20_sd");
print_polynomial(A2s00_sd,"A2s00_sd");
print_polynomial(A2s02_sd,"A2s02_sd");
print_polynomial(A2s22_sd,"A2s22_sd");
print_polynomial(A1s20_desd,"A1s20_desd");
print_polynomial(A1s00_desd,"A1s00_desd");
print_polynomial(A1s02_desd,"A1s02_desd");
print_polynomial(A1s22_desd,"A1s22_desd");
print_polynomial(A2s20_desd,"A2s20_desd");
print_polynomial(A2s00_desd,"A2s00_desd");
print_polynomial(A2s02_desd,"A2s02_desd");
print_polynomial(A2s22_desd,"A2s22_desd");
save de_min_schurNSPAlattice_lowpass_test.mat ...
  A1s20_rd   A1s00_rd   A1s02_rd   A1s22_rd ...
  A2s20_rd   A2s00_rd   A2s02_rd   A2s22_rd ...
  A1s20_de   A1s00_de   A1s02_de   A1s22_de ... 
  A2s20_de   A2s00_de   A2s02_de   A2s22_de ...
  A1s20_sd   A1s00_sd   A1s02_sd   A1s22_sd ...
  A2s20_sd   A2s00_sd   A2s02_sd   A2s22_sd ...
  A1s20_desd A1s00_desd A1s02_desd A1s22_desd ...
  A2s20_desd A2s00_desd A2s02_desd A2s22_desd

% Done
diary off
movefile de_min_schurNSPAlattice_lowpass_test.diary.tmp ...
         de_min_schurNSPAlattice_lowpass_test.diary;
