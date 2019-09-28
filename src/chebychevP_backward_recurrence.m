function S=chebychevP_backward_recurrence(a,kind)
% S=chebychevP_backward_recurrence(a,kind)
% Given the Chebychev expansion coefficients, a, return the sum, S
%
% The recurrence relations for the Chebychev polynomials of the first
% kind are:
%   T{0}=1,T{2}=x,..,T{n+1}(x)=2xT{n}(x)-T{n-1}(x)
% and similarly, for the second kind:
%   U{0}=1,U{2}=2x,..,U{n+1}(x)=2xU{n}(x)-U{n-1}(x)
% Given the coefficients, a, of the expansion of a function in the
% Chebychev polynomials of the first or second kind, F, calculate the
% sum of a(k)*F{k}(x) by backwards recursion.

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

  if nargin~=2 || nargout>1
    print_usage("S=chebychevP_backwards_recurrence(a,kind)");
  endif
  if kind~=1 && kind~=2
    error("Expected kind=1 or kind=2");
  endif

  if isempty(a)
    S=[];
    return;
  elseif length(a)==1
    S=a;
    return;
  endif
  
  n=length(a)-1;
  S=zeros(1,n+1);
  Smp1=a(end);
  Smp2=[];
  for m=(n-1):-1:1,
    S=(2*conv([1,0],Smp1))-[0,0,Smp2];
    S(end)=S(end)+a(1+m);
    Smp2=Smp1;
    Smp1=S;
  endfor
  S=(kind*conv([1,0],Smp1))-[0,0,Smp2];
  S(end)=S(end)+a(1);

endfunction

