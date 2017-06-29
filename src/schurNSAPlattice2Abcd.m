function [A,B,Cap,Dap,dAds,dBds,dCapds,dDapds]=...
         schurNSAPlattice2Abcd(s20,s00,s02,s22)
% [A,B,Cap,Dap,dAds,dBds,dCapds,dDapds]=schurNSAPlattice2Abcd(s20,s00,s02,s22)
%
% Calculate the state-variable matrixes and gradients of a
% normalised-scaled allpass Schur lattice filter. The gradients are
% returned in cell arrays ordered by section. For example, dAds is :
%    {dAds20_1,...,dAds22_1,dAds20_2,...,dAds22_Ns}
%
% Inputs:
%   s20,s00,s02,s22 - normalised-scaled allpass Schur lattice coefficients
% Outputs:
%   [A,B;Cap,Dap] - the state-variable matrixes
%   dAds,dBds,dCapds,dDapds - the gradients of the state variable matrixes

% Copyright (C) 2017 Robert G. Jenssen
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
  if (nargout>8) || (nargin<4)
    print_usage...
("[A,B,Cap,Dap,dAds,dBds,dCapds,dDapds]=schurNSAPlattice2Abcd(s20,s00,s02,s22)");
  endif
  if length(s20) ~= length(s00)
    error("length(s20) ~= length(s00)");
  endif
  if length(s20) ~= length(s02)
    error("length(s20) ~= length(s02)");
  endif
  if length(s20) ~= length(s22)
    error("length(s20) ~= length(s22)");
  endif
  if isempty(s20)
    error("Input coefficient arrays are empty");    
  endif
  
  % Calculate the state-variable matrixes and gradients of the
  % corresponding normalised-scaled Schur lattice filter.
  s10_dummy=zeros(size(s20));
  s11_dummy=zeros(size(s20));
  [A,B,Cdummy,Dummy,Cap,Dap, ...
   dAdx,dBdx,dCdummyds,dDdummyds,dCapdx,dDapdx]=...
    schurNSlattice2Abcd(s10_dummy,s11_dummy,s20,s00,s02,s22);
  
  % Remove the dummy gradients
  Ns=length(s20);
  dAds=cell(1,Ns*4);
  dBds=cell(1,Ns*4);
  dCapds=cell(1,Ns*4);
  dDapds=cell(1,Ns*4);
  for l=1:Ns
    for n=1:4
      dAds{((l-1)*4)+n}=dAdx{((l-1)*6)+2+n};
      dBds{((l-1)*4)+n}=dBdx{((l-1)*6)+2+n};
      dCapds{((l-1)*4)+n}=dCapdx{((l-1)*6)+2+n};
      dDapds{((l-1)*4)+n}=dDapdx{((l-1)*6)+2+n};
    endfor
  endfor
  
endfunction
