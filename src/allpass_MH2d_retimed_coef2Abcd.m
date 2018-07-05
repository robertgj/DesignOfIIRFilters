function [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_MH2d_retimed_coef2Abcd(b1,b2)
% [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_MH2d_retimed_coef2Abcd(b1,b2)
% Given the MH2d_retimed second order all-pass filter section coefficients,
% b1 and b2, return the state variable description and cell arrays of the
% derivatives of the state variable description with respect to b1 and b2.

% Copyright (C) 2018 Robert G. Jenssen
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
      ("[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_MH2d_retimed_coef2Abcd(b1,b2)");
  endif

  % Make the state-variable description
  A = zeros(5,5);
  A(2,1) = 1;
  A(3,2) = 1;
  A(4,1) = -1;
  A(4,3) = 1;
  A(4,4) = b1;
  A(4,5) = -b2;
  A(5,3) = 1;
  A(5,4) = b1;
  B = zeros(5,1);
  B(1,1) = 1;
  B(4,1) = b2;
  C = zeros(1,5);
  C(1,3) = 1;
  C(1,4) = b1;
  D = 0;

  if nargout==4
    return;
  endif
  
  dAdx = cell(1,2);
  dAdx{1} = zeros(5,5);
  dAdx{1}(4,4) = 1;
  dAdx{1}(5,4) = 1;
  dAdx{2} = zeros(5,5);
  dAdx{2}(4,5) = -1;

  dBdx = cell(1,2);
  dBdx{1} = zeros(5,1);
  dBdx{2} = zeros(5,1);
  dBdx{2}(4,1) = 1;

  dCdx = cell(1,2);
  dCdx{1} = zeros(1,5);
  dCdx{1}(1,4) = 1;
  dCdx{2} = zeros(1,5);

  dDdx = cell(1,2);
  dDdx{1} = 0;
  dDdx{2} = 0;
  
endfunction
