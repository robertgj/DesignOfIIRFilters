function [T,gradT,diagHessT]=schurOneMAPlatticeT(w,k,epsilon,p,R)
% [T,gradT,diagHessT]=schurOneMAPlatticeT(w,k,epsilon,p,R)
% Calculate the group-delay responses and gradients of a Schur one-multiplier
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
%   T - the group delay response at w
%   gradT - the gradients of T with respect to k and c
%   diagHessT - diagonal of the Hessian of T with respect to k and c

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
  if ((nargin ~= 4) && (nargin ~= 5)) || (nargout > 3) 
    print_usage("[T,gradT,diagHessT]=schurOneMAPlatticeT(w,k,epsilon,p[,R])");
  endif
  if length(k) ~= length(epsilon)
    error("length(k) ~= length(epsilon)");
  endif
  if length(k) ~= length(p)
    error("length(k) ~= length(p)");
  endif
  if length(w) == 0
    T=[]; gradT=[]; diagHessT=[];
    return;
  endif
  if nargin == 4
    R=1;
    wR=w;
  elseif ~isscalar(R)
    error("~isscalar(R)");
  else
    wR=w*R;
  endif

  % Calculate the complex transfer function at w 
  if nargout==1
    [A,B,Cap,Dap]=schurOneMAPlattice2Abcd(k,epsilon,p);
    [H,dHdw]=schurOneMAPlattice2H(wR,A,B,Cap,Dap);
    if nargin==5
      dHdw=R*dHdw;
    endif
    T=H2T(H,dHdw);
  elseif nargout==2
    [A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk]=...
      schurOneMAPlattice2Abcd(k,epsilon,p);
    [H,dHdw,dHdk,d2Hdwdk]=...
      schurOneMAPlattice2H(wR,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
    if nargin==5
      dHdw=R*dHdw;
      d2Hdwdk=R*d2Hdwdk;
    endif
    [T,gradT]=H2T(H,dHdw,dHdk,d2Hdwdk);
  elseif nargout==3
    [A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk]=...
      schurOneMAPlattice2Abcd(k,epsilon,p);
    [H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2]=...
      schurOneMAPlattice2H(wR,A,B,Cap,Dap,dAdk,dBdk,dCapdk,dDapdk);
    if nargin==5
      dHdw=R*dHdw;
      d2Hdwdk=R*d2Hdwdk;
      diagd3Hdwdk2=R*diagd3Hdwdk2;
    endif
    [T,gradT,diagHessT]=H2T(H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2);
  endif    

endfunction
