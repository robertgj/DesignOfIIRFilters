function Azp=johansson_cascade_allpassAzp(wa,fM,a0,a1)
% Azp=johansson_cascade_allpassAzp(wa,fM,a0,a1)
% Inputs:
%   wa - angular frequencies
%   fM - M+1 distinct coefficients of an even order, symmetric FIR filter
%        in the form [fM_0 ... fM_M]
%   a0,a1 - all-pass transformation denominator polynomials
% Outputs:
%   Azp - zero-phase amplitude at wa
  
% Copyright (C) 2019-2025 Robert G. Jenssen
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

  if (nargout > 1) || (nargin ~= 4)
    print_usage("Azp=johansson_cascade_allpassAzp(wa,fM,a0,a1)");
  endif
  if isempty(fM)
    error("fM is empty");
  endif
  if isempty(wa)
    Azp=[];
    return;
  endif

  fM=fM(:)';
  a0=a0(:)';
  a1=a1(:)';
  wa=wa(:);
  
  Mon2=length(fM)-1;
  oneswa=ones(size(wa));
  kfM=kron(oneswa,fM(1:Mon2));

  Ha0=freqz(fliplr(a0),a0,wa);
  Ha1=freqz(fliplr(a1),a1,wa);
  coskOmegaT=cos(kron(arg(Ha0)-arg(Ha1),Mon2:-1:1));
  Azp=fM(Mon2+1)+2*sum(kfM.*coskOmegaT,2);

endfunction
