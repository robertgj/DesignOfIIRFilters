% bitflip_schurOneMlattice_lowpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for the bit-flipping algorithm with coefficents of
% a 5th order elliptic lattice filter in one multiplier form.

test_common;

delete("bitflip_schurOneMlattice_lowpass_test.diary");
delete("bitflip_schurOneMlattice_lowpass_test.diary.tmp");
diary bitflip_schurOneMlattice_lowpass_test.diary.tmp

truncation_test_common;

strf="bitflip_schurOneMlattice_lowpass_test";

% Lattice decomposition
[k0,epsilon0,p0,c0] = tf2schurOneMlattice(n0,d0);

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
% Find optimised lattice coefficients with bit-flipping
svec_bf=bitflip(@schurOneMlattice_cost,svec_rd,nbits,bitstart,msize);
[cost_bf,k_bf,c_bf]=schurOneMlattice_cost(svec_bf);
printf("cost_bf=%8.5f\n",cost_bf);
[n_bf,d_bf]=schurOneMlattice2tf(k_bf,epsilon0,ones(size(p0)),c_bf);
h_bf=freqz(n_bf,d_bf,nplot);
% Signed-digit truncation
[cost_sd,k_sd,c_sd,svec_sd] = ...
  schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=schurOneMlattice2tf(k_sd,epsilon0,ones(size(p0)),c_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsd=bitflip(@schurOneMlattice_cost,svec_sd,nbits,bitstart,msize);
[cost_bfsd,k_bfsd,c_bfsd]=schurOneMlattice_cost(svec_bfsd);
printf("cost_bfsd=%8.5f\n",cost_bfsd);
[n_bfsd,d_bfsd]=schurOneMlattice2tf(k_bfsd,epsilon0,ones(size(p0)),c_bfsd);
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
strt=sprintf("5th order elliptic OneM lattice: \
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
     wplot*0.5/pi,20*log10(abs(h_bfsd)),"linestyle","-")
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
print_polynomial(k_rd,"k_rd");
print_polynomial(c_rd,"c_rd");
print_polynomial(k_bf,"k_bf");
print_polynomial(c_bf,"c_bf");
print_polynomial(k_sd,"k_sd");
print_polynomial(c_sd,"c_sd");
print_polynomial(k_bfsd,"k_bfsd");
print_polynomial(c_bfsd,"c_bfsd");
save bitflip_schurOneMlattice_lowpass_test.mat ...
     k_rd c_rd k_bf c_bf k_sd c_sd k_bfsd c_bfsd

% Done
diary off
movefile bitflip_schurOneMlattice_lowpass_test.diary.tmp ...
         bitflip_schurOneMlattice_lowpass_test.diary;
