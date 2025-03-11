% simplex_schurOneMPAlattice_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the simplex algorithm with coefficients of
% a 5th order elliptic filter implemented as the sum of two 
% all-pass lattice filters in one-multiplier form.

test_common;

pkg load optim;

delete("simplex_schurOneMPAlattice_lowpass_test.diary");
delete("simplex_schurOneMPAlattice_lowpass_test.diary.tmp");
diary simplex_schurOneMPAlattice_lowpass_test.diary.tmp

truncation_test_common;

strf="simplex_schurOneMPAlattice_lowpass_test";

% Lattice decomposition
difference=false;
[Aap1,Aap2]=tf2pa(n0,d0);
[A1k0,A1epsilon0,A1p0,A1c0]=tf2schurOneMlattice(fliplr(Aap1),Aap1);
[A2k0,A2epsilon0,A2p0,A2c0]=tf2schurOneMlattice(fliplr(Aap2),Aap2);

% Find vector of exact lattice coefficients
[cost_ex,A1_ex,A2_ex,svec_ex] = ...
  schurOneMPAlattice_cost([],Ad,Wa,Td,Wt, ...
                          A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
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
% Find optimised lattice coefficients with the simplex algorithm
svec_sx=nelder_mead_min(@schurOneMPAlattice_cost,svec_rd);
[cost_sx,A1k_sx,A2k_sx]=schurOneMPAlattice_cost(svec_sx);
printf("cost_sx=%8.5f\n",cost_sx);
[n_sx,d_sx]=schurOneMPAlattice2tf(A1k_sx,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_sx,A2epsilon0,ones(size(A2p0)));
h_sx=freqz(n_sx,d_sx,nplot);
% Signed-digit truncation
[cost_sd,A1k_sd,A2k_sd,svec_sd] = ...
  schurOneMPAlattice_cost([],Ad,Wa,Td,Wt,A1k0,A1epsilon0,A1p0, ...
                          A2k0,A2epsilon0,A2p0,difference,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=schurOneMPAlattice2tf(A1k_sd,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_sd,A2epsilon0,ones(size(A2p0)));
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised lattice coefficients with simplex and signed-digits
svec_sxsd=nelder_mead_min(@schurOneMPAlattice_cost,svec_sd);
[cost_sxsd,A1k_sxsd,A2k_sxsd]=schurOneMPAlattice_cost(svec_sxsd);
printf("cost_sxsd=%8.5f\n",cost_sxsd);
[n_sxsd,d_sxsd] = ...
schurOneMPAlattice2tf(A1k_sxsd,A1epsilon0,ones(size(A1p0)), ...
                      A2k_sxsd,A2epsilon0,ones(size(A2p0)));
h_sxsd=freqz(n_sxsd,d_sxsd,nplot);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_sx)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_sxsd)),"linestyle","-")
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
strt=sprintf("5th order elliptic OneM PA lattice: nbits=%d,ndigits=%d", ...
             nbits,ndigits);
title(strt);
legend("exact","round","simplex(round)","signed-digit","simplex(s-d)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Passband response
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_sx)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_sxsd)),"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 fpass*1.1 -3 3]);
title(strt);
legend("exact","round","simplex(round)","signed-digit","simplex(s-d)");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Results
print_polynomial(A1k_rd,"A1k_rd");
print_polynomial(A2k_rd,"A2k_rd");
print_polynomial(A1k_sx,"A1k_sx");
print_polynomial(A2k_sx,"A2k_sx");
print_polynomial(A1k_sd,"A1k_sd");
print_polynomial(A2k_sd,"A2k_sd");
print_polynomial(A1k_sxsd,"A1k_sxsd");
print_polynomial(A2k_sxsd,"A2k_sxsd");
save simplex_schurOneMPAlattice_lowpass_test.mat ...
     A1k_rd A2k_rd A1k_sx A2k_sx A1k_sd A2k_sd A1k_sxsd A2k_sxsd

  % Done
diary off
movefile simplex_schurOneMPAlattice_lowpass_test.diary.tmp ...
         simplex_schurOneMPAlattice_lowpass_test.diary;
