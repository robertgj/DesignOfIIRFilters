% directFIRhilbertA_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("directFIRhilbertA_test.diary");
unlink("directFIRhilbertA_test.diary.tmp");
diary directFIRhilbertA_test.diary.tmp

% Make a Hilbert filter
M=8;
n4M1=((-2*M)+1):2:((2*M)-1)';
h0=zeros((4*M)+1,1);
h0(n4M1+(2*M)+1)=2*(sin(pi*n4M1/2).^2)./(pi*n4M1);
h0=h0.*hamming((4*M)+1);
hM0=h0(((2*M)+2):2:(end-1));

n=1000;
w=(0:(n-1))'*pi/n;
AM0=directFIRhilbertA(w,hM0);

h0=[-flipud(kron(hM0,[1;0]));0;kron(hM0,[1;0])];
H0=freqz(h0,1,w);

if max(abs(abs(AM0(:))-abs(H0)))>10*eps
  error("max(abs(abs(AM0)-abs(H0)))>10*eps");
endif

% Done
diary off
movefile directFIRhilbertA_test.diary.tmp directFIRhilbertA_test.diary;
