function Fk=gkyp_find_z_basis(A,B)
% Fk=gkyp_find_z_basis(A,B)
% Find the basis matrixes of the lagrange multiplier matrix in the
% dual of the discrete-time KYP lemma with the Schur complement of Theta.
% Inputs:
%   A,B - from the state variable description, zx=Ax+Bu
% Outputs:
%   Fk - cell array of basis matrixes
  
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

  if (nargin ~= 2) || (nargout>2)
    print_usage("Fk=gkyp_find_z_basis(A,B)");
  endif
  if rows(A) ~= columns(A),
    error("rows(A) ~= columns(A)");
  endif
  if columns(B) ~= 1,
    error("columns(B) ~= 1");
  endif
  if rows(A) ~= rows(B),
    error("rows(A) ~= rows(B)");
  endif

  % For KYP with Schur complement of Theta (unknown FIR coefficients in [C,D])
  N=rows(A);
  Fk=cell(1,N+2+N+2);
  % Basis for adjoint matrixes
  for k=1:N
    Ek12=zeros(N,1);
    Ek12(k)=1;
    Ek11=dlyap(A,(B*(Ek12')*(A'))+(A*Ek12*(B')));
    Fk{k}=sparse([[Ek11,Ek12,zeros(N,1)];[Ek12',0,0];[zeros(1,N+2)]]);
  endfor
  Ek11=dlyap(A,(B*(B')));
  Fk{N+1}=sparse([[Ek11,zeros(N,2)];[zeros(2,N+2)]]);
  Fk{N+2}=sparse([[zeros(N,N+2)];[zeros(2,N),[1,0;0,0]]]);
  % Basis for h and ZR(N+2,N+2)
  for k=1:(N+2),
    Ek13=zeros(N+2,N+2);
    Ek13(N+2,k)=1;
    Ek13(k,N+2)=1;
    Fk{N+2+k}=sparse(Ek13);
  endfor

  % Sanity checks
  sum_Fk=zeros(N+2); for k=1:length(Fk), sum_Fk=sum_Fk+Fk{k}; endfor;
  if any(any(sum_Fk==0))
    error("any(any(sum_Fk==0))");
  endif
  for k=1:length(Fk)
    if ~issymmetric(Fk{k})
      error("~issymmetric(Fk{%d})",k);
    endif
  endfor
  for k=1:length(Fk)
    for l=(k+1):length(Fk)
      if Fk{k} == Fk{l}
        error("Fk{%d} == Fk{%d}",k,l);
      endif
    endfor
  endfor

endfunction
  
