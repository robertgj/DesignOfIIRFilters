function [h,c]=selesnickFIRantisymmetric_linear_differentiator(N,K)
% [h,c]=selesnickFIRantisymmetric_linear_differentiator(N,K)
% Implement Selesnick's algorithm for the closed-form design of an even- or
% odd-order,  odd- or even-length, anti-symmetric, linear-phase, low-pass,
% maximally-linear at omega=0, FIR differentiator filters.
%
% Inputs:
%   N - filter length (filter order is N-1)
%   K - number of zeros at z=-1
%
% Outputs:
%   h - coefficients of the anti-symmetric FIR differentiator filter
%   c - coefficients of the maximally-flat components (ie [-1;2;-1]/4)
%
% This function closely follows the chebdiff.m MATLAB function of Selesnick
% for even length filters and adds the case of odd length filters. See
% Section IV of "Exchange Algorithms for the Design of Linear Phase
% FIR Filters and Differentiators Having Flat Monotonic Passbands and
% Equiripple %Stopband", Ivan W. Selesnick and C. Sidney Burrus, IEEE
% TRANSACTIONS ON CIRCUITS AND SYSTEMS—II: ANALOG AND DIGITAL SIGNAL
% PROCESSING, VOL. 43, NO. 9, SEPTEMBER 1996, pp. 671-675

% Copyright (C) 2020-2025 Robert G. Jenssen
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

  if (nargin<2) || (nargout>2)
    print_usage("h=selesnickFIRantisymmetric_linear_differentiator(N,K);\n\
[h,c]=selesnickFIRantisymmetric_linear_differentiator(N,K);");
  endif

  % Sanity checks
  if N<=0
    error("N<=0");
  endif
  if K>=N
    error("K>=N");
  endif
  
  % Recursive calculation of the maximally-linear filter coefficients
  L=(N-2-K)/2;
  c=zeros(L,1);
  c(1+0)=2;
  if L>=1
    c(1+1)=K+(1/3);
  endif
  for l=2:L,
    c(1+l)=((((8*l*l)+(4*K*l)-(10*l)-K+3)*c(1+l-1))- ...
            ((((2*l)+K-3)^2)*c(1+l-2)))/((2*l)*((2*l)+1));
  endfor
  
  % Construct the overall filter impulse response
  h=c(1+L);
  for l=(L-1):-1:0,
    h=[zeros((length(h)+1)/2,1);c(1+l);zeros((length(h)+1)/2,1)]+ ...
      conv(h,[-1;2;-1]/4);
  endfor
  for k=1:K,
    h=conv(h,[1;1]/2);
  endfor
  h=conv(h,[1;-1]/2);

endfunction
