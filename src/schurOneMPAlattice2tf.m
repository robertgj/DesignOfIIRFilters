function [n,d]=schurOneMPAlattice2tf(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                                     difference)
% [n,d]=schurOneMPAlattice2tf(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p)
% [n,d]=schurOneMPAlattice2tf(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference)

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

  if (nargout ~= 2) || ((nargin ~= 6) && (nargin ~= 7))
    print_usage ...
(["[n,d]=schurOneMPAlattice2tf(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p)\n", ...
 "[n,d]=schurOneMPAlattice2tf(A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference)"]);
  endif
  if nargin == 6
    difference = false;
  endif
  A1c=zeros(1,length(A1k)+1);
  [A1A,A1B,A1C,A1D,A1Cap,A1Dap]=schurOneMlattice2Abcd(A1k,A1epsilon,A1p,A1c);
  A2c=zeros(1,length(A2k)+1);
  [A2A,A2B,A2C,A2D,A2Cap,A2Dap]=schurOneMlattice2Abcd(A2k,A2epsilon,A2p,A2c);
  [A1n,A1d]=Abcd2tf(A1A,A1B,A1Cap,A1Dap);
  [A2n,A2d]=Abcd2tf(A2A,A2B,A2Cap,A2Dap);
  if difference
    n=0.5*(conv(A1n,A2d)-conv(A2n,A1d));
  else
    n=0.5*(conv(A1n,A2d)+conv(A2n,A1d));
  endif
  d=conv(A1d,A2d);
endfunction

