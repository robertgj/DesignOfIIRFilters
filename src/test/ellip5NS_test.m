% ellip5NS_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen
%
% Test case for the 5th order elliptic lattice filter with
% scaled-normalised form. Use the transposed transfer function to
% estimate the noise gain. Note that this method does not really apply
% for quantised lattice coefficients becausee the corresponding Schur 
% basis is not quantised. 

test_common;

delete("ellip5NS_test.diary");
delete("ellip5NS_test.diary.tmp");
diary ellip5NS_test.diary.tmp


% fc is the filter cutoff as a fraction of the sampling frequency
fc=0.05
[n,d]=ellip(7,0.5,40,2*fc)
n60=p2n60(d)

% Lattice decomposition
[s10,s11,s20,s00,s02,s22,c,S] = tf2schurNSlattice(n,d)

% Calculate the roundoff noise gains from each internal node to 
% the output (See Parhi, Section 12.7)
% For the Butterworth filter function
ng=schurNSlatticeNoiseGain(S,s10,s11,s20,s00,s02,s22,d,n,zeros(size(d)))
% For the all-pass transfer function
dStar=d(length(d):-1:1);
ngap=schurNSlatticeNoiseGain(S,s10,s11,s20,s00,s02,s22,...
                             zeros(size(d)),dStar,d)

% Compare with the globally optimised filter
[A,B,C,D,Cap,Dap]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22)
[K,W]=KW(A,B,C,D);
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
u=rand(n60+nsamples,1)-0.5;
u=0.25*u/std(u);
u=round(u*scale);
u_dir_scaled=u*(2^24);

% Filter
[yap,y,xx]=schurNSlatticeFilter(s10,s11,s20,s00,s02,s22,u,"none");
[yapf,yf,xxf]=schurNSlatticeFilter(s10,s11,s20,s00,s02,s22,u,"round");
[yopt,xxopt]=svf(Aopt,Bopt,Copt,Dopt,u,"none");
[yoptf,xxoptf]=svf(Aopt,Bopt,Copt,Dopt,u,"round");
[ydir,xxdir]=svf(Adir,Bdir,Cdir,Ddir,u_dir_scaled,"none");
[ydirf,xxdirf]=svf(Adir,Bdir,Cdir,Ddir,u_dir_scaled,"round");

% Remove initial transient
Rn60=(n60+1):length(u);
u=u(Rn60);
yap=yap(Rn60);
y=y(Rn60);
xx=xx(Rn60,:);
yapf=yapf(Rn60);
yf=yf(Rn60);
xxf=xxf(Rn60,:);
yopt=yopt(Rn60);
xxopt=xxopt(Rn60,:);
yoptf=yoptf(Rn60);
xxoptf=xxoptf(Rn60,:);
ydir=ydir(Rn60);
xxdir=xxdir(Rn60,:);
ydirf=ydirf(Rn60);
xxdirf=xxdirf(Rn60,:);

% Plot frequency response
nfpts=1024;
nppts=(0:511);
Hf=crossWelch(u,yf,nfpts);
Hapf=crossWelch(u,yapf,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(Hf)),...
     nppts/nfpts,20*log10(abs(Hapf))),...
xlabel("Frequency")
ylabel("Amplitude(dB)")
axis([0 0.5 -50 5]);
grid("on");
print("ellip5NS_response","-dpdflatex");
close

% Check output round-off noise variance
est_varyd=(1+ng)/12
varyd=var(y-yf)
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
svk=(n60+(nsamples/2)):(n60+(nsamples/2)+nstates);
subplot(211);
plot(xxf(svk,1), xxf(svk,2));
xlabel("State variable x1");
ylabel("State variable x2");
subplot(212);
plot(xxf(svk,1), xxf(svk,3));
xlabel("State variable x1");
ylabel("State variable x3");
print("ellip5NS_sv_noise_schur_lattice","-dpdflatex");
close
subplot(211);
plot(xxdirf(svk,1)/(2^32), xxdirf(svk,2)/(2^32));
xlabel("State variable x1/2^{32}");
ylabel("State variable x2/2^{32}");
subplot(212);
plot(xxdirf(svk,1)/(2^32), xxdirf(svk,3)/(2^32));
xlabel("State variable x1/2^{32}");
ylabel("State variable x3/2^{32}");
print("ellip5NS_sv_noise_direct_form","-dpdflatex");
close
subplot(211);
plot(xxoptf(svk,1), xxoptf(svk,2));
xlabel("State variable x1");
ylabel("State variable x2");
subplot(212);
plot(xxoptf(svk,1), xxoptf(svk,3));
xlabel("State variable x1");
ylabel("State variable x3");
print("ellip5NS_sv_noise_global_optimum","-dpdflatex");
close

% Filter a quantised sine wave
usin=round(0.5*sin(2*pi*0.0125*(1:128))*scale);
[ydirsin,xxdirsin]=svf(Adir,Bdir,Cdir,Ddir,usin(:),"none");
% Plot state variables for the sine wave
subplot(211);
plot(xxdirsin(:,1), xxdirsin(:,2))
xlabel("State variable x1")
ylabel("State variable x2")
subplot(212);
plot(xxdirsin(:,1), xxdirsin(:,3))
xlabel("State variable x1")
ylabel("State variable x3")
print("ellip5NS_sv_sine_direct_form","-dpdflatex");
close

diary off
movefile ellip5NS_test.diary.tmp ellip5NS_test.diary;
