% butt3NSSV_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% Test case for the 3rd order Butterworth scaled normalised 
% lattice filter in state variable form

test_common;

unlink("butt3NSSV_test.diary");
unlink("butt3NSSV_test.diary.tmp");
diary butt3NSSV_test.diary.tmp

format short e

% fc is the filter cutoff as a fraction of the sampling frequency
fc=0.05
[n,d]=butter(3,2*fc)

% Lattice decomposition
[s10,s11,s20,s00,s02,s22] = tf2schurNSlattice(n,d)

% Build a state variable representation of the retimed filter for
% the exact coefficients and calculate the noise gains
[AR2,BR2,CR2,DR2,ng,AR2ap,BR2ap,CR2ap,DR2ap,ngap]=...
  schurNSlatticeRetimed2Abcd(s10,s11,s20,s00,s02,s22);
ng
ngap

% Quantise filter coefficients
exact=false;
nbits=10
scale=2^(nbits-1)
ndigits=2
format long e
if exact==true
 ;
elseif ndigits ~= 0 
s10f = flt2SD(s10, nbits, ndigits)
s11f = flt2SD(s11, nbits, ndigits)
s20f = flt2SD(s20, nbits, ndigits)
s00f = flt2SD(s00, nbits, ndigits)
s02f = flt2SD(s02, nbits, ndigits)
s22f = flt2SD(s22, nbits, ndigits) 
else
s10f = round(s10*scale)/scale
s11f = round(s11*scale)/scale
s20f = round(s20*scale)/scale
s00f = round(s00*scale)/scale
s02f = round(s02*scale)/scale
s22f = round(s22*scale)/scale
endif
format short e

% Build a state variable representation of the retimed filter for the
% truncated coefficients and calculate the noise gains
[AR2f,BR2f,CR2f,DR2f,ngf,AR2fap,BR2fap,CR2fap,DR2fap,ngfap]=...
  schurNSlatticeRetimed2Abcd(s10f,s11f,s20f,s00f,s02f,s22f);
ngf
ngfap

% Make a quantised noise signal
nsamples=2^14;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u);
u=round(u*scale);

% Filter
[yap,y,xx]=schurNSlatticeFilter(s10f,s11f,s20f,s00f,s02f,s22f,u,"none");
[yapf,yf,xxf]=schurNSlatticeFilter(s10f,s11f,s20f,s00f,s02f,s22f,u,"round");

% Check output round-off noise variance
est_varyd=(1+ngf)/12
varyd=var(y-yf)

% Check all-pass output round-off noise variance
est_varyapd=(1+ngfap)/12
varyapd=var(yap-yapf)

% Check state variable std. deviation
stdxf=std(xxf)

% Plot frequency response
nfpts=1024;
nppts=(0:511);
Hf=crossWelch(u,yf,nfpts);
Hapf=crossWelch(u,yapf,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(Hf)),"1",...
     nppts/nfpts,20*log10(abs(Hapf)),"2")
axis([0 0.5 -50 5])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
print("butt3NSSV_test_response","-dpdflatex");
close

diary off
movefile butt3NSSV_test.diary.tmp butt3NSSV_test.diary;
