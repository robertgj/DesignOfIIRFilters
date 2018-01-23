% samin_svcasc_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% Test case for the simulated-annealing samin algorithm with coefficents of a
% 5th order elliptic filter implemented as a cascade of 2nd order state variable
% sections.
%
% Notes:
%  1. The samin function from the OctaveForge optim package adds to the end of
%     the vector of coefficients being optimised!
%  2. Unfortunately samin is not repeatable. The minimum cost found varies.
%  3. Change use_best_samin_found to false to run samin

test_common;

unlink("samin_svcasc_test.diary");
unlink("samin_svcasc_test.diary.tmp");
diary samin_svcasc_test.diary.tmp

truncation_test_common;

use_best_samin_found=true
if use_best_samin_found
  warning("Using the best filter found so far. \
Set \"use_best_samin_found\"=false to re-run samin.");
endif

% Second order cascade state variable decomposition
[sos,g]=tf2sos(n0,d0);
[dd_0,p1,p2,q1,q2]=sos2pq(sos,g);
[a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0]=pq2svcasc(p1,p2,q1,q2,"minimum");
if mod(norder,2)
  [a11_0(end),a12_0(end),a21_0(end),a22_0(end),b1_0(end),b2_0(end), ...
   c1_0(end),c2_0(end)]=pq2svcasc(p1(end),p2(end),q1(end),q2(end),"direct");
endif

% Find vector of exact coefficients
[cost_ex,a11_ex,a12_ex,a21_ex,a22_ex,b1_ex,b2_ex,c1_ex,c2_ex,dd_ex,svec_ex] = ...
svcasc_cost([],Ad,Wa,Td,Wt,a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0,dd_0,0,0);
printf("cost_ex=%8.5f\n",cost_ex);
% Find the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
% Rounded truncation
[cost_rd,a11_rd,a12_rd,a21_rd,a22_rd,b1_rd,b2_rd,c1_rd,c2_rd,dd_rd,svec_rd] = ...
  svcasc_cost([],Ad,Wa,Td,Wt, ...
              a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0,dd_0,nbits,0);
printf("cost_rd=%8.5f\n",cost_rd);
[n_rd,d_rd]=svcasc2tf(a11_rd,a12_rd,a21_rd,a22_rd,b1_rd,b2_rd,c1_rd,c2_rd,dd_rd);
h_rd=freqz(n_rd,d_rd,nplot);
% Find optimised state variable coefficients with simulated annealing
if use_best_samin_found
  svec_sa_exact = [  21,  22, -24, -12,  25,  19,  16,  23,  22,  22, ...
                     10,  28,  -3,  -3,  19,  30,   4,  21,  10,  13, ...
                      6,   9,   9 ];
else
  % See /usr/local/share/octave/packages/optim-1.4.1/samin_example.m
  ub=nshift*ones(9*length(a11_0),1);
  lb=-ub;
  nt=20;
  ns=5;
  rt=0.5;
  maxevals=5e4;
  neps=5;
  functol=1e-3;
  paramtol=1e-3;
  verbosity=2;
  minarg=1;
  control={lb,ub,nt,ns,rt,maxevals,neps,functol,paramtol,verbosity,minarg};
  svec_sa_exact=[];
  [svec_sa_exact,cost_sa,conv_sa,details_sa] = ...
  samin("svcasc_cost",{svec_rd(:)},control)
  if isempty(svec_sa_exact)
    error("samin failed!");
  endif
endif
[cost_sa,a11_sa,a12_sa,a21_sa,a22_sa,b1_sa,b2_sa,c1_sa,c2_sa,dd_sa,svec_sa]=...
  svcasc_cost(svec_sa_exact);
printf("cost_sa=%8.5f\n",cost_sa);
[n_sa,d_sa]=svcasc2tf(a11_sa,a12_sa,a21_sa,a22_sa,b1_sa,b2_sa,c1_sa,c2_sa,dd_sa);
h_sa=freqz(n_sa,d_sa,nplot);
% Signed-digit truncation
[cost_sd,a11_sd,a12_sd,a21_sd,a22_sd,b1_sd,b2_sd,c1_sd,c2_sd,dd_sd,svec_sd]=...
  svcasc_cost([],Ad,Wa,Td,Wt, ...
              a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0,dd_0,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=svcasc2tf(a11_sd,a12_sd,a21_sd,a22_sd,b1_sd,b2_sd,c1_sd,c2_sd,dd_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised state variable coefficients with
% simulated annealing and signed-digits
if use_best_samin_found
  svec_sasd_exact = [  24,  24, -16, -15, -24,  10,  30,  18,  20,  18, ...
                       16,  16,  -3, -28,  10,   5,  20,  15,  -1,  32, ...
                        5,   9,  14 ];
else
  [svec_sasd_exact,cost_sasd,conv_sasd,details_sasd] = ...
  samin("svcasc_cost",{svec_sd(:)},control)
  if isempty(svec_sasd_exact)
    error("samin SD failed!");
  endif
endif
[cost_sasd,a11_sasd,a12_sasd,a21_sasd,a22_sasd,b1_sasd,b2_sasd, ...
  c1_sasd,c2_sasd,dd_sasd,svec_sasd]=svcasc_cost(svec_sasd_exact);
printf("cost_sasd=%8.5f\n",cost_sasd);
[n_sasd,d_sasd]=svcasc2tf(a11_sasd,a12_sasd,a21_sasd,a22_sasd, ...
                          b1_sasd,b2_sasd,c1_sasd,c2_sasd,dd_sasd);
h_sasd=freqz(n_sasd,d_sasd,nplot);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_sa)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sasd)),"linestyle","--");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
tstr=sprintf("5th order elliptic 2nd order cascade: nbits=%d,ndigits=%d",
             nbits,ndigits);
title(tstr);
legend("exact","round","samin(round)","samin(s-d)");
legend("location","northeast");
legend("Boxoff");
legend("left");
grid("on");
print("samin_svcasc_response","-dpdflatex");
close

% Passband response
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_sa)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sasd)),"linestyle","--");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 fpass*1.1 -3 3]);
title(tstr);
legend("exact","round","samin(round)","samin(s-d)");
legend("location","northwest");
legend("Boxoff");
legend("left");
grid("on");
print("samin_svcasc_passband_response","-dpdflatex");
close

% Save results
print_polynomial(a11_rd,"a11_rd");
print_polynomial(a12_rd,"a12_rd");
print_polynomial(a21_rd,"a21_rd");
print_polynomial(a22_rd,"a22_rd");
print_polynomial(b1_rd,"b1_rd");
print_polynomial(b2_rd,"b2_rd");
print_polynomial(c1_rd,"c1_rd");
print_polynomial(c2_rd,"c2_rd");
print_polynomial(dd_rd,"dd_rd");
print_polynomial(a11_sa,"a11_sa");
print_polynomial(a12_sa,"a12_sa");
print_polynomial(a21_sa,"a21_sa");
print_polynomial(a22_sa,"a22_sa");
print_polynomial(b1_sa,"b1_sa");
print_polynomial(b2_sa,"b2_sa");
print_polynomial(c1_sa,"c1_sa");
print_polynomial(c2_sa,"c2_sa");
print_polynomial(dd_sa,"dd_sa");
print_polynomial(a11_sasd,"a11_sasd");
print_polynomial(a12_sasd,"a12_sasd");
print_polynomial(a21_sasd,"a21_sasd");
print_polynomial(a22_sasd,"a22_sasd");
print_polynomial(b1_sasd,"b1_sasd");
print_polynomial(b2_sasd,"b2_sasd");
print_polynomial(c1_sasd,"c1_sasd");
print_polynomial(c2_sasd,"c2_sasd");
print_polynomial(dd_sasd,"dd_sasd");
save samin_svcasc_test.mat ...
     a11_rd a12_rd a21_rd a22_rd b1_rd b2_rd c1_rd c2_rd dd_rd ...
     a11_sa a12_sa a21_sa a22_sa b1_sa b2_sa c1_sa c2_sa dd_sa ...
     a11_sasd a12_sasd a21_sasd a22_sasd b1_sasd b2_sasd c1_sasd c2_sasd dd_sasd

% Done
diary off
movefile samin_svcasc_test.diary.tmp samin_svcasc_test.diary;
