function Z=kyp_expand_z_basis(Fk,z)
% Z=find_expand_z_basis(Fk,z)
% Expand the basis coefficients of the lagrange multiplier matrix
% Inputs:
%   Fk - cell array of basis matrixes
%   z - Lagrange multiplier matrix basis coefficients
  
% Copyright (C) 2026 Robert G. Jenssen
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

  if (nargin ~= 2) || (nargout>1)
    print_usage("Z=kyp_expand_z_basis(Fk,z)");
  endif
  if ~iscell(Fk),
    error("~iscell(Fk)");
  endif
  if length(Fk) ~= length(z),
    error("length(Fk) ~= length(z)");
  endif
  if length(Fk)==0,
    error("length(Fk)==0");
  endif

  NFk=rows(Fk{1});
  for l=1:length(Fk),
    if ~issquare(Fk{l}) || (rows(Fk{l}) ~= NFk),
      error("~issquare(Fk{l}) || (rows(Fk{l}) ~= NFk),");
    endif
  endfor
  
  Z=zeros(NFk,NFk);
  for l=1:length(Fk),
    Z=Z+(z(l)*Fk{l});
  endfor
  
endfunction
  
