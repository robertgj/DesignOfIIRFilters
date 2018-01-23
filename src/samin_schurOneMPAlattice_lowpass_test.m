% samin_schurOneMPAlattice_lowpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for the simulated annealing algorithm with coefficents of
% a 5th order elliptic filter implemented as the sum of two 
% all-pass lattice filters in one-multiplier form.
%
% Notes:
%  1. The samin function from the OctaveForge optim package adds to the end of
%     the vector of coefficients being optimised!
%  2. Unfortunately samin is not repeatable. The minimum cost found varies.
%  3. Change use_best_samin_found to false to run samin

test_common;

unlink("samin_schurOneMPAlattice_lowpass_test.diary");
unlink("samin_schurOneMPAlattice_lowpass_test.diary.tmp");
diary samin_schurOneMPAlattice_lowpass_test.diary.tmp

truncation_test_common;

use_best_samin_found=true
if use_best_samin_found
  warning("Using the best filter found so far. \n\
           Set \"use_best_samin_found\"=false to re-run samin.");
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
[n_rd,d_rd]=schurOneMPAlattice2tf(A1k_rd,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_rd,A2epsilon0,ones(size(A2p0)));
h_rd=freqz(n_rd,d_rd,nplot);
% Find optimised rounded lattice coefficients with samin
if use_best_samin_found
  svec_sa_exact = [ -2.60569127155080e+01,   2.00946980173253e+01, ...
                    -2.46011294624484e+01,   2.91906097596826e+01, ...
                    -1.92632659232837e+01 ]';
else
  % See /usr/local/share/octave/packages/optim-1.4.1/samin_example.m or similar
  ub=nshift*ones(length(A1k0)+length(A2k0),1);
  lb=-ub;
  nt=20;
  ns=5;
  rt=0.5;
  maxevals=1e4;
  neps=5;
  functol=1e-3;
  paramtol=1e-3;
  verbosity=2;
  minarg=1;
  control={lb,ub,nt,ns,rt,maxevals,neps,functol,paramtol,verbosity,minarg};
  [svec_sa_exact,cost_sa,conv,details_sa] = ...
  samin("schurOneMPAlattice_cost",{svec_rd},control)
endif
[cost_sa,A1k_sa,A2k_sa,svec_sa]=schurOneMPAlattice_cost(svec_sa_exact);
printf("cost_sa=%8.5f\n",cost_sa);
[n_sa,d_sa]=schurOneMPAlattice2tf(A1k_sa,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_sa,A2epsilon0,ones(size(A2p0)));
h_sa=freqz(n_sa,d_sa,nplot);

% Signed-digit truncation
[cost_sd,A1k_sd,A2k_sd,svec_sd] = ...
  schurOneMPAlattice_cost([],Ad,Wa,Td,Wt,A1k0,A1epsilon0,A1p0, ...
                          A2k0,A2epsilon0,A2p0,difference,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=schurOneMPAlattice2tf(A1k_sd,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_sd,A2epsilon0,ones(size(A2p0)));
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised signed-digit lattice coefficients with samin
if use_best_samin_found
  svec_sasd_exact = [ -2.41469063970995e+01,   1.01809732736584e+01, ...
                      -2.19166945219831e+01,   2.73571329511950e+01, ...
                      -9.49504948491203e+00 ]';

else
  [svec_sasd_exact,cost_sasd,conv,details_sasd] = ...
    samin("schurOneMPAlattice_cost",{svec_sd},control)
endif
[cost_sasd,A1k_sasd,A2k_sasd,svec_sasd]=schurOneMPAlattice_cost(svec_sasd_exact);
printf("cost_sasd=%8.5f\n",cost_sasd);
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

% Results
print_polynomial(A1k_rd,"A1k_rd");
print_polynomial(A2k_rd,"A2k_rd");
print_polynomial(A1k_sa,"A1k_sa");
print_polynomial(A2k_sa,"A2k_sa");
print_polynomial(A1k_sd,"A1k_sd");
print_polynomial(A2k_sd,"A2k_sd");
print_polynomial(A1k_sasd,"A1k_sasd");
print_polynomial(A2k_sasd,"A2k_sasd");
save samin_schurOneMPAlattice_lowpass_test.mat ...
     A1k_rd A2k_rd A1k_sa A2k_sa A1k_sd A2k_sd A1k_sasd A2k_sasd

% Done
diary off
movefile samin_schurOneMPAlattice_lowpass_test.diary.tmp ...
         samin_schurOneMPAlattice_lowpass_test.diary;
