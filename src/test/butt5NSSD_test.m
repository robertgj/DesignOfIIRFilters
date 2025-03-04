% butt5NSSD_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the 5th order Butterworth lattice filter with
% scaled-normalised exact and truncated coefficients.

test_common;

delete("butt5NSSD_test.diary");
delete("butt5NSSD_test.diary.tmp");
diary butt5NSSD_test.diary.tmp

output_precision(10)

% fc is the filter cutoff as a fraction of the sampling frequency
fc=0.05
[n,d]=butter(5,2*fc);
n=n(:)'
d=d(:)'
n60=p2n60(d)
[Aap1,Aap2]=tf2pa(n,d)

% Lattice decomposition of transfer function
[S,s10,s11,s20,s00,s02,s22,c] = tf2schurNSlattice(n,d)

% Schur lattice decomposition of allpass filters
[A1s10,A1s11,A1s20,A1s00,A1s02,A1s22]=tf2schurNSlattice(fliplr(Aap1),Aap1);
[A2s10,A2s11,A2s20,A2s00,A2s02,A2s22]=tf2schurNSlattice(fliplr(Aap2),Aap2);

% Quantise the all-pass filter coefficients
nbits=10
scale=2^(nbits-1)
ndigits=2
A1s10f = flt2SD(A1s10, nbits, ndigits)
A1s11f = flt2SD(A1s11, nbits, ndigits)
A1s20f = flt2SD(A1s20, nbits, ndigits)
A1s00f = flt2SD(A1s00, nbits, ndigits)
A1s02f = flt2SD(A1s02, nbits, ndigits)
A1s22f = flt2SD(A1s22, nbits, ndigits)
A2s10f = flt2SD(A2s10, nbits, ndigits)
A2s11f = flt2SD(A2s11, nbits, ndigits)
A2s20f = flt2SD(A2s20, nbits, ndigits)
A2s00f = flt2SD(A2s00, nbits, ndigits)
A2s02f = flt2SD(A2s02, nbits, ndigits)
A2s22f = flt2SD(A2s22, nbits, ndigits)

% Make a quantised noise signal with standard deviation 0.25
nsamples=2^14;
rand("seed",0xdeadbeef);
u=rand(n60+nsamples,1)-0.5;
u=0.25*u/std(u); 
u=round(u*scale);

% Filter
[A1yapf, A1yf, A1xxf]=...
  schurNSlatticeFilter(A1s10f,A1s11f,A1s20f,A1s00f,A1s02f,A1s22f,u,"round");
[A2yapf, A2yf, A2xxf]=...
  schurNSlatticeFilter(A2s10f,A2s11f,A2s20f,A2s00f,A2s02f,A2s22f,u,"round");
yapf=round(0.5*(A1yapf+A2yapf));

% Remove initial transient
Rn60=(n60+1):length(u);
u=u(Rn60);
A1yapf=A1yapf(Rn60);
A1yf=A1yf(Rn60);
A1xxf=A1xxf(Rn60,:);
A2yapf=A2yapf(Rn60);
A2yf=A2yf(Rn60);
A2xxf=A2xxf(Rn60,:);
yapf=yapf(Rn60);

% Show the state variances
stdA1xxf=std(A1xxf)
stdA2xxf=std(A2xxf)

% Plot frequency response
nfpts=1024;
nppts=(0:511);
Hapf=crossWelch(u,yapf,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(Hapf)));
axis([0 0.5 -50 5])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
print("butt5NSSD_response","-dpdflatex");
close

diary off
movefile butt5NSSD_test.diary.tmp butt5NSSD_test.diary;
