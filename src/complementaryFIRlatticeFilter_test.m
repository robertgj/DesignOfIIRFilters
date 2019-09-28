% complementaryFIRlatticeFilter_test.m
% Copyright (C) 2017,2018 Robert G. Jenssen

test_common;

unlink("complementaryFIRlatticeFilter_test.diary");
unlink("complementaryFIRlatticeFilter_test.diary.tmp");
diary complementaryFIRlatticeFilter_test.diary.tmp


strf="complementaryFIRlatticeFilter_test";

%{
% Remez filter from Vaidyanathan Example 1
N=61;fp=0.088;fs=0.135;rap=0.0013;ras=10^(-32/20);
b=remez(N-1,2*[0 fp fs 0.5],[1 1 0 0]);

% k and khat from Vaidyanathan Example 1, Table 1
kv=[     0.002331  0.999871  0.999939  0.999974 -1.000000 -0.999956 ...
        -0.999894 -0.999927 -0.999999  0.999926  0.999762  0.999793 ...
         0.999981 -0.999889 -0.999505 -0.999481 -0.999915  0.999824 ...
         0.998941  0.998748  0.999760 -0.999587 -0.997249 -0.996791 ...
        -0.999647  0.997416  0.987856  0.991294 -0.995787 -0.867826 ...
        -0.713467 ]';
khatv=[  0.999997  0.016038  0.011081  0.007208  0.000000  0.009332 ...
         0.014533  0.012089  0.001686  0.012183  0.021803  0.020337 ...
         0.006167  0.014912  0.031474  0.032228  0.013047  0.018739 ...
         0.046000  0.050015  0.021926  0.028726  0.074126  0.080049 ...
         0.026561  0.071841  0.155375  0.131669  0.091698  0.496868 ...
         0.700689 ]';
Nkv=length(kv);
kv=[kv; kv((Nkv-1):-1:1)];
khatv=[khatv; khatv((Nkv-1):-1:1)];
tol=1e-6;
if max(abs(kv.^2+khatv.^2-1)) > tol
  error("max(abs(kv.^2+khatv.^2-1)) > tol");
endif
%}

%
% Lowpass filter specification
%
fap=0.1;fas=0.25;
M=15;N=(2*M)+1;
brz1=remez(2*M,2*[0 fap fas 0.5],[1 1 0 0]);

% Find lattice coefficients (brz1 is scaled to |H|<=1 and returned as brz)
[brz,brzc,krz,krzhat]=complementaryFIRlattice(brz1(:));

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
print_polynomial(ykrz(1:256),"ykrz",strcat(strf,"_ykrz.m"),"% 12.4f");
print_polynomial(ykrzhat(1:256),"ykrzhat",strcat(strf,"_ykrzhat.m"),"% 12.4f");
print_polynomial(std(xxkrz),"stdxxkrz",strcat(strf,"_stdxxkrz.m"),"% 12.4f");

% Compare
ybrz=filter(brz,1,u);
ybrzc=filter(brzc,1,u);
tol=1e-10;
if max(abs(ybrz(:)-ykrz(:))) > tol
  error("max(abs(ybrz(:)-ykrz(:))) (%g) > %g",
        max(abs(ybrz(:)-ykrz(:))),tol);
endif
if max(abs(ybrzc(:)-ykrzhat(:))) > tol
  error("max(abs(ybrzc(:)-ykrzhat(:))) (%g) > %g",
        max(abs(ybrzc(:)-ykrzhat(:))),tol);
endif

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
legend("boxoff");
legend("left");
subplot(212);
plot(nppts/nfpts,abs(abs(Hkrz).^2+abs(Hkrzhat).^2));
axis([0 0.5 0.9 1.1])
grid("on");
xlabel("Frequency")
ylabel("|Hkrz|^2+|Hkrzhat|^2");
print(strcat(strf,"_krz_krzhat_response"),"-dpdflatex");
close

% Filter with 3-signed-digit coefficients
ndigits=3;
sdkrz=flt2SD(krz,nbits,ndigits);
sdkrzhat=flt2SD(krzhat,nbits,ndigits);
[ysdkrz ysdkrzhat xxsdkrz] = ...
  complementaryFIRlatticeFilter(sdkrz,sdkrzhat,u,"round");
print_polynomial(ysdkrz(1:256),"ysdkrz",strcat(strf,"_ysdkrz.m"),"% 12.4f");
print_polynomial ...
  (ysdkrzhat(1:256),"ysdkrzhat",strcat(strf,"_ysdkrzhat.m"),"% 12.4f");
print_polynomial ...
  (std(xxsdkrz),"stdxxsdkrz",strcat(strf,"_stdxxsdkrz.m"),"% 12.4f");

% Calculate frequency response
nfpts=1024;
nppts=(0:511);
Hsdkrz=crossWelch(u,ysdkrz,nfpts);
Hsdkrzhat=crossWelch(u,ysdkrzhat,nfpts);

% Plot frequency response
subplot(211);
plot(nppts/nfpts,20*log10(abs(Hsdkrz)),"linestyle","-", ...
     nppts/nfpts,20*log10(abs(Hsdkrzhat)),"linestyle","-.");
axis([0 0.5 -100 3])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
legend("Hsdkrz","Hsdkrzhat");
legend("location","northeast");
legend("boxoff");
legend("left");
subplot(212);
plot(nppts/nfpts,abs(abs(Hsdkrz).^2+abs(Hsdkrzhat).^2));
axis([0 0.5 0.9 1.1])
grid("on");
xlabel("Frequency")
ylabel("|Hsdkrz|^2+|Hsdkrzhat|^2");
print(strcat(strf,"_sdkrz_sdkrzhat_response"),"-dpdflatex");
close

% Direct form filter with 3-signed-digit coefficients
ndigits=3;
sdbrz=flt2SD(brz,nbits,ndigits);
sdbrzc=flt2SD(brzc,nbits,ndigits);
ysdbrz=round(filter(sdbrz,1,u));
ysdbrzc=round(filter(sdbrzc,1,u));

% Calculate frequency response
nfpts=1024;
nppts=(0:511);
Hsdbrz=crossWelch(u,ysdbrz,nfpts);
Hsdbrzc=crossWelch(u,ysdbrzc,nfpts);

% Plot frequency response
subplot(211);
plot(nppts/nfpts,20*log10(abs(Hsdbrz)),"linestyle","-", ...
     nppts/nfpts,20*log10(abs(Hsdbrzc)),"linestyle","-.");
axis([0 0.5 -100 3])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
legend("Hsdbrz","Hsdbrzc");
legend("location","southeast");
legend("boxoff");
legend("left");
subplot(212);
plot(nppts/nfpts,abs(abs(Hsdbrz).^2+abs(Hsdbrzc).^2));
axis([0 0.5 0.9 1.1])
grid("on");
xlabel("Frequency")
ylabel("|Hsdbrz|^2+|Hsdbrzc|^2");
print(strcat(strf,"_sdbrz_sdbrzc_response"),"-dpdflatex");
close

% Filter a sine wave
us=sin(0.05*2*pi*(0:(nsamples-1)));
ybrz=filter(brz,1,us);
ybrzc=filter(brzc,1,us);
[ykrz,ykrzhat]=complementaryFIRlatticeFilter(krz,krzhat,us);
tol=10*eps;
if max(abs(ybrz(:)-ykrz(:))) > tol
  error("max(abs(ybrz(:)-ykrz(:))) > (%g*eps)",tol/eps);
endif
if max(abs(ybrzc(:)-ykrzhat(:))) > tol
  error("max(abs(ybrzc(:)-ykrzhat(:))) > (%g*eps)",tol/eps);
endif

% Done
diary off
movefile complementaryFIRlatticeFilter_test.diary.tmp ...
         complementaryFIRlatticeFilter_test.diary;
