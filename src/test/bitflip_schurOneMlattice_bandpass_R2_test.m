% bitflip_schurOneMlattice_bandpass_R2_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the bit-flipping algorithm with coefficients of
% a bandpass lattice filter in one multiplier form.

test_common;

strf="bitflip_schurOneMlattice_bandpass_R2_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

bitflip_bandpass_R2_test_common;

% Lattice decomposition
[k0,epsilon0,p0,c0]=tf2schurOneMlattice(n0,d0);

% Find vector of exact lattice coefficients
[cost_ex,k_ex,c_ex,svec_ex] = ...
  schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,0,0)

% Find the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
t0=delayz(n0,d0,nplot);
% Rounded truncation
[cost_rd,k_rd,c_rd,svec_rd] = ...
  schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,0)
[n_rd,d_rd]=schurOneMlattice2tf(k_rd,epsilon0,ones(size(p0)),c_rd);
h_rd=freqz(n_rd,d_rd,nplot);
t_rd=delayz(n_rd,d_rd,nplot);
% Find optimised lattice coefficients with bit-flipping
svec_bf=bitflip(@schurOneMlattice_cost,svec_rd,nbits,bitstart,msize);
[cost_bf,k_bf,c_bf]=schurOneMlattice_cost(svec_bf)
[n_bf,d_bf]=schurOneMlattice2tf(k_bf,epsilon0,ones(size(p0)),c_bf);
h_bf=freqz(n_bf,d_bf,nplot);
t_bf=delayz(n_bf,d_bf,nplot);
% Find the total number of adders required to implement the BF multipliers
kcbf=[k_bf(:);c_bf(:)];
[kcbf_digits,kcbf_adders]=SDadders(kcbf,nbits);
fname=strcat(strf,"_adders_bf.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",kcbf_adders);
fclose(fid);

% Signed-digit truncation
[cost_sd,k_sd,c_sd,svec_sd] = ...
   schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,ndigits)
[n_sd,d_sd]=schurOneMlattice2tf(k_sd,epsilon0,ones(size(p0)),c_sd);
h_sd=freqz(n_sd,d_sd,nplot);
t_sd=delayz(n_sd,d_sd,nplot);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsd=bitflip(@schurOneMlattice_cost,svec_sd,nbits,bitstart,msize);
[cost_bfsd,k_bfsd,c_bfsd]=schurOneMlattice_cost(svec_bfsd)
[n_bfsd,d_bfsd]=schurOneMlattice2tf(k_bfsd,epsilon0,ones(size(p0)),c_bfsd);
h_bfsd=freqz(n_bfsd,d_bfsd,nplot);
t_bfsd=delayz(n_bfsd,d_bfsd,nplot);

% Allocate signed digits with Lim's algorithm
ndigits_Lim=schurOneMlattice_allocsd_Lim ...
              (nbits,ndigits,k0,epsilon0,p0,c0, ...
               w,Ad.^2,ones(size(w)),w,Td,ones(size(w)));

% Signed-digit truncation with Lim's algorithm
[cost_sdl,k_sdl,c_sdl,svec_sdl] = ...
   schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,ndigits_Lim)
[n_sdl,d_sdl]=schurOneMlattice2tf(k_sdl,epsilon0,ones(size(p0)),c_sdl);
h_sdl=freqz(n_sdl,d_sdl,nplot);
t_sdl=delayz(n_sdl,d_sdl,nplot);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsdl=bitflip(@schurOneMlattice_cost,svec_sdl,nbits,bitstart,msize);
[cost_bfsdl,k_bfsdl,c_bfsdl]=schurOneMlattice_cost(svec_bfsdl)
[n_bfsdl,d_bfsdl]=schurOneMlattice2tf(k_bfsdl,epsilon0,ones(size(p0)),c_bfsdl);
h_bfsdl=freqz(n_bfsdl,d_bfsdl,nplot);
t_bfsdl=delayz(n_bfsdl,d_bfsdl,nplot);

% Allocate signed digits with Ito's algorithm
ndigits_Ito=schurOneMlattice_allocsd_Ito(nbits,ndigits,k0,epsilon0,p0,c0, ...
                                         w,Ad.^2,Wa,w,Td,Wt);

% Signed-digit truncation with Ito's algorithm
[cost_sdi,k_sdi,c_sdi,svec_sdi] = ...
   schurOneMlattice_cost([],Ad,Wa,Td,Wt,k0,epsilon0,p0,c0,nbits,ndigits_Ito)
[n_sdi,d_sdi]=schurOneMlattice2tf(k_sdi,epsilon0,ones(size(p0)),c_sdi);
h_sdi=freqz(n_sdi,d_sdi,nplot);
t_sdi=delayz(n_sdi,d_sdi,nplot);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsdi=bitflip(@schurOneMlattice_cost,svec_sdi,nbits,bitstart,msize);
[cost_bfsdi,k_bfsdi,c_bfsdi]=schurOneMlattice_cost(svec_bfsdi)
[n_bfsdi,d_bfsdi]=schurOneMlattice2tf(k_bfsdi,epsilon0,ones(size(p0)),c_bfsdi);
h_bfsdi=freqz(n_bfsdi,d_bfsdi,nplot);
t_bfsdi=delayz(n_bfsdi,d_bfsdi,nplot);

% Make a LaTeX table for cost
fname=strcat(strf,"_cost.tab");
fid=fopen(fname,"wt");
fprintf(fid,"Exact & %6.4f\\\\\n",cost_ex);
fprintf(fid,"%d-bit rounded & %6.4f\\\\\n",nbits,cost_rd);
fprintf(fid,"%d-bit rounded with bit-flipping & %6.4f\\\\\n",nbits,cost_bf);
fprintf(fid,"%d-bit %d-signed-digit & %6.4f \\\\ \n",nbits,ndigits,cost_sd);
fprintf(fid,"%d-bit %d-signed-digit with bit-flipping & %6.4f\\\\\n", ...
        nbits,ndigits,cost_bfsd);
fprintf(fid,"%d-bit %d-signed-digit(Lim alloc.) & %6.4f\\\\\n", ...
        nbits,ndigits,cost_sdl);
fprintf(fid,"%d-bit %d-signed-digit(Lim alloc.) with bit-flipping & %6.4f\\\\\n", ...
        nbits,ndigits,cost_bfsdl);
fprintf(fid,"%d-bit %d-signed-digit(Ito alloc.) & %6.4f\\\\\n", ...
        nbits,ndigits,cost_sdi);
fprintf(fid,"%d-bit %d-signed-digit(Ito alloc.) with bit-flipping & %6.4f\\\\\n", ...
        nbits,ndigits,cost_bfsdi);
fclose(fid);

% Find the total number of adders required to implement the SD multipliers
kcbfsd=[k_bfsd(:);c_bfsd(:)];
[kcbfsd_digits,kcbfsd_adders]=SDadders(kcbfsd,nbits);
fname=strcat(strf,"_adders_bfsd.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",kcbfsd_adders);
fclose(fid);

% Find the total number of adders required to implement the SD multipliers
% with Lim's allocation method
kcbfsdl=[k_bfsdl(:);c_bfsdl(:)];
[kcbfsdl_digits,kcbfsdl_adders]=SDadders(kcbfsdl,nbits);
fname=strcat(strf,"_adders_Lim.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",kcbfsdl_adders);
fclose(fid);

% Find the total number of adders required to implement the SD multipliers
% with Ito's allocation method
kcbfsdi=[k_bfsdi(:);c_bfsdi(:)];
[kcbfsdi_digits,kcbfsdi_adders]=SDadders(kcbfsdi,nbits);
fname=strcat(strf,"_adders_Ito.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",kcbfsdi_adders);
fclose(fid);

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(    h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(  h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(  h_bf)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(  h_sd)),"linestyle","-.", ... 
     wplot*0.5/pi,20*log10(abs(h_bfsd)),"linestyle","-")
legend("exact","round","bitflip(round)","signed-digit","bitflip(s-d)");
legend("location","northeast");
legend("boxoff");
legend("left");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
strt=sprintf(["Bandpass R=2 Schur OneM lattice, nbits=%d,bitstart=%d,", ...
 "msize=%d,ndigits=%d"],nbits,bitstart,msize,ndigits);
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
title(strt);
print(strcat(strf,"_delay"),"-dpdflatex");
close

% Plot results with signed-digit allocation
plot(wplot*0.5/pi,20*log10(abs(    h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(  h_sdl)),"linestyle",":", ... 
     wplot*0.5/pi,20*log10(abs(h_bfsdl)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(  h_sdi)),"linestyle","-.", ...  
     wplot*0.5/pi,20*log10(abs(h_bfsdi)),"linestyle","-")
legend("exact","signed-digit (Lim)","bitflip(s-d Lim)","signed-digit (Ito)", ...
       "bitflip(s-d Ito)");
legend("location","northeast");
legend("boxoff");
legend("left");
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
strt=sprintf(["Bandpass R=2 Schur OneM lattice, nbits=%d,bitstart=%d,", ...
 "msize=%d,ndigits=%d, Lim and Ito SD allocation"],nbits,bitstart,msize,ndigits);
title(strt);
print(strcat(strf,"_amplitude_allocsd"),"-dpdflatex");
close

iplot=1:(0.7*nplot); % Avoid overlap with legend
plot(wplot(iplot)*0.5/pi,      t0(iplot),"linestyle","-", ...
     wplot(iplot)*0.5/pi,   t_sdl(iplot),"linestyle",":", ...
     wplot(iplot)*0.5/pi, t_bfsdl(iplot),"linestyle","--", ... 
     wplot(iplot)*0.5/pi,   t_sdi(iplot),"linestyle","-.", ... 
     wplot(iplot)*0.5/pi, t_bfsdi(iplot),"linestyle","-");
legend("exact","signed-digit (Lim)","bitflip(s-d Lim)","signed-digit (Ito)", ...
       "bitflip(s-d Ito)");
legend("location","northeast");
legend("boxoff");
legend("left");
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0 0.5 0 25]);
grid("on");
title(strt);
print(strcat(strf,"_delay_allocsd"),"-dpdflatex");
close

% Print the results
print_polynomial(k_ex,"k_ex");
print_polynomial(c_ex,"c_ex");

print_polynomial(k_ex,"k_ex",strcat(strf,"_k_ex_coef.m"));
print_polynomial(c_ex,"c_ex",strcat(strf,"_c_ex_coef.m"));

print_polynomial(k_rd,"k_rd",nscale);
print_polynomial(c_rd,"c_rd",nscale);

print_polynomial(k_rd,"k_rd",strcat(strf,"_k_rd_coef.m"),nscale);
print_polynomial(c_rd,"c_rd",strcat(strf,"_c_rd_coef.m"),nscale);

print_polynomial(k_bf,"k_bf",nscale);
print_polynomial(c_bf,"c_bf",nscale);

print_polynomial(k_bf,"k_bf",strcat(strf,"_k_bf_coef.m"),nscale);
print_polynomial(c_bf,"c_bf",strcat(strf,"_c_bf_coef.m"),nscale);

print_polynomial(k_sd,"k_sd",nscale);
print_polynomial(c_sd,"c_sd",nscale);

print_polynomial(k_sd,"k_sd",strcat(strf,"_k_sd_coef.m"),nscale);
print_polynomial(c_sd,"c_sd",strcat(strf,"_c_sd_coef.m"),nscale);

print_polynomial(k_bfsd,"k_bfsd",nscale);
print_polynomial(c_bfsd,"c_bfsd",nscale);

print_polynomial(k_bfsd,"k_bfsd",strcat(strf,"_k_bfsd_coef.m"),nscale);
print_polynomial(c_bfsd,"c_bfsd",strcat(strf,"_c_bfsd_coef.m"),nscale);

print_polynomial(k_sdl,"k_sdl",nscale);
print_polynomial(c_sdl,"c_sdl",nscale);

print_polynomial(k_sdl,"k_sdl",strcat(strf,"_k_sdl_coef.m"),nscale);
print_polynomial(c_sdl,"c_sdl",strcat(strf,"_c_sdl_coef.m"),nscale);

print_polynomial(k_bfsdl,"k_bfsdl",nscale);
print_polynomial(c_bfsdl,"c_bfsdl",nscale);

print_polynomial(k_bfsdl,"k_bfsdl",strcat(strf,"_k_bfsdl_coef.m"),nscale);
print_polynomial(c_bfsdl,"c_bfsdl",strcat(strf,"_c_bfsdl_coef.m"),nscale);

print_polynomial(k_sdi,"k_sdi",nscale);
print_polynomial(c_sdi,"c_sdi",nscale);

print_polynomial(k_sdi,"k_sdi",strcat(strf,"_k_sdi_coef.m"),nscale);
print_polynomial(c_sdi,"c_sdi",strcat(strf,"_c_sdi_coef.m"),nscale);

print_polynomial(k_bfsdi,"k_bfsdi",nscale);
print_polynomial(c_bfsdi,"c_bfsdi",nscale);

print_polynomial(k_bfsdi,"k_bfsdi",strcat(strf,"_k_bfsdi_coef.m"),nscale);
print_polynomial(c_bfsdi,"c_bfsdi",strcat(strf,"_c_bfsdi_coef.m"),nscale);

% Save the results
eval(sprintf(["save %s.mat ", ...
 "k_ex c_ex k_rd c_rd k_bf c_bf k_sd c_sd k_bfsd c_bfsd ", ...
 "k_sdl c_sdl k_bfsdl c_bfsdl k_sdi c_sdi k_bfsdi c_bfsdi"],strf));

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
