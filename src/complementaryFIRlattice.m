function [hm,g,k,khat] = complementaryFIRlattice(h,tol,Nw)
% [hm,g,k,khat]=complementaryFIRlattice(h,[tol,Nw])
% Find the FIR filter, g, with a complementary response, G, to that of
% h, H, ie: |H|^2+|G|^2=1, and the FIR lattice coefficients, k and khat.
% h is scaled so that max|H|=1.
  
% Copyright (C) 2017-2022 Robert G. Jenssen
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
  if nargin > 3 || nargout ~= 4
    print_usage("[hm,g,k,khat] = complementaryFIRlattice(h[,tol,Nw])");
  endif
  if nargin < 2
    tol = 20*eps;
  endif
  if nargin < 3
    Nw=2^16;
  endif

  %
  % Scale h to have a maximum response of 1
  %
  h=h(:);
  hm=direct_form_scale(h,1,Nw);
  
  %
  % Find the complementary filter, g
  %
  % Find the filter corresponding to |H|^2
  hh=conv(hm(:),flipud(hm(:)));
  % Find the filter corresponding to 1-|H|^2.
  MM=(length(hh)-1)/2;
  gg=[zeros(MM,1); 1; zeros(MM,1)]-hh;
  % Use Orchard's routine to find the minimum-phase component of 1-|H|^2
  [g,ssp,iter]=minphase(gg(length(h):end));
  g=g(:);

  if nargout <= 2
    return;
  endif
  
  %
  % Find the lattice coefficients
  %
  [k,khat] = complementaryFIRdecomp(hm,g,tol);

  %
  % Sanity checks
  %
  if abs(((hm')*hm)+((g')*g)-1) > tol
    error("abs(((hm')*hm)+((g')*g)-1)(%g*eps) > (%g*eps)",
          abs(((hm')*hm)+((g')*g)-1)/eps, tol/eps);
  endif
  if max(abs((k.^2)+(khat.^2)-ones(size(k)))) > tol
    error("max(abs((k.^2)+(khat.^2)-ones(size(k))))(%g*eps)>(%g*eps)",
          max(abs((k.^2)+(khat.^2)-ones(size(k))))/eps,tol/eps);
  endif

endfunction
