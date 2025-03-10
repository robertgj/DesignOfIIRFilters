function ndigits_alloc=schurOneMlatticePipelined_allocsd_Ito ...
  (nbits,ndigits,k0,epsilon0,c0,kk0,ck0,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)
% ndigits_alloc=schurOneMlatticePipelined_allocsd_Ito ...
%   (nbits,ndigits,k0,epsilon0,c0,kk0,ck0,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)
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

% Copyright (C) 2024-2025 Robert G. Jenssen
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
  if (nargin<10) || ...
     ((nargin~=10) && (nargin~=13) && (nargin~=16) && (nargin~=19)) || ...
     (nargout~=1)
    print_usage (["ndigits_alloc=schurOneMlatticePipelined_allocsd_Ito ...\n", ...
 "      (nbits,ndigits,k0,epsilon0,c0,kk0,ck0, ...\n", ...
 "       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)"]);
  endif
  if length(k0)~=length(epsilon0) || ...
     (length(k0)+1)~=length(c0) || ...
     (length(k0)-1)~=length(kk0) || ...
     (length(k0)-1)~=length(ck0)
    error("Input coefficient vector lengths inconsistent!");
  endif
  if (length(Asqd)~=length(wa)) || (length(Asqd)~=length(Wa))
    error("Input squared-amplitude vector lengths inconsistent!");
  endif
  if nargin < 13
    wt=[];Td=[];Wt=[];
  else
    if (length(Td)~=length(wt)) || (length(Td)~=length(Wt))
      error("Input delay vector lengths inconsistent!");
    endif
  endif
  if nargin < 16
    wp=[];Pd=[];Wp=[];
  else
    if (length(Pd)~=length(wp)) || (length(Pd)~=length(Wp)) 
      error("Input phase vector lengths inconsistent!");
    endif
  endif
  if nargin<19
    wd=[];Dd=[];Wd=[];
  else
    if (length(Dd)~=length(wd)) || (length(Dd)~=length(Wd))
      error("Input dAsqdw vector lengths inconsistent!");
    endif
  endif

  %
  % Initialise
  %
  Nk=length(k0);
  Nc=length(c0);
  Nkk=length(kk0);
  Nck=length(ck0);
  Rk=1:Nk;
  Rc=(Nk+1):(Nk+Nc);
  Rkk=(Nk+Nc+1):(Nk+Nc+Nkk);
  Rck=(Nk+Nc+Nkk+1):(Nk+Nc+Nkk+Nck);
  kc0=[k0(:);c0(:);kk0(:);ck0(:)];
  % Find the non-zero coefficients in k0, c0, kk0 and ck0
  tol=2.^(-nbits);
  inzkc=find(abs(kc0(:)') >= tol);
  % Find the initial costs for the upper and lower bound of each non-zero k,c
  [kc_sd,kc_sdU,kc_sdL]=flt2SD(kc0,nbits,2*ndigits);
  cost_kc=inf*ones(size(kc0));
  for l=inzkc
    kcdel=kc0;
    kcdel(l)=kc_sdU(l);
    cost_kcU=schurOneMlatticePipelinedEsq ...
               (kcdel(Rk),epsilon0,kcdel(Rc),kcdel(Rkk),kcdel(Rck), ...
                wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    kcdel(l)=kc_sdL(l);
    cost_kcL=schurOneMlatticePipelinedEsq ...
               (kcdel(Rk),epsilon0,kcdel(Rc),kcdel(Rkk),kcdel(Rck), ...
                wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    if cost_kcU>cost_kcL
      cost_kc(l)=cost_kcU;
    else
      cost_kc(l)=cost_kcL;
    endif
  endfor
  
  %
  % Loop reducing the number of digits allocated
  %
  % Find the desired total number of signed-digits
  ndigits_alloc=zeros(size(kc0));
  ndigits_alloc(inzkc)=2*ndigits;
  desired_total_digits=ndigits*length(inzkc);
  while sum(ndigits_alloc) > desired_total_digits
    % Update the digits allocated to the coefficient with least cost
    [min_cost_kc,imkc]=min(cost_kc);
    ndigits_alloc(imkc)=ndigits_alloc(imkc)-1;

    % Update the cost
    if ndigits_alloc(imkc) <= 1
      cost_kc(imkc)=inf;
    else
      kcdel=kc0;
      [nextkc,nextkcU,nextkcL]=flt2SD(kc0,nbits,ndigits_alloc);
      kcdel(imkc)=nextkcU(imkc);
      cost_kcU=schurOneMlatticePipelinedEsq ...
                 (kcdel(Rk),epsilon0,kcdel(Rc),kcdel(Rkk),kcdel(Rck), ...
                  wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      kcdel(imkc)=nextkcL(imkc);
      cost_kcL=schurOneMlatticePipelinedEsq ...
                 (kcdel(Rk),epsilon0,kcdel(Rc),kcdel(Rkk),kcdel(Rck), ...
                  wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      if cost_kcU>cost_kcL
        cost_kc(imkc)=cost_kcU;
      else
        cost_kc(imkc)=cost_kcL;
      endif
    endif
  endwhile

endfunction
