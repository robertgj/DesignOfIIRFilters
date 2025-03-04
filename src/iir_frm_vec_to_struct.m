function x0=iir_frm_vec_to_struct(xk,Uad,Vad,Mad,Qad,na,nc)
% x0=iir_frm_vec_to_struct(xk,Uad,Vad,Mad,Qad,na,nc)
% Convert the vector representation of a frequency response masking
% (FRM) filter to a structure of filter polynomials. The FRM
% IIR model filter is expressed in gain-zero-pole form.
% The FIR masking filters are assumed to be symmetric (linear phase).
% The input variables are:
%  xk - the vector of coefficients
%   Uad,Vad,Mad,Qad - number of model filter real and complex poles and zeros
%   na - the number of masking filter coefficients
%   nc - the number of complementary masking filter coefficients
% The fields of x0 are:
%   a - numerator of IIR model filter
%   d - denominator of IIR model filter (d(1)=1, no decimation)
%   aa - masking filter
%   ac - complementary masking filter

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
  if (nargin ~= 7) || (nargout ~= 1)
    print_usage("x0=iir_frm_vec_to_struct(xk,Uad,Vad,Mad,Qad,na,nc)");
  endif
  if isempty(xk)
    error("xk is empty!");
  endif
  % Check lengths of aa and ac
  na_is_odd=(mod(na,2)==1);
  nc_is_odd=(mod(nc,2)==1);
  if na_is_odd ~= nc_is_odd
    error("na_is_odd ~= nc_is_odd");
  endif
  % Check length of xk
  if na_is_odd
    una=(na+1)/2;
  else
    una=na/2;
  endif 
  if nc_is_odd
    unc=(nc+1)/2;
  else
    unc=nc/2;
  endif
  nfir=una+unc;
  niir=1+Uad+Vad+Mad+Qad;
  if length(xk) ~= (niir+nfir)
    error("length(xk) ~= ((1+Uad+Vad+Mad+Qad) + una + unc)");
  endif

  % Extract model filter gain-pole-zero coefficients
  [x0.a,x0.d]=x2tf(xk(1:niir),Uad,Vad,Mad,Qad,1);
  
  % Extract masking filter
  x0.aa=zeros(na,1);
  x0.aa(una:-1:1)=xk((niir+1):(niir+una));
  if na_is_odd
    x0.aa(na:-1:una)=x0.aa(1:una);
  else
    x0.aa(na:-1:(una+1))=x0.aa(1:una);
  endif
  x0.aa=x0.aa(:);

  % Extract complementary masking filter
  x0.ac=zeros(nc,1);
  x0.ac(unc:-1:1)=xk((niir+una+1):(niir+una+unc));
  if nc_is_odd
    x0.ac(nc:-1:unc)=x0.ac(1:unc);
  else
    x0.ac(nc:-1:(unc+1))=x0.ac(1:unc);
  endif
  x0.ac=x0.ac(:);

endfunction
