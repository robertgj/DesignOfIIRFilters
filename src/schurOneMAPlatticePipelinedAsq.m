function [Asq,gradAsq,diagHessAsq,hessAsq] = ...
           schurOneMAPlatticePipelinedAsq(w,k,epsilon,kk)
% [Asq,gradAsq,diagHessAsq,hessAsq] = ...
%  schurOneMAPlatticePipelinedAsq(w,k,epsilon,kk)
% Calculate the squared-magnitude response and gradients for a pipelined Schur
% one-multiplier lattice filter. If the order of the denominator polynomial is
% Nk, then there are Nk one-multiplier lattice section coefficients, k.
%
% This function helps design pipelined one-multiplier Schur all-pass lattice
% filters with fixed point coefficients k, and kk. Nominally,
% kk=k(1:(Nk-1)).*k(2:Nk) but variations in kk make the amplitude response
% differ from allpass.
%
% Inputs:
%   w - column vector of angular frequencies
%   k - one-multiplier allpass section denominator multiplier coefficients
%   epsilon - one-multiplier scaling coefficients
%   kk - coefficients nominally corresponding to k(1:(Nk-1)).*k(2:Nk)
%
% Outputs:
%   Asq - the squared magnitude response at w
%   gradAsq - the gradients of Asq with respect to x=[k(:);kk(:)]
%   diagHessAsq - diagonal of the Hessian of Asq with respect to k and kk
%   hessAsq - Hessian of Asq with respect to k and kk

% Copyright (C) 2023-2025 Robert G. Jenssen
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
    print_usage(["[Asq,gradAsq,diagHessAsq,hessAsq] = ...\n", ...
 "      schurOneMAPlatticePipelinedAsq(w,k,epsilon,kk)"]);
  endif
  if(length(k)) ~= length(epsilon)
    error("length(k)(%d) ~= length(epsilon)(%d)",length(k),length(epsilon));
  endif
  if(length(k)-1) ~= length(kk)
    error("(length(k)(%d)-1) ~= length(kk)(%d)",length(k),length(kk));
  endif
  if length(w) == 0
    Asq=[];gradAsq=[];diagHessAsq=[];hessAsq=[];
    return;
  endif

  [Aap,Bap,Cap,Dap,dAapdx,dBapdx,dCapdx,dDapdx]= ...
    schurOneMAPlatticePipelined2Abcd(k,epsilon,kk);
  
  if nargout==1 
    H=Abcd2H(w,Aap,Bap,Cap,Dap);
    Asq=H2Asq(H);  
  elseif nargout==2 
    [H,~,dHdx]=Abcd2H(w,Aap,Bap,Cap,Dap,dAapdx,dBapdx,dCapdx,dDapdx);
    [Asq,gradAsq]=H2Asq(H,dHdx);  
  elseif nargout==3
    [H,~,dHdx,~,diagd2Hdx2]= ...
      Abcd2H(w,Aap,Bap,Cap,Dap,dAapdx,dBapdx,dCapdx,dDapdx);
    [Asq,gradAsq,diagHessAsq]=H2Asq(H,dHdx,diagd2Hdx2);
  else
    [H,~,dHdx,~,diagd2Hdydx,~,d2Hdydx] = ...
      Abcd2H(w,Aap,Bap,Cap,Dap,dAapdx,dBapdx,dCapdx,dDapdx);
    [Asq,gradAsq,diagHessAsq,hessAsq]=H2Asq(H,dHdx,diagd2Hdydx,d2Hdydx);
  endif
   
endfunction
