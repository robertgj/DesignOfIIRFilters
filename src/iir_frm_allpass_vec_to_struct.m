function x1=iir_frm_allpass_vec_to_struct(xk,Vr,Qr,Rr,na,nc)
% x1=iir_frm_allpass_vec_to_struct(xk,Vr,Qr,Rr,na,nc)
% Convert the vector of coefficients representation of a frequency response
% masking (FRM) filter to the structure representation. The FRM
% filter consists of a model filter with an allpass filter in parallel
% with a pure delay and linear phase odd length FIR masking filters.
%
% The inputs are:
%   xk - vector of coefficients
%   Vr,Qr - number of allpass filter denominator real and complex poles
%   Rr - decimation factor of the allpass filter
%   na,nc - masking filter lengths
%
% The fields of x1 are:
%   R - decimation factor of the allpass branch of the model filter
%   r - denominator of the allpass branch of the model filter
%   aa,ac - FIR masking filters
%

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
  if (nargin ~= 6) || (nargout ~= 1)
    print_usage("x1=iir_frm_allpass_vec_to_struct(xk,Vr,Qr,Rr,na,nc)");
  endif
  if rem(na,2) ~= 1
    error("Expected na to be odd");
  endif
  if rem(nc,2) ~= 1
    error("Expected nc to be odd");
  endif
  
  % Convert the allpass filter to polynomial form
  x1.R=Rr;
  [numd,x1.r]=a2tf(xk(1:(Vr+Qr)),Vr,Qr,1);

  % Convert the masking filter to symmetric form
  x1.aa=zeros(na,1);
  una=(na+1)/2;
  x1.aa(una:na)=xk((Vr+Qr+1):(Vr+Qr+una));
  x1.aa(1:una)=x1.aa(na:-1:una);
  x1.aa=x1.aa(:);

  % Convert the complementary masking filter to symmetric form
  x1.ac=zeros(nc,1);
  unc=(nc+1)/2;
  x1.ac(unc:nc)=xk((Vr+Qr+una+1):(Vr+Qr+una+unc));
  x1.ac(1:unc)=x1.ac(nc:-1:unc);
  x1.ac=x1.ac(:);
  
endfunction
