% schur_retimed_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("schur_retimed_test.diary");
unlink("schur_retimed_test.diary.tmp");
diary schur_retimed_test.diary.tmp


strf="schur_retimed_test";

% Filter specification
fap=0.05;R=2;nN=4;nD=nN/R;
nsamples=1024;
% Desired response
w=(0:(nsamples-1))'*pi/nsamples;
bw=round(nsamples*fap/0.5);
Hd=[ones(bw,1);zeros(nsamples-bw,1)];
% Band weights
Wd=[100*ones(bw,1);ones(nsamples-bw,1)];
% Initial filter estimate
[ni,di]=butter(nD,fap*5);
if nD==1
  ni=conv(ni,[1 1])/4;
elseif nD==2
  ni=conv(ni,[1 2 1])/4;
elseif nD==3
  ni=conv(ni,[1 3 3 1])/4;
endif
ni=ni(:)/di(1);
di=di(:)/di(1);
ndi=[ni;di(2:end)];
% Unconstrained minimisation
WISEJ([],nN,nD,R,w,Hd,Wd);
[ND, FVEC, INFO, OUTPUT] = fminunc(@WISEJ,ndi);
if (INFO <= 0)
  error("fminunc failed!");
endif
% Create the output polynomials
ND=ND(:);
n=ND(1:(nN+1));
d=ND((nN+2):end);
dR=[1; kron(ND((nN+2):end), [zeros(R-1,1);1])];
% Show response
[h,w]=freqz(n,dR,nsamples);
plot(0.5*w/pi,20*log10(abs(h)));
ylabel("Amplitude(dB)");
xlabel("Frequency");
axis([0 0.5 -40 5]);
grid("on");
print(strcat(strf,"_expected_response"),"-dpdflatex");
close

% Schur decomposition
[s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n,dR)

% Retimed Schur lattice
sA=[...
% x1     x2     x3     x4     x5     x6     x7     x8     x9     x10    x11
  0      0      1      0      0      0      0      0      0      0      0;
  s11(1) 0      s10(1) 0      0      0      0      0      0      0      0;
  s02(2) 0      0      0      0      0      0      0      s00(2) 0      0;
  0      0      0      0      0      0      0      0      1      0      0;
  0      0      0      0      0      0      0      0      1      0      0;
  0      s11(2) 0      s10(2) 0      0      0      0      0      0      0;
  s22(2) 0      0      0      0      0      0      0      s20(2) 0      0;
  0      0      0      0      s10(3) s11(3) 0      0      0      0      0;
  0      0      0      0      0      0      s02(4) 0      0      0      0;
  0      0      0      0      0      0      0      0      0      0      1;
  0      0      0      0      0      0      0      0      0      0      0];
sB=[...
  0      0      0      0      0      0      0      0      s00(4) 0      1]';
sC=[...
  0      0      0      0      0      0      0      s11(4) 0      s10(4) 0];
sD=0;
sCap=[...
  0      0      0      0      0      0      s22(4) 0      0      0      0];
sDap=s20(4);

% Compare retimed Schur lattice response to the transfer function
[sn,sdR]=Abcd2tf(sA,sB,sC,sD)
% Check transfer function
printf("max(abs(sn(3:7)-n'))=%f\n",max(abs(sn(3:7)-n')));
printf("max(abs(sdR(1:5)-dR'))=%f\n",max(abs(sdR(1:5)-dR')));

% Noise gain of the Schur retimed lattice
[sK,sW]=KW(sA,sB,sC,sD);
ngABCD=sum(diag(sK).*diag(sW).*[0 1 1 0 0 1 1 1 1 0 0]')
[sKap,sWap]=KW(sA,sB,sCap,sDap);
ngABCDap=sum(diag(sKap).*diag(sWap).*[0 0 1 0 0 0 1 0 1 0 0]')

% Simulate the Schur retimed lattice
% Make a quantised noise signal with standard deviation 0.25*2^nbits
nbits=10;
scale=2^(nbits-1);
nsamples=2^14;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=0.25*u/std(u);
u=round(u*scale);

% Filter
[yABCD,xxABCD]=svf(sA,sB,sC,sD,u,"none");
[yABCDf,xxABCDf]=svf(sA,sB,sC,sD,u,"round");
[yABCDap,xxABCDap]=svf(sA,sB,sCap,sDap,u,"none");
[yABCDfap,xxABCDfap]=svf(sA,sB,sCap,sDap,u,"round");

% Check output round-off noise variance
est_varyd=(1+ngABCD)/12
varyd=var(yABCD-yABCDf)
est_varydap=(1+ngABCDap)/12
varydap=var(yABCDap-yABCDfap)

% Check state variable std. deviation
stdxx=std(xxABCD)

% Plot frequency response
nfpts=1024;
nppts=(0:511);
HABCDf=crossWelch(u,yABCDf,nfpts);
plot(nppts/nfpts,20*log10(abs(HABCDf)));
xlabel("Frequency");
ylabel("Amplitude(dB)");
axis([0 0.5 -40 5]);
grid("on");
print(strcat(strf,"_output_response"),"-dpdflatex");
close

diary off
movefile schur_retimed_test.diary.tmp schur_retimed_test.diary;
