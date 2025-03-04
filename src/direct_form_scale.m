function [scaled_b,scaled_w,scaled_H] = direct_form_scale(b,a,Nw)
% [scaled_b,scaled_w,scaled_H] = direct_form_scale(b,a,Nw)
%
% Utility function to scale the maximum response of a direct form filter to 1.
%
% Inputs:
%   b,a - numerator and denominator polynomials of the direct form filter
%   Nw - size of the frequency response
%   
% Outputs:
%   scaled_b - scaled numerator polynomial
%   scaled_w - frequency response angular frequencies
%   scaled_H - frequency response

% Copyright (C) 2020-2025 Robert G. Jenssen
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

if (nargin > 3) || (nargout > 3)
  print_usage("[scaled_b,scaled_w,scaled_H] = direct_form_scale(b,a,Nw)");
endif

if nargin < 2
  a=1;
endif
if nargin < 3
  Nw=2^16;
endif

[H,w]=freqz(b,a,Nw);
[~,iH]=max(abs(H));
if iH==1
  iH=2;
endif
if iH==Nw
  iH=Nw-1;
endif
Nwi=16;
delw=(w(iH+1)-w(iH-1))/(2*Nwi);
wi=w(iH)+(((-Nwi):Nwi)*delw);
Hwi=freqz(b,a,wi);
[mHwi,iHwi]=max(abs(Hwi));
if iHwi~=1 && iHwi~=length(wi)
  % Quadratic interpolation to the maximum
  bp=polyfit(wi((iHwi-1):(iHwi+1)),abs(Hwi((iHwi-1):(iHwi+1))),2);
  mHwi=bp(3)-(0.25*bp(2)*bp(2)/bp(1));
endif
scaled_b=b/mHwi;
scaled_w=w;
scaled_H=freqz(scaled_b,a,Nw);

endfunction
