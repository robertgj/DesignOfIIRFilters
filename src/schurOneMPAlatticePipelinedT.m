function [T,gradT,diagHessT,hessT]=schurOneMPAlatticePipelinedT ...
    (w,A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk,difference)
% [T,gradT,diagHessT,hessT] = schurOneMPAlatticePipelinedT ...
%                              (w,A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk)
% [T,gradT,diagHessT,hessT] = schurOneMPAlatticePipelinedT ...
%                              (w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference)
% Calculate the group-delay response and gradients of the parallel
% combination of two Schur one-multiplier all-pass pipelined lattice filters.
% The epsilon inputs scale the internal nodes. Nominally
% kk=k(1:(Nk-1)).*k(2:Nk). If not, then the actual individual filter responses
% may not be all-pass.
%
% Inputs:
%   w - column vector of angular frequencies
%   A1k,A1epsilon,A1kk - filter 1 one-multiplier allpass section denominator
%                        multiplier and scaling coefficients
%   A2k,A2epsilon,A2kk - filter 2 one-multiplier allpass section denominator
%                        multiplier and scaling coefficients
%  difference - return the response for the difference of the all-pass filters
%
% Outputs:
%   T - the group delay response at w
%   gradT - the gradients of T with respect to k and kk
%   diagHessT - diagonal of the Hessian of T with respect to k and kk
%   hessT - Hessian of T with respect to k and kk

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
  if ((nargin ~= 7) && (nargin ~= 8)) || (nargout > 4) 
    print_usage("[T,gradT,diagHessT,hessT]= ...\n\
  schurOneMPAlatticePipelinedT(w,A1k,A1epsilon,A1kk,A2k,A2epsilon,A2kk) \n\
[T,gradT,diagHessT,hessT] = ...\n\
  schurOneMPAlatticePipelinedT(w,A1k,A1epsilon,A1p, ...\n\
                               A2kk,A2epsilon,A2kk,difference)");
  endif
  if nargin == 7
    difference = false;
  endif
  if length(A1k) ~= length(A1epsilon)
    error("length(A1k) ~= length(A1epsilon)");
  endif
  if length(A1k) ~= length(A1kk)+1
    error("length(A1k) ~= length(A1kk)+1");
  endif
  if length(A2k) ~= length(A2epsilon)
    error("length(A2k) ~= length(A2epsilon)");
  endif
  if length(A2k) ~= length(A2kk)+1
    error("length(A2k) ~= length(A2kk)+1");
  endif
  if length(w) == 0
    T=[]; gradT=[]; diagHessT=[]; hessT=[];
    return;
  endif

  if difference
    mm=-1;
  else
    mm=1;
  endif

  [A1Aap,A1Bap,A1Cap,A1Dap,A1dAapdx,A1dBapdx,A1dCapdx,A1dDapdx] = ...
    schurOneMAPlatticePipelined2Abcd(A1k,A1epsilon,A1kk);

  [A2Aap,A2Bap,A2Cap,A2Dap,A2dAapdx,A2dBapdx,A2dCapdx,A2dDapdx] = ...
    schurOneMAPlatticePipelined2Abcd(A2k,A2epsilon,A2kk);

  if nargout == 1
    [A1H,dA1Hdw]=Abcd2H(w,A1Aap,A1Bap,A1Cap,A1Dap);
    [A2H,dA2Hdw]=Abcd2H(w,A2Aap,A2Bap,A2Cap,A2Dap);
    H=(A1H+(mm*A2H))/2;
    dHdw=(dA1Hdw+(mm*dA2Hdw))/2;
    T=H2T(H,dHdw);

  elseif nargout == 2
    [A1H,dA1Hdw,dA1Hdx,d2A1Hdwdx] = ...
      Abcd2H(w,A1Aap,A1Bap,A1Cap,A1Dap,A1dAapdx,A1dBapdx,A1dCapdx,A1dDapdx);
    [A2H,dA2Hdw,dA2Hdx,d2A2Hdwdx] = ...
      Abcd2H(w,A2Aap,A2Bap,A2Cap,A2Dap,A2dAapdx,A2dBapdx,A2dCapdx,A2dDapdx);
    H=(A1H+(mm*A2H))/2;
    dHdw=(dA1Hdw+(mm*dA2Hdw))/2;
    dHdx=[dA1Hdx,mm*dA2Hdx]/2;
    d2Hdwdx=[d2A1Hdwdx,mm*d2A2Hdwdx]/2;
    [T,gradT]=H2T(H,dHdw,dHdx,d2Hdwdx);

  elseif nargout == 3
    [A1H,dA1Hdw,dA1Hdx,d2A1Hdwdx,diagd2A1Hdx2,diagd3A1Hdwdx2] = ...
      Abcd2H(w,A1Aap,A1Bap,A1Cap,A1Dap,A1dAapdx,A1dBapdx,A1dCapdx,A1dDapdx);
    [A2H,dA2Hdw,dA2Hdx,d2A2Hdwdx,diagd2A2Hdx2,diagd3A2Hdwdx2] = ...
      Abcd2H(w,A2Aap,A2Bap,A2Cap,A2Dap,A2dAapdx,A2dBapdx,A2dCapdx,A2dDapdx);
    H=(A1H+(mm*A2H))/2;
    dHdw=(dA1Hdw+(mm*dA2Hdw))/2;
    dHdx=[dA1Hdx,mm*dA2Hdx]/2;
    d2Hdwdx=[d2A1Hdwdx,mm*d2A2Hdwdx]/2;
    diagd2Hdx2=[diagd2A1Hdx2,mm*diagd2A2Hdx2]/2;
    diagd3Hdwdx2=[diagd3A1Hdwdx2,mm*diagd3A2Hdwdx2]/2;
    [T,gradT,diagHessT]=H2T(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2);

  elseif nargout == 4
    [A1H,dA1Hdw,dA1Hdx,d2A1Hdwdx,diagd2A1Hdx2,diagd3A1Hdwdx2, ...
     d2A1Hdydx,d3A1Hdwdydx] = ...
      Abcd2H(w,A1Aap,A1Bap,A1Cap,A1Dap,A1dAapdx,A1dBapdx,A1dCapdx,A1dDapdx);
    [A2H,dA2Hdw,dA2Hdx,d2A2Hdwdx,diagd2A2Hdx2,diagd3A2Hdwdx2, ...
     d2A2Hdydx,d3A2Hdwdydx] = ...
      Abcd2H(w,A2Aap,A2Bap,A2Cap,A2Dap,A2dAapdx,A2dBapdx,A2dCapdx,A2dDapdx);
    
    H=(A1H+(mm*A2H))/2;
    dHdw=(dA1Hdw+(mm*dA2Hdw))/2;
    dHdx=[dA1Hdx,mm*dA2Hdx]/2;
    d2Hdwdx=[d2A1Hdwdx,mm*d2A2Hdwdx]/2;
    diagd2Hdx2=[diagd2A1Hdx2,mm*diagd2A2Hdx2]/2;
    diagd3Hdwdx2=[diagd3A1Hdwdx2,mm*diagd3A2Hdwdx2]/2;
    NA1=length(A1k)+length(A1kk);
    NA2=length(A2k)+length(A2kk);
    d2Hdydx=zeros(length(H),NA1+NA2,NA1+NA2);
    for l=1:length(H)
      d2Hdydx(l,:,:) = [squeeze(d2A1Hdydx(l,:,:)),zeros(NA1,NA2); ...
                        zeros(NA2,NA1),squeeze(mm*d2A2Hdydx(l,:,:))]/2;
      d3Hdwdydx(l,:,:) = [squeeze(d3A1Hdwdydx(l,:,:)),zeros(NA1,NA2); ...
                          zeros(NA2,NA1),squeeze(mm*d3A2Hdwdydx(l,:,:))]/2;
    endfor
    [T,gradT,diagHessT,hessT] = ...
      H2T(H,dHdw,dHdx,d2Hdwdx,diagd2Hdx2,diagd3Hdwdx2,d2Hdydx,d3Hdwdydx);

  endif    

endfunction
