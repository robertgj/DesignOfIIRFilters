% directFIRhilbertA_test.m
% Copyright (C) 2019 Robert G. Jenssen

test_common;

set(0,'DefaultFigureVisible','on');
set(0,"defaultlinelinewidth",2);

delete("directFIRhilbertA_test.diary");
delete("directFIRhilbertA_test.diary.tmp");
diary directFIRhilbertA_test.diary.tmp

%
% Even order, odd length Hilbert filter
%
M=8;
n4M1=(((-2*M)+1):2:((2*M)-1))';
h0=zeros((4*M)-1,1);
h0(n4M1+(2*M))=2*(sin(pi*n4M1/2).^2)./(pi*n4M1);
h0=h0.*hamming((4*M)-1);
hM0=h0(1:2:((2*M)-1));

% Check amplitude response
n=1000;
w=(0:(n-1))'*pi/n;
AM0=directFIRhilbertA(w,hM0);
H0=freqz(h0,1,w);
if max(abs(AM0+abs(H0)))>10*eps
  error("max(abs(AM0+abs(H0)))>10*eps");
endif

%
% Odd order, even length Hilbert filter
%
M=8;
n2M=(-((2*M)-1)/2:((2*M)-1)/2)';
h0=zeros(2*M,1);
h0(n2M+(M+(1/2)))=2*(sin(pi*n2M/2).^2)./(pi*n2M);
h0=h0.*hamming(2*M);
hM0=h0(1:M);

% Check amplitude response
n=1000;
w=(0:(n-1))'*pi/n;
AM0odd=directFIRhilbertA(2*w,hM0,"odd");
H0odd=freqz(h0,1,2*w);
if max(abs(AM0odd+abs(H0odd)))>10*eps
  error("max(abs(AM0odd+abs(H0odd)))>10*eps");
endif

AM0=directFIRhilbertA(w,hM0);
H0=freqz(kron(h0(:),[1;0])(1:(end-1)),1,w);
if max(abs(AM0+abs(H0)))>10*eps
  error("max(abs(AM0+abs(H0)))>10*eps");
endif

if max(abs(AM0-AM0odd))>10*eps
  error("max(abs(AM0-AM0odd))>10*eps");
endif

% Done
diary off
movefile directFIRhilbertA_test.diary.tmp directFIRhilbertA_test.diary;
