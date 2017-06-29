function [yap y xx]=schurNSlatticeFilter(s10,s11,s20,s00,s02,s22,u,rounding)
% [yap y xx]=schurNSlatticeFilter(s10,s11,s20,s00,s02,s22,u,rounding)
% Use the lattice filter coefficients sxx to filter the input sequence, 
% u, producing the all-pass output, yap, and the filtered output, y. If 
% rounding="round", use rounding to nearest. If rounding="fix" use 
% truncation to zero(2s complement).
%
% The scaled-normalised lattice filter structure is:
%       _______          _______                _______   
% Out <-|     |<---------|     |<---------...<--|     |<---------- 
%       |     |  ______  |     |  ______        |     |  ______  |
%  In ->|  N  |->|z^-1|->| N-1 |->|z^-1|->...-->|  1  |->|z^-1|->o
%       |     |  ------  |     |  ------        |     |  ------  |
%  AP <-|     |<---------|     |<---------...<--|     |<----------
% Out   -------          -------                ------- 
%
% Each module 1,..,N is implemented as:
%                      
%       <---------+<----------------<
%                 ^     s11       
%              s10|
%                 |
%       >---------o--o------>+------>
%                    |  s00  ^
%                 s20|       |s02 
%                    V  s22  |
%       <------------+<------o------<

% Copyright (C) 2017 Robert G. Jenssen
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
if nargin ~= 8
  print_usage("[yap y xx]=schurNSlatticeFilter(s10,s11,s20,s00,s02,s22,u,rounding)");
endif

% Initialise
rounding=rounding(1:3);
if rounding == "rou"
  % Rounding to nearest
  rtype=1;
elseif rounding == "fix"
  % Rounding to zero (2s complement)
  rtype=2;
else
  rtype=0;
endif
u=u(:);
N=length(u);
M=length(s10);
y=zeros(N,1);
yap=zeros(N,1);
x=zeros(1,M);
xx=zeros(N,M);

% Filter
for n = 1:N

  y(n)=x(1);
  star=x(1);
  for m = 1:M-1

    x(m) = s02(m)*star + s00(m)*x(m+1);
    star = s22(m)*star + s20(m)*x(m+1);
    % Simulate double length accumulator truncation of star
    if rtype == 1
      star = round(star);
    elseif rtype == 2
      star = fix(star);
    endif

    y(n) = s11(m)*y(n) + s10(m)*x(m+1);

    % Simulate double length accumulator truncation of y
    % Note that with an "acc+=(acc*B)" instruction the y could be 
    % calculated in one pass with only output truncation
    if rtype == 1
      y(n) = round(y(n));
    elseif rtype == 2
      y(n) = fix(y(n));
    endif

  endfor

  yap(n) = s22(M)*star + s20(M)*u(n);
  y(n) =   s11(M)*y(n) + s10(M)*u(n);
  x(M) =   s02(M)*star + s00(M)*u(n);

  % Simulate double length accumulator truncation of x
  if rtype == 1
    x = round(x);
  elseif rtype == 1
    x = fix(x);
  endif
  xx(n,:) = x;

endfor

% Simulate double length accumulator truncation
if rtype == 1
  y = round(y);
  yap = round(yap);
elseif rtype == 2
  y = fix(y);
  yap = fix(yap);
endif

endfunction
