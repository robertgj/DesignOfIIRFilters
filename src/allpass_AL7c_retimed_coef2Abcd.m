function [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_AL7c_retimed_coef2Abcd(k1,k2)
% [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_AL7c_retimed_coef2Abcd(k1,k2)
% Given the AL7c_retimed second order all-pass filter section coefficients, k1
% and k2, return the state variable description and cell arrays of the
% derivatives of the state variable description with respect to k1 and k2.

% Copyright (C) 2018-2025 Robert G. Jenssen
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
  if (nargin~=2) || (nargout~=4 && nargout~=8)
    print_usage ...
      ("[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_AL7c_retimed_coef2Abcd(k1,k2)");
  endif

  % Make the state-variable description
  A = zeros(5,5);
  A(1,2) = -k2;
  A(1,4) = -k2-1;
  A(2,5) = 1;
  A(3,1) = 1;
  A(4,1) = k1;
  A(5,3) = 1;
  B = zeros(5,1);
  B(1,1) = k2+1;
  C = zeros(1,5);
  C(1,2) = 1-k2;
  C(1,4) = 1-k2;
  D = k2;

  if nargout==4
    return;
  endif
  
  dAdx = cell(1,2);
  dAdx{1} = zeros(5,5);
  dAdx{1}(4,1) = 1;
  dAdx{2} = zeros(5,5);
  dAdx{2}(1,2) = -1;
  dAdx{2}(1,4) = -1;

  dBdx = cell(1,2);
  dBdx{1} = zeros(5,1);
  dBdx{2} = zeros(5,1);
  dBdx{2}(1,1) = 1;

  dCdx = cell(1,2);
  dCdx{1} = zeros(1,5);
  dCdx{2} = zeros(1,5);
  dCdx{2}(1,2) = -1;
  dCdx{2}(1,4) = -1;

  dDdx = cell(1,2);
  dDdx{1} = 0;
  dDdx{2} = 1;
  
endfunction
