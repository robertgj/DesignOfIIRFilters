function nextra=x2nextra(x,nshift)
% nextra=x2nextra(x,nshift)
% The elements of x are expected, but not required, to have
% -1<=x<1. This utility function returns the number of bits
% required to shift x to that range.
%
% For example:
%
%   octave:1> x=0.5:0.25:2;
%   octave:2> nbits=8;
%   octave:3> nscale=nshift./(2.^x2nextra(x,nshift))
%   nscale =
% 
%      128   128    64    64    64    64    32
%

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
  if (nargin ~= 2) || (nargout > 1)
    print_usage("nextra=x2nextra(x,nshift)");
  endif
  if length(size(x)) > 2
    error("x expected to have <= 2 dimensions");
  endif

  % Find extra bits required (avoiding log(0)=NaN)
  xx=round(x.*nshift)./nshift;
  bitsize=log2(abs(xx)+(xx==0));
  undersized=xx<(-1);
  oversized=(xx>=1);
  if any(any(undersized+oversized))
    nextra=(undersized.*ceil(bitsize))+(oversized.*(1+floor(bitsize)));
  else
    nextra=zeros(size(xx));
  endif
  
endfunction
