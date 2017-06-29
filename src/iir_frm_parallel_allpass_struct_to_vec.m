function [xk,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x0)
% [xk,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x0)
% Convert the structure representation of a frequency response masking
% (FRM) filter to a vector of coefficients to be optimised. The FRM
% filter consists of a model filter with parallel allpass filters
% and FIR masking filters.
%
% The fields of x0 are:
%   r,s - denominators of the parallel allpass IIR model filter
%   aa,ac - FIR masking and complementary masking filters with
%           lengths na and nc respectively
%
% The outputs are:
%   xk - vector of gain-pole-zero coefficients for r,s,a and b
%   Vr,Qr,Vs,Qs - numbers of allpass denominator real and complex poles 
%   na,nc - lengths of FIR masking and complementary masking filters

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

  % Sanity checks
  if (nargin ~= 1) || (nargout ~= 7)
    print_usage(...
      "[xk,Vr,Qr,Vs,Qs,na,nc]=iir_frm_parallel_allpass_struct_to_vec(x0)");
  endif
  if all(isfield(x0,{"r","s","aa","ac"}))==false
    error("Field missing from x0");
  endif

  % Convert the allpass filters to gain-pole-zero form
  [rk,Vr,Qr]=tf2a(x0.r);
  [sk,Vs,Qs]=tf2a(x0.s);

  % Masking filter lengths
  na=length(x0.aa);
  nc=length(x0.ac);

  % Done
  xk=[rk(:);sk(:);x0.aa(:);x0.ac(:)];

endfunction
