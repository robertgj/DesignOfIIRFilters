function [A,gradA]=directFIRsymmetricA(wa,hM,order)
% [A,gradA]=directFIRsymmetricA(wa,hM,order)
% Inputs:
%   wa - angular frequencies
%   hM - distinct coefficients of a symmetric FIR filter polynomial, [h0 ... hM]
%   order - "odd" for odd order, even length filters,
%          "even" for even order, odd length filters (the default is "even")
% Outputs:
%   A - a column vector of the amplitudes at wa
%   gradA - the gradients of the amplitude wrt h at wa. The rows of gradA
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

  if (nargout > 2) || ((nargin ~= 2) && (nargin~=3))
    print_usage("A=directFIRsymmetricA(wa,hM)\n\
[A,gradA]=directFIRsymmetricA(wa,hM)\n\
A=directFIRsymmetricA(wa,hM,order)\n\
[A,gradA]=directFIRsymmetricA(wa,hM,order)");
  endif
  if nargin==2
    order="even";
  elseif nargin==3
    if ~((length(order)==3) || (length(order)==4)) ...
       || ...
       ~(strncmp(order,"odd",3) || (strncmp(order,"even",4)))
      error("Expected order to be \"odd\" or \"even\"");
    endif
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
  
  if strncmp(order,"odd",3)
    M=rows(hM);
    gradA=2*cos((M-(0:(M-1))-0.5).*wa);
  else
    M=rows(hM)-1;
    gradA=[2*cos((M-(0:(M-1))).*wa), ones(size(wa))];
  endif
  
  A=gradA*hM;
  
endfunction
