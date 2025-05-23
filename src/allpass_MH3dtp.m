function [y,xx]=allpass_MH3dtp(b1,b2,u,rounding)
% [y,xx]=allpass_MH3dtp(b1,b2,u,rounding)
% Filter the u with the second order MH3dtp allpass section with coefficients
% b1 and b2. If rounding=="round", the output is rounded to nearest. This
% section is derived from MH3dt by recognising that in that section, x1=-b1*x3
% and removing state x1.

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

  if nargin<3 || nargin>4 || nargout>2
    print_usage("[y,xx]=allpass_MH3dtp(b1,b2,u,rounding)");
  endif
  if nargin==3
    rounding="none";
  endif
  if length(rounding)<3
    error("length(rounding)<3");
  endif 
  if ~ischar(rounding)
    error("~ischar(rounding)");
  endif

  % Decode rounding
  rounding=rounding(1:3);
  if rounding == "rou"
    % Round to nearest
    rtype=1;
  elseif rounding == "non"
    rtype=0;
  else
    error("unknown rounding");
  endif

  % Allocate output storage now
  u=u(:);
  y=zeros(size(u));
  xx=zeros(length(u),3);
  x=zeros(1,3);
  
  % Calculate the state scaling factors
  if rtype==1
    [A,B,C,D]=allpass_MH3dtp_coef2Abcd(b1,b2);
    [K,W]=KW(A,B,C,D);
    T=diag(sqrt(diag(K)));
  endif

  % Do the filter
  for l=1:length(u)
    if rtype==1
      x=x*T;
    endif
    v2=-(b2*x(2))+(b1*x(1))+(b1*u(l));
    v3=x(1)+u(l);
    v4=-(b1*x(1))+x(2)-(b1*u(l));
    y(l)=(b2*x(1))+x(3)+(b2*u(l));
    x=[v2,v3,v4];
    if rtype==1
      x=round(x*inv(T));
    endif
    xx(l,:)=x;
  endfor

  % Round the output
  if rtype==1
    y=round(y);
  endif

endfunction
