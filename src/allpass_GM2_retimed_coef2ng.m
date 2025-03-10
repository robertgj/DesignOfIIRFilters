function ng=allpass_GM2_retimed_coef2ng(arg1,arg2,arg3,arg4)
% ng=allpass_GM2_retimed_coef2ng(k1,k2)
% ng=allpass_GM2_retimed_coef2ng(k1,e1,k2,e2)
% Given the GM2_retimed second order all-pass filter section coefficients,
% k1 and k2, return the noise gain due to truncation at the state inputs.

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
  if (nargin~=2 && nargin~=4) || (nargout~=1)
    print_usage(["ng=allpass_GM2_retimed_coef2ng(k1,k2)\n", ...
 "ng=allpass_GM2_retimed_coef2ng(k1,e1,k2,e2)"]);
  endif

  % Find the GM2 multipliers
  if (nargin==2)
    k1=arg1;
    e1=1;
    k2=arg2;
    e2=1;
  else
    k1=arg1;
    e1=arg2;
    k2=arg3;
    e2=arg4;
  endif
  if abs(k1)>=1
    error("abs(k1)>=1");
  endif
  if abs(e1)~=1
    error("abs(e1)~=1");
  endif
  if abs(k2)>=1
    error("abs(k2)>=1");
  endif
  if abs(e2)~=1
    error("abs(e2)~=1");
  endif

  % Make the state-variable description with an additional state
  [A,B,C,D]=allpass_GM2_retimed_coef2Abcd(k1,k2);

  % Calculate the noise gain
  ng=Abcd2ng(A,B,C,D);
  
endfunction
