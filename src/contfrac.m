function [A,B,C,D]=contfrac(b,a)
% [A,B,C,D]=contfrac(b,a)
% Find the state variable equations for the continued fraction
% expansion of the transfer function b(z)/a(z)

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

if nargin ~= 2
  print_usage("[A,B,C,D]=contfrac(b,a)");
endif
if length(a) ~= length(b)
  error("Expected length(b)==length(a)!");
endif
if length(a) < 3
  error("Expected length>=3!");
endif

% Initialise
N=length(a)-1;
Alpha=zeros(N,1);
BetaGamma=zeros(N,1);

% Normalise b and a
b=b(:)/a(1);
a=a(:)/a(1);

% Continued fraction expansion
D=b(1);
b=b-(b(1)*a);
b=b(2:end);
for k=1:N
  [q,r]=deconv(a,b);
  if (length(q) ~= 2)
    error("Expected length(q)==2!");
  endif
  BetaGamma(k)=1/q(1);
  Alpha(k)=-q(2)/q(1);
  a=b;
  b=-r(3:end)/q(1);
endfor

% Express in state variable form
A=diag(Alpha) + diag(BetaGamma(2:N),1) + diag(ones(N-1,1),-1);
B=[BetaGamma(1); zeros(N-1,1)];
C=[1 zeros(1,N-1)];

endfunction
