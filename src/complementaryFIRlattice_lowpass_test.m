% complementaryFIRlattice_lowpass_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("complementaryFIRlattice_lowpass_test.diary");
unlink("complementaryFIRlattice_lowpass_test.diary.tmp");
diary complementaryFIRlattice_lowpass_test.diary.tmp

format short e
fstr="complementaryFIRlattice_lowpass_test_%s";

%
% Lowpass filter specification
%
fap=0.1;fas=0.25;
M=15;N=(2*M)+1;
brz1=remez(2*M,2*[0 fap fas 0.5],[1 1 0 0]);

% Find lattice coefficients (brz1 is scaled to |H|<=1 and returned as brz)
[brz,brzc,krz,krzhat]=complementaryFIRlattice(brz1(:));

% Save results
print_polynomial(brz,"brz",sprintf(fstr,"brz_coef.m"),"%12.8f");
print_polynomial(brzc,"brzc",sprintf(fstr,"brzc_coef.m"),"%12.8f");
print_polynomial(krz,"krz",sprintf(fstr,"krz_coef.m"),"%12.8f");
print_polynomial(krzhat,"krzhat",sprintf(fstr,"krzhat_coef.m"),"%12.8f");

% Sanity check on FIR response
nplot=1024;
[Hbrz,wplot]=freqz(brz,1,nplot);
Hbrzc=freqz(brzc,1,wplot);
tol=100*eps;
if max(abs(abs(Hbrz).^2+abs(Hbrzc).^2-1)) > tol
  error("max(abs(abs(Hbrz).^2+abs(Hbrzc).^2-1)) > (%g*eps)",tol/eps);
endif

% Plot FIR response
plot(wplot*0.5/pi,20*log10(abs(Hbrz)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(Hbrzc)),"linestyle","-.")
axis([0 0.5 -100 3]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("Hbrz","Hbrzc");
legend("location","east");
legend("Boxoff");
legend("left");
print(sprintf(fstr,"brz_brzc_response"),"-dpdflatex");
close

% Make a quantised noise signal with standard deviation 0.25
nbits=16;
nscale=2^(nbits-1);
nsamples=2^14;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u); 
u=round(u*nscale);

% Filter
[ykrz ykrzhat xxkrz]=complementaryFIRlatticeFilter(krz,krzhat,u);
print_polynomial(ykrz(1:256),"ykrz",sprintf(fstr,"ykrz.m"),"% 12.4f");
print_polynomial(ykrzhat(1:256),"ykrzhat",sprintf(fstr,"ykrzhat.m"),"% 12.4f");
print_polynomial(std(xxkrz),"stdxxkrz",sprintf(fstr,"stdxxkrz.m"),"% 12.4f");

% Calculate frequency response
nfpts=1024;
nppts=(0:511);
Hkrz=crossWelch(u,ykrz,nfpts);
Hkrzhat=crossWelch(u,ykrzhat,nfpts);

% Plot frequency response
subplot(211);
plot(nppts/nfpts,20*log10(abs(Hkrz)),"linestyle","-", ...
     nppts/nfpts,20*log10(abs(Hkrzhat)),"linestyle","-.");
axis([0 0.5 -100 3])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
legend("Hkrz","Hkrzhat");
legend("location","east");
legend("Boxoff");
legend("left");
subplot(212);
plot(nppts/nfpts,abs(abs(Hkrz).^2+abs(Hkrzhat).^2));
axis([0 0.5 0.9 1.1])
grid("on");
xlabel("Frequency")
ylabel("|Hkrz|^2+|Hkrzhat|^2");
print(sprintf(fstr,"krz_krzhat_response"),"-dpdflatex");
close

% Estimate the complementary FIR lattice transfer functions
we=nppts(:)*pi/length(nppts);
[ebrz,earz] = invfreq(Hkrz(:),we,length(brz)-1,0);
[ebrzc,earzc] = invfreq(Hkrzhat(:),we,length(brzc)-1,0);
% Plot estimated FIR response
Hebrz=freqz(ebrz,1,we);
Hebrzc=freqz(ebrzc,1,we);
subplot(211);
plot(we*0.5/pi,20*log10(abs(Hebrz)),"linestyle","-", ...
     we*0.5/pi,20*log10(abs(Hebrzc)),"linestyle","-.")
axis([0 0.5 -100 3]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("Hebrz","Hebrzc");
legend("location","east");
legend("Boxoff");
legend("left");
subplot(212);
plot(nppts/nfpts,abs(abs(Hebrz).^2+abs(Hebrzc).^2));
axis([0 0.5 0.9 1.1])
grid("on");
xlabel("Frequency")
ylabel("|Hebrz|^2+|Hebrzc|^2");
print(sprintf(fstr,"ebrz_ebrzc_response"),"-dpdflatex");
close

% Filter a sine wave
us=sin(0.05*2*pi*(0:(nsamples-1)));
ysbrz=filter(brz,1,us);
ysbrzc=filter(brzc,1,us);
[yskrz,yskrzhat]=complementaryFIRlatticeFilter(krz,krzhat,us);
tol=10*eps;
if max(abs(ysbrz(:)-yskrz(:))) > tol
  error("max(abs(ysbrz(:)-yskrz(:))) > (%g*eps)",tol/eps);
endif
if max(abs(ysbrzc(:)-yskrzhat(:))) > tol
  error("max(abs(ysbrzc(:)-yskrzhat(:))) > (%g*eps)",tol/eps);
endif

% By trial-and-error, this gives better state variable scaling
pkrz=krz;
pkrzhat=krzhat;
tmp=pkrz(1); pkrz(1)=-pkrzhat(1); pkrzhat(1)=tmp;
tmp=pkrz(end); pkrz(end)=pkrzhat(end); pkrzhat(end)=-tmp;

% Find the corresponding state variable description
[Ap,Bp,Cpkrz,Dpkrz,Cpkrzhat,Dpkrzhat]=complementaryFIRlattice2Abcd(pkrz,pkrzhat);

% Find corresponding filter polynomials
pbkrz=Abcd2tf(Ap,Bp,Cpkrz,Dpkrz);
pbkrzhat=Abcd2tf(Ap,Bp,Cpkrzhat,Dpkrzhat);
tol=10*eps;
if max(abs(brz(:)-pbkrz(:))) > tol
  error("max(abs(brz(:)-pbkrz(:))) > (%g*eps)",tol/eps);
endif
if max(abs(brzc(:)-flipud(pbkrzhat(:)))) > tol
  error("max(abs(brz(:)-flipud(pbkrzhat(:)))) > (%g*eps)",tol/eps);
endif

% Filter (brz=-pbkrz and brzc=-flipud(pbrzkhat) so phase responses differ)
[ypkrz ypkrzhat xxpkrz]=complementaryFIRlatticeFilter(pkrz,pkrzhat,u);
print_polynomial(ypkrz(1:256),"ypkrz",sprintf(fstr,"ypkrz.m"),"% 12.4f");
print_polynomial ...
  (ypkrzhat(1:256),"ypkrzhat",sprintf(fstr,"ypkrzhat.m"),"% 12.4f");
print_polynomial(std(xxpkrz),"stdxxpkrz",sprintf(fstr,"stdxxpkrz.m"),"% 12.4f");

% Calculate frequency response
nfpts=1024;
nppts=(0:511);
Hpkrz=crossWelch(u,ypkrz,nfpts);
Hpkrzhat=crossWelch(u,ypkrzhat,nfpts);

% Plot frequency response
subplot(211);
plot(nppts/nfpts,20*log10(abs(Hpkrz)),"linestyle","-", ...
     nppts/nfpts,20*log10(abs(Hpkrzhat)),"linestyle","-.");
axis([0 0.5 -100 3])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
legend("Hpkrz","Hpkrzhat");
legend("location","east");
legend("Boxoff");
legend("left");
subplot(212);
plot(nppts/nfpts,abs(abs(Hpkrz).^2+abs(Hpkrzhat).^2));
axis([0 0.5 0.9 1.1])
grid("on");
xlabel("Frequency")
ylabel("|Hpkrz|^2+|Hpkrzhat|^2");
print(sprintf(fstr,"pkrz_pkrzhat_response"),"-dpdflatex");
close

% Done
diary off
movefile complementaryFIRlattice_lowpass_test.diary.tmp ...
         complementaryFIRlattice_lowpass_test.diary;
