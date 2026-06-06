function ...
  ndigits_alloc = schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Lim ...
                    (nbits,ndigits,A1k,A2k,difference,B1k,B2k, ...
                     wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)
% ndigits_alloc=schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Lim ...
%   (nbits,ndigits,A1k,A2k,difference,B1k,B2k, ...
%    wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd)
%
% Lim et al. signed-digit allocation algorithm. See: "Signed Power-of-Two Term
% Allocation Scheme for the Design of Digital Filters", Y. C. Lim, R. Yang,
% D. Li and J. Song, IEEE Transactions on Circuits and Systems-II:Analog and
% Digital Signal Processing, Vol. 46, No. 5, May 1999, pp.577-584

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
      "  schurOneMPAlatticeDoublyPipelinedAntiAliased_allocsd_Lim ...\n", ...
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

  % Calculate the response squared-error and gradient
  [Esq,gradEsq]=schurOneMPAlatticeDoublyPipelinedAntiAliasedEsq ...
                  (A1k,A2k,difference,B1k,B2k, ...
                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp,wd,Dd,Wd);

  % Allocate signed digits to non-zero coefficients
  k=[A1k(:);A2k(:);B1k(:);B2k(:)];
  cost=0.36*(log2(abs(k))+log2(abs(gradEsq')));
  ndigits_alloc=zeros(size(k));
  R=ndigits*sum(double(abs(k)>=(2^(-nbits))));
  while R>0
    [mc,imc]=max(cost);
    cost(imc)=cost(imc)-1;
    ndigits_alloc(imc)=ndigits_alloc(imc)+1;
    R=R-1;
  endwhile
  
endfunction
