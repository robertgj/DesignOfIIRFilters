% bitflip_schurNSPAlattice_lowpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for the bit-flipping algorithm with coefficents of
% a 5th order elliptic filter implemented as the sum of two 
% all-pass lattice filters in normalised-scaled form.

test_common;

delete("bitflip_schurNSPAlattice_lowpass_test.diary");
delete("bitflip_schurNSPAlattice_lowpass_test.diary.tmp");
diary bitflip_schurNSPAlattice_lowpass_test.diary.tmp

truncation_test_common;

strf="bitflip_schurNSPAlattice_lowpass_test";

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
% Find optimised lattice coefficients with bit-flipping
svec_bf=bitflip(@schurNSPAlattice_cost,svec_rd,nbits,bitstart,msize);
[cost_bf, ...
 A1s20_bf,A1s00_bf,A1s02_bf,A1s22_bf,A2s20_bf,A2s00_bf,A2s02_bf,A2s22_bf] = ...
schurNSPAlattice_cost(svec_bf);
printf("cost_bf=%8.5f\n",cost_bf);
[n_bf,d_bf]=schurNSPAlattice2tf(A1s20_bf,A1s00_bf,A1s02_bf,A1s22_bf, ...
                                A2s20_bf,A2s00_bf,A2s02_bf,A2s22_bf);
h_bf=freqz(n_bf,d_bf,nplot);
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
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsd=bitflip(@schurNSPAlattice_cost,svec_sd,nbits,bitstart,msize);
[cost_bfsd, ...
 A1s20_bfsd,A1s00_bfsd,A1s02_bfsd,A1s22_bfsd, ...
 A2s20_bfsd,A2s00_bfsd,A2s02_bfsd,A2s22_bfsd] = ...
  schurNSPAlattice_cost(svec_bfsd);
printf("cost_bfsd=%8.5f\n",cost_bfsd);
[n_bfsd,d_bfsd] = ...
  schurNSPAlattice2tf(A1s20_bfsd,A1s00_bfsd,A1s02_bfsd,A1s22_bfsd, ...
                      A2s20_bfsd,A2s00_bfsd,A2s02_bfsd,A2s22_bfsd);
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
strt=sprintf("5th order elliptic NS PA lattice: \
nbits=%d,bitstart=%d,msize=%d,ndigits=%d",nbits,bitstart,msize,ndigits);
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

% Results
print_polynomial(A1s20_bf,"A1s20_bf");
print_polynomial(A1s00_bf,"A1s00_bf");
print_polynomial(A1s02_bf,"A1s02_bf");
print_polynomial(A1s22_bf,"A1s22_bf");
print_polynomial(A2s20_bf,"A2s20_bf");
print_polynomial(A2s00_bf,"A2s00_bf");
print_polynomial(A2s02_bf,"A2s02_bf");
print_polynomial(A2s22_bf,"A2s22_bf");
print_polynomial(A1s20_bfsd,"A1s20_bfsd");
print_polynomial(A1s00_bfsd,"A1s00_bfsd");
print_polynomial(A1s02_bfsd,"A1s02_bfsd");
print_polynomial(A1s22_bfsd,"A1s22_bfsd");
print_polynomial(A2s20_bfsd,"A2s20_bfsd");
print_polynomial(A2s00_bfsd,"A2s00_bfsd");
print_polynomial(A2s02_bfsd,"A2s02_bfsd");
print_polynomial(A2s22_bfsd,"A2s22_bfsd");

save bitflip_schurNSPAlattice_lowpass_test.mat ...
     A1s20_rd A1s00_rd A1s02_rd A1s22_rd ...
     A2s20_rd A2s00_rd A2s02_rd A2s22_rd ...
     A1s20_bf A1s00_bf A1s02_bf A1s22_bf ...
     A2s20_bf A2s00_bf A2s02_bf A2s22_bf ...
     A1s20_sd A1s00_sd A1s02_sd A1s22_sd ...
     A2s20_sd A2s00_sd A2s02_sd A2s22_sd ...
     A1s20_bfsd A1s00_bfsd A1s02_bfsd A1s22_bfsd ...
     A2s20_bfsd A2s00_bfsd A2s02_bfsd A2s22_bfsd

% Done
diary off
movefile bitflip_schurNSPAlattice_lowpass_test.diary.tmp ...
         bitflip_schurNSPAlattice_lowpass_test.diary;