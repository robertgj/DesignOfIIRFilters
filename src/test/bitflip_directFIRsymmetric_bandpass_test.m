% bitflip_directFIRsymmetric_bandpass_test.m
% Copyright (C) 2017-2023 Robert G. Jenssen
%
% Test case for the bit-flipping algorithm with coefficents of
% a direct-form symmetric FIR bandpass filter.

test_common;

delete("bitflip_directFIRsymmetric_bandpass_test.diary");
delete("bitflip_directFIRsymmetric_bandpass_test.diary.tmp");
diary bitflip_directFIRsymmetric_bandpass_test.diary.tmp

bitflip_bandpass_test_common;

% File name string
strf="bitflip_directFIRsymmetric_bandpass_test";

% Frequency specifications for directFIRsymmetricEsqPW
waf=w([1 nasl napl napu nasu end]);
Adf=[0 0 1 0 0];
Waf=[Wasl 0 Wap 0 Wasu];
                
function [cost,hM,svec_out]= ...
         directFIRsymmetric_cost(svec,_waf,_Adf,_Waf,_hM0,_nbits,_ndigits)

  persistent waf Adf Waf
  persistent hM0
  persistent nbits nscale ndigits npoints
  persistent init_done=false

  if nargin==7
    cost=inf;
    waf=_waf(:);
    Adf=_Adf(:);
    Waf=_Waf(:);
    hM0=_hM0(:)';
    nbits=_nbits;
    ndigits=_ndigits;
    if nbits ~= 0
      nshift=2^(nbits-1);
      nscale=nshift./(2.^x2nextra(hM0,nshift));
    else
      nscale=1;
    endif
    svec=hM0.*nscale;
    init_done=true;
  elseif nargin ~= 1
    print_usage("[cost,hM,svec_out] = ...\n\
      directFIRsymmetric_cost(svec[,waf,Adf,Waf,hM0,nbits,ndigits])");
  elseif init_done==false
    error("init_done==false");
  endif
  svec=svec(:)';
  if nbits ~= 0
    if isscalar(ndigits) && ndigits == 0
      svec=round(svec)./nscale;
    else
      svec=svec./nscale;
      svec=flt2SD(svec,nbits,ndigits);
    endif
  endif
  hM=svec;
  cost=directFIRsymmetricEsqPW(hM,waf,Adf,Waf);
  svec_out=svec.*nscale;
endfunction

function r=find_range(h)
  r=ceil(-log2(min(abs(h(find(h~=0))))/max(abs(h))));
endfunction

% Initial symmetric FIR filter found by directFIRsymmetric_slb_bandpass_test
hM1 = [  -0.0004538174,  -0.0114029873,  -0.0194431345,  -0.0069796479, ... 
          0.0215771882,   0.0348545408,   0.0158541332,  -0.0033225166, ... 
          0.0154055974,   0.0414424100,  -0.0021970758,  -0.1162784301, ... 
         -0.1760013118,  -0.0669604509,   0.1451751014,   0.2540400868 ]';

% Show the range of bits required by hM1
printf("hM1 has range %d bits\n",find_range(hM1));
r=find_range(round(hM1*nscale));
printf("hM1 rounded to %d bits has range %d bits\n",nbits,r);
if (nbits-r-1)<=0
  enbits=nbits;
  enscale=nscale;
else
  enbits=nbits+nbits-r-1;
  enscale=2^(enbits-1);
endif

% Find vector of exact coefficients
[cost_ex,hM_ex,svec_ex] = directFIRsymmetric_cost([],waf,Adf,Waf,hM1,0,0)

% Find the responses for exact, rounded, truncated and signed-digit coefficients
% Exact
nplot=1024;
wplot=(0:(nplot-1))'*pi/nplot;
A_ex=directFIRsymmetricA(wplot,hM_ex);
% Rounded truncation
[cost_rd,hM_rd,svec_rd] = directFIRsymmetric_cost([],waf,Adf,Waf,hM_ex,enbits,0)
A_rd=directFIRsymmetricA(wplot,hM_rd);
[hM_rd_digits,hM_rd_adders]=SDadders(hM_rd,enbits);
% Find optimised coefficients with bit-flipping
svec_bf=bitflip(@directFIRsymmetric_cost,svec_rd,enbits,bitstart,msize);
[cost_bf,hM_bf]=directFIRsymmetric_cost(svec_bf)
A_bf=directFIRsymmetricA(wplot,hM_bf);
[hM_bf_digits,hM_bf_adders]=SDadders(hM_bf,enbits);
fid=fopen(strcat(strf,"_bf_adders.tab"),"wt");
fprintf(fid,"$%d$",hM_bf_adders);
fclose(fid);
% Find the total number of adders required to implement the bitflipped
% rounded and bitflipped coefficients in transposed-direct-form
h_bft=[hM_bf,hM_bf((end-1):-1:1)];
[h_bft_digits,h_bft_adders]=SDadders(h_bft,enbits);
fid=fopen(strcat(strf,"_bft_adders.tab"),"wt");
fprintf(fid,"$%d$",h_bft_adders);
fclose(fid);
fid=fopen(strcat(strf,"_bft_digits.tab"),"wt");
fprintf(fid,"$%d$",h_bft_digits);
fclose(fid);

% Signed-digit truncation
[cost_sd,hM_sd,svec_sd] = ...
  directFIRsymmetric_cost([],waf,Adf,Waf,hM_ex,enbits,ndigits)
A_sd=directFIRsymmetricA(wplot,hM_sd);
[hM_sd_digits,hM_sd_adders]=SDadders(hM_sd,enbits);
% Find optimised coefficients with bit-flipping and signed-digits
svec_bfsd=bitflip(@directFIRsymmetric_cost,svec_sd,enbits,bitstart,msize);
[cost_bfsd,hM_bfsd]=directFIRsymmetric_cost(svec_bfsd)
A_bfsd=directFIRsymmetricA(wplot,hM_bfsd);
% Find the total number of adders required to implement the bitflipped SD coef.s
[hM_bfsd_digits,hM_bfsd_adders]=SDadders(hM_bfsd,enbits);
fid=fopen(strcat(strf,"_bfsd_adders.tab"),"wt");
fprintf(fid,"$%d$",hM_bfsd_adders);
fclose(fid);
% Find the total number of adders required to implement the bitflipped
% SD coef.s in transposed-direct-form
h_bfsdt=[hM_bfsd,hM_bfsd((end-1):-1:1)];
[h_bfsdt_digits,h_bfsdt_adders]=SDadders(h_bfsdt,enbits);
fid=fopen(strcat(strf,"_bfsdt_adders.tab"),"wt");
fprintf(fid,"$%d$",h_bfsdt_adders);
fclose(fid);
fid=fopen(strcat(strf,"_bfsdt_digits.tab"),"wt");
fprintf(fid,"$%d$",h_bfsdt_digits);
fclose(fid);

% Allocate signed digits with Lim's algorithm
ndigits_Lim=directFIRsymmetric_allocsd_Lim(enbits,ndigits,hM_ex, ...
                                           waf,Adf,ones(size(Waf)));

% Signed-digit truncation with Lim's algorithm
[cost_sdl,hM_sdl,svec_sdl] = ...
  directFIRsymmetric_cost([],waf,Adf,Waf,hM_ex,enbits,ndigits_Lim)
A_sdl=directFIRsymmetricA(wplot,hM_sdl);
[hM_sdl_digits,hM_sdl_adders]=SDadders(hM_sdl,enbits);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsdl=bitflip(@directFIRsymmetric_cost,svec_sdl,enbits,bitstart,msize);
[cost_bfsdl,hM_bfsdl]=directFIRsymmetric_cost(svec_bfsdl)
A_bfsdl=directFIRsymmetricA(wplot,hM_bfsdl);
% Find the total number of adders required to implement the SD multipliers
% with Lim's allocation method
[hM_bfsdl_digits,hM_bfsdl_adders]=SDadders(hM_bfsdl,enbits);
fname=strcat(strf,"_adders_Lim.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",hM_bfsdl_adders);
fclose(fid);

% Allocate signed digits with Ito's algorithm
ndigits_Ito=directFIRsymmetric_allocsd_Ito(enbits,ndigits,hM_ex,waf,Adf,Waf);

% Signed-digit truncation with Ito's algorithm
[cost_sdi,hM_sdi,svec_sdi] = ...
  directFIRsymmetric_cost([],waf,Adf,Waf,hM_ex,enbits,ndigits_Ito)
A_sdi=directFIRsymmetricA(wplot,hM_sdi);
[hM_sdi_digits,hM_sdi_adders]=SDadders(hM_sdi,enbits);
% Find optimised lattice coefficients with bit-flipping and signed-digits
svec_bfsdi=bitflip(@directFIRsymmetric_cost,svec_sdi,enbits,bitstart,msize);
[cost_bfsdi,hM_bfsdi]=directFIRsymmetric_cost(svec_bfsdi)
A_bfsdi=directFIRsymmetricA(wplot,hM_bfsdi);
% Find the total number of adders required to implement the SD multipliers
% with Ito's allocation method
[hM_bfsdi_digits,hM_bfsdi_adders]=SDadders(hM_bfsdi,enbits);
fname=strcat(strf,"_adders_Ito.tab");
fid=fopen(fname,"wt");
fprintf(fid,"$%d$",hM_bfsdi_adders);
fclose(fid);

% Make a LaTeX table for cost
fname=strcat(strf,"_cost.tab");
fid=fopen(fname,"wt");
fprintf(fid,"Exact & %6.4f \\\\ \n",cost_ex);
fprintf(fid,"%d-bit rounded & %6.4f \\\\ \n",nbits,cost_rd);
fprintf(fid,"%d-bit rounded with bitflipping & %6.4f \\\\ \n",nbits,cost_bf);
fprintf(fid,"%d-bit %d-signed-digit & %6.4f \\\\ \n",nbits,ndigits,cost_sd);
fprintf(fid,"%d-bit %d-signed-digit with bitflipping & %6.4f \\\\ \n", ...
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

% Plot the results
plot(wplot*0.5/pi,20*log10(abs(  A_ex)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(  A_rd)),"linestyle",":", ...
     wplot*0.5/pi,20*log10(abs(  A_bf)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(  A_sd)),"linestyle","-.", ...
     wplot*0.5/pi,20*log10(abs(A_bfsd)),"linestyle","-");
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.5 -60 10]);
grid("on");
strt=sprintf("Bandpass direct-form symmetric FIR, nbits=%d,bitstart=%d,\
msize=%d,ndigits=%d",nbits,bitstart,msize,ndigits);
title(strt);
legend("exact","round","bitflip(round)","signed-digit","bitflip(s-d)");
legend("location","northeast");
legend("boxoff");
legend("left");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Plot results with signed-digit allocation
plot(wplot*0.5/pi,20*log10(abs(   A_ex)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(  A_sdl)),"linestyle",":", ... 
     wplot*0.5/pi,20*log10(abs(A_bfsdl)),"linestyle","--", ...
     wplot*0.5/pi,20*log10(abs(  A_sdi)),"linestyle","-.", ...  
     wplot*0.5/pi,20*log10(abs(A_bfsdi)),"linestyle","-")
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -60 10]);
grid("on");
strt=sprintf("Bandpass direct-form symmetric FIR, nbits=%d,bitstart=%d,\
msize=%d,ndigits=%d, Lim and Ito SD allocation",nbits,bitstart,msize,ndigits);
title(strt);
legend("exact","signed-digit (Lim)","bitflip(s-d Lim)","signed-digit (Ito)", ...
       "bitflip(s-d Ito)");
legend("location","northeast");
legend("boxoff");
legend("left");
print(strcat(strf,"_response_allocsd"),"-dpdflatex");
close

% Print the results
print_polynomial(hM_ex,"hM_ex");
print_polynomial(hM_ex,"hM_ex",strcat(strf,"_hM_ex_coef.m"));

print_polynomial(hM_rd,"hM_rd",enscale);
print_polynomial(hM_rd,"hM_rd",strcat(strf,"_hM_rd_coef.m"),enscale);

print_polynomial(hM_bf,"hM_bf",enscale);
print_polynomial(hM_bf,"hM_bf",strcat(strf,"_hM_bf_coef.m"),enscale);

print_polynomial(hM_sd,"hM_sd",enscale);
print_polynomial(hM_sd,"hM_sd",strcat(strf,"_hM_sd_coef.m"),enscale);

print_polynomial(hM_bfsd,"hM_bfsd",enscale);
print_polynomial(hM_bfsd,"hM_bfsd",strcat(strf,"_hM_bfsd_coef.m"),enscale);

print_polynomial(hM_sdl,"hM_sdl",enscale);
print_polynomial(hM_sdl,"hM_sdl",strcat(strf,"_hM_sdl_coef.m"),enscale);

print_polynomial(hM_bfsdl,"hM_bfsdl",enscale);
print_polynomial(hM_bfsdl,"hM_bfsdl",strcat(strf,"_hM_bfsdl_coef.m"),enscale);

print_polynomial(hM_sdi,"hM_sdi",enscale);
print_polynomial(hM_sdi,"hM_sdi",strcat(strf,"_hM_sdi_coef.m"),enscale);

print_polynomial(hM_bfsdi,"hM_bfsdi",enscale);
print_polynomial(hM_bfsdi,"hM_bfsdi",strcat(strf,"_hM_bfsdi_coef.m"),enscale);

% Save the results
save bitflip_directFIRsymmetric_bandpass_test.mat ...
     hM_ex hM_rd hM_bf hM_sd hM_bfsd hM_sdl hM_bfsdl hM_sdi hM_bfsdi

% Done
diary off
movefile bitflip_directFIRsymmetric_bandpass_test.diary.tmp ...
         bitflip_directFIRsymmetric_bandpass_test.diary;
