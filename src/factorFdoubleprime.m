function [Fq,Fsign]=factorFdoubleprime(Fpp)
% [Fq,Fsign]=factorFdoubleprime(Fpp)
% Given an orthogonal matrix, Fpp, with all zeros below the 2nd 
% sub-diagonal, find the primitive factorisation of Fpp.

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

% Check arguments
if nargin~=1 || nargout~=2
  print_usage("[Fq,Fsign]=factorFdoubleprime(Fpp)");
endif

% Sanity check
if rows(Fpp) ~= columns(Fpp)
  error("Fpp not square!");
endif

% Initialise
tol=10*eps;
N=rows(Fpp);
q=1;
Fq=cell(2*N-3,1);
Fsign=cell(2*N-3,1);

% Zero second sub-diagonal
row=N-1;
col=N-2;
for k=1:N-2

  if abs(Fpp(row+1,col+1)) < tol
    nextT=eye(size(Fpp));
  else
    theta=atan(Fpp(row+1,col)/Fpp(row+1,col+1));
    nextT=eye(size(Fpp));
    nextT(col:col+1,col:col+1)=[ cos(theta),sin(theta);...
                                -sin(theta),cos(theta)]; 
    Fpp=Fpp*nextT;
  endif

  % Store nextT
  Fq{q}=nextT;
  q=q+1;
  row=row-1;
  col=col-1;
endfor

% Zero first sub-diagonal
row=N-1;
col=N-1;
for k=1:N-1

  if abs(Fpp(row+1,col+1)) < tol
    nextT=eye(size(Fpp));
  else
    theta=atan(Fpp(row+1,col)/Fpp(row+1,col+1));
    nextT=eye(size(Fpp));
    nextT(col:col+1,col:col+1)=[ cos(theta),sin(theta);...
                                -sin(theta),cos(theta)];
    Fpp=Fpp*nextT;
  endif

  % Store nextT
  Fq{q}=nextT;
  q=q+1;
  row=row-1;
  col=col-1;
endfor

% Sanity check
if any(any((abs(Fpp)-eye(size(Fpp)))>tol))
  error("Fpp element not 0, +1 or -1");
endif
diagFpp=diag(Fpp);
if (abs(diagFpp)-1)>tol
  error("Fpp diagonal element not +1 or -1");
endif

% Return +1,-1 signs on the diagonal
Fsign = Fpp;

endfunction
