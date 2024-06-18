function [n,d]=schurNSPAlattice2tf(A1s20,A1s02,A1s00,A1s22, ...
                                   A2s20,A2s02,A2s00,A2s22,difference)
% [n,d]=schurNSPAlattice2tf(A1s20,A1s02,A1s00,A1s22,A2s20,A2s02,A2s00,A2s22, ...
%                           difference)

% Copyright (C) 2017-2024 Robert G. Jenssen
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

  if ((nargin ~= 8) && (nargin ~= 9)) || (nargout ~= 2)
    print_usage
      ("[n,d]=schurNSPAlattice2tf(A1s20,A1s02,A1s00,A1s22, ...\n\
              A2s20,A2s02,A2s00,A2s22,difference)");
  endif
  if nargin==8
    difference=false;
  endif
  
  [A1A,A1B,~,~,A1Cap,A1Dap]= ...
    schurNSlattice2Abcd(zeros(size(A1s20)),zeros(size(A1s20)), ...
                        A1s20,A1s02,A1s00,A1s22);

  [A2A,A2B,~,~,A2Cap,A2Dap]= ...
    schurNSlattice2Abcd(zeros(size(A2s20)),zeros(size(A2s20)), ...
                        A2s20,A2s02,A2s00,A2s22);

  [A1n,A1d]=Abcd2tf(A1A,A1B,A1Cap,A1Dap);
  [A2n,A2d]=Abcd2tf(A2A,A2B,A2Cap,A2Dap);

  if difference
    n=0.5*(conv(A1n,A2d)-conv(A2n,A1d));
  else
    n=0.5*(conv(A1n,A2d)+conv(A2n,A1d));
  endif
  d=conv(A1d,A2d);
endfunction

