function c = schurexpand(n,S)
% c = schurexpand(n,S)
% Expand the polynomial n in the Schur basis S
% n  input polynomial
% S  lower-triangular matrix containing the Schur orthonormal basis 
% c  the expansion coefficients
%
% Note that the Schur decomposition algorithm uses the coefficients
% in the order  d(1)+d(2)*z+d(3)*z^2+...+d(N)*z^(N-1) whereas the Octave
% (Matlab?) convention is d(1)*z^(N-1)+d(2)*z^(N-2)+...+d(N)

% Copyright (C) 2017 Robert G. Jenssen
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

warning("Using Octave m-file version of function schurexpand()!");

% Sanity check
if (nargin ~= 2)
  print_usage("c = schurexpand(n,S)");
endif
if (min(size(n)) ~= 1)
  error("expected n a vector");
endif
if (columns(S) ~= rows(S))
  error("expected S square");
endif
if (columns(S) < length(n))
  error("expected columns(S) >= length(n) ");
endif

% Initialise
n=n(:)';
nN=length(n);
% Reverse Octave polynomial convention to suit the Schur algorithm
nn=fliplr(n);
N=columns(S);
c=zeros(1,N);

% Polynomial expansion of n in rows of S
for k=1:nN
  nk=nN-k+1;
  c(nk)=nn(nk)/S(nk,nk);
  nn=nn(1:nk)-(c(nk)*S(nk,1:nk));
endfor

endfunction
