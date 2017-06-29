function y=bin2SD(x,nbits,ndigits)
% y=bin2SD(x,nbits,ndigits)
% Convert an nbits 2's complement binary number x with digits from {0,1} in
% the range -2^(nbits-1) <= x < 2^(nbits-1) to a number equivalent to a
% signed-digit number with nbits ternary digits from {-1,0,1} of which
% ndigits are non-zero.
  
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

  warning("Using Octave m-file version of function bin2SD()!");

  % Sanity checks
  if nargin~=3
    print_usage("y=bin2SD(x,nbits,ndigits)");
  endif
  max_nbits=floor(log2(flintmax())-2);
  if (nbits<=0) ||(nbits>max_nbits)
    error("Expected 0<nbits(%d)<=%d",nbits,max_nbits);
  endif
  if ndigits==0
    % SD allocation may allocate 0 signed digits
    y=0;
    return;
  elseif (ndigits<0) || (ndigits>nbits)
    error("Expected 0<=ndigits(%d)<=nbits(%d)",ndigits,nbits);
  endif
  if ~isscalar(x)
    error("x is not a scalar");
  endif
  if (round(x)<-2^(nbits-1)) || (2^(nbits-1)<=round(x))
    error("x=%g,round(x)=%g is out of range for a %d bits 2s complement number!",
          x,round(x),nbits);
  endif
  
  % Loop finding signed digits
  xx=round(x);
  r=sign(xx)*(2^(nbits-1));
  y=0;
  nd=0;nb=0;
  while (nd < ndigits) && (nb < nbits) && (xx ~= 0)
    if abs(4*xx) >= abs(3*r)
      xx=xx-r;
      y=y+r;
      nd=nd+1;
    elseif abs(2*xx) >= abs(r)
      xx=xx-(r/2);
      y=y+(r/2);
      nd=nd+1;
    endif
    nb=nb+1;
    r=sign(xx)*abs(r)/2;
  endwhile

endfunction

