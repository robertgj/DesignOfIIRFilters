function ndigits_alloc=schurOneMPAlattice_allocsd_Ito ...
                         (nbits,ndigits,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p, ...
                          difference,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)
% ndigits_alloc=schurOneMPAlattice_allocsd_Ito ...
%   (nbits,ndigits,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference, ...
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

% Copyright (C) 2017-2024 Robert G. Jenssen
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
  if ((nargin~=12)&&(nargin~=15)&&(nargin~=18)&&(nargin~=21)) || (nargout~=1)
    print_usage ("ndigits_alloc=schurOneMPAlattice_allocsd_Ito ...\n\
      (nbits,ndigits,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference, ...\n\
       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)");
  endif
  if length(A1k)~=length(A1epsilon) || length(A1k)~=length(A1p)
    error("Input A1 coefficient vector lengths inconsistent!");
  endif
  if length(A2k)~=length(A2epsilon) || length(A2k)~=length(A2p)
    error("Input A2 coefficient vector lengths inconsistent!");
  endif
  if (length(Asqd)~=length(wa)) || (length(Asqd)~=length(Wa))
    error("Input squared-amplitude vector lengths inconsistent!");
  endif
  if nargin<15
    wt=[];Td=[];Wt=[];
  else
    if (length(Td)~=length(wt)) || (length(Td)~=length(Wt))
      error("Input delay vector lengths inconsistent!");
    endif
  endif
  if nargin<18
    wp=[];Pd=[];Wp=[];
  else
    if (length(Pd)~=length(wp)) || (length(Pd)~=length(Wp))
      error("Input phase vector lengths inconsistent!");
    endif
  endif
  if nargin<21
    wd=[];Dd=[];Wd=[];
  else
    if (length(Dd)~=length(wd)) || (length(Dd)~=length(Wd))
      error("Input dAsqdw vector lengths inconsistent!");
    endif
  endif

  %
  % Initialise
  %
  NA1=length(A1k);
  NA2=length(A2k);
  RA1=1:NA1;
  RA2=(NA1+1):(NA1+NA2);
  k=[A1k(:);A2k(:)];
  % Find the non-zero coefficients in k
  tol=2.^(-nbits);
  inzk=find(abs(k(:)') >=tol);
  % Find the initial costs for the upper and lower bound of each non-zero k
  [k_sd,k_sdU,k_sdL]=flt2SD(k,nbits,2*ndigits);
  cost_k=inf*ones(size(k));
  for l=inzk
    kdel=k;
    kdel(l)=k_sdU(l);
    cost_kU=schurOneMPAlatticeEsq(kdel(RA1),A1epsilon,A1p, ...
                                  kdel(RA2),A2epsilon,A2p,difference, ...
                                  wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    kdel(l)=k_sdL(l);
    cost_kL=schurOneMPAlatticeEsq(kdel(RA1),A1epsilon,A1p, ...
                                  kdel(RA2),A2epsilon,A2p,difference, ...
                                  wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
    if cost_kU>cost_kL
      cost_k(l)=cost_kU;
    else
      cost_k(l)=cost_kL;
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
      [nextk,nextkU,nextkL]=flt2SD(k,nbits,ndigits_alloc);
      kdel(imk)=nextkU(imk);
      cost_kU=schurOneMPAlatticeEsq(kdel(RA1),A1epsilon,A1p, ...
                                    kdel(RA2),A2epsilon,A2p,difference, ...
                                    wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      kdel(imk)=nextkL(imk);
      cost_kL=schurOneMPAlatticeEsq(kdel(RA1),A1epsilon,A1p, ...
                                    kdel(RA2),A2epsilon,A2p,difference, ...
                                    wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);
      if cost_kU>cost_kL
        cost_k(imk)=cost_kU;
      else
        cost_k(imk)=cost_kL;
      endif
    endif
  endwhile

endfunction
