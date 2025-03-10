function [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_GM1_coef2Abcd(k1,e1)
% [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_GM1_coef2Abcd(k1)
% [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_GM1_coef2Abcd(k1,e1)
% Given the GM1 first order all-pass filter section coefficient, k1,
% return the state variable description and cell arrays of the derivatives
% of the state variable description with respect to k1.

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
  if (nargin~=1 && nargin~=2) || (nargout~=4 && nargout~=8)
    print_usage(["[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_GM1_coef2Abcd(k1)\n", ...
 "[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_GM1_coef2Abcd(k1,e1)"]);
  endif
  if (nargin==1)
    e1=1;
  endif
  if abs(k1)>=1
    error("abs(k1)>=1");
  endif
  if abs(e1)~=1
    error("abs(e1)~=1");
  endif
  
  % Make the state-variable description
  A = zeros(1,1);
  A(1,1) = -k1;
  B = zeros(1,1);
  B(1,1) = (e1*k1)+1;
  C = zeros(1,1);
  C(1,1) = 1-(e1*k1);
  D = k1;
  
  if nargout==4
    return;
  endif
  
  dAdx = cell(1,1);
  dAdx{1} = zeros(1,1);
  dAdx{1}(1,1) = -1;

  dBdx = cell(1,1);
  dBdx{1} = zeros(1,1);
  dBdx{1}(1,1) = e1;

  dCdx = cell(1,1);
  dCdx{1} = zeros(1,1);
  dCdx{1}(1,1) = -e1;

  dDdx = cell(1,1);
  dDdx{1} = 1;
  
endfunction
