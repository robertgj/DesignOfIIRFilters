function [yu,yl]=bin2SDul(x,nbits,ndigits)
% [yu,yl]=bin2SDul(x,nbits,ndigits)
% Find the nbits, ndigits signed-digit numbers that are the greatest
% lower bound, yl, and least upper bound, yu, approximating x.

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

  if ndigits==0
    yu=0;
    yl=0;
    return;
  endif
  
  xsd=bin2SD(x,nbits,ndigits);
  if xsd==x
    yu=x;
    yl=x;
  elseif (0.5>=x) && (x>0)
    yu=1;
    yl=0;
  elseif (-0.5<=x) && (x<0)
    yu=0;
    yl=-1;
  elseif xsd>x
    yu=xsd;
    xx=x;
    while xsd>x
      xx=xx-1;
      xsd=bin2SD(xx,nbits,ndigits);
    endwhile
    yl=xsd;
  else
    yl=xsd;
    xx=x;
    while xsd<x
      xx=xx+1;
      xsd=bin2SD(xx,nbits,ndigits);
    endwhile
    yu=xsd;
  endif
  
endfunction
