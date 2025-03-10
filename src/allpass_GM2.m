function [y,xx]=allpass_GM2(arg1,arg2,arg3,arg4,arg5,arg6)
% [y,xx]=allpass_GM2(k1,k2,u)
% [y,xx]=allpass_GM2(k1,k2,u,rounding)
% [y,xx]=allpass_GM2(k1,e1,k2,e2,u)
% [y,xx]=allpass_GM2(k1,e1,k2,e2,u,rounding)
% Filter the input u with the second order GM2 allpass section with
% coefficients k1 and k2. If rounding=="round", the output is rounded
% to nearest.

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

  if nargin<3 || nargin>6 || nargout>2
    print_usage(["[y,xx]=allpass_GM2(k1,k2,u)\n", ...
 "[y,xx]=allpass_GM2(k1,k2,u,rounding)\n", ...
 "[y,xx]=allpass_GM2(k1,e1,k2,e2,u)\n", ...
 "[y,xx]=allpass_GM2(k1,e1,k2,e2,u,rounding)"]);
  endif
  if nargin==3
    k1=arg1;
    k2=arg2;
    u=arg3;
    e1=1;
    e2=1;
    rounding="none";
  elseif nargin==4
    k1=arg1;
    k2=arg2;
    u=arg3;
    rounding=arg4;
    e1=1;
    e2=1;
  elseif nargin==5
    k1=arg1;
    e1=arg2;
    k2=arg3;
    e2=arg4;
    u=arg5;
    rounding="none";
  else
    k1=arg1;
    e1=arg2;
    k2=arg3;
    e2=arg4;
    u=arg5;
    rounding=arg6;    
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
  else
    rtype=0;
  endif

  % Allocate output storage now
  u=u(:);
  y=zeros(size(u));
  xx=zeros(length(u),2);
  x=zeros(1,2);

  % Calculate the state scaling factors
  if rtype==1
    [A,B,C,D]=allpass_GM2_coef2Abcd(k1,k2);
    [~,~,~,~,~,T]=Abcd2ng(A,B,C,D);
  endif
  
  % Do the filter
  for l=1:length(u)
    if rtype==1
      x=x*T;
    endif
    tmp=x*[(1-(e1*k1));k1];
    v1=((1+(k1*e1))*x(2))-(k1*x(1));
    v2=((1+(k2*e2))*u(l))-(k2*tmp);
    y(l)=((1-(e2*k2))*tmp)+(k2*u(l));
    x=[v1,v2];
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
