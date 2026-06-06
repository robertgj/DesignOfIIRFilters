function ...
  ndigits_alloc = schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Ito ...
                    (nbits,ndigits,A1k,A2k,difference,B1k,B2k, ...
                     wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)
% ndigits_alloc=schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Ito ...
%   (nbits,ndigits,A1k,A2k,difference,B1k,B2k, ...
%    wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)
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
  if (nargin<10) || ...
     ((nargin~=10) && (nargin~=13) && (nargin~=16) && (nargin~=19)) || ...
     (nargout~=1)
    print_usage
    (["ndigits_alloc= ...\n", ...
      "  schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Ito ...\n", ...
      "    (nbits,ndigits,A1k,A2k,difference,B1k,B2k, ...\n", ...
      "     wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)"]);
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
  NA1k=length(A1k);
  NA2k=length(A2k);
  NB1k=length(B1k);
  NB2k=length(B2k);
  RA1k=1:NA1k;
  RA2k=(NA1k+1):(NA1k+NA2k);
  RB1k=(NA1k+NA2k+1):(NA1k+NA2k+NB1k);
  RB2k=(NA1k+NA2k+NB1k+1):(NA1k+NA2k+NB1k+NB2k);
  k=[A1k(:);A2k(:);B1k(:);B2k(:)];
  % Find the non-zero coefficients in k
  tol=2.^(-nbits);
  inzk=find(abs(k(:)') >=tol);
  % Find the initial costs for the upper and lower bound of each non-zero k
  [k_sd,k_sdu,k_sdl]=flt2SD(k,nbits,2*ndigits);
  cost_k=inf*ones(size(k));
  for m=inzk
    kdel=k;
    kdel(m)=k_sdu(m);
    cost_ku=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
              (kdel(RA1k),kdel(RA2k),difference,kdel(RB1k),kdel(RB2k), ...
               wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    kdel(m)=k_sdl(m);
    cost_kl=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
              (kdel(RA1k),kdel(RA2k),difference,kdel(RB1k),kdel(RB2k), ...
               wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    if cost_ku>cost_kl
      cost_k(m)=cost_ku;
    else
      cost_k(m)=cost_kl;
    endif
  endfor
  
  %
  % Loop reducing the number of digits allocated
  %
  % Find the desired total number of signed-digits
  ndigits_alloc=zeros(size(k));
  ndigits_alloc(inzk)=2*ndigits;
  desired_total_digits=ndigits*length(inzk);
  while sum(ndigits_alloc) > desired_total_digits
    % Update the digits allocated to the coefficient with least cost
    [min_cost_k,imk]=min(cost_k);
    ndigits_alloc(imk)=ndigits_alloc(imk)-1;

    % Update the cost
    if ndigits_alloc(imk) <= 1
      cost_k(imk)=inf;
    else
      kdel=k;
      [nextk,nextku,nextkl]=flt2SD(k,nbits,ndigits_alloc);
      kdel(imk)=nextku(imk);
      cost_ku=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
                (kdel(RA1k),kdel(RA2k),difference,kdel(RB1k),kdel(RB2k), ...
                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      kdel(imk)=nextkl(imk);
      cost_kl=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
                (kdel(RA1k),kdel(RA2k),difference,kdel(RB1k),kdel(RB2k), ...
                 wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      if cost_ku>cost_kl
        cost_k(imk)=cost_ku;
      else
        cost_k(imk)=cost_kl;
      endif
    endif
  endwhile

endfunction
