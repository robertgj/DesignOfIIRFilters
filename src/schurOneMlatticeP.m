function [P,gradP,diagHessP]=schurOneMlatticeP(w,k,epsilon,p,c)
% [P,gradP,diagHessP]=schurOneMlatticeP(w,k,epsilon,p,c)
% Calculate the phase responses and gradients of a Schur one-multiplier
% lattice filter. If the order of the filter numerator polynomial is N, then
% there are N+1 numerator tap coefficients, c. If the order of the denominator
% polynomial is Nk, then there are Nk one-multiplier lattice section
% coefficients, k. The epsilon and p inputs scale the internal nodes.
%
% Inputs:
%   w - column vector of angular frequencies
%   k - one-multiplier allpass section denominator multiplier coefficients
%   epsilon - one-multiplier allpass section sign coefficients (+1 or -1)
%   p - internal state scaling factors
%   c - numerator all-pass filter tap coefficients 
%
% Outputs:
%   P - the phase response at w
%   gradP - the gradients of P with respect to k and c
%   diagHessP - diagonal of the Hessian of P with respect to k and c

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

  %
  % Sanity checks
  %
  if (nargin ~= 5) || (nargout > 3) 
    print_usage("[P,gradP,diagHessP]=schurOneMlatticeP(w,k,epsilon,p,c)");
  endif
  if length(k) ~= length(epsilon)
    error("length(k) ~= length(epsilon)");
  endif
  if length(k) ~= length(p)
    error("length(k) ~= length(p)");
  endif
  if(length(k)+1) ~= length(c)
    error("(length(k)+1) ~= length(c)");
  endif
  if length(w) == 0
    P=[]; gradP=[]; diagHessP=[];
    return;
  endif

  % Calculate the complex transfer function at w 
  if nargout==1
    [A,B,C,D]=schurOneMlattice2Abcd(k,epsilon,p,c);
    H=schurOneMlattice2H(w,A,B,C,D);
    P=H2P(H);
  elseif nargout==2
    [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc]=...
      schurOneMlattice2Abcd(k,epsilon,p,c);
    [H,dHdw,dHdkc]=schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
    [P,gradP]=H2P(H,dHdkc);
  elseif nargout==3
    [A,B,C,D,Cap,Dap,dAdkc,dBdkc,dCdkc,dDdkc]=...
      schurOneMlattice2Abcd(k,epsilon,p,c);
    [H,dHdw,dHdkc,d2Hdwdkc,diagd2Hdkc2]=...
      schurOneMlattice2H(w,A,B,C,D,dAdkc,dBdkc,dCdkc,dDdkc);
    [P,gradP,diagHessP]=H2P(H,dHdkc,diagd2Hdkc2);
  endif    

endfunction
