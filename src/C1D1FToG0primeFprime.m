function [G0prime,Fprime]=C1D1FToG0primeFprime(C1,D1,F)
% [G0prime,Fprime]=C1D1FToG0primeFprime(C1,D1,F)
% Given the state variable matrixes C1 and D1 and the associated
% all-pass orthogonal filter matrix, F, find the similarity transform
% and factor that converts F to the desired filter matrix, G.

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

% Find the sequence of Givens rotations that zeros the leftmost 
% elements of Gamma leaving a scalar, gamma. T is the cumulative 
% product of the rotations.
N=length(C1);
Gamma_delta=[C1,D1]*F';
T=eye(N+1,N+1);
for k=1:N-1
  theta=atan(Gamma_delta(k)/Gamma_delta(k+1));
  nextT=eye(N+1,N+1);
  nextT(k:k+1,k:k+1)=[cos(theta),sin(theta);-sin(theta),cos(theta)];
  T=T*nextT;
  Gamma_delta=Gamma_delta*nextT;
endfor
G0prime=[eye(N,N),zeros(N,1);Gamma_delta];

% Apply the similarity transform to F
Fprime=inv(T)*F*T;

endfunction
