% bitflip_schurNSlattice_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the bit-flipping algorithm with coefficients of
% a 5th order elliptic lattice filter in normalised-scaled form.

test_common;

delete("bitflip_schurNSlattice_lowpass_test.diary");
delete("bitflip_schurNSlattice_lowpass_test.diary.tmp");
diary bitflip_schurNSlattice_lowpass_test.diary.tmp

truncation_test_common;

strf="bitflip_schurNSlattice_lowpass_test";

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
% Find optimised lattice coefficients with bit-flipping
svec_bf=bitflip(@schurNSlattice_cost,svec_rd,nbits,bitstart,msize);
[cost_bf,s10_bf,s11_bf,s20_bf,s00_bf,s02_bf,s22_bf]=schurNSlattice_cost(svec_bf);
printf("cost_bf=%8.5f\n",cost_bf);
[n_bf,d_bf]=schurNSlattice2tf(s10_bf,s11_bf,s20_bf,s00_bf,s02_bf,s22_bf);
h_bf=freqz(n_bf,d_bf,nplot);
% Signed-digit truncation
use_symmetric_s=false;
[cost_sd,s10_sd,s11_sd,s20_sd,s00_sd,s02_sd,s22_sd,svec_sd] = ...
  schurNSlattice_cost([],Ad,Wa,Td,Wt, ...
                      s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                      use_symmetric_s,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=schurNSlattice2tf(s10_sd,s11_sd,s20_sd,s00_sd,s02_sd,s22_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsd=bitflip(@schurNSlattice_cost,svec_sd,nbits,bitstart,msize);
[cost_bfsd,s10_bfsd,s11_bfsd,s20_bfsd,s00_bfsd,s02_bfsd,s22_bfsd] = ...
  schurNSlattice_cost(svec_bfsd);
printf("cost_bfsd=%8.5f\n",cost_bfsd);
[n_bfsd,d_bfsd] = ...
  schurNSlattice2tf(s10_bfsd,s11_bfsd,s20_bfsd,s00_bfsd,s02_bfsd,s22_bfsd);
h_bfsd=freqz(n_bfsd,d_bfsd,nplot);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_bf)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_bfsd)),"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
strt=sprintf(["5th order elliptic NS lattice: ", ...
 "nbits=%d,bitstart=%d,msize=%d,ndigits=%d"],nbits,bitstart,msize,ndigits);
title(strt);
legend("exact","round","bitflip(round)","signed-digit","bitflip(s-d)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Passband response
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_bf)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_bfsd)),"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 fpass*1.1 -3 3]);
title(strt);
legend("exact","round","bitflip(round)","signed-digit","bitflip(s-d)");
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
print_polynomial(s10_bf,"s10_bf");
print_polynomial(s11_bf,"s11_bf");
print_polynomial(s20_bf,"s20_bf");
print_polynomial(s00_bf,"s00_bf");
print_polynomial(s02_bf,"s02_bf");
print_polynomial(s22_bf,"s22_bf");
print_polynomial(s10_sd,"s10_sd");
print_polynomial(s11_sd,"s11_sd");
print_polynomial(s20_sd,"s20_sd");
print_polynomial(s00_sd,"s00_sd");
print_polynomial(s02_sd,"s02_sd");
print_polynomial(s22_sd,"s22_sd");
print_polynomial(s10_bfsd,"s10_bfsd");
print_polynomial(s11_bfsd,"s11_bfsd");
print_polynomial(s20_bfsd,"s20_bfsd");
print_polynomial(s00_bfsd,"s00_bfsd");
print_polynomial(s02_bfsd,"s02_bfsd");
print_polynomial(s22_bfsd,"s22_bfsd");
save bitflip_schurNSlattice_lowpass_test.mat ...
     s10_rd s11_rd s20_rd s00_rd s02_rd s22_rd ...
     s10_bf s11_bf s20_bf s00_bf s02_bf s22_bf ...
     s10_sd s11_sd s20_sd s00_sd s02_sd s22_sd ...
     s10_bfsd s11_bfsd s20_bfsd s00_bfsd s02_bfsd s22_bfsd

% Done
diary off
movefile bitflip_schurNSlattice_lowpass_test.diary.tmp ...
         bitflip_schurNSlattice_lowpass_test.diary;
