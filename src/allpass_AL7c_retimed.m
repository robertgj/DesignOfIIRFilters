function [y,xx]=allpass_AL7c_retimed(k1,k2,u,rounding)
% [y,xx]=allpass_AL7c_retimed(k1,k2,u,rounding)
% Filter the u with the second order AL7c_retimed allpass section with
% coefficients k1 and k2. If rounding=="round", the output is rounded to
% nearest.

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
    print_usage("[y,xx]=allpass_AL7c_retimed(k1,k2,u,rounding)");
  endif
  if nargin==3
    rounding="none";
  endif
  if ~ischar(rounding)
    error("~ischar(rounding)");
  endif
  if length(rounding)<3
    error("length(rounding)<3");
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
  xx=zeros(length(u),5);
  x=zeros(1,5);

  % Calculate the state scaling factors
  if rtype==1
    [A,B,C,D]=allpass_AL7c_retimed_coef2Abcd(k1,k2);
    [~,~,~,~,~,T]=Abcd2ng(A,B,C,D);
  endif
  
  % Do the filter
  for l=1:length(u)
    if rtype==1
      x=x*T;
    endif
    v1=(-k2*(x(2)+x(4)))-x(4)+((1+k2)*u(l));
    v2=x(5);
    v3=x(1);
    v4=k1*x(1);
    v5=x(3);
    y(l)=((1-k2)*(x(2)+x(4)))+(k2*u(l));
    x=[v1,v2,v3,v4,v5];
    if any(isnan(x))
      error("any(isnan(x))");
    endif
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
