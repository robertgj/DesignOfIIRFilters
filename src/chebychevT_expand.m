function a=chebychevT_expand(p)
% a=chebychevT_expand(p)
% Helper function. Expand the polynomial p in Chebychev polynomials of
% the first kind, T. The polynomials are ordered highest power at the
% left (or lowest index) to lowest power at right (or highest index).
% The expansion is a(1)*T(0)+a(2)*T(1)+ ... +a(n)*T(n-1)

% TODO: Implement expansion in chebychevP.m by overloading n with p

% Copyright (C) 2019 Robert G. Jenssen
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

  if nargin~=1 || nargout>1
    print_usage("a=chebychevT_expand(p)");
  endif

  pt=p;
  a=zeros(size(pt));
  for m=1:length(p),
    Tm=chebychevT(length(p)-m);
    a(length(p)-m+1)=pt(m)/Tm(1);
    pt(m:end)=pt(m:end)-(a(length(p)-m+1)*Tm);
  endfor

  if any(abs(pt)>eps)
    error("any(abs(pt)>eps)");
  endif
  
endfunction
