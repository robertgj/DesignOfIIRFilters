% samin_svcasc_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the simulated-annealing samin algorithm with coefficients of a
% 5th order elliptic filter implemented as a cascade of 2nd order state variable
% sections.
%
% Notes:
%  1. Unfortunately the siman algorithm is not repeatable.
%     The minimum cost found varies.
%  2. Change use_best_siman_found to false to run siman

test_common;

pkg load optim;

delete("samin_svcasc_lowpass_test.diary");
delete("samin_svcasc_lowpass_test.diary.tmp");
diary samin_svcasc_lowpass_test.diary.tmp

truncation_test_common;

use_best_siman_found=true
if use_best_siman_found
  warning("Using the best filter found so far. \n\
Set \"use_best_siman_found\"=false to re-run siman.");
endif

strf="samin_svcasc_lowpass_test";

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
[svec_rd_digits,svec_rd_adders]=SDadders(svec_rd,nbits);
printf("svec_rd_digits=%d,svec_rd_adders=%d\n",svec_rd_digits,svec_rd_adders);
[n_rd,d_rd]=svcasc2tf(a11_rd,a12_rd,a21_rd,a22_rd,b1_rd,b2_rd,c1_rd,c2_rd,dd_rd);
h_rd=freqz(n_rd,d_rd,nplot);
% Find optimised state variable coefficients with simulated annealing
if use_best_siman_found
  svec_sa_exact = [  24.3867,  21.9366, -22.1740, -12.0831, ... 
                     15.8383,  21.1725,  17.3108,  19.9410, ... 
                     21.7762,  21.8095,  12.5136,  21.0909, ... 
                      4.0427,   2.1297,  15.9911,  12.1491, ... 
                      2.3762,  30.2050,  12.7520,  13.4953, ... 
                      7.6093,   9.2074,   6.5839 ]';
else
  ub=nshift*ones(length(svec_rd),1);
  lb=-ub;
  siman_opt=optimset("algorithm","siman","lbound",lb,"ubound",ub); 
  svec_sa_exact=[];
  [svec_sa_exact,cost_sa,conv_sa,details_sa] = ...
    nonlin_min("svcasc_cost",svec_rd(:),siman_opt);
  if isempty(svec_sa_exact)
    error("samin failed!");
  endif
  print_polynomial(svec_sa_exact,"svec_sa_exact","%8.4f");
endif
[cost_sa,a11_sa,a12_sa,a21_sa,a22_sa,b1_sa,b2_sa,c1_sa,c2_sa,dd_sa,svec_sa]=...
  svcasc_cost(svec_sa_exact);
printf("cost_sa=%8.5f\n",cost_sa);
print_polynomial(svec_sa,"svec_sa","%3d");
[svec_sa_digits,svec_sa_adders]=SDadders(svec_sa,nbits);
printf("svec_sa_digits=%d,svec_sa_adders=%d\n",svec_sa_digits,svec_sa_adders);
[n_sa,d_sa]=svcasc2tf(a11_sa,a12_sa,a21_sa,a22_sa,b1_sa,b2_sa,c1_sa,c2_sa,dd_sa);
h_sa=freqz(n_sa,d_sa,nplot);
% Signed-digit truncation
[cost_sd,a11_sd,a12_sd,a21_sd,a22_sd,b1_sd,b2_sd,c1_sd,c2_sd,dd_sd,svec_sd]=...
  svcasc_cost([],Ad,Wa,Td,Wt, ...
              a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0,dd_0,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[svec_sd_digits,svec_sd_adders]=SDadders(svec_sd,nbits);
printf("svec_sd_digits=%d,svec_sd_adders=%d\n",svec_sd_digits,svec_sd_adders);
[n_sd,d_sd]=svcasc2tf(a11_sd,a12_sd,a21_sd,a22_sd,b1_sd,b2_sd,c1_sd,c2_sd,dd_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised state variable coefficients with
% simulated annealing and signed-digits
if use_best_siman_found
svec_sasd_exact = [  24.0000,  24.0000, -24.0000, -12.0000, ... 
                     16.0000,  24.0000,  18.0000,  24.0000, ... 
                     24.0000,  24.0000,  12.0000,  24.0000, ... 
                      4.0000,   3.0000,  16.0000,  10.0000, ... 
                      2.0000,  24.0000,  12.0000,  15.0000, ... 
                      9.0000,   9.0000,   9.0000 ]';
else
  ub=nshift*ones(length(svec_sd),1);
  lb=-ub;
  siman_opt=optimset("algorithm","siman","lbound",lb,"ubound",ub); 
  svec_sasd_exact=[];
  [svec_sasd_exact,cost_sasd,conv_sasd,details_sasd] = ...
    nonlin_min("svcasc_cost",svec_sd(:),siman_opt);
  if isempty(svec_sasd_exact)
    error("samin SD failed!");
  endif
  print_polynomial(svec_sasd_exact,"svec_sasd_exact","%8.4f");
endif
[cost_sasd,a11_sasd,a12_sasd,a21_sasd,a22_sasd,b1_sasd,b2_sasd, ...
  c1_sasd,c2_sasd,dd_sasd,svec_sasd]=svcasc_cost(svec_sasd_exact);
printf("cost_sasd=%8.5f\n",cost_sasd);
print_polynomial(svec_sasd,"svec_sasd","%3d");
[svec_sasd_digits,svec_sasd_adders]=SDadders(svec_sasd,nbits);
printf("svec_sasd_digits=%d,svec_sasd_adders=%d\n", ...
       svec_sasd_digits,svec_sasd_adders);
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
strt=sprintf("5th order elliptic 2nd order cascade: nbits=%d,ndigits=%d",
             nbits,ndigits);
title(strt);
legend("exact","round","siman(round)","siman(s-d)");
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
     wplot*0.5/pi,20*log10(abs(h_sasd)),"linestyle","--");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 fpass*1.1 -3 3]);
title(strt);
legend("exact","round","siman(round)","siman(s-d)");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_passband_response"),"-dpdflatex");
close

% Save results
print_polynomial(a11_rd,"a11_rd","%9.6f");
print_polynomial(a12_rd,"a12_rd","%9.6f");
print_polynomial(a21_rd,"a21_rd","%9.6f");
print_polynomial(a22_rd,"a22_rd","%9.6f");
print_polynomial(b1_rd,"b1_rd","%9.6f");
print_polynomial(b2_rd,"b2_rd","%9.6f");
print_polynomial(c1_rd,"c1_rd","%9.6f");
print_polynomial(c2_rd,"c2_rd","%9.6f");
print_polynomial(dd_rd,"dd_rd","%9.6f");
print_polynomial(a11_sa,"a11_sa","%9.6f");
print_polynomial(a12_sa,"a12_sa","%9.6f");
print_polynomial(a21_sa,"a21_sa","%9.6f");
print_polynomial(a22_sa,"a22_sa","%9.6f");
print_polynomial(b1_sa,"b1_sa","%9.6f");
print_polynomial(b2_sa,"b2_sa","%9.6f");
print_polynomial(c1_sa,"c1_sa","%9.6f");
print_polynomial(c2_sa,"c2_sa","%9.6f");
print_polynomial(dd_sa,"dd_sa","%9.6f");
print_polynomial(a11_sasd,"a11_sasd","%9.6f");
print_polynomial(a12_sasd,"a12_sasd","%9.6f");
print_polynomial(a21_sasd,"a21_sasd","%9.6f");
print_polynomial(a22_sasd,"a22_sasd","%9.6f");
print_polynomial(b1_sasd,"b1_sasd","%9.6f");
print_polynomial(b2_sasd,"b2_sasd","%9.6f");
print_polynomial(c1_sasd,"c1_sasd","%9.6f");
print_polynomial(c2_sasd,"c2_sasd","%9.6f");
print_polynomial(dd_sasd,"dd_sasd","%9.6f");
save samin_svcasc_lowpass_test.mat ...
     a11_rd a12_rd a21_rd a22_rd b1_rd b2_rd c1_rd c2_rd dd_rd ...
     a11_sa a12_sa a21_sa a22_sa b1_sa b2_sa c1_sa c2_sa dd_sa ...
     a11_sasd a12_sasd a21_sasd a22_sasd b1_sasd b2_sasd c1_sasd c2_sasd dd_sasd

% Done
diary off
movefile samin_svcasc_lowpass_test.diary.tmp samin_svcasc_lowpass_test.diary;
