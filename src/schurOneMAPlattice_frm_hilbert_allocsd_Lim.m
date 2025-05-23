function ndigits_alloc=schurOneMAPlattice_frm_hilbert_allocsd_Lim ...
  (nbits,ndigits,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel,wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
% ndigits_alloc=schurOneMAPlattice_frm_hilbert_allocsd_Lim ...
%   (nbits,ndigits,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...
%    wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)
%
% Lim's signed-digit allocation algorithm. See: "Signed Power-of-Two Term
% Allocation Scheme for the Design of Digital Filters", Y. C. Lim, R. Yang,
% D. Li and J. Song, IEEE Transactions on Circuits and Systems-II:Analog and
% Digital Signal Processing, Vol. 46, No. 5, May 1999, pp.577-584

% Copyright (C) 2017-2025 Robert G. Jenssen
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
  if ((nargin~=12)&&(nargin~=15)&&(nargin~=18)) || nargout~=1
    print_usage (["ndigits_alloc=schurOneMAPlattice_frm_hilbert_allocsd_Lim ...\n", ...
 "      (nbits,ndigits,k0,epsilon0,p0,u0,v0,Mmodel,Dmodel, ...\n", ...
 "       wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp)"]);
  endif
  if length(k0)~=length(epsilon0) || ...
     length(k0)~=length(p0) || ...
     (length(v0)+1)~=length(u0)
    error("Input coefficient vector lengths inconsistent!");
  endif
  if isempty(Wa)
    Wa=ones(size(wa));
  endif
  if length(Asqd)~=length(wa) || length(Asqd)~=length(Wa) 
    error("Input squared-amplitude vector lengths inconsistent!");
  endif
  if nargin<15
    wt=[];Td=[];Wt=[];
  else 
    if isempty(Wt)
      Wt=ones(size(wt));
    endif
    if length(Td)~=length(wt) || length(Td)~=length(Wt)
      error("Input delay vector lengths inconsistent!");
    endif
  endif
  if nargin<18
    wp=[];Pd=[];Wp=[];
  else
    if isempty(Wp)
      Wp=ones(size(wp));
    endif
    if length(Pd)~=length(wp) || length(Pd)~=length(Wp)
      error("Input phase vector lengths inconsistent!");
    endif
  endif

  % Calculate the response squared-error and gradient
  [Esq,gradEsq]=schurOneMAPlattice_frm_hilbertEsq ...
                  (k0,epsilon0,p0,u0,v0,Dmodel,Mmodel, ...
                   wa,Asqd,Wa,wt,Td,Wt,wp,Pd,Wp);

  % Allocate signed digits to non-zero coefficients
  kuv0=[k0(:);u0(:);v0(:)];
  cost=0.36*(log2(abs(kuv0))+log2(abs(gradEsq')));
  ndigits_alloc=zeros(size(kuv0));
  R=ndigits*sum(double(abs(kuv0)>=(2^(-nbits))));
  while R>0
    [mc,imc]=max(cost);
    cost(imc)=cost(imc)-1;
    ndigits_alloc(imc)=ndigits_alloc(imc)+1;
    R=R-1;
  endwhile
  
endfunction
