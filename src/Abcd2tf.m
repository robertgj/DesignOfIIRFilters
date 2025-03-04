function [N,D,B]=Abcd2tf(A,b,c,d)
% [N,D,B]=Abcd2tf(A,b,c,d)
%
% Use Le Verrier's algorithm to find the transfer function
% H(z)=[N(z)/D(z)]=c*[(zI-A)^{-1}]*b+d where[A,b;c,d] is the real valued
% single-input and single-output state variable description. D(z) is the
% characteristic equation of A. B is a length (n=rows(A))+1 cell array
% of nxn matrixes in which B{k} is the k'th matrix coefficient of the
% resolvent (zI-A)^{-1}.
%
% See Appendix 8A, pp. 332-333 of "Digital Signal Processing", R.A. Roberts
% and C.T. Mullis, Addison-Wesley ISBN 0-201-16350-0

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
  if (nargin ~= 4) || (nargout~=2) && (nargout~=3)
    print_usage("[N,D,B]=Abcd2tf(A,b,c,d)");
  endif
  if isempty(A)
    error("A is empty");
  endif
  if rows(A) ~= columns(A)
    error("Expect A square");
  endif
  if columns(b) ~= 1 || rows(A) ~= rows(b) 
    error("Expect b rows(A)x1 column vector");
  endif
  if columns(c) ~= columns(A) || rows(c) ~= 1 
    error("Expect c 1xcolumns(A) row vector");
  endif
  if columns(d) ~= 1 || rows(d) ~= 1 
    error("Expect d a scalar");
  endif

  % Use Le Verrier's algorithm to find the characteristic polynomial of A
  % and calculate the coefficients of N at the same time
  nA=rows(A);
  nN=nA+1;
  N=zeros(1,nN);
  D=[1,zeros(1,nA)];
  BB=eye(nA);
  B=cell(1,nN);
  B{1}=BB;
  for k=1:nA
    N(k+1)=c*BB*b;
    D(k+1)=-trace(A*BB)/k;
    BB=(A*BB)+(D(k+1)*eye(nA));
    B{k+1}=BB;
  endfor
  
  % Complete the numerator
  N=(d*D)+N;

endfunction
