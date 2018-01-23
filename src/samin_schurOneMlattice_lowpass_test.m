% samin_schurOneMlattice_lowpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for the simulated annealing algorithm with coefficents of
% a 5th order elliptic lattice filter in one multiplier form.
%
% Notes:
%  1. The samin function from the OctaveForge optim package adds to the end of
%     the vector of coefficients being optimised!
%  2. Unfortunately samin is not repeatable. The minimum cost found varies.
%  3. Change use_best_samin_found to false to run samin

test_common;

unlink("samin_schurOneMlattice_lowpass_test.diary");
unlink("samin_schurOneMlattice_lowpass_test.diary.tmp");
diary samin_schurOneMlattice_lowpass_test.diary.tmp

truncation_test_common;

use_best_samin_found=true
if use_best_samin_found
  warning("Using the best filter found so far. \n\
           Set \"use_best_samin_found\"=false to re-run samin.");
endif

strf="samin_schurOneMlattice_lowpass_test";

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
% Find optimised rounded lattice coefficients with samin
if use_best_samin_found
  svec_sa_exact = [ -26,  30, -28,  24, -10,  1,  4, 20,  3,  3,  1 ]';
else
  % See /usr/local/share/octave/packages/optim-1.4.1/samin_example.m
  ub=nshift*ones(length(k0)+length(c0),1);
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
  [svec_sa_exact,cost_sa,conv,details_sa] = ...
    samin("schurOneMlattice_cost",{svec_rd(:)},control)
endif
[cost_sa,k_sa,c_sa,svec_sa]=schurOneMlattice_cost(svec_sa_exact);
printf("cost_sa=%8.5f\n",cost_sa);
[n_sa,d_sa]=schurOneMlattice2tf(k_sa,epsilon0,ones(size(p0)),c_sa);
h_sa=freqz(n_sa,d_sa,nplot);

% Signed-digit truncation
[cost_sd,k_sd,c_sd,svec_sd] = ...
   schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=schurOneMlattice2tf(k_sd,epsilon0,ones(size(p0)),c_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised signed-digit lattice coefficients with samin
if use_best_samin_found
  svec_sasd_exact = [  -24,  31, -28,  24,  -8,  0,  2,  20,  3,  4,  1 ]';
else
  [svec_sasd_exact,cost_sasd,conv,details_sasd] = ...
    samin("schurOneMlattice_cost",{svec_sd(:)},control)
endif
[cost_sasd,k_sasd,c_sasd,svec_sasd]=schurOneMlattice_cost(svec_sasd_exact);
printf("cost_sasd=%8.5f\n",cost_sasd);
[n_sasd,d_sasd]=schurOneMlattice2tf(k_sasd,epsilon0,ones(size(p0)),c_sasd);
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
strt=sprintf("5th order elliptic OneM lattice: nbits=%d,ndigits=%d",
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
     wplot*0.5/pi,20*log10(abs(h_sasd)),"linestyle","-")
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
print_polynomial(k_rd,"k_rd");
print_polynomial(c_rd,"c_rd");
print_polynomial(k_sa,"k_sa");
print_polynomial(c_sa,"c_sa");
print_polynomial(k_sd,"k_sd");
print_polynomial(c_sd,"c_sd");
print_polynomial(k_sasd,"k_sasd");
print_polynomial(c_sasd,"c_sasd");
save samin_schurOneMlattice_lowpass_test.mat ...
     k_rd c_rd k_sa c_sa k_sd c_sd k_sasd c_sasd

% Done
diary off
movefile samin_schurOneMlattice_lowpass_test.diary.tmp ...
         samin_schurOneMlattice_lowpass_test.diary;
