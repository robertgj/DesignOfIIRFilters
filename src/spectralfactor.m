function q=spectralfactor(n,d)
% q=spectralfactor(n,d)
% Given a transfer function G(z) = n(z)/d(z), return the spectral 
% factor polynomial, q, for which the complementary transfer
% function H(z)=q(z)/d(z) and |H(w)|^2 + |G(w)|^2=1.
% If r(z)=n(z)^2 - z^(-N)d(z^(-1))d(z) then the coefficients
% of r(z) are r(n)=sum^{n}_{k=0}q(k)q(n-k)
%
% See P.P.Vaidyanathan et al. "A New Approach to the Realization of
% Low-Sensitivity IIR Digital Filters", IEEE Trans. Acoustics, Speech
% and Signal Processing, Vol.34, No.2, April 1986, pp350-361.

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

  warning("Using Octave version of function spectralfactor()!");
  if (nargin ~= 2)
    print_usage("q=spectralfactor(n,d)");
  endif
  if (length(n) ~= length(d))
    error("expect equal order numerator and denominator!");
  endif
  if (mod(length(n),2) ~= 0)
    error("expect odd filter order!");
  endif

  % q is antisymmetric
  n=n(:)';
  d=d(:)';
  r=conv(n,n)-conv(d,fliplr(d));
  q=zeros(size(d));
  q(1)=sqrt(r(1));
  q(2)=r(2)/(2*q(1));
  for n=2:(floor(length(q)/2))
    q(n+1)=(r(n+1)-sum(q(2:n).*q(n:-1:2)))/(2*q(1));
  endfor
  q((floor(length(q)/2)+1):end)=-fliplr(q(1:floor(length(q)/2)));

endfunction
