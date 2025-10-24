% vlcekFIRsymmetric_flat_lowpass_test.m
% Design a maximally-flat FIR filter with the algorithm of Vlcek et al. 
%
% Copyright (C) 2020-2025 Robert G. Jenssen

test_common;

delete("vlcekFIRsymmetric_flat_lowpass_test.diary");
delete("vlcekFIRsymmetric_flat_lowpass_test.diary.tmp");
diary vlcekFIRsymmetric_flat_lowpass_test.diary.tmp

strf="vlcekFIRsymmetric_flat_lowpass_test";

tol=eps;
for M=18:19,
  for K=11:12,
    hMh=herrmannFIRsymmetric_flat_lowpass(M,K);
    hMv=vlcekFIRsymmetric_flat_lowpass(M,K);
    if norm(hMh-hMv)>tol
      error("M=%d,K=%d,norm(hMh-hMv)(%g)>tol(%g)",M,K,norm(hMh-hMv),tol);
    endif
  endfor
endfor

M=300;
K=10:20:(M-10);
nplot=1000;
f=(0:nplot)'*0.5/nplot;
w=2*pi*f;
Av=zeros(length(f),length(K));
for k=1:length(K),
  hMv=vlcekFIRsymmetric_flat_lowpass(M,K(k));
  Av(:,k)=directFIRsymmetricA(w,hMv);
endfor

plot(f,Av)
axis([-0.05 0.55 -0.05 1.05])
grid("on");
text(0.45,0.9,sprintf("K=%d",K(1)));
text(-0.02,0.9,sprintf("K=%d",K(end)));
xlabel("Frequency");
ylabel("Amplitude");
title(sprintf(["Vlcek maximally-flat low-pass filter responses for ", ...
 "M=%d,K=%d,%d,...,%d"],M,K(1),K(2),K(end)));
zticks([]);
print(strcat(strf,"_response"),"-dpdflatex");
close

%
% Done
%
diary off
movefile vlcekFIRsymmetric_flat_lowpass_test.diary.tmp ...
         vlcekFIRsymmetric_flat_lowpass_test.diary;

