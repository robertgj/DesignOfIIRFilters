function [y yc xx]=complementaryFIRlatticeFilter(k,khat,u,rounding)
% [y yc xx]=complementaryFIRlatticeFilter(k,khat,u[,rounding])
% Use the complementary FIR lattice filter coefficients, k and khat,
% to filter the input sequence, u, producing the filtered output, y.
% If rounding="round", use rounding to nearest. If rounding="fix" use
% truncation to zero(2s complement).
%
% The FIR lattice filter structure is:
%        _______             _______       
% In --->|     |---> ... --->|     |---> Out
%     |  |     |             |     |
%     |  |  k1 |             |  kN |
%     |  |     |             |     |
%     -->|     |---> ... --->|     |
%        -------             -------
%
% Each module 1,..,N is implemented as:
%
%                    kn 
%   hn-1  >------>o----->+--->  hn
%                  \    /
%                   \  -^kn
%                    \/
%                    /\
%                   / ^kn
%           z^-1   /    \
%   gn-1  >------>o----->+--->  gn
%                    kn
  
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
  if nargin~=3 && nargin~=4
    print_usage("[y xx]=schurNSlatticeFilter(k,khat,u[,rounding])");
  endif
  if length(k) ~= length(khat)
    error("Expect length(k) == length(khat) !");
  endif
  
  % Initialise rounding
  rtype=0;
  if nargin == 4
    rounding=rounding(1:3);
    if rounding == "rou"
      % Rounding to nearest
      rtype=1;
    elseif rounding == "fix"
      % Rounding to zero (2s complement)
      rtype=2;
    endif
  endif
    
  % Initialise state
  k=k(:)';
  khat=khat(:)';
  M=length(k)-1;
  N=length(u);
  x=zeros(1,M);
  xx=zeros(N,M);

  % Initialise output
  y=zeros(N,1);
  yc=zeros(N,1);

  % Filter
  for n = 1:N

    hn=u(n)*k(1);
    gn=u(n)*khat(1);

    for m = 1:M
      nexthn = hn*k(m+1)    - khat(m+1)*x(m);
      nextgn = hn*khat(m+1) + k(m+1)*x(m);
      x(m)=gn;
      hn=nexthn;
      gn=nextgn;
      % Simulate double length accumulator truncation of x and gn
      if rtype == 1
        x(m) = round(x(m));
      elseif rtype == 2
        x(m) = fix(x(m));
      endif
    endfor

    xx(n,:) = x;

    if rtype == 1
      y(n) = round(hn);
      yc(n) = round(gn);
    elseif rtype == 2
      y(n) = fix(hn); 
      yc(n) = fix(gn);
    else
      y(n) = hn;
      yc(n) = gn;
    endif

  endfor

endfunction
