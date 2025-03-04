function [A,B,C,D]=tfp2Abcd(n0,d0,p,s)
% [A,B,C,D=tfp2Abcd(n0,d0,p,s)
% For H(z)=d-(z)/d0(z) and frequency transformation function 
% F(z)=s*p(z)/(z^(-M)p(z^-1) find the state-variable filter 
% representation for H(F(z)). s=1(-1) for low-pass(stop)
% Reference: C. T. Mullis and R. A. Roberts, "Roundoff Noise in 
% Digital Filters:Frequency Transformations and Invariants", 
% IEEE Trans. Acoustics Speech and Signal Processing, Vol. 24 No. 6,
% pp. 538-550, December 1976

% Copyright (C) 2017-2025 Robert G. Jenssen
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
  print_usage("[A,B,C,D]=tfp2Abcd(n0,d0,p,s)");
endif

% Find the state variable representation of 1/F(z)
[Alpha,Beta,Gamma,Delta]=tf2Abcd(p(length(p):-1:1),s*p);

%  Find the state variable representation of H(z)=N(z)/D(z)
[a,b,c,d]=tf2Abcd(n0,d0);
 
%  Find the state variable representation of H(F(z))
In=eye(rows(a));
invImDelta_a=inv(In-Delta*a);
A=kron(In,Alpha)+kron(a*invImDelta_a,Beta*Gamma);
B=kron(invImDelta_a*b,Beta);
C=kron(c*invImDelta_a,Gamma);
D=d+(Delta*c*invImDelta_a*b);

endfunction
