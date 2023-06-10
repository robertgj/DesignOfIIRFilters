function [cost,s10,s11,s20,s00,s02,s22,svecnz_out] = ...
         schurNSlattice_cost(svecnz,_Ad,_Wa,_Td,_Wt, ...
                             _s10_0,_s11_0,_s20_0,_s00_0,_s02_0,_s22_0, ...
                             _use_symmetric_s,_nbits,_ndigits,_max_cost)
% function cost=schurNSlattice_cost(svecnz)
%
% function [cost,s10,s11,s20,s00,s02,s22,svecnz_out]=schurNSlattice_cost(svecnz)
%
% function [cost,s10,s11,s20,s00,s02,s22,svecnz_out] = ...
%          schurNSlattice_cost(svecnz,Ad,Wa,Td,Wt, ...
%                              s10_0,s11_0,s20_0,s00_0,s0_0,s22_0, ...
%                              use_symmetric_s,nbits,ndigits,max_cost)
%
% Calculate the weighted error (cost) of the frequency response of a
% scaled-normalised Schur lattice filter. Intended to be used as the
% cost function of an optimisation routine.
  
% Notes:
%   1. "use_symmetric_s==false" means that the "rotation" matrixes
%      of each all-pass section are not required to have s02=-s20 and s00=s22.
%   2. Ad,Wa,Td and Wt are assumed to have the same lengths and the
%      the corresponding implicit frequency points are evenly spaced in [0,pi)
%   3. Coefficients that are initially zero are not included in the
%      optimisation.
%   4. nbits is assumed to be a scalar. If nbits==0 then do not truncate
%      svecnz. Otherwise, decode ndigits
%      as follows:
%        a. If ndigits==0 then round the coefficients to nbits 2's
%           complement integers.
%        b. If ndigits is a non-zero scalar then use ndigits signed-digits
%           for each filter coefficient
%        c. If ndigits is an array then allocate ndigits(i) signed-digits to
%           the corresponding svecnz(i)
%   5. Workarounds for samin: 
%       - samin expects svecnz to be a column vector
%       - samin adds to the end of svecnz
%       - samin calls this function with two arguments
%   6. Workarounds for max_cost:
%       - de_min fails if max_cost is inf
%       - simplex fails if max_cost is not inf

   
% Copyright (C) 2017-2023 Robert G. Jenssen
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
  persistent s10_0 s11_0 s20_0 s00_0 s02_0 s22_0 use_symmetric_s
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
    s10_0=_s10_0(:)';
    s11_0=_s11_0(:)';
    s20_0=_s20_0(:)';
    s00_0=_s00_0(:)';
    s02_0=_s02_0(:)';
    s22_0=_s22_0(:)';
    use_symmetric_s=_use_symmetric_s;
    if use_symmetric_s
      svec=[s10_0,s11_0,s20_0,s00_0];
    else
      svec=[s10_0,s11_0,s20_0,s00_0,s02_0,s22_0];
    endif
    lsvec=length(svec);
    nsvecnz=find(svec~=0);
    svecnz=svec(nsvecnz);
    lsvecnz=length(svecnz);
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
  elseif (nargin~=1) && (nargin~=2)
    print_usage("[cost,s10,s11,s20,s00,s02,s22,svecnz_out] = ...\n\
         schurNSlattice_cost(svecnz,Ad,Wa,Td,Wt, ...\n\
                             s10_0,s11_0,s20_0,s00_0,s02_0,s22_0, ...\n\
                             use_symmetric_s,nbits,ndigits,max_cost)");
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
  % Extract the lattice coefficients from the scaled svecnz
  svec=zeros(1,lsvec);
  svec(nsvecnz)=svecnz;
  [s10,s11,s20,s00,s02,s22]=svec2NS(svec,lsvec,use_symmetric_s);
  if any(abs(s20)>1) || any(abs(s00)>1) || any(abs(s02)>1) || any(abs(s22)>1)
    cost=max_cost;
    return;
  endif
  % Restore svec to the bitflip optimiser integer format
  svecnz=svecnz.*nscale;
  svecnz_out=svecnz(:);
  % Find cost
  [n,d]=schurNSlattice2tf(s10,s11,s20,s00,s02,s22);
  h=freqz(n,d,npoints);
  h=h(:);
  cost=sqrt(sum(Wa.*((abs(h)-abs(Ad)).^2)));
  if ~isempty(Td)
    t=delayz(n,d,npoints);
    t=t(:);
    tnf=find(~isfinite(t));
    t(tnf)=Td(tnf);
    cost=cost+sqrt(sum(Wt.*((abs(t-Td)).^2)));
  endif
endfunction

function [s10,s11,s20,s00,s02,s22]=svec2NS(svec,lsvec,use_symmetric_s)
  if (nargin ~= 3) || (nargout ~= 6)
    print_usage("[s10,s11,s20,s00,s02,s22]=svec2NS(svec,lsvec,use_symmetric_s)");
  endif

  if use_symmetric_s
    if mod(lsvec,4)
      error("mod(length(svec),4)~=0");
    endif
    svec=svec(1:lsvec);
    svec=svec(:);
    svec=reshape(svec,lsvec/4,4);
    s10=svec(:,1);
    s11=svec(:,2);
    s20=svec(:,3);
    s00=svec(:,4);
    s02=-svec(:,3);
    s22=svec(:,4);
  else
    if mod(lsvec,6)
      error("mod(length(svec),6)~=0");
    endif
    svec=svec(1:lsvec);
    svec=svec(:);
    svec=reshape(svec,lsvec/6,6);
    s10=svec(:,1);
    s11=svec(:,2);
    s20=svec(:,3);
    s00=svec(:,4);
    s02=svec(:,5);
    s22=svec(:,6);
  endif
endfunction
