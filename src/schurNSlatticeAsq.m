function [Asq,gradAsq,diagHessAsq]=schurNSlatticeAsq(w,s10,s11,s20,s00,s02,s22)
% [Asq,gradAsq,diagHessAsq]=schurNSlatticeAsq(w,s10,s11,s20,s00,s02,s22)
% Calculate the squared-magnitude response and gradients of a Schur
% scaled-normalised lattice filter. 
%
% Inputs:
%   w - column vector of angular frequencies
%   s10,s11,s20,s00,s02,s22 - lattice coefficients
%
% Outputs:
%   Asq - the squared magnitude response at w
%   gradAsq - the gradients of Asq at w
%   diagHessAsq - diagonal of the Hessian of Asq at w

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
  if (nargin ~= 7) || (nargout > 3) 
    print_usage ...
      ("[Asq,gradAsq,diagHessAsq]=schurNSlatticeAsq(w,s10,s11,s20,s00,s02,s22)");
  endif
  if length(s10) ~= length(s11)
    error("length(s10) ~= length(s11)");
  endif
  if length(s10) ~= length(s20)
    error("length(s10) ~= length(s20)");
  endif
  if length(s10) ~= length(s00)
    error("length(s10) ~= length(s00)");
  endif
  if length(s10) ~= length(s02)
    error("length(s10) ~= length(s02)");
  endif
  if length(s10) ~= length(s22)
    error("length(s10) ~= length(s22)");
  endif
  if length(w) == 0
    Asq=[]; gradAsq=[]; diagHessAsq=[];
    return;
  endif

  % Calculate the complex transfer function at w
  if nargout==1 
    [A,B,C,D]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
    H=Abcd2H(w,A,B,C,D);
    Asq=H2Asq(H);
  elseif nargout==2 
    [A,B,C,D,Cap,Dap,dAds,dBds,dCds,dDds] = ...
      schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
    [H,dHdw,dHds]=Abcd2H(w,A,B,C,D,dAds,dBds,dCds,dDds);
    [Asq,gradAsq]=H2Asq(H,dHds);
  elseif nargout==3
    [A,B,C,D,Cap,Dap,dAds,dBds,dCds,dDds]=...
      schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
    [H,dHdw,dHds,d2Hdwds,diagd2Hds2]=Abcd2H(w,A,B,C,D,dAds,dBds,dCds,dDds);
    [Asq,gradAsq,diagHessAsq]=H2Asq(H,dHds,diagd2Hds2);
  endif
   
endfunction
