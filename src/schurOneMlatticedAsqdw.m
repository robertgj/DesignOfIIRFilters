function [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw]= ...
  schurOneMlatticedAsqdw(w,k,epsilon,p,c)
% [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw]= ...
%  schurOneMlatticedAsqw(w,k,epsilon,p,c)
% Calculate the gradients with respect to frequency of the squared-magnitude
% response of a Schur one-multiplier lattice filter.
%
% Inputs:
%   w - column vector of angular frequencies
%   k - one-multiplier allpass section denominator multiplier coefficients
%   epsilon - one-multiplier allpass section sign coefficients (+1 or -1)
%   p - internal state scaling factors
%   c - numerator all-pass filter tap coefficients 
%
% Outputs:
%   dAsqdw - gradient with respect to frequency of the squared magnitude
%            response at w
%   graddAsqdw - gradients of dAsqdw with respect to k and c
%   diagHessdAsqdw - diagonal of the hessian of dAsqdw with respect to k and c
%   hessdAsqdw - hessian of dAsqdw with respect to k and c
  
% Copyright (C) 2024-2025 Robert G. Jenssen
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
  if (nargin ~= 5) || (nargout > 4) 
    print_usage ...
      (["[dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw]= ...\n", ...
 "         schurOneMlatticedAsqdw(w,k,epsilon,p,c)"]);
  endif
  if length(k) ~= length(epsilon)
    error("length(k) ~= length(epsilon)");
  endif
  if length(k) ~= length(p)
    error("length(k) ~= length(p)");
  endif
  if(length(k)+1) ~= length(c)
    error("(length(k)(%d)+1) ~= length(c)(%d)",length(k),length(c));
  endif
  
  if (length(w) == 0) || (nargout == 0)
    dAsqdw=[]; graddAsqdw=[]; diagHessdAsqdw=[]; hessdAsqdw=[];
    return;
  endif

  if nargout == 1
    [A,B,C,D]=schurOneMlattice2Abcd(k,epsilon,p,c);
    [H,dHdw]=schurOneMlattice2H(w,A,B,C,D);
    dAsqdw=H2dAsqdw(H,dHdw);
  elseif nargout == 2
    [A,B,C,D,~,~,dAdkc,dBdkc,dCdkc,dDdkc]=schurOneMlattice2Abcd(k,epsilon,p,c);
    [H,dHdw,dHdkc,d2Hdwdkc] = ...
      schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
    [dAsqdw,graddAsqdw]=H2dAsqdw(H,dHdw,dHdkc,d2Hdwdkc);
  elseif nargout == 3
    [A,B,C,D,~,~,dAdkc,dBdkc,dCdkc,dDdkc]=schurOneMlattice2Abcd(k,epsilon,p,c);
    [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2] = ...
      schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
    [dAsqdw,graddAsqdw,diagHessdAsqdw] = ...
      H2dAsqdw(H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2);
  else
    [A,B,C,D,~,~,dAdkc,dBdkc,dCdkc,dDdkc,~,~,d2Adkc2] = ...
      schurOneMlattice2Abcd(k,epsilon,p,c);
    [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2,d2Hdydx,d3Hdwdydx] = ...
      schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc,d2Adkc2);
    [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw] = ...
      H2dAsqdw(H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2,diagd3Hdwdkc2, ...
               d2Hdydx,d3Hdwdydx);
  endif

endfunction
