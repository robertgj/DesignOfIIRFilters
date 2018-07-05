function [a,V,Q]=tf2a(den,tol)
% [a,V,Q]=tf2a(den,tol)
%
% Inputs:
%   den - denominator polynomial of an allpass filter
%   tol - tolerance on real zero/pole imaginary parts
%
% Outputs:
%   a - coefficient vector 
%       [pR(1:V); abs(p(1:Qon2)); angle(p(1:Qon2))];
%       where pR represents the real poles and z and p represents the
%       conjugate pole pairs of the denominator polynomial of the
%       allpass filter.
%   V - number of real poles
%   Q - number of conjugate pole pairs

% Copyright (C) 2017,2018 Robert G. Jenssen
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

% Sanity checks
if nargin < 1
  print_usage("[a,V,Q]=tf2x(den,tol)");
endif
if nargin==1
  tol=100*eps;
endif

% Find real and complex zeros of den. (Finding the complex zeros that
% have an imaginary part greater than zero).
denz=qroots(den);
iRdenz=find(abs(imag(denz))<tol);
iCdenz=find(imag(denz)>=tol);

% Make outputs
a=[real(denz(iRdenz)); abs(denz(iCdenz)); angle(denz(iCdenz))];
V = length(iRdenz);
Q = 2*length(iCdenz);

% Sanity checks
if length(den) ~= 1+V+Q
  error("length(den)=%d not consistent with V=%d and Q=%d", length(den), V, Q);
endif;

endfunction
