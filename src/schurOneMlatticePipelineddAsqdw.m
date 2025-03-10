function [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw] = ...
  schurOneMlatticePipelineddAsqdw(w,k,epsilon,c,kk,ck)
% [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw] = ...
%  schurOneMlatticePipelineddAsqdw(w,k,epsilon,c,kk,ck)
% Calculate the gradients of the squared-magnitude responses of a pipelined
% Schur one-multiplier lattice filter. If the order of the filter numerator
% polynomial is N, then there are N+1 numerator tap coefficients, c. If the
% order of the denominator polynomial is Nk, then there are Nk one-multiplier
% lattice section coefficients, k. The epsilon inputs scale the internal nodes.
%
% Inputs:
%   w - column vector of angular frequencies
%   k - one-multiplier allpass section denominator multiplier coefficients
%   epsilon - one-multiplier allpass section sign coefficients (+1 or -1)
%   c - numerator all-pass filter tap coefficients
%   kk - k(1:(Nk-1)).*k(2:Nk)
%   ck - c(2:Nk).*k(2:Nk) (c(1)=c_{0}, ... ,c(Nk+1)=c_{Nk})
%
% Outputs:
%   dAsqdw - the group delay response at w
%   graddAsqdw - the gradients of dAsqdw with respect to k, etc
%   diagHessdAsqdw - diagonal of the Hessian of dAsqdw with respect to k, etc
%   hessdAsqdw - Hessian of dAsqdw with respect to k, etc

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
  if (nargin ~= 6) || (nargout > 4) 
    print_usage(["dAsqdw=schurOneMlatticePipelineddAsqdw(w,k,epsilon,c,kk,ck)\n", ...
 "[dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw]= ...\n", ...
 " schurOneMlatticePipelineddAsqdw(w,k,epsilon,c,kk,ck)"]);
  endif
  if length(k) ~= length(epsilon)
    error("length(k) ~= length(epsilon)");
  endif
  if (length(k)+1) ~= length(c)
    error("(length(k)+1) ~= length(c)");
  endif
  if (length(k)-1) ~= length(kk)
    error("(length(k)-1) ~= length(kk)");
  endif
  if (length(k)-1) ~= length(ck)
    error("(length(k)-1) ~= length(ck)");
  endif
  if length(w) == 0
    dAsqdw=[];graddAsqdw=[];diagHessdAsqdw=[];hessdAsqdw=[];
    return;
  endif

  [A,B,C,D,~,~,dAdx,dBdx,dCdx,dDdx,~,~] = ...
    schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck);

  % Calculate the complex transfer function at w 
  if nargout == 1
    [H,dHdw]=Abcd2H(w,A,B,C,D);
    dAsqdw=H2dAsqdw(H,dHdw);

  elseif nargout == 2
    [H,dHdw,dHdx,d2Hdwdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
    [dAsqdw,graddAsqdw] = H2dAsqdw(H,dHdw,dHdx,d2Hdwdx);

  elseif nargout == 3
    [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2] = ...
           Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
    [dAsqdw,graddAsqdw,diagHessdAsqdw] = ...
      H2dAsqdw(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2);

  elseif nargout == 4
    [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx] = ...
      Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
    [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw] = ...
      H2dAsqdw(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx);
 
  endif

endfunction
