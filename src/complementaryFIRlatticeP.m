function [P,gradP]=complementaryFIRlatticeP(w,k,khat)
% [P,gradP]=complementaryFIRlatticeP(w,k,khat)
% Calculate the phase response and gradients of a complementary
% FIR lattice filter. If the order of the filter polynomial is N, then there
% are N+1 lattice k and khat coefficients. This function only considers the
% response and gradients at the filter output and not the response at the
% complementary filter output.
%
% Inputs:
%   w - column vector of angular frequencies
%   k,khat - complementary FIR lattice coefficients
%
% Outputs:
%   P - the phase response at w
%   gradP - the gradients of P with respect to k and khat

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
  if (nargin ~= 3) || (nargout > 2) 
    print_usage("[P,gradP]=complementaryFIRlatticeP(w,k,khat)");
  endif
  if length(k) ~= length(khat)
    error("length(k) ~= length(khat)");
  endif
  if length(w) == 0
    P=[]; gradP=[];
    return;
  endif

  if nargout==1 
    [A,B,Ch,Dh]=complementaryFIRlattice2Abcd(k,khat);
    H=Abcd2H(w,A,B,Ch,Dh);
    P=H2P(H);  
  elseif nargout==2 
    [A,B,Ch,Dh,Cg,Dg,dAdkkhat,dBdkkhat,dChdkkhat,dDhdkkhat] = ...
      complementaryFIRlattice2Abcd(k,khat);
    [H,dHdw,dHdkkhat]=Abcd2H(w,A,B,Ch,Dh,dAdkkhat,dBdkkhat,dChdkkhat,dDhdkkhat);
    [P,gradP]=H2P(H,dHdkkhat);
  endif
   
endfunction
