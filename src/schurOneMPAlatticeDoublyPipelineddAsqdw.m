function [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw] = ...
  schurOneMPAlatticeDoublyPipelineddAsqdw(w,A1k,A2k,difference)
% [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw] = ...
%   schurOneMPAlatticeDoublyPipelineddAsqdw(w,A1k,A2k)
% [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw] = ...
%   schurOneMPAlatticeDoublyPipelineddAsqdw(w,A1k,A2k,difference)
%
% Calculate the gradient of the squared-magnitude response w.r.t w and
% gradients of the parallel combination of two Schur one-multiplier all-pass
% doubly-pipelined lattice filters.
%
% Inputs:
%  w - column vector of angular frequencies
%  A1k - filter 1 one-multiplier allpass section denominator coefficients
%  A2k - filter 2 one-multiplier allpass section denominator coefficients
%  difference - return the response for the difference of the all-pass filters
%
% Outputs:
%   dAsqdw - the gradient of the squared magnitude response w.r.t. w
%   graddAsqdw - the gradients of dAsqdw with respect to k
%   diagHessdAsqdw - diagonal of the Hessian of dAsqdw with respect to k
%   hessdAsqdw - Hessian of dAsqdw with respect to k as a [Nw,Nk,Nk]-matrix

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
if ((nargin ~= 3) && (nargin ~= 4)) || (nargout > 4) 
  print_usage(["[dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw]= ...\n", ...
 "    schurOneMPAlatticeDoublyPipelineddAsqdw(w,A1k,A2k)\n", ...
 "[dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw]= ...\n", ...
 "      schurOneMPAlatticeDoublyPipelineddAsqdw(w,A1k,A2k,difference)"]);
endif
if nargin == 3
  difference=false;
endif
if length(w) == 0
  printf ("length(w)=0\n");
  dAsqdw=[]; graddAsqdw=[]; diagHessdAsqdw=[]; hessdAsqdw=[];
  return;
endif
if difference
  mm=-1;
else
  mm=1;
endif

% Calculate the complex transfer function, H, and derivatives at w
[A1A,A1B,A1Cap,A1Dap,~,A1dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A1k);
[A2A,A2B,A2Cap,A2Dap,~,A2dAdk]=schurOneMAPlatticeDoublyPipelined2Abcd(A2k);

if nargout==1
  [A1H,dA1Hdw] = ...
    schurOneMAPlatticeDoublyPipelined2H(w,A1A,A1B,A1Cap,A1Dap,A1dAdk);
  [A2H,dA2Hdw] = ...
    schurOneMAPlatticeDoublyPipelined2H(w,A2A,A2B,A2Cap,A2Dap,A2dAdk);
  H=(A1H+(mm*A2H))/2;
  dHdw=(dA1Hdw+(mm*dA2Hdw))/2;
  dAsqdw=H2dAsqdw(H,dHdw);
  
elseif nargout==2
  [A1H,dA1Hdw,dA1Hdk,d2A1Hdwdk] = ...
    schurOneMAPlatticeDoublyPipelined2H(w,A1A,A1B,A1Cap,A1Dap,A1dAdk);
  [A2H,dA2Hdw,dA2Hdk,d2A2Hdwdk] = ...
    schurOneMAPlatticeDoublyPipelined2H(w,A2A,A2B,A2Cap,A2Dap,A2dAdk);
  
  H=(A1H+(mm*A2H))/2;
  dHdw=(dA1Hdw+(mm*dA2Hdw))/2;
  dHdk=[dA1Hdk,mm*dA2Hdk]/2;
  d2Hdwdk=[d2A1Hdwdk,mm*d2A2Hdwdk]/2;
  [dAsqdw,graddAsqdw]=H2dAsqdw(H,dHdw,dHdk,d2Hdwdk);

elseif nargout==3
  [A1H,dA1Hdw,dA1Hdk,d2A1Hdwdk,diagd2A1Hdk2,diagd3A1Hdwdk2] = ...
    schurOneMAPlatticeDoublyPipelined2H(w,A1A,A1B,A1Cap,A1Dap,A1dAdk);
  [A2H,dA2Hdw,dA2Hdk,d2A2Hdwdk,diagd2A2Hdk2,diagd3A2Hdwdk2] = ...
    schurOneMAPlatticeDoublyPipelined2H(w,A2A,A2B,A2Cap,A2Dap,A2dAdk);

  H=(A1H+(mm*A2H))/2;
  dHdw=(dA1Hdw+(mm*dA2Hdw))/2;
  dHdk=[dA1Hdk,mm*dA2Hdk]/2;
  d2Hdwdk=[d2A1Hdwdk,mm*d2A2Hdwdk]/2;
  diagd2Hdk2=[diagd2A1Hdk2,mm*diagd2A2Hdk2]/2;
  diagd3Hdwdk2=[diagd3A1Hdwdk2,mm*diagd3A2Hdwdk2]/2;
  [dAsqdw,graddAsqdw,diagHessdAsqdw] = ...
    H2dAsqdw(H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2);

elseif nargout==4
  [A1H,dA1Hdw,dA1Hdk,d2A1Hdwdk,diagd2A1Hdk2,diagd3A1Hdwdk2, ...
   d2A1Hdydx,d3A1Hdwdydx] = ...
    schurOneMAPlatticeDoublyPipelined2H(w,A1A,A1B,A1Cap,A1Dap,A1dAdk);
  [A2H,dA2Hdw,dA2Hdk,d2A2Hdwdk,diagd2A2Hdk2,diagd3A2Hdwdk2, ...
   d2A2Hdydx,d3A2Hdwdydx] = ...
    schurOneMAPlatticeDoublyPipelined2H(w,A2A,A2B,A2Cap,A2Dap,A2dAdk);

  H=(A1H+(mm*A2H))/2;
  dHdw=(dA1Hdw+(mm*dA2Hdw))/2;
  dHdk=[dA1Hdk,mm*dA2Hdk]/2;
  diagd2Hdk2=[diagd2A1Hdk2,mm*diagd2A2Hdk2]/2;
  d2Hdwdk=[d2A1Hdwdk,mm*d2A2Hdwdk]/2;
  diagd2Hdk2=[diagd2A1Hdk2,mm*diagd2A2Hdk2]/2;
  diagd3Hdwdk2=[diagd3A1Hdwdk2,mm*diagd3A2Hdwdk2]/2;
  d2Hdydx=zeros(length(H),length(A1k)+length(A2k),length(A1k)+length(A2k));
  A1R=1:length(A1k);
  A2R=(length(A1k)+1):(length(A1k)+length(A2k));
  for l=1:length(H)
    d2Hdydx(l,:,:) = ...
        [squeeze(d2A1Hdydx(l,:,:)),zeros(length(A1k),length(A2k)); ...
         zeros(length(A2k),length(A1k)),squeeze(mm*d2A2Hdydx(l,:,:))]/2;
  endfor
  d3Hdwdydx=zeros(length(H),length(A1k)+length(A2k),length(A1k)+length(A2k));
  for l=1:length(H)
    d3Hdwdydx(l,:,:) = ...
        [squeeze(d3A1Hdwdydx(l,:,:)),zeros(length(A1k),length(A2k)); ...
         zeros(length(A2k),length(A1k)),squeeze(mm*d3A2Hdwdydx(l,:,:))]/2;
  endfor
  [dAsqdw,graddAsqdw,diagHessdAsqdw,hessdAsqdw] = ...
    H2dAsqdw(H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2,d2Hdydx,d3Hdwdydx);
  
endif    

endfunction
