% vaidyanathan_allpass_example_test.m
% Copyright (C) 2017-2024 Robert G. Jenssen
% Example from Section V of "A New Approach to the Realization of
% Low-Sensitivity IIR Digital Filters", P. P. Vaidyanathan, S.K. Mitra,
% Y. Neuvo, IEEE Transactions on Acoustics, Speech and Signal Processing,
% Vol. ASSP-34. No. 2, April I986, pp. 350-361.

test_common;

strf="vaidyanathan_allpass_example_test";
delete(strcat(strf,".diary.tmp"));
delete(strcat(strf,".diary"));
eval(sprintf("diary %s.diary.tmp",strf));


P=0.13494*[1, 1.73306, 2.83075, 2.83075, 1.73306, 1];
D=[1, -0.7004, 1.42787, -0.57995, 0.40866, -0.05463];
Q=spectralfactor(P,D);
PQ=P+Q;
Z=qroots(PQ);
A1=[1];
A2=[1];
for m=1:length(Z)
  if abs(Z(m)) == 1
    error("All-pass pole on unit circle!");
  elseif abs(Z(m)) > 1
    A1=conv(A1, [-1/Z(m) 1]);
  else
    A2=conv(A2, [-Z(m) 1]);
  endif
endfor

[G1,w]=freqz(A1,flipud(A1(:)),1024);
G2=freqz(A2,flipud(A2(:)),w);
if max(1-(((abs(G1).^2)+(abs(G2).^2))/2)) > 10*eps
  error("max(1-(((abs(G1).^2)+(abs(G2).^2))/2)) > 10*eps");
endif

diary off

movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
