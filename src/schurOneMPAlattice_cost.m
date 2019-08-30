function [cost,A1k,A2k,svecnz_out] = ...
         schurOneMPAlattice_cost(svecnz,_Ad,_Wa,_Td,_Wt, ...
                                 _A1k0,_A1epsilon0,_A1p0, ...
                                 _A2k0,_A2epsilon0,_A2p0, ...
                                 _difference,_nbits,_ndigits,_max_cost)
% cost=schurOneMPAlattice_cost(svecnz)
%
% [cost,A1k,A2k,svecnz_out] = schurOneMPAlattice_cost(svecnz)
%
% [cost,A1k,A2k,svecnz_out] = ...
%    schurOneMPAlattice_cost(svecnz,Ad,Wa,Td,Wt, ...
%                            A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
%                            difference,nbits,ndigits)
%
% [cost,A1k,A2k,svecnz_out] = ...
%    schurOneMPAlattice_cost(svecnz,Ad,Wa,Td,Wt, ...
%                            A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...
%                            difference,nbits,ndigits,max_cost)
%
% Calculate the weighted error (cost) of the frequency response of the
% parallel combination of two all-pass one-multiplier Schur lattice filters.
% Intended to be used as the cost function of an optimisation routine.
%
% Calculate the weighted error (cost) of the frequency response of a
% one-multiplier Schur lattice filter. Intended to be used as the
% cost function of an optimisation routine.
%
% Notes:
%   1. Ad,Wa,Td and Wt are assumed to have the same lengths and the
%      the corresponding implicit frequency points are evenly spaced in [0,pi)
%   2. Coefficients that are initially zero are not included in the
%      optimisation.
%   3. nbits is assumed to be a scalar. If nbits==0 then do not truncate
%      svecnz. Otherwise, decode ndigits
%      as follows:
%        a. If ndigits==0 then round the coefficients to nbits 2's
%           complement integers.
%        b. If ndigits is a non-zero scalar then use ndigits signed-digits
%           for each filter coefficient
%        c. If ndigits is an array then allocate ndigits(i) signed-digits to
%           the corresponding svecnz(i)
%   4. Workarounds for samin: 
%       - samin expects svecnz to be a column vector
%       - samin adds to the end of svecnz
%       - samin calls this function with two arguments
%   5. Workarounds for max_cost:
%       - de_min fails if max_cost is inf
%       - simplex fails if max_cost is not inf


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

  persistent Ad Wa Td Wt
  persistent A1k0 A1epsilon0 A1p0 A2k0 A2epsilon0 A2p0 difference
  persistent lsvec lsvecnz nsvecnz
  persistent nbits nscale ndigits npoints
  persistent max_cost
  persistent init_done=false

  if (nargin==14) || (nargin==15)
    if nargin==14
      max_cost=inf;
    else
      max_cost=_max_cost;
    endif
    cost=max_cost;
    Ad=_Ad(:);
    Wa=_Wa(:);
    Td=_Td(:);
    Wt=_Wt(:);
    A1k0=_A1k0(:)';
    A1epsilon0=_A1epsilon0(:)';
    A1p0=_A1p0(:)';
    A2k0=_A2k0(:)';
    A2epsilon0=_A2epsilon0(:)';
    A2p0=_A2p0(:)';
    svec=[A1k0,A2k0];
    lsvec=length(svec);
    nsvecnz=find(svec~=0);
    svecnz=svec(nsvecnz);
    lsvecnz=length(svecnz);
    difference=_difference;
    nbits=_nbits;
    ndigits=_ndigits;
    if ~isscalar(ndigits)
      ndigits=ndigits(:)';
      if size(ndigits) ~= size(svec)
        error("Expect (length(ndigits)(%d) ~= length(svec)(%d))",
              length(ndigits),length(svec));
      endif
    endif
    npoints=length(Ad);
    nshift=2^(nbits-1);
    if ~isscalar(nbits)
      error("Expect nbits to be a scalar");
    elseif nbits ~= 0
      nscale=nshift./(2.^x2nextra(svecnz,nshift));
    else
      nscale=1;
    endif
    svecnz=svecnz.*nscale;
    svecnz=svecnz(:);
    init_done=true;
  elseif (nargin ~= 1)
    print_usage("[cost,A1k,A2k,svecnz_out] = schurOneMPAlattice_cost(svecnz)\n\
[cost,A1k,A2k,svecnz_out] = schurOneMPAlattice_cost(svecnz,Ad,Wa,Td,Wt, ...\n\
                              A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...\n\
                              difference,nbits,ndigits)\n\
[cost,A1k,A2k,svecnz_out] = schurOneMPAlattice_cost(svecnz,Ad,Wa,Td,Wt, ...\n\
                              A1k0,A1epsilon0,A1p0,A2k0,A2epsilon0,A2p0, ...\n\
                              difference,nbits,ndigits,max_cost)");
  elseif init_done==false
    error("init_done==false");
  endif
  % Scale and truncate svecnz
  svecnz=svecnz(1:lsvecnz);
  svecnz=svecnz(:)';
  if nbits ~= 0
    if isscalar(ndigits)
      if ndigits == 0
        svecnz=round(svecnz)./nscale;
      else
        svecnz=svecnz./nscale;
        svecnz=flt2SD(svecnz,nbits,ndigits);        
      endif
    else
      svecnz=svecnz./nscale;
      svecnz=flt2SD(svecnz,nbits,ndigits(nsvecnz));
    endif
  endif
  % Extract the coefficients from the scaled svecnz
  svec=zeros(1,lsvec);
  svec(nsvecnz)=svecnz;
  % Check stability 
  A1k=svec(1:length(A1k0));
  A2k=svec((length(A1k0)+1):lsvec);
  if any(abs(A1k)>=1) || any(abs(A2k)>=1)
    cost=max_cost;
    return;
  endif
  % Restore svec to the bitflip optimiser integer format
  svecnz=svecnz.*nscale;
  svecnz_out=svecnz(:);
  % Find cost
  [n,d]=schurOneMPAlattice2tf(A1k,A1epsilon0,A1p0, ...
                              A2k,A2epsilon0,A2p0,difference);
  h=freqz(n,d,npoints);
  h=h(:);
  cost=sqrt(sum(Wa.*((abs(h)-abs(Ad)).^2)));
  if ~isempty(Td)
    t=grpdelay(n,d,npoints);
    t=t(:);
    cost=cost+sqrt(sum(Wt.*((t-Td).^2)));
  endif
endfunction

