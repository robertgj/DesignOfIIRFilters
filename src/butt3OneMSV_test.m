% butt3OneMSV_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Test case for the 3rd order Butterworth lattice filter 

test_common;

unlink("butt3OneMSV_test.diary");
unlink("butt3OneMSV_test.diary.tmp");
diary butt3OneMSV_test.diary.tmp

format short e

% fc is the filter cutoff as a fraction of the sampling frequency
fc=0.05
[n,d]=butter(3,2*fc);

% Lattice decomposition
[k,epsilon,p,c] = tf2schurOneMlattice(n,d)

% State-variable implementation with exact coefficients
[A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,p,c)

% Build a state variable representation of the retimed filter for
% the exact coefficients to find noise gains of the lattice
[AR2,BR2,CR2,DR2,ng,AR2ap,BR2ap,CR2ap,DR2ap,ngap]=...
  schurOneMlatticeRetimed2Abcd(k,epsilon,p,c,"schur");
ng
ngap
[AR2,BR2,CR2,DR2,ngABCD,AR2ap,BR2ap,CR2ap,DR2ap,ngABCDap]=...
  schurOneMlatticeRetimed2Abcd(k,epsilon,p,c,"ABCD");
ngABCD
ngABCDap
[AR2,BR2,CR2,DR2,ngDecim,AR2ap,BR2ap,CR2ap,DR2ap,ngDecimap]=...
  schurOneMlatticeRetimed2Abcd(k,epsilon,p,c,"decim");
ngDecim
ngDecimap

% Compare with the noise gain of the globally optimised state variable
% filters with exact coefficients
[A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,p,c);
delta=1;
[K,W]=KW(A,B,C,D);
[Topt,Kopt,Wopt]=optKW(K,W,delta);
ngopt=sum(diag(Kopt).*diag(Wopt))
Aopt=inv(Topt)*A*Topt;
Bopt=inv(Topt)*B;
Copt=C*Topt;
[Kap,Wap]=KW(A,B,Cap,Dap);
[Toptap,Koptap,Woptap]=optKW(Kap,Wap,delta);
ngoptap=sum(diag(Koptap).*diag(Woptap))
Aoptap=inv(Toptap)*A*Toptap;
Boptap=inv(Toptap)*B;
Coptap=C*Toptap;

% Quantise filter coefficients
exact=false;
nbits=10
scale=2^(nbits-1)
ndigits=3
format long e
if exact==true
 ;
elseif ndigits ~= 0 
kf = flt2SD(k, nbits, ndigits)
cf = flt2SD(c, nbits, ndigits)
else
kf = round(k*scale)/scale
cf = round(c*scale)/scale
endif
format short e

% Build a state variable representation of the retimed filter for the
% truncated coefficients and calculate the noise gains
[AR2f,BR2f,CR2f,DR2f,ngf,AR2fap,BR2fap,CR2fap,DR2fap,ngfap]=...
  schurOneMlatticeRetimed2Abcd(kf,epsilon,p,cf,"schur");
ngf
ngfap
[AR2f,BR2f,CR2f,DR2f,ngABCDf,AR2fap,BR2fap,CR2fap,DR2fap,ngABCDfap]=...
  schurOneMlatticeRetimed2Abcd(kf,epsilon,p,cf,"ABCD");
ngABCDf
ngABCDfap

% Make a quantised noise signal
nsamples=2^14;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u);
u=round(u*scale);

% Filter with lattice structure and truncated coefficients
[yap,y,xx]=schurOneMlatticeFilter(kf,epsilon,p,cf,u,"none");
[yapf,yf,xxf]=schurOneMlatticeFilter(kf,epsilon,p,cf,u,"round");

% Check output round-off noise variance
delta=1;
est_varyd=(1+(ngf*delta*delta))/12
varyd=var(y-yf)

% Check all-pass output round-off noise variance
delta=1;
est_varyapd=(1+(ngfap*delta*delta))/12
varyapd=var(yap-yapf)

% Check state variable std. deviation
stdxf=std(xxf)

% Plot frequency response for the Schur lattice implemetation
nfpts=1024;
nppts=(0:511);
Hf=crossWelch(u,yf,nfpts);
Hapf=crossWelch(u,yapf,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(Hf)),"1",...
     nppts/nfpts,20*log10(abs(Hapf)),"2");
axis([0 0.5 -50 5])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
print("butt3OneMSV_test_response_schur_lattice","-dpdflatex");
close

% Check state-variable implementation with truncated coefficients
[Af,Bf,Cf,Df,Cfap,Dfap]=schurOneMlattice2Abcd(kf,epsilon,p,cf);
% Butterworth output
[yABCD,xxABCD]=svf(Af,Bf,Cf,Df,u,"none");
[yABCDf,xxABCDf]=svf(Af,Bf,Cf,Df,u,"round");
est_varyABCDd=(1+(ngABCDf*delta*delta))/12
varyABCDd=var(yABCD-yABCDf)
% All-pass output
[yABCDap,xxABCDap]=svf(Af,Bf,Cfap,Dfap,u,"none");
[yABCDapf,xxABCDapf]=svf(Af,Bf,Cfap,Dfap,u,"round");
est_varyABCDapd=(1+(ngABCDfap*delta*delta))/12
varyABCDapd=var(yABCDap-yABCDapf)

% Plot frequency response for the state-variable implementation
nfpts=1024;
nppts=(0:511);
HABCD=crossWelch(u,yABCD,nfpts);
HABCDap=crossWelch(u,yABCDap,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(HABCD)),"1",...
     nppts/nfpts,20*log10(abs(HABCDap)),"2");
axis([0 0.5 -50 5])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
print("butt3OneMSV_test_response_state_variable","-dpdflatex");
close

diary off
movefile butt3OneMSV_test.diary.tmp butt3OneMSV_test.diary;
