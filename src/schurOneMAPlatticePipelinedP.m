function [P,gradP,diagHessP,hessP]=schurOneMAPlatticePipelinedP(w,k,epsilon,kk)
% [P,gradP,diagHessP,hessP]=schurOneMAPlatticePipelinedP(w,k,epsilon,kk)
% Calculate the phase responses and gradients of a Schur one-multiplier
% all-pass pipelined lattice filter. If the order of the denominator
% polynomial is Nk, then there are Nk one-multiplier lattice section
% coefficients, k. The epsilon inputs scale the internal nodes.
%
% Inputs:
%   w - column vector of angular frequencies
%   k - one-multiplier allpass section denominator multiplier coefficients
%   epsilon - one-multiplier allpass section sign coefficients (+1 or -1)
%   kk - nominally kk=k(1:(Nk-1)).*k(2:Nk)
%
% Outputs:
%   P - the phase response at w
%   gradP - the gradients of P with respect to k and kk
%   diagHessP - diagonal of the Hessian of P with respect to k and kk
%   hessP - Hessian of P with respect to k and kk

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
  if nargin~=4 || (nargout > 4)
    print_usage("[P,gradP,diagHessP,hessP]=schurOneMAPlatticeP(w,k,epsilon,kk)");
  endif
  if length(k) ~= length(epsilon)
    error("length(k) ~= length(epsilon)");
  endif
  if length(k) ~= length(kk)+1
    error("length(k) ~= length(kk)+1");
  endif
  if length(w) == 0
    P=[]; gradP=[]; diagHessP=[]; hessP=[];
    return;
  endif

  [Aap,Bap,Cap,Dap,dAapdx,dBapdx,dCapdx,dDapdx] = ...
    schurOneMAPlatticePipelined2Abcd(k,epsilon,kk);
  
  % Calculate the complex transfer function at w
  if nargout==1
    H = Abcd2H(w,Aap,Bap,Cap,Dap);
    P = H2P(H);
    
  elseif nargout==2
    [H,~,dHdx] = Abcd2H(w,Aap,Bap,Cap,Dap,dAapdx,dBapdx,dCapdx,dDapdx);
    [P,gradP] = H2P(H,dHdx);
    
  elseif nargout==3
    [H,~,dHdx,~,diagd2Hdx2] = ...
           Abcd2H(w,Aap,Bap,Cap,Dap,dAapdx,dBapdx,dCapdx,dDapdx);
    [P,gradP,diagHessP] = H2P(H,dHdx,diagd2Hdx2);
    
  elseif nargout==4
    [H,~,dHdx,~,diagd2Hdx2,~,d2Hdydx] = ...
           Abcd2H(w,Aap,Bap,Cap,Dap,dAapdx,dBapdx,dCapdx,dDapdx);
    [P,gradP,diagHessP,hessP] = H2P(H,dHdx,diagd2Hdx2,d2Hdydx);
    
  endif    

endfunction
