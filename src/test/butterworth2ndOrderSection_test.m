% butterworth2ndOrderSection_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen

test_common;

delete("butterworth2ndOrderSection_test.diary");
delete("butterworth2ndOrderSection_test.diary.tmp");
diary butterworth2ndOrderSection_test.diary.tmp


% Filter specification
n=7;
fs=2000;
fc=400;

% Pole angles
if mod(n,2)
  thetak=0.5*pi*(1+(((2*(((n+3)/2):n))-1)/n));
else
  thetak=0.5*pi*(1+(((2*(((n/2)+1):n))-1)/n));
endif

% Prewarp analog filter
T=1/fs;
Wc=2*pi*fc;
wc=(2/T)*tan(Wc*T/2);
wcT2=wc*T/2;

% Bilinear transform of analog filter
p0=1-(2*wcT2*cos(thetak))+(wcT2^2);
p1=-2+(2*((wcT2)^2));
p1=p1./p0;
p2=1+(2*wcT2*cos(thetak))+(wcT2^2);
p2=p2./p0;

% Denominator of digital filter from first and second order sections
if mod(n,2)
  n2s=(n-1)/2;
  denom=[1 (wcT2-1)/(1+wcT2)];
else
  n2s=n/2;
  denom=1;
endif
for k=1:n2s,
  denom=conv(denom,[1 p1(k) p2(k)]);
endfor

% Compare with builtin function
[b,a]=butter(n,2*fc/fs);
[z,p,g]=butter(n,2*fc/fs);

% Check
if max(abs(a-denom))>2*eps
  error("max(abs(a-denom))>2*eps");
endif

% Done
diary off
movefile butterworth2ndOrderSection_test.diary.tmp butterworth2ndOrderSection_test.diary;
