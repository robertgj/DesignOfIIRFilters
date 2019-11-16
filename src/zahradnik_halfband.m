function [hn,a,alpha]=zahradnik_halfband(n,kp)
% [hn,a,alpha]=zahradnik_halfband(n,kp)
% Implement Table 1 of [1] (with a correction for alpha(2n-4))
% Inputs:
%  2n+1 - Order the zero-phase half-band filter (not including the 0.5)
%         The final half-band FIR filter has length 4n+3
%  kp - A constant determined by the pass-band edge frequency
% Output:
%  hn - Impulse response of the integrated generating function
%  a - coefficients for Chebyshev polynomials of the first kind
%  alpha - coefficients for Chebyshev polynomials of the second kind
%
% [1] "Equiripple Approximation of Half-Band FIR Filters",
% P. Zahradnik and M. Vlcek, IEEE Transactions on Circuits and Systems - II:
% Express Briefs, Vol. 56, No. 12, December 2009, pp. 941-945

% Copyright (C) 2019 Robert G. Jenssen
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

% Sanity checks
if nargin~=2 || nargout>3
  print_usage("[hn,a,alpha]=zahradnik_halfband(n,kp)");
endif
if kp<=0 || kp>=1
  error("Expect 0<kp<1!")
endif
if mod(n,1)
  error("Expect n an integer");
endif
if n<=0
  error("Expect n>0!")
endif

% Initialisation
kp2=kp^2;
alpha=zeros(1,1+(2*n));
alpha(1+(2*n))=(1-kp2)^(-n);
alpha(1+(2*n)-2)=-((2*n*kp2)+1)*alpha(1+2*n);
alpha(1+(2*n)-4)= ...
  -((((4*n)+1+((n-1)*((2*n)-1)*kp2))*alpha(1+(2*n)-2))/(2*n)) ...
  -((((2*n)+1)*(((n+1)*kp2)+1)*alpha(1+(2*n)))/(2*n));

% Body
nnp2=n*(n+2);
for l=n:-1:3,
  twol=2*l;
  l2=l*l;
  alpha(1+twol-6)= ...
  (-(((3*(nnp2-(l2-twol)))+twol-3+ ...
      (2*(l-2)*(twol-3)*kp2))*alpha(1+twol-4)) ...
   -(((3*(nnp2-(l2-1)))+(2*(twol-1))+ ...
      (twol*(twol-1)*kp2))*alpha(1+twol-2)) ...
   -((nnp2-(l2-1))*alpha(1+twol)))/(nnp2-((l-3)*(l-1))); 
endfor

% Integration
a=zeros(1,1+1+(2*n));
twolp1=2*(0:n)+1;
a(1+twolp1)=alpha(twolp1)./twolp1;

% Impulse response
hn=zeros(1,(4*n)+3);
twonp1=(2*n)+1;
hn(1+twonp1+twolp1)=a(1+twolp1)/2;
hn(1+twonp1-twolp1)=a(1+twolp1)/2;

endfunction
