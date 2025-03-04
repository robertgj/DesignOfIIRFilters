function spt=bin2SPT(x,nbits)
% spt=bin2SPT(x,nbits)
% Convert an nbits 2's complement binary number x with digits from
% {0,1} in the range -2^(nbits-1) <= x < 2^(nbits-1) to a
% signed-digit number with nbits ternary digits from {-1,0,1}.
%
% See Section 13.6.1 of the book "VLSI Digital Signal Processing 
% Systems: Design and Implementation" by Keshab K. Parhi. 
%
% The algorithm used to convert a W-bit 2's complement number
% AHat=aHat(W-1)aHat(W-2)---aHat(1)aHat(0) to a W-bit CSD number
% A=a(W-1)a(W-2)---a(1)a(0) is:
%
%   aHat(-1)=0
%   aHat(W)=aHat(W-1)
%   gamma(-1)=0
%   for i=0:(W-1)
%     theta=aHat(i) ^ aHat(i-1)
%     gamma(i)=(~gamma(i-1))*theta
%     a(i)=(1-2*aHat(i+1))*gamma(i)
%   endfor
%
% where "^" means exclusive-or and "~" means ones-complement.
%
% The signed-digit representation produced by this algorithm is said
% to be "canonical":
%  - each digit is a number in the set {-1,0,1}
%  - no two consecutive bits are nonzero
%  - the representation contains the minimum number of nonzero bits
%  - the representation is unique
%
% Example 13.6.1 of the reference shows conversion of 101110011 or
% -bin2dec("010001101") or -141 to {0,-1,0,0,-1,0,1,0,-1}
% where the left-most digit is the MSD and represents {-256,0,256}.
%
% This implementation uses the bitget() etc functions. Notes regarding
% the bitget() function:
%   1. bitget() requires a positive input value
%   2. bitget() rounds the input value.
%        For example, in this version of Octave:
%          bitget(1.5,1) returns 0
%          bitget(1.499999999999999,1) returns 1
  
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

  warning("Using Octave m-file version of function bin2SPT()!");

  % Sanity checks
  if (nargin>2) || (nargout>1)
    print_usage("y=bin2SPT(x,nbits)");
  endif
  if ~isscalar(x)
    error("x is not a scalar");
  endif
  xx=round(x);

  % Sanity check on nbits
  if nargin==1
    if xx==0
      nbits=1;
    else
      nbits=1+ceil(log2(abs(xx)));
    endif
  endif
  if nbits<=0
    error("nbits<=0");
  endif
  max_nbits=floor(log2(flintmax())-2);
  if (nbits<=0) ||(nbits>max_nbits)
    error("Expected 0<nbits(%d)<=%d",nbits,max_nbits);
  endif
  
  % Initialise outputs
  spt=zeros(1,nbits);
  
  % Handle -0.5<x<0.5
  if xx==0
    spt(1)=[0];
    return;
  endif
 
  % Check that round(x) is in range
  log2xx=log2(abs(xx));
  if log2xx>(nbits-1)
    error("round(x)=%d is out of range for a %d bits signed-digit number",
          xx,nbits);
  endif
  
  % Handle abs(round(x)) is a power of 2
  if mod(log2xx,1) == 0
    if xx>0
      spt(log2xx+1)=1;
    else  
      spt(log2xx+1)=-1;
    endif
    return;
  endif
    
  % Find the nbits 2's complement representation of round(x)
  if xx<0
    xx=bitcmp(abs(xx),nbits)+1;
  endif
  
  % Find the canonical signed-digit representation
  xxw=bitset(xx,nbits+1,bitget(xx,nbits));
  a_km1=0;
  gamma_km1=0;
  for k=1:(nbits)
    a_k=bitget(xxw,k);
    a_kp1=bitget(xxw,k+1);
    theta_k=bitxor(a_km1,a_k);
    gamma_k=bitcmp(gamma_km1,1)*theta_k;
    spt(k)=int8((1-(2*a_kp1))*gamma_k);
    a_km1=a_k;
    gamma_km1=gamma_k(1);
  endfor

endfunction

