function [x,a]=selesnickFIRsymmetric_lowpass_exchange ...
                 (x0,a0,ai,eindex,pindex,sindex,deltap,deltas)

% [x,a]=selesnickFIRsymmetric_lowpass_exchange ...
%  (x0,a0,ai,eindex,pindex,sindex,deltap,deltas)
% Implement the Selesnick-Burrus exchange algorithm for the extremal frequencies
% of a linear-phase FIR filter with given pass-band and stop-band ripples.
%
% Inputs:
%   x0 - initial extremal frequencies (coswT)
%   a0 - initial extremal amplitudes
%   ai - frequency response
%   eindex - extremal indexes in ai
%   pindex - highest pass-band index in eindex
%   sindex - lowest stop-band index in eindex
%   deltap - desired pass-band amplitude response ripple
%   deltas - desired stop-band amplitude response ripple
%
% Outputs:
%   x - updated extremal frequencies
%   a - updated extremal amplitudes
%
% See: Section II.B of "Exchange Algorithms that Complement the Parks-McClellan
% Algorithm for Linear-Phase FIR Filter Design", Ivan W. Selesnick and
% C. Sidney Burrus, IEEE TRANSACTIONS ON CIRCUITS AND SYSTEMS—II: ANALOG AND
% DIGITAL SIGNAL PROCESSING, VOL. 44, NO. 2, FEBRUARY 1997, pp. 137-143

% Copyright (C) 2020 Robert G. Jenssen
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

  if (nargin ~= 8) || (nargout ~= 2)
    print_usage ...
      ("[x,a]=selesnickFIRsymmetric_lowpass ...\n\
                (x0,a0,ai,eindex,pindex,sindex,deltap,deltas)");
  endif
  if length(x0)~=length(a0)
    error("length(x0)~=length(a0");
  endif
    if ~isscalar(deltap)
    error("~isscalar(deltap)");
  endif
  if ~isscalar(deltas)
    error("~isscalar(deltas)");
  endif
  if deltap<=0
    error("deltap<=0");
  endif
  if deltap>=1
    error("deltap>=1");
  endif
  if deltas<=0
    error("deltas<=0");
  endif
  if deltas>=1
    error("deltas>=1");
  endif

  if pindex==1
  % No extrema in the open interval x=(1,xt)
    x=x0(2:end);
    a=a0(2:end);
  elseif sindex==length(eindex)
  % No extrema in the open interval (xt,-1)
    x=x0(1:(end-1));
    a=a0(1:(end-1));
  else
    if (abs(ai(1)-ai(eindex(2)))*deltas) < ...
       (abs(ai(end)-ai(eindex(end-1)))*deltap)
      x=x0(2:end);
      a=a0(2:end);
    else
      x=x0(1:(end-1));
      a=a0(1:(end-1));
    endif
  endif
  
endfunction
