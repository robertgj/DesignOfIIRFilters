% complementaryFIRlattice_bandpass_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("complementaryFIRlattice_bandpass_test.diary");
delete("complementaryFIRlattice_bandpass_test.diary.tmp");
diary complementaryFIRlattice_bandpass_test.diary.tmp


strf="complementaryFIRlattice_bandpass_test";

%
% Filter from iir_sqp_slb_fir_17_bandpass_test.m
%
Ud1=2;Vd1=0;Md1=14;Qd1=0;Rd1=1;
d1 = [   0.0920209477, ...
         0.9990000000,   0.5128855702, ...
         0.7102414018,   0.9990000000,   0.9990000000,   0.9990000000, ... 
         0.9990000000,   0.9990000000,   0.9990000000, ...
        -0.9667931503,   0.2680255295,   2.2176753593,   3.3280228348, ... 
         3.7000375301,   4.4072989555,   4.6685041037 ]';
[b17b1,a17b1]=x2tf(d1,Ud1,Vd1,Md1,Qd1,Rd1);
nb17b=length(b17b1);

% Find lattice coefficients (b17b1 is scaled to |H|<=1 and returned as b17b)
[b17b,b17bc,k17b,k17bhat]=complementaryFIRlattice(b17b1(:));

% Save results
print_polynomial(b17b,"b17b",strcat(strf,"_b17b_coef.m"),"%12.8f");
print_polynomial(b17bc,"b17bc",strcat(strf,"_b17bc_coef.m"),"%12.8f");
print_polynomial(k17b,"k17b",strcat(strf,"_k17b_coef.m"),"%12.8f");
print_polynomial(k17bhat,"k17bhat",strcat(strf,"_k17bhat_coef.m"),"%12.8f");

% Sanity check on FIR response
nplot=1024;
[Hb17b,wplot]=freqz(b17b,1,nplot);
Hb17bc=freqz(b17bc,1,wplot);
tol=10*eps;
if max(abs(abs(Hb17b).^2+abs(Hb17bc).^2-1)) > tol
  error("max(abs(abs(Hb17b).^2+abs(Hb17bc).^2-1)) > (%g*eps)",tol/eps);
endif

% Plot FIR response
plot(wplot*0.5/pi,20*log10(abs(Hb17b)),"linestyle","-", ...
     wplot*0.5/pi,20*log10(abs(Hb17bc)),"linestyle","-.")
axis([0 0.5 -40 3]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("Hb17b","Hb17bc");
legend("location","east");
legend("boxoff");
legend("left");
print(strcat(strf,"_b17b_b17bc_response"),"-dpdflatex");
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
[yk17b yk17bhat xxk17b]=complementaryFIRlatticeFilter(k17b,k17bhat,u);
print_polynomial(yk17b(1:256),"yk17b",strcat(strf,"_yk17b.m"),"% 12.4f");
print_polynomial ...
  (yk17bhat(1:256),"yk17bhat",strcat(strf,"_yk17bhat.m"),"% 12.4f");
print_polynomial(std(xxk17b),"stdxxk17b",strcat(strf,"_stdxxk17b.m"),"% 12.4f");

% Calculate frequency response
nfpts=1024;
nppts=(0:511);
Hk17b=crossWelch(u,yk17b,nfpts);
Hk17bhat=crossWelch(u,yk17bhat,nfpts);

% Plot frequency response
subplot(211);
plot(nppts/nfpts,20*log10(abs(Hk17b)),"linestyle","-", ...
     nppts/nfpts,20*log10(abs(Hk17bhat)),"linestyle","-.");
axis([0 0.5 -40 3])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
legend("Hk17b","Hk17bhat");
legend("location","east");
legend("boxoff");
legend("left");
subplot(212);
plot(nppts/nfpts,abs(abs(Hk17b).^2+abs(Hk17bhat).^2));
axis([0 0.5 0.98 1.02])
grid("on");
xlabel("Frequency")
ylabel("|Hk17b|^2+|Hk17bhat|^2");
print(strcat(strf,"_k17b_k17bhat_response"),"-dpdflatex");
close

% Estimate the complementary FIR lattice transfer functions
we=nppts(:)*pi/length(nppts);
[eb17b,ea17b] = invfreq(Hk17b(:),we,length(b17b)-1,0);
[eb17bc,ea17bc] = invfreq(Hk17bhat(:),we,length(b17bc)-1,0);
% Plot estimated FIR response
Heb17b=freqz(eb17b,1,we);
Heb17bc=freqz(eb17bc,1,we);
subplot(211);
plot(we*0.5/pi,20*log10(abs(Heb17b)),"linestyle","-", ...
     we*0.5/pi,20*log10(abs(Heb17bc)),"linestyle","-.")
axis([0 0.5 -40 3]);
grid("on");
xlabel("Frequency");
ylabel("Amplitude(dB)");
legend("Heb17b","Heb17bc");
legend("location","east");
legend("boxoff");
legend("left");
subplot(212);
plot(nppts/nfpts,abs(abs(Heb17b).^2+abs(Heb17bc).^2));
axis([0 0.5 0.98 1.02])
grid("on");
xlabel("Frequency")
ylabel("|Heb17b|^2+|Heb17bc|^2");
print(strcat(strf,"_eb17b_eb17bc_response"),"-dpdflatex");
close

% Filter a sine wave
us=sin(0.05*2*pi*(0:(nsamples-1)));
ysb17b=filter(b17b,1,us);
ysb17bc=filter(b17bc,1,us);
[ysk17b,ysk17bhat]=complementaryFIRlatticeFilter(k17b,k17bhat,us);
tol=10*eps;
if max(abs(ysb17b(:)-ysk17b(:))) > tol
  error("max(abs(ysb17b(:)-ysk17b(:))) > (%g*eps)",tol/eps);
endif
if max(abs(ysb17bc(:)-ysk17bhat(:))) > tol
  error("max(abs(ysb17bc(:)-ysk17bhat(:))) > (%g*eps)",tol/eps);
endif

% By trial-and-error, this gives better state variable scaling, but
% the resulting filter is not minimum-phase and does not implement b17b
pk17b=k17b;
pk17bhat=k17bhat;
tmp=pk17b(1); pk17b(1)=-pk17bhat(1); pk17bhat(1)=tmp;
tmp=pk17b(end); pk17b(end)=pk17bhat(end); pk17bhat(end)=-tmp;

% Find the corresponding state variable description
[Ap,Bp,Cpk17b,Dpk17b,Cpk17bhat,Dpk17bhat] = ...
  complementaryFIRlattice2Abcd(pk17b,pk17bhat);

% Find corresponding filter polynomials
[pbk17b,~]=Abcd2tf(Ap,Bp,Cpk17b,Dpk17b);
[pbk17bhat,~]=Abcd2tf(Ap,Bp,Cpk17bhat,Dpk17bhat);
tol=10*eps;
if max(abs(b17b(:)-flipud(pbk17b(:)))) > tol
  error("max(abs(b17b(:)-flipud(pbk17b(:)))) > (%g*eps)",tol/eps);
endif
if max(abs(b17bc(:)-flipud(pbk17bhat(:)))) > tol
  error("max(abs(b17b(:)-flipud(pbk17bhat(:)))) > (%g*eps)",tol/eps);
endif

% Plot group delay
Tb17b=delayz(b17b,1,wplot);
Tpbk17b=delayz(pbk17b,1,wplot);
plot(wplot*0.5/pi,Tb17b,"linestyle","-", ...
     wplot*0.5/pi,Tpbk17b,"linestyle","-.")
axis([0 0.5 0 16])
grid("on");
xlabel("Frequency");
ylabel("Delay(samples)");
legend("Tb17b","Tpbk17b");
legend("location","west");
legend("boxoff");
legend("left");
print(strcat(strf,"_Tb17b_Tpbk17b_response"),"-dpdflatex");
close

% Filter (b17b=-pbk17b and b17bc=-flipud(pb17bkhat) so phase responses differ)
[ypk17b ypk17bhat xxpk17b]=complementaryFIRlatticeFilter(pk17b,pk17bhat,u);
print_polynomial(ypk17b(1:256),"ypk17b",strcat(strf,"_ypk17b.m"),"% 12.4f");
print_polynomial ...
  (ypk17bhat(1:256),"ypk17bhat",strcat(strf,"_ypk17bhat.m"),"% 12.4f");
print_polynomial ...
  (std(xxpk17b),"stdxxpk17b",strcat(strf,"_stdxxpk17b.m"),"% 12.4f");

% Calculate frequency response
nfpts=1024;
nppts=(0:511);
Hpk17b=crossWelch(u,ypk17b,nfpts);
Hpk17bhat=crossWelch(u,ypk17bhat,nfpts);

% Plot frequency response
subplot(211);
plot(nppts/nfpts,20*log10(abs(Hpk17b)),"linestyle","-", ...
     nppts/nfpts,20*log10(abs(Hpk17bhat)),"linestyle","-.");
axis([0 0.5 -40 3])
grid("on");
xlabel("Frequency")
ylabel("Amplitude(dB)")
legend("Hpk17b","Hpk17bhat");
legend("location","east");
legend("boxoff");
legend("left");
subplot(212);
plot(nppts/nfpts,abs(abs(Hpk17b).^2+abs(Hpk17bhat).^2));
axis([0 0.5 0.98 1.02])
grid("on");
xlabel("Frequency")
ylabel("|Hpk17b|^2+|Hpk17bhat|^2");
print(strcat(strf,"_pk17b_pk17bhat_response"),"-dpdflatex");
close

% Done
diary off
movefile complementaryFIRlattice_bandpass_test.diary.tmp ...
         complementaryFIRlattice_bandpass_test.diary;
