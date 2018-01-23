function [Esq,gradEsq,Q,q]=directFIRsymmetricEsq(hM,wa,Ad,Wa)
% [Esq,gradEsq,Q,q]=directFIRsymmetricEsq(hM,wa,Ad,Wa)
% Inputs:
%   hM - distinct coefficients of an even order, symmetric FIR filter polynomial
%   wa - angular frequencies
%   Ad - desired response
%   Wa - weighting function
%
% Outputs:
%   Esq - the squared error value at h, a scalar
%   gradEsq - gradient of the squared error value at h, a row vector
%   Q,q - gradEsq=2*hM'*Q+2*q. hM is (M+1)x1, q is 1x(M+1) and Q is (M+1)x(M+1)
  
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

  if (nargout > 4) || (nargin ~= 4)
    print_usage("[Esq,gradEsq,Q,q]=directFIRsymmetricEsq(hM,wa,Ad,Wa)");
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
  M=length(hM)-1;
  wa=wa(:);
  Ad=Ad(:);
  Wa=Wa(:);

  % Find A and gradA
  if nargout==1
    A=directFIRsymmetricA(wa,hM);
  else
    [A,gradA]=directFIRsymmetricA(wa,hM);
  endif
  
  % Find Esq
  SqErr=Wa.*((A(:)-Ad).^2);
  Esq=0.5*sum(diff(wa).*(SqErr(1:(end-1))+SqErr(2:end)),1)/pi;
  if nargout==1
    return;
  endif
  
  % Find gradEsq
  gradSqErr=kron(Wa.*(A-Ad),ones(1,M+1)).*gradA;
  gradEsq=sum(diff(wa).*(gradSqErr(1:(end-1),:)+gradSqErr(2:end,:)),1)/pi;
  if nargout==2
    return;
  endif

  % Find q
  nM=M-(0:(M-1));
  cosnMwa=[2*cos(nM.*wa) ones(length(wa),1)];
  intq=cosnMwa.*(Wa.*Ad);
  q=-0.5*sum(diff(wa).*(intq(1:(end-1),:)+intq(2:end,:)),1)/pi;

  %
  % Find Q=sumoverw(Wa.*{[2cos(M-k)wa .. 1]'*[2cos(M-l)wa .. 1]}), k,l=0..M-1
  % Simplify the sum by:
  %  1. Use the identity 2cos(x)cos(y)=cos(x+y)+cos(x-y)
  %  2. Use cos(M-k)wa where k=0:M and correct for the factor of 2 later
  %  3. Convert the M+1-by-M+1 matrix (M-k)'*(M-l) to a vector
  %
  
  % Make M+1-by-M+1 matrixes (x+y and x-y)
  MMkl=(M:-1:0)'+(M:-1:0);
  kl=(0:M)'-(0:M);
  
  % Convert to a matrix length(wa)-by-(M+1)^2
  intQ=(Wa.*2.*cos(wa.*(MMkl(:)')))+(Wa.*2.*cos(wa.*(kl(:)')));

  % Sum over rows with trapezoidal approximation to integration
  Q=0.5*(sum(diff(wa).*(intQ(1:(end-1),:)+intQ(2:end,:)),1))/pi;

  % Convert back to an M+1-by-M+1 matrix
  Q=reshape(Q,M+1,M+1);

  % Make corrections to right-hand column and bottom row
  Q(M+1,:)=Q(M+1,:)/2;
  Q(:,M+1)=Q(:,M+1)/2;

endfunction
