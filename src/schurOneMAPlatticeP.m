function [P,gradP,diagHessP,hessP]=schurOneMAPlatticeP(w,k,epsilon,p,R)
% [P,gradP,diagHessP,hessP]=schurOneMAPlatticeP(w,k,epsilon,p,R)
% Calculate the phase responses and gradients of a Schur one-multiplier
% all-pass lattice filter. If the order of the denominator
% polynomial is Nk, then there are Nk one-multiplier lattice section
% coefficients, k. The epsilon and p inputs scale the internal nodes.
% The filter has coefficients only in z^R.
%
% Inputs:
%   w - column vector of angular frequencies
%   k - one-multiplier allpass section denominator multiplier coefficients
%   epsilon - one-multiplier allpass section sign coefficients (+1 or -1)
%   p - internal state scaling factors
%   R - coefficients only for z^R terms
%
% Outputs:
%   P - the phase response at w
%   gradP - the gradients of P with respect to k and c
%   diagHessP - diagonal of the Hessian of P with respect to k and c
%   hessP - Hessian of P with respect to k and c

% Copyright (C) 2017-2024 Robert G. Jenssen
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
  if (nargin < 2) || (nargin > 5) || (nargout > 4)
    print_usage ...
      ("[P,gradP,diagHessP,hessP]=schurOneMAPlatticeP(w,k[,epsilon,p,R])");
  endif
  if nargin <= 2
    epsilon=ones(size(k));
  else
    if length(k) ~= length(epsilon)
      error("length(k) ~= length(epsilon)");
    endif
  endif
  if nargin <= 3
    p=ones(size(k));
  else
    if length(k) ~= length(p)
      error("length(k) ~= length(p)");
    endif
  endif
  if (nargin <= 4)
    R=1;
    wR=w;
  else
    if ~isscalar(R)
      error("~isscalar(R)");
    endif
    wR=w*R;
  endif
 
  if length(w) == 0
    P=[]; gradP=[]; diagHessP=[]; hessP=[];
    return;
  endif

  % Calculate the complex transfer function at w
  if nargout==1
    [A,B,Cap,Dap] = schurOneMAPlattice2Abcd(k,epsilon,p);
    H = schurOneMAPlattice2H(wR,A,B,Cap,Dap);
    P = H2P(H);
  elseif nargout==2
    [A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk] = schurOneMAPlattice2Abcd(k,epsilon,p);
    [H,~,dHdk] = schurOneMAPlattice2H(wR,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
    [P,gradP] = H2P(H,dHdk);
  elseif nargout==3
    [A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk] = schurOneMAPlattice2Abcd(k,epsilon,p);
    [H,~,dHdk,~,diagd2Hdk2] = ...
      schurOneMAPlattice2H(wR,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
    [P,gradP,diagHessP] = H2P(H,dHdk,diagd2Hdk2); 
  elseif nargout==4
    [A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk,d2Adydx,~,d2Capdydx,~] = ...
      schurOneMAPlattice2Abcd(k,epsilon,p);
    [H,~,dHdk,~,diagd2Hdk2,~,d2Hdydx] = ...
      schurOneMAPlattice2H(wR,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk, ...
                           d2Adydx,d2Capdydx);
    [P,gradP,diagHessP,hessP] = H2P(H,dHdk,diagd2Hdk2,d2Hdydx);
  endif    

endfunction
