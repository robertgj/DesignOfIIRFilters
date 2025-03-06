function [y,xx]=svf(a,b,c,d,u,rounding,efb)
% [y,xx]=svf(a,b,c,d,u,rounding,efb)
% svf filters the input u using the state variable equations 
% represented by a,b,c,d. rounding determines the rounding used,
% "round" for rounding to nearest, "fix" for rounding to zero,
% "floor" for rounding to -inf and "lperrfb" for low-pass
% error feedback with efb bits. The row numbers of y and u correspond
% to sample number. The rows of u are inputs at each sample and the
% rows of y are the outputs at each sample.

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

% Sanity checks
if nargin<5 || nargin>7 || nargout>2
  print_usage("y=svf(a,b,c,d,u) \n\
[y,xx]=svf(a,b,c,d,u) \n\
[y,xx]=svf(a,b,c,d,u,rounding) \n\
[y,xx]=svf(a,b,c,d,u,rounding,efb)");
endif
if rows(a)~=columns(a)
  error("rows(a)~=columns(a)");
endif
if rows(a)~=rows(b)
  error("rows(a)~=rows(b)");
endif
if columns(a)~=columns(c)
  error("columns(a)~=columns(c)");
endif
if columns(b)~=columns(d)
  error("columns(b)~=columns(d)");
endif
if rows(c)~=rows(d)
  error("rows(c)~=rows(d)");
endif
if columns(u)~=columns(d)
  error("columns(u)~=columns(d)");
endif
if nargin==5
  rounding="none";
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
nstates=columns(a);
xk=zeros(nstates,1);

% Allocate output storage now for speed
nsamples=rows(u);
xx=zeros(nsamples,nstates);
noutputs=rows(d);
y=zeros(nsamples,noutputs);

% Do the filter
for k=1:nsamples
  uk=u(k,:)';    
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
  y(k,:)=yk';
  xx(k,:)=xk';
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
