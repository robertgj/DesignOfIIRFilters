function hM=xfr2tf(M,x,A,tol)
% hM=xfr2tf(M,x,A,tol)
% Convert the x=cos(omega) frequency response given by the points (x,A) to the
% coefficients of the impulse response of an FIR digital filter of order 2*M.
%
% Inputs:
%   M - filter order is 2*M, M+1 distinct coefficients
%   x - x=cos(omega) frequency points -1<x<1
%   A - amplitudes at x
%   tol - tolerance
% Output:
%   hM - M+1 distinct coeficients of the impulse response
  
% Copyright (C) 2019-2025 Robert G. Jenssen
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

  if (nargin < 3) || (nargout > 1)
    print_usage("hM=xfr2tf(M,x,A,tol)");
  endif
  if nargin==3
    tol=1e-12;
  endif

  % Sanity checks
  if length(x) ~= length(A)
    error("length(x) ~= length(A)");
  endif

  % Initialise
  allow_extrap=true;
  x=x(:);
  A=A(:);

  % Cosine polynomial
  AM=lagrange_interp(x,A,[],cos(pi*(0:M)'/M),tol,allow_extrap);  
  a=ifft([AM;flipud(AM(2:(end-1)))]);
  if norm(imag(a))>tol
    error("norm(imag(a))(%g)>tol",norm(imag(a)));
  endif
  a=real(a(:));

  % Convert a to vector of the distinct impulse response coefficients
  hM=[a(M+1)/2;flipud(a(1:M))];
                                         
endfunction
