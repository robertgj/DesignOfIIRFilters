function X=dlyap_recursive(P,Q,tol)
% X=dlyap_recursive(P,Q,tol)
% Find the recursive solution to the 
% discrete Lyapunov equation X=PXP'+Q*Q'
% See "Digital Signal Processing", R. A. Roberts and 
% C. T. Mullis, Section 9.11 .

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

% Sanity checks
if (nargin ~= 2) && (nargin ~= 3)
  print_usage("X=dlyap_recursive(P,Q,tol)");
endif
if (rows(P) ~= columns(P))
  error("Expect square argument P");
endif 
if (columns(Q) ~= 1) || (rows(Q) ~= rows(P))
  error("Expect columns(Q)=1 and rows(Q)=rows(P)!");
endif
if nargin == 2
  tol = 100*eps;
endif

% Recursion
F=P;
X=Q*Q';
while max(max(F)) > tol
  X=F*X*F'+X;
  F=F*F;
endwhile

endfunction
