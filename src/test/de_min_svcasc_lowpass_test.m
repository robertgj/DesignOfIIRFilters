% de_min_svcasc_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the de_min differential evolution algorithm with coefficients
% of a 5th order elliptic filter implemented as a cascade of 2nd order state
% variable sections.
%
% Notes:
%  1. The de_min function from the OctaveForge optim package adds to the end of
%     the vector of coefficients being optimised!
%  2. Unfortunately de_min is not repeatable. The minimum cost found varies.
%  3. Change use_best_de_min_found to false to run de_min

test_common;

pkg load optim;

delete("de_min_svcasc_lowpass_test.diary");
delete("de_min_svcasc_lowpass_test.diary.tmp");
diary de_min_svcasc_lowpass_test.diary.tmp

truncation_test_common;

use_best_de_min_found=true
if use_best_de_min_found
  warning(["Using the best filter found so far. ", ...
 "Set \"use_best_de_min_found\"=false to re-run de_min."]);
endif

strf="de_min_svcasc_lowpass_test";

% Second order cascade state variable decomposition
[sos,g]=tf2sos(n0,d0);
[dd_0,p1,p2,q1,q2]=sos2pq(sos,g);
[a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0]=pq2svcasc(p1,p2,q1,q2,"minimum");
if mod(norder,2)
  [a11_0(end),a12_0(end),a21_0(end),a22_0(end),b1_0(end),b2_0(end), ...
   c1_0(end),c2_0(end)]=pq2svcasc(p1(end),p2(end),q1(end),q2(end),"direct");
endif

% Find vector of exact coefficients
max_cost=1e10;
[cost_ex,a11_ex,a12_ex,a21_ex,a22_ex,b1_ex,b2_ex,c1_ex,c2_ex,dd_ex,svec_ex] = ...
svcasc_cost([],Ad,Wa,Td,Wt, ...
            a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0,dd_0, ...
            0,0,max_cost);
printf("cost_ex=%8.5f\n",cost_ex);

% Find the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
% Rounded truncation
[cost_rd,a11_rd,a12_rd,a21_rd,a22_rd,b1_rd,b2_rd,c1_rd,c2_rd,dd_rd,svec_rd] = ...
  svcasc_cost([],Ad,Wa,Td,Wt, ...
              a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0,dd_0,nbits,0,max_cost);
printf("cost_rd=%8.5f\n",cost_rd);
[n_rd,d_rd]=svcasc2tf(a11_rd,a12_rd,a21_rd,a22_rd,b1_rd,b2_rd,c1_rd,c2_rd,dd_rd);
h_rd=freqz(n_rd,d_rd,nplot);
% Find optimised state variable coefficients with differential evolution
if use_best_de_min_found
  svec_de_exact = [  22.7977,  23.0241, -14.6113,  18.6578, ... 
                    -20.6985,  13.4383, -23.8584,  20.8037, ... 
                     20.6648,  21.6901,  -8.3780,  21.7558, ... 
                    -15.2276, -13.5731, -14.4033,  13.6960, ... 
                      0.7839, -16.9549, -10.1575, -13.6444, ... 
                      4.1261,  17.9528,   7.4589,  21.0263, ... 
                      2.6500,  -5.1591,  31.2328 ];
else
  ctl.XVmax=nshift*ones(1,9*length(a11_0));
  ctl.XVmin=-ctl.XVmax;
  ctl.NP=10*length(ctl.XVmax);
  ctl.constr=1;
  ctl.const=[];
  ctl.F=0.8;
  ctl.CR=0.9;
  ctl.strategy=12;
  ctl.refresh=10;
  ctl.VTR=-inf;
  ctl.tol=1e-3;
  ctl.maxnfe=1e6;
  ctl.maxiter=1e3;
  try
    [svec_de_exact,cost_de_exact,nfeval_de,conv_de] = ...
      de_min("svcasc_cost",ctl);
  catch err
    error("Caught error: %s\n",err.message);
  end_try_catch
  if ~exist("svec_de_exact") || isempty(svec_de_exact)
    error("de_min failed!");
  endif
  print_polynomial(svec_de_exact,"svec_de_exact","%8.4f");
endif
[cost_de,a11_de,a12_de,a21_de,a22_de,b1_de,b2_de,c1_de,c2_de,dd_de,svec_de]=...
  svcasc_cost(svec_de_exact);
printf("cost_de=%8.5f\n",cost_de);
[n_de,d_de]=svcasc2tf(a11_de,a12_de,a21_de,a22_de,b1_de,b2_de,c1_de,c2_de,dd_de);
h_de=freqz(n_de,d_de,nplot);
% Signed-digit truncation
[cost_sd,a11_sd,a12_sd,a21_sd,a22_sd,b1_sd,b2_sd,c1_sd,c2_sd,dd_sd,svec_sd]=...
  svcasc_cost([],Ad,Wa,Td,Wt, ...
              a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0,dd_0, ...
              nbits,ndigits,max_cost);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=svcasc2tf(a11_sd,a12_sd,a21_sd,a22_sd,b1_sd,b2_sd,c1_sd,c2_sd,dd_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised state variable signed-digit coefficients with differential
% evolution
if use_best_de_min_found
  svec_desd_exact = [  28.1129,  20.6398, -30.1464,  15.9308, ... 
                       27.1540,   6.8794, -27.8147,  14.6071, ... 
                       22.9622,  20.0151,   5.5506,  28.4896, ... 
                      -17.0297,  14.3222,  -4.3800,  16.1505, ... 
                       10.4777,  -8.3257,  -6.1120, -22.9707, ... 
                        5.9236,  20.4803,   4.0623,   9.1482, ... 
                       22.2478,  28.1791,   6.6383 ];
else
  try
    [svec_desd_exact,cost_desd_exact,nfeval_desd,conv_desd,] = ...
      de_min("svcasc_cost",ctl);
  catch err
    error("Caught error: %s\n",err.message);
  end_try_catch
  if isempty(svec_desd_exact)
    error("de_min SD failed!");
  endif
  print_polynomial(svec_desd_exact,"svec_desd_exact","%8.4f");
endif
[cost_desd,a11_desd,a12_desd,a21_desd,a22_desd,b1_desd,b2_desd, ...
  c1_desd,c2_desd,dd_desd,svec_desd]=svcasc_cost(svec_desd_exact);
printf("cost_desd=%8.5f\n",cost_desd);
[n_desd,d_desd]=svcasc2tf(a11_desd,a12_desd,a21_desd,a22_desd, ...
                          b1_desd,b2_desd,c1_desd,c2_desd,dd_desd);
h_desd=freqz(n_desd,d_desd,nplot);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_de)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_desd)),"linestyle","--");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
strt=sprintf("5th order elliptic 2nd order cascade: nbits=%d,ndigits=%d", ...
             nbits,ndigits);
title(strt);
legend("exact","round","de\\_min(round)","de\\_min(s-d)");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
close

% Passband response
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_de)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_desd)),"linestyle","--");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 fpass*1.1 -3 3]);
title(strt);
legend("exact","round","de\\_min(round)","de\\_min(s-d)");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
zticks([]);
print(strcat(strf,"_passband_response"),"-dpdflatex");
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
print_polynomial(a11_de,"a11_de");
print_polynomial(a12_de,"a12_de");
print_polynomial(a21_de,"a21_de");
print_polynomial(a22_de,"a22_de");
print_polynomial(b1_de,"b1_de");
print_polynomial(b2_de,"b2_de");
print_polynomial(c1_de,"c1_de");
print_polynomial(c2_de,"c2_de");
print_polynomial(dd_de,"dd_de");
print_polynomial(a11_desd,"a11_desd");
print_polynomial(a12_desd,"a12_desd");
print_polynomial(a21_desd,"a21_desd");
print_polynomial(a22_desd,"a22_desd");
print_polynomial(b1_desd,"b1_desd");
print_polynomial(b2_desd,"b2_desd");
print_polynomial(c1_desd,"c1_desd");
print_polynomial(c2_desd,"c2_desd");
print_polynomial(dd_desd,"dd_desd");
save de_min_svcasc_lowpass_test.mat ...
     a11_rd a12_rd a21_rd a22_rd b1_rd b2_rd c1_rd c2_rd dd_rd ...
     a11_de a12_de a21_de a22_de b1_de b2_de c1_de c2_de dd_de ...
     a11_desd a12_desd a21_desd a22_desd b1_desd b2_desd c1_desd c2_desd dd_desd

% Done
diary off
movefile de_min_svcasc_lowpass_test.diary.tmp de_min_svcasc_lowpass_test.diary;
