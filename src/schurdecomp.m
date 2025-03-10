function [k,S] = schurdecomp(d)
% k=schurdecomp(d)
% [k,S]=schurdecomp(d)
% Find the Schur orthonormal polynomial basis for d
% d  Schur polynomial initialising a Schur polynomial orthonormal basis
% k  "reflection coefficients"
% S  lower-triangular matrix containing the basis 
%
% Note that the Schur decomposition algorithm uses the coefficients
% in the order  d(1)+d(2)*z+d(3)*z^2+...+d(N)*z^(N-1) whereas the Octave
% (Matlab?) convention is d(1)*z^(N-1)+d(2)*z^(N-2)+...+d(N)

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

warning("Using m-file version of function schurdecomp()!");

% Sanity checks
if nargin ~= 1
  print_usage("[k,S]=schurdecomp(d)");
endif
if isempty(d)
  error("d is empty");
  return;
endif
if d(1)==0
  error("First element of d is 0");
endif
if isscalar(d)
  k=[];S=d;
  return;
endif

% Reverse Octave polynomial convention to suit the Schur algorithm
dd=fliplr(d(:)');

% Initialise
N=length(dd);
S=dd;
k=[];

% Find the Schur basis
do

  % Scaled-normalised coefficient
  k=[dd(1)/dd(end), k];

  % Sanity check
  if (k(1) >= 1)
    k
    error("Not a Schur polynomial!");
  endif

  % Schur polynomial
  dN0 = sqrt(1-(k(1)^2));
  dd = (dd(2:end) - (k(1)*dd((length(dd)-1):-1:1)))/dN0;
  S = [dd zeros(1, N-length(dd)); S];

until (length(dd) == 1)

endfunction
