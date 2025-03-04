function hM=vlcekFIRsymmetric_flat_lowpass(M,K)
% hM=vlcekFIRsymmetric_flat_lowpass(M,K)
% Implement the algorithm of Vlcek et al. for the calculation of the distinct
% coefficients of the impulse response of a symmetric, odd-length, even-order,
% maximally-flat FIR lowpass filter.
%
% Inputs:
%   M - filter length is 2M+1
%   K - order of maximally flatness at omega=pi
%
% Outputs:
%   hM - M+1 distinct coefficients of the impulse response
%
% See Table I of "Analytical Design of FIR Filters", Miroslav Vlcek,
% Pavel Zahradnik and Rolf Unbehauen, IEEE Transactions on Signal Processing,
% Vol. 48, No. 9, September 2000, pp. 2705-2709
  
% Copyright (C) 2020-2025 Robert G. Jenssen
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

  if (nargin~=2) || (nargout > 1)
    print_usage("h=vlcekFIRsymmetric_flat_lowpass(M,K)");
  endif

  % Sanity checks
  if ~isscalar(M)
    error("~isscalar(M)");
  endif
  if ~isscalar(K)
    error("~isscalar(K)");
  endif
  if K>M
    error("K>M");
  endif
  
  % Initialise
  hM=zeros(1,M+1);
  a=zeros(1,M+1);
  alpha=zeros(1,M+1);
  alpha(1+M)=((-1)^(M-K))*(2^(1-(2*M)))*M*bincoeff(M-1,M-K);
  alpha(1+M-1)=-2*(M-(2*K)+1)*alpha(1+M);

  % Body
  for k=(M-1):-1:2,
    alpha(1+k-1)=-(((M-(2*K)+1)*alpha(1+k))+((M+1+k)*alpha(1+k+1)/2))*2/(M-k+1);
  endfor

  % Integration
  a(1+(1:M))=alpha(1+(1:M))./(1:M);
  a(1+0)=1-sum(a(1+(1:M)));
    
  % Impulse response
  hM(1+((M-1):-1:0))=a(1+(1:M))/2;
  hM(1+M)=a(1+0);
  
endfunction
