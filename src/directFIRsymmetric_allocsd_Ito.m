function ndigits_alloc=directFIRsymmetric_allocsd_Ito ...
  (nbits,ndigits,hM,waf,Adf,Waf)
% ndigits_alloc=directFIRsymmetric_allocsd_Ito(nbits,ndigits,hM,waf,Adf,Waf)
%
% Inputs:
%   hM - distinct coefficients of an even order, symmetric FIR filter polynomial
%   waf - angular frequencies of band edges in [0,pi] eg: [0 0.1 0.2 0.5]*2*pi
%   Adf - desired response, assumed to be 0 in stop bands, eg: [0 1 0]
%   Waf - weight in each band eg: [100 1 100]
%
% A modified version of Itos digit allocation algorithm:
%   - the total signed-digit allocation is initially set to a large
%     number and reduced to that desired
%   - a digit is removed from the allocation to the coefficient that has
%     the minimum maximum approximation error unless that digits allocation
%     is already 0 or 1.
% hM are the distinct coefficients of a symmetric even-order FIR filter
% polynomial. See: "A powers-of-two term allocation algorithm for designing FIR
% filters with CSD coefficients in a min-max sense", Rika Ito, Tetsuya Fujie,
% Kenji Suyama and Ryuichi Hirabayashi.
% http://www.eurasip.org/Proceedings/Eusipco/Eusipco2004/defevent/papers/cr1722.pdf

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

  %
  % Sanity checks
  %
  if (nargin~=6) || (nargout~=1)
    print_usage("ndigits_alloc=directFIRsymmetric_allocsd_Ito ...\
      (nbits,ndigits,hM,waf,Adf,Waf)");
  endif
  
  %
  % Initialise
  %
  N=length(hM);
  RhM=1:N;
  % Find the non-zero coefficients in hM
  tol=2.^(-nbits);
  inzhM=find(abs(hM(:)') >=tol);
  % Find the initial costs for the upper and lower bound of each non-zero k,c
  [hM_sd,hM_sdU,hM_sdL]=flt2SD(hM,nbits,2*ndigits);
  cost_hM=inf*ones(size(hM));
  for l=inzhM
    hMdel=hM;
    hMdel(l)=hM_sdU(l);
    cost_hMU=directFIRsymmetricEsqPW(hMdel(RhM),waf,Adf,Waf);
    hMdel(l)=hM_sdL(l);
    cost_hML=directFIRsymmetricEsqPW(hMdel(RhM),waf,Adf,Waf);
    if cost_hMU>cost_hML
      cost_hM(l)=cost_hMU;
    else
      cost_hM(l)=cost_hML;
    endif
  endfor
  
  %
  % Loop reducing the number of digits allocated
  % to find the desired total number of signed-digits
  %
  ndigits_alloc=zeros(size(hM));
  ndigits_alloc(inzhM)=2*ndigits;
  desired_total_digits=ndigits*length(inzhM);
  while sum(ndigits_alloc) > desired_total_digits
    % Update the digits allocated to the coefficient with least cost
    [min_cost_hM,imhM]=min(cost_hM);
    ndigits_alloc(imhM)=ndigits_alloc(imhM)-1;

    % Update the cost
    if ndigits_alloc(imhM) <= 1
      cost_hM(imhM)=inf;
    else
      hMdel=hM;
      [nexthM,nexthMU,nexthML]=flt2SD(hM,nbits,ndigits_alloc);
      hMdel(imhM)=nexthMU(imhM);
      cost_hMU=directFIRsymmetricEsqPW(hMdel(RhM),waf,Adf,Waf);
      hMdel(imhM)=nexthML(imhM);
      cost_hML=directFIRsymmetricEsqPW(hMdel(RhM),waf,Adf,Waf);
      if cost_hMU>cost_hML
        cost_hM(imhM)=cost_hMU;
      else
        cost_hM(imhM)=cost_hML;
      endif
    endif
  endwhile

endfunction
