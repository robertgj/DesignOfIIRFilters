function [A,gradA]=directFIRhilbertA(wa,hM,order)
% [A,gradA]=directFIRhilbertA(wa,hM,order)
% Inputs:
%   wa - angular frequencies
%   hM - M distinct coefficients of an even order 4M-2, odd length 4M-1,
%        Hilbert FIR filter:
%          h=[hM(1) 0 hM(2) 0 ... 0 hM(M) 0 -hM(M) 0 ... 0 -hM(1)] or
%        For an odd-order 2M-1, even length 2M filter:
%          h=[hM(1) ... hM(M) -hM(M) ... -hM(1)]
%   order - "even" if even order, odd length (the default)
%         - "odd" if odd order, even length
% Outputs:
%   A - a column vector of the amplitudes at wa
%   gradA - the gradients of the amplitude wrt hM at wa. The rows of gradA
%           are the gradients of A at each frequency in wa. 
  
% Copyright (C) 2017-2020 Robert G. Jenssen
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

  if (nargout > 2) || ((nargin~=2) && (nargin~=3))
    print_usage("A=directFIRhilbertA(wa,hM)\n\
[A,gradA]=directFIRhilbertA(wa,hM,order)");
  endif
  if nargin==2
    order="even";
  endif
  if isempty(hM)
    error("hM is empty");
  endif
  if isempty(wa)
    A=[];
    gradA=[];
    return;
  endif

  wa=wa(:);
  hM=hM(:);
  M=rows(hM);

  if strncmp(order,"odd",3)
    gradA=2*sin((M-(0:(M-1))-0.5).*wa);
  else
    gradA=2*sin((2*M-(1:2:(2*M-1))).*wa);
  endif
  
  A=gradA*hM;

endfunction
