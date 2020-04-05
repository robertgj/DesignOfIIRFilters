% simplex_schurNSlattice_lowpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for the simplex algorithm with coefficents of
% a 5th order elliptic lattice filter in normalised-scaled form.

test_common;

delete("simplex_schurNSlattice_lowpass_test.diary");
delete("simplex_schurNSlattice_lowpass_test.diary.tmp");
diary simplex_schurNSlattice_lowpass_test.diary.tmp

truncation_test_common;

strf="simplex_schurNSlattice_lowpass_test";

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
[n_rd,d_rd]=schurNSlattice2tf(s10_rd,s11_rd,s20_rd,s00_rd,s02_rd,s22_rd);
h_rd=freqz(n_rd,d_rd,nplot);
% Find optimised lattice coefficients with the simplex algorithm
svec_sx=nelder_mead_min(@schurNSlattice_cost,svec_rd);
[cost_sx,s10_sx,s11_sx,s20_sx,s00_sx,s02_sx,s22_sx]=...
  schurNSlattice_cost(svec_sx);
printf("cost_sx=%8.5f\n",cost_sx);
[n_sx,d_sx]=schurNSlattice2tf(s10_sx,s11_sx,s20_sx,s00_sx,s02_sx,s22_sx);
h_sx=freqz(n_sx,d_sx,nplot);
% Signed-digit truncation
use_symmetric_s=false;
[cost_sd,s10_sd,s11_sd,s20_sd,s00_sd,s02_sd,s22_sd,svec_sd] = ...
  schurNSlattice_cost([],Ad,Wa,Td,Wt, ...
                      s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                      use_symmetric_s,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=schurNSlattice2tf(s10_sd,s11_sd,s20_sd,s00_sd,s02_sd,s22_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised lattice coefficients with simplex and signed-digits
svec_sxsd=nelder_mead_min(@schurNSlattice_cost,svec_sd);
[cost_sxsd,s10_sxsd,s11_sxsd,s20_sxsd,s00_sxsd,s02_sxsd,s22_sxsd] = ...
  schurNSlattice_cost(svec_sxsd);
printf("cost_sxsd=%8.5f\n",cost_sxsd);
[n_sxsd,d_sxsd] = ...
  schurNSlattice2tf(s10_sxsd,s11_sxsd,s20_sxsd,s00_sxsd,s02_sxsd,s22_sxsd);
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
strt=sprintf("5th order elliptic NS lattice: nbits=%d,ndigits=%d",nbits,ndigits);
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

% Save results
print_polynomial(s10_rd,"s10_rd");
print_polynomial(s11_rd,"s11_rd");
print_polynomial(s20_rd,"s20_rd");
print_polynomial(s00_rd,"s00_rd");
print_polynomial(s02_rd,"s02_rd");
print_polynomial(s22_rd,"s22_rd");
print_polynomial(s10_sx,"s10_sx");
print_polynomial(s11_sx,"s11_sx");
print_polynomial(s20_sx,"s20_sx");
print_polynomial(s00_sx,"s00_sx");
print_polynomial(s02_sx,"s02_sx");
print_polynomial(s22_sx,"s22_sx");
print_polynomial(s10_sd,"s10_sd");
print_polynomial(s11_sd,"s11_sd");
print_polynomial(s20_sd,"s20_sd");
print_polynomial(s00_sd,"s00_sd");
print_polynomial(s02_sd,"s02_sd");
print_polynomial(s22_sd,"s22_sd");
print_polynomial(s10_sxsd,"s10_sxsd");
print_polynomial(s11_sxsd,"s11_sxsd");
print_polynomial(s20_sxsd,"s20_sxsd");
print_polynomial(s00_sxsd,"s00_sxsd");
print_polynomial(s02_sxsd,"s02_sxsd");
print_polynomial(s22_sxsd,"s22_sxsd");
save simplex_schurNSlattice_lowpass_test.mat ...
     s10_rd s11_rd s20_rd s00_rd s02_rd s22_rd ...
     s10_sx s11_sx s20_sx s00_sx s02_sx s22_sx ...
     s10_sd s11_sd s20_sd s00_sd s02_sd s22_sd ...
     s10_sxsd s11_sxsd s20_sxsd s00_sxsd s02_sxsd s22_sxsd

% Done
diary off
movefile simplex_schurNSlattice_lowpass_test.diary.tmp ...
         simplex_schurNSlattice_lowpass_test.diary;
