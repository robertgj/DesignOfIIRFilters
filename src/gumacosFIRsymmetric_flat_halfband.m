function h=gumacosFIRsymmetric_flat_halfband(M)
% h=gumacosFIRsymmetric_flat_halfband(M)
% C. Gumacos's closed-form design of a symmetric, linear-phase,
% maximally-flat FIR half-band filter.
%
% Inputs:
%   M - the filter length is 4M+3
%
% Outputs:
%   h - coefficients of the symmetric FIR half-band filter
% See: "Weighting Coefficients for Certain Maximally Flat Nonrecursive
% Digital Filters", C. Gumacos, IEEE Transactions of Circuits and Systems,
% Vol. 25, No. 4, April 1978, pp. 234-235
  
% Copyright (C) 2020 Robert G. Jenssen
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

  if (nargin~=1) || (nargout>1)
    print_usage("h=gumacosFIRsymmetric_flat_halfband(M);");
  endif

  % Sanity checks
  if M<=0
    error("M<=0");
  endif

  % Calculate the filter a coefficients
  a=zeros(M+1,1);
  a(1+0)=1;
  for k=1:M,
    a(1+k)=a(1+k-1)*(-(2*k-1)/(2*k+1))*(M-k+1)/(M+k+1);
  endfor
  
  % Build the filter impulse response
  h=zeros(4*M+3,1);
  h(2*M+2)=1/2;
  h(2*M+2+1)=1/(4*sum(a));
  h(2*M+(2*(1:M)+3))=h(2*M+2+1)*a(1+(1:M));
  h(1:2:(2*M+1))=flipud(h((2*M+2+1):2:end));
  
endfunction
