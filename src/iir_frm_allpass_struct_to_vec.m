function [xk,Vr,Qr,Rr,na,nc]=iir_frm_allpass_struct_to_vec(x0)
% [xk,Vr,Qr,Rr,na,nc]=iir_frm_allpass_struct_to_vec(x0)
% Convert the structure representation of a frequency response masking
% (FRM) filter to a vector of coefficients to be optimised. The FRM
% filter consists of a model filter with an allpass filter and parallel
% delay and FIR masking filters. The masking filters are assumed to be
% even order (ie: odd length) and symmetric (ie: linear phase).
%
% The fields of x0 are:
%   d - denominator of the allpass branch of the IIR model filter 
%   aa,ac - FIR masking and complementary masking filters with
%           lengths na and nc respectively
%
% The outputs are:
%   xk - vector of gain-pole-zero coefficients for d, a and b
%   Rr - decimation factor of the allpass filter
%   Vr, Qr - number of allpass denominator real and complex poles 
%   na, nc - lengths of FIR masking and complementary masking filters

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

  % Sanity checks
  if (nargin ~= 1) || (nargout ~= 6)
    print_usage("[xk,Vr,Qr,Rr,na,nc]=iir_frm_allpass_struct_to_vec(x0)");
  endif
  if any(isfield(x0,{"R","r","aa","ac"}))==false
    error("Field missing from x0");
  endif
  if length(x0.aa) ~= length(x0.ac)
    error("Expect length(x0.aa) == length(x0.ac)");
  endif
  if rem(length(x0.aa),2) ~= 1
    error("Expect length(x0.aa) to be odd");
  endif
  if rem(length(x0.ac),2) ~= 1
    error("Expect length(x0.ac) to be odd");
  endif
  
  % Convert the allpass filter to gain-pole-zero form
  [rk,Vr,Qr]=tf2a(x0.r);
  Rr=x0.R;

  % Masking filter lengths
  na=length(x0.aa);
  nc=length(x0.ac);

  % Symmetric parts
  una=(na+1)/2;
  unc=(nc+1)/2;
  
  % Done
  rk=rk(:);x0.aa=x0.aa(:);x0.ac=x0.ac(:);
  xk=[rk;x0.aa(una:end);x0.ac(unc:end)];

endfunction
