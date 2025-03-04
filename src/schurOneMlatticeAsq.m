function [Asq,gradAsq,diagHessAsq,hessAsq]=schurOneMlatticeAsq(w,k,epsilon,p,c)
% [Asq,gradAsq,diagHessAsq,hessAsq]=schurOneMlatticeAsq(w,k,epsilon,p,c)
% Calculate the squared-magnitude response and gradients of a Schur
% one-multiplier lattice filter. If the order of the filter numerator
% polynomial is N, then there are N+1 numerator tap coefficients, c.
% If the order of the denominator polynomial is Nk, then there are Nk
% one-multiplier lattice section coefficients, k. The epsilon and p inputs
% scale the internal nodes. 
%
% Inputs:
%   w - column vector of angular frequencies
%   k - one-multiplier allpass section denominator multiplier coefficients
%   epsilon - one-multiplier allpass section sign coefficients (+1 or -1)
%   p - internal state scaling factors
%   c - numerator all-pass filter tap coefficients 
%
% Outputs:
%   Asq - the squared magnitude response at w
%   gradAsq - the gradients of Asq with respect to k and c
%   diagHessAsq - diagonal of the Hessian of Asq with respect to k and c
%   hessAsq - Hessian of Asq with respect to k and c

% Copyright (C) 2017-2025 Robert G. Jenssen
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
    print_usage...
      ("[Asq,gradAsq,diagHessAsq,hessAsq]=schurOneMlatticeAsq(w,k,epsilon,p,c)");
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
  
  if length(w) == 0
    Asq=[]; gradAsq=[]; diagHessAsq=[]; hessAsq=[];
    return;
  endif

  if nargout==1 
    [A,B,C,D]=schurOneMlattice2Abcd(k,epsilon,p,c);
    H=schurOneMlattice2H(w,A,B,C,D);
    Asq=H2Asq(H);  
  elseif nargout==2 
    [A,B,C,D,~,~,dAdkc,dBdkc,dCdkc,dDdkc]=...
      schurOneMlattice2Abcd(k,epsilon,p,c);
    [H,~,dHdkc]=schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
    [Asq,gradAsq]=H2Asq(H,dHdkc);  
  elseif nargout==3
    [A,B,C,D,~,~,dAdkc,dBdkc,dCdkc,dDdkc,~,~,d2Adkc2] = ...
      schurOneMlattice2Abcd(k,epsilon,p,c);
    [H,~,dHdkc,~,diagd2Hdkc2] = ...
      schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc,d2Adkc2);
    [Asq,gradAsq,diagHessAsq]=H2Asq(H,dHdkc,diagd2Hdkc2);
  else
    [A,B,C,D,~,~,dAdkc,dBdkc,dCdkc,dDdkc,~,~,d2Adydx]=...
        schurOneMlattice2Abcd(k,epsilon,p,c);
    [H,~,dHdkc,~,diagd2Hdkdc,~,d2Hdydx] = ...
      schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc,d2Adydx);
    [Asq,gradAsq,diagHessAsq,hessAsq]=H2Asq(H,dHdkc,diagd2Hdkdc,d2Hdydx);
  endif
   
endfunction
