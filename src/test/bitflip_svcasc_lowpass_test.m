% bitflip_svcasc_lowpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the bit-flipping algorithm with coefficients of a 5th order
% elliptic filter implemented as a cascade of 2nd order state variable sections.

test_common;

delete("bitflip_svcasc_lowpass_test.diary");
delete("bitflip_svcasc_lowpass_test.diary.tmp");
diary bitflip_svcasc_lowpass_test.diary.tmp

truncation_test_common;

strf="bitflip_svcasc_lowpass_test";

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
% Find optimised state variable coefficients with bit-flipping
svec_bf=bitflip(@svcasc_cost,svec_rd,nbits,bitstart,msize);
[cost_bf,a11_bf,a12_bf,a21_bf,a22_bf,b1_bf,b2_bf,c1_bf,c2_bf,dd_bf] = ...
  svcasc_cost(svec_bf);
printf("cost_bf=%8.5f\n",cost_bf);
[n_bf,d_bf]=svcasc2tf(a11_bf,a12_bf,a21_bf,a22_bf,b1_bf,b2_bf,c1_bf,c2_bf,dd_bf);
h_bf=freqz(n_bf,d_bf,nplot);
% Signed-digit truncation
[cost_sd,a11_sd,a12_sd,a21_sd,a22_sd,b1_sd,b2_sd,c1_sd,c2_sd,dd_sd,svec_sd]=...
  svcasc_cost([],Ad,Wa,Td,Wt, ...
              a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0,dd_0,nbits,ndigits);
printf("cost_sd=%8.5f\n",cost_sd);
[n_sd,d_sd]=svcasc2tf(a11_sd,a12_sd,a21_sd,a22_sd,b1_sd,b2_sd,c1_sd,c2_sd,dd_sd);
h_sd=freqz(n_sd,d_sd,nplot);
% Find optimised state variable coefficients with bit-flipping and signed-digits
svec_bfsd=bitflip(@svcasc_cost,svec_sd,nbits,bitstart,msize);
[cost_bfsd,a11_bfsd,a12_bfsd,a21_bfsd,a22_bfsd,b1_bfsd,b2_bfsd, ...
  c1_bfsd,c2_bfsd,dd_bfsd]=svcasc_cost(svec_bfsd);
printf("cost_bfsd=%8.5f\n",cost_bfsd);
[n_bfsd,d_bfsd]=svcasc2tf(a11_bfsd,a12_bfsd,a21_bfsd,a22_bfsd, ...
                          b1_bfsd,b2_bfsd,c1_bfsd,c2_bfsd,dd_bfsd);
h_bfsd=freqz(n_bfsd,d_bfsd,nplot);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_bf)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_bfsd)),"linestyle","--");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
strt=sprintf(["5th order elliptic 2nd order cascade: ", ...
 "nbits=%d,bitstart=%d,msize=%d,ndigits=%d"],nbits,bitstart,msize,ndigits);
title(strt);
legend("exact","round","bitflip(round)","bitflip(s-d)");
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
     wplot*0.5/pi,20*log10(abs(h_bf)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(h_bfsd)),"linestyle","--");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 fpass*1.1 -3 3]);
title(strt);
legend("exact","round","bitflip(round)","bitflip(s-d)");
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
print_polynomial(a11_bf,"a11_bf");
print_polynomial(a12_bf,"a12_bf");
print_polynomial(a21_bf,"a21_bf");
print_polynomial(a22_bf,"a22_bf");
print_polynomial(b1_bf,"b1_bf");
print_polynomial(b2_bf,"b2_bf");
print_polynomial(c1_bf,"c1_bf");
print_polynomial(c2_bf,"c2_bf");
print_polynomial(dd_bf,"dd_bf");
print_polynomial(a11_bfsd,"a11_bfsd");
print_polynomial(a12_bfsd,"a12_bfsd");
print_polynomial(a21_bfsd,"a21_bfsd");
print_polynomial(a22_bfsd,"a22_bfsd");
print_polynomial(b1_bfsd,"b1_bfsd");
print_polynomial(b2_bfsd,"b2_bfsd");
print_polynomial(c1_bfsd,"c1_bfsd");
print_polynomial(c2_bfsd,"c2_bfsd");
print_polynomial(dd_bfsd,"dd_bfsd");
save bitflip_svcasc_lowpass_test.mat ...
     a11_rd a12_rd a21_rd a22_rd b1_rd b2_rd c1_rd c2_rd dd_rd ...
     a11_bf a12_bf a21_bf a22_bf b1_bf b2_bf c1_bf c2_bf dd_bf ...
     a11_bfsd a12_bfsd a21_bfsd a22_bfsd b1_bfsd b2_bfsd c1_bfsd c2_bfsd dd_bfsd

% Done
diary off
movefile bitflip_svcasc_lowpass_test.diary.tmp ...
         bitflip_svcasc_lowpass_test.diary;
