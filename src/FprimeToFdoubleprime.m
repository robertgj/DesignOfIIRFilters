function Tq=FprimeToFdoubleprime(Fprime)
% Tq=FprimeToFdoubleprime(Fprime)
% Given an orthogonal matrix, Fprime, Find the similarity transformation, 
% Tprime, that zeros all diagonals below the second sub-diagonal.
% Tprime is returned as a cell array of 2x2 block diagonal rotation
% matrixes.

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
if (nargin ~= 1) || (nargout ~= 1)
   print_usage("Tq=FprimeToFdoubleprime(Fprime)");
endif
if rows(Fprime) ~= columns(Fprime)
  error("F1 not square!");
endif

% Zero the elements below the second sub-diagonal.
% Order by rows starting at the bottom left corner.
tol=10*eps;
N=rows(Fprime);
Tprime=eye(N,N);
Fdoubleprime=Fprime;
% Number of rotations is a triangular number, T(N-3) where Tn=n(n+1)/2
Tq=cell((N-3)*(N-2)/2,1);
q=1;
for row=(N-1):-1:2
  for col=1:(row-2) 
    nextTprime=eye(N,N);
    if abs(Fdoubleprime(row+1,col)) < tol
      ;
    elseif abs(Fdoubleprime(row+1,col+1)) > tol
      % Zero matrix entry from the right
      theta=atan(Fdoubleprime(row+1,col)/Fdoubleprime(row+1,col+1));
      nextTprime(col:col+1,col:col+1)=[ cos(theta),sin(theta);...
                                       -sin(theta),cos(theta)];
    elseif abs(Fdoubleprime(row,col)) > tol
     % Zero matrix entry from the left
     theta=atan(Fdoubleprime(row+1,col)/Fdoubleprime(row,col));
      nextTprime(col:col+1,col:col+1)=[ cos(theta),-sin(theta);...
                                        sin(theta), cos(theta)];        
    else
      error("Can not zero Fprime(%d,%d)", row, col);
    endif
    % Do rotation
    Fdoubleprime=inv(nextTprime)*Fdoubleprime*nextTprime;
    Tprime=Tprime*nextTprime;
    % Store this 2x2 rotation
    Tq{q}=nextTprime;
    q=q+1;
  endfor
endfor

endfunction
