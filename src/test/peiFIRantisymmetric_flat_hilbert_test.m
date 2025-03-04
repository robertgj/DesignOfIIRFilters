% peiFIRantisymmetric_flat_hilbert_test.m
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

delete("peiFIRantisymmetric_flat_hilbert_test.diary");
delete("peiFIRantisymmetric_flat_hilbert_test.diary.tmp");
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
text(0.02,-0.002,"M=25")
legend("M=5","M=10","M=15","M=20","M=25");
legend("location","south");
legend("boxoff");
legend("left");
grid("on");
print(strcat(strf,"_response"),"-dpdflatex");
close

% Calculate filter coefficients
hM=cell(1,5);
for m=1:5,
  M=5*m;
  h=[zeros(1,2*M),1,zeros(1,2*M)]; 
  hterm=1;
  kterm=1;
  for k=1:M,
    hterm=conv(hterm,[1 0 2 0 1])/4;
    kterm=kterm*((2*k)-1)/(2*k);
    h=h+(kterm*conv([zeros(1,2*(M-k)),1,zeros(1,2*(M-k))],hterm));
  endfor
  hM{m}=-conv(h,[1 0 -1])/2;
  % Sanity check
  tol=5e-15;
  HM=freqz(hM{m},1,w);
  HM=HM(:);
  AMM=AM(:,M);
  if max(abs(abs(HM)-AMM))>tol
    error("max(abs(abs(HM)-AMM))(%g)>tol(%g)",max(abs(abs(HM)-AMM)),tol);
  endif
  % Save filter coefficients
  print_polynomial(hM{m},sprintf("h%d",M),"%15.12f");
  print_polynomial(hM{m},sprintf("h%d",M),sprintf("%s_h%d_coef.m",strf,M), ...
                   "%15.12f");
endfor

% Save filter coefficients
save peiFIRantisymmetric_flat_hilbert_test.mat hM

%
% Done
%
diary off
movefile peiFIRantisymmetric_flat_hilbert_test.diary.tmp ...
         peiFIRantisymmetric_flat_hilbert_test.diary;

