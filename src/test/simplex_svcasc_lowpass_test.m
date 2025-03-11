% simplex_svcasc_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the Nelder-Mead simplex algorithm with coefficients of a 5th
% order elliptic filter implemented as a cascade of 2nd order state variable
% sections.

test_common;

pkg load optim;

delete("simplex_svcasc_lowpass_test.diary");
delete("simplex_svcasc_lowpass_test.diary.tmp");
diary simplex_svcasc_lowpass_test.diary.tmp

truncation_test_common;

strf="simplex_svcasc_lowpass_test";

% Second order cascade state variable decomposition
[sos,g]=tf2sos(n0,d0);
[dd_0,p1,p2,q1,q2]=sos2pq(sos,g);
[a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0]=pq2svcasc(p1,p2,q1,q2,"minimum");
if mod(norder,2)
  [a11_0(end),a12_0(end),a21_0(end),a22_0(end),b1_0(end),b2_0(end), ...
   c1_0(end),c2_0(end)]=pq2svcasc(p1(end),p2(end),q1(end),q2(end),"direct");
endif

% Find vector of exact coefficients
[cost_ex,a11_ex,a12_ex,a21_ex,a22_ex,b1_ex,b2_ex,c1_ex,c2_ex,dd_ex,svec_ex]=...
svcasc_cost([],Ad,Wa,Td,Wt,a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0,dd_0,0,0);
printf("cost_ex=%8.5f\n",cost_ex);

% Find the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
% Rounded truncation
[cost_rd,a11_rd,a12_rd,a21_rd,a22_rd,b1_rd,b2_rd,c1_rd,c2_rd,dd_rd,svec_rd]=...
  svcasc_cost([],Ad,Wa,Td,Wt, ...
              a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0,dd_0,nbits,0);
printf("cost_rd=%8.5f\n",cost_rd);
[n_rd,d_rd]=svcasc2tf(a11_rd,a12_rd,a21_rd,a22_rd,b1_rd,b2_rd,c1_rd,c2_rd,dd_rd);
h_rd=freqz(n_rd,d_rd,nplot);
% Find optimised state variable coefficients with the simplex algorithm
svec_sx=nelder_mead_min(@svcasc_cost,svec_rd);
[cost_sx,a11_sx,a12_sx,a21_sx,a22_sx,b1_sx,b2_sx,c1_sx,c2_sx,dd_sx] = ...
  svcasc_cost(svec_sx);
printf("cost_sx=%8.5f\n",cost_sx);
[n_sx,d_sx]=svcasc2tf(a11_sx,a12_sx,a21_sx,a22_sx,b1_sx,b2_sx,c1_sx,c2_sx,dd_sx);
h_sx=freqz(n_sx,d_sx,nplot);
% Signed-digit truncation
[cost_sd,a11_sd,a12_sd,a21_sd,a22_sd,b1_sd,b2_sd,c1_sd,c2_sd,dd_sd,svec_sd]=...
  svcasc_cost([],Ad,Wa,Td,Wt, ...
              a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0,dd_0,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=svcasc2tf(a11_sd,a12_sd,a21_sd,a22_sd,b1_sd,b2_sd,c1_sd,c2_sd,dd_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised state variable coefficients with simplex and signed-digits
svec_sxsd=nelder_mead_min(@svcasc_cost,svec_sd);
[cost_sxsd,a11_sxsd,a12_sxsd,a21_sxsd,a22_sxsd,b1_sxsd,b2_sxsd, ...
  c1_sxsd,c2_sxsd,dd_sxsd]=svcasc_cost(svec_sxsd);
printf("cost_sxsd=%8.5f\n",cost_sxsd);
[n_sxsd,d_sxsd]=svcasc2tf(a11_sxsd,a12_sxsd,a21_sxsd,a22_sxsd, ...
                          b1_sxsd,b2_sxsd,c1_sxsd,c2_sxsd,dd_sxsd);
h_sxsd=freqz(n_sxsd,d_sxsd,nplot);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_sx)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_sxsd)),"linestyle","--");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
strt=sprintf("5th order elliptic 2nd order cascade: nbits=%d,ndigits=%d", ...
             nbits,ndigits);
title(strt);
legend("exact","round","simplex(round)","simplex(s-d)");
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
     wplot*0.5/pi,20*log10(abs(h_sxsd)),"linestyle","--");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 fpass*1.1 -3 3]);
title(strt);
legend("exact","round","simplex(round)","simplex(s-d)");
legend("location","northwest");
legend("boxoff");
legend("left");
grid("on");
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
print_polynomial(a11_sx,"a11_sx");
print_polynomial(a12_sx,"a12_sx");
print_polynomial(a21_sx,"a21_sx");
print_polynomial(a22_sx,"a22_sx");
print_polynomial(b1_sx,"b1_sx");
print_polynomial(b2_sx,"b2_sx");
print_polynomial(c1_sx,"c1_sx");
print_polynomial(c2_sx,"c2_sx");
print_polynomial(dd_sx,"dd_sx");
print_polynomial(a11_sxsd,"a11_sxsd");
print_polynomial(a12_sxsd,"a12_sxsd");
print_polynomial(a21_sxsd,"a21_sxsd");
print_polynomial(a22_sxsd,"a22_sxsd");
print_polynomial(b1_sxsd,"b1_sxsd");
print_polynomial(b2_sxsd,"b2_sxsd");
print_polynomial(c1_sxsd,"c1_sxsd");
print_polynomial(c2_sxsd,"c2_sxsd");
print_polynomial(dd_sxsd,"dd_sxsd");
save simplex_svcasc_lowpass_test.mat ...
     a11_rd a12_rd a21_rd a22_rd b1_rd b2_rd c1_rd c2_rd dd_rd ...
     a11_sx a12_sx a21_sx a22_sx b1_sx b2_sx c1_sx c2_sx dd_sx ...
     a11_sxsd a12_sxsd a21_sxsd a22_sxsd b1_sxsd b2_sxsd c1_sxsd c2_sxsd dd_sxsd

% Done
diary off
movefile simplex_svcasc_lowpass_test.diary.tmp ...
         simplex_svcasc_lowpass_test.diary;
