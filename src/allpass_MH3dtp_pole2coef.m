function [b1,b2]=allpass_MH3dtp_pole2coef(arg1,arg2,real_comp_str)
% [b1,b2]=allpass_MH3dtp_pole2coef(r1,r2,"real")
% [b1,b2]=allpass_MH3dtp_pole2coef(r,theta,"complex")
% Given the MH3dtp second order all-pass filter section pole locations,
% return the coefficients b1 and b2.

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
  if (nargin~=3) || (nargout~=2)
    print_usage("[b1,b2]=allpass_MH3dtp_pole2coef(r1,r2,\"real_poles\")\n\
[b1,b2]=allpass_MH3dtp_pole2coef(r,theta,\"complex_poles\")");
  endif
  if length(real_comp_str)<4
    error("length(real_comp_str)<4");
  endif 
  if ~ischar(real_comp_str)
    error("~ischar(real_comp_str)");
  endif
 
  % Find the MH3dtp multipliers
  fchoice = tolower(real_comp_str(1:4));
  if fchoice == "comp"
    r=arg1;
    if abs(r)>=1
      error("abs(r)>=1");
    endif
    theta=arg2;
    b1=2*r*cos(theta);
    b2=r*r;
  elseif fchoice == "real"
    r1=arg1;
    if abs(r1)>=1 
      error("abs(r1)>=1");
    endif
    r2=arg2;
    if abs(r2)>=1
      error("abs(r2)>=1");
    endif
    b1=(r1+r2);
    b2=r1*r2;
  else
    error("Unknown real_complex_str");
  endif
  
endfunction
