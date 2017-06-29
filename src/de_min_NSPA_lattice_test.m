% de_min_NSPA_lattice_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% Test case for the de_min differential evolution algorithm with
% coefficents of a 5th order elliptic filter implemented as the sum of two 
% all-pass lattice filters in normalised-scaled form.
%
% Notes:
%  1. The de_min function from the OctaveForge optim package adds to the end of
%     the vector of coefficients being optimised!
%  2. Unfortunately de_min is not repeatable. The minimum cost found varies.
%  3. Change use_best_de_min_found to false to run de_min

test_common;

unlink("de_min_NSPA_lattice_test.diary");
unlink("de_min_NSPA_lattice_test.diary.tmp");
diary de_min_NSPA_lattice_test.diary.tmp

truncation_test_common;

use_best_de_min_found=true
if use_best_de_min_found
  warning("Using the best filter found so far. \
Set \"use_best_de_min_found\"=false to re-run de_min.");
endif

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
  svec_de_exact = [ -27,  23, -16, -24, -28,  27, -23, -24, -10,  25 ]';
else
  ctl.XVmax=nshift*ones(1,4*(length(A1s00_0)+length(A2s00_0)));
  ctl.XVmin=-ctl.XVmax;
  ctl.constr=1;
  ctl.const=[];
  ctl.NP=0;
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
  svec_desd_exact = [  31,  10, -24, -28,  28,  24,  32,   8, -12,  28, ...
                       -7, -18,  12,  20,  12, -20,  31, -30, -24,  28 ]';
else
  ctl.XVmax=nshift*ones(1,6*(length(A1s00_0)+length(A2s00_0)));
  ctl.XVmin=-ctl.XVmax;
  [svec_desd_exact,cost_desd_exact,nfeval_desd,conv_desd] = ...
    de_min("schurNSPAlattice_cost",ctl);
  if isempty(svec_desd_exact)
    error("de_min SD failed!");
  endif
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
tstr=sprintf("5th order elliptic NS PA lattice: nbits=%d,ndigits=%d",
             nbits,ndigits);
title(tstr);
legend("exact","round","de\\_min(round)","signed-digit","de\\_min(s-d)");
legend("location","northeast");
legend("Boxoff");
legend("left");
grid("on");
print("de_min_NSPA_lattice_response","-dpdflatex");
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
title(tstr);
legend("exact","round","de\\_min(round)","signed-digit","de\\_min(s-d)");
legend("location","northwest");
legend("Boxoff");
legend("left");
grid("on");
print("de_min_NSPA_lattice_passband_response","-dpdflatex");
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
save de_min_NSPA_lattice_test.mat ...
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
movefile de_min_NSPA_lattice_test.diary.tmp de_min_NSPA_lattice_test.diary;
