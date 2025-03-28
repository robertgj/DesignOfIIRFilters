% simplex_schurNSPAlattice_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the simplex algorithm with coefficients of
% a 5th order elliptic filter implemented as the sum of two 
% all-pass lattice filters in normalised-scaled form.

test_common;

pkg load optim;

delete("simplex_schurNSPAlattice_lowpass_test.diary");
delete("simplex_schurNSPAlattice_lowpass_test.diary.tmp");
diary simplex_schurNSPAlattice_lowpass_test.diary.tmp

truncation_test_common;

strf="simplex_schurNSPAlattice_lowpass_test";

% Lattice decomposition
[Aap1_0,Aap2_0]=tf2pa(n0,d0);
[A1s10_0,A1s11_0,A1s20_0,A1s00_0,A1s02_0,A1s22_0]= ...
  tf2schurNSlattice(fliplr(Aap1_0),Aap1_0);
[A2s10_0,A2s11_0,A2s20_0,A2s00_0,A2s02_0,A2s22_0]= ...
  tf2schurNSlattice(fliplr(Aap2_0),Aap2_0);

% Find vector of exact lattice coefficients
use_symmetric_s=true;
[cost_ex, ...
 A1s20_ex,A1s00_ex,A1s02_ex,A1s22_ex,A2s20_ex,A2s00_ex,A2s02_ex,A2s22_ex, ...
 svec_ex] = ...
  schurNSPAlattice_cost([],Ad,Wa,Td,Wt, ...
                        A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
                        A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
                        use_symmetric_s,0,0);
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
                        use_symmetric_s,nbits,0);
printf("cost_rd=%8.5f\n",cost_rd);
[n_rd,d_rd]=schurNSPAlattice2tf(A1s20_rd,A1s00_rd,A1s02_rd,A1s22_rd, ...
                                A2s20_rd,A2s00_rd,A2s02_rd,A2s22_rd);
h_rd=freqz(n_rd,d_rd,nplot);
% Find optimised lattice coefficients with the simplex algorithm
svec_sx=nelder_mead_min(@schurNSPAlattice_cost,svec_rd);
[cost_sx, ...
 A1s20_sx,A1s00_sx,A1s02_sx,A1s22_sx,A2s20_sx,A2s00_sx,A2s02_sx,A2s22_sx] = ...
 schurNSPAlattice_cost(svec_sx);
printf("cost_sx=%8.5f\n",cost_sx);
[n_sx,d_sx]=schurNSPAlattice2tf(A1s20_sx,A1s00_sx,A1s02_sx,A1s22_sx, ...
                                A2s20_sx,A2s00_sx,A2s02_sx,A2s22_sx);
h_sx=freqz(n_sx,d_sx,nplot);
% Signed-digit truncation
use_symmetric_s=false;
[cost_sd, ...
 A1s20_sd,A1s00_sd,A1s02_sd,A1s22_sd, ...
 A2s20_sd,A2s00_sd,A2s02_sd,A2s22_sd, ...
 svec_sd] = ...
  schurNSPAlattice_cost([],Ad,Wa,Td,Wt, ...
                        A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
                        A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
                        use_symmetric_s,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=schurNSPAlattice2tf(A1s20_sd,A1s00_sd,A1s02_sd,A1s22_sd, ...
                                A2s20_sd,A2s00_sd,A2s02_sd,A2s22_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised lattice coefficients with simplex and signed-digits
svec_sxsd=nelder_mead_min(@schurNSPAlattice_cost,svec_sd);
[cost_sxsd, ...
 A1s20_sxsd,A1s00_sxsd,A1s02_sxsd,A1s22_sxsd, ...
 A2s20_sxsd,A2s00_sxsd,A2s02_sxsd,A2s22_sxsd] = ...
  schurNSPAlattice_cost(svec_sxsd);
printf("cost_sxsd=%8.5f\n",cost_sxsd);
[n_sxsd,d_sxsd] = ...
  schurNSPAlattice2tf(A1s20_sxsd,A1s00_sxsd,A1s02_sxsd,A1s22_sxsd, ...
                      A2s20_sxsd,A2s00_sxsd,A2s02_sxsd,A2s22_sxsd);
h_sxsd=freqz(n_sxsd,d_sxsd,nplot);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_sx)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_sxsd)),"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
strt=sprintf("5th order elliptic NS PA lattice,nbits=%d,ndigits=%d", ...
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
print_polynomial(A1s20_sx,"A1s20_sx");
print_polynomial(A1s00_sx,"A1s00_sx");
print_polynomial(A1s02_sx,"A1s02_sx");
print_polynomial(A1s22_sx,"A1s22_sx");
print_polynomial(A2s20_sx,"A2s20_sx");
print_polynomial(A2s00_sx,"A2s00_sx");
print_polynomial(A2s02_sx,"A2s02_sx");
print_polynomial(A2s22_sx,"A2s22_sx");
print_polynomial(A1s20_sxsd,"A1s20_sxsd");
print_polynomial(A1s00_sxsd,"A1s00_sxsd");
print_polynomial(A1s02_sxsd,"A1s02_sxsd");
print_polynomial(A1s22_sxsd,"A1s22_sxsd");
print_polynomial(A2s20_sxsd,"A2s20_sxsd");
print_polynomial(A2s00_sxsd,"A2s00_sxsd");
print_polynomial(A2s02_sxsd,"A2s02_sxsd");
print_polynomial(A2s22_sxsd,"A2s22_sxsd");
save simplex_schurNSPAlattice_lowpass_test.mat ...
     A1s20_rd A1s00_rd A1s02_rd A1s22_rd ...
     A2s20_rd A2s00_rd A2s02_rd A2s22_rd ...
     A1s20_sx A1s00_sx A1s02_sx A1s22_sx ...
     A2s20_sx A2s00_sx A2s02_sx A2s22_sx ...
     A1s20_sd A1s00_sd A1s02_sd A1s22_sd ...
     A2s20_sd A2s00_sd A2s02_sd A2s22_sd ...
     A1s20_sxsd A1s00_sxsd A1s02_sxsd A1s22_sxsd ...
     A2s20_sxsd A2s00_sxsd A2s02_sxsd A2s22_sxsd

% Done
diary off
movefile simplex_schurNSPAlattice_lowpass_test.diary.tmp ...
         simplex_schurNSPAlattice_lowpass_test.diary;
