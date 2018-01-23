function k = schurFIRdecomp(d)
% k=schurFIRdecomp(d)
% Find the Schur FIR lattice coefficients,k, for the Schur polynomial d
%
% Note that the Schur decomposition algorithm uses the coefficients
% in the order  d(1)+d(2)*z+d(3)*z^2+...+d(N)*z^(N-1) whereas the Octave
% (Matlab?) convention is d(1)*z^(N-1)+d(2)*z^(N-2)+...+d(N)

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

  warning("Using Octave m-file version of function schurFIRdecomp()!");

  % Sanity check
  if (nargin ~= 1) || (nargout ~=1)
    print_usage("k=schurFIRdecomp(d)");
  endif

  if d(1) ~= 1
    error("Expect term in z^n has d(1)==1!");
  endif

  % For convenience, reverse the Octave polynomial convention
  N=length(d);
  dd=fliplr(d(:)');
  k=[];
  do
    % Lattice coefficient
    k=[dd(1) k];
    % Sanity check. The product of all the roots should be less than 1.
    if (k(1) >= 1)
      k
      error("Not a Schur polynomial!");
    endif
    % Schur FIR polynomial order reduction
    dd = (dd(2:end) - (k(1)*dd((length(dd)-1):-1:1)))/(1 - (k(1)^2));
  until (length(dd) == 1)

endfunction
