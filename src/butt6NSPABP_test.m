% butt6NSPABP_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for the 6th order Butterworth band-pass lattice filter

test_common;

unlink("butt6NSPABP_test.diary");
unlink("butt6NSPABP_test.diary.tmp");
diary butt6NSPABP_test.diary.tmp

format short e

% fc is the filter cutoff as a fraction of the sampling frequency
fc=0.25
[n,d]=butter(3,2*fc)
[Aap1Star,Aap2Star]=tf2pa(n,d);
Aap1=fliplr(Aap1Star(:)');
Aap2=fliplr(Aap2Star(:)');

% Low-pass to band-pass transformation
p=phi2p([0.2 0.25])
sgma=-1;
[A1BPStar,A1BP]=tfp2g(Aap1Star,Aap1,p,sgma)
[A2BPStar,A2BP]=tfp2g(Aap2Star,Aap2,p,sgma)
% Fix an artefact of tfp2g !?!
A2BP=A2BP*round(abs(A2BP(1))/A2BP(1));

% Schur lattice decomposition. 
% The roots of A1BP and A2BP are outside the unit circle
[A1s10,A1s11,A1s20,A1s00,A1s02,A1s22,A1c,A1S] = ...
  tf2schurNSlattice(A1BP,fliplr(A1BP));
if (A1s00-A1s11)>10*eps
  error("(A1s00-A1s11)>10*eps");
endif
if (A1s10-A1s20)>10*eps
  error("(A1s10-A1s20)>10*eps");
endif
[A2s10,A2s11,A2s20,A2s00,A2s02,A2s22,A2c,A2S] = ...
  tf2schurNSlattice(A2BP,fliplr(A2BP));
if (A2s00-A2s11)>10*eps
  error("(A2s00-A2s11)>10*eps");
endif
if (A2s10-A2s20)>10*eps
  error("(A2s10-A2s20)>10*eps");
endif

% Noise gain for the allpass filters with exact coefficients
A1ng=schurNSlatticeNoiseGain(A1S,A1s10,A1s11,A1s20,A1s00,A1s02,A1s22,...
zeros(size(A1BP)),A1BP,fliplr(A1BP))
A2ng=schurNSlatticeNoiseGain(A2S,A2s10,A2s11,A2s20,A2s00,A2s02,A2s22,...
zeros(size(A2BP)),A2BP,fliplr(A2BP))

% Another method for noise gain
[A1R2,B1R2,C1R2,D1R2,A1ngABCD,A1R2ap,B1R2ap,C1R2ap,D1R2ap,A1ngapABCD]=...
  schurNSlatticeRetimed2Abcd(A1s10,A1s11,A1s20,A1s00,A1s02,A1s22);
A1ngABCD
A1ngapABCD
[A2R2,B2R2,C2R2,D2R2,A2ngABCD,A2R2ap,B2R2ap,C2R2ap,D2R2ap,A2ngapABCD]=...
  schurNSlatticeRetimed2Abcd(A2s10,A2s11,A2s20,A2s00,A2s02,A2s22);
A2ngABCD
A2ngapABCD

% Quantise filter coefficients
use_exact_coefficients=false
nbits=10
scale=2^(nbits-1)
ndigits=3
if use_exact_coefficients
  A1s10f = A1s10;
  A1s11f = A1s11;
  A1s20f = A1s20;
  A1s00f = A1s00;
  A1s02f = A1s02;
  A1s22f = A1s22;
  A2s10f = A2s10;
  A2s11f = A2s11;
  A2s20f = A2s20;
  A2s00f = A2s00;
  A2s02f = A2s02;
  A2s22f = A2s22;
  print_polynomial(A1s10f,"A1s10f");
  print_polynomial(A1s11f,"A1s11f");
  print_polynomial(A1s20f,"A1s20f");
  print_polynomial(A1s00f,"A1s00f");
  print_polynomial(A1s02f,"A1s02f");
  print_polynomial(A1s22f,"A1s22f");
  print_polynomial(A2s10f,"A2s10f");
  print_polynomial(A2s11f,"A2s11f");
  print_polynomial(A2s20f,"A2s20f");
  print_polynomial(A2s00f,"A2s00f");
  print_polynomial(A2s02f,"A2s02f");
  print_polynomial(A2s22f,"A2s22f");
else
  if ndigits ~= 0
    A1s10f = flt2SD(A1s10, nbits, ndigits);
    A1s11f = flt2SD(A1s11, nbits, ndigits);
    A1s20f = flt2SD(A1s20, nbits, ndigits);
    A1s00f = flt2SD(A1s00, nbits, ndigits);
    A1s02f = flt2SD(A1s02, nbits, ndigits);
    A1s22f = flt2SD(A1s22, nbits, ndigits);
    A2s10f = flt2SD(A2s10, nbits, ndigits);
    A2s11f = flt2SD(A2s11, nbits, ndigits);
    A2s20f = flt2SD(A2s20, nbits, ndigits);
    A2s00f = flt2SD(A2s00, nbits, ndigits);
    A2s02f = flt2SD(A2s02, nbits, ndigits);
    A2s22f = flt2SD(A2s22, nbits, ndigits);
  else
    A1s10f = round(A1s10*scale)/scale;
    A1s11f = round(A1s11*scale)/scale;
    A1s20f = round(A1s20*scale)/scale;
    A1s00f = round(A1s00*scale)/scale;
    A1s02f = round(A1s02*scale)/scale;
    A1s22f = round(A1s22*scale)/scale;
    A2s10f = round(A2s10*scale)/scale;
    A2s11f = round(A2s11*scale)/scale;
    A2s20f = round(A2s20*scale)/scale;
    A2s00f = round(A2s00*scale)/scale;
    A2s02f = round(A2s02*scale)/scale;
    A2s22f = round(A2s22*scale)/scale;
  endif
  print_polynomial(A1s10f,"A1s10f",scale);
  print_polynomial(A1s11f,"A1s11f",scale);
  print_polynomial(A1s20f,"A1s20f",scale);
  print_polynomial(A1s00f,"A1s00f",scale);
  print_polynomial(A1s02f,"A1s02f",scale);
  print_polynomial(A1s22f,"A1s22f",scale);
  print_polynomial(A2s10f,"A2s10f",scale);
  print_polynomial(A2s11f,"A2s11f",scale);
  print_polynomial(A2s20f,"A2s20f",scale);
  print_polynomial(A2s00f,"A2s00f",scale);
  print_polynomial(A2s02f,"A2s02f",scale);
  print_polynomial(A2s22f,"A2s22f",scale);
endif

% Noise gain for the allpass filters with quantised coefficients
[A1R2,B1R2,C1R2,D1R2,A1ngABCDf,A1R2ap,B1R2ap,C1R2ap,D1R2ap,A1ngapABCDf]=...
  schurNSlatticeRetimed2Abcd(A1s10f,A1s11f,A1s20f,A1s00f,A1s02f,A1s22f);
A1ngABCDf
A1ngapABCDf
[A2R2,B2R2,C2R2,D2R2,A2ngABCDf,A2R2ap,B2R2ap,C2R2ap,D2R2ap,A2ngapABCDf]=...
  schurNSlatticeRetimed2Abcd(A2s10f,A2s11f,A2s20f,A2s00f,A2s02f,A2s22f);
A2ngABCDf
A2ngapABCDf

% Show the response
[A1,B1,C1,D1,Cap1,Dap1]=...
    schurNSlattice2Abcd(A1s10f,A1s11f,A1s20f,A1s00f,A1s02f,A1s22f);
[nap1,dap1]=Abcd2tf(A1,B1,Cap1,Dap1);
[hap1,w]=freqz(nap1,dap1,1024);
[A2,B2,C2,D2,Cap2,Dap2]=...
    schurNSlattice2Abcd(A2s10f,A2s11f,A2s20f,A2s00f,A2s02f,A2s22f);
[nap2,dap2]=Abcd2tf(A2,B2,Cap2,Dap2);
[hap2,w]=freqz(nap2,dap2,1024);
plot(w*0.5/pi,20*log10(abs(hap1+(sgma*hap2))/2));
axis([0 0.5 -50 5]);
grid("on");

% Make a quantised noise signal with standard deviation 0.25*2^nbits
nsamples=2^14;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u);
u=round(u*scale);

% Filter
[A1yap, A1y, A1xx]=...
schurNSlatticeFilter(A1s10f,A1s11f,A1s20f,A1s00f,A1s02f,A1s22f,u,"none");
[A2yap, A2y, A2xx]=...
schurNSlatticeFilter(A2s10f,A2s11f,A2s20f,A2s00f,A2s02f,A2s22f,u,"none");
[A1yapf, A1yf, A1xxf]=...
schurNSlatticeFilter(A1s10f,A1s11f,A1s20f,A1s00f,A1s02f,A1s22f,u,"round");
[A2yapf, A2yf, A2xxf]=...
schurNSlatticeFilter(A2s10f,A2s11f,A2s20f,A2s00f,A2s02f,A2s22f,u,"round");

% Round the summed outputs
y=0.5*(A1yap+(sgma*A2yap));
yap=0.5*(A1y+(sgma*A2y));
yf=round(0.5*(A1yf+(sgma*A2yf))) ;
yapf=round(0.5*(A1yapf+(sgma*A2yapf))) ;

% Find output round-off noise variance at the output
est_varA1yd=(1+A1ngABCDf)/12
varA1yd=var(A1y-A1yf)
est_varA2yd=(1+A2ngABCDf)/12
varA2yd=var(A2y-A2yf)
est_varyd=(2 + 0.25*(A1ngABCDf+A2ngABCDf))/12
varyd=var(y-yf)

% Find output round-off noise variance at the all-pass output
est_varA1yapd=(1+A1ngapABCDf)/12
varA1yapd=var(A1yap-A1yapf)
est_varA2yapd=(1+A2ngapABCDf)/12
varA2yapd=var(A2yap-A2yapf)
est_varyapd=(2 + 0.25*(A1ngapABCDf+A2ngapABCDf))/12
varyapd=var(yap-yapf)

% Check state variable std. deviation
A1stdxf=std(A1xxf)
A2stdxf=std(A2xxf)

% Plot frequency response
nfpts=1024;
nppts=(0:511);
HA1=crossWelch(u,A1yf,nfpts);
subplot(411);
plot(nppts/nfpts,20*log10(abs(HA1)));
ylabel("A1(dB)")
axis([0 0.5 -5 5])
grid("on");

HA1ap=crossWelch(u,A1yapf,nfpts);
subplot(412);
plot(nppts/nfpts,20*log10(abs(HA1ap)));
ylabel("A1ap(dB)")
axis([0 0.5 -5 5])
grid("on");

HA2=crossWelch(u,A2yf,nfpts);
subplot(413);
plot(nppts/nfpts,20*log10(abs(HA2)));
ylabel("A2(dB)")
axis([0 0.5 -5 5])
grid("on");

HA2ap=crossWelch(u,A2yapf,nfpts);
subplot(414);
plot(nppts/nfpts,20*log10(abs(HA2ap)));
xlabel("Frequency")
ylabel("A2ap(dB)")
axis([0 0.5 -5 5])
grid("on");
print("butt6NSPABP_test_allpass_response","-dpdflatex");
close

nfpts=1024;
nppts=(0:511);
HA=crossWelch(u,yf,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(HA)))
axis([0 0.5 -50 5])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
print("butt6NSPABP_test_output_response","-dpdflatex");
close

nfpts=1024;
nppts=(0:511);
HAap=crossWelch(u,yapf,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(HAap)))
axis([0 0.5 -50 5])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
print("butt6NSPABP_test_combined_allpass_output_response","-dpdflatex");
close

% Plot state variables
nstates=1000;
svk=(nsamples/2):((nsamples/2)+nstates);
subplot(211);
plot(A1xxf(svk,1), A1xxf(svk,2))
xlabel("A1 state variable x1")
ylabel("A1 state variable x2")
subplot(212);
plot(A2xxf(svk,1), A2xxf(svk,2))
xlabel("A2 state variable x1")
ylabel("A2 stbutt6NSPABP_test.mate variable x2")
print("butt6NSPABP_test_sv","-dpdflatex");
close

diary off
movefile butt6NSPABP_test.diary.tmp butt6NSPABP_test.diary;
