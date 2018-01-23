function [y,xx1,xx2]=svcascf(a11,a12,a21,a22,b1,b2,c1,c2,d,u,rounding,xbits)
% [y,xx1,xx2]=svcascf(a11,a12,a21,a22,b1,b2,c1,c2,d,u,rounding,xbits)
% svcascf filters the input u using the cascaded 2nd order state
% variable sections represented by a11,a12,a21,a22,b1,b2,c1,c2
% and d. rounding determines the rounding used,
% "round" for rounding to nearest, "fix" for rounding to zero,
% "floor" for rounding to -inf. xx1 and xx2 are the time values
% of the x1 and x2 state variables for each section. xbits adds
% extra bits to the state variables. y contains the output from
% each section.

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

  if (nargin<11) || (nargin>12)
    print_usage("[y,xx1,xx2]=svcascf(a11,a12,a21,a22,b1,b2,c1,c2,d, ...\n\
    u,rounding,extra_bits)");
  endif
  if (nargin==11)
    xbits=zeros(size(d));
  endif
  sections=max(size(d));
  if sections ~= length(a11) || sections ~= length(a12) || ...
     sections ~= length(a21) || sections ~= length(a22) || ...
     sections ~= length(b1)  || sections ~= length(b2)  || ...
     sections ~= length(c1)  || sections ~= length(c2)  || ...
     sections ~= length(b1)  || sections ~= length(b2)  || ...
     sections ~= length(xbits)
    error("Expect section coefficient vectors to have equal length!");
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
  else
    rtype=0;
  end

  % Allocate state variable storage 
  x1=zeros(sections,1);
  x2=zeros(sections,1);

  % Allocate output storage now for speed
  u=u(:);
  nsamples=length(u);
  xscale=2.^xbits;
  xx1=zeros(nsamples,sections);
  xx2=zeros(nsamples,sections);
  y=zeros(nsamples,sections);

  % Do the filter
  for k=1:nsamples

    % Do each section
    utmp=u(k);
    for l=1:sections
      ytmp= ( c1(l)*x1(l)/xscale(l)) + ( c2(l)*x2(l)/xscale(l)) + ( d(l)*utmp);
      x1tmp=(a11(l)*x1(l)/xscale(l)) + (a12(l)*x2(l)/xscale(l)) + (b1(l)*utmp);
      x2(l)=(a21(l)*x1(l)/xscale(l)) + (a22(l)*x2(l)/xscale(l)) + (b2(l)*utmp);
      x1(l)=x1tmp;
      
      % Scale the state variables according to the extra bit allocation
      x1(l)=x1tmp*xscale(l);
      x2(l)=x2(l)*xscale(l);
      
      % Round the output
      if rtype == 1
        ytmp=round(ytmp);
      elseif rtype == 2
        ytmp=floor(ytmp);
      elseif rtype == 3
        ytmp=fix(ytmp);
      end

      % Save the output from each section
      utmp=ytmp;
      y(k,l)=ytmp;
    endfor

    % Round the state variables
    if rtype == 1       
      x1=round(x1);
      x2=round(x2);
    elseif rtype == 2
      x1=floor(x1);
      x2=floor(x2);
    elseif rtype == 3
      x1=fix(x1);
      x2=fix(x2);
    end

    % Save the state variables
    xx1(k,:)=x1;
    xx2(k,:)=x2;
  end

endfunction
