function ng=allpass_MH2dt_coef2ng(b1,b2)
% ng=allpass_MH2dt_coef2ng(b1,b2)
% Given the MH2dt second order all-pass filter section coefficients, b1 and b2,
% return the noise gain due to truncation at the state inputs.

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

  % Sanity check
  if (nargin~=2) || (nargout~=1)
    print_usage("ng=allpass_MH2dt_coef2ng(b1,b2)");
  endif

  % Make the state-variable description
  [A,B,C,D]=allpass_MH2dt_coef2Abcd(b1,b2);
  
  % Calculate the noise gain
  ng=Abcd2ng(A,B,C,D);
  
endfunction
