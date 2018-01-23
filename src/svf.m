function [y,xx]=svf(a,b,c,d,u,rounding,efb)
% [y,xx]=svf(a,b,c,d,u,rounding,efb)
% svf filters the input u using the state variable equations 
% represented by a,b,c,d. rounding determines the rounding used,
% "round" for rounding to nearest, "fix" for rounding to zero,
% "floor" for rounding to -inf and "lperrfb" for low-pass
% error feedback with efb bits.

% Copyright (C) 2017,2018 Robert G. Jenssen
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

if nargin<5
  print_usage("[y,xx]=svf(a,b,c,d,u,rounding,efb)");
endif

% Decode rounding
rounding=rounding(1:3);
if rounding == "rou"
  % Round to nearest
  rtype=1;
elseif rounding == "flo" 
  % Truncation to -infinity instead of rounding
  rtype=2;
elseif rounding == "fix" 
  % Truncation to zero (2s complement)
  rtype=3;
elseif rounding == "lpe" 
  % Low-pass error feedback
  if nargin ~= 7
    print_usage("[y,xx]=svf(a,b,c,d,u,rounding,efb)");
  endif
  rtype=4;
else
  rtype=0;
end

% Allocate state variable storage 
xk=zeros(max(size(a)),1);

% Allocate output storage now for speed
u=u(:);
nsamples=length(u);
[ynout dec]=size(d);
nblocks=floor(nsamples/dec);
nstates=max(size(a));
xx=zeros(nblocks,nstates);
y=zeros(nsamples,1);

% Do the filter
for l=1:nblocks
  k=1+((l-1)*dec):l*dec;
  uk=u(k); 
  if rtype==4
    yk=c*round(xk)+d*uk;
  else
    yk=c*xk+d*uk;
  endif
  xk=a*xk+b*uk;
  % Round the state variables
  if rtype == 1       
    xk=round(xk);
  elseif rtype == 2
    xk=floor(xk);
  elseif rtype == 3
    xk=fix(xk);
  elseif rtype == 4
    xk=round(xk*(2^efb))/(2^efb);
  end
  % Save 
  y(k)=yk';
  xx(l,:)=xk;
end

% Round the output
if rtype == 1
  y=round(y);
elseif rtype == 2
  y=floor(y);
elseif rtype == 3
  y=fix(y);
elseif rtype == 4
  y=round(y);
end

endfunction
