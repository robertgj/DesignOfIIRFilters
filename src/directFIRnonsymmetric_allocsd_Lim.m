function ndigits_alloc=directFIRnonsymmetric_allocsd_Lim ...
  (nbits,ndigits,h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% ndigits_alloc=directFIRsymmetric_allocsd_Lim ...
%               (nbits,ndigits,h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
%
% Inputs:
%   h - nonsymmetric FIR filter polynomial
%   wa - squared amplitude angular frequencies
%   Asqd - desired squared amplitude response
%   Wa - squared amplitude response weights
%   wt - group delay angular frequencies
%   Td - desired group delay response
%   Wt - group delay response weights
%   wp - phase angular frequencies
%   Pd - desired phase response
%   Wp - phase response weights
%
% A modified version of Lims digit allocation algorithm:
%   - the total signed-digit allocation is initially set to a large
%     number and reduced to that desired
%   - a digit is removed from the allocation to the coefficient that has
%     the minimum maximum approximation error unless that digits allocation
%     is already 0 or 1.
% See: "Signed Power-of-Two Term Allocation Scheme for the Design of Digital
% Filters", Y. C. Lim, R. Yang, D. Li and J. Song, IEEE Transactions on
% Circuits and Systems-II:Analog and Digital Signal Processing, Vol. 46,
% No. 5, May 1999, pp.577-584

% Copyright (C) 2026 Robert G. Jenssen
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

  %
  % Sanity checks
  %
  if ((nargin~=6) && (nargin~=9) && (nargin~=12)) || (nargout~=1)
    print_usage(["ndigits_alloc=directFIRnonsymmetric_allocsd_Lim ...", ...
                 "  (nbits,ndigits,h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)"]);
  endif

  if nargin >= 6
    if length(wa) ~= length(Asqd)
      error("length(wa) ~= length(Asqd)");
    endif
    if length(wa) ~= length(Wa)
      error("length(wa) ~= length(Wa)");
    endif
  endif
  if nargin < 9
    wt=[];Td=[];Wt=[];
  endif
  if nargin >= 9
    if length(wt) ~= length(Td)
      error("length(wt) ~= length(Td)");
    endif
    if length(wt) ~= length(Wt)
      error("length(wt) ~= length(Wt)");
    endif
  endif
  if nargin < 12
    wp=[];Pd=[];Wp=[];
  endif
  if nargin == 12
    if length(wp) ~= length(Pd)
      error("length(wp) ~= length(Pd)");
    endif
    if length(wp) ~= length(Wp)
      error("length(wp) ~= length(Wp)");
    endif
  endif
    
 % Calculate the response squared-error and gradient
  [Esq,gradEsq]=directFIRnonsymmetricEsq(h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

  % Allocate signed digits to non-zero coefficients
  cost=0.36*(log2(abs(h))+log2(abs(gradEsq')));
  ndigits_alloc=zeros(size(h));
  R=ndigits*sum(double(abs(h)>=(2^(-nbits))));
  while R>0
    [mc,imc]=max(cost);
    cost(imc)=cost(imc)-1;
    ndigits_alloc(imc)=ndigits_alloc(imc)+1;
    R=R-1;
  endwhile

endfunction
