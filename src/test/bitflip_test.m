% bitflip_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the bit-flipping algorithm

test_common;

delete("bitflip_test.diary");
delete("bitflip_test.diary.tmp");
diary bitflip_test.diary.tmp

check_octave_file("bitflip");

truncation_test_common;

% Specify quantisation
nbits=7;
nscale=2^(nbits-1);

% Find the exact lattice coefficients
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n0,d0);

% Initialise the cost function with the desired response
use_symmetric_s=true;
[cost_ex,s10_ex,s11_ex,s20_ex,s00_ex,s02_ex,s22_ex,svec_ex] = ...
  schurNSlattice_cost([],Ad,Wa,Td,Wt,s10,s11,s20,s00,s02,s22, ...
                      use_symmetric_s,0,0);
printf("bitflip_test: cost_ex=%8.5f\n",cost_ex);

% Find the rounded coefficient vector
[cost_rd,s10_rd,s11_rd,s20_rd,s00_rd,s02_rd,s22_rd,svec_rd] = ...
  schurNSlattice_cost([],Ad,Wa,Td,Wt,s10,s11,s20,s00,s02,s22, ...
                      use_symmetric_s,nbits,0);
printf("bitflip_test: cost_rd=%8.5f\n",cost_rd);

% Run the bitflipping algorithm for varying msize
bitstart=nbits-1;
for msize=1:bitstart
  [svec_bf,cost_bf,fiter] = ...
    bitflip(@schurNSlattice_cost,svec_rd,nbits,bitstart,msize,false);
  printf("bitflip_test:nbits=%d,bitstart=%d,msize=%d,cost_bf=%8.5f,fiter=%d\n",
         nbits,bitstart,msize,cost_bf,fiter);
endfor

% Run the bitflipping algorithm for msize=5
bitstart=nbits-1;
msize=5;
[svec_bf,cost_bf,fiter] = ...
  bitflip(@schurNSlattice_cost,svec_rd,nbits,bitstart,msize,true);
printf("bitflip_test:nbits=%d,bitstart=%d,msize=%d,cost_bf=%8.5f,fiter=%d\n",
       nbits,bitstart,msize,cost_bf,fiter);
[cost_bf,s10_bf,s11_bf,s20_bf,s00_bf,s02_bf,s22_bf]=schurNSlattice_cost(svec_bf);

% Bitflip results
print_polynomial(s10_bf,"s10_bf");
print_polynomial(s11_bf,"s11_bf");
print_polynomial(s20_bf,"s20_bf");
print_polynomial(s00_bf,"s00_bf");
print_polynomial(s02_bf,"s02_bf");
print_polynomial(s22_bf,"s22_bf");
print_polynomial(svec_bf,"svec_bf");

% Plot comparison
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
[n_rd,d_rd]=schurNSlattice2tf(s10_rd,s11_rd,s20_rd,s00_rd,s02_rd,s22_rd);
h_rd=freqz(n_rd,d_rd,nplot);
[n_bf,d_bf]=schurNSlattice2tf(s10_bf,s11_bf,s20_bf,s00_bf,s02_bf,s22_bf);
h_bf=freqz(n_bf,d_bf,nplot);
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_bf)),"linestyle","--");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
strt=sprintf("bitflip\\_test: NS lattice,nbits=%d,bitstart=%d,msize=%d",
             nbits,bitstart,msize);
title(strt);
legend("exact","round","bitflip");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print("bitflip_test_response","-dpdflatex");
close
plot(wplot*0.5/pi,20*log10(abs(h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(h_bf)),"linestyle","--");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 fpass -3 3]);
title(strt);
legend("exact","round","bitflip");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print("bitflip_test_passband_response","-dpdflatex");
close

% Perturb each coefficient. 
bitstart=nbits;msize=3;
for k=1:length(svec_rd)
  % Flip bit
  svec_del=svec_rd;
  svec_del(k)=bitxor(svec_del(k),2^(msize-1));
  cost_del=schurNSlattice_cost(svec_del);
  % Check bitflip cost
  [svec_bf,cost_bf,fiter]=...
    bitflip(@schurNSlattice_cost,svec_del,nbits,bitstart,msize,false,k);
  printf("bitflip_test:k=%d,cost_del=%g,cost_bf=%8.5f,fiter=%d\n",
         k,cost_del,cost_bf,fiter);
endfor

% Done
diary off
movefile bitflip_test.diary.tmp bitflip_test.diary;
