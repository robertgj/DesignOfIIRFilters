function Bstar=invSVD(B)
% Bstar=invSVD(B)
% Invert a rank-deficient matrix, B, using SVD
% An alternative for finding Bstar in goldfarb_idnani.m

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

if any(any(isnan(B)))
  error("Found NaN in B");
endif

[U S V]=svd(B);
n=rows(S);
m=columns(S);
if m>n
  diagS=diag(S(1:n,1:n));
  invS=[diag(1./diagS); zeros(m-n,n)];
elseif m<n
  diagS=diag(S(1:m,1:m));
  invS=[diag(1./diagS) zeros(m,n-m)];
else
  diagS=diag(S(1:m,1:m));
  invS=diag(1./diagS);
endif
Bstar=V*invS*U';

endfunction
