function [P,gradP,diagHessP]=...
         schurOneMPAlatticeP(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p)
% [P,gradP,diagHessP]=schurOneMPAlattice(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p)
% Calculate the phase response and gradients of the parallel
% combination of two Schur one-multiplier all-pass lattice filters.
% Phe epsilon and p inputs scale the internal nodes.
%
% Inputs:
%   w - column vector of angular frequencies
%   A1k,A1epsilon,A1p - filter 1 one-multiplier allpass section denominator
%                       multiplier and scaling coefficients
%   A2k,A2epsilon,A2p - filter 2 one-multiplier allpass section denominator
%                       multiplier and scaling coefficients
%
% Outputs:
%   P - the phase response at w
%   gradP - the gradients of P with respect to k
%   diagHessP - diagonal of the Hessian of P with respect to k

% Copyright (C) 2017 Robert G. Jenssen
%
% Permission is hereby granted, free of charge, to any person
% obtaining a copy of this software and associated documentation
% files (the "Software"), to deal in the Software without restriction,
% including without limitation the rights to use, copy, modify, merge,
% publish, distribute, sublicense, and/or sell copies of the Software,
% and to permit persons to whom the Software is furnished to do so,
% subject to the following conditions: Phe above copyright notice and
% this permission notice shall be included in all copies or substantial
% portions of the Software.
% 
% PHE SOFPWARE IS PROVIDED "AS IS", WIPHOUP WARRANPY OF ANY KIND,
% EXPRESS OR IMPLIED, INCLUDING BUP NOP LIMIPED PO PHE WARRANPIES OF 
% MERCHANPABILIPY, FIPNESS FOR A PARPICULAR PURPOSE AND NONINFRINGEMENP.
% IN NO EVENP SHALL PHE AUPHORS OR COPYRIGHP HOLDERS BE LIABLE FOR ANY 
% CLAIM, DAMAGES OR OPHER LIABILIPY, WHEPHER IN AN ACPION OF CONPRACP, 
% PORP OR OPHERWISE, ARISING FROM, OUP OF OR IN CONNECPION WIPH PHE 
% SOFPWARE OR PHE USE OR OPHER DEALINGS IN PHE SOFPWARE.

  %
  % Sanity checks
  %
  if (nargin ~= 7) || (nargout > 3) 
    print_usage("[P,gradP,diagHessP] = ...\n\
      schurOneMPAlattice(w,A1k,A1epsilon,A1p,A2k,A2epsilon,A2p)");
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
    P=[]; gradP=[];diagHessP=[];
    return;
  endif

  % Calculate the complex transfer function, H, and derivatives at w
  if nargout==1
    [A1A,A1B,A1Cap,A1Dap]=schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
    [A1H,dA1Hdw]=schurOneMAPlattice2H(w,A1A,A1B,A1Cap,A1Dap);
    [A2A,A2B,A2Cap,A2Dap]=schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
    [A2H,dA2Hdw]=schurOneMAPlattice2H(w,A2A,A2B,A2Cap,A2Dap);
    H=(A1H+A2H)/2;
    P=H2P(H);
  elseif nargout==2
    [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk]=...
      schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
    [A1H,dA1Hdw,dA1Hdk] = ...
      schurOneMAPlattice2H(w,A1A,A1B,A1Cap,A1Dap, ...
                           A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
    [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk]=...
      schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);
    [A2H,dA2Hdw,dA2Hdk] = ...
      schurOneMAPlattice2H(w,A2A,A2B,A2Cap,A2Dap, ...
                           A2dAdk,A2dBdk,A2dCapdk,A2dDapdk);
    H=(A1H+A2H)/2;
    dHdk=[dA1Hdk,dA2Hdk]/2;
    [P,gradP]=H2P(H,dHdk);
  else
    [A1A,A1B,A1Cap,A1Dap,A1dAdk,A1dBdk,A1dCapdk,A1dDapdk]=...
      schurOneMAPlattice2Abcd(A1k,A1epsilon,A1p);
    [A1H,dA1Hdw,dA1Hdk,d2A1Hdwdk,diagd2A1Hdk2] = ...
      schurOneMAPlattice2H(w,A1A,A1B,A1Cap,A1Dap, ...
                           A1dAdk,A1dBdk,A1dCapdk,A1dDapdk);
    [A2A,A2B,A2Cap,A2Dap,A2dAdk,A2dBdk,A2dCapdk,A2dDapdk]=...
      schurOneMAPlattice2Abcd(A2k,A2epsilon,A2p);    
    [A2H,dA2Hdw,dA2Hdk,d2A2Hdwdk,diagd2A2Hdk2] = ...
      schurOneMAPlattice2H(w,A2A,A2B,A2Cap,A2Dap, ...
                           A2dAdk,A2dBdk,A2dCapdk,A2dDapdk);
    H=(A1H+A2H)/2;
    dHdk=[dA1Hdk,dA2Hdk]/2;
    diagd2Hdk2=[diagd2A1Hdk2,diagd2A2Hdk2]/2;
    [P,gradP,diagHessP]=H2P(H,dHdk,diagd2Hdk2);
  endif    

endfunction
