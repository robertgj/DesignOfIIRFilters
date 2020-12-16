% freq_transform_structure_test.m
% Copyright (C) 2017-2020 Robert G. Jenssen

test_common;

delete("freq_transform_structure_test.diary");
delete("freq_transform_structure_test.diary.tmp");
diary freq_transform_structure_test.diary.tmp


strf="freq_transform_structure_test";

% Filter specification
fap=0.25;tp=3;R=2;nN=8;nD=4;
nsamples=1024;
% Desired response
w=(0:(nsamples-1))'*pi/nsamples;
bw=round(nsamples*fap/0.5);
Hd=[ones(bw,1);zeros(nsamples-bw,1)];
% Band weights
Wd=[ones(bw,1);100*ones(nsamples-bw,1)];
% Initial filter estimate
[ni,di]=butter(nD,fap);
ni=conv(ni,conv([1 2 1],[1 2 1]))/6;
ni=ni(:)/di(1);
di=di(:)/di(1);
ndi=[ni; di(2:end)];
% Unconstrained minimisation
WISEJ([],nN,nD,R,w,Hd,Wd);
opt=optimset("MaxFunEvals",10000,"MaxIter",1000);
[ND, FVEC, INFO, OUTPUT] = fminunc(@WISEJ,ndi,opt);
if (INFO <= 0)
  error("fminunc failed!");
endif
% Create the output polynomials
ND=ND(:)';
n=ND(1:(nN+1));
dR=[1, kron(ND((nN+2):end),[zeros(1,R-1),1])];

% Show low-pass prototype response
[h,w]=freqz(n,dR,nsamples);
plot(0.5*w/pi,20*log10(abs(h)));
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.5 -50 5]);
strt=sprintf("Low-pass prototype : fap=%1.2f", fap);
title(strt);
grid("on");
print(strcat(strf,"_lowpass_response"),"-dpdflatex");
close

% Do a frequency transformation
pA=phi2p([0.1 0.25]);
[nftA,dRftA]=tfp2g(n,dR,pA,-1);
[hftA,w]=freqz(nftA,dRftA,1024);
plot(0.5*w/pi,20*log10(abs(hftA)));
ylabel("Amplitude(dB)")
xlabel("Frequency");
axis([0 0.5 -50 5]);
strt=sprintf("pA=phi2p([0.1 0.25])=[%1.2f %1.2f %1.2f]",pA(1),pA(2),pA(3));
title(strt);
grid("on");
print(strcat(strf,"_bandpass_A_response"),"-dpdflatex");
close

% Do a second frequency transformation
pB=phi2p([0.2 0.3]);
[nftB,dRftB]=tfp2g(n,dR,pB,-1);
[hftB,w]=freqz(nftB,dRftB,1024);
plot(0.5*w/pi,20*log10(abs(hftB)))
ylabel("Amplitude(dB)")
xlabel("Frequency")
axis([0 0.5 -50 5]);
strt=sprintf("pB=phi2p([0.2 0.3])=[%1.2f %1.2f %1.2f]",pB(1),pB(2),pB(3));
title(strt);
grid("on");
print(strcat(strf,"_bandpass_B_response"),"-dpdflatex");
close

% Results
print_polynomial(n,"n");
print_polynomial(dR,"dR");
print_polynomial(pA,"pA");
print_polynomial(nftA,"nftA");
print_polynomial(dRftA,"dRftA");
print_polynomial(pB,"pB");
print_polynomial(nftB,"nftB");
print_polynomial(dRftB,"dRftB");

% Done
diary off
movefile freq_transform_structure_test.diary.tmp ...
         freq_transform_structure_test.diary;
