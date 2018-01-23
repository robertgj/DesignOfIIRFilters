function [b,a]=tfp2g(B,A,p,s)
% [b,a]=tfp2g(B,A,p,s)
% Given a prototype filter transfer function H(z)=B(z)/A(z)
% and a frequency transformation defined by F(z)=p(z)/(z^(-M)p(z^(-1))) 
% and p(z)=Sum[k=0,M](p(k)z^(-k)) find the corresponding G(z)=H(F(z)).
% s=1 for low-pass and s=-1 for low-stop

% Copyright (C) 2017,2018 Robert G. Jenssen
%
% Permission is hereby granted, free of charge, to any person
% obtaining a copy of this software and associated documentation
% files (the "Software"), to deal in the Software without restriction,
% including without limitation the rights to use, copy, modify, merge,
% publish, distribute, sublicense, and/or sell copies of the Software,
% and to permit persons to whom the Software is furnished to do so,
% subject to the following conditions: The above copyright notice and
% this permission notice shall be included in all copies or substantial
% portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
% IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
% TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% Sanity check
if nargin ~= 4
  print_usage("[b,a]=tfp2g(B,A,p,s)");
endif

% Initialise
A=A(:)';
B=B(:)';
p=p(:)';
L=length(A)-1;
M=length(p)-1;
N=2^ceil(log2((L*M)+1));

% Find DFT of p(z)
P=fft(p,N);
PL=P.^L;
theta=(2*arg(P))+((1-s)*pi/2)+(2*(0:(N-1))*M*pi/N);

% Find DFT of a and b
A=freqz(A,1,theta);
B=freqz(B,1,theta);

% Inverse DFT to find a and b
a=ifft(A.*PL);
b=ifft(B.*PL);
a=real(a(1:((L*M)+1)));
b=real(b(1:((L*M)+1)));

% Normalise
b=b/a(1);
a=a/a(1);

endfunction
