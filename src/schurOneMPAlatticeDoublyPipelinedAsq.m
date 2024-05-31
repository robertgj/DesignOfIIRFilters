function [Asq,gradAsq,diagHessAsq,hessAsq] = ...
  schurOneMPAlatticeDoublyPipelinedAsq(w,A1k,A2k,difference)
% [Asq,gradAsq,diagHessAsq,hessAsq] = ...
%   schurOneMPAlatticeDoublyPipelinedAsq(w,A1k,A2k)
% [Asq,gradAsq,diagHessAsq,hessAsq] = ...
%   schurOneMPAlatticeDoublyPipelinedAsq(w,A1k,A2k,difference)
%
% Calculate the squared-magnitude response and gradients of the parallel
% combination of two Schur one-multiplier all-pass doubly-pipelined lattice
% filters.
%
% Inputs:
%  w - column vector of angular frequencies
%  A1k - filter 1 one-multiplier allpass section denominator coefficients
%  A2k - filter 2 one-multiplier allpass section denominator coefficients
%  difference - return the response for the difference of the all-pass filters
%
% Outputs:
%   Asq - the squared magnitude response at w
%   gradAsq - the gradients of Asq with respect to k
%   diagHessAsq - diagonal of the Hessian of Asq with respect to k
%   hessAsq - Hessian of Asq with respect to k as a [Nw,Nk,Nk]-matrix

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
if ((nargin ~= 3) && (nargin ~= 4)) || (nargout > 4) 
  print_usage("[Asq,gradAsq,diagHessAsq,hessAsq]= ...\n\
    schurOneMPAlatticeDoublyPipelinedAsq(w,A1k,A2k)\n\
[Asq,gradAsq,diagHessAsq,hessAsq]= ...\n\
      schurOneMPAlatticeDoublyPipelinedAsq(w,A1k,A2k,difference)");
endif
if nargin == 3
  difference=false;
endif
if length(w) == 0
  Asq=[]; gradAsq=[]; diagHessAsq=[]; hessAsq=[];
  return;
endif

% Calculate the complex transfer function, H, and derivatives at w
[A1A,A1B,A1Cap,A1Dap,~,A1dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A1k);
[A2A,A2B,A2Cap,A2Dap,~,A2dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A2k);
if nargout==1
  A1H=schurOneMAPlatticeDoublyPipelined2H(w,A1A,A1B,A1Cap,A1Dap,A1dAdk);
  A2H=schurOneMAPlatticeDoublyPipelined2H(w,A2A,A2B,A2Cap,A2Dap,A2dAdk);
  if difference
    H=(A1H-A2H)/2;
  else
    H=(A1H+A2H)/2;
  endif
  Asq=H2Asq(H); 
elseif nargout==2
  [A1H,dA1Hdw,dA1Hdk] = ...
    schurOneMAPlatticeDoublyPipelined2H(w,A1A,A1B,A1Cap,A1Dap,A1dAdk);
  [A2H,dA1Hdw,dA2Hdk] = ...
    schurOneMAPlatticeDoublyPipelined2H(w,A2A,A2B,A2Cap,A2Dap,A2dAdk);
  if difference
    H=(A1H-A2H)/2;
    dHdk=[dA1Hdk,-dA2Hdk]/2;
  else
    H=(A1H+A2H)/2;
    dHdk=[dA1Hdk,dA2Hdk]/2;
  endif
  [Asq,gradAsq]=H2Asq(H,dHdk);
elseif nargout==3
  [A1H,~,dA1Hdk,~,diagd2A1Hdk2] = ...
    schurOneMAPlatticeDoublyPipelined2H(w,A1A,A1B,A1Cap,A1Dap,A1dAdk);
  [A2H,~,dA2Hdk,~,diagd2A2Hdk2] = ...
    schurOneMAPlatticeDoublyPipelined2H(w,A2A,A2B,A2Cap,A2Dap,A2dAdk);
  if difference
    H=(A1H-A2H)/2;
    dHdk=[dA1Hdk,-dA2Hdk]/2;
    diagd2Hdk2=[diagd2A1Hdk2,-diagd2A2Hdk2]/2;
  else
    H=(A1H+A2H)/2;
    dHdk=[dA1Hdk,dA2Hdk]/2;
    diagd2Hdk2=[diagd2A1Hdk2,diagd2A2Hdk2]/2;
  endif
  [Asq,gradAsq,diagHessAsq]=H2Asq(H,dHdk,diagd2Hdk2);
elseif nargout==4
  [A1H,~,dA1Hdk,~,diagd2A1Hdk2,~,d2A1Hdydx] = ...
    schurOneMAPlatticeDoublyPipelined2H(w,A1A,A1B,A1Cap,A1Dap,A1dAdk);
  [A2H,~,dA2Hdk,~,diagd2A2Hdk2,~,d2A2Hdydx] = ...
    schurOneMAPlatticeDoublyPipelined2H(w,A2A,A2B,A2Cap,A2Dap,A2dAdk);
  if difference
    H=(A1H-A2H)/2;
    dHdk=[dA1Hdk,-dA2Hdk]/2;
    diagd2Hdk2=[diagd2A1Hdk2,-diagd2A2Hdk2]/2;
    d2Hdydx=zeros(length(w),length(A1k)+length(A2k),length(A1k)+length(A2k));
    for l=1:length(w),
      d2Hdydx(l,:,:)= ...
        [squeeze(d2A1Hdydx(l,:,:)),zeros(length(A1k),length(A2k)); ...
         zeros(length(A2k),length(A1k)),-squeeze(d2A2Hdydx(l,:,:))]/2;
    endfor
  else
    H=(A1H+A2H)/2;
    dHdk=[dA1Hdk,dA2Hdk]/2;
    diagd2Hdk2=[diagd2A1Hdk2,diagd2A2Hdk2]/2;
    d2Hdydx=zeros(length(w),length(A1k)+length(A2k),length(A1k)+length(A2k));
    for l=1:length(w),
      d2Hdydx(l,:,:)= ...
        [squeeze(d2A1Hdydx(l,:,:)),zeros(length(A1k),length(A2k)); ...
         zeros(length(A2k),length(A1k)),squeeze(d2A2Hdydx(l,:,:))]/2;
    endfor
  endif
  [Asq,gradAsq,diagHessAsq,hessAsq]=H2Asq(H,dHdk,diagd2Hdk2,d2Hdydx);
endif    

endfunction
