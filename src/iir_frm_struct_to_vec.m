function [xk,Uad,Vad,Mad,Qad,na,nc]=iir_frm_struct_to_vec(x0)
% [xk,Uad,Vad,Mad,Qad,na,nc]=iir_frm_struct_to_vec(x0)
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
%   Uad,Vad,Mad,Qad - number of model filter real and complex poles and zeros 
%   na - the number of masking filter coefficients
%   nc - the number of complementary masking filter coefficients
%
% The FIR masking filters are assumed to be symmetric (linear phase).

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
    print_usage("[xk,Uad,Vad,Mad,Qad,na,nc]=iir_frm_struct_to_vec(x0)");
  endif
  if all(isfield(x0,{"a","d","aa","ac"}))==false
    error("Field missing from x0");
  endif
  na=length(x0.aa);
  na_is_odd=(mod(na,2)==1);
  nc=length(x0.ac);
  nc_is_odd=(mod(nc,2)==1);
  if na_is_odd != nc_is_odd
    error("na_is_odd != nc_is_odd");
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

  % Convert the model filter to gain-pole-zero form
  [adk,Uad,Vad,Mad,Qad]=tf2x(x0.a,x0.d);
  adk=adk(:);
  
  % Done
  xk=[adk;aak;ack];

endfunction
