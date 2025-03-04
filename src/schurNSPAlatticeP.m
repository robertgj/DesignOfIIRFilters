function [P,gradP,diagHessP]=schurNSPAlatticeP ...
 (w,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference)
% [P,gradP,diagHessP] = schurNSPAlatticeP ...
%  (w,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22)
% [P,gradP,diagHessP] = schurNSPAlatticeP ...
%  (w,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference)
%
% Calculate the phase response and gradients of the parallel
% combination of two Schur normalised-scaled all-pass lattice filters.
%
% Inputs:
%   w - column vector of angular frequencies
%   A1s20,A1s00,A1s02,A1s22 - filter 1 normalised-scaled allpass section coef.s
%   A2s20,A2s00,A2s02,A2s22 - filter 2 normalised-scaled allpass section coef.s
%   difference - return the response for the difference of the all-pass filters
% Outputs:
%   P - the phase response at w
%   gradP,diagHessP - the gradients of P with respect to A1sxx,A2sxx

% Copyright (C) 2022-2025 Robert G. Jenssen
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
  if ((nargin ~= 9) && (nargin ~= 10)) || (nargout > 3) 
    print_usage("[P,gradP] = schurNSPAlatticeP ...\n\
      (w,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22) \n\
[P,gradP,diagHessP] = schurNSPAlatticeP ...\n\
      (w,A1s20,A1s00,A1s02,A1s22,A2s20,A2s00,A2s02,A2s22,difference)");
  endif
  if nargin == 9
    difference = false;
  endif
  if length(A1s20) ~= length(A1s00)
    error("length(A1s20) ~= length(A1s00)");
  endif
  if length(A1s20) ~= length(A1s02)
    error("length(A1s20) ~= length(A1s02)");
  endif
  if length(A1s20) ~= length(A1s22)
    error("length(A1s20) ~= length(A1s22)");
  endif
  if length(A2s20) ~= length(A2s00)
    error("length(A2s20) ~= length(A2s00)");
  endif
  if length(A2s20) ~= length(A2s02)
    error("length(A2s20) ~= length(A2s02)");
  endif
  if length(A2s20) ~= length(A2s22)
    error("length(A2s20) ~= length(A2s22)");
  endif
  if length(w) == 0
    P=[];
    gradP=[];
    return;
  endif

  % Note that schurNSAPlattice2Abcd returns gradients in by-section order:
  % A1s20-1,A1s00-1,A1s02-1,A1s22-1,A1s20-2,...,A1s22-NA1,A2s20-1,...,A2s22-NA2
  % so they must be reordered to:
  % A1s20-1,A1s20-2,A1s20-3,...,A1s20-NA1,A1s00-1,...,A2s22-NA2
  if nargout>1
    A1Ns=length(A1s20);
    A2Ns=length(A2s20);
    reorderA1=reshape(reshape(1:(4*A1Ns),4,A1Ns)',1,(4*A1Ns));
    reorderA2=reshape(reshape((4*A1Ns)+(1:(4*A2Ns)),4,A2Ns)',1,(4*A2Ns));
    reorderA12=[reorderA1,reorderA2];
  endif
  
  % Calculate the complex transfer function, H, and derivatives at w
  if nargout==1
    [A1A,A1B,A1Cap,A1Dap]=schurNSAPlattice2Abcd(A1s20,A1s00,A1s02,A1s22);
    A1H=Abcd2H(w,A1A,A1B,A1Cap,A1Dap);
    [A2A,A2B,A2Cap,A2Dap]=schurNSAPlattice2Abcd(A2s20,A2s00,A2s02,A2s22);
    A2H=Abcd2H(w,A2A,A2B,A2Cap,A2Dap);
    if difference
      H=(A1H-A2H)/2;
    else
      H=(A1H+A2H)/2;
    endif
    P=H2P(H);
  elseif nargout==2
    [A1A,A1B,A1Cap,A1Dap,A1dAds,A1dBds,A1dCapds,A1dDapds] = ...
      schurNSAPlattice2Abcd(A1s20,A1s00,A1s02,A1s22);
    [A1H,~,dA1Hds] = ...
      Abcd2H(w,A1A,A1B,A1Cap,A1Dap,A1dAds,A1dBds,A1dCapds,A1dDapds);
    [A2A,A2B,A2Cap,A2Dap,A2dAds,A2dBds,A2dCapds,A2dDapds] = ...
      schurNSAPlattice2Abcd(A2s20,A2s00,A2s02,A2s22);
    [A2H,~,dA2Hds] = ...
      Abcd2H(w,A2A,A2B,A2Cap,A2Dap,A2dAds,A2dBds,A2dCapds,A2dDapds);
    if difference
      H=(A1H-A2H)/2;
      dHds=[dA1Hds,-dA2Hds]/2;
    else
      H=(A1H+A2H)/2;
      dHds=[dA1Hds,dA2Hds]/2;
    endif
    [P,gradP]=H2P(H,dHds);
    gradP=gradP(:,reorderA12);
  else
    [A1A,A1B,A1Cap,A1Dap,A1dAds,A1dBds,A1dCapds,A1dDapds] = ...
      schurNSAPlattice2Abcd(A1s20,A1s00,A1s02,A1s22);
    [A1H,~,dA1Hds,~,diagd2A1Hds2] = ...
      Abcd2H(w,A1A,A1B,A1Cap,A1Dap,A1dAds,A1dBds,A1dCapds,A1dDapds);
    [A2A,A2B,A2Cap,A2Dap,A2dAds,A2dBds,A2dCapds,A2dDapds] = ...
      schurNSAPlattice2Abcd(A2s20,A2s00,A2s02,A2s22);
    [A2H,~,dA2Hds,~,diagd2A2Hds2] = ...
      Abcd2H(w,A2A,A2B,A2Cap,A2Dap,A2dAds,A2dBds,A2dCapds,A2dDapds);
    if difference
      H=(A1H-A2H)/2;
      dHds=[dA1Hds,-dA2Hds]/2;
      diagd2Hds2=[diagd2A1Hds2,-diagd2A2Hds2]/2;
    else
      H=(A1H+A2H)/2;
      dHds=[dA1Hds,dA2Hds]/2;
      diagd2Hds2=[diagd2A1Hds2, diagd2A2Hds2]/2;
    endif
    [P,gradP,diagHessP]=H2P(H,dHds,diagd2Hds2);
    gradP=gradP(:,reorderA12);
    diagHessP=diagHessP(:,reorderA12);
  endif    

endfunction
