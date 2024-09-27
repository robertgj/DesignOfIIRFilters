function [T,gradT,diagHessT,hessT]=...
         schurOneMPAlatticeT(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference)
% [T,gradT,diagHessT,hessT] = ...
%   schurOneMPAlatticeT(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p)
% [T,gradT,diagHessT,hessT]= ...
%   schurOneMPAlatticeT(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference)
% Calculate the group-delay response and gradients of the parallel
% combination of two Schur one-multiplier all-pass lattice filters.
% The epsilon and p inputs scale the internal nodes.
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
%   T - the group delay response at w
%   gradT - the gradients of T with respect to k
%   diagHessT - diagonal of the Hessian of T with respect to k
%   hessT - Hessian of T with respect to k

% Copyright (C) 2017-2024 Robert G. Jenssen
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
  schurOneMPAlatticeT(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p) \n\
[T,gradT,diagHessT,hessT] = ...\n\
  schurOneMPAlatticeT(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p,difference)");
  endif
  if nargin == 7
    difference = false;
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
    T=[]; gradT=[]; diagHessT=[]; hessT=[];
    return;
  endif

  if difference
    mm=-1;
  else
    mm=1;
  endif
  
  if nargout==1
    [A1A,A1B,A1Cap,A1Dap]=schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
    [A1H,dA1Hdw]=schurOneMAPlattice2H(w,A1A,A1B,A1Cap,A1Dap);
    
    [A2A,A2B,A2Cap,A2Dap]=schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
    [A2H,dA2Hdw]=schurOneMAPlattice2H(w,A2A,A2B,A2Cap,A2Dap);
    
    H=(A1H+(mm*A2H))/2;
    dHdw=(dA1Hdw+(mm*dA2Hdw))/2;
    T=H2T(H,dHdw);

  elseif nargout==2
    [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk]=...
      schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
    [A1H,dA1Hdw,dA1Hdk,d2A1Hdwdk] = ...
      schurOneMAPlattice2H(w,A1A,A1B,A1Cap,A1Dap, ...
                           A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
    
    [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk]=...
      schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
    [A2H,dA2Hdw,dA2Hdk,d2A2Hdwdk] = ...
      schurOneMAPlattice2H(w,A2A,A2B,A2Cap,A2Dap, ...
                           A2dAdk,A2dBdk,A2dCapdk,A2dDapdk);
    
    H=(A1H+(mm*A2H))/2;
    dHdw=(dA1Hdw+(mm*dA2Hdw))/2;
    dHdk=[dA1Hdk,mm*dA2Hdk]/2;
    d2Hdwdk=[d2A1Hdwdk,mm*d2A2Hdwdk]/2;
    [T,gradT]=H2T(H,dHdw,dHdk,d2Hdwdk);

  elseif nargout==3
    [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk]=...
           schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
    [A1H,dA1Hdw,dA1Hdk,d2A1Hdwdk,diagd2A1Hdk2,diagd3A1Hdwdk2] = ...
      schurOneMAPlattice2H(w,A1A,A1B,A1Cap,A1Dap, ...
                           A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
    
    [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk]=...
      schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);    
    [A2H,dA2Hdw,dA2Hdk,d2A2Hdwdk,diagd2A2Hdk2,diagd3A2Hdwdk2] = ...
      schurOneMAPlattice2H(w,A2A,A2B,A2Cap,A2Dap, ...
                           A2dAdk,A2dBdk,A2dCapdk,A2dDapdk);

    H=(A1H+(mm*A2H))/2;
    dHdw=(dA1Hdw+(mm*dA2Hdw))/2;
    dHdk=[dA1Hdk,mm*dA2Hdk]/2;
    d2Hdwdk=[d2A1Hdwdk,mm*d2A2Hdwdk]/2;
    diagd2Hdk2=[diagd2A1Hdk2,mm*diagd2A2Hdk2]/2;
    diagd3Hdwdk2=[diagd3A1Hdwdk2,mm*diagd3A2Hdwdk2]/2;
    [T,gradT,diagHessT]=H2T(H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2);

  elseif nargout==4
    [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk, ...
     A1d2Adydx,A1d2Bdydx,A1d2Capdydx,A1d2Dapdydx]=...
      schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
    [A1H,dA1Hdw,dA1Hdk,d2A1Hdwdk,diagd2A1Hdk2,diagd3A1Hdwdk2, ...
     d2A1Hdydx,d3A1Hdwdydx] = ...
      schurOneMAPlattice2H(w,A1A,A1B,A1Cap,A1Dap, ...
                           A1dAdk,A1dBdk,A1dCapdk,A1dDapdk, ...
                           A1d2Adydx,A1d2Capdydx);
    
    [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk, ...
     A2d2Adydx,A2d2Bdydx,A2d2Capdydx,A2d2Dapdydx]=...
      schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);    
    [A2H,dA2Hdw,dA2Hdk,d2A2Hdwdk,diagd2A2Hdk2,diagd3A2Hdwdk2, ...
     d2A2Hdydx,d3A2Hdwdydx] = ...
      schurOneMAPlattice2H(w,A2A,A2B,A2Cap,A2Dap, ...
                           A2dAdk,A2dBdk,A2dCapdk,A2dDapdk, ...
                           A2d2Adydx,A2d2Capdydx);
    
    H=(A1H+(mm*A2H))/2;
    dHdw=(dA1Hdw+(mm*dA2Hdw))/2;
    dHdk=[dA1Hdk,mm*dA2Hdk]/2;
    d2Hdwdk=[d2A1Hdwdk,mm*d2A2Hdwdk]/2;
    diagd2Hdk2=[diagd2A1Hdk2,mm*diagd2A2Hdk2]/2;
    diagd3Hdwdk2=[diagd3A1Hdwdk2,mm*diagd3A2Hdwdk2]/2;
    A1R=1:length(A1k);
    A2R=(length(A1k)+1):(length(A1k)+length(A2k));
    for l=1:length(H)
      d2Hdydx(l,:,:) = ...
          [squeeze(d2A1Hdydx(l,:,:)),zeros(length(A1k),length(A2k)); ...
           zeros(length(A2k),length(A1k)),squeeze(mm*d2A2Hdydx(l,:,:))]/2;
    endfor
    for l=1:length(H)
      d3Hdwdydx(l,:,:) = ...
          [squeeze(d3A1Hdwdydx(l,:,:)),zeros(length(A1k),length(A2k)); ...
           zeros(length(A2k),length(A1k)),squeeze(mm*d3A2Hdwdydx(l,:,:))]/2;
    endfor
    [T,gradT,diagHessT,hessT]=H2T(H,dHdw,dHdk,d2Hdwdk,diagd2Hdk2,diagd3Hdwdk2,...
                                  d2Hdydx,d3Hdwdydx);

  endif    

endfunction
