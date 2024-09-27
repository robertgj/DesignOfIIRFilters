function [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw] = ...
  schurOneMAPlatticePipelineddAsqdw(w,k,epsilon,kk)
% [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw] = ...
%  schurOneMAPlatticePipelineddAsqdw(w,k,epsilon,kk)
% Calculate the gradients of the squared-magnitude responses of a Schur
% one-multiplier all-pass pipelined lattice filter. If the order of the
% denominator polynomial is Nk, then there are Nk one-multiplier lattice
% section coefficients, k. The epsilon inputs scale the internal nodes.
%
% Inputs:
%   w - column vector of angular frequencies
%   k - one-multiplier allpass section denominator multiplier coefficients
%   epsilon - one-multiplier allpass section sign coefficients (+1 or -1)
%   kk - nominally k(1:(Nk-1)).*k(2:Nk)
%
% Outputs:
%   dAsqdw - the group delay response at w
%   graddAsqdw - the gradients of dAsqdw with respect to k, etc
%   diagHessdAsqdw - diagonal of the Hessian of dAsqdw with respect to k, etc
%   hessdAsqdw - Hessian of dAsqdw with respect to k, etc

% Copyright (C) 2024 Robert G. Jenssen
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
  if (nargin ~= 4) || (nargout > 4)
    print_usage("[dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw]= ...\n\
      schurOneMAPlatticePipelineddAsqdw(w,k,epsilon,kk)");
  endif
  if length(k) ~= length(epsilon)
    error("length(k) ~= length(epsilon)");
  endif
  if length(k) ~= length(kk)+1
    error("length(k) ~= length(kk)+1");
  endif
  if length(w) == 0
    dAsqdw=[]; graddAsqdw=[]; diagHessdAsqdw=[]; hessdAsqdw=[];
    return;
  endif
  
  [Aap,Bap,Cap,Dap,dAapdx,dBapdx,dCapdx,dDapdx] = ...
    schurOneMAPlatticePipelined2Abcd(k,epsilon,kk);
  
  % Calculate the complex transfer function at w 
  if nargout == 1
    [H,dHdw] = Abcd2H(w,Aap,Bap,Cap,Dap);
    dAsqdw = H2dAsqdw(H,dHdw);
    
  elseif nargout == 2
    [H,dHdw,dHdx,d2Hdwdx] = ...
      Abcd2H(w,Aap,Bap,Cap,Dap,dAapdx,dBapdx,dCapdx,dDapdx);
    [dAsqdw,graddAsqdw] = H2dAsqdw(H,dHdw,dHdx,d2Hdwdx);

  elseif nargout == 3
    [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2] = ...
      Abcd2H(w,Aap,Bap,Cap,Dap,dAapdx,dBapdx,dCapdx,dDapdx);
    [dAsqdw,graddAsqdw,diagHessdAsqdw] = ...
      H2dAsqdw(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2);

  elseif nargout == 4
    [H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx] = ...
      Abcd2H(w,Aap,Bap,Cap,Dap,dAapdx,dBapdx,dCapdx,dDapdx);
    [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw] = ...
      H2dAsqdw(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx);

  endif    

endfunction
