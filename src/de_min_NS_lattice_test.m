% de_min_NS_lattice_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% Test case for the de_min differential evolution algorithm with coefficents
% of a 5th order elliptic lattice filter in normalised-scaled form.
%
% Notes:
%  1. The de_min function from the OctaveForge optim package adds to the end of
%     the vector of coefficients being optimised!
%  2. Unfortunately de_min is not repeatable. The minimum cost found varies.
%  3. Change use_best_de_min_found to false to run de_min

test_common;

unlink("de_min_NS_lattice_test.diary");
unlink("de_min_NS_lattice_test.diary.tmp");
diary de_min_NS_lattice_test.diary.tmp

truncation_test_common;

use_best_de_min_found=true
if use_best_de_min_found
  warning("Using the best filter found so far. \n\
           Set \"use_best_de_min_found\"=false to re-run de_min.");
endif

% Lattice decomposition
[s10_0,s11_0,s20_0,s00_0,s02_0,s22_0]=tf2schurNSlattice(n0,d0);

% Find vector of exact lattice coefficients
use_symmetric_s=true;
max_cost=1e10;
[cost_ex,s10_ex,s11_ex,s20_ex,s00_ex,s02_ex,s22_ex,svec_ex] = ...
  schurNSlattice_cost([],Ad,Wa,Td,Wt, ...
                      s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                      use_symmetric_s,0,0,max_cost);
printf("cost_ex=%8.5f\n",cost_ex);

% Find the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
% Rounded truncation
[cost_rd,s10_rd,s11_rd,s20_rd,s00_rd,s02_rd,s22_rd,svec_rd] = ...
  schurNSlattice_cost([],Ad,Wa,Td,Wt, ...
                      s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                      use_symmetric_s,nbits,0,max_cost);
printf("cost_rd=%8.5f\n",cost_rd);
[n_rd,d_rd]=schurNSlattice2tf(s10_rd,s11_rd,s20_rd,s00_rd,s02_rd,s22_rd);
h_rd=freqz(n_rd,d_rd,nplot);
% Find the optimised rounded lattice coefficients with de_min
if use_best_de_min_found
  svec_de_exact = [ -21, -28, -30, -17,  -1, -32, -32, -27, -31,  -7, ...
                    -17,  31, -31,  29, -19,  12, -17, -20, -12, -20]';
else
  ctl.XVmax=nshift*ones(1,4*length(s00_0));
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
    de_min("schurNSlattice_cost",ctl)
  if isempty(svec_de_exact)
    error("de_min failed!");
  endif
endif
[cost_de,s10_de,s11_de,s20_de,s00_de,s02_de,s22_de,svec_de] = ...
  schurNSlattice_cost(svec_de_exact);
printf("cost_de=%8.5f\n",cost_de);
[n_de,d_de]=schurNSlattice2tf(s10_de,s11_de,s20_de,s00_de,s02_de,s22_de);
h_de=freqz(n_de,d_de,nplot);

% Signed-digit truncation
use_symmetric_s=false;
[cost_sd,s10_sd,s11_sd,s20_sd,s00_sd,s02_sd,s22_sd,svec_sd] = ...
  schurNSlattice_cost([],Ad,Wa,Td,Wt, ...
                      s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                      use_symmetric_s,nbits,ndigits,max_cost);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=schurNSlattice2tf(s10_sd,s11_sd,s20_sd,s00_sd,s02_sd,s22_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find the optimised signed-digit lattice coefficients with de_min
if use_best_de_min_found
  svec_desd_exact = [  28,  16,  16,   8,   1,  -6, -32,  30,  24, -20, ...
                       24,  31, -32, -28,  -3, -28, -10,  15,  12, -16, ...
                       24,  20,  15, -24, -24,  24,  -4,  31,  12,  -1 ]';
else
  ctl.XVmax=nshift*ones(1,6*length(s00_0));
  ctl.XVmin=-ctl.XVmax;
  [svec_desd_exact,cost_desd_exact,nfeval_desd,conv_desd,] = ...
    de_min("schurNSlattice_cost",ctl)
  if isempty(svec_desd_exact)
    error("de_min SD failed!");
  endif
endif
[cost_desd,s10_desd,s11_desd,s20_desd,s00_desd,s02_desd,s22_desd,svec_desd] = ...
  schurNSlattice_cost(svec_desd_exact);
printf("cost_desd=%8.5f\n",cost_desd);
[n_desd,d_desd] = ...
  schurNSlattice2tf(s10_desd,s11_desd,s20_desd,s00_desd,s02_desd,s22_desd);
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
tstr=sprintf("5th order elliptic NS lattice: nbits=%d,ndigits=%d",nbits,ndigits);
title(tstr);
legend("exact","round","de\\_min(round)","signed-digit","de\\_min(s-d)");
legend("location","northeast");
legend("Boxoff");
legend("left");
grid("on");
print("de_min_NS_lattice_response","-dpdflatex");
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
print("de_min_NS_lattice_passband_response","-dpdflatex");
close

% Save results
print_polynomial(s10_rd,"s10_rd");
print_polynomial(s11_rd,"s11_rd");
print_polynomial(s20_rd,"s20_rd");
print_polynomial(s00_rd,"s00_rd");
print_polynomial(s02_rd,"s02_rd");
print_polynomial(s22_rd,"s22_rd");
print_polynomial(s10_de,"s10_de");
print_polynomial(s11_de,"s11_de");
print_polynomial(s20_de,"s20_de");
print_polynomial(s00_de,"s00_de");
print_polynomial(s02_de,"s02_de");
print_polynomial(s22_de,"s22_de");
print_polynomial(s10_sd,"s10_sd");
print_polynomial(s11_sd,"s11_sd");
print_polynomial(s20_sd,"s20_sd");
print_polynomial(s00_sd,"s00_sd");
print_polynomial(s02_sd,"s02_sd");
print_polynomial(s22_sd,"s22_sd");
print_polynomial(s10_desd,"s10_desd");
print_polynomial(s11_desd,"s11_desd");
print_polynomial(s20_desd,"s20_desd");
print_polynomial(s00_desd,"s00_desd");
print_polynomial(s02_desd,"s02_desd");
print_polynomial(s22_desd,"s22_desd");
save de_min_NS_lattice_test.mat ...
     s10_rd s11_rd s20_rd s00_rd s02_rd s22_rd ...
     s10_de s11_de s20_de s00_de s02_de s22_de ...
     s10_sd s11_sd s20_sd s00_sd s02_sd s22_sd ...
     s10_desd s11_desd s20_desd s00_desd s02_desd s22_desd

% Done
diary off
movefile de_min_NS_lattice_test.diary.tmp de_min_NS_lattice_test.diary;
