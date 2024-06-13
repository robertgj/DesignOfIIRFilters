% bitflip_schurFIRlattice_bandpass_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen
%
% Test case for the bit-flipping algorithm with coefficents of
% a bandpass FIR Schurlattice filter.

test_common;

strf="bitflip_schurFIRlattice_bandpass_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

bitflip_bandpass_test_common;

function n=schurFIRlattice2tf(k,gain)
  if (nargin ~= 2) || (nargout ~= 1)
    print_usage("n=schurFIRlattice2tf(k,gain)");
  endif
  [A,B,C,D]=schurFIRlattice2Abcd(k);
  [n,~]=Abcd2tf(A,B,C,D);
  n=n*gain;
endfunction

function [cost,k,svec_out] = ...
         schurFIRlattice_cost(svec,_Ad,_Wa,_k0,_gain,_nbits,_ndigits)

  persistent k0 gain Ad Wa nbits nscale ndigits npoints
  persistent init_done=false

  if nargin==7
    cost=inf;
    k0=_k0(:)';
    gain=_gain;
    Ad=_Ad(:);
    Wa=_Wa(:);
    nbits=_nbits;
    ndigits=_ndigits;
    npoints=length(Ad);
    nshift=2^(nbits-1);
    if nbits ~= 0
      nscale=nshift./(2.^x2nextra(k0,nshift));
    else
      nscale=1;
    endif
    svec=k0.*nscale;
    init_done=true;
  elseif nargin ~= 1
    print_usage("[cost,k,svec_out] = ...\n\
      schurFIRlattice_cost(svec[,Ad,Wa,k0,gain,nbits,ndigits])");
  elseif init_done==false
    error("init_done==false");
  endif
  if nbits ~= 0
    if ndigits ~= 0
      svec=svec./nscale;
      svec=flt2SD(svec,nbits,ndigits);
    else
      svec=round(svec)./nscale;
    endif
  endif
  b=schurFIRlattice2tf(svec,gain);
  h=freqz(b,[],npoints);
  h=h(:);
  cost=sqrt(sum(Wa.*((abs(h)-abs(Ad)).^2)));
  k=svec;
  svec_out=svec.*nscale;
endfunction

% PCLS FIR band pass filter (from iir_sqp_slb_fir_17_bandpass_test.m)
iir_sqp_slb_fir_17_bandpass_test_b1_coef;
b0=b1;

% Lattice decomposition
gain=b0(1);
k0=schurFIRdecomp(b0/gain);

% Find vector of exact lattice coefficients
[cost_ex,k_ex,svec_ex]=schurFIRlattice_cost([],Ad,Wa,k0,gain,0,0)

% Find the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(b0,[],nplot);
t0=delayz(b0,[],nplot);
% Rounded truncation
[cost_rd,k_rd,svec_rd]=schurFIRlattice_cost([],Ad,Wa,k0,gain,nbits,0)
n_rd=schurFIRlattice2tf(k_rd,gain);
h_rd=freqz(n_rd,[],nplot);
t_rd=delayz(n_rd,[],nplot);
% Find optimised lattice coefficients with bit-flipping
svec_bf=bitflip(@schurFIRlattice_cost,svec_rd,nbits,bitstart,msize);
[cost_bf,k_bf]=schurFIRlattice_cost(svec_bf)
n_bf=schurFIRlattice2tf(k_bf,gain);
h_bf=freqz(n_bf,[],nplot);
t_bf=delayz(n_bf,[],nplot);

% Signed-digit truncation
[cost_sd,k_sd,svec_sd]=schurFIRlattice_cost([],Ad,Wa,k0,gain,nbits,ndigits)
n_sd=schurFIRlattice2tf(k_sd,gain);
h_sd=freqz(n_sd,[],nplot);
t_sd=delayz(n_sd,[],nplot);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsd=bitflip(@schurFIRlattice_cost,svec_sd,nbits,bitstart,msize);
[cost_bfsd,k_bfsd]=schurFIRlattice_cost(svec_bfsd)
n_bfsd=schurFIRlattice2tf(k_bfsd,gain);
h_bfsd=freqz(n_bfsd,[],nplot);
t_bfsd=delayz(n_bfsd,[],nplot);

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
strt=sprintf("Bandpass Schur FIR lattice,nbits=%d,bitstart=%d,\
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
[k_bfsd_digits,k_bfsd_adders]=SDadders(k_bfsd,nbits);
fname=strcat(strf,"_adders.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",2*k_bfsd_adders);
fclose(fid);

% Print the results
print_polynomial(b0,"b0");
print_polynomial(b0,"b0",strcat(strf,"_b0_coef.m"));

print_polynomial(k_ex,"k_ex");
print_polynomial(k_ex,"k_ex",strcat(strf,"_k_ex_coef.m"));

print_polynomial(k_rd,"k_rd",nscale);
print_polynomial(k_rd,"k_rd",strcat(strf,"_k_rd_coef.m"),nscale);

print_polynomial(k_bf,"k_bf",nscale);
print_polynomial(k_bf,"k_bf",strcat(strf,"_k_bf_coef.m"),nscale);

print_polynomial(k_sd,"k_sd",nscale);
print_polynomial(k_sd,"k_sd",strcat(strf,"_k_sd_coef.m"),nscale);

print_polynomial(k_bfsd,"k_bfsd",nscale);
print_polynomial(k_bfsd,"k_bfsd",strcat(strf,"_k_bfsd_coef.m"),nscale);

% Save the results
eval(sprintf("save %s.mat b0 k0 k_ex k_rd k_bf k_sd k_bfsd",strf));

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
