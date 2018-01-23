function x1=iir_frm_parallel_allpass_vec_to_struct(xk,Vr,Qr,Vs,Qs,na,nc)
% x1=iir_frm_parallel_allpass_struct_to_vec(xk,Vr,Qr,Vs,Qs,na,nc)
% Convert the structure representation of a frequency response masking
% (FRM) filter to a vector of coefficients to be optimised. The FRM
% filter consists of a model filter with parallel allpass filters
% and FIR masking filters.
%
% The fields of x1 are:
%   r,s - denominators of the parallel allpass IIR model filter
%   aa,ac - FIR masking and complementary masking filters 
%
% The outputs are:
%   xk - vector of coefficients
%   Vr,Qr,Vs,Qs - numbers of allpass denominator real and complex poles 
%   na,nc - lengths of FIR masking and complementary masking filters

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

  % Sanity checks
  if (nargin ~= 7) || (nargout ~= 1)
    print_usage(...
      "x0=iir_frm_parallel_allpass_struct_to_vec(xk,Vr,Qr,Vs,Qs,na,nc)");
  endif
  if length(xk) ~= (Vr+Qr+Vs+Qs+na+nc)
    error("Expected length(xk) == (Vr+Qr+Vs+Qs+na+nc)");
  endif
  
  % Convert the allpass filters to polynomial form
  [numr,x1.r]=a2tf(xk(1:(Vr+Qr)),Vr,Qr,1);
  [nums,x1.s]=a2tf(xk((Vr+Qr+1):(Vr+Qr+Vs+Qs)),Vs,Qs,1);

  % Copy the masking filters
  x1.aa=xk((Vr+Qr+Vs+Qs+1):(Vr+Qr+Vs+Qs+na));
  x1.aa=x1.aa(:);
  x1.ac=xk((Vr+Qr+Vs+Qs+na+1):(Vr+Qr+Vs+Qs+na+nc));
  x1.ac=x1.ac(:);
  
endfunction
