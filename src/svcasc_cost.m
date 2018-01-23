function [cost,a11,a12,a21,a22,b1,b2,c1,c2,dd,svecnz_out] = ...
     svcasc_cost(svecnz,_Ad,_Wa,_Td,_Wt, ...
                 _a11_0,_a12_0,_a21_0,_a22_0,_b1_0,_b2_0,_c1_0,_c2_0,_dd_0, ...
                 _nbits,_ndigits,_max_cost)
% function cost=svcasc_cost(svecnz)
%
% function [cost,a11,a12,a21,a22,b1,b2,c1,c2,dd,svecnz_out]=svcasc_cost(svecnz)
%
% function [cost,a11,a12,a21,a22,b1,b2,c1,c2,dd,svecnz_out] = ...
%   svcasc_cost(svecnz,Ad,Wa,Td,Wt,a11,a12,a21,a22,b1,b2,c1,c2,dd, ...
%               nbits,ndigits,max_cost)
%
% Calculate the weighted error (cost) of the frequency response of a
% filter implemented as a cascade of 2nd-order state variable sections.
% Intended to be used as the cost function of an optimisation routine.
  
% Notes:
%   1. Ad,Wa,Td and Wt are assumed to have the same lengths and the
%      the corresponding implicit frequency points are evenly spaced in [0,pi)
%   2. Coefficients that are initially zero are not included in the optimisation
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
  persistent a11_0 a12_0 a21_0 a22_0 b1_0 b2_0 c1_0 c2_0 dd_0
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
    a11_0=_a11_0(:)';
    a12_0=_a12_0(:)';
    a21_0=_a21_0(:)';
    a22_0=_a22_0(:)';
    b1_0=_b1_0(:)';
    b2_0=_b2_0(:)';
    c1_0=_c1_0(:)';
    c2_0=_c2_0(:)';
    dd_0=_dd_0(:)';
    svec=[a11_0,a12_0,a21_0,a22_0,b1_0,b2_0,c1_0,c2_0,dd_0];
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
    print_usage("[cost,a11,a12,a21,a22,b1,b2,c1,c2,dd,svecnz_out] = ... \n\
  svcasc_cost(svecnz,Ad,Wa,Td,Wt,a11,a12,a21,a22,b1,b2,c1,c2,dd, ...\n\
              nbits,ndigits,max_cost)");
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
  % Extract the 2nd order cascade coefficients from the scaled svecnz
  svec=zeros(1,lsvec);
  svec(nsvecnz)=svecnz;
  [a11,a12,a21,a22,b1,b2,c1,c2,dd]=svec2svcasc(svec,lsvec);
  % Restore svec to the bitflip optimiser integer format
  svecnz=svecnz.*nscale;
  svecnz_out=svecnz(:);
  % Find cost
  [n,d]=svcasc2tf(a11,a12,a21,a22,b1,b2,c1,c2,dd);
  % Check stability
  if any(abs(roots(d)) >= 1)
    cost=max_cost;
    return;
  endif
  h=freqz(n,d,npoints);
  h=h(:);
  cost=sqrt(sum(Wa.*((abs(h)-abs(Ad)).^2)));
  if ~isempty(Td)
    t=grpdelay(n,d,npoints);
    t=t(:);
    cost=cost+sqrt(sum(Wt.*((abs(t-Td)).^2)));
  endif
endfunction

function [a11,a12,a21,a22,b1,b2,c1,c2,dd]=svec2svcasc(svec,lsvec)
  if (nargin ~= 2) || (nargout ~= 9)
    print_usage("[a11,a12,a21,a22,b1,b2,c1,c2,dd]=svec2svcasc(svec,lsvec)");
  endif

  if mod(lsvec,nargout)
    error("mod(length(svec),%d)~=0",nargout);
  endif
  svec=svec(1:lsvec);
  svec=svec(:);
  svec=reshape(svec,lsvec/nargout,nargout);
  a11=svec(:,1)'; 
  a12=svec(:,2)'; 
  a21=svec(:,3)'; 
  a22=svec(:,4)'; 
  b1=svec(:,5)'; 
  b2=svec(:,6)'; 
  c1=svec(:,7)'; 
  c2=svec(:,8)'; 
  dd=svec(:,9)'; 
endfunction
