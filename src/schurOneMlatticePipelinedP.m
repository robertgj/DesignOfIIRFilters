function [P,gradP,diagHessP,hessP] = ...
  schurOneMlatticePipelinedP(w,k,epsilon,c,kk,ck)
% [P,gradP,diagHessP,hessP] = schurOneMlatticePipelinedP(w,k,epsilon,c,kk,ck)
% Calculate the phase responses of a pipelined Schur one-multiplier
% lattice filter. If the order of the filter numerator polynomial is N, then
% there are N+1 numerator tap coefficients, c. If the order of the denominator
% polynomial is Nk, then there are Nk one-multiplier lattice section
% coefficients, k. The epsilon inputs scale the internal nodes.
%
% Inputs:
%   w - column vector of angular frequencies
%   k - one-multiplier allpass section denominator multiplier coefficients
%   epsilon - one-multiplier allpass section sign coefficients (+1 or -1)
%   c - numerator all-pass filter tap coefficients
%   kk - nominally k(1:(Nk-1)).*k(2:Nk)
%   ck - nominally c(2:Nk).*k(2:Nk) (c(1)=c_{0}, c(Nk+1)=c_{Nk})
%
% Outputs:
%   P - the phase response at w
%   gradP - the gradients of P with respect to k, c and kk
%   diagHessP - diagonal of the Hessian of P with respect to k, c and kk
%   hessP - Hessian of P with respect to k, c and kk

% Copyright (C) 2023-2024 Robert G. Jenssen
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
    print_usage("P=schurOneMlatticePipelinedP(w,k,epsilon,c,kk,ck)");
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
    P=[];gradP=[];diagHessP=[];hessP=[];
    return;
  endif

  % Calculate the complex transfer function at w 
  [A,B,C,D,~,~,dAdx,dBdx,dCdx,dDdx,~,~] = ...
    schurOneMlatticePipelined2Abcd(k,epsilon,c,kk,ck);

  if nargout == 1
    H = Abcd2H(w,A,B,C,D);
    P = H2P(H);
    
  elseif nargout == 2
   [H,~,dHdx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
   [P,gradP] = H2P(H,dHdx);

  elseif nargout == 3
    [H,~,dHdx,~,diagd2Hdx2] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
    [P,gradP,diagHessP] = H2P(H,dHdx,diagd2Hdx2);

  elseif nargout == 4
    [H,~,dHdx,~,diagd2Hdx2,~,d2Hdydx] = Abcd2H(w,A,B,C,D,dAdx,dBdx,dCdx,dDdx);
    [P,gradP,diagHessP,hessP] = H2P(H,dHdx,diagd2Hdx2,d2Hdydx);

  endif
endfunction
