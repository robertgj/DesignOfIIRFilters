function Asq=schurOneMlatticePipelinedAsq(w,k,epsilon,c,kk,ck)
% Asq=schurOneMlatticePipelinedAsq(w,k,epsilon,c,kk,ck)
% Calculate the squared-magnitude response of a pipelined Schur
% one-multiplier lattice filter. If the order of the filter numerator
% polynomial is N, then there are N+1 numerator tap coefficients, c.
% If the order of the denominator polynomial is Nk, then there are Nk
% one-multiplier lattice section coefficients, k. The epsilon inputs
% scale the internal nodes. 
%
% Inputs:
%   w - column vector of angular frequencies
%   k - one-multiplier allpass section denominator multiplier coefficients
%   epsilon - one-multiplier allpass section sign coefficients (+1 or -1)
%   c - numerator all-pass filter tap coefficients
%   kk - k(2n-1)*k(2n)
%   ck - c(2n)*k(2n) (c(1)=c_0, c(2n)=c_{2n-1})
%
% Outputs:
%   Asq - the squared magnitude response at w

% Copyright (C) 2023 Robert G. Jenssen
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

  %
  % Sanity checks
  %
  if (nargin ~= 6) || (nargout > 1) 
    print_usage("Asq=schurOneMlatticePipelinedAsq(w,k,epsilon,c,kk,ck)");
  endif
  if length(k) ~= length(epsilon)
    error("length(k) ~= length(epsilon)");
  endif
  if(length(k)+1) ~= length(c)
    error("(length(k)(%d)+1) ~= length(c)(%d)",length(k),length(c));
  endif
  if length(w) == 0
    Asq=[]; 
    return;
  endif

  [A,B,C,D]=schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck);
  H=Abcd2H(w,A,B,C,D);
  Asq=H2Asq(H);  
   
endfunction
