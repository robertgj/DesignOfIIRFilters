% de_min_schurOneMPAlattice_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the differential evolution algorithm with coefficients of
% a 5th order elliptic filter implemented as the sum of two 
% all-pass lattice filters in one-multiplier form.
%
% Notes:
%  1. The de_min function from the OctaveForge optim package adds to the end of
%     the vector of coefficients being optimised!
%  2. Unfortunately de_min is not repeatable. The minimum cost found varies.
%  3. Change use_best_de_min_found to false to run de_min

test_common;

pkg load optim;

delete("de_min_schurOneMPAlattice_lowpass_test.diary");
delete("de_min_schurOneMPAlattice_lowpass_test.diary.tmp");
diary de_min_schurOneMPAlattice_lowpass_test.diary.tmp

truncation_test_common;

use_best_de_min_found=true
if use_best_de_min_found
  warning(["Using the best filter found so far. \n", ...
 "           Set \"use_best_de_min_found\"=false to re-run de_min."]);
endif

strf="de_min_schurOneMPAlattice_lowpass_test";

% Lattice decomposition
[Aap1,Aap2]=tf2pa(n0,d0);
[A1k0,A1epsilon0,A1p0,A1c0] = tf2schurOneMlattice(fliplr(Aap1),Aap1);
[A2k0,A2epsilon0,A2p0,A2c0] = tf2schurOneMlattice(fliplr(Aap2),Aap2);

% Find vector of exact lattice coefficients
difference=false;
max_cost=1e10;
[cost_ex,A1_ex,A2_ex,svec_ex] = ...
 schurOneMPAlattice_cost([],Ad,Wa,Td,Wt, ...
                         A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
                         difference,0,0,max_cost);
printf("cost_ex=%8.5f\n",cost_ex);

% Find the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
% Rounded truncation
[cost_rd,A1k_rd,A2k_rd,svec_rd] = ...
  schurOneMPAlattice_cost([],Ad,Wa,Td,Wt,A1k0,A1epsilon0,A1p0, ...
                          A2k0,A2epsilon0,A2p0,difference,nbits,0,max_cost);
printf("cost_rd=%8.5f\n",cost_rd);
[n_rd,d_rd]=schurOneMPAlattice2tf(A1k_rd,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_rd,A2epsilon0,ones(size(A2p0)));
h_rd=freqz(n_rd,d_rd,nplot);
% Find optimised rounded lattice coefficients with differential evolution
if use_best_de_min_found
  svec_de_exact = [ -26.0287,  20.2071, -24.9264,  29.0766, -19.0108 ];
else
  ctl.XVmax=nshift*ones(1,length(A1k0)+length(A2k0));
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
    de_min("schurOneMPAlattice_cost",ctl);
  if isempty(svec_de_exact)
    error("de_min failed!");
  endif
  print_polynomial(svec_de_exact,"svec_de_exact","%8.4f");
endif
[cost_de,A1k_de,A2k_de,svec_de]=schurOneMPAlattice_cost(svec_de_exact);
printf("cost_de=%8.5f\n",cost_de);
[n_de,d_de]=schurOneMPAlattice2tf(A1k_de,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_de,A2epsilon0,ones(size(A2p0)));
h_de=freqz(n_de,d_de,nplot);

% Signed-digit truncation
[cost_sd,A1k_sd,A2k_sd,svec_sd] = ...
  schurOneMPAlattice_cost([],Ad,Wa,Td,Wt,A1k0,A1epsilon0,A1p0, ...
                          A2k0,A2epsilon0,A2p0,difference, ...
                          nbits,ndigits,max_cost);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=schurOneMPAlattice2tf(A1k_sd,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_sd,A2epsilon0,ones(size(A2p0)));
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised signed-digit lattice coefficients with differential evolution
if use_best_de_min_found
  svec_desd_exact = [ -25.4525,  10.0295, -23.9623,  27.7382, -9.2640 ];
else
  [svec_desd_exact,cost_desd_exact,nfeval_desd,conv_desd] = ...
    de_min("schurOneMPAlattice_cost",ctl);
  if isempty(svec_desd_exact)
    error("de_min SD failed!");
  endif
  print_polynomial(svec_desd_exact,"svec_desd_exact","%8.4f");
endif
[cost_desd,A1k_desd,A2k_desd,svec_desd]=schurOneMPAlattice_cost(svec_desd_exact);
printf("cost_desd=%8.5f\n",cost_desd);
[n_desd,d_desd] = schurOneMPAlattice2tf(A1k_desd,A1epsilon0,ones(size(A1p0)), ...
                                        A2k_desd,A2epsilon0,ones(size(A2p0)));
h_desd=freqz(n_desd,d_desd,nplot);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_de)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_desd)),"linestyle","-")
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
strt=sprintf("5th order elliptic OneM PA lattice: nbits=%d,ndigits=%d", ...
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
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Results
print_polynomial(A1k_rd,"A1k_rd");
print_polynomial(A2k_rd,"A2k_rd");
print_polynomial(A1k_de,"A1k_de");
print_polynomial(A2k_de,"A2k_de");
print_polynomial(A1k_sd,"A1k_sd");
print_polynomial(A2k_sd,"A2k_sd");
print_polynomial(A1k_desd,"A1k_desd");
print_polynomial(A2k_desd,"A2k_desd");
save de_min_schurOneMPAlattice_lowpass_test.mat ...
     A1k_rd A2k_rd A1k_de A2k_de A1k_sd A2k_sd A1k_desd A2k_desd

% Done
diary off
movefile de_min_schurOneMPAlattice_lowpass_test.diary.tmp ...
         de_min_schurOneMPAlattice_lowpass_test.diary;
