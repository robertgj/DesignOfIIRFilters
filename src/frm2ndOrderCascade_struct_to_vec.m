function [xk,mn,mr,na,nc]=frm2ndOrderCascade_struct_to_vec(x0)
% [xk,mn,mr,na,nc]=frm2ndOrderCascade_struct_to_vec(x0)
% Convert the structure representation of a frequency response masking
% (FRM) filter to a vector of coefficients to be optimised. 
%
% The fields of x0 are:
%   a - numerator of IIR model filter
%   d - denominator of IIR model filter (d(1)=1)
%   aa - masking filter
%   ac - complementary masking filter
%
% The outputs are:
%   xk - vector of coefficients
%   mn - the order of the model filter numerator polynomial
%   mr - the order of the model filter denominator polynomial
%   na - the number of masking filter coefficients
%   nc - the number of complementary masking filter coefficients
%
% The FRM IIR model filter consists of a cascade of second order sections.
% The number of model filter numerator polynomial coefficients is mn+1.
% The number of model filter denominator polynomial coefficients is mr.
% In other words the denominator coefficient of z^0 is 1. The FIR
% masking filters are assumed to be symmetric (linear phase).

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
  if (nargin ~= 1) || ((nargout ~= 1) && (nargout ~= 5))
    print_usage("[xk,mn,mr,na,nc]=frm2ndOrderCascade_struct_to_vec(x0)");
  endif
  if all(isfield(x0,{"a","d","aa","ac"}))==false
    error("Field missing from x0");
  endif
  na=length(x0.aa);
  na_is_odd=(mod(na,2)==1);
  nc=length(x0.ac);
  nc_is_odd=(mod(nc,2)==1);
  if na_is_odd ~= nc_is_odd
    error("na_is_odd ~= nc_is_odd");
  endif

  % Only copy the unique coefficients of the FIR masking filters
  % Masking filter
  if na_is_odd
    una=(na+1)/2;
  else
    una=na/2;
  endif 
  aak=x0.aa(1:una);
  aak=flipud(aak(:));
  % Complementary masking filter
  if nc_is_odd
    unc=(nc+1)/2;
  else
    unc=nc/2;
  endif 
  ack=x0.ac(1:unc);
  ack=flipud(ack(:));

  % Model filter numerator  coefficients 
  ak=x0.a(:);
  mn=length(ak)-1;

  % Convert the model filter denominator to second order sections
  dk=tf2casc(x0.d(:));
  dk=dk(:);
  mr=length(dk);

  % Done
  xk=[ak;dk;aak;ack];

endfunction
