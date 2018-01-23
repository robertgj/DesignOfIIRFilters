% minphase_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("minphase_test.diary");
unlink("minphase_test.diary.tmp");
diary minphase_test.diary.tmp

format short e

strf="minphase_test";

%
% Using remez.m and Orchard's minphase.m
%
fapl=0.1;fapu=0.2;dBap=1;Wap=1;
fasl=0.05;fasu=0.25;dBas=36;Wasl=2;Wasu=2;
M=15;N=(2*M)+1;
brz=remez(2*M,2*[0 fasl fapl fapu fasu 0.5],[0 0 1 1 0 0],...
          [Wasl Wap Wasu],'bandpass');
brz=brz(:);
% Brute force scaling of brz so that max(abs(Hbrz))==1
Nw=2^16;
[Hbrz,w]=freqz(brz,1,Nw);
[~,ibrz]=max(abs(Hbrz));
if ibrz==1
  ibrz=2;
endif
if ibrz==Nw
  ibrz=Nw-1;
endif
Nwi=16;
delw=(w(ibrz+1)-w(ibrz-1))/(2*Nwi);
w=w(ibrz)+(((-Nwi):Nwi)*delw);
Hbrz=freqz(brz,1,w);
[mbrz,ibrz]=max(abs(Hbrz));
if ibrz~=1 && ibrz ~= length(w)
  % Quadratic interpolation to the maximum
  bp=polyfit(w((ibrz-1):(ibrz+1)),abs(Hbrz((ibrz-1):(ibrz+1))),2);
  mbrz=bp(3)-(0.25*bp(2)*bp(2)/bp(1));
endif
brz=brz/mbrz;
% Find the filter corresponding to |H|^2
bbrz=conv(brz(:),flipud(brz(:)));
% Find the filter corresponding to 1-|H|^2.
bbrzc=[zeros(2*M,1); 1; zeros(2*M,1)]-bbrz;
% By construction, bbrzc has double zeros on the unit circle.
% Use Orchard's routine to find the minimum-phase component of 1-|H|^2
[brzc,ssp,iter]=minphase(bbrzc(N:end));
brzc=brzc(:);
% Sanity checks
tol=10*eps;
if abs(((brz(:)')*brz(:))+((brzc(:)')*brzc(:))-1)>tol
  error("abs(((brz(:)')*brz(:))+((brzc(:)')*brzc(:))-1)>(%g*eps)",tol/eps);
endif
[Hbrz,w]=freqz(brz,1,Nw);
[Hbrzc,w]=freqz(brzc,1,Nw);
if max(abs(abs(Hbrz).^2+abs(Hbrzc).^2-1))>tol
  error("max(abs(abs(Hbrz).^2+abs(Hbrzc).^2-1))>(%g*eps)",tol/eps);
endif
% Plot
plot(w*0.5/pi,20*log10(abs(Hbrz)),"linestyle","-", ...
     w*0.5/pi,20*log10(abs(Hbrzc)),"linestyle","-.")
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -50 1]);
legend("Hbrz","Hbrzc");
legend("location","east");
legend("boxoff");
legend("left");
print(strcat(strf,"_brz_brzc_response"),"-dpdflatex");
close

%
% Print results
%
print_polynomial(brz,"brz",strcat(strf,"_brz_coef.m"),"%15.12f");
print_polynomial(brzc,"brzc",strcat(strf,"_brzc_coef.m"),"%15.12f");

%
% A simple example of using the cepstrum to find the
% minimum phase spectral factor of the squared-magnitude filter
%
% Construct a minimum phase example with zeros on the unit circle
a1=[1 -1 0.5];a2=[1 -0.5];a3=[1 0 0.81];a4=[1 -1];a5=[1 -sqrt(2) 1];
a=conv(conv(conv(conv(a1,a2),a3),a4),a5);
% Construct the squared-magnitude filter for a contour of |z|=alpha
Na=length(a)-1;
alpha=1.05;
aalpha=a.*(alpha.^[0:-1:-Na]);
asq=conv(fliplr(aalpha),aalpha);
% The zero-phase squared-magnitude frequency response is real, positive and even
Hasq=freqz(asq,[zeros(1,Na) 1],4096,"whole");
Hasq=real(Hasq);
% The cepstrum is real and even
hhatasq=ifft(log(Hasq));
hhatasq=real(hhatasq(:)');
% Use the causal part of the cepstrum
ha=zeros(1,Na+1);
ha(1)=exp(hhatasq(1)/2);
for n=2:(Na+1)
  ha(n)=sum([1:(n-1)].*hhatasq(2:n).*fliplr(ha(1:(n-1))))/(n-1);
endfor
% Recover the original minimum-phase impulse response
h=ha.*(alpha.^[0:Na]);

%
% Using the cepstrum of bbrzc given brz
%
% Find the region of convergence for the cepstrum (log) ie: the
% maximum magnitude of the minimum phase zeros within the unit circle
tol=1e-6;
zmin=roots(brz);
zmin_i=find(abs(zmin)>(1+tol));
if 0
  % Unfortunately, F(alpha*z) is not positive with this alpha
  alpha=(1+min(abs(zmin(zmin_i))))/2;
else
  alpha=1;
endif
L=2^(16+ceil(log(N)/log(2)));
% Find the complementary squared-magnitude response on the contour |z|=alpha
brzalpha=(brz(:)').*(alpha.^[0:-1:-(2*M)]);
bbrzcalpha=[zeros(1,2*M) alpha^(-N) zeros(1,2*M)] - ...
           conv(fliplr(brzalpha),brzalpha);
Falpha=freqz(bbrzcalpha,[zeros(1,2*M) 1],L,"whole");
Falpha=real(Falpha);
% Use the real cepstrum to find the minimum phase spectral factor of bbrzc
falphahat=ifft(log(Falpha));
falphahat=real(falphahat(:)');
grzcalpha=zeros(1,N);
grzcalpha(1)=exp(falphahat(1)/2);
for n=2:N
  grzcalpha(n)=sum([1:(n-1)].*falphahat(2:n).*fliplr(grzcalpha(1:(n-1))))/(n-1);
endfor
grzc=grzcalpha.*(alpha.^[0:(2*M)]);
% Sanity check
[Grzc,w]=freqz(grzc,1,Nw);
if max(abs(abs(Hbrz).^2+abs(Grzc).^2-1)) > 75810*eps
  error("max(abs(abs(Hbrz).^2+abs(Grzc).^2-1)) > 75810*eps");
endif
% Combined response with the complementary filter found by the cepstral method
plot(w*0.5/pi, 10*log10(abs(Grzc).^2 + abs(Hbrz).^2));
xlabel("Frequency");
ylabel("Amplitude(dB)");
print(strcat(strf,"_cepstral_combined_response"),"-dpdflatex");
close

% Done
diary off
movefile minphase_test.diary.tmp minphase_test.diary;
