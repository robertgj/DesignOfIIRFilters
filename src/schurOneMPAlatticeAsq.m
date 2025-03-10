function [Asq,gradAsq,diagHessAsq,hessAsq] = ...
         schurOneMPAlatticeAsq(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference)
% [Asq,gradAsq,diagHessAsq,hessAsq] = ...
%   schurOneMPAlatticeAsq(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p)
% [Asq,gradAsq,diagHessAsq,hessAsq] = ...
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
%   hessAsq - Hessian of Asq with respect to k

% Copyright (C) 2017-2025 Robert G. Jenssen
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
    print_usage(["[Asq,gradAsq,diagHessAsq,hessAsq]= ...\n", ...
 "      schurOneMPAlattice(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p)\n", ...
 "[Asq,gradAsq,diagHessAsq,hessAsq]= ...\n", ...
 "      schurOneMPAlattice(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference)"]);
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
    Asq=[]; gradAsq=[]; diagHessAsq=[]; hessAsq=[];
    return;
  endif

  if difference
    mm=-1;
  else
    mm=1;
  endif
  
  if nargout==1
    [A1A,A1B,A1Cap,A1Dap]=schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
    A1H=schurOneMAPlattice2H(w,A1A,A1B,A1Cap,A1Dap);

    [A2A,A2B,A2Cap,A2Dap]=schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
    A2H=schurOneMAPlattice2H(w,A2A,A2B,A2Cap,A2Dap);

    H=(A1H+(mm*A2H))/2;
    Asq=H2Asq(H);
    
  elseif nargout==2
    [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk] = ...
      schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
    [A1H,~,dA1Hdk]=schurOneMAPlattice2H(w,A1A,A1B,A1Cap,A1Dap, ...
                                        A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);

    [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk] = ...
      schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
    [A2H,~,dA2Hdk]=schurOneMAPlattice2H(w,A2A,A2B,A2Cap,A2Dap, ...
                                        A2dAdk,A2dBdk,A2dCapdk,A2dDapdk);

    H=(A1H+(mm*A2H))/2;
    dHdk=[dA1Hdk,mm*dA2Hdk]/2;
    [Asq,gradAsq]=H2Asq(H,dHdk);
    
  elseif nargout==3
    [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk] = ...
      schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p); 
    [A1H,~,dA1Hdk,~,diagd2A1Hdk2] = ...
      schurOneMAPlattice2H(w,A1A,A1B,A1Cap,A1Dap, ...
                           A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
    
    [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk] = ...
      schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
    [A2H,~,dA2Hdk,~,diagd2A2Hdk2] = ...
      schurOneMAPlattice2H(w,A2A,A2B,A2Cap,A2Dap, ...
                           A2dAdk,A2dBdk,A2dCapdk,A2dDapdk);
    
    H=(A1H+(mm*A2H))/2;
    dHdk=[dA1Hdk,mm*dA2Hdk]/2;
    diagd2Hdk2=[diagd2A1Hdk2,mm*diagd2A2Hdk2]/2;
    [Asq,gradAsq,diagHessAsq]=H2Asq(H,dHdk,diagd2Hdk2);
    
  else
    [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk, ...
     A1d2Adydx,A1d2Bdydx,A1d2Capdydx,A1d2Dapdydx] = ...
      schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
    [A1H,~,dA1Hdk,~,diagd2A1Hdk2,~,d2A1Hdydx] = ...
      schurOneMAPlattice2H(w,A1A,A1B,A1Cap,A1Dap, ...
                           A1dAdk,A1dBdk,A1dCapdk,A1dDapdk, ...
                           A1d2Adydx,A1d2Capdydx);

    [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk, ...
     A2d2Adydx,A2d2Bdydx,A2d2Capdydx,A2d2Dapdydx] = ...
      schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
    [A2H,~,dA2Hdk,~,diagd2A2Hdk2,~,d2A2Hdydx] = ...
      schurOneMAPlattice2H(w,A2A,A2B,A2Cap,A2Dap, ...
                           A2dAdk,A2dBdk,A2dCapdk,A2dDapdk, ...
                           A2d2Adydx,A2d2Capdydx);

    H=(A1H+(mm*A2H))/2;
    dHdk=[dA1Hdk,mm*dA2Hdk]/2;
    diagd2Hdk2=[diagd2A1Hdk2,mm*diagd2A2Hdk2]/2;
    d2Hdydx=zeros(length(H),length(A1k)+length(A2k),length(A1k)+length(A2k));
    A1R=1:length(A1k);
    A2R=(length(A1k)+1):(length(A1k)+length(A2k));
    for l=1:length(H)
      d2Hdydx(l,:,:) = ...
          [squeeze(d2A1Hdydx(l,:,:)),zeros(length(A1k),length(A2k)); ...
           zeros(length(A2k),length(A1k)),squeeze(mm*d2A2Hdydx(l,:,:))]/2;
    endfor
    [Asq,gradAsq,diagHessAsq,hessAsq]=H2Asq(H,dHdk,diagd2Hdk2,d2Hdydx);
    
  endif
  
endfunction
