% contfrac_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("contfrac_test.diary");
unlink("contfrac_test.diary.tmp");
diary contfrac_test.diary.tmp

format short e

N=5
fc=0.05
dBap=0.1;
dBas=40;
[b,a]=ellip(N,dBap,dBas,2*fc);

[Acf,Bcf,Ccf,Dcf]=contfrac(b,a)

[bcf,acf]=Abcd2tf(Acf,Bcf,Ccf,Dcf);
printf("max(abs(b-bcf))=%f\n",max(abs(b-bcf)));
printf("max(abs(a-acf))=%f\n",max(abs(a-acf)));

% Check the continued fraction state variable form noise gain
% (Note that no attempt has been made to use the N-1 free parameters
% to optimise noise gain).
[Kcf,Wcf]=KW(Acf,Bcf,Ccf,Dcf);
ngcf=sum(diag(Kcf).*diag(Wcf))

% Compare the direct form state variable noise gain
[Adir,Bdir,Cdir,Ddir]=tf2Abcd(b,a);
[Kdir,Wdir]=KW(Adir,Bdir,Cdir,Ddir);
ngdir=sum(diag(Kdir).*diag(Wdir))
% Check
delta=4;
[Toptdir,Koptdir,Woptdir]=optKW(Kdir,Wdir,delta);
ngoptdir=sum(diag(Koptdir).*diag(Woptdir))

% Compare with the optimised noise gain with state scaling by 4
[Topt,Kopt,Wopt]=optKW(Kcf,Wcf,delta);
ngopt=sum(diag(Kopt).*diag(Wopt))

% Make a quantised noise signal with standard deviation 0.25*2^nbits
nbits=10;
scale=2^(nbits-1);
nsamples=2^14;
rand("seed",0xdeadbeef);
u=rand(nsamples,1)-0.5;
u=u/std(u);
u=u/delta;
u=round(u*scale);

% Filter
ycf=svf(Acf,Bcf,Ccf,Dcf,u,"none");
ycf_f=svf(Acf,Bcf,Ccf,Dcf,u,"round");

% Plot frequency response
nfpts=1024;
nppts=(0:511);
Hcf=crossWelch(u,ycf,nfpts);
subplot(111);
plot(nppts/nfpts,20*log10(abs(Hcf)))
xlabel("Frequency")
ylabel("Amplitude(dB)")
axis([0 0.5 -50 5]);
title(sprintf("Simulated response of a continued-fraction elliptic filter : \
fc=%g,dBap=%g,dBas=%g",fc,dBap,dBas));
grid("on");
print("contfrac_test_response","-dpdflatex");
%print("contfrac_test_response","-dsvg");
close

% Check output round-off noise variance
est_varydcf=(1+(delta*ngcf))/12
varydcf=var(ycf-ycf_f)

% Done
diary off
movefile contfrac_test.diary.tmp contfrac_test.diary;
