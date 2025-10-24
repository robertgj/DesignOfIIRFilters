% butt3OneMSV_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Test case for the 3rd order Butterworth lattice filter 

test_common;

delete("butt3OneMSV_test.diary");
delete("butt3OneMSV_test.diary.tmp");
diary butt3OneMSV_test.diary.tmp


% fc is the filter cutoff as a fraction of the sampling frequency
fc=0.05
[n,d]=butter(3,2*fc);
n60=p2n60(d);

% Lattice decomposition
[k,epsilon,p,c] = tf2schurOneMlattice(n,d)

% State-variable implementation with exact coefficients
[A,B,C,D,Cap,Dap]=schurOneMlattice2Abcd(k,epsilon,p,c)

% Build a state variable representation of the retimed filter for
% the exact coefficients to find noise gains of the lattice
[ng,ngap]=schurOneMlatticeRetimedNoiseGain(k,epsilon,p,c,"schur");
ng
ngap
[ngABCD,ngABCDap]=schurOneMlatticeRetimedNoiseGain(k,epsilon,p,c,"ABCD");
ngABCD
ngABCDap

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
if exact==true
 ;
elseif ndigits ~= 0 
kf = flt2SD(k, nbits, ndigits)
cf = flt2SD(c, nbits, ndigits)
else
kf = round(k*scale)/scale
cf = round(c*scale)/scale
endif

% Build a state variable representation of the retimed filter for the
% truncated coefficients and calculate the noise gains
[ngf,ngfap]=schurOneMlatticeRetimedNoiseGain(kf,epsilon,p,cf,"schur")
[ngABCDf,ngABCDfap]=schurOneMlatticeRetimedNoiseGain(kf,epsilon,p,cf,"ABCD")

% Make a quantised noise signal
nsamples=2^14;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u);
u=round(u*scale);

% Filter with lattice structure and truncated coefficients
[yap,y,xx]=schurOneMlatticeFilter(kf,epsilon,p,cf,u,"none");
[yapf,yf,xxf]=schurOneMlatticeFilter(kf,epsilon,p,cf,u,"round");

% Remove initial transient
Rn60=(n60+1):length(u);
ub=u(Rn60);
yapb=yap(Rn60);
yb=y(Rn60);
xxb=xx(Rn60,:);
yapfb=yapf(Rn60);
yfb=yf(Rn60);
xxfb=xxf(Rn60,:);

% Check output round-off noise variance
delta=1;
est_varyd=(1+(ngf*delta*delta))/12
varyd=var(yb-yfb)

% Check all-pass output round-off noise variance
delta=1;
est_varyapd=(1+(ngfap*delta*delta))/12
varyapd=var(yapb-yapfb)

% Check state variable std. deviation
stdxxfb=std(xxfb)

% Plot frequency response for the Schur lattice implemetation
nfpts=1024;
nppts=(0:511);
Hfb=crossWelch(ub,yfb,nfpts);
Hapfb=crossWelch(ub,yapfb,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(Hfb)),...
     nppts/nfpts,20*log10(abs(Hapfb)));
axis([0 0.5 -50 5])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
zticks([]);
print("butt3OneMSV_test_response_schur_lattice","-dpdflatex");
close

% Check state-variable implementation with truncated coefficients
[Af,Bf,Cf,Df,Cfap,Dfap]=schurOneMlattice2Abcd(kf,epsilon,p,cf);
% Butterworth output
yABCD=svf(Af,Bf,Cf,Df,u,"none");
yABCDb=yABCD(Rn60);
yABCDf=svf(Af,Bf,Cf,Df,u,"round");
yABCDfb=yABCDf(Rn60);
est_varyABCDd=(1+(ngABCDf*delta*delta))/12
varyABCDd=var(yABCDb-yABCDfb)
% All-pass output
yABCDap=svf(Af,Bf,Cfap,Dfap,u,"none");
yABCDapb=yABCDap(Rn60);
yABCDapf=svf(Af,Bf,Cfap,Dfap,u,"round");
yABCDapfb=yABCDapf(Rn60);
est_varyABCDapd=(1+(ngABCDfap*delta*delta))/12
varyABCDapd=var(yABCDapb-yABCDapfb)

% Plot frequency response for the state-variable implementation
nfpts=1024;
nppts=(0:511);
HABCDfb=crossWelch(ub,yABCDfb,nfpts);
HABCDapfb=crossWelch(ub,yABCDapfb,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(HABCDfb)), ...
     nppts/nfpts,20*log10(abs(HABCDapfb)));
axis([0 0.5 -50 5])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
zticks([]);
print("butt3OneMSV_test_response_state_variable","-dpdflatex");
close

diary off
movefile butt3OneMSV_test.diary.tmp butt3OneMSV_test.diary;
