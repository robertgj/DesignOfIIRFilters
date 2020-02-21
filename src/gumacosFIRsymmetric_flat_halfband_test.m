% gumacosFIRsymmetric_flat_halfband_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

unlink("gumacosFIRsymmetric_flat_halfband_test.diary");
unlink("gumacosFIRsymmetric_flat_halfband_test.diary.tmp");
diary gumacosFIRsymmetric_flat_halfband_test.diary.tmp

strf="gumacosFIRsymmetric_flat_halfband_test";

%
% Calculate Gumacos half-band filter coefficients and responses
%
nplot=2048;
f=((0:nplot-1)')*0.5/nplot;
w=2*pi*f;
nresp=5;
H=zeros(nplot,nresp);
HH=zeros(nplot,nresp);
for k=1:nresp,
   % Halfband filter
  M=k*5;
  h=gumacosFIRsymmetric_flat_halfband(M);

  % Corresponding Hilbert filter
  hh=zeros(size(h));
  hh(1:2:(2*M+1))=-2*abs(h(1:2:(2*M+1)));
  hh(2*M+2)=0;
  hh((2*M+3):2:end)=2*abs(h((2*M+3):2:end));

  % Calculate responses
  H(:,k)=freqz(h,1,w);
  HH(:,k)=freqz(hh,1,w);
  
  % Save results
  print_polynomial(h,sprintf("h%d",M),"%15.12f");
  print_polynomial(h,"h",sprintf("%s_h%d_coef.m",strf,M),"%15.12f");
endfor

%
% Plot results
%

% Half-band filter
plot(f,20*log10(abs(H)))
axis([0 0.5 -100 1])
grid("on");
xlabel("Frequency");
ylabel("Amplitude (dB)");
title("Gumacos maximally-flat half-band filters : M=5,10,15,20 and 25");
legend("M=5","M=10","M=15","M=20","M=25");
legend("location","northeast");
legend("boxoff");
legend("left");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Corresponding Hilbert filter
plot(f,20*log10(abs(HH)))
axis([0 0.5 -0.01 0.001])
grid("on");
xlabel("Frequency");
title("Gumacos maximally-flat Hilbert filters : M=5,10,15,20 and 25");
ylabel("Amplitude (dB)");
legend("M=5","M=10","M=15","M=20","M=25");
legend("location","northeast");
legend("boxoff");
legend("left");
print(strcat(strf,"_hilbert"),"-dpdflatex");
close

%
% Done
%
diary off
movefile gumacosFIRsymmetric_flat_halfband_test.diary.tmp ...
         gumacosFIRsymmetric_flat_halfband_test.diary;

