% peiFIRantisymmetric_flat_hilbert_test.m
% Copyright (C) 2020 Robert G. Jenssen

test_common;

unlink("peiFIRantisymmetric_flat_hilbert_test.diary");
unlink("peiFIRantisymmetric_flat_hilbert_test.diary.tmp");
diary peiFIRantisymmetric_flat_hilbert_test.diary.tmp

strf="peiFIRantisymmetric_flat_hilbert_test";

% Calculate frequency response amplitude
nplot=1024;
w=(0:(nplot-1))'*pi/nplot;
M=25;
kM=1:M;
AM=sin(w).*(1+cumsum(cumprod(((2*kM)-1)./(2*kM)).*(cos(w).^(2*kM)),2));

% Plot
plot(w*0.5/pi,20*log10(AM(:,5:5:M)));
axis([0 0.5 -0.01 0.001])
xlabel("Frequency");
ylabel("Amplitude (dB)");
tstr=sprintf("Amplitude responses of Pei and Wang maximally flat at \
$\\omega=\\frac{\\pi}{2}$ Hilbert filters for M=5,10,...,%d",M);
title(tstr);
text(0.18,-0.002,"M=5")
text(0.04,-0.002,"M=25")
legend("M=5","M=10","M=15","M=20","M=25");
legend("location","northeast");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

%
% Done
%
diary off
movefile peiFIRantisymmetric_flat_hilbert_test.diary.tmp ...
         peiFIRantisymmetric_flat_hilbert_test.diary;

