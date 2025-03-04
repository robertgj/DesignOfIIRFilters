function [G0prime,Tq,Fq,Fsign]=orthogonaliseTF(n,d)
% [G0doubleprime,Tq,Fq,Fsign]=factorTF(n,d)
% Given a transfer function represented by the polynomials
% n and d, make a factored state variable description, Ftq, 
% a series of orthogonal matrixes representing 2x2 coordinate 
% rotations comprising a two-input, two-output all-pass filter.
% The G0prime matrix converts the all-pass output to the 
% desired transfer function. Tq and Fq are 2x2 block diagonal
% rotation matrixes and Fsign is a diagonal matrix of +/-1

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

% Construct the factored output filter matrix Gdoubleprime by:
%{
  [G0prime,Tq,Fq,Fsign]=orthogonaliseTF(n,d)
  Fdoubleprime=Fsign;
  for q=length(Fq):-1:1
    Fdoubleprime=Fdoubleprime*Fq{q}';
  endfor
  Gdoubleprime=G0prime*Fdoubleprime;
%}
  
% Check arguments
if nargin~=2 || nargout~=4
  print_usage("[G0prime,Tq,Fq,Fsign]=orthogonaliseTF(n,d)");
endif

% Find the state variable representation for which K=I
if 1
  % One-multiplier Schur decomposition appears least sensitive
  [k,epsilon,p,c] = tf2schurOneMlattice(n,d);
  [sA,sB,sC,sD,sCap,sDap]=schurOneMlattice2Abcd(k,epsilon,p,c);
elseif 0
  % Scaled-normalised Schur decomposition
  [s10,s11,s20,s00,s02,s22]=tf2schurNSlattice(n,d);
  [sA,sB,sC,sD,sCap,sDap]=schurNSlattice2Abcd(s10,s11,s20,s00,s02,s22);
else
  % Direct method is less accurate
  % Test with "N=3;dbap=0.1;dbas=20;fc=0.05;[n,d]=ellip(N,dbap,dbas,2*fc);"
  [A,B,C,D]=tf2Abcd(n,d);
  [A,B,Cap,Dap]=tf2Abcd(fliplr(d),d);
  [K,Wap]=KW(A,B,Cap,Dap);
  [U,S]=schur(K);
  % We want T such that T^(-1) * K * T^(-1)' = I
  % The diagonal of S contains the eigenvalues of K = U * S * U'
  % See Golub & Van Loan p.313 .
  T=U*diag(sqrt(diag(S)));
  invT=inv(T);
  % Sanity check on accuracy
  normK_I=norm(invT*K*invT'-eye(size(K)),inf)/eps;
  if normK_I > 100
    error("norm(invT*K*invT'-eye(size(K)),2)/eps > 100 !");
  endif
  sA=invT*A*T;
  sB=invT*B;
  sCap=Cap*T;
  sDap=Dap;
  sC=C*T;
  sD=D;
endif

% Find the factor that converts F to the required transfer function
G=[sA,sB;sC,sD];
F=[sA,sB;sCap,sDap];
[G0prime,Fprime]=C1D1FToG0primeFprime(sC,sD,F);

% Zero all diagonals below the second subdiagonal
% Fdoubleprime = Fprime * Tprime
Tq=FprimeToFdoubleprime(Fprime);
Tprime=eye(size(F));
for q=1:length(Tq)
  Tprime=Tprime*Tq{q};
endfor
Fdoubleprime=Tprime'*Fprime*Tprime;

% Factor F into 2x2 rotations returned in the cell array Fq
% The +/-1 factors are on the diagonal of Fsign
[Fq,Fsign]=factorFdoubleprime(Fdoubleprime);

endfunction
