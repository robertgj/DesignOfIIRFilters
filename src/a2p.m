function p=a2p(a,V,Q,R)
% p=a2p(a,V,Q,R)
% p=a2p(a,V,Q)
% Convert a single vector real and complex pole representation of an allpass
% filter into poles.
%
% Inputs:
%   a - coefficient vector [pR(1:V); abs(pr(1:Qon2)); angle(pr(1:Qon2))];
%       where pR represent real poles and pr represents conjugate zero
%       and pole pairs. 
%   V - number of real poles
%   Q - number of conjugate pole-zero pairs
%   R - decimation factor for z^R
%
% Outputs:
%   num - numerator polynomial
%   den - denominator polynomial

% Copyright (C) 2018 Robert G. Jenssen
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
if ((nargin ~=3) && (nargin ~= 4)) || (nargout~=1)
  print_usage("p=a2p(a,V,Q,R)");
endif
if nargin==3
  R=1;
endif
if rem(Q,2) ~= 0
  error("Expected Q even");
endif
if length(a) ~= (V+Q)
  error("Expected length(a)==V+Q");
endif
if isempty(a)
  p=[];
  return;
endif

[~,p,~]=x2zp([1;a(:)],0,V,0,Q,R);

endfunction
