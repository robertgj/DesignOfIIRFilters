function ndigits_alloc=directFIRnonsymmetric_allocsd_Ito ...
  (nbits,ndigits,h,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% ndigits_alloc=directFIRsymmetric_allocsd_Ito ...
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
% A modified version of Itos digit allocation algorithm:
%   - the total signed-digit allocation is initially set to a large
%     number and reduced to that desired
%   - a digit is removed from the allocation to the coefficient that has
%     the minimum maximum approximation error unless that digits allocation
%     is already 0 or 1.
% See: "A powers-of-two term allocation algorithm for designing FIR
% filters with CSD coefficients in a min-max sense", Rika Ito, Tetsuya Fujie,
% Kenji Suyama and Ryuichi Hirabayashi.
% http://www.eurasip.org/Proceedings/Eusipco/Eusipco2004/defevent/papers/cr1722.pdf

% Copyright (C) 2025 Robert G. Jenssen
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
    print_usage(["ndigits_alloc=directFIRnonsymmetric_allocsd_Ito ...", ...
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
    
  %
  % Initialise
  %
  N=length(h);
  Rh=1:N;
  % Find the non-zero coefficients in h
  tol=2.^(-nbits);
  inzh=find(abs(h(:)') >=tol);
  % Find the initial costs for the upper and lower bound of each non-zero h
  [h_sd,h_sdu,h_sdl]=flt2SD(h,nbits,2*ndigits);
  cost_h=inf*ones(size(h));
  for l=inzh
    hdel=h;
    hdel(l)=h_sdu(l);
    cost_hu=directFIRnonsymmetricEsq(hdel(Rh),wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    hdel(l)=h_sdl(l);
    cost_hl=directFIRnonsymmetricEsq(hdel(Rh),wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
    if cost_hu>cost_hl
      cost_h(l)=cost_hu;
    else
      cost_h(l)=cost_hl;
    endif
  endfor
  
  %
  % Loop reducing the number of digits allocated
  % to find the desired total number of signed-digits
  %
  ndigits_alloc=zeros(size(h));
  ndigits_alloc(inzh)=2*ndigits;
  desired_total_digits=ndigits*length(inzh);
  while sum(ndigits_alloc) > desired_total_digits
    % Update the digits allocated to the coefficient with least cost
    [min_cost_h,imh]=min(cost_h);
    ndigits_alloc(imh)=ndigits_alloc(imh)-1;

    % Update the cost
    if ndigits_alloc(imh) <= 1
      cost_h(imh)=inf;
    else
      hdel=h;
      [nexth,nexthu,nexthl]=flt2SD(h,nbits,ndigits_alloc);
      hdel(imh)=nexthu(imh);
      cost_hu=directFIRnonsymmetricEsq(hdel(Rh),wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      hdel(imh)=nexthl(imh);
      cost_hl=directFIRnonsymmetricEsq(hdel(Rh),wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);
      if cost_hu>cost_hl
        cost_h(imh)=cost_hu;
      else
        cost_h(imh)=cost_hl;
      endif
    endif
  endwhile

endfunction
