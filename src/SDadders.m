function [x_digits,x_adders]=SDadders(x,nbits)
% [x_digits,x_adders]=SDadders(x,nbits)
% For an array of fixed point numbers, x, each nbits long, find the
% total number of digits and adders required to implement the
% signed-digit representation of x.

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

  if (nargin ~= 2) || (nargout > 2)
    print_usage("[x_digits,x_adders]=SDadders(x,nbits)");
  endif
  x=x(:);
  if isscalar(nbits)
    nbits=nbits*ones(size(x));
  endif

  % Express elements of x as signed-digits in powers-of-two
  x_spt=arrayfun(@bin2SPT,x.*(2.^(nbits-1)),'UniformOutput',false);

  % Find the number of digits in each element of x
  x_sum=cellfun(@(x) sum(abs(x)),x_spt);

  % Find the total number of signed-digits in x
  x_digits=sum(x_sum);

  % Find the total number of adders required to implement multiplication by x
  x_adders=sum((x_sum-1).*(x_sum>1));

endfunction
