function [a,V,Q]=p2a(p,tol)
% [a,V,Q]=p2a(p,tol)
% Convert pole locations into a single vector allpass representation
%
% Inputs:
%   p - poles
%
% Outputs:
%   a - coefficient vector [pR(1:V); abs(pr(1:Qon2)); angle(pr(1:Qon2))];
%       where pR represent real poles and pr represents conjugate zero
%       and pole pairs. 
%   V - number of real poles
%   Q - number of conjugate pole-zero pairs

% Copyright (C) 2018-2025 Robert G. Jenssen
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
if ((nargin~=1) && (nargin~=2)) || (nargout ~= 3) 
  print_usage("[a,V,Q]=p2a(p,tol)");
endif
if isempty(p)
  a=[];V=0;Q=0;
  return;
endif

if nargin==1
  [xa,~,V,~,Q]=zp2x([],p,1);
else
  [xa,~,V,~,Q]=zp2x([],p,1,tol);  
endif
a=xa(2:end);

endfunction
