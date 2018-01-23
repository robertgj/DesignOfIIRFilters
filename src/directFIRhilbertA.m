function [A,gradA]=directFIRhilbertA(wa,hM)
% [A,gradA]=directFIRhilbertA(wa,hM)
% Inputs:
%   wa - angular frequencies
%   hM - M distinct coefficients of an order 4M, Hilbert FIR filter polynomial
% Outputs:
%   A - a column vector of the amplitudes at wa
%   gradA - the gradients of the amplitude wrt hM at wa. The rows of gradA
%           are the gradients of A at each frequency in wa. 
  
% Copyright (C) 2017 Robert G. Jenssen
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

  if (nargout > 2) || (nargin ~= 2)
    print_usage("[A,gradA]=directFIRhilbertA(wa,hM)");
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
  gradA=2*sin((1:2:((2*M)-1)).*wa);
  A=gradA*hM;

endfunction
