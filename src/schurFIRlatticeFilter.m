function [y xx]=schurFIRlatticeFilter(k,u,rounding)
% [y xx]=schurFIRlatticeFilter(k,u,rounding)
% Use the FIR lattice filter coefficients, k, to filter the input sequence, 
% u, producing the filtered output, y. If rounding="round", use
% rounding to nearest. If rounding="fix" use truncation to zero(2s complement).
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
%   psi   >------>o----->+--->
%                  \    /
%                   \  ki
%                    \/
%                    /\
%                   /  ki
%           z^-1   /    \
%   psi*  >------>o----->+--->

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
  if nargin ~= 3
    print_usage("[y xx]=schurNSlatticeFilter(k,u,rounding)");
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
  k=k(:)';
  N=length(u);
  M=length(k);
  y=zeros(N,1);
  x=zeros(1,M);
  xx=zeros(N,M);

  % Filter
  for n = 1:N

    psi=u(n);
    psistar=u(n);

    for m = 1:M
      nextpsi = psi+k(m)*x(m);
      nextpsistar=k(m)*psi + x(m);
      x(m)=psistar;
      psi=nextpsi;
      psistar=nextpsistar;
      % Simulate double length accumulator truncation of x, psi, psistar
      if rtype == 1
        x(m) = round(x(m));
        psi = round(psi);
        psistar = round(psistar);
      elseif rtype == 2
        x(m) = fix(x(m));
        psi = fix(psi);
        psistar = fix(psistar);
      endif
    endfor
    
    y(n) = psi;
    xx(n,:) = x;

  endfor

endfunction
