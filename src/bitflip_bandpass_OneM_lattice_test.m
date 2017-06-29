% bitflip_bandpass_OneM_lattice_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% Test case for the bit-flipping algorithm with coefficents of
% a bandpass lattice filter in one multiplier form.

test_common;

unlink("bitflip_bandpass_OneM_lattice_test.diary");
unlink("bitflip_bandpass_OneM_lattice_test.diary.tmp");
diary bitflip_bandpass_OneM_lattice_test.diary.tmp

format long e

bitflip_bandpass_test_common;

% Lattice decomposition
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(n0,d0);

% Find vector of exact lattice coefficients
[cost_ex,k_ex,c_ex,svec_ex] = ...
  schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,0,0)

% Find the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
t0=grpdelay(n0,d0,nplot);
% Rounded truncation
[cost_rd,k_rd,c_rd,svec_rd] = ...
  schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,0)
[n_rd,d_rd]=schurOneMlattice2tf(k_rd,epsilon0,ones(size(p0)),c_rd);
h_rd=freqz(n_rd,d_rd,nplot);
t_rd=grpdelay(n_rd,d_rd,nplot);
% Find optimised lattice coefficients with bit-flipping
svec_bf=bitflip(@schurOneMlattice_cost,svec_rd,nbits,bitstart,msize);
[cost_bf,k_bf,c_bf]=schurOneMlattice_cost(svec_bf)
[n_bf,d_bf]=schurOneMlattice2tf(k_bf,epsilon0,ones(size(p0)),c_bf);
h_bf=freqz(n_bf,d_bf,nplot);
t_bf=grpdelay(n_bf,d_bf,nplot);

% Signed-digit truncation
[cost_sd,k_sd,c_sd,svec_sd] = ...
   schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,ndigits)
[n_sd,d_sd]=schurOneMlattice2tf(k_sd,epsilon0,ones(size(p0)),c_sd);
h_sd=freqz(n_sd,d_sd,nplot);
t_sd=grpdelay(n_sd,d_sd,nplot);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsd=bitflip(@schurOneMlattice_cost,svec_sd,nbits,bitstart,msize);
[cost_bfsd,k_bfsd,c_bfsd]=schurOneMlattice_cost(svec_bfsd)
[n_bfsd,d_bfsd]=schurOneMlattice2tf(k_bfsd,epsilon0,ones(size(p0)),c_bfsd);
h_bfsd=freqz(n_bfsd,d_bfsd,nplot);
t_bfsd=grpdelay(n_bfsd,d_bfsd,nplot);

% Allocate signed digits with Lim's algorithm
ndigits_lim=schurOneMlattice_allocsd_Lim ...
              (nbits,ndigits,k0,epsilon0,p0,c0, ...
               w,Ad.^2,ones(size(w)),w,Td,ones(size(w)));

% Signed-digit truncation with Lim's algorithm
[cost_sdl,k_sdl,c_sdl,svec_sdl] = ...
   schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,ndigits_lim)
[n_sdl,d_sdl]=schurOneMlattice2tf(k_sdl,epsilon0,ones(size(p0)),c_sdl);
h_sdl=freqz(n_sdl,d_sdl,nplot);
t_sdl=grpdelay(n_sdl,d_sdl,nplot);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsdl=bitflip(@schurOneMlattice_cost,svec_sdl,nbits,bitstart,msize);
[cost_bfsdl,k_bfsdl,c_bfsdl]=schurOneMlattice_cost(svec_bfsdl)
[n_bfsdl,d_bfsdl]=schurOneMlattice2tf(k_bfsdl,epsilon0,ones(size(p0)),c_bfsdl);
h_bfsdl=freqz(n_bfsdl,d_bfsdl,nplot);
t_bfsdl=grpdelay(n_bfsdl,d_bfsdl,nplot);

% Allocate signed digits with Ito's algorithm
ndigits_ito=schurOneMlattice_allocsd_Ito(nbits,ndigits,k0,epsilon0,p0,c0, ...
                                         w,Ad.^2,Wa,w,Td,Wt);

% Signed-digit truncation with Ito's algorithm
[cost_sdi,k_sdi,c_sdi,svec_sdi] = ...
   schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,ndigits_ito)
[n_sdi,d_sdi]=schurOneMlattice2tf(k_sdi,epsilon0,ones(size(p0)),c_sdi);
h_sdi=freqz(n_sdi,d_sdi,nplot);
t_sdi=grpdelay(n_sdi,d_sdi,nplot);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsdi=bitflip(@schurOneMlattice_cost,svec_sdi,nbits,bitstart,msize);
[cost_bfsdi,k_bfsdi,c_bfsdi]=schurOneMlattice_cost(svec_bfsdi)
[n_bfsdi,d_bfsdi]=schurOneMlattice2tf(k_bfsdi,epsilon0,ones(size(p0)),c_bfsdi);
h_bfsdi=freqz(n_bfsdi,d_bfsdi,nplot);
t_bfsdi=grpdelay(n_bfsdi,d_bfsdi,nplot);

% Make a LaTeX table for cost
fname=sprintf("bitflip_bandpass_OneM_lattice_test_cost.tab");
fid=fopen(fname,"wt");
fprintf(fid,"Exact & %6.4f\\\\\n",cost_ex);
fprintf(fid,"%d-bit rounded & %6.4f\\\\\n",nbits,cost_rd);
fprintf(fid,"%d-bit rounded with bit-flipping & %6.4f\\\\\n",nbits,cost_bf);
fprintf(fid,"%d-bit %d-signed-digit & %6.4f \\\\ \n",nbits,ndigits,cost_sd);
fprintf(fid,"%d-bit %d-signed-digit with bit-flipping & %6.4f\\\\\n",
        nbits,ndigits,cost_bfsd);
fprintf(fid,"%d-bit %d-signed-digit(Lim alloc.) & %6.4f\\\\\n",
        nbits,ndigits,cost_sdl);
fprintf(fid,"%d-bit %d-signed-digit(Lim alloc.) with bit-flipping & %6.4f\\\\\n",
        nbits,ndigits,cost_bfsdl);
fprintf(fid,"%d-bit %d-signed-digit(Ito alloc.) & %6.4f\\\\\n",
        nbits,ndigits,cost_sdi);
fprintf(fid,"%d-bit %d-signed-digit(Ito alloc.) with bit-flipping & %6.4f\\\\\n",
        nbits,ndigits,cost_bfsdi);
fclose(fid);

% Find the total number of adders required to implement the SD multipliers
kcbfsd=[k_bfsd(:);c_bfsd(:)];
[kcbfsd_digits,kcbfsd_adders]=SDadders(kcbfsd,nbits);
fid=fopen("bitflip_bandpass_OneM_lattice_test_adders_bfsd.tab","wt");
fprintf(fid,"$%d$",kcbfsd_adders);
fclose(fid);

% Find the total number of adders required to implement the SD multipliers
% with Lim's allocation method
kcbfsdl=[k_bfsdl(:);c_bfsdl(:)];
[kcbfsdl_digits,kcbfsdl_adders]=SDadders(kcbfsdl,nbits);
fid=fopen("bitflip_bandpass_OneM_lattice_test_adders_Lim.tab","wt");
fprintf(fid,"$%d$",kcbfsdl_adders);
fclose(fid);

% Find the total number of adders required to implement the SD multipliers
% with Ito's allocation method
kcbfsdi=[k_bfsdi(:);c_bfsdi(:)];
[kcbfsdi_digits,kcbfsdi_adders]=SDadders(kcbfsdi,nbits);
fid=fopen("bitflip_bandpass_OneM_lattice_test_adders_Ito.tab","wt");
fprintf(fid,"$%d$",kcbfsdi_adders);
fclose(fid);

% Plot the results
subplot(211)
plot(wplot*0.5/pi,20*log10(abs(    h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(  h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(  h_bf)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(  h_sd)),"linestyle","-.", ... 
     wplot*0.5/pi,20*log10(abs(h_bfsd)),"linestyle","-")
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
tstr=sprintf("Bandpass OneM lattice,nbits=%d,bitstart=%d,\
msize=%d,ndigits=%d",nbits,bitstart,msize,ndigits);
title(tstr);
subplot(212)
iplot=1:(0.7*nplot); % Avoid overlap with legend
plot(wplot(iplot)*0.5/pi,    t0(iplot),"linestyle","-", ...
     wplot(iplot)*0.5/pi,  t_rd(iplot),"linestyle",":", ...
     wplot(iplot)*0.5/pi,  t_bf(iplot),"linestyle","--", ... 
     wplot(iplot)*0.5/pi,  t_sd(iplot),"linestyle","-.", ... 
     wplot(iplot)*0.5/pi,t_bfsd(iplot),"linestyle","-");
legend("exact","round","bitflip(round)","signed-digit","bitflip(s-d)");
legend("location","northeast");
legend("Boxoff");
legend("left");
xlabel("Frequency");
ylabel("Group delay(samples)");
axis([0 0.5 0 25]);
grid("on");
print("bitflip_bandpass_OneM_lattice_response","-dpdflatex");
close
% Plot results with signed-digit allocation
subplot(211)
plot(wplot*0.5/pi,20*log10(abs(    h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(  h_sdl)),"linestyle",":", ... 
     wplot*0.5/pi,20*log10(abs(h_bfsdl)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(  h_sdi)),"linestyle","-.", ...  
     wplot*0.5/pi,20*log10(abs(h_bfsdi)),"linestyle","-")
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
tstr=sprintf("Bandpass OneM lattice,nbits=%d,bitstart=%d,\
msize=%d,ndigits=%d, Lim and Ito SD allocation",nbits,bitstart,msize,ndigits);
title(tstr);
subplot(212)
iplot=1:(0.7*nplot); % Avoid overlap with legend
plot(wplot(iplot)*0.5/pi,      t0(iplot),"linestyle","-", ...
     wplot(iplot)*0.5/pi,   t_sdl(iplot),"linestyle",":", ...
     wplot(iplot)*0.5/pi, t_bfsdl(iplot),"linestyle","--", ... 
     wplot(iplot)*0.5/pi,   t_sdi(iplot),"linestyle","-.", ... 
     wplot(iplot)*0.5/pi, t_bfsdi(iplot),"linestyle","-");
legend("exact","signed-digit (Lim)","bitflip(s-d Lim)","signed-digit (Ito)", ...
       "bitflip(s-d Ito)");
legend("location","northeast");
legend("Boxoff");
legend("left");
xlabel("Frequency");
ylabel("Group delay(samples)");
axis([0 0.5 0 25]);
grid("on");
print("bitflip_bandpass_OneM_lattice_response_allocsd","-dpdflatex");
close

% Print the results
print_polynomial(k_ex,"k_ex");
print_polynomial(c_ex,"c_ex");
print_polynomial(k_ex,"k_ex", ...
                 "bitflip_bandpass_OneM_lattice_test_k_ex_coef.m");
print_polynomial(c_ex,"c_ex", ...
                 "bitflip_bandpass_OneM_lattice_test_c_ex_coef.m");
print_polynomial(k_rd,"k_rd");
print_polynomial(c_rd,"c_rd");
print_polynomial(k_rd,"k_rd", ...
                 "bitflip_bandpass_OneM_lattice_test_k_rd_coef.m",fmt_str);
print_polynomial(c_rd,"c_rd", ...
                 "bitflip_bandpass_OneM_lattice_test_c_rd_coef.m",fmt_str);
print_polynomial(k_bf,"k_bf");
print_polynomial(c_bf,"c_bf");
print_polynomial(k_bf,"k_bf", ...
                 "bitflip_bandpass_OneM_lattice_test_k_bf_coef.m",fmt_str);
print_polynomial(c_bf,"c_bf", ...
                 "bitflip_bandpass_OneM_lattice_test_c_bf_coef.m",fmt_str);
print_polynomial(k_sd,"k_sd");
print_polynomial(c_sd,"c_sd");
print_polynomial(k_sd,"k_sd", ...
                 "bitflip_bandpass_OneM_lattice_test_k_sd_coef.m",fmt_str);
print_polynomial(c_sd,"c_sd", ...
                 "bitflip_bandpass_OneM_lattice_test_c_sd_coef.m",fmt_str);
print_polynomial(k_bfsd,"k_bfsd");
print_polynomial(c_bfsd,"c_bfsd");
print_polynomial(k_bfsd,"k_bfsd", ...
                 "bitflip_bandpass_OneM_lattice_test_k_bfsd_coef.m",fmt_str);
print_polynomial(c_bfsd,"c_bfsd", ...
                 "bitflip_bandpass_OneM_lattice_test_c_bfsd_coef.m",fmt_str);

print_polynomial(k_sdl,"k_sdl");
print_polynomial(c_sdl,"c_sdl");
print_polynomial(k_sdl,"k_sdl", ...
                 "bitflip_bandpass_OneM_lattice_test_k_sdl_coef.m",fmt_str);
print_polynomial(c_sdl,"c_sdl", ...
                 "bitflip_bandpass_OneM_lattice_test_c_sdl_coef.m",fmt_str);
print_polynomial(k_bfsdl,"k_bfsdl");
print_polynomial(c_bfsdl,"c_bfsdl");
print_polynomial(k_bfsdl,"k_bfsdl", ...
                 "bitflip_bandpass_OneM_lattice_test_k_bfsdl_coef.m",fmt_str);
print_polynomial(c_bfsdl,"c_bfsdl", ...
                 "bitflip_bandpass_OneM_lattice_test_c_bfsdl_coef.m",fmt_str);

print_polynomial(k_sdi,"k_sdi");
print_polynomial(c_sdi,"c_sdi");
print_polynomial(k_sdi,"k_sdi", ...
                 "bitflip_bandpass_OneM_lattice_test_k_sdi_coef.m",fmt_str);
print_polynomial(c_sdi,"c_sdi", ...
                 "bitflip_bandpass_OneM_lattice_test_c_sdi_coef.m",fmt_str);
print_polynomial(k_bfsdi,"k_bfsdi");
print_polynomial(c_bfsdi,"c_bfsdi");
print_polynomial(k_bfsdi,"k_bfsdi", ...
                 "bitflip_bandpass_OneM_lattice_test_k_bfsdi_coef.m",fmt_str);
print_polynomial(c_bfsdi,"c_bfsdi", ...
                 "bitflip_bandpass_OneM_lattice_test_c_bfsdi_coef.m",fmt_str);

% Save the results
save bitflip_bandpass_OneM_lattice_test.mat ...
     k_ex c_ex k_rd c_rd k_bf c_bf k_sd c_sd k_bfsd c_bfsd ...
     k_sdl c_sdl k_bfsdl c_bfsdl k_sdi c_sdi k_bfsdi c_bfsdi 

% Done
diary off
movefile bitflip_bandpass_OneM_lattice_test.diary.tmp ...
       bitflip_bandpass_OneM_lattice_test.diary;
