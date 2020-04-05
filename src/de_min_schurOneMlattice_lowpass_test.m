% de_min_schurOneMlattice_lowpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for the de_min differential evolution algorithm with coefficents
% of a 5th order elliptic lattice filter in one multiplier form.
%
% Notes:
%  1. The de_min function from the OctaveForge optim package adds to the end of
%     the vector of coefficients being optimised!
%  2. Unfortunately de_min is not repeatable. The minimum cost found varies.
%  3. Change use_best_de_min_found to false to run de_min

test_common;

delete("de_min_schurOneMlattice_lowpass_test.diary");
delete("de_min_schurOneMlattice_lowpass_test.diary.tmp");
diary de_min_schurOneMlattice_lowpass_test.diary.tmp

truncation_test_common;

use_best_de_min_found=true
if use_best_de_min_found
  warning("Using the best filter found so far. \n\
           Set \"use_best_de_min_found\"=false to re-run de_min.");
endif

strf="de_min_schurOneMlattice_lowpass_test";

% Lattice decomposition
[k0,epsilon0,p0,c0] = tf2schurOneMlattice(n0,d0);

% Find vector of exact lattice coefficients
max_cost=1e10;
[cost_ex,k_ex,c_ex,svec_ex] = ...
  schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,0,0,max_cost);
printf("cost_ex=%8.5f\n",cost_ex);

% Find the responses for exact, rounded and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
% Rounded truncation
% Find vector of rounded lattice coefficients
[cost_rd,k_rd,c_rd,svec_rd] = ...
  schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,0,max_cost);
printf("cost_rd=%8.5f\n",cost_rd);
[n_rd,d_rd]=schurOneMlattice2tf(k_rd,epsilon0,ones(size(p0)),c_rd);
h_rd=freqz(n_rd,d_rd,nplot);
% Find optimised rounded lattice coefficients with de_min
if use_best_de_min_found
  svec_de_exact = [ -7, -18,  29, -26,  14,   3,   6,   5,  15,   2,   1 ]';
else
  ctl.XVmax=nshift*ones(1,length(k0)+length(c0));
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
    de_min("schurOneMlattice_cost",ctl)
  if isempty(svec_de_exact)
    error("de_min failed!");
  endif
endif
[cost_de,k_de,c_de,svec_de]=schurOneMlattice_cost(svec_de_exact);
printf("cost_de=%8.5f\n",cost_de);
[n_de,d_de]=schurOneMlattice2tf(k_de,epsilon0,ones(size(p0)),c_de);
h_de=freqz(n_de,d_de,nplot);

% Signed-digit truncation
[cost_sd,k_sd,c_sd,svec_sd] = ...
  schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,ndigits,max_cost);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=schurOneMlattice2tf(k_sd,epsilon0,ones(size(p0)),c_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised signed-digit lattice coefficients with de_min
if use_best_de_min_found
  svec_desd_exact = [ -24,  12,  24, -24,  10,   5,   5,   6,  14,   2,   1 ]';
else
  [svec_desd_exact,cost_desd_exact,nfeval_desd,conv_desd] = ...
    de_min("schurOneMlattice_cost",ctl)
  if isempty(svec_desd_exact)
    error("de_min SD failed!");
  endif
endif
[cost_desd,k_desd,c_desd,svec_desd]=schurOneMlattice_cost(svec_desd_exact);
printf("cost_desd=%8.5f\n",cost_desd);
[n_desd,d_desd]=schurOneMlattice2tf(k_desd,epsilon0,ones(size(p0)),c_desd);
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
strt=sprintf("5th order elliptic OneM lattice: nbits=%d,ndigits=%d",
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
     wplot*0.5/pi,20*log10(abs(h_desd)),"linestyle","-")
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
print_polynomial(k_rd,"k_rd");
print_polynomial(c_rd,"c_rd");
print_polynomial(k_de,"k_de");
print_polynomial(c_de,"c_de");
print_polynomial(k_sd,"k_sd");
print_polynomial(c_sd,"c_sd");
print_polynomial(k_desd,"k_desd");
print_polynomial(c_desd,"c_desd");
save de_min_schurOneMlattice_lowpass_test.mat ...
     k_rd c_rd k_de c_de k_sd c_sd k_desd c_desd

% Done
diary off
movefile de_min_schurOneMlattice_lowpass_test.diary.tmp ...
         de_min_schurOneMlattice_lowpass_test.diary;
