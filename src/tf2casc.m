function [a,k]=tf2casc(p)
% [a,k]=tf2casc(p)
% Convert polynomial [p(1)+p(2)*z^-1+...+p(n)*z^-(n-1))] to a product
% of second-order sections with gain factor, k=p(1). If n is odd 
% then a(1) is the coefficient of a first order section,
% (1+a(1)*z^-1). The remaining elements of a are, in order, ai1 
% and ai2, the coefficients of a second order section 
% [1 + ai1*z^-1 + ai2*z^-2]. The second order section may result from
% two real poles. Accuracy is limited by the roots() function.

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

  % Sanity checks
  if isempty(p) || isempty(find(p))
    a=[];
    k=0;
    return;
  endif
  if length(p) == 1
    a=[];
    k=p(1);
    return;
  endif
  
  % Scale (allowing for zeros in low order coefficients of z^(-k))
  ik=find(p);
  k=p(ik(1));
  p=p/k; 
  % Find roots of p(z^-1) sorted by absolute magnitude of the imaginary part
  pr=roots(p);
  [spr,ipr]=sort(abs(imag(pr)));
  pr=pr(ipr);

  % Find a
  n=length(pr);
  L=floor(n/2);
  if L==0
    a=1;
  elseif mod(n,2)==1
    if imag(pr(1))>eps
      error("n is odd and imag(pr(1))>eps");
    endif
    a(1)=-real(pr(1));
    for l=1:L
      a(1+(2*l)-1)=-(pr(1+(2*l)-1) + pr(1+(2*l)));
      a(1+(2*l))=pr(1+(2*l)-1) * pr(1+(2*l));
    endfor
  else
    for l=1:L
      a((2*l)-1)=-(pr((2*l)-1) + pr(2*l));
      a(2*l)=pr((2*l)-1) * pr(2*l);
    endfor
  endif
  a=a(:);
  if isrow(p)
    a=a';
  endif

endfunction
