function Theta=kyp_find_symmetric_Theta_basis(M)
% Theta=kyp_find_Theta_basis(M)
% Find the basis matrixes of the Theta matrix in the discrete-time KYP lemma
% Inputs:
%   M - length(C)/2
% Outputs:
%   Theta - cell array of basis matrixes
  
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

  if (nargin ~= 1) || (nargout>2)
    print_usage("Theta=kyp_find_symmetric_Theta_basis(M)");
  endif

  N=2*M;
  Theta=cell(1,M+2);
  for k=1:(M+1), 
    Theta{k}=sparse(zeros(N+2,N+2));
    Theta{k}(N+2,k)=1;
    Theta{k}(N+2,N+2-k)=1;
    Theta{k}(k,N+2)=1;
    Theta{k}(N+2-k,N+2)=1;
  endfor
  Theta{M+1+1}=sparse(zeros(N+2,N+2));
  Theta{M+1+1}(N+1,N+1)=-1;


endfunction
  
