% butt3OneM_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the 3rd order Butterworth lattice filter with 
% single multiplier form. Use the transposed transfer function to
% estimate the noise gain. Note that this method does not really apply 
% for quantised lattice coefficients because the corresponding Schur 
% basis is not quantised. 

test_common;

delete("butt3OneM_test.diary");
delete("butt3OneM_test.diary.tmp");
diary butt3OneM_test.diary.tmp


% fc is the filter cutoff as a fraction of the sampling frequency
fc=0.05
[n,d]=butter(3,2*fc);
n=n(:)'
d=d(:)'
n60=p2n60(d);

% Lattice decomposition
[k,epsilon,p,c,S] = tf2schurOneMlattice(n,d)

% Calculate the roundoff noise gains from each internal node to 
% the output (See Parhi, Section 12.7)
ng=schurOneMlatticeNoiseGain(S,k,epsilon,p,c,d,n,zeros(size(d)))

% Repeat for the all-pass transfer function
ngap=schurOneMlatticeNoiseGain(S,k,epsilon,p,c,zeros(size(d)),fliplr(d),d)

% Make a quantised noise signal with standard deviation 0.25
nbits=10;
scale=2^(nbits-1);
nsamples=2^14;
rand("seed",0xdeadbeef);
u=rand(n60+nsamples,1)-0.5;
u=0.25*u/std(u); 
u=round(u*scale);

% Filter
[yap,y,xx]=schurOneMlatticeFilter(k,epsilon,p,c,u,"none");
[yapf,yf,xxf]=schurOneMlatticeFilter(k,epsilon,p,c,u,"round");

% Renove initial transient
Rn60=(n60+1):length(u);
u=u(Rn60);
yap=yap(Rn60);
y=y(Rn60);
xx=xx(Rn60,:);
yapf=yapf(Rn60);
yf=yf(Rn60);
xxf=xxf(Rn60,:);

% Check output round-off noise variance
est_varyd=(1+ng)/12
varyd=var(y-yf)

% Check all-pass output round-off noise variance
est_varyapd=(1+ngap)/12
varyapd=var(yap-yapf)

% Check state variable std. deviation
stdxf=std(xxf)

% Plot frequency response
nfpts=1024;
nppts=(0:511);
Hf=crossWelch(u,yf,nfpts);
Hapf=crossWelch(u,yapf,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(Hf)),...
     nppts/nfpts,20*log10(abs(Hapf)));
axis([0 0.5 -50 5])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
zticks([]);
print("butt3OneM_test_response","-dpdflatex");
close

% Plot state variables
nstates=1000;
svk=(n60+(nsamples/2)):(n60+(nsamples/2)+nstates);
subplot(211);
plot(xxf(svk,1), xxf(svk,2))
xlabel("State variable x1")
ylabel("State variable x2")
subplot(212);
plot(xxf(svk,1), xxf(svk,3))
xlabel("State variable x1")
ylabel("State variable x3")
zticks([]);
print("butt3OneM_test_sv_noise","-dpdflatex");
close

% Filter a quantised sine wave
usin=round(0.5*sin(2*pi*0.0125*(1:128))*scale);
usin=usin(:);
[yapsin,ysin,xxfsin]=schurOneMlatticeFilter(k,epsilon,p,c,usin,"round");
% Plot state variables for the sine wave
subplot(211);
plot(xxfsin(:,1), xxfsin(:,2))
xlabel("State variable x1")
ylabel("State variable x2")
subplot(212);
plot(xxfsin(:,1), xxfsin(:,3))
xlabel("State variable x1")
ylabel("State variable x3")
zticks([]);
print("butt3OneM_test_sv_sine","-dpdflatex");
close

diary off
movefile butt3OneM_test.diary.tmp butt3OneM_test.diary;
