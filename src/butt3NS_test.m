% butt3NS_test.m
% Copyright (C) 2017 Robert G. Jenssen
%
% Test case for the 3rd order Butterworth lattice filter with
% scaled-normalised form. Use the transposed transfer function to
% estimate the noise gain. Note that this method does not really apply
% for quantised lattice coefficients becausee the corresponding Schur 
% basis is not quantised. 

test_common;

unlink("butt3NS_test.diary");
unlink("butt3NS_test.diary.tmp");
diary butt3NS_test.diary.tmp

format short e

% fc is the filter cutoff as a fraction of the sampling frequency
fc=0.05
[n,d]=butter(3,2*fc);
n=n(:)'
d=d(:)'

% Expected response
[H,w]=freqz(n,d,512);
T=grpdelay(n,d,w);
subplot(211);
plot(0.5*w/pi,20*log10(abs(H)));
xlabel("Frequency")
ylabel("Amplitude(dB)")
axis([0 0.5 -50 5]);
grid("on");
subplot(212);
plot(0.5*w/pi,T);
xlabel("Frequency")
ylabel("Group Delay(Samples)")
axis([0 0.5 0 10]);
grid("on");
print("butt3NS_test_expected_response","-dpdflatex");
close

% Lattice decomposition
[s10,s11,s20,s00,s02,s22,c,S] = tf2schurNSlattice(n,d)

% Calculate the roundoff noise gains from each internal node to 
% the output (See Parhi, Section 12.7)
% For the Butterworth filter function
ng=schurNSlatticeNoiseGain(S,s10,s11,s20,s00,s02,s22,d,n,zeros(size(d)))
% For the all-pass transfer function
ngap=schurNSlatticeNoiseGain(S,s10,s11,s20,s00,s02,s22,...
                             zeros(size(d)),fliplr(d),d)

% Compare with the state variable implementation
[A,B,C,D,Cap,Dap]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22)
[K,W]=KW(A,B,C,D)
ngABCD=sum(diag(K).*diag(W))
[Kap,Wap]=KW(A,B,Cap,Dap)
ngABCDap=sum(diag(Kap).*diag(Wap))

% Compare with the globally optimised filter
deltaopt=1;
[Topt,Kopt,Wopt]=optKW(K,W,deltaopt);
ngopt=sum(diag(Kopt).*diag(Wopt))
Aopt=inv(Topt)*A*Topt;
Bopt=inv(Topt)*B;
Copt=C*Topt;
Dopt=D;
[Kap,Wap]=KW(A,B,Cap,Dap);
[Toptap,Koptap,Woptap]=optKW(Kap,Wap,deltaopt);
ngoptap=sum(diag(Koptap).*diag(Woptap))

% Compare with the scaled direct form filter
[Adir,Bdir,Cdir,Ddir]=tf2Abcd(n,d);
[Kdir,Wdir]=KW(Adir,Bdir,Cdir,Ddir);
ngdir=sum(diag(Kdir).*diag(Wdir))
deltadir=1;
Tdir=diag(deltadir*sqrt(diag(Kdir)));
Adir=inv(Tdir)*Adir*Tdir;
Bdir=inv(Tdir)*Bdir;
Cdir=Cdir*Tdir;
Ddir=Ddir;
[Adirap,Bdirap,Cdirap,Ddirap]=tf2Abcd(flipud(d(:)),d(:));
[Kdirap,Wdirap]=KW(Adirap,Bdirap,Cdirap,Ddirap);
ngdirap=sum(diag(Kdirap).*diag(Wdirap))

% Make a quantised noise signal with standard deviation 0.25*2^nbits
nbits=10;
scale=2^(nbits-1);
nsamples=2^14;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u);
dir_extra_bits=0;
u_dir_scaled=round(u*scale*(2^dir_extra_bits));
u=round(u*scale);

% Filter
[yap,y,xx]=schurNSlatticeFilter(s10,s11,s20,s00,s02,s22,u,"none");
[yapf,yf,xxf]=schurNSlatticeFilter(s10,s11,s20,s00,s02,s22,u,"round");
[yABCD,xxABCD]=svf(A,B,C,D,u,"none");
[yABCDf,xxABCDf]=svf(A,B,C,D,u,"round");
[yopt,xxopt]=svf(Aopt,Bopt,Copt,Dopt,u,"none");
[yoptf,xxoptf]=svf(Aopt,Bopt,Copt,Dopt,u,"round");
[ydir,xxdir]=svf(Adir,Bdir,Cdir,Ddir,u_dir_scaled,"none");
[ydirf,xxdirf]=svf(Adir,Bdir,Cdir,Ddir,u_dir_scaled,"round");

% Plot frequency response
nfpts=1024;
nppts=(0:511);
Hf=crossWelch(u,yf,nfpts);
Hapf=crossWelch(u,yapf,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(Hf)),...
     nppts/nfpts,20*log10(abs(Hapf)))
xlabel("Frequency")
ylabel("Amplitude(dB)")
axis([0 0.5 -50 5]);
grid("on");
print("butt3NS_test_response","-dpdflatex");
close

% Check output round-off noise variance
est_varyd=(1+ng)/12
varyd=var(y-yf)
est_varyABCDd=(1+ngABCD)/12
varyABCDd=var(yABCD-yABCDf)
est_varyoptd=(1+ngopt)/12
varyoptd=var(yopt-yoptf)
est_varydird=(1+(ngdir*deltadir*deltadir))/12
varydird=var(ydir-ydirf)

% Check all-pass output round-off noise variance
est_varyapd=(1+ngap)/12
varyapd=var(yap-yapf)

% Check state variable std. deviation
stdxx=std(xxf)
stdxxopt=std(xxoptf)
stdxxdir=std(xxdirf)

% Plot state variables
nstates=1000;
svk=(nsamples/2):((nsamples/2)+nstates);
subplot(211);
plot(xxf(svk,1), xxf(svk,2));
xlabel("State variable x1");
ylabel("State variable x2");
subplot(212);
plot(xxf(svk,1), xxf(svk,3));
xlabel("State variable x1");
ylabel("State variable x3");
print("butt3NS_test_sv_noise_schur_lattice","-dpdflatex");
close
subplot(211);
plot(xxdirf(svk,1), xxdirf(svk,2));
xlabel("State variable x1");
ylabel("State variable x2");
subplot(212);
plot(xxdirf(svk,1), xxdirf(svk,3));
xlabel("State variable x1");
ylabel("State variable x3");
print("butt3NS_test_sv_noise_direct_form","-dpdflatex");
close
subplot(211);
plot(xxoptf(svk,1), xxoptf(svk,2));
xlabel("State variable x1");
ylabel("State variable x2");
subplot(212);
plot(xxoptf(svk,1), xxoptf(svk,3));
xlabel("State variable x1");
ylabel("State variable x3");
print("butt3NS_test_sv_noise_global_optimum","-dpdflatex");
close

% Plot frequency response of the noise
nfpts=1024;
nppts=(0:511);
box=128;
Hoptdiff=filter(ones(box,1)/box,1,crossWelch(u,yoptf-yopt,nfpts));
subplot(211);
plot(nppts/nfpts,20*log10(abs(Hoptdiff)));
title("Optimum filter output noise response")
%Hdiff=filter(ones(box,1)/box,1,crossWelch(u,yf-y,nfpts));
%subplot(211);
%plot(nppts/nfpts,20*log10(abs(Hdiff)));
%title("Schur lattice filter output noise response")
ylabel("Amplitude(dB)")
axis([0 0.5 -100 -60]);
grid("on");
Hdirdiff=filter(ones(box,1)/box,1,crossWelch(u,ydirf-ydir,nfpts));
subplot(212);
plot(nppts/nfpts,20*log10(abs(Hdirdiff)));
xlabel("Frequency")
ylabel("Amplitude(dB)")
title("Direct form filter output noise response")
axis([0 0.5 -100 -60]);
grid("on");
print("butt3NS_test_response_direct_form_noise","-dpdflatex");
close

% Filter a quantised sine wave
usin=round(0.5*sin(2*pi*0.0125*(1:128))*scale);
usin=usin(:);
[ysinap,ysin,xxsin]=schurNSlatticeFilter(s10,s11,s20,s00,s02,s22,usin,"none");
% Plot state variables for the sine wave
subplot(211);
plot(xxsin(:,1), xxsin(:,2))
xlabel("State variable x1")
ylabel("State variable x2")
subplot(212);
plot(xxsin(:,1), xxsin(:,3))
xlabel("State variable x1")
ylabel("State variable x3")
print("butt3NS_test_sv_sine_schur_lattice","-dpdflatex");
close

diary off
movefile butt3NS_test.diary.tmp butt3NS_test.diary;
