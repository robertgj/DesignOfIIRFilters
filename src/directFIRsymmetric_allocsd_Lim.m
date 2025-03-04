function ndigits_alloc=directFIRsymmetric_allocsd_Lim ...
                         (nbits,ndigits,hM,waf,Adf,Waf)
% ndigits_alloc=directFIRsymmetric_allocsd_Lim(nbits,ndigits,hM,waf,Adf,Waf)
%
% Inputs:
%   hM - distinct coefficients of an even order, symmetric FIR filter polynomial
%   wa - angular frequencies of band edges in [0,pi] eg: [0 0.1 0.2 0.5]*2*pi
%   Ad - desired response, assumed to be 0 in stop bands, eg: [0 1 0]
%   Wa - weight in each band eg: [100 1 100]
%
% Lim's signed-digit allocation algorithm implemented for a symmetric,
% even-order FIR filter polynomial. See: "Signed Power-of-Two Term
% Allocation Scheme for the Design of Digital Filters", Y. C. Lim, R. Yang,
% D. Li and J. Song, IEEE Transactions on Circuits and Systems-II:Analog and
% Digital Signal Processing, Vol. 46, No. 5, May 1999, pp.577-584

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

  %
  % Sanity checks
  %
  if (nargin~=6) || nargout~=1
    print_usage ...
("ndigits_alloc=directFIRsymmetric_allocsd_Lim(nbits,ndigits,hM,waf,Adf,Waf)");
  endif

  % Calculate the response squared-error and gradient
  [Esq,gradEsq]=directFIRsymmetricEsqPW(hM,waf,Adf,Waf);

  % Allocate signed digits to non-zero coefficients
  cost=0.36*(log2(abs(hM(:)))+log2(abs(gradEsq(:))));
  ndigits_alloc=zeros(size(hM));
  R=ndigits*sum(double(abs(hM)>=(2^(-nbits))));
  while R>0
    [mc,imc]=max(cost);
    cost(imc)-=1;
    ndigits_alloc(imc)+=1;
    R=R-1;
  endwhile
  
endfunction
