% bitflip_schurNSlattice_bandpass_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen
%
% Test case for the bit-flipping algorithm with coefficents of
% a bandpass lattice filter in normalised-scaled form.

test_common;

strf="bitflip_schurNSlattice_bandpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

bitflip_bandpass_test_common;

% Lattice decomposition
[s10_0,s11_0,s20_0,s00_0,s02_0,s22_0]=tf2schurNSlattice(n0,d0);

% Find vector of exact lattice coefficients
use_symmetric_s=true;
[cost_ex,s10_ex,s11_ex,s20_ex,s00_ex,s02_ex,s22_ex,svec_ex] = ...
  schurNSlattice_cost([],Ad,Wa,Td,Wt, ...
                      s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                      use_symmetric_s,0,0)

% Find the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
t0=delayz(n0,d0,nplot);
% Rounded truncation
[cost_rd,s10_rd,s11_rd,s20_rd,s00_rd,s02_rd,s22_rd,svec_rd] = ...
  schurNSlattice_cost([],Ad,Wa,Td,Wt, ...
                      s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                      use_symmetric_s,nbits,0)
[n_rd,d_rd]=schurNSlattice2tf(s10_rd,s11_rd,s20_rd,s00_rd,s02_rd,s22_rd);
h_rd=freqz(n_rd,d_rd,nplot);
t_rd=delayz(n_rd,d_rd,nplot);
% Find optimised lattice coefficients with bit-flipping
svec_bf=bitflip(@schurNSlattice_cost,svec_rd,nbits,bitstart,msize);
[cost_bf,s10_bf,s11_bf,s20_bf,s00_bf,s02_bf,s22_bf]=schurNSlattice_cost(svec_bf)
[n_bf,d_bf]=schurNSlattice2tf(s10_bf,s11_bf,s20_bf,s00_bf,s02_bf,s22_bf);
h_bf=freqz(n_bf,d_bf,nplot);
t_bf=delayz(n_bf,d_bf,nplot);
% Signed-digit truncation
use_symmetric_s=false;
[cost_sd,s10_sd,s11_sd,s20_sd,s00_sd,s02_sd,s22_sd,svec_sd] = ...
  schurNSlattice_cost([],Ad,Wa,Td,Wt, ...
                      s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...
                      use_symmetric_s,nbits,ndigits)
[n_sd,d_sd]=schurNSlattice2tf(s10_sd,s11_sd,s20_sd,s00_sd,s02_sd,s22_sd);
h_sd=freqz(n_sd,d_sd,nplot);
t_sd=delayz(n_sd,d_sd,nplot);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsd=bitflip(@schurNSlattice_cost,svec_sd,nbits,bitstart,msize);
[cost_bfsd,s10_bfsd,s11_bfsd,s20_bfsd,s00_bfsd,s02_bfsd,s22_bfsd] = ...
  schurNSlattice_cost(svec_bfsd)
[n_bfsd,d_bfsd] = ...
  schurNSlattice2tf(s10_bfsd,s11_bfsd,s20_bfsd,s00_bfsd,s02_bfsd,s22_bfsd);
h_bfsd=freqz(n_bfsd,d_bfsd,nplot);
t_bfsd=delayz(n_bfsd,d_bfsd,nplot);

  % Make a LaTeX table for cost
fname=strcat(strf,"_cost.tab");
fid=fopen(fname,"wt");
fprintf(fid,"Exact & %6.4f \\\\ \n",cost_ex);
fprintf(fid,"%d-bit rounded & %6.4f \\\\ \n",nbits,cost_rd);
fprintf(fid,"%d-bit rounded with bitflipping & %6.4f \\\\ \n",nbits,cost_bf);
fprintf(fid,"%d-bit %d-signed-digit & %6.4f \\\\ \n",nbits,ndigits,cost_sd);
fprintf(fid,"%d-bit %d-signed-digit with bitflipping & %6.4f \\\\ \n", ...
        nbits,ndigits,cost_bfsd);
fclose(fid);

% Find the total number of adders required to implement the SD multipliers
sbfsd=[s10_bfsd(:);s11_bfsd(:);s20_bfsd(:);s00_bfsd(:);s02_bfsd(:);s22_bfsd(:)];
[sbfsd_digits,sbfsd_adders]=SDadders(sbfsd,nbits);
fname=strcat(strf,"_adders.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",sbfsd_adders);
fclose(fid);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(    h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(  h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(  h_bf)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(  h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_bfsd)),"linestyle","-");
legend("exact","round","bitflip(round)","signed-digit","bitflip(s-d)");
legend("location","northeast");
legend("boxoff");
legend("left");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
strt=sprintf("Bandpass NS lattice,nbits=%d,bitstart=%d,\
msize=%d,ndigits=%d",nbits,bitstart,msize,ndigits);
title(strt);
print(strcat(strf,"_amplitude"),"-dpdflatex");
close
iplot=1:(0.7*nplot); % Avoid overlap with legend
plot(wplot(iplot)*0.5/pi,    t0(iplot),"linestyle","-", ...
     wplot(iplot)*0.5/pi,  t_rd(iplot),"linestyle",":", ...
     wplot(iplot)*0.5/pi,  t_bf(iplot),"linestyle","--", ...
     wplot(iplot)*0.5/pi,  t_sd(iplot),"linestyle","-.", ... 
     wplot(iplot)*0.5/pi,t_bfsd(iplot),"linestyle","-");
legend("exact","round","bitflip(round)","signed-digit","bitflip(s-d)");
legend("location","northeast");
legend("boxoff");
legend("left");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0 0.5 0 25]);
grid("on");
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Save results
print_polynomial(s10_rd,"s10_rd");
print_polynomial(s11_rd,"s11_rd");
print_polynomial(s20_rd,"s20_rd");
print_polynomial(s00_rd,"s00_rd");
print_polynomial(s02_rd,"s02_rd");
print_polynomial(s22_rd,"s22_rd");

print_polynomial(s10_bf,"s10_bf");
print_polynomial(s11_bf,"s11_bf");
print_polynomial(s20_bf,"s20_bf");
print_polynomial(s00_bf,"s00_bf");
print_polynomial(s02_bf,"s02_bf");
print_polynomial(s22_bf,"s22_bf");

print_polynomial(s10_sd,"s10_sd");
print_polynomial(s11_sd,"s11_sd");
print_polynomial(s20_sd,"s20_sd");
print_polynomial(s00_sd,"s00_sd");
print_polynomial(s02_sd,"s02_sd");
print_polynomial(s22_sd,"s22_sd");

print_polynomial(s10_bfsd,"s10_bfsd");
print_polynomial(s11_bfsd,"s11_bfsd");
print_polynomial(s20_bfsd,"s20_bfsd");
print_polynomial(s00_bfsd,"s00_bfsd");
print_polynomial(s02_bfsd,"s02_bfsd");
print_polynomial(s22_bfsd,"s22_bfsd");

print_polynomial(s10_bfsd,"s10_bfsd",strcat(strf,"_s10_bfsd_coef.m"),nscale);
print_polynomial(s11_bfsd,"s11_bfsd",strcat(strf,"_s11_bfsd_coef.m"),nscale);
print_polynomial(s20_bfsd,"s20_bfsd",strcat(strf,"_s20_bfsd_coef.m"),nscale);
print_polynomial(s00_bfsd,"s00_bfsd",strcat(strf,"_s00_bfsd_coef.m"),nscale);
print_polynomial(s02_bfsd,"s02_bfsd",strcat(strf,"_s02_bfsd_coef.m"),nscale);
print_polynomial(s22_bfsd,"s22_bfsd",strcat(strf,"_s22_bfsd_coef.m"),nscale);

eval(sprintf("save %s.mat \
s10_rd   s11_rd   s20_rd   s00_rd   s02_rd   s22_rd \
s10_bf   s11_bf   s20_bf   s00_bf   s02_bf   s22_bf \
s10_sd   s11_sd   s20_sd   s00_sd   s02_sd   s22_sd \
s10_bfsd s11_bfsd s20_bfsd s00_bfsd s02_bfsd s22_bfsd",strf));

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
