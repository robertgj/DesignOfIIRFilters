function Qadj=kyp_Q_adjoint(Z,A,B,Psi)
% Qadj=kyp_Q_adjoint(Z,A,B,Psi)
% Find the adjoint of the Q matrix in the discrete-time KYP lemma
% Inputs:
%   Z - the Lagrange multiplier matrix for the dual of the KYP lemma
%   A,B - from the state variable description, zx=Ax+Bu
%   Psi - frequency specification matrix
  
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

  if (nargin~=4) || (nargout>1)
    print_usage("Qadj=kyp_Q_adjoint(Z,A,B,Psi)");
  endif
  
  N=rows(A);
  if N~=columns(A)
    error("Expect A square N by N");
  endif
  if columns(B)~=1 || rows(B)~=N
    error("Expect B column vector");
  endif
  if ~issquare(Z) || (N>=rows(Z)) 
    error("Expect Z square, N>=rows(Z)");
  endif
  if 2~=columns(Psi) || 2~=rows(Psi)
    error("Expect Psi square 2 by 2");
  endif

  Z11=Z(1:N,1:N);
  Z12=Z(1:N,N+1);
  Z22=Z(N+1,N+1);
  Qadj=(Psi(1,2)*Z11*(A'))+(Psi(2,1)*A*Z11)+(Psi(2,2)*Z11)+ ...
       (Psi(2,1)*B*(Z12'))+(Psi(1,2)*Z12*(B'));
  
endfunction

