function [Pn,Pnm1]=chebyshevP(n,kind)
% [Pn,Pnm1]=chebyshevP(n,kind)
% Utility function that calculates the coefficients
% of the Chebyshev polynomial of order n of the first
% or second kind. Both Pn and the previous polynomial
% are returned for convenience.

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

if nargin~=2 || nargout>2
  print_usage("[P,Pnm1]=chebyshevP(n,kind)");
endif
if mod(n,1)
  error("Expect n an integer");
endif
if kind~=1 && kind~=2
  error("kind~=1 && kind~=2");
endif
if n<0
  Pn=0;
  Pnm1=0;
elseif n==0
  Pn=1;
  Pnm1=0;
elseif n==1
  Pn=[kind, 0];
  Pnm1=[1];
else
  Pnm1=[zeros(1,n),1];
  Pn=[zeros(1,n-1),kind,0];
  Pnp1=zeros(1,n+1);
  for m=2:n,
    Pnp1=2*circshift(Pn,-1)-Pnm1;
    Pnm1=Pn;
    Pn=Pnp1;
  endfor
  Pnm1=Pnm1(2:end);
endif
endfunction
