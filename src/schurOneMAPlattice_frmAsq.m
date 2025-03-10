function [Asq,gradAsq] = ...
           schurOneMAPlattice_frmAsq(w,k,epsilon,p,u,v,Mmodel,Dmodel)
% [Asq,gradAsq] = schurOneMAPlattice_frmAsq(w,k,epsilon,p,u,v,Mmodel,Dmodel)
% Calculate the squared-amplitude response and gradients of the
% response with respect to the coefficients of an FRM filter in which the
% model filter consists of a Schur one-multiplier lattice all-pass filter
% in  parallel with a delay in the Johansson and Wanhammar structure. The
% FIR masking filters are assumed to be odd length (ie: even order) and
% symmetric (linear phase).
% 
% Inputs:
%   w - angular frequencies for response
%   k - all-pass filter one-multiplier lattice filter coefficients
%   epsilon, p - one-multiplier lattice scaling coefficients
%   u,v - distinct symmetric, even order FIR masking filter coefficients
%         (with aa=[u(end:-1:2);u] and ac=[v(end:-1:2);v])
%   Mmodel - decimation factor of the all-pass model filter
%   Dmodel - delay of the pure delay branch of the model filter
%
% Outputs:
%   Asq - squared-amplitude response at angular frequencies w
%   gradAsq - gradient of Asq at w

% Copyright (C) 2019-2025 Robert G. Jenssen
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
  if (nargin ~= 8) || (nargout > 2)
    print_usage (["[Asq,gradAsq]= ...\n", ...
 "  schurOneMAPlattice_frmAsq(w,k,epsilon,p,u,v,Mmodel,Dmodel);"]);
  endif
  
  if nargout == 0
    % Do nothing
    return;
  elseif nargout == 1
    Asq=schurOneMAPlattice_frm(w,k,epsilon,p,u,v,Mmodel,Dmodel);
  else 
    [Asq,~,~,gradAsq]=schurOneMAPlattice_frm(w,k,epsilon,p,u,v,Mmodel,Dmodel);
  endif
  
endfunction  
