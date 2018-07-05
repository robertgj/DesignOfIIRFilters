function [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_LS1_coef2Abcd(c1)
% [A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_LS1_coef2Abcd(c1)
% Given the LS1 first order all-pass filter section coefficient, c1,
% return the state variable description and cell arrays of the derivatives
% of the state variable description with respect to c1.

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

  % Sanity check
  if (nargin~=1) || (nargout~=4 && nargout~=8)
    print_usage("[A,B,C,D,dAdx,dBdx,dCdx,dDdx]=allpass_LS1_coef2Abcd(c1)");
  endif

  % Make the state-variable description
  A = zeros(1,1);
  A(1,1) = 1-c1;
  B = zeros(1,1);
  B(1,1) = c1;
  C = zeros(1,1);
  C(1,1) = 2-c1;
  D = c1-1;
  
  if nargout==4
    return;
  endif
  
  dAdx = cell(1,1);
  dAdx{1} = zeros(1,1);
  dAdx{1}(1,1) = -1;

  dBdx = cell(1,1);
  dBdx{1} = zeros(1,1);
  dBdx{1}(1,1) = 1;

  dCdx = cell(1,1);
  dCdx{1} = zeros(1,1);
  dCdx{1}(1,1) = -1;

  dDdx = cell(1,1);
  dDdx{1} = 1;
  
endfunction
