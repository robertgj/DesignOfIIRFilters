function [C,e]=stability2ndOrderCascade(m,limit_cycle)
% [C,e]=stability2ndOrderCascade(m)
% Return the second order stability and limit-cycle constraint
% matrixes, C and e, for an order m filter denominator polynomial.

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

  if (nargin ~= 1) && (nargin ~= 2)
    print_usage("[C,e]=stability2ndOrderCascade(m[,limit_cycle])");
  endif
  if nargin == 1
    limit_cycle=false;
  endif
  
  c1=[1;-1];
  e1=[1;1];
  if limit_cycle
    c2=[1 1;-1 1;1 -1;-1 -1;0 -1];
  else
    c2=[1 1;-1 1;0 -1];
  endif    
  m2=floor(m/2);  
  e2=ones(m2*rows(c2),1);
  C2=kron(eye(m2,m2),c2);
  if mod(m,2)==1
    C=[c1, zeros(2,columns(C2));zeros(rows(C2),1), C2];
    e=[e1;e2];
  else
    C=C2;
    e=e2;
  endif

endfunction
