function p=casc2tf(a)
% p=casc2tf(a)
% Convert a product of second-order sections to a polynomial
% [p(1)+p(2)*z^-1+...+p(n)*z^-(n-1)]. If n is odd then a(1)
% is the coefficient of a first order section, (1+a(1)*z^-1). The 
% remaining elements of a are, in order, ai1 and ai2, the coefficients
% of a second order section [1 + ai1*z^-1 + ai2*z^-2]. 

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

  if isempty(a)
    p=1;
    return;
  endif

  n=length(a);
  L=floor(n/2);
  if mod(n,2)==1
    p=[1 a(1)];
    ai=reshape(a(2:end),2,L);
  else
    p=1;
    ai=reshape(a,2,L);
  endif
  ai1=ai(1:2:end);
  ai2=ai(2:2:end);
  for m=1:L
    p=conv(p,[1 ai1(m) ai2(m)]);
  endfor
  p=p(:);
  if isrow(a)
    p=p';
  endif

endfunction
