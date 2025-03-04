function [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_MH2dt_coef2Abcd(b1,b2)
% [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_MH2dt_coef2Abcd(b1,b2)
% Given the MH2dt second order all-pass filter section coefficients, b1 and b2,
% return the state variable description and cell arrays of the derivatives
% of the state variable description with respect to b1 and b2.

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
    print_usage("[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_MH2dt_coef2Abcd(b1,b2)");
  endif

  % Make the state-variable description
  A = zeros(4,4);
  A(1,1) = 0;
  A(1,2) = 0;
  A(1,3) = 1;
  A(1,4) = 0;
  A(2,1) = 1;
  A(2,2) = 0;
  A(2,3) = -b1;
  A(2,4) = 0;
  A(3,1) = 0;
  A(3,2) = 0;
  A(3,3) = b1;
  A(3,4) = 1;
  A(4,1) = 0;
  A(4,2) = 0;
  A(4,3) = -b1*b2;
  A(4,4) = 0;
  B = zeros(4,1);
  B(1,1) = 1;
  B(2,1) = -b1;
  B(3,1) = b1;
  B(4,1) = -b1*b2;
  C = zeros(1,4);
  C(1,1) = 0;
  C(1,2) = 1;
  C(1,3) = b1*b2;
  C(1,4) = 0;
  D = b1*b2;
  
  if nargout==4
    return;
  endif
  
  dAdx = cell(1,2);
  dAdx{1} = zeros(4,4);
  dAdx{1}(1,1) = 0;
  dAdx{1}(1,2) = 0;
  dAdx{1}(1,3) = 0;
  dAdx{1}(1,4) = 0;
  dAdx{1}(2,1) = 0;
  dAdx{1}(2,2) = 0;
  dAdx{1}(2,3) = -1;
  dAdx{1}(2,4) = 0;
  dAdx{1}(3,1) = 0;
  dAdx{1}(3,2) = 0;
  dAdx{1}(3,3) = 1;
  dAdx{1}(3,4) = 0;
  dAdx{1}(4,1) = 0;
  dAdx{1}(4,2) = 0;
  dAdx{1}(4,3) = -b2;
  dAdx{1}(4,4) = 0;
  dAdx{2} = zeros(4,4);
  dAdx{2}(1,1) = 0;
  dAdx{2}(1,2) = 0;
  dAdx{2}(1,3) = 0;
  dAdx{2}(1,4) = 0;
  dAdx{2}(2,1) = 0;
  dAdx{2}(2,2) = 0;
  dAdx{2}(2,3) = 0;
  dAdx{2}(2,4) = 0;
  dAdx{2}(3,1) = 0;
  dAdx{2}(3,2) = 0;
  dAdx{2}(3,3) = 0;
  dAdx{2}(3,4) = 0;
  dAdx{2}(4,1) = 0;
  dAdx{2}(4,2) = 0;
  dAdx{2}(4,3) = -b1;
  dAdx{2}(4,4) = 0;

  dBdx = cell(1,2);
  dBdx{1} = zeros(4,1);
  dBdx{1}(1,1) = 0;
  dBdx{1}(2,1) = -1;
  dBdx{1}(3,1) = 1;
  dBdx{1}(4,1) = -b2;
  dBdx{2} = zeros(4,1);
  dBdx{2}(1,1) = 0;
  dBdx{2}(2,1) = 0;
  dBdx{2}(3,1) = 0;
  dBdx{2}(4,1) = -b1;

  dCdx = cell(1,2);
  dCdx{1} = zeros(1,4);
  dCdx{1}(1,1) = 0;
  dCdx{1}(1,2) = 0;
  dCdx{1}(1,3) = b2;
  dCdx{1}(1,4) = 0;
  dCdx{2} = zeros(1,4);
  dCdx{2}(1,1) = 0;
  dCdx{2}(1,2) = 0;
  dCdx{2}(1,3) = b1;
  dCdx{2}(1,4) = 0;

  dDdx = cell(1,2);
  dDdx{1} = b2;
  dDdx{2} = b1;
  
endfunction
