function [cost,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,svecnz_out] = ...
         schurNSPAlattice_cost(svecnz,_Ad,_Wa,_Td,_Wt, ...
                               _A1s20_0,_A1s00_0,_A1s02_0,_A1s22_0, ...
                               _A2s20_0,_A2s00_0,_A2s02_0,_A2s22_0, ...
                               _use_symmetric_s,_nbits,_ndigits,_max_cost)
% function cost=schurNSPAlattice_cost(svecnz)
%  
% function [cost,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,svecnz_out]= ...
%          schurNSPAlattice_cost(svecnz)
%
% function [cost,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,svecnz_out]= ...
%          schurNSPAlattice_cost(svecnz,Ad,Wa,Td,Wt, ...
%                                A1s20_0,A1s00_0,A1s02_0,A1s22_0, ...
%                                A2s20_0,A2s00_0,A2s02_0,A2s22_0, ...
%                                use_symmetric_s,nbits,ndigits,max_cost)
%
% Calculate the weighted error (cost) of the frequency response of the
% parallel combination of two all-pass scaled-normalised Schur lattice filters.
% Intended to be used as the cost function of an optimisation routine.
  
% Notes:
%   1. "use_symmetric_s==false" means that the "rotation" matrixes
%      of each all-pass section are not required to be orthogonal.
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
  persistent A1s20_0 A1s00_0 A1s02_0 A1s22_0 A2s20_0 A2s00_0 A2s02_0 A2s22_0
  persistent use_symmetric_s lA1 lA2
  persistent lsvec lsvecnz nsvecnz 
  persistent nbits nscale ndigits npoints
  persistent max_cost
  persistent init_done=false

  if (nargin==16) || (nargin==17)
    if nargin==16
      max_cost=inf;
    else
      max_cost=_max_cost;
    endif
    cost=max_cost;
    Ad=_Ad(:);
    Wa=_Wa(:);
    Td=_Td(:);
    Wt=_Wt(:);
    A1s20_0=_A1s20_0(:)';
    A1s00_0=_A1s00_0(:)';
    A1s02_0=_A1s02_0(:)';
    A1s22_0=_A1s22_0(:)';
    A2s20_0=_A2s20_0(:)';
    A2s00_0=_A2s00_0(:)';
    A2s02_0=_A2s02_0(:)';
    A2s22_0=_A2s22_0(:)';
    use_symmetric_s=_use_symmetric_s;
    if use_symmetric_s
      svec=[A1s20_0,A1s00_0,A2s20_0,A2s00_0];
      lA1=2*length(A1s20_0);
      lA2=2*length(A2s20_0);
    else
      svec=[A1s20_0,A1s00_0,A1s02_0,A1s22_0,A2s20_0,A2s00_0,A2s02_0,A2s22_0];
      lA1=4*length(A1s20_0);
      lA2=4*length(A2s20_0);
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
    print_usage ...
    ("[cost,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,svecnz_out] = ... \n\
         schurNSPAlattice_cost(svecnz,Ad,Wa,Td,Wt, ... \n\
                               A1s20_0,A1s00_0,A1s02_0,A1s22_0, ... \n\
                               A2s20_0,A2s00_0,A2s02_0,A2s22_0, ... \n\
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
  % Extract the coefficients from the scaled svecnz
  svec=zeros(1,lsvec);
  svec(nsvecnz)=svecnz;
  [A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22] = ...
    svec2NSPA(svec,lA1,lA2,use_symmetric_s);
  if any(abs(A1s20)>1) || any(abs(A1s00)>1) ...
     || any(abs(A1s02)>1) || any(abs(A1s22)>1) ...
     || any(abs(A2s20)>1) || any(abs(A2s00)>1) ...
     || any(abs(A2s02)>1) || any(abs(A2s22)>1)
    cost=max_cost;
    return;
  endif
  % Restore svec to the bitflip optimiser integer format
  svecnz=svecnz.*nscale;
  svecnz_out=svecnz(:);
  % Find cost
  [n,d]=schurNSPAlattice2tf(A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22);
  h=freqz(n,d,npoints);
  h=h(:);
  cost=sqrt(sum(Wa.*((abs(h)-abs(Ad)).^2)));
  if ~isempty(Td)
    t=grpdelay(n,d,npoints);
    t=t(:);
    cost=cost+sqrt(sum(Wt.*((abs(t-Td)).^2)));
  endif
endfunction

function [A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22] = ...
         svec2NSPA(svec,lA1,lA2,use_symmetric_s)

  if (nargin ~= 4) || (nargout ~= 8)
    print_usage("[A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22] = ...\n\
                 svec2NSPA(svec,lA1,lA2,use_symmetric_s)");
  endif
  if length(svec) ~= (lA1+lA2)
     error("length(svec) ~= (lA1+lA2)");
  endif
  
  if use_symmetric_s
    if mod(lA1,2)
      error("mod(lA1,2)(=%d)~=0",lA1);
    endif
    if mod(lA2,2)
      error("mod(lA2,2)(=%d)~=0",lA2);
    endif

    A1s=svec(1:lA1);
    A1s=A1s(:);
    A1s=reshape(A1s,lA1/2,2);
    A1s20=A1s(:,1);
    A1s00=A1s(:,2);
    A1s02=-A1s20;
    A1s22=A1s00;

    A2s = svec((lA1+1):end);
    A2s=A2s(:);
    A2s=reshape(A2s,lA2/2,2);
    A2s20=A2s(:,1);
    A2s00=A2s(:,2);
    A2s02=-A2s20;
    A2s22=A2s00;
  else
    if mod(lA1,4)
      error("mod(lA1,4)(=%d)~=0",lA1);
    endif
    if mod(lA2,4)
      error("mod(lA2,4)(=%d)~=0",lA2);
    endif

    A1s=svec(1:lA1);
    A1s=A1s(:);
    A1s=reshape(A1s,lA1/4,4);
    A1s20=A1s(:,1);
    A1s00=A1s(:,2);
    A1s02=A1s(:,3);
    A1s22=A1s(:,4);

    A2s = svec((lA1+1):end);
    A2s=A2s(:);
    A2s=reshape(A2s,lA2/4,4);
    A2s20=A2s(:,1);
    A2s00=A2s(:,2);
    A2s02=A2s(:,3);
    A2s22=A2s(:,4);
  endif
endfunction         
