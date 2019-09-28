function a=chebychevU_expand(p)
% a=chebychevU_expand(p)
% Helper function. Expand the polynomial p in Chebychev polynomials of
% the second kind, U. The polynomials are ordered highest power at the
% left (or lowest index) to lowest power at right (or highest index).
% The expansion is a(1)*U(0)+a(2)*U(1)+ ... +a(n)*U(n-1)

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
    print_usage("a=chebychevU_expand(p)");
  endif

  pu=p;
  a=zeros(size(pu));
  for m=1:length(p),
    Um=chebychevU(length(p)-m);
    a(length(p)-m+1)=pu(m)/Um(1);
    pu(m:end)=pu(m:end)-(a(length(p)-m+1)*Um);
  endfor

  if any(abs(pu)>eps)
    error("any(abs(pu)>eps)");
  endif
  
endfunction
