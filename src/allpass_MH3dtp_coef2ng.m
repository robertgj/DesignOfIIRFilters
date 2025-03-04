function ng=allpass_MH3dtp_coef2ng(b1,b2)
% ng=allpass_MH3dtp_coef2ng(b1,b2)
% Given the MH3dtp second order all-pass filter section coefficients, b1 and b2,
% return the noise gain.

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
    print_usage("ng=allpass_MH3dtp_coef2ng(b1,b2)");
  endif

  % Make the state-variable description
  [A,B,C,D]=allpass_MH3dtp_coef2Abcd(b1,b2);
  
  % Select states that contribute to round-off noise
  tol=1e-10;
  z=[A,B];
  stsel=ones(rows(z),1);
  for r=1:rows(z)
    z0=abs(z(r,:))<tol;
    z1=abs(z(r,:)-1)<tol;
    if (sum(z1) == 1) && (sum(z0) == (columns(z)-1))
      stsel(r)=0;
    endif
  endfor
  
  % Calculate the noise gain
  [K,W]=KW(A,B,C,D);
  ng=sum(diag(K.*W).*stsel);
  
endfunction
