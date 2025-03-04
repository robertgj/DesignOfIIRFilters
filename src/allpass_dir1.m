function [y,xx]=allpass_dir1(b1,u,rounding)
% [y,xx]=allpass_dir1(b1,u,rounding)
% Filter the input u with the first order direct form allpass section with
% coefficient, b1. If rounding=="round", the output is rounded to nearest.

% Copyright (C) 2017-2025 Robert G. Jenssen
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

  if nargin<2 || nargin>3 || nargout>2
    print_usage("[y,xx]=allpass_dir1(b1,u,rounding)");
  endif
  if nargin==2
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
  else
    rtype=0;
  endif

  % Allocate output storage now
  u=u(:);
  xx=zeros(size(u));
  y=zeros(size(u));
  x=0;

  % Calculate the state scaling factors
  if rtype==1
    [A,B,C,D]=allpass_dir1_coef2Abcd(b1);
    [~,~,~,~,~,T]=Abcd2ng(A,B,C,D);
  endif
  
  % Do the filter
  for l=1:length(u)
    if rtype==1
      x=x*T;
    endif
    tmp=u(l)-(b1*x);
    y(l)=x+(b1*tmp);
    x=tmp;
    if any(isnan(x))
      error("any(isnan(x))");
    endif
    if rtype==1
      x=round(x*inv(T));
    endif
    xx(l)=x;
  endfor

  % Round the output
  if rtype==1
    y=round(y);
  endif

endfunction
