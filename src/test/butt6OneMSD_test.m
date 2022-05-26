% butt6OneMSD_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen
%
% Test case for a 5th order Butterworth lattice filter with 
% single multiplier form and truncated coefficients. 

test_common;

delete("butt6OneMSD_test.diary");
delete("butt6OneMSD_test.diary.tmp");
diary butt6OneMSD_test.diary.tmp

% fc is the filter cutoff as a fraction of the sampling frequency
fc=0.05
[n,d]=butter(5,2*fc);
n=n(:)';
d=d(:)';
n60=p2n60(d)
[Aap1,Aap2]=tf2pa(n,d);
sgma=1;

% Schur lattice decomposition. 
% The roots of A1BP and A2BP are outside the unit circle
% Lattice decompositions
[A1k,A1epsilon,A1p,A1c] = tf2schurOneMlattice(fliplr(Aap1),Aap1);
[A2k,A2epsilon,A2p,A2c] = tf2schurOneMlattice(fliplr(Aap2),Aap2);

% Quantise the all-pass filter coefficients
nbits=8
scale=2^(nbits-1)
ndigits=2
A1ksd = flt2SD(A1k, nbits, ndigits);
A1csd = flt2SD(A1c, nbits, ndigits);
A2ksd = flt2SD(A2k, nbits, ndigits);
A2csd = flt2SD(A2c, nbits, ndigits);

print_polynomial(n,"n","%13.10f");
print_polynomial(d,"d","%13.10f");
print_polynomial(A1ksd,"A1ksd","%12.8f");
print_polynomial(A1ksd,"A1ksd","%12.8f");
print_polynomial(A1csd,"A1csd","%12.8f");
print_polynomial(A1ksd,"A2ksd","%12.8f");
print_polynomial(A1ksd,"A2csd","%12.8f");

% Make a quantised noise signal with standard deviation 0.25
nbits=10;
scale=2^(nbits-1);
nsamples=2^14;
rand("seed",0xdeadbeef);
u=rand(n60+nsamples,1)-0.5;
u=0.25*u/std(u); 
u=round(u*scale);

% Filter
[A1yapf,A1yf,A1xxf]=schurOneMlatticeFilter(A1ksd,A1epsilon,A1p,A1csd,u,"round");
[A2yapf,A2yf,A2xxf]=schurOneMlatticeFilter(A2ksd,A2epsilon,A2p,A2csd,u,"round");
yapf=round(0.5*(A1yapf+(sgma*A2yapf)));

% Remove initial transient
Rn60=(n60+1):length(u);
A1yapf=A1yapf(Rn60);
A1yf=A1yf(Rn60);
A1xxf=A1xxf(Rn60,:);
A2yapf=A2yapf(Rn60);
A2yf=A2yf(Rn60);
A2xxf=A2xxf(Rn60,:);

% Show the state variances
A1stdxf=std(A1xxf)
A2stdxf=std(A2xxf)

% Plot frequency response
nfpts=1024;
nppts=(0:511);
Hapf=crossWelch(u,yapf,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(Hapf)));
axis([0 0.5 -70 5])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
print("butt6OneMSD_response","-dpdflatex");
close

diary off
movefile butt6OneMSD_test.diary.tmp butt6OneMSD_test.diary;
