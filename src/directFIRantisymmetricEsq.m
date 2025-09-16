function [Esq,gradEsq]=directFIRantisymmetricEsq(hM,wa,Ad,Wa)
% [Esq,gradEsq]=directFIRantisymmetricEsq(hM,wa,Ad,Wa)
% Inputs:
%   hM - distinct coefficients of an even order, anti-symmetric FIR filter
%   wa - angular frequencies
%   Ad - desired response
%   Wa - weighting function
%
% Outputs:
%   Esq - the squared error value at h, a scalar
%   gradEsq - gradient of the squared error value at h, a row vector
  
% Copyright (C) 2025 Robert G. Jenssen
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

  if (nargout > 2) || (nargin ~= 4)
    print_usage("[Esq,gradEsq]=directFIRantisymmetricEsq(hM,wa,Ad,Wa)");
  endif
  if isempty(hM)
    error("hM is empty");
  endif
  if isempty(wa)
    error("wa is empty");
  endif
  if length(wa) ~= length(Ad)
      error("length(wa) ~= length(Ad)");
    endif
  if length(wa) ~= length(Wa)
    error("length(wa) ~= length(Wa)");
  endif
    
  hM=hM(:);
  M=length(hM);
  wa=wa(:);
  Ad=Ad(:);
  Wa=Wa(:);

  % Find A and gradA
  if nargout==1
    A=directFIRantisymmetricA(wa,hM);
  else
    [A,gradA]=directFIRantisymmetricA(wa,hM);
  endif
  
  % Find Esq
  SqErr=Wa.*((A(:)-Ad).^2);
  Esq=0.5*sum(diff(wa).*(SqErr(1:(end-1))+SqErr(2:end)),1)/pi;
  if nargout==1
    return;
  endif
  
  % Find gradEsq
  gradSqErr=2*kron(Wa.*(A(:)-Ad),ones(1,M)).*gradA;
  gradEsq=0.5*sum(diff(wa).*(gradSqErr(1:(end-1),:)+gradSqErr(2:end,:)),1)/pi;
  
endfunction
