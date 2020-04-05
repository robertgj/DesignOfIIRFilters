% bitflip_directIIR_bandpass_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for the bit-flipping algorithm with coefficents of
% a bandpass filter in directIIR form.
%
% NOTE: workaround for bug in grpdelay with frequency array argument
% WARNING: This script takes a long time to run!

test_common;

% Avoid grpdelay warning messages
warning("off");

delete("bitflip_directIIR_bandpass_test.diary");
delete("bitflip_directIIR_bandpass_test.diary.tmp");
diary bitflip_directIIR_bandpass_test.diary.tmp

bitflip_bandpass_test_common;

function [cost,n,d,svec_out] = ...
         directIIR_cost(svec,_Ad,_Wa,_Td,_Wt,_n0,_d0,_nbits,_ndigits)

  persistent Ad Wa Td Wt
  persistent n0 d0
  persistent lsvec
  persistent nbits nscale ndigits npoints
  persistent init_done=false

  if nargin==9
    cost=inf;
    Ad=_Ad(:);
    Wa=_Wa(:);
    Td=_Td(:);
    Wt=_Wt(:);
    n0=_n0(:)';
    d0=_d0(:)';
    svec0=[n0,d0];
    lsvec=length(svec0);
    nbits=_nbits;
    ndigits=_ndigits;
    npoints=length(Ad);
    if nbits ~= 0
      nshift=2^(nbits-1);
      nscale=nshift./(2.^x2nextra(svec0,nshift));
    else
      nscale=1;
    endif
    svec=svec0.*nscale;
    init_done=true;
  elseif nargin ~= 1
    print_usage("[cost,n,d,svec_out] = ...\n\
      directIIR_cost(svec[,Ad,Wa,Td,Wt,n0,d0,nbits,ndigits])");
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
  n=svec(1:length(n0));
  d=svec((length(n0)+1):lsvec);
  if any(abs(roots(d)) >= 1)
    cost=inf;
    return;
  endif
  h=freqz(n,d,npoints);
  h=h(:);
  t=grpdelay(n,d,npoints);
  t=t(:);
  cost=sqrt(sum(Wa.*((abs(h)-abs(Ad)).^2)))+sqrt(sum(Wt.*((abs(t-Td)).^2)));
  svec_out=svec.*nscale;
endfunction

% File name string
strf="bitflip_directIIR_bandpass_test";

% Find vector of exact lattice coefficients
[cost_ex,n_ex,d_ex,svec_ex] = directIIR_cost([],Ad,Wa,Td,Wt,n0,d0,0,0)

% F ind the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
[h0,wplot]=freqz(n0,d0,nplot);
t0=grpdelay(n0,d0,nplot);
% Rounded truncation
[cost_rd,n_rd,d_rd,svec_rd] = directIIR_cost([],Ad,Wa,Td,Wt,n0,d0,nbits,0)
h_rd=freqz(n_rd,d_rd,nplot);
t_rd=grpdelay(n_rd,d_rd,nplot);
% Find optimised coefficients with bit-flipping
svec_bf=bitflip(@directIIR_cost,svec_rd,nbits,bitstart,msize);
[cost_bf,n_bf,d_bf]=directIIR_cost(svec_bf)
h_bf=freqz(n_bf,d_bf,nplot);
t_bf=grpdelay(n_bf,d_bf,nplot);

% Signed-digit truncation
[cost_sd,n_sd,d_sd,svec_sd] = directIIR_cost([],Ad,Wa,Td,Wt,n0,d0,nbits,ndigits)
h_sd=freqz(n_sd,d_sd,nplot);
t_sd=grpdelay(n_sd,d_sd,nplot);
% Find optimised coefficients with bit-flipping and signed-digits
svec_bfsd=bitflip(@directIIR_cost,svec_sd,nbits,bitstart,msize);
[cost_bfsd,n_bfsd,d_bfsd]=directIIR_cost(svec_bfsd)
h_bfsd=freqz(n_bfsd,d_bfsd,nplot);
t_bfsd=grpdelay(n_bfsd,d_bfsd,nplot);

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
nd_bfsd=[n_bfsd(:);d_bfsd(:)];
[nd_bfsd_digits,nd_bfsd_adders]=SDadders(nd_bfsd,nbits);
fname=strcat(strf,"_adders.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",nd_bfsd_adders);
fclose(fid);

% Plot the results
subplot(211)
plot(wplot*0.5/pi,20*log10(abs(    h0)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(  h_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(  h_bf)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(  h_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(h_bfsd)),"linestyle","-");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
strt=sprintf("Bandpass directIIR form, nbits=%d,bitstart=%d,\
msize=%d,ndigits=%d",nbits,bitstart,msize,ndigits);
title(strt);
subplot(212)
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
ylabel("Group delay(samples)");
axis([0 0.5 0 25]);
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Print the results
print_polynomial(n_ex,"n_ex");
print_polynomial(n_ex,"n_ex",strcat(strf,"_n_ex_coef.m"));

print_polynomial(d_ex,"d_ex");
print_polynomial(d_ex,"d_ex",strcat(strf,"_d_ex_coef.m"));

print_polynomial(n_rd,"n_rd",nscale);
print_polynomial(n_rd,"n_rd",strcat(strf,"_n_rd_coef.m"),nscale);

print_polynomial(d_rd,"d_rd",nscale);
print_polynomial(d_rd,"d_rd",strcat(strf,"_d_rd_coef.m"),nscale);

print_polynomial(n_bf,"n_bf",nscale);
print_polynomial(n_bf,"n_bf",strcat(strf,"_n_bf_coef.m"),nscale);

print_polynomial(d_bf,"d_bf",nscale);
print_polynomial(d_bf,"d_bf",strcat(strf,"_d_bf_coef.m"),nscale);

print_polynomial(n_sd,"n_sd",nscale);
print_polynomial(n_sd,"n_sd",strcat(strf,"_n_sd_coef.m"),nscale);

print_polynomial(d_sd,"d_sd",nscale);
print_polynomial(d_sd,"d_sd",strcat(strf,"_d_sd_coef.m"),nscale);

print_polynomial(n_bfsd,"n_bfsd",nscale);
print_polynomial(n_bfsd,"n_bfsd",strcat(strf,"_n_bfsd_coef.m"),nscale);

print_polynomial(d_bfsd,"d_bfsd",nscale);
print_polynomial(d_bfsd,"d_bfsd",strcat(strf,"_d_bfsd_coef.m"),nscale);

% Save the results
save bitflip_directIIR_bandpass_test.mat ...
     n0 d0 n_ex d_ex n_rd d_rd n_bf d_bf n_sd d_sd n_bfsd d_bfsd

% Done
diary off
movefile bitflip_directIIR_bandpass_test.diary.tmp ...
         bitflip_directIIR_bandpass_test.diary;
