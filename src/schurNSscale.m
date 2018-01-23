function [s10,s11,s20,s00,s02,s22] = schurNSscale(k,c)
% [s10,s11,s20,s00,s02,s22] = schurNSscale(k,c)

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

  if (nargin ~= 2) || (nargout ~= 6)
    print_usage("[s10,s11,s20,s00,s02,s22] = schurNSscale(k,c)");
  endif
  if (nargin == 2)
    verbose = false;
  endif
  if (isempty(c))
    error("c is empty");
  endif
  if ((length(k)+1) ~= length(c))
    error("(length(k)+1) ~= length(c)");
  endif

  warning("Using Octave m-file version of function schurNSscale()!");

  % The number of modules is length(c)-1 
  N=length(c)-1;  

  % Cumulative sum of squared expansion coefficients (for scaling)
  cc=sqrt(cumsum(c.^2));

  % Synthesise scaled coefficients of the lattice filter
  if N==0
    s10=c;
    s11=0;
    k=1;
  elseif N==1
    s10=c(2);
    s11=cc(1);
  else
    s10=[c(2:N)./cc(2:N) c(N+1)];
    s11=[cc(1:(N-1))./cc(2:N) cc(N)];
  endif

  % Combine sigma_10(0)(so-called) and sigma_11(1)
  s11(1)=s11(1)*sign(c(1));

  % Copy the lattice elements
  s20=k;
  s00=sqrt(1-(k.^2));
  s02=-k;
  s22=s00;

endfunction
