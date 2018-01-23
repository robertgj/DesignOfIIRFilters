function [T,gradT,diagHessT]=schurNSlatticeT(w,s10,s11,s20,s00,s02,s22)
% [T,gradT,diagHessT]=schurNSlatticeT(w,s10,s11,s20,s00,s02,s22)
% Calculate the group delay response and gradients of a Schur
% scaled-normalised lattice filter. 
%
% Inputs:
%   w - column vector of angular frequencies
%   s10,s11,s20,s00,s02,s22 - lattice coefficients
%
% Outputs:
%   T - the group delay response at w
%   gradT - the gradients of T at w
%   diagHessT - diagonal of the Hessian of T at w

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
  if (nargin ~= 7) || (nargout > 3) 
    print_usage ...
      ("[T,gradT,diagHessT]=schurNSlatticeT(w,s10,s11,s20,s00,s02,s22)");
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
    T=[]; gradT=[]; diagHessT=[];
    return;
  endif

  % Calculate the complex transfer function at w
  if nargout==1 
    [A,B,C,D]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
    [H,dHdw]=Abcd2H(w,A,B,C,D);
    T=H2T(H,dHdw);
  elseif nargout==2 
    [A,B,C,D,Cap,Dap,dAds,dBds,dCds,dDds] = ...
      schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
    [H,dHdw,dHds,d2Hdwds]=Abcd2H(w,A,B,C,D,dAds,dBds,dCds,dDds);
    [T,gradT]=H2T(H,dHdw,dHds,d2Hdwds);
  elseif nargout==3
    [A,B,C,D,Cap,Dap,dAds,dBds,dCds,dDds]=...
      schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
    [H,dHdw,dHds,d2Hdwds,diagd2Hds2,diagd3Hdwds2]=...
      Abcd2H(w,A,B,C,D,dAds,dBds,dCds,dDds);
    [T,gradT,diagHessT]=H2T(H,dHdw,dHds,d2Hdwds,diagd2Hds2,diagd3Hdwds2);
  endif
   
endfunction
