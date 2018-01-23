function [Asq,gradAsq,diagHessAsq] = ...
         schurOneMPAlatticeAsq(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference)
% [Asq,gradAsq,diagHessAsq] = ...
%   schurOneMPAlatticeAsq(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p)
% [Asq,gradAsq,diagHessAsq] = ...
%   schurOneMPAlatticeAsq(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference)
% Calculate the squared-magnitude response and gradients of the parallel
% combination of two Schur one-multiplier all-pass lattice filters. The
% epsilon and p inputs scale the internal nodes.
%
% Inputs:
%   w - column vector of angular frequencies
%   A1k,A1epsilon,A1p - filter 1 one-multiplier allpass section denominator
%                       multiplier and scaling coefficients
%   A2k,A2epsilon,A2p - filter 2 one-multiplier allpass section denominator
%                       multiplier and scaling coefficients
%  difference - return the response for the difference of the all-pass filters
%
% Outputs:
%   Asq - the squared magnitude response at w
%   gradAsq - the gradients of Asq with respect to k
%   diagHessAsq - diagonal of the Hessian of Asq with respect to k

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
  if ((nargin ~= 7) && (nargin ~= 8)) || (nargout > 3) 
    print_usage("[Asq,gradAsq,diagHessAsq]= ...\n\
      schurOneMPAlattice(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p)\n\
[Asq,gradAsq,diagHessAsq]= ...\n\
      schurOneMPAlattice(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference)");
  endif
  if nargin == 7
    difference=false;
  endif
  if length(A1k) ~= length(A1epsilon)
    error("length(A1k) ~= length(A1epsilon)");
  endif
  if length(A1k) ~= length(A1p)
    error("length(A1k) ~= length(A1p)");
  endif
  if length(A2k) ~= length(A2epsilon)
    error("length(A2k) ~= length(A2epsilon)");
  endif
  if length(A2k) ~= length(A2p)
    error("length(A2k) ~= length(A2p)");
  endif
  if length(w) == 0
    Asq=[]; gradAsq=[]; diagHessAsq=[];
    return;
  endif

  % Calculate the complex transfer function, H, and derivatives at w
  if nargout==1
    [A1A,A1B,A1Cap,A1Dap]=schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
    [A2A,A2B,A2Cap,A2Dap]=schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
    A1H=schurOneMAPlattice2H(w,A1A,A1B,A1Cap,A1Dap);
    A2H=schurOneMAPlattice2H(w,A2A,A2B,A2Cap,A2Dap);
    if difference
      H=(A1H-A2H)/2;
    else
      H=(A1H+A2H)/2;
    endif
    Asq=H2Asq(H); 
  elseif nargout==2
    [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk] = ...
      schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
    [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk] = ...
      schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
    [A1H,dA1Hdw,dA1Hdk]=schurOneMAPlattice2H(w,A1A,A1B,A1Cap,A1Dap, ...
                                             A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
    [A2H,dA1Hdw,dA2Hdk]=schurOneMAPlattice2H(w,A2A,A2B,A2Cap,A2Dap, ...
                                             A2dAdk,A2dBdk,A2dCapdk,A2dDapdk);
    if difference
      H=(A1H-A2H)/2;
      dHdk=[dA1Hdk,-dA2Hdk]/2;
    else
      H=(A1H+A2H)/2;
      dHdk=[dA1Hdk,dA2Hdk]/2;
    endif
    [Asq,gradAsq]=H2Asq(H,dHdk);
  else
    [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk] = ...
      schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
    [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk] = ...
      schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
    [A1H,dA1Hdw,dA1Hdk,d2A1Hdwdk,diagd2A1Hdk2] = ...
      schurOneMAPlattice2H(w,A1A,A1B,A1Cap,A1Dap, ...
                           A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
    [A2H,dA2Hdw,dA2Hdk,d2A2Hdwdk,diagd2A2Hdk2] = ...
      schurOneMAPlattice2H(w,A2A,A2B,A2Cap,A2Dap, ...
                           A2dAdk,A2dBdk,A2dCapdk,A2dDapdk);
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
  endif    

endfunction
