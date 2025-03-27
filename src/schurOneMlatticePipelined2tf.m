function [n,d]=schurOneMlatticePipelined2tf(k,epsilon,c,kk,ck,tol)
% [n,d]=schurOneMlatticePipelined2tf(k,epsilon,c,kk,ck,tol)

% Copyright (C) 2025 Robert G. Jenssen
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


  if ((nargin ~= 5) && (nargin ~= 6)) || (nargout ~= 2)
    print_usage(["[n,d]=schurOneMlatticePipelined2tf(k,epsilon,c,kk,ck)\n", ...
                 "[n,d]=schurOneMlatticePipelined2tf(k,epsilon,c,kk,ck,tol)"]);
  endif
  if nargin == 5
    tol=100*eps;
  endif
  
  [A,B,C,D]=schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck);

  [n,d]=Abcd2tf(A,B,C,D);
  while (abs(n(end)) < tol) && (abs(d(end)) < tol)
    n=n(1:(end-1)); 
    d=d(1:(end-1));
  endwhile
  
endfunction
