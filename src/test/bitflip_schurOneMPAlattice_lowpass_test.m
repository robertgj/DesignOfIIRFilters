% bitflip_schurOneMPAlattice_lowpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for the bit-flipping algorithm with coefficents of
% a 5th order elliptic filter implemented as the sum of two 
% all-pass lattice filters in one-multiplier form.

test_common;

delete("bitflip_schurOneMPAlattice_lowpass_test.diary");
delete("bitflip_schurOneMPAlattice_lowpass_test.diary.tmp");
diary bitflip_schurOneMPAlattice_lowpass_test.diary.tmp

truncation_test_common;

strf="bitflip_schurOneMPAlattice_lowpass_test";

% Lattice decomposition
difference=false;
[Aap1,Aap2]=tf2pa(n0,d0);
[A1k0,A1epsilon0,A1p0,A1c0] = tf2schurOneMlattice(fliplr(Aap1),Aap1);
[A2k0,A2epsilon0,A2p0,A2c0] = tf2schurOneMlattice(fliplr(Aap2),Aap2);

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
% Find optimised lattice coefficients with bit-flipping
svec_bf=bitflip(@schurOneMPAlattice_cost,svec_rd,nbits,bitstart,msize);
[cost_bf,A1k_bf,A2k_bf]=schurOneMPAlattice_cost(svec_bf);
printf("cost_bf=%8.5f\n",cost_bf);
[n_bf,d_bf]=schurOneMPAlattice2tf(A1k_bf,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_bf,A2epsilon0,ones(size(A2p0)));
h_bf=freqz(n_bf,d_bf,nplot);
% Signed-digit truncation
[cost_sd,A1k_sd,A2k_sd,svec_sd] = ...
  schurOneMPAlattice_cost([],Ad,Wa,Td,Wt,A1k0,A1epsilon0,A1p0, ...
                          A2k0,A2epsilon0,A2p0,difference,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=schurOneMPAlattice2tf(A1k_sd,A1epsilon0,ones(size(A1p0)), ...
                                  A2k_sd,A2epsilon0,ones(size(A2p0)));
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsd=bitflip(@schurOneMPAlattice_cost,svec_sd,nbits,bitstart,msize);
[cost_bfsd,A1k_bfsd,A2k_bfsd]=schurOneMPAlattice_cost(svec_bfsd);
printf("cost_bfsd=%8.5f\n",cost_bfsd);
[n_bfsd,d_bfsd]=schurOneMPAlattice2tf(A1k_bfsd,A1epsilon0,ones(size(A1p0)), ...
                                      A2k_bfsd,A2epsilon0,ones(size(A2p0)));
h_bfsd=freqz(n_bfsd,d_bfsd,nplot);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_bf)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_bfsd)),"linestyle","-")
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
strt=sprintf("5th order elliptic OneM PA lattice: \
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
print_polynomial(A1k_rd,"A1k_rd");
print_polynomial(A2k_rd,"A2k_rd");
print_polynomial(A1k_bf,"A1k_bf");
print_polynomial(A2k_bf,"A2k_bf");
print_polynomial(A1k_sd,"A1k_sd");
print_polynomial(A2k_sd,"A2k_sd");
print_polynomial(A1k_bfsd,"A1k_bfsd");
print_polynomial(A2k_bfsd,"A2k_bfsd");
save bitflip_schurOneMPAlattice_lowpass_test.mat ...
     A1k_rd A2k_rd A1k_bf A2k_bf A1k_sd A2k_sd A1k_bfsd A2k_bfsd

% Dome
diary off
movefile bitflip_schurOneMPAlattice_lowpass_test.diary.tmp ...
         bitflip_schurOneMPAlattice_lowpass_test.diary;
