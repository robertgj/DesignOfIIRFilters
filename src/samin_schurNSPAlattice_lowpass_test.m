% samin_schurNSPAlattice_lowpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for the samin algorithm with coefficents of
% a 5th order elliptic filter implemented as the sum of two 
% all-pass lattice filters in normalised-scaled form.
%
% Notes:
%  1. The samin function from the OctaveForge optim package adds to the end of
%     the vector of coefficients being optimised!
%  2. Unfortunately samin is not repeatable. The minimum cost found varies.
%  3. Change use_best_samin_found to false to run samin

test_common;

delete("samin_schurNSPAlattice_lowpass_test.diary");
delete("samin_schurNSPAlattice_lowpass_test.diary.tmp");
diary samin_schurNSPAlattice_lowpass_test.diary.tmp

truncation_test_common;

use_best_samin_found=true
if use_best_samin_found
  warning("Using the best filter found so far. \
Set \"use_best_samin_found\"=false to re-run samin.");
endif

strf="samin_schurNSPAlattice_lowpass_test";

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
% Find the optimised rounded lattice coefficients with samin
if use_best_samin_found
  svec_sa_exact = [ -27,  23,  18,  22, -24,  31, -22, -20,  12,  23 ]';
else
  % See /usr/local/share/octave/packages/optim-1.4.1/samin_example.m 
  ub=nshift*ones(4*(length(A1s00_0)+length(A2s00_0)),1);
  lb=-ub;
  nt=20;
  ns=5;
  rt=0.5;
  maxevals=2e4;
  neps=5;
  functol=1e-3;
  paramtol=1e-3;
  verbosity=2;
  minarg=1;
  control={lb,ub,nt,ns,rt,maxevals,neps,functol,paramtol,verbosity,minarg};
  svec_sa_exact=[];
  [svec_sa_exact,cost_sa,conv_sa,details_sa] = ...
    samin("schurNSPAlattice_cost",{svec_rd(:)},control)
  if isempty(svec_sa_exact)
    error("samin failed!");
  endif
endif
[cost_sa, ...
 A1s20_sa,A1s00_sa,A1s02_sa,A1s22_sa, ...
 A2s20_sa,A2s00_sa,A2s02_sa,A2s22_sa, ...
 svec_sa] = ...
 schurNSPAlattice_cost(svec_sa_exact);
printf("cost_sa=%8.5f\n",cost_sa);
[n_sa,d_sa]=schurNSPAlattice2tf(A1s20_sa,A1s00_sa,A1s02_sa,A1s22_sa, ...
                                A2s20_sa,A2s00_sa,A2s02_sa,A2s22_sa);
h_sa=freqz(n_sa,d_sa,nplot);

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
% Find the optimised signed-digit lattice coefficients with samin
if use_best_samin_found
  svec_sasd_exact = [ -16,  24, ...
                       16,  30, ...
                       28, -32, ...
                       14,  28, ...
                      -24,  24, -24, ...
                       24,  10,  32, ...
                       28, -28,  24, ...
                       18,  16,  20 ]';
else
  ub=nshift*ones(6*(length(A1s00_0)+length(A2s00_0)),1);
  lb=-ub;
  maxevals=4e4;
  control={lb,ub,nt,ns,rt,maxevals,neps,functol,paramtol,verbosity,minarg};
  svec_sasd_exact=[];
  [svec_sasd_exact,cost_sasd,conv_sasd,details_sasd] = ...
    samin("schurNSPAlattice_cost",{svec_sd(:)},control)
  if isempty(svec_sasd_exact)
    error("samin SD failed!");
  endif
endif
[cost_sasd, ...
 A1s20_sasd,A1s00_sasd,A1s02_sasd,A1s22_sasd, ...
 A2s20_sasd,A2s00_sasd,A2s02_sasd,A2s22_sasd, ...
 svec_sasd] = ...
  schurNSPAlattice_cost(svec_sasd_exact);
printf("cost_sasd=%8.5f\n",cost_sasd);
[n_sasd,d_sasd] = ...
  schurNSPAlattice2tf(A1s20_sasd,A1s00_sasd,A1s02_sasd,A1s22_sasd, ...
                      A2s20_sasd,A2s00_sasd,A2s02_sasd,A2s22_sasd);
h_sasd=freqz(n_sasd,d_sasd,nplot);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_sa)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_sasd)),"linestyle","-");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
strt=sprintf("5th order elliptic NS PA lattice: nbits=%d,ndigits=%d",
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

% Save results
print_polynomial(A1s20_rd,"A1s20_rd");
print_polynomial(A1s00_rd,"A1s00_rd");
print_polynomial(A1s02_rd,"A1s02_rd");
print_polynomial(A1s22_rd,"A1s22_rd");
print_polynomial(A2s20_rd,"A2s20_rd");
print_polynomial(A2s00_rd,"A2s00_rd");
print_polynomial(A2s02_rd,"A2s02_rd");
print_polynomial(A2s22_rd,"A2s22_rd");
print_polynomial(A1s20_sa,"A1s20_sa");
print_polynomial(A1s00_sa,"A1s00_sa");
print_polynomial(A1s02_sa,"A1s02_sa");
print_polynomial(A1s22_sa,"A1s22_sa");
print_polynomial(A2s20_sa,"A2s20_sa");
print_polynomial(A2s00_sa,"A2s00_sa");
print_polynomial(A2s02_sa,"A2s02_sa");
print_polynomial(A2s22_sd,"A2s22_sd");
print_polynomial(A1s20_sd,"A1s20_sd");
print_polynomial(A1s00_sd,"A1s00_sd");
print_polynomial(A1s02_sd,"A1s02_sd");
print_polynomial(A1s22_sd,"A1s22_sd");
print_polynomial(A2s20_sd,"A2s20_sd");
print_polynomial(A2s00_sd,"A2s00_sd");
print_polynomial(A2s02_sd,"A2s02_sd");
print_polynomial(A2s22_sd,"A2s22_sd");
print_polynomial(A1s20_sasd,"A1s20_sasd");
print_polynomial(A1s00_sasd,"A1s00_sasd");
print_polynomial(A1s02_sasd,"A1s02_sasd");
print_polynomial(A1s22_sasd,"A1s22_sasd");
print_polynomial(A2s20_sasd,"A2s20_sasd");
print_polynomial(A2s00_sasd,"A2s00_sasd");
print_polynomial(A2s02_sasd,"A2s02_sasd");
print_polynomial(A2s22_sasd,"A2s22_sasd");
save samin_schurNSPAlattice_lowpass_test.mat ...
  A1s20_rd   A1s00_rd   A1s02_rd   A1s22_rd ...
  A2s20_rd   A2s00_rd   A2s02_rd   A2s22_rd ...
  A1s20_sa   A1s00_sa   A1s02_sa   A1s22_sa ... 
  A2s20_sa   A2s00_sa   A2s02_sa   A2s22_sa ...
  A1s20_sd   A1s00_sd   A1s02_sd   A1s22_sd ...
  A2s20_sd   A2s00_sd   A2s02_sd   A2s22_sd ...
  A1s20_sasd A1s00_sasd A1s02_sasd A1s22_sasd ...
  A2s20_sasd A2s00_sasd A2s02_sasd A2s22_sasd

% Done
diary off
movefile samin_schurNSPAlattice_lowpass_test.diary.tmp ...
         samin_schurNSPAlattice_lowpass_test.diary;
