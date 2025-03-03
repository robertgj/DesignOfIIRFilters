% simplex_schurOneMlattice_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the simplex algorithm with coefficients of
% a 5th order elliptic lattice filter in one multiplier form.

test_common;

pkg load optim;

delete("simplex_schurOneMlattice_lowpass_test.diary");
delete("simplex_schurOneMlattice_lowpass_test.diary.tmp");
diary simplex_schurOneMlattice_lowpass_test.diary.tmp

truncation_test_common;

strf="simplex_schurOneMlattice_lowpass_test";

% Lattice decomposition
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(n0,d0);

% Find vector of exact lattice coefficients
[cost_ex,k_ex,c_ex,svec_ex] = ...
  schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,0,0);
printf("cost_ex=%8.5f\n",cost_ex);

% Find the responses for exact, rounded and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
% Rounded truncation
% Find vector of rounded lattice coefficients
[cost_rd,k_rd,c_rd,svec_rd] = ...
  schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,0);
printf("cost_rd=%8.5f\n",cost_rd);
[n_rd,d_rd]=schurOneMlattice2tf(k_rd,epsilon0,ones(size(p0)),c_rd);
h_rd=freqz(n_rd,d_rd,nplot);
% Find optimised lattice coefficients with the simplex algorithm
svec_sx=nelder_mead_min(@schurOneMlattice_cost,svec_rd);
[cost_sx,k_sx,c_sx]=schurOneMlattice_cost(svec_sx);
printf("cost_sx=%8.5f\n",cost_sx);
[n_sx,d_sx]=schurOneMlattice2tf(k_sx,epsilon0,ones(size(p0)),c_sx);
h_sx=freqz(n_sx,d_sx,nplot);
% Signed-digit truncation
[cost_sd,k_sd,c_sd,svec_sd] = ...
   schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=schurOneMlattice2tf(k_sd,epsilon0,ones(size(p0)),c_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised lattice coefficients with simplex and signed-digits
svec_sxsd=nelder_mead_min(@schurOneMlattice_cost,svec_sd);
[cost_sxsd,k_sxsd,c_sxsd]=schurOneMlattice_cost(svec_sxsd);
printf("cost_sxsd=%8.5f\n",cost_sxsd);
[n_sxsd,d_sxsd]=schurOneMlattice2tf(k_sxsd,epsilon0,ones(size(p0)),c_sxsd);
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
strt=sprintf("5th order elliptic OneM lattice: nbits=%d,ndigits=%d",
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
     wplot*0.5/pi,20*log10(abs(h_sxsd)),"linestyle","-")
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
print_polynomial(k_rd,"k_rd");
print_polynomial(c_rd,"c_rd");
print_polynomial(k_sx,"k_sx");
print_polynomial(c_sx,"c_sx");
print_polynomial(k_sd,"k_sd");
print_polynomial(c_sd,"c_sd");
print_polynomial(k_sxsd,"k_sxsd");
print_polynomial(c_sxsd,"c_sxsd");
save simplex_schurOneMlattice_lowpass_test.mat ...
     k_rd c_rd k_sx c_sx k_sd c_sd k_sxsd c_sxsd

% Done
diary off
movefile simplex_schurOneMlattice_lowpass_test.diary.tmp ...
         simplex_schurOneMlattice_lowpass_test.diary;
